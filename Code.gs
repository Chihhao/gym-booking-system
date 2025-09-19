// --- 全域變數設定 ---
// 之後會將 Google Sheet 的各個工作表定義在這裡，方便管理
const SPREADSHEET = SpreadsheetApp.getActiveSpreadsheet(); 
const USER_SHEET = SPREADSHEET.getSheetByName("Users");
const COACH_SHEET = SPREADSHEET.getSheetByName("Coaches");
const CLASS_SHEET = SPREADSHEET.getSheetByName("Classes");
const BOOKING_SHEET = SPREADSHEET.getSheetByName("Bookings");

// 這裡未來會放置 LINE Bot 的 Channel Access Token
const CHANNEL_ACCESS_TOKEN = '6HTikANeIpIjHqztdhXHorN8XehTVjYJLHmbgTSWK/GuaKVztsg65IkK/JC7sRDi47nayqJPlr0wGHeZJSx/YOvWEjypEdMpwR0Mqb71JhhOumQ8Dj4PXIkxVX5cjIDtkDktRdwZcLwyUdXgiuLSTQdB04t89/1O/w1cDnyilFU=';

// GAS URL:
// https://script.google.com/macros/s/AKfycbxDeUvMH7y_OlMqDrZIwylgOtcCE0HwbOIpQkABj7Sa7KtD5Pd5ndjwInrL9OE3Ngo/exec

// https://liff.line.me/2008135811-vNO5bYyx

function doGet(e) {
  const page = e.parameter.page;

  if (page === 'admin') {
    // 如果參數是 'admin'，就執行提供待審核清單的邏輯
    return getPendingBookings();
  } else {
    // 否則，執行原本的提供課程表的邏輯
    return getClassSchedule();
  }
}

function buildClassMap_() {
  const classData = CLASS_SHEET.getDataRange().getValues();
  const coachData = COACH_SHEET.getDataRange().getValues();
  
  const coachMap = {};
  for(let i=1; i<coachData.length; i++){
      if(coachData[i][0]){
          coachMap[coachData[i][0]] = coachData[i][1];
      }
  }

  const classMap = {};
  for (let i = 1; i < classData.length; i++) {
    const row = classData[i];
    const classId = row[0];
    if (classId) {
      const classDate = Utilities.formatDate(new Date(row[2]), "GMT+8", "yyyy-MM-dd");
      const startTime = Utilities.formatDate(new Date(row[3]), "GMT+8", "HH:mm");
      const coachName = coachMap[row[1]] || '未知教練';
      // 讓 classMap 儲存更完整的資訊，方便各處使用
      classMap[classId] = `${classDate} ${startTime} (${coachName})`;
    }
  }
  return classMap;
}

function getPendingBookings() {
  const classMap = buildClassMap_(); // 直接呼叫輔助函式

  const userData = USER_SHEET.getDataRange().getValues();
  const userMap = {};
  for(let i=1; i<userData.length; i++){
      if(userData[i][0]){
          userMap[userData[i][0]] = userData[i][1];
      }
  }
  
  const bookingData = BOOKING_SHEET.getDataRange().getValues();
  const pendingBookings = [];

  for (let i = bookingData.length - 1; i > 0; i--) {
    const row = bookingData[i];
    const status = row[4];

    if (status === '待審核') {
      const bookingId = row[0];
      const classId = row[1];
      const userId = row[2];
      pendingBookings.push({
        bookingId: bookingId,
        classInfo: classMap[classId] || `未知課程(ID: ${classId})`, // 使用新的 classMap
        userName: userMap[userId] || '未知用戶'
      });
    }
  }

  return ContentService
    .createTextOutput(JSON.stringify({ bookings: pendingBookings }))
    .setMimeType(ContentService.MimeType.JSON);
}

function getClassSchedule() {
  const coachData = COACH_SHEET.getDataRange().getValues();
  const coachMap = {};
  for (let i = 1; i < coachData.length; i++) {
    if (coachData[i][0]) {
      coachMap[coachData[i][0]] = coachData[i][1];
    }
  }

  const classData = CLASS_SHEET.getDataRange().getValues();
  const schedule = [];

  for (let i = 1; i < classData.length; i++) {
    const row = classData[i];
    const classId = row[0];
    
    if (classId && row[7] === '開放中') { // [7] is status
      schedule.push({
        classId: classId,
        coachName: coachMap[row[1]] || '未知教練',
        date: Utilities.formatDate(new Date(row[2]), "GMT+8", "yyyy-MM-dd"),
        startTime: Utilities.formatDate(new Date(row[3]), "GMT+8", "HH:mm"),
        endTime: Utilities.formatDate(new Date(row[4]), "GMT+8", "HH:mm"),
        remaining: row[5] - row[6],
      });
    }
  }
  
  return ContentService
    .createTextOutput(JSON.stringify({ classes: schedule }))
    .setMimeType(ContentService.MimeType.JSON);
}

function doPost(e) {
  const quickReply = ContentService.createTextOutput(JSON.stringify({'status': 'ok'}));

  try {
    // 解析請求內容
    const request = JSON.parse(e.postData.contents);

    // 如果請求來自 LINE 平台 Webhook (有 events 屬性)
    if (request.events && request.events.length > 0) {
      request.events.forEach(function(event) {
        // 只處理 postback 事件，其他事件 (如 Verify 的假事件) 直接忽略
        if (event.type === 'postback') {
          handlePostback(event);
        }
      });
    }
    // 如果請求來自我們的 LIFF 網頁 (有 action 屬性)
    else if (request.action) {
      // 網頁請求需要等待真實的處理結果，所以要 return 處理函式的回傳值
      return createJsonResponse(handleWebAppActions(request));
    }
  } catch (err) {
    // 如果解析或處理過程中出錯，可以在日誌中記錄錯誤
    // 但仍然回傳一個成功的 quickReply 給 LINE，避免 LINE 不斷重試
    console.error(err.toString());
  }
  
  return quickReply;
}

// 新增一個專門處理網頁請求的函式，讓 doPost 更清晰 ---
function handleWebAppActions(request) {
    switch (request.action) {
      case 'createBooking':
        return createBooking(request.data);
      case 'reviewBooking':
        return reviewBooking(request.data);
      default:
        return { status: 'error', message: '無效的網頁操作' };
    }
}

/**
 * 處理新增預約的核心函式 (*** 已修正回傳值的格式 ***)
 * @param {object} data - 包含 classId 和 liffData (使用者資訊)
 */
function createBooking(data) {
  const { classId, liffData } = data;
  const { userId, displayName } = liffData;

  const bookingValues = BOOKING_SHEET.getDataRange().getValues();
  for (let i = 1; i < bookingValues.length; i++) {
    const bookedUserId = bookingValues[i][2];
    const bookedClassId = bookingValues[i][1];
    const bookingStatus = bookingValues[i][4];
    
    if (bookedUserId === userId && bookedClassId === classId && (bookingStatus === '待審核' || bookingStatus === '已確認')) {
      // 【修改】只回傳純粹的 JS 物件
      return { status: 'error', message: '您已預約過此課程，請勿重複預約。' };
    }
  }

  const lock = LockService.getScriptLock();
  lock.waitLock(15000);

  try {
    const classValues = CLASS_SHEET.getDataRange().getValues();
    let targetClassRow = -1;
    let classInfo = {};
    for (let i = 1; i < classValues.length; i++) {
      if (classValues[i][0] === classId) {
        targetClassRow = i + 1;
        classInfo = { max: classValues[i][5], current: classValues[i][6] };
        break;
      }
    }

    if (targetClassRow === -1 || classInfo.current >= classInfo.max) {
      // 【修改】只回傳純粹的 JS 物件
      return { status: 'error', message: '課程已額滿或不存在' };
    }

    CLASS_SHEET.getRange(targetClassRow, 7).setValue(classInfo.current + 1);
    const userValues = USER_SHEET.getDataRange().getValues();
    let userExists = false;
    for (let i = 1; i < userValues.length; i++) {
      if (userValues[i][0] === userId) {
        userExists = true;
        break;
      }
    }
    if (!userExists) {
      USER_SHEET.appendRow([userId, displayName, new Date()]);
    }
    const bookingId = "BK" + new Date().getTime();
    BOOKING_SHEET.appendRow([bookingId, classId, userId, new Date(), '待審核']);

    // 【修改】只回傳純粹的 JS 物件
    return { status: 'success', message: '預約成功，待教練審核！' };

  } catch (error) {
    // 【修改】只回傳純粹的 JS 物件
    return { status: 'error', message: '處理預約時發生錯誤: ' + error.toString() };
  } finally {
    lock.releaseLock();
  }
}

/**
 * 處理審核預約的核心函式 (*** 已修正回傳值的格式 ***)
 * @param {object} data - 包含 bookingId 和 decision ('approve' or 'reject')
 */
function reviewBooking(data) {
  const { bookingId, decision } = data;
  const newStatus = (decision === 'approve') ? '已確認' : '已駁回';

  const lock = LockService.getScriptLock();
  lock.waitLock(15000);

  try {
    const bookingValues = BOOKING_SHEET.getDataRange().getValues();
    let targetBookingRow = -1;
    let classId = '';
    for (let i = 1; i < bookingValues.length; i++) {
      if (bookingValues[i][0] === bookingId) {
        targetBookingRow = i + 1;
        classId = bookingValues[i][1];
        break;
      }
    }

    if (targetBookingRow === -1) {
      throw new Error('找不到該筆預約紀錄');
    }

    BOOKING_SHEET.getRange(targetBookingRow, 5).setValue(newStatus);

    if (decision === 'reject') {
      const classValues = CLASS_SHEET.getDataRange().getValues();
      let targetClassRow = -1;
      let currentStudents = 0;
      for (let i = 1; i < classValues.length; i++) {
        if (classValues[i][0] === classId) {
          targetClassRow = i + 1;
          currentStudents = classValues[i][6];
          break;
        }
      }
      if (targetClassRow !== -1 && currentStudents > 0) {
        CLASS_SHEET.getRange(targetClassRow, 7).setValue(currentStudents - 1);
      }
    }
    
    // 【修改】只回傳純粹的 JS 物件
    return { status: 'success', message: `操作成功：${newStatus}` };

  } catch (error) {
    // 【修改】只回傳純粹的 JS 物件
    return { status: 'error', message: '處理時發生錯誤: ' + error.toString() };
  } finally {
    lock.releaseLock();
  }
}

// 新增一個輔助函式，方便建立 JSON 回應 ---
function createJsonResponse(obj) {
    return ContentService
        .createTextOutput(JSON.stringify(obj))
        .setMimeType(ContentService.MimeType.JSON);
}

/**
 * 處理 LINE Postback 事件
 * @param {object} event - LINE Webhook 的事件物件
 */
function handlePostback(event) {
  const userId = event.source.userId;
  const postbackData = event.postback.data; // 例如 "action=show_history"

  // --- 手動解析 postback data ---
  // 因為 GAS 環境不支援 URLSearchParams，我們需要自己手動解析。
  // 這種方法更通用，即使未來 data 變成 "action=abc&type=xyz" 也能處理。
  const params = {};
  postbackData.split('&').forEach(pair => {
    const parts = pair.split('=');
    // 確保分割後是兩個部分，避免 data 格式錯誤導致程式出錯
    if (parts.length === 2) {
      // params['action'] = 'show_history'
      params[decodeURIComponent(parts[0])] = decodeURIComponent(parts[1]);
    }
  });
  
  const action = params['action']; // 使用解析後的物件來取得 action 的值

  if (action === 'show_history') {
    const recordsText = getBookingHistory(userId);
    replyMessage(event.replyToken, recordsText);
  }
  
  // 未來若有其他 postback 動作，可以繼續在這裡增加 else if
  // else if (action === 'some_other_action') { ... }
}

/**
 * 根據 userId 查詢預約歷史紀錄 (*** 已使用 CacheService 優化 ***)
 * @param {string} userId - 使用者的 LINE User ID
 * @returns {string} - 組合好的要回傳給使用者的文字訊息
 */
function getBookingHistory(userId) {
  // 取得快取服務
  const cache = CacheService.getScriptCache();
  const CACHE_KEY_CLASSMAP = 'class_map_cache'; // 為我們的快取資料命名

  // --- 優化步驟 1: 嘗試從快取中讀取 classMap ---
  let classMap = null;
  const cachedClassMap = cache.get(CACHE_KEY_CLASSMAP);

  if (cachedClassMap != null) {
    // 如果快取中存在，直接解析使用，速度極快
    classMap = JSON.parse(cachedClassMap);
    Logger.log('從快取成功讀取 classMap');
  } else {
    // 如果快取中沒有，才從 Google Sheet 讀取 (耗時操作)
    Logger.log('快取未命中，從 Google Sheet 重新建立 classMap');
    
    // 建立課程 ID -> 課程日期+時間+教練 的對照表
    const classData = CLASS_SHEET.getDataRange().getValues();
    const coachData = COACH_SHEET.getDataRange().getValues();
    const coachMap = {};
    for(let i=1; i<coachData.length; i++){ coachMap[coachData[i][0]] = coachData[i][1]; }
    
    classMap = {}; // 初始化
    for (let i = 1; i < classData.length; i++) {
      const row = classData[i];
      const classId = row[0];
      if (classId) {
        const classDate = Utilities.formatDate(new Date(row[2]), "GMT+8", "yyyy-MM-dd");
        const startTime = Utilities.formatDate(new Date(row[3]), "GMT+8", "HH:mm");
        const coachName = coachMap[row[1]] || '未知教練';
        classMap[classId] = `${classDate} ${startTime} (${coachName})`;
      }
    }
    
    // --- 優化步驟 2: 將新建立的 classMap 存入快取，設定 10 分鐘 (600秒) 的有效期 ---
    // 這樣 10 分鐘內的下一次請求就能直接使用快取了
    cache.put(CACHE_KEY_CLASSMAP, JSON.stringify(classMap), 600);
  }

  // --- 後續邏輯不變，但現在 classMap 的取得速度非常快 ---
  const bookingValues = BOOKING_SHEET.getDataRange().getValues();
  const userRecords = [];
  for (let i = 1; i < bookingValues.length; i++) {
    if (bookingValues[i][2] === userId) { // [2] is line_user_id
      userRecords.push({
        classInfo: classMap[bookingValues[i][1]] || '未知課程',
        status: bookingValues[i][4] // [4] is status
      });
    }
  }

  if (userRecords.length === 0) {
    return '您目前沒有任何預約紀錄喔！';
  }

  let message = '您的預約紀錄如下：\n----------\n';
  userRecords.forEach(record => {
    message += `課程：${record.classInfo}\n狀態：${record.status}\n----------\n`;
  });
  return message.trim();
}

/**
 * 回覆訊息給 LINE 使用者
 * @param {string} replyToken - 回覆用的 token
 * @param {string} text - 要回覆的文字內容
 */
function replyMessage(replyToken, text) {
  const url = 'https://api.line.me/v2/bot/message/reply';
  const payload = {
    replyToken: replyToken,
    messages: [{
      type: 'text',
      text: text
    }]
  };
  const options = {
    'method': 'post',
    'contentType': 'application/json',
    'headers': {
      'Authorization': 'Bearer ' + CHANNEL_ACCESS_TOKEN
    },
    'payload': JSON.stringify(payload)
  };
  UrlFetchApp.fetch(url, options);
}

/**
 * =================================================================
 * 【一次性執行】建立並設定 LINE 圖文選單 (Rich Menu)
 * =================================================================
 * 版本：三按鈕優化版 (Compact Size)
 *
 * 執行此函式前，請務必:
 * 1. 準備好一張 2500x843 像素的 JPG 或 PNG 圖片。
 * 2. 將圖片上傳到可公開存取的 URL (例如 GitHub)，並填入下方的 imageUrl 變數。
 * 3. 將 action 中的 LIFF URL 換成您自己的。
 * 4. 確保最上方的 CHANNEL_ACCESS_TOKEN 變數是正確的。
 */
function createRichMenu() {
  // --- Step 1: 定義圖文選單的結構 (按鈕區塊與對應動作) ---
  const richMenuBody = {
    // 使用 Compact 尺寸，更適合三按鈕的長條形佈局
    "size": { "width": 2500, "height": 843 },
    "selected": true,
    "name": "Gym Booking Menu V2 (Compact)",
    "chatBarText": "點此開啟選單",
    "areas": [
      {
        // 按鈕一：查看/預約課程 (左邊 1/3)
        // 寬度約為 2500 / 3 = 833
        "bounds": { "x": 0, "y": 0, "width": 833, "height": 843 },
        "action": {
          "type": "uri",
          "uri": "https://liff.line.me/2008135811-vNO5bYyx" // <<-- ⚠️ 請務必替換成您的 LIFF URL
        }
      },
      {
        // 按鈕二：我的預約紀錄 (中間 1/3)
        // x 從 833 開始，寬度為 834 (833+834+833 = 2500)
        "bounds": { "x": 833, "y": 0, "width": 834, "height": 843 },
        "action": {
          "type": "postback",
          "data": "action=show_history" // 這會觸發您的 doPost -> handlePostback 函式
        }
      },
      {
        // 按鈕三：聯絡我們 (右邊 1/3)
        // x 從 833 + 834 = 1667 開始
        "bounds": { "x": 1667, "y": 0, "width": 833, "height": 843 },
        "action": {
          "type": "message",
          "text": "請問有什麼可以為您服務的嗎？"
        }
      }
    ]
  };

  try {
    // --- Step 2: 建立圖文選單，取得 richMenuId ---
    const createUrl = 'https://api.line.me/v2/bot/richmenu';
    const createOptions = {
      'method': 'post',
      'contentType': 'application/json',
      'headers': { 'Authorization': 'Bearer ' + CHANNEL_ACCESS_TOKEN },
      'payload': JSON.stringify(richMenuBody)
    };
    const createResponse = UrlFetchApp.fetch(createUrl, createOptions);
    const richMenuId = JSON.parse(createResponse.getContentText()).richMenuId;
    Logger.log('圖文選單建立成功，ID: ' + richMenuId);

    // --- Step 3: 上傳圖文選單的圖片 ---
    // ⚠️ 請將此 URL 換成您自己的 2500x843 尺寸的圖片網址
    const imageUrl = "https://raw.githubusercontent.com/Chihhao/gym-booking-system/main/richmenu-compact.png"; // <<-- 範例：請換成您自己的圖片 URL
    const imageBlob = UrlFetchApp.fetch(imageUrl).getBlob();

    // **修正後的圖片上傳網址**，使用 api-data.line.me
    const uploadUrl = `https://api-data.line.me/v2/bot/richmenu/${richMenuId}/content`;
    const uploadOptions = {
      'method': 'post',
      'contentType': imageBlob.getContentType(),
      'headers': { 'Authorization': 'Bearer ' + CHANNEL_ACCESS_TOKEN },
      'payload': imageBlob
    };
    UrlFetchApp.fetch(uploadUrl, uploadOptions);
    Logger.log('圖片上傳成功！');

    // --- Step 4: 將此圖文選單設為所有使用者的預設選單 ---
    const setDefaultUrl = 'https://api.line.me/v2/bot/user/all/richmenu/' + richMenuId;
    const setDefaultOptions = {
      'method': 'post',
      'headers': { 'Authorization': 'Bearer ' + CHANNEL_ACCESS_TOKEN }
    };
    UrlFetchApp.fetch(setDefaultUrl, setDefaultOptions);
    Logger.log('已成功將圖文選單設定為預設！');

  } catch (e) {
    Logger.log('發生錯誤: ' + e.toString());
  }
}

/**
 * 【臨時工具】用來刪除指定的圖文選單
 * 如果需要更換選單，可以先用這個函式刪除舊的
 */
function deleteRichMenu(richMenuIdToDelete) {
  // 使用方法：
  // 1. 在 LINE Developer 後台的 Rich menus 頁面找到要刪除的 ID
  // 2. 在編輯器中手動執行 deleteRichMenu("richmenu-xxxxxx")
  if (!richMenuIdToDelete) {
      Logger.log("請提供要刪除的 Rich Menu ID");
      return;
  }
  const deleteUrl = 'https://api.line.me/v2/bot/richmenu/' + richMenuIdToDelete;
  const deleteOptions = {
    'method': 'delete',
    'headers': { 'Authorization': 'Bearer ' + CHANNEL_ACCESS_TOKEN }
  };
  
  try {
    UrlFetchApp.fetch(deleteUrl, deleteOptions);
    Logger.log('成功刪除圖文選單: ' + richMenuIdToDelete);
  } catch(e) {
    Logger.log('刪除失敗: ' + e.toString());
  }
}





