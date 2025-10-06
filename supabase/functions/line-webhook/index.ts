
// 上傳命令：supabase functions deploy line-webhook --no-verify-jwt

import { createClient } from '@supabase/supabase-js'

// 這些機密資訊將從 Supabase 儀表板的環境變數中讀取，非常安全
const CHANNEL_ACCESS_TOKEN = Deno.env.get('LINE_CHANNEL_ACCESS_TOKEN')
// 修正：使用您在 Supabase 儀表板中設定的新變數名稱
const SUPABASE_URL = Deno.env.get('SB_URL')
const SUPABASE_ANON_KEY = Deno.env.get('SB_ANON_KEY')

// 新增：在函式啟動時就檢查必要的環境變數是否存在
if (!CHANNEL_ACCESS_TOKEN || !SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error('Missing required environment variables (LINE_CHANNEL_ACCESS_TOKEN, SB_URL, SB_ANON_KEY). Please check your Supabase function settings.');
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 })
  }

  try {
    // 新增：強健性檢查。如果請求沒有內容 (content-length 為 0 或 null)，
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
      // 新增：只查詢上課日期為今天或未來的預約
      .gte('classes.class_date', todayString)
      .eq('line_user_id', userId)
      .order('booking_time', { ascending: false })

    if (error) throw error

    if (!data || data.length === 0) {
      // 如果沒有預約，回傳純文字訊息
      return '您目前沒有任何預約紀錄喔！';
    } else {
      // 新增：建立 Flex Message Carousel
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

  // 新增：格式化日期與時間作為標題
  let title = '預約資訊';
  if (classDate !== '未知日期') {
    const dateParts = classDate.split('-');
    const formattedDate = `${dateParts[1]}/${dateParts[2]}`;
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    const dayOfWeek = weekDays[new Date(classDate).getDay()];   
    title = `${formattedDate}(${dayOfWeek}) ${startTime}`;
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
                            "color": "#fcc419",
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
                    "action": {
                        "type": "message",
                        "label": "取消預約",
                        "text": `[功能開發中] 取消預約 ${bookingId}`
                    },
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
                        "uri": `https://liff.line.me/2008135811-vNO5bYyx?liff.state=/booking-details.html?id=${bookingId}`
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
