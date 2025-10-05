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
    if (event && event.type === 'postback') {
      // 修正：移除 await，讓 handlePostback 在背景執行，立即回傳 OK
      handlePostback(event)
    } else if (event && event.type === 'message' && event.message.type === 'text') {
      // 新增：處理來自圖文選單的文字訊息事件，例如 "聯絡資訊"
      // 修正：判斷文字需與圖文選單設定的 `[聯絡資訊]` 一致
      if (event.message.text === '[聯絡資訊]') {        
        // 修正：只發送 Flex Message
        replyMessage(event.replyToken, createContactFlexMessage());
      }
      // 新增：處理 [確認/取消] 按鈕的點擊事件
      else if (event.message.text === '[確認/取消]') {
        const cancelMessage = `您好！若要確認或取消您的預約，請點擊下方圖文選單的「個人記錄」按鈕，找到對應的預約憑證後即可進行操作。`
        replyMessage(event.replyToken, cancelMessage)
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
 * 處理 Postback 事件的核心函式
 */
async function handlePostback(event: any) {
  const postbackData = event.postback.data
  const action = new URLSearchParams(postbackData).get('action')

  switch (action) {
    case 'show_history':
      // 直接在背景執行，不需等待
      getBookingHistoryAndPush(event.source.userId)
      break
    default:
      console.log(`收到未知的 postback action: ${action}`)
  }
}

/**
 * 查詢預約紀錄並推送給使用者
 */
async function getBookingHistoryAndPush(userId: string) {
  // 修正：改用 Push API 發送提示訊息，讓使用者知道系統正在處理
  await pushMessage(userId, '正在為您查詢預約紀錄，請稍候...')

  try {
    // 建立一個 Supabase client 來查詢資料
    const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

    // 查詢使用者所有預約，並關聯課堂、課程、教練資訊
    const { data, error } = await supabaseClient
      .from('bookings')
      .select(`
        status,
        classes (
          class_date,
          start_time,
          courses ( course_name ),
          coaches ( coach_name )
        )
      `)
      .eq('line_user_id', userId)
      .order('booking_time', { ascending: false })

    if (error) throw error

    // 組合訊息
    let message: string
    if (!data || data.length === 0) {
      message = '您目前沒有任何預約紀錄喔！'
    } else {
      message = '您的預約紀錄如下：\n----------\n'
      message += data.map(record => {
        const cls = record.classes as any; // 型別斷言
        let classInfo = '未知課程'
        if (cls) {
          const courseName = cls.courses?.course_name || '課程'
          const coachName = cls.coaches?.coach_name || '教練'
          const classTime = `${cls.class_date} ${cls.start_time.substring(0, 5)}`
          classInfo = `${courseName}\n時間：${classTime}\n教練：${coachName}`
        }
        return `課程：${classInfo}\n狀態：${record.status}\n----------`
      }).join('\n')
    }

    // 使用 Push API 將最終結果推送給使用者
    await pushMessage(userId, message.trim())

  } catch (error) {
    console.error('查詢或推送歷史紀錄時發生錯誤:', error)
    await pushMessage(userId, '查詢預約紀錄時發生錯誤，請稍後再試。')
  }
}

/**
 * 輔助函式：主動推送一則文字訊息給 LINE
 */
async function pushMessage(userId: string, text: string) {
  // 將單一文字訊息包裝成 LINE API 要求的陣列格式
  const messages = [{ type: 'text', text }];

  const body = {
    to: userId,
    messages: messages,
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
  const messagesArray = Array.isArray(messages) ? messages : [messages];
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
