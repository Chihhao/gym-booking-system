// supabase/functions/manage-rich-menu/index.ts

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { corsHeaders } from '../_shared/cors.ts'

// 從 config.js 取得 LIFF ID，確保與前端一致
// 注意：Edge Function 無法直接讀取前端 JS 檔案，
// 這裡我們手動保持同步，或未來可考慮從資料庫讀取設定。
const LIFF_ID_COURSES = '2008135811-vNO5bYyx';

// 圖文選單的定義
const richMenuObject = {
  size: {
    width: 2500,
    height: 1686, // 圖片高度更新為 1686px
  },
  selected: true,
  name: 'Gym Booking Main Menu',
  chatBarText: '查看更多功能',
  areas: [
    {
      // 按鈕 (a): 上方大按鈕 - 預約課程
      // 高度為 1686 - 734 = 952
      bounds: { x: 0, y: 0, width: 2500, height: 952 },
      action: {
        type: 'uri',
        uri: `https://liff.line.me/${LIFF_ID_COURSES}`,
      },
    },
    {
      // 按鈕 (b): 左下角按鈕 - 確認/取消
      // y 從 952 開始
      bounds: { x: 0, y: 952, width: 833, height: 734 },
      action: {
        type: 'message',
        text: '[確認/取消]',
      },
    },
    {
      // 按鈕 (c): 中間下方按鈕 - 個人記錄
      // x 從 833 開始
      bounds: { x: 833, y: 952, width: 834, height: 734 },
      action: {
        type: 'postback',
        data: 'action=show_history',
        displayText: '[個人記錄]', // 讓使用者點擊後看到的文字
      },
    },
    {
      // 按鈕 (d): 右下角按鈕 - 聯絡資訊
      // x 從 833 + 834 = 1667 開始
      bounds: { x: 1667, y: 952, width: 833, height: 734 },
      action: {
        type: 'message',
        text: '[聯絡資訊]',
      },
    },
  ],
}

serve(async (req) => {
  // 處理 CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. 從環境變數讀取 LINE Channel Access Token
    const channelAccessToken = Deno.env.get('LINE_CHANNEL_ACCESS_TOKEN')
    if (!channelAccessToken) {
      throw new Error('LINE_CHANNEL_ACCESS_TOKEN is not set in environment variables.')
    }

    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${channelAccessToken}`,
    }

    // 2. 建立圖文選單，取得 richMenuId
    console.log('Step 1: Creating rich menu object...')
    const createMenuResponse = await fetch('https://api.line.me/v2/bot/richmenu', {
      method: 'POST',
      headers: headers,
      body: JSON.stringify(richMenuObject),
    })

    if (!createMenuResponse.ok) {
      const errorBody = await createMenuResponse.json()
      throw new Error(`Failed to create rich menu: ${JSON.stringify(errorBody)}`)
    }

    const { richMenuId } = await createMenuResponse.json()
    console.log(`Step 1 Success: Rich menu created with ID: ${richMenuId}`)

    // 3. 從 GitHub URL 讀取圖片並上傳
    console.log('Step 2: Fetching and uploading rich menu image...')
    const imageUrl = "https://raw.githubusercontent.com/Chihhao/gym-booking-system/main/images/KAY-GYM-MENU.jpg";
    const imageResponse = await fetch(imageUrl);
    if (!imageResponse.ok) {
      throw new Error(`Failed to fetch image from URL: ${imageUrl}`);
    }
    // 使用 arrayBuffer() 來取得原始的二進位資料
    const imageContent = await imageResponse.arrayBuffer();

    const uploadImageResponse = await fetch(`https://api-data.line.me/v2/bot/richmenu/${richMenuId}/content`, {
      method: 'POST',
      headers: {
        'Content-Type': 'image/jpeg', // 圖片格式改為 jpeg
        'Authorization': `Bearer ${channelAccessToken}`,
      },
      body: imageContent,
    })

    if (!uploadImageResponse.ok) {
      const errorBody = await uploadImageResponse.json()
      throw new Error(`Failed to upload image: ${JSON.stringify(errorBody)}`)
    }
    console.log('Step 2 Success: Image uploaded.')

    // 4. 將此圖文選單設為預設
    console.log('Step 3: Setting rich menu as default...')
    const setDefaultResponse = await fetch(`https://api.line.me/v2/bot/user/all/richmenu/${richMenuId}`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${channelAccessToken}`,
      },
    })

    if (!setDefaultResponse.ok) {
      const errorBody = await setDefaultResponse.json()
      throw new Error(`Failed to set default menu: ${JSON.stringify(errorBody)}`)
    }
    console.log('Step 3 Success: Rich menu is now default for all users.')

    // 5. 回傳成功訊息
    return new Response(
      JSON.stringify({
        message: 'Rich menu created, uploaded, and set as default successfully!',
        richMenuId: richMenuId,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Error in manage-rich-menu function:', error.message)
    return new Response(
        JSON.stringify({ error: error.message }), 
        {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 500
        }
    )
  }
})
