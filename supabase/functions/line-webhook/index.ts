
// 上傳命令：supabase functions deploy line-webhook --no-verify-jwt

import { createClient } from '@supabase/supabase-js'

// 這些機密資訊將從 Supabase 儀表板的環境變數中讀取，非常安全
const CHANNEL_ACCESS_TOKEN = Deno.env.get('LINE_CHANNEL_ACCESS_TOKEN')
// 修正：使用您在 Supabase 儀表板中設定的新變數名稱
const SUPABASE_URL = Deno.env.get('SB_URL')
const SUPABASE_ANON_KEY = Deno.env.get('SB_ANON_KEY')

// 在函式啟動時就檢查必要的環境變數是否存在
if (!CHANNEL_ACCESS_TOKEN || !SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error('Missing required environment variables (LINE_CHANNEL_ACCESS_TOKEN, SB_URL, SB_ANON_KEY). Please check your Supabase function settings.');
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 })
  }

  try {
    // 強健性檢查。如果請求沒有內容 (content-length 為 0 或 null)，
    // 這通常是 LINE 的 "Verify" 測試請求，直接回覆 OK 即可。
    if (!req.headers.get('content-length')) {
      return new Response('OK: No body', { status: 200 });
    }

    const body = await req.json()
    const event = body.events[0]

    console.log('Received event:', JSON.stringify(event, null, 2))
    if (!event) {
      console.log('Received a request without an event (likely a test from LINE).');
      return new Response('OK: No event', { status: 200 });
    }

    console.log('Received event:', JSON.stringify(event, null, 2));

    if (event && event.type === 'message' && event.message.type === 'text') {
      if (event.message.text === '[聯絡資訊]') {        
        replyMessage(event.replyToken, createContactFlexMessage());
      }
      else if (event.message.text === '[確認/取消]') {
        // 修正：改為取得訊息後，使用免費的 replyMessage 回覆
        const message = await getBookingHistoryMessage(event.source.userId);
        await replyMessage(event.replyToken, message);
      }
      else if (event.message.text === '[個人記錄]') {        
        replyMessage(event.replyToken, `「開發中」`)
      }
    }

    // 新增：處理 Postback 事件
    if (event && event.type === 'postback') {
      const postbackData = new URLSearchParams(event.postback.data);
      const action = postbackData.get('action');

      if (action === 'cannot_cancel_paid') {
        // 當使用者點擊已扣款課程的取消按鈕時，回覆提示訊息
        await replyMessage(event.replyToken, '無法取消已扣款的預約，請洽客服。');
      } else if (action === 'request_cancel') {
        // 當使用者點擊「已預約」課程的取消按鈕時，先檢查時效性
        const bookingId = postbackData.get('bookingId');
        if (bookingId) {
          const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
          const { data: booking, error } = await supabaseClient
            .from('bookings')
            .select('classes(class_date, start_time)')
            .eq('booking_id', bookingId)
            .single();

          if (error || !booking || !booking.classes) {
            await replyMessage(event.replyToken, '找不到此預約紀錄，無法取消。');
            return new Response('OK', { status: 200 });
          }

          // 組合課程時間
          const classDateTime = new Date(`${booking.classes.class_date}T${booking.classes.start_time}`);
          const now = new Date();

          // 檢查課程是否已開始或結束
          if (classDateTime < now) {
            await replyMessage(event.replyToken, '此課程已開始或已結束，無法取消。');
          } else {
            // 只有在課程尚未開始時，才回覆確認卡片
            const confirmationMessage = await createCancelConfirmationMessage(bookingId);
            await replyMessage(event.replyToken, confirmationMessage);
          }
        }
      } else if (action === 'confirm_cancel') {
        // 當使用者點擊「確認取消」按鈕時，執行真正的取消操作
        const bookingId = postbackData.get('bookingId');
        const userId = event.source.userId;

        if (bookingId && userId) {
          const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
          // 呼叫後端 RPC 函式來執行原子操作
          const { data, error } = await supabaseClient.rpc('cancel_booking_atomic', {
            p_booking_id: bookingId,
            p_user_id: userId
          });

          if (error || !data || data.length === 0) {
            await replyMessage(event.replyToken, '取消失敗，請稍後再試或聯繫客服。');
          } else {
            await replyMessage(event.replyToken, data[0].message);
          }
        }
      }

    }

    // 3. 無論如何，都立即回傳 200 OK 給 LINE
    return new Response('OK', { status: 200 })

  } catch (error) {
    console.error('處理 Webhook 時發生錯誤:', error)
    // 即使發生錯誤，也回傳 200 OK，避免 LINE 不斷重試
    return new Response('Internal Server Error', { status: 200 })
  }
})

async function getBookingHistoryMessage(userId: string): Promise<any> {
  try {
    const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

    const today = new Date();
    const todayString = `${today.getFullYear()}-${(today.getMonth() + 1).toString().padStart(2, '0')}-${today.getDate().toString().padStart(2, '0')}`;

    // 查詢使用者所有預約，並關聯課堂、課程、教練資訊
    const { data, error } = await supabaseClient
      .from('bookings')
      .select(`
        booking_id,
        status,
        classes!inner (
          class_date,
          start_time,
          courses ( course_name ),
          coaches ( coach_name )
        )
      `)
      // 只查詢上課日期為今天或未來的預約
      .gte('classes.class_date', todayString)
      // 修正：只顯示未取消的預約
      .in('status', ['已預約', '已扣款'])
      .eq('line_user_id', userId)
      .order('booking_time', { ascending: false })

    if (error) throw error

    if (!data || data.length === 0) {
      // 如果沒有預約，回傳純文字訊息
      return '您目前沒有任何預約紀錄喔！';
    } else {
      // 建立 Flex Message Carousel
      const flexMessage = {
        type: 'flex',
        altText: '您的預約紀錄',
        contents: {
          type: 'carousel',
          // 將每個預約紀錄轉換成一個 Bubble 卡片
          contents: data.map(record => createBookingCard(record)),
        },
      };
      // 回傳組合好的 Flex Message
      return flexMessage;
    }

  } catch (error) {
    console.error('發生錯誤：查詢預約紀錄時發生錯誤，請稍後再試。', error)
    return '查詢預約紀錄時發生錯誤，請稍後再試。';
  }
}

function createBookingCard(record: any): any {
  const cls = record.classes as any; // 型別斷言
  const coachName = cls?.coaches?.coach_name || '未知教練';
  const classDate = cls?.class_date || '未知日期';
  const startTime = cls?.start_time?.substring(0, 5) || '未知時間';
  const bookingId = record.booking_id || 'NO_ID';
  const status = record.status || '未知狀態';

  // 格式化日期與時間作為標題
  let title = '預約資訊';
  if (classDate !== '未知日期') {
    const dateParts = classDate.split('-');
    const formattedDate = `${dateParts[1]}/${dateParts[2]}`;
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    const dayOfWeek = weekDays[new Date(classDate).getDay()];   
    title = `${formattedDate}(${dayOfWeek}) ${startTime}`;
  }

  // 1. 根據狀態決定文字顏色
  const statusColor = status === '已扣款' ? '#28a745' : '#fcc419';

  // 2. 根據狀態決定「取消預約」按鈕的行為
  let cancelAction;
  if (status === '已扣款') {
    // 如果已扣款，按鈕發送提示訊息
    // 修正：將 type 從 'message' 改為 'postback'，讓後端來回覆訊息
    cancelAction = {
      type: 'postback',
      label: '取消預約',
      data: `action=cannot_cancel_paid&bookingId=${bookingId}`
    };
  } else {
    // 如果是其他可取消狀態 (如：已預約)，則使用 postback 觸發取消流程
    cancelAction = {
      type: 'postback',
      label: '取消預約',
      data: `action=request_cancel&bookingId=${bookingId}`
    };
  }

    return {
        "type": "bubble",
        "size": "micro",
        "header": {
            "type": "box",
            "layout": "vertical",
            "contents": [
                {
                    "type": "text",
                    "text": title,
                    "weight": "bold",
                    "size": "md",
                    "align": "center",
                    "color": "#fcc419"
                }
            ],
            "paddingAll": "md",
            "justifyContent": "center",
            "offsetTop": "none"
        },
        "body": {
            "type": "box",
            "layout": "vertical",
            "contents": [
                {
                    "type": "box",
                    "layout": "baseline",
                    "spacing": "sm",
                    "contents": [
                        {
                            "type": "text",
                            "text": "課程",
                            "color": "#aaaaaa",
                            "size": "sm",
                            "flex": 2
                        },
                        {
                            "type": "text",
                            "text": cls?.courses?.course_name || '未知課程',
                            "wrap": true,
                            "color": "#FFFFFF",
                            "size": "sm",
                            "flex": 5
                        }
                    ]
                },
                {
                    "type": "box",
                    "layout": "baseline",
                    "spacing": "sm",
                    "contents": [
                        {
                            "type": "text",
                            "text": "教練",
                            "color": "#aaaaaa",
                            "size": "sm",
                            "flex": 2
                        },
                        {
                            "type": "text",
                            "text": coachName,
                            "wrap": true,
                            "color": "#FFFFFF",
                            "size": "sm",
                            "flex": 5
                        }
                    ]
                },
                {
                    "type": "box",
                    "layout": "baseline",
                    "spacing": "sm",
                    "contents": [
                        {
                            "type": "text",
                            "text": "狀態",
                            "color": "#aaaaaa",
                            "size": "sm",
                            "flex": 2
                        },
                        {
                            "type": "text",
                            "text": status,
                            "wrap": true,
                            "color": statusColor, // 使用動態顏色
                            "size": "sm",
                            "flex": 5
                        }
                    ]
                }
            ],
            "spacing": "md",
            "paddingAll": "lg",
            "backgroundColor": "#212529",
            "offsetStart": "none",
            "paddingStart": "xl",
            "paddingEnd": "xl"
        },
        "footer": {
            "type": "box",
            "layout": "vertical",
            "spacing": "none",
            "contents": [
                {
                    "type": "button",
                    "style": "link",
                    "action": cancelAction, // 使用動態產生的 action
                    "color": "#dc3545",
                    "height": "sm"
                },
                {
                    "type": "separator",
                    "color": "#555555",
                    "margin": "none"
                },
                {
                    "type": "button",
                    "style": "link",
                    "height": "sm",
                    "action": {
                        "type": "uri",
                        "label": "查看憑證",
                        // 終極修正：根據 LIFF 規範，所有參數都應附加在 liff.state 的路徑後面，
                        // 並且需要經過 URL 編碼，以確保參數能被正確解析。
                        "uri": `https://liff.line.me/2008135811-vNO5bYyx/booking-details.html?id=${bookingId}`
                    },
                    "color": "#fcc419"
                }
            ],
            "flex": 0,
            "backgroundColor": "#404040",
            "paddingAll": "none"
        },
        "styles": {
            "header": {
                "backgroundColor": "#212529"
            },
            "body": {
                "separator": true,
                "separatorColor": "#fcc419",
                "backgroundColor": "#212529"
            },
            "footer": {
                "separator": true,
                "separatorColor": "#fcc419"
            }
        }
    };
}

/**
 * 建立一個 Flex Message，用於向使用者確認是否要取消預約
 * @param bookingId - 要取消的預約 ID
 * @returns Flex Message 物件或錯誤訊息文字
 */
async function createCancelConfirmationMessage(bookingId: string): Promise<any> {
  try {
    const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

    // 根據 bookingId 查詢課程詳細資訊
    const { data, error } = await supabaseClient
      .from('bookings')
      .select(`
        booking_id,
        classes!inner (
          class_date,
          start_time,
          courses ( course_name ),
          coaches ( coach_name )
        )
      `)
      .eq('booking_id', bookingId)
      .single();

    if (error || !data) {
      throw new Error(error.message || 'Booking not found');
    }

    // 解構並格式化資料
    const cls = data.classes as any;
    const courseName = cls.courses.course_name || '未知課程';
    const classDate = cls.class_date;
    const startTime = cls.start_time.substring(0, 5);
    const dateParts = classDate.split('-');
    const formattedDate = `${dateParts[1]}/${dateParts[2]}`;
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    const dayOfWeek = weekDays[new Date(classDate).getDay()];

    // 建立 Flex Message
    return {
      type: 'flex',
      altText: '確認取消預約',
      contents: {
        type: 'bubble',
        size: 'kilo',
        body: {
          type: 'box',
          layout: 'vertical',
          contents: [
            {
              type: 'text',
              text: '您確定要取消嗎？',
              weight: 'bold',
              size: 'lg',
              color: '#FFFFFF'
            },
            {
              type: 'text',
              text: '取消後將無法復原',
              size: 'sm',
              color: '#aaaaaa',
              margin: 'sm'
            },
            {
              type: 'separator',
              margin: 'lg',
              color: '#555555'
            },
            {
              type: 'box',
              layout: 'vertical',
              margin: 'lg',
              spacing: 'sm',
              contents: [
                { type: 'text', text: courseName, size: 'md', color: '#fcc419', weight: 'bold' },
                { type: 'text', text: `${formattedDate} (${dayOfWeek}) ${startTime}`, color: '#FFFFFF' }
              ]
            }
          ],
          backgroundColor: '#212529',
          paddingAll: 'xl'
        },
        footer: {
          type: 'box',
          layout: 'horizontal',
          spacing: 'sm',
          contents: [
            {
              type: 'button',
              style: 'link',
              height: 'sm',
              action: {
                type: 'message',
                label: '返回',
                text: '返回'
              },
              color: '#aaaaaa'
            },
            {
              type: 'button',
              style: 'primary',
              height: 'sm',
              action: {
                type: 'postback',
                label: '確認取消',
                data: `action=confirm_cancel&bookingId=${bookingId}`,
                displayText: `正在取消預約...`
              },
              color: '#dc3545'
            }
          ],
          flex: 0,
          paddingAll: 'md',
          backgroundColor: '#212529'
        }
      }
    };
  } catch (error) {
    console.error('建立取消確認訊息時發生錯誤:', error);
    return '無法取得預約資料，請稍後再試。';
  }
}

async function replyMessage(replyToken: string, messages: any | any[]) {
  // 確保 messages 永遠是陣列格式
  let messagesArray = Array.isArray(messages) ? messages : [messages];

  // 修正：如果陣列中的元素是純文字字串，將其轉換為 LINE 的文字訊息物件格式
  messagesArray = messagesArray.map(msg => 
    typeof msg === 'string' ? { type: 'text', text: msg } : msg
  );
  const body = {
    replyToken: replyToken,
    messages: messagesArray,
  }

  try {
    const response = await fetch('https://api.line.me/v2/bot/message/reply', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${CHANNEL_ACCESS_TOKEN}`,
      },
      body: JSON.stringify(body),
    })

    // 檢查 API 回應
    if (!response.ok) {
      console.error('LINE Reply API Error:', await response.text());
    }
  } catch (error) {
    console.error('Failed to call LINE Reply API:', error);
  }
}

function createContactFlexMessage() {
    return {
        type: 'flex',
        altText: 'Wally Studio 聯絡資訊',
        contents: {
            "type": "bubble",
            "hero": {
                "type": "image",
                "url": "https://raw.githubusercontent.com/Chihhao/gym-booking-system/main/images/card_cover.png",
                "size": "full",
                "action": {
                    "type": "uri",
                    "uri": "https://www.google.com/maps/search/?api=1&query=%E6%96%B0%E7%AB%B9%E5%B8%82%E4%B8%AD%E8%8F%AF%E8%B7%AF%E4%BA%8C%E6%AE%B5625%E8%99%9F2%E6%A8%93"
                },
                "aspectRatio": "21:9",
                "aspectMode": "cover"
            },
            "body": {
                "type": "box",
                "layout": "vertical",
                "contents": [
                    {
                        "type": "text",
                        "text": "Wally 自由訓練工作室",
                        "weight": "bold",
                        "size": "lg",
                        "color": "#fcc419"
                    },
                    {
                        "type": "box",
                        "layout": "baseline",
                        "margin": "md",
                        "contents": [
                            {
                                "type": "icon",
                                "size": "sm",
                                "url": "https://developers-resource.landpress.line.me/fx/img/review_gold_star_28.png"
                            },
                            {
                                "type": "icon",
                                "size": "sm",
                                "url": "https://developers-resource.landpress.line.me/fx/img/review_gold_star_28.png"
                            },
                            {
                                "type": "icon",
                                "size": "sm",
                                "url": "https://developers-resource.landpress.line.me/fx/img/review_gold_star_28.png"
                            },
                            {
                                "type": "icon",
                                "size": "sm",
                                "url": "https://developers-resource.landpress.line.me/fx/img/review_gold_star_28.png"
                            },
                            {
                                "type": "icon",
                                "size": "sm",
                                "url": "https://developers-resource.landpress.line.me/fx/img/review_gold_star_28.png"
                            },
                            {
                                "type": "text",
                                "text": "4.9",
                                "size": "sm",
                                "color": "#999999",
                                "margin": "md",
                                "flex": 0
                            }
                        ]
                    },
                    {
                        "type": "box",
                        "layout": "vertical",
                        "margin": "lg",
                        "spacing": "sm",
                        "contents": [
                            {
                                "type": "box",
                                "layout": "baseline",
                                "spacing": "sm",
                                "contents": [
                                    {
                                        "type": "text",
                                        "text": "營業時間",
                                        "color": "#aaaaaa",
                                        "size": "sm",
                                        "flex": 1
                                    },
                                    {
                                        "type": "text",
                                        "text": "09:00~21:00 (週一到週五)",
                                        "wrap": true,
                                        "color": "#666666",
                                        "size": "sm",
                                        "flex": 3
                                    }
                                ]
                            },
                            {
                                "type": "box",
                                "layout": "baseline",
                                "spacing": "sm",
                                "contents": [
                                    {
                                        "type": "text",
                                        "text": "地址",
                                        "color": "#aaaaaa",
                                        "size": "sm",
                                        "flex": 1
                                    },
                                    {
                                        "type": "text",
                                        "text": "新竹市中華路二段 625 號 2 樓",
                                        "wrap": true,
                                        "color": "#666666",
                                        "size": "sm",
                                        "flex": 3
                                    }
                                ]
                            },
                            {
                                "type": "box",
                                "layout": "baseline",
                                "spacing": "sm",
                                "contents": [
                                    {
                                        "type": "text",
                                        "text": "預約專線",
                                        "color": "#aaaaaa",
                                        "size": "sm",
                                        "flex": 1
                                    },
                                    {
                                        "type": "text",
                                        "text": "0937-402-893",
                                        "wrap": true,
                                        "color": "#666666",
                                        "size": "sm",
                                        "flex": 3
                                    }
                                ]
                            }
                        ]
                    }
                ],
                "paddingTop": "lg"
            },
            "footer": {
                "type": "box",
                "layout": "horizontal",
                "spacing": "none",
                "contents": [
                    {
                        "type": "button",
                        "style": "link",
                        "height": "sm",
                        "action": {
                            "type": "uri",
                            "label": "撥打電話",
                            "uri": "tel:0937402893"
                        },
                        "color": "#fcc419"
                    },
                    {
                        "type": "button",
                        "style": "link",
                        "height": "sm",
                        "action": {
                            "type": "uri",
                            "label": "查看地圖",
                            "uri": "https://www.google.com/maps/search/?api=1&query=%E6%96%B0%E7%AB%B9%E5%B8%82%E4%B8%AD%E8%8F%AF%E8%B7%AF%E4%BA%8C%E6%AE%B5625%E8%99%9F2%E6%A8%93"
                        },
                        "color": "#fcc419"
                    }
                ],
                "flex": 0
            },
            "styles": {
                "body": {
                    "backgroundColor": "#212529"
                },
                "footer": {
                    "backgroundColor": "#212529"
                }
            }
        }
    };
}
