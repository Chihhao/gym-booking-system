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

// Edge Function 的主處理函式
// 修正：使用 Deno.serve 替換已被棄用的 std/http serve
Deno.serve(async (req) => {
  // 1. 確認請求方法是 POST
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

    // 新增：印出收到的完整事件，方便偵錯
    console.log('Received event:', JSON.stringify(event, null, 2))
    // 修正：更精確的事件檢查與日誌記錄
    if (!event) {
      console.log('Received a request without an event (likely a test from LINE).');
      return new Response('OK: No event', { status: 200 });
    }

    // 只有在事件存在時才印出
    console.log('Received event:', JSON.stringify(event, null, 2));

    // 2. 根據事件類型處理
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
        replyMessage(event.replyToken, `正在為您查詢個人記錄，請稍候...`)
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

/**
 * 修正：查詢預約紀錄並「回傳」訊息物件，而不是直接推送
 */
async function getBookingHistoryMessage(userId: string): Promise<any> {
  // 由於 Reply API 速度很快，可以移除「查詢中」的提示
  try {
    // 建立一個 Supabase client 來查詢資料
    const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

    // 新增：取得今天的日期字串 (YYYY-MM-DD)，用於篩選
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
    console.error('查詢或推送歷史紀錄時發生錯誤:', error)
    return '查詢預約紀錄時發生錯誤，請稍後再試。';
  }
}

/**
 * 新增：根據單一預約紀錄建立 Flex Message Bubble
 */
function createBookingCard(record: any): any {
  const cls = record.classes as any; // 型別斷言

  // 處理可能的 null 值，提供預設文字
  const courseName = cls?.courses?.course_name || '未知課程';
  const coachName = cls?.coaches?.coach_name || '未知教練';
  const classDate = cls?.class_date || '未知日期';
  const startTime = cls?.start_time?.substring(0, 5) || '未知時間';
  const bookingId = record.booking_id || 'NO_ID';
  const status = record.status || '未知狀態';

  return {
    type: 'bubble',
    header: {
      type: 'box',
      layout: 'vertical',
      contents: [
        {
          type: 'text',
          text: courseName,
          weight: 'bold',
          size: 'xl',
          color: '#FFFFFF',
        },
      ],
      backgroundColor: '#404040',
      paddingAll: 'lg',
    },
    body: {
      type: 'box',
      layout: 'vertical',
      contents: [
        {
          type: 'box',
          layout: 'baseline',
          spacing: 'sm',
          contents: [
            { type: 'text', text: '📅 日期', color: '#aaaaaa', size: 'sm', flex: 2 },
            { type: 'text', text: classDate, wrap: true, color: '#FFFFFF', size: 'sm', flex: 5 },
          ],
        },
        {
          type: 'box',
          layout: 'baseline',
          spacing: 'sm',
          contents: [
            { type: 'text', text: '🕒 時間', color: '#aaaaaa', size: 'sm', flex: 2 },
            { type: 'text', text: startTime, wrap: true, color: '#FFFFFF', size: 'sm', flex: 5 },
          ],
        },
        {
          type: 'box',
          layout: 'baseline',
          spacing: 'sm',
          contents: [
            { type: 'text', text: '🏋️ 教練', color: '#aaaaaa', size: 'sm', flex: 2 },
            { type: 'text', text: coachName, wrap: true, color: '#FFFFFF', size: 'sm', flex: 5 },
          ],
        },
        {
          type: 'box',
          layout: 'baseline',
          spacing: 'sm',
          contents: [
            { type: 'text', text: '📝 狀態', color: '#aaaaaa', size: 'sm', flex: 2 },
            { type: 'text', text: status, wrap: true, color: '#fcc419', size: 'sm', flex: 5, weight: 'bold' },
          ],
        },
      ],
      spacing: 'md',
      paddingAll: 'lg',
      backgroundColor: '#212529',
    },
    footer: {
      type: 'box',
      layout: 'horizontal',
      spacing: 'none', // 修正：移除按鈕間的預設間距
      contents: [
        {
          type: 'button',
          style: 'link',
          height: 'sm',
          action: { type: 'message', label: '查看憑證', text: `[功能開發中] 查看憑證 ${bookingId}` },
          color: '#fcc419',
        },
        {
          type: 'button',
          style: 'link',
          height: 'sm',
          action: { type: 'message', label: '取消預約', text: `[功能開發中] 取消預約 ${bookingId}` },
          color: '#dc3545',
        },
      ],
      flex: 0,
      backgroundColor: '#404040',
    },
  };
}

/**
 * 輔助函式：主動推送訊息給 LINE (支援文字或 Flex Message)
 */
async function pushMessage(userId: string, message: any) {
  // 確保 messages 永遠是陣列格式
  let messagesArray = Array.isArray(message) ? message : [message];

  // 如果陣列中的元素是純文字字串，將其轉換為 LINE 的文字訊息物件格式
  messagesArray = messagesArray.map(msg => 
    typeof msg === 'string' ? { type: 'text', text: msg } : msg
  );

  const body = {
    to: userId,
    messages: messagesArray,
  }
  // 修正：將重複的 fetch 呼叫合併，並加入完整的錯誤處理
  try {
    const response = await fetch('https://api.line.me/v2/bot/message/push', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${CHANNEL_ACCESS_TOKEN}`,
      },
      body: JSON.stringify(body),
    })

    // 檢查 API 回應，如果不是 200 OK，就印出錯誤訊息
    if (!response.ok) {
      console.error('LINE Push API Error:', await response.text());
    }
  } catch (error) {
    console.error('Failed to call LINE Push API:', error);
  }
}

/**
 * 輔助函式：使用 Reply API 回覆訊息 (可回覆單一或多則訊息)
 */
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

/**
 * 新增：建立聯絡資訊的 Flex Message JSON 物件
 */
function createContactFlexMessage() {
  return {
    type: 'flex',
    altText: 'Wally Studio 聯絡資訊',
    // 根據您提供的 JSON 結構進行更新
    contents: {
      type: 'bubble',
      header: {
        type: 'box',
        layout: 'vertical',
        contents: [
          {
            type: 'text',
            text: 'Wally 自由教練工作室',
            size: 'lg',
            color: '#fcc419',
            offsetStart: 'none',
            align: 'center'
          }
        ],
        backgroundColor: '#404040',
        paddingAll: 'lg',
        offsetStart: 'none'
      },
      body: {
        type: 'box',
        layout: 'vertical',
        contents: [
          {
            type: 'box',
            layout: 'horizontal',
            contents: [
              {
                type: 'text',
                text: '🕒',
                flex: 0,
                size: 'lg',
                gravity: 'center',
              },
              {
                type: 'text',
                text: '09:00~21:00 (週一至週五)',
                wrap: true,
                margin: 'md',
                size: 'md',
              }
            ],
            alignItems: 'center',
          },
          {
            type: 'box',
            layout: 'horizontal',
            contents: [
              {
                type: 'text',
                text: '📞',
                flex: 0,
                size: 'lg',
                gravity: 'center',
              },
              {
                type: 'text',
                text: '0937-402-893',
                wrap: true,
                margin: 'md',
                size: 'md',
              }
            ],
            margin: 'lg',
            alignItems: 'center',
          },
          {
            type: 'box',
            layout: 'horizontal',
            contents: [
              {
                type: 'text',
                text: '📍',
                flex: 0,
                size: 'lg',
                gravity: 'center',
              },
              {
                type: 'text',
                text: '新竹市中華路二段 625 號 2 樓',
                wrap: true,
                margin: 'md',
                size: 'md',
              }
            ],
            margin: 'lg',
            alignItems: 'flex-start',
          }
        ],
        spacing: 'md',
        paddingAll: 'lg',
        backgroundColor: '#EEEEEE',
        borderWidth: 'none',
      },
      footer: {
        type: 'box',
        layout: 'horizontal',
        contents: [
          {
            type: 'button',
            action: {
              type: 'uri',
              label: '查看地圖',
              // 修正：將 URI 中的中文字元進行 URL 編碼，避免 "Invalid action URI" 錯誤
              uri: 'https://www.google.com/maps/search/?api=1&query=%E6%96%B0%E7%AB%B9%E5%B8%82%E4%B8%AD%E8%8F%AF%E8%B7%AF%E4%BA%8C%E6%AE%B5625%E8%99%9F2%E6%A8%93'
            },
            color: '#fcc419'
          },
          {
            type: 'separator'
          },
          {
            type: 'button',
            action: {
              type: 'uri',
              label: '撥打電話',
              // 修正：將 URI 改為 tel: 協議
              uri: 'tel:0937402893'
            },
            color: '#fcc419'
          }
        ],
        paddingAll: 'none',
        backgroundColor: '#404040'
      }
    }
  };
}
