// 修正：為 Supabase 客戶端提供 GAS 環境中缺少的 self 全域物件
const self = this;
// =================================================================
// Supabase 改造區
// =================================================================

// --- 安全的金鑰管理 ---
// 從「專案設定 > 指令碼屬性」讀取機密金鑰
const properties = PropertiesService.getScriptProperties();
const SUPABASE_SERVICE_KEY = properties.getProperty('SUPABASE_SERVICE_KEY');
const CHANNEL_ACCESS_TOKEN = properties.getProperty('CHANNEL_ACCESS_TOKEN');

// 在程式開始時就檢查金鑰是否存在，若否，則拋出錯誤
if (!SUPABASE_SERVICE_KEY) {
  throw new Error('錯誤：找不到 SUPABASE_SERVICE_KEY。請在「專案設定 > 指令碼屬性」中設定。');
}
if (!CHANNEL_ACCESS_TOKEN) {
  throw new Error('錯誤：找不到 CHANNEL_ACCESS_TOKEN。請在「專案設定 > 指令碼屬性」中設定。');
}

const SUPABASE_URL = 'https://zseddmfljxtcgtzmvove.supabase.co';

const SUPABASE_HEADERS = {
  'apikey': SUPABASE_SERVICE_KEY,
  'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`
};

// =================================================================
// (舊版 Google Sheet 程式碼保留於下方)
// =================================================================

function doGet(e) {
  // 新的 API 路由器
  const action = e.parameter.action;

  try {
    switch (action) {
      case 'getBookingDetails': // 改造點：指向新的 Supabase 函式
        return createJsonResponse(getBookingDetailsFromSupabase(e.parameter));
      // 預設行為：如果沒有 action，則渲染 index.html (首頁)
      default:
        return HtmlService.createTemplateFromFile('index').evaluate();
    }
  } catch (error) {
    return createJsonResponse({ status: 'error', message: '處理 GET 請求時發生錯誤: ' + error.toString() });
  }
}

/**
 * [Supabase版] 根據 bookingId 取得單筆預約的詳細資訊
 * @param {object} params - 包含 bookingId 的請求參數
 */
function getBookingDetailsFromSupabase(params) {
  const bookingId = params.bookingId;
  if (!bookingId) {
    throw new Error("缺少 bookingId 參數");
  }

  try {
    const tableName = 'bookings';
    // 使用關聯查詢，一次取得所有需要的資料
    const query = `select=booking_id,status,classes(class_id,class_date,start_time,courses(course_id,course_name)),users(line_display_name)&booking_id=eq.${bookingId}`;
    const url = `${SUPABASE_URL}/rest/v1/${tableName}?${query}`;

    const options = {
      'method': 'get',
      'headers': {
        ...SUPABASE_HEADERS,
        // 要求 Supabase 回傳單一物件而非陣列，如果找不到會回傳 404
        'Accept': 'application/vnd.pgrst.object+json' 
      },
      'muteHttpExceptions': true
    };

    const response = UrlFetchApp.fetch(url, options);
    const responseCode = response.getResponseCode();
    const responseBody = response.getContentText();

    if (responseCode !== 200) {
      throw new Error(`Supabase API 錯誤 (HTTP ${responseCode}): ${responseBody}`);
    }

    const details = JSON.parse(responseBody);

    // 組合前端需要的格式
    return {
      status: 'success',
      bookingId: details.booking_id,
      courseName: details.classes.courses.course_name,
      courseId: details.classes.courses.course_id,
      classId: details.classes.class_id,
      classTime: `${details.classes.class_date} ${details.classes.start_time.substring(0, 5)}`,
      userName: details.users.line_display_name,
      bookingStatus: details.status
    };

  } catch (error) {
    Logger.log(`getBookingDetailsFromSupabase 發生錯誤: ${error.toString()}`);
    return { status: 'error', message: '讀取預約詳細資料時發生錯誤: ' + error.toString() };
  }
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
    } else {
      // 如果請求不是來自 LINE Webhook，記錄下來以供除錯
      console.log("收到非 LINE Webhook 的 POST 請求:", e.postData.contents);
    }
  } catch (err) {
    // 如果解析或處理過程中出錯，可以在日誌中記錄錯誤
    // 仍然回傳一個成功的 quickReply 給 LINE，避免 LINE 不斷重試
    console.error(err.toString());
  }
  return quickReply;
}

/**
 * =================================================================
 * 【一次性執行】將 Google Sheets 資料遷移至 Supabase
 * =================================================================
 * 執行此函式前，請務必：
 * 1. 備份您的 Google Sheet 試算表。
 * 2. 確認已在 Supabase 中建立好所有資料表 (Tables)。
 * 3. 確認已將 Supabase-js 客戶端程式碼貼到 `SupabaseClient.gs` 檔案中。
 * 4. 將下方的 SUPABASE_URL 和 SUPABASE_SERVICE_KEY 替換成您自己的金鑰。
 *
 * 執行方式：在 GAS 編輯器頂部的函式下拉選單中，選擇 `migrateDataToSupabase` 並點擊「執行」。
 */
function migrateDataToSupabase() {
  Logger.log('🚀 開始進行資料遷移...');

  // 輔助函式，用於執行插入並記錄日誌
  async function insertData(tableName, sheet, transformFn = null) {
    try {
      // 輔助函式，用於將工作表的二維陣列資料轉換為物件陣列。
      const sheetDataToObjects_ = (data) => {
        if (!data || data.length < 2) return [];
        const headers = data[0].map(h => h.trim());
        return data.slice(1).map(row => headers.reduce((obj, header, index) => (header ? (obj[header] = row[index], obj) : obj), {}));
      };

      Logger.log(`--- 正在處理: ${tableName} ---`);
      let objects = sheetDataToObjects_(sheet.getDataRange().getValues());

      // 如果提供了轉換函式，則對資料進行轉換
      if (transformFn) {
        objects = objects.map(transformFn);
      }

      if (objects.length === 0) {
        Logger.log(`✅ ${tableName} 中沒有資料，跳過。`);
        return;
      }

      // 直接使用 UrlFetchApp 呼叫 Supabase REST API
      const url = `${SUPABASE_URL}/rest/v1/${tableName}`;
      const options = {
        method: 'post',
        contentType: 'application/json',
        headers: { // 修正：直接使用從指令碼屬性讀取的 SUPABASE_HEADERS
          ...SUPABASE_HEADERS,
          // 修正 #1: 使用 upsert 模式。如果主鍵已存在，則更新資料，否則新增。
          // resolution=merge-duplicates 會合併資料，而不是直接覆蓋。
          // return=minimal 表示我們不需要回傳插入的資料，這樣比較快。
          'Prefer': 'resolution=merge-duplicates,return=minimal'
        },
        payload: JSON.stringify(objects),
        muteHttpExceptions: true // 讓 GAS 在遇到 4xx/5xx 錯誤時不要拋出例外，而是回傳回應物件
      };

      const response = UrlFetchApp.fetch(url, options);
      const responseCode = response.getResponseCode();

      // 201 Created (插入) 或 200 OK (更新) 都是成功的狀態碼
      if (responseCode !== 201 && responseCode !== 200) {
        const errorResponse = response.getContentText();
        Logger.log(`❌ 遷移 ${tableName} 失敗 (HTTP ${responseCode}): ${errorResponse}`);
        throw new Error(`Failed to insert data into ${tableName}. See logs for details.`);
      } else {
        Logger.log(`✅ 成功遷移 ${objects.length} 筆資料到 ${tableName}。`);
      }
    } catch (e) {
      Logger.log(`❌ 執行 ${tableName} 遷移時發生嚴重錯誤: ${e.toString()}`);
      throw e; // 拋出錯誤以終止後續操作
    }
  }

  // 遷移順序很重要，先遷移沒有外鍵的表
  try {
    // 由於 sheetDataToObjects_ 是在 insertData 內部定義的，所以需要從外部取得工作表物件
    const SPREADSHEET = SpreadsheetApp.getActiveSpreadsheet(); 
    const USER_SHEET = SPREADSHEET.getSheetByName("Users");
    const COACH_SHEET = SPREADSHEET.getSheetByName("Coaches");
    const CLASS_SHEET = SPREADSHEET.getSheetByName("Classes");
    const COURSE_SHEET = SPREADSHEET.getSheetByName("Courses");
    const BOOKING_SHEET = SPREADSHEET.getSheetByName("Bookings");

    // 1. 遷移 Users, Coaches, Courses
    // 對於日期欄位，Google Sheet 讀取出來可能是 Date 物件，Supabase 客戶端會自動轉為 ISO 字串，通常不需特別處理
    // 但為保險起見，可以手動轉換
    const userTransform = (user) => {
      if (user.registration_date && user.registration_date instanceof Date) {
        user.registration_date = user.registration_date.toISOString();
      }
      return user;
    };
    insertData('users', USER_SHEET, userTransform);
    insertData('coaches', COACH_SHEET);
    insertData('courses', COURSE_SHEET);

    // 2. 遷移 Classes (依賴 Courses 和 Coaches)
    const classTransform = (cls) => {
      // 修正 #2: 處理數字欄位的空值
      cls.max_students = parseInt(cls.max_students) || 1; // 如果為空，預設為 1
      cls.current_students = parseInt(cls.current_students) || 0; // 如果為空，預設為 0
      cls.points = parseInt(cls.points) || 0; // 如果為空，預設為 0

      // 處理日期和時間格式，確保所有鍵都存在，無效值轉為 null
      cls.class_date = (cls.class_date instanceof Date) ? cls.class_date.toISOString().split('T')[0] : null;
      cls.start_time = (cls.start_time instanceof Date) ? cls.start_time.toISOString().split('T')[1].split('.')[0] : null;
      cls.end_time = (cls.end_time instanceof Date) ? cls.end_time.toISOString().split('T')[1].split('.')[0] : null;
      
      // 修正：對於 NOT NULL 且有 default 值的欄位，如果來源為空，我們提供一個有效的預設值。
      // 對於可為 NULL 的欄位，如果來源為空，我們傳遞 null。
      cls.create_time = (cls.create_time instanceof Date) ? cls.create_time.toISOString() : new Date().toISOString();
      cls.update_time = (cls.update_time instanceof Date) ? cls.update_time.toISOString() : null;

      return cls;
    };
    insertData('classes', CLASS_SHEET, classTransform);

    // 3. 遷移 Bookings (依賴 Classes 和 Users)
    const bookingTransform = (booking) => {
      // 修正：與 classes 表同樣的邏輯，確保所有鍵都存在
      booking.booking_time = (booking.booking_time instanceof Date) ? booking.booking_time.toISOString() : new Date().toISOString();
      booking.create_time = (booking.create_time instanceof Date) ? booking.create_time.toISOString() : new Date().toISOString();
      booking.update_time = (booking.update_time instanceof Date) ? booking.update_time.toISOString() : null;

      // 確保 create_user 和 update_user 鍵存在
      booking.create_user = booking.create_user || null;
      booking.update_user = booking.update_user || null;
      return booking;
    };
    insertData('bookings', BOOKING_SHEET, bookingTransform);

    Logger.log('🎉🎉🎉 所有資料遷移成功！🎉🎉🎉');
    Browser.msgBox("資料遷移成功！請前往 Supabase Table Editor 檢查資料。");

  } catch (e) {
    Logger.log('🔴 資料遷移過程中斷，請檢查上方日誌找出錯誤原因。');
    Browser.msgBox("資料遷移失敗！請檢查執行紀錄 (View -> Executions) 以了解詳細錯誤。");
  }
}

// 輔助函式，方便建立 JSON 回應
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
    try {
        // 1. 組合 Supabase 查詢 URL
        const tableName = 'bookings';
        // 查詢使用者所有預約，並關聯課堂、課程、教練資訊，按預約時間降序排列
        const query = `select=status,classes(class_date,start_time,courses(course_name),coaches(coach_name))&line_user_id=eq.${userId}&order=booking_time.desc`;
        const url = `${SUPABASE_URL}/rest/v1/${tableName}?${query}`;

        const options = {
            'method': 'get',
            'headers': SUPABASE_HEADERS,
            'muteHttpExceptions': true
        };

        // 2. 發送請求
        const response = UrlFetchApp.fetch(url, options);
        const responseCode = response.getResponseCode();
        const responseBody = response.getContentText();

        if (responseCode !== 200) {
            throw new Error(`Supabase API 錯誤 (HTTP ${responseCode}): ${responseBody}`);
        }

        const userRecords = JSON.parse(responseBody);

        // 3. 處理查詢結果
        if (userRecords.length === 0) {
            return '您目前沒有任何預約紀錄喔！';
        }

        // 4. 組合回傳訊息
        let message = '您的預約紀錄如下：\n----------\n';
        userRecords.forEach(record => {
            const cls = record.classes;
            let classInfo = '未知課程';
            if (cls) {
                const courseName = cls.courses ? cls.courses.course_name : '課程';
                const coachName = cls.coaches ? cls.coaches.coach_name : '教練';
                const classTime = `${cls.class_date} ${cls.start_time.substring(0, 5)}`;
                classInfo = `${courseName}\n時間：${classTime}\n教練：${coachName}`;
            }
            message += `課程：${classInfo}\n狀態：${record.status}\n----------\n`;
        });
        return message.trim();

    } catch (error) {
        Logger.log(`getBookingHistory 發生錯誤: ${error.toString()}`);
        return '查詢預約紀錄時發生錯誤，請稍後再試。';
    }
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
          "text": "聯絡資訊" // 點擊後，使用者會送出 "聯絡資訊" 文字訊息
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
 * [管理後台] 取得指定一週的課表資料
 * @param {object} params - 包含 startDate (格式 YYYY-MM-DD) 的請求參數
 * @returns {object} - 包含該週所有課堂資訊的物件
 */
function getClassesForManager(params) {
  try {
    if (!params.startDate) {
      throw new Error("缺少 startDate 參數");
    }

    // 1. 準備時間範圍和資料結構
    const startDate = new Date(params.startDate);
    const endDate = new Date(startDate);
    endDate.setDate(startDate.getDate() + 7); // 取得7天的範圍

    const scheduleData = {};
    for (let i = 0; i < 7; i++) {
      const date = new Date(startDate);
      date.setDate(startDate.getDate() + i);
      const dateString = Utilities.formatDate(date, "GMT+8", "yyyy-MM-dd");
      scheduleData[dateString] = {};
    }

    // 2. 讀取並建立 Coach Map
    const coachObjects = getCachedSheetData_(COACH_SHEET, 'coaches_data', 600); // 快取 10 分鐘
    const coachMap = new Map(coachObjects.map(c => [c.coach_id, c.coach_name]));

    // 新增：讀取課程資料並建立 Map，以便查詢顏色
    const courseObjects = getCachedSheetData_(COURSE_SHEET, 'courses_data', 600);
    const courseMap = new Map(courseObjects.map(c => [c.course_id, { color: c.color }]));

    // 3. 讀取所有課堂資料並填入網格
    const classObjects = getCachedSheetData_(CLASS_SHEET, 'classes_data', 60); // 課表變動頻繁，快取 1 分鐘

    classObjects.forEach(cls => {
      const classDate = new Date(cls.class_date);
      // 篩選出在指定日期範圍內的課堂
      if (classDate >= startDate && classDate < endDate) {
        const dateString = Utilities.formatDate(classDate, "GMT+8", "yyyy-MM-dd");
        const startTimeString = Utilities.formatDate(new Date(cls.start_time), "GMT+8", "HH:00");

        if (scheduleData[dateString]) {
          // 一個時段可能有多堂課，所以用陣列儲存
          if (!scheduleData[dateString][startTimeString]) {
            scheduleData[dateString][startTimeString] = [];
          }
          // 從 courseMap 查找顏色，如果找不到則給一個預設顏色
          const courseInfo = courseMap.get(cls.course_id);
          const courseColor = courseInfo && courseInfo.color ? courseInfo.color : '#6c757d'; // 預設灰色

          scheduleData[dateString][startTimeString].push({
            classId: cls.class_id,
            className: cls.class_name,
            color: courseColor, // 新增：回傳顏色代碼
            coachName: coachMap.get(cls.coach_id) || '未知教練',
            currentStudents: cls.current_students,
            maxStudents: cls.max_students,
          });
        }
      }
    });

    return { status: 'success', classes: scheduleData };
  } catch (error) {
    Logger.log('getClassesForManager 發生錯誤: ' + error.toString());
    return { status: 'error', message: '讀取課表資料時發生錯誤: ' + error.toString() };
  }
}

/**
 * [管理後台] 取得課表表單需要用的資料 (課程型錄、教練列表)
 * @returns {object} - 包含 courses 和 coaches 陣列的物件
 */
function getManagerFormData() {
  try {
    const courseObjects = getCachedSheetData_(COURSE_SHEET, 'courses_data', 600); // 快取 10 分鐘
    const coachObjects = getCachedSheetData_(COACH_SHEET, 'coaches_data', 600); // 快取 10 分鐘

    // 只回傳狀態為 Active 的課程
    const activeCourses = courseObjects.filter(c => c.status === 'Active').map(c => ({
      courseId: c.course_id,
      courseName: c.course_name
    }));

    const coaches = coachObjects.map(c => ({
      coachId: c.coach_id,
      coachName: c.coach_name
    }));

    return { status: 'success', courses: activeCourses, coaches: coaches };
  } catch (error) {
    Logger.log('getManagerFormData 發生錯誤: ' + error.toString());
    return { status: 'error', message: '讀取表單資料時發生錯誤: ' + error.toString() };
  }
}

/**
 * [管理後台] 新增或更新一筆課堂資料
 * @param {object} data - 包含課堂資訊的物件
 * @returns {object} - 操作結果
 */
function saveClass(data) {
  const lock = LockService.getScriptLock();
  lock.waitLock(15000);

  // 在寫入操作前，清除相關快取
  const cache = CacheService.getScriptCache();
  cache.remove('classes_data');

  try {
    const classValues = CLASS_SHEET.getDataRange().getValues();
    const headers = classValues[0];
    const classIdColIndex = headers.indexOf('class_id');

    // 從 data 中解構出需要的欄位
    const { classId, dateTime, courseId, className, coachId, maxStudents } = data;

    if (!dateTime || !courseId || !className || !coachId || !maxStudents) {
      throw new Error("缺少必要的課堂資訊");
    }

    // 解析日期和時間
    const [datePart, timePart] = dateTime.split(' ');
    const classDate = new Date(datePart);
    const startTime = new Date(`${datePart}T${timePart}:00`);

    if (classId) {
      // --- 更新模式 ---
      let targetRow = -1;
      for (let i = 1; i < classValues.length; i++) {
        if (classValues[i][classIdColIndex] === classId) {
          targetRow = i + 1;
          break;
        }
      }

      if (targetRow === -1) {
        return { status: 'error', message: '找不到要更新的課堂' };
      }

      // 建立一個要更新的欄位和值的對應
      const updates = {
        'course_id': courseId,
        'coach_id': coachId,
        'class_name': className,
        'max_students': maxStudents,
        'update_time': new Date(),
        'update_user': 'Admin' // 假設是管理者操作
      };

      // 遍歷 headers 來設定對應欄位的值
      headers.forEach((header, index) => {
        if (updates[header]) {
          CLASS_SHEET.getRange(targetRow, index + 1).setValue(updates[header]);
        }
      });

      return { status: 'success', message: '課堂更新成功！' };

    } else {
      // --- 新增模式 ---
      // 根據上課日期產生新的流水號 ID，格式為 CLYYMMXXX
      const year = classDate.getFullYear().toString().slice(-2); // YY
      const month = (classDate.getMonth() + 1).toString().padStart(2, '0'); // MM
      const idPrefix = `CL${year}${month}`;

      // 找出該月份已存在的最大流水號
      const classIdsForMonth = classValues
        .slice(1) // 略過標頭
        .map(row => row[classIdColIndex])
        .filter(id => id && typeof id === 'string' && id.startsWith(idPrefix));

      let maxNum = 0;
      classIdsForMonth.forEach(id => {
        const numPart = parseInt(id.substring(idPrefix.length), 10);
        if (!isNaN(numPart) && numPart > maxNum) {
          maxNum = numPart;
        }
      });

      const newNum = maxNum + 1;
      if (newNum > 999) {
        return { status: 'error', message: `當月課堂ID已達上限 (999)，無法新增。` };
      }

      const newClassId = idPrefix + String(newNum).padStart(3, '0');
      
      // 注意：appendRow 的順序必須和 Classes 工作表欄位完全一致
      CLASS_SHEET.appendRow([
        newClassId,       // class_id
        courseId,         // course_id
        coachId,          // coach_id
        className,        // class_name
        classDate,        // class_date
        startTime,        // start_time
        '',               // end_time (可選)
        maxStudents,      // max_students
        0,                // current_students (初始為0)
        '開放中',         // status
        0,                // points (可選)
        new Date(),       // create_time
        'Admin',          // create_user
        '',               // update_time
        ''                // update_user
      ]);

      return { status: 'success', message: '課堂新增成功！' };
    }
  } catch (error) {
    Logger.log('saveClass 發生錯誤: ' + error.toString());
    return { status: 'error', message: '儲存課堂時發生錯誤: ' + error.toString() };
  } finally {
    lock.releaseLock();
  }
}

/**
 * [管理後台] 刪除一筆課堂資料
 * @param {object} data - 包含 classId 的物件
 * @returns {object} - 操作結果
 */
function deleteClass(data) {
  const lock = LockService.getScriptLock();
  lock.waitLock(15000);

  // 在寫入操作前，清除相關快取
  const cache = CacheService.getScriptCache();
  cache.remove('classes_data');

  try {
    const { classId } = data;
    if (!classId) {
      throw new Error("缺少 classId");
    }

    // 1. 安全檢查：檢查是否有學員預約此課程
    const bookingObjects = sheetDataToObjects_(BOOKING_SHEET.getDataRange().getValues());
    const hasBookings = bookingObjects.some(booking => 
        booking.class_id === classId && 
        (booking.status === '已預約' || booking.status === '已扣款')
    );

    if (hasBookings) {
      return { status: 'error', message: '無法刪除：此課堂已有學員預約。請先將相關預約取消。' };
    }

    // 2. 尋找並刪除課程
    const classValues = CLASS_SHEET.getDataRange().getValues();
    const classIdColIndex = classValues[0].indexOf('class_id');
    let targetRow = -1;
    for (let i = 1; i < classValues.length; i++) {
      if (classValues[i][classIdColIndex] === classId) {
        targetRow = i + 1;
        break;
      }
    }

    if (targetRow !== -1) {
      CLASS_SHEET.deleteRow(targetRow);
      return { status: 'success', message: '課堂刪除成功！' };
    } else {
      return { status: 'error', message: '找不到要刪除的課堂。' };
    }
  } catch (error) {
    Logger.log('deleteClass 發生錯誤: ' + error.toString());
    return { status: 'error', message: '刪除課堂時發生錯誤: ' + error.toString() };
  } finally {
    lock.releaseLock();
  }
}
