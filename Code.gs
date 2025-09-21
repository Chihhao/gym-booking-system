// --- 全域變數設定 ---
const VERSION = "2.1";
const DEPLOYMENT_ID = "AKfycbzsR-H8MM9LLrAxeHPK97qJtLNL-YweksnKpA6Io14RyOrZ8NENTQ7uZ3Bd2ng6Ht3G"; // 固定的部署ID
// 之後會將 Google Sheet 的各個工作表定義在這裡，方便管理
const SPREADSHEET = SpreadsheetApp.getActiveSpreadsheet(); 
const USER_SHEET = SPREADSHEET.getSheetByName("Users");
const COACH_SHEET = SPREADSHEET.getSheetByName("Coaches");
const CLASS_SHEET = SPREADSHEET.getSheetByName("Classes");
const COURSE_SHEET = SPREADSHEET.getSheetByName("Courses"); // 新增 Courses 工作表
const BOOKING_SHEET = SPREADSHEET.getSheetByName("Bookings");

const CHANNEL_ACCESS_TOKEN = '6HTikANeIpIjHqztdhXHorN8XehTVjYJLHmbgTSWK/GuaKVztsg65IkK/JC7sRDi47nayqJPlr0wGHeZJSx/YOvWEjypEdMpwR0Mqb71JhhOumQ8Dj4PXIkxVX5cjIDtkDktRdwZcLwyUdXgiuLSTQdB04t89/1O/w1cDnyilFU=';

// GAS URL:
// https://script.google.com/macros/s/AKfycbxDeUvMH7y_OlMqDrZIwylgOtcCE0HwbOIpQkABj7Sa7KtD5Pd5ndjwInrL9OE3Ngo/exec

// https://liff.line.me/2008135811-vNO5bYyx

// 佈署命令
// clasp push && clasp deploy --deploymentId AKfycbzsR-H8MM9LLrAxeHPK97qJtLNL-YweksnKpA6Io14RyOrZ8NENTQ7uZ3Bd2ng6Ht3G

/**
 * [核心輔助函式] 將工作表的二維陣列資料轉換為物件陣列。
 * @param {Array<Array<any>>} data - 從 sheet.getDataRange().getValues() 得到的資料。
 * @returns {Array<Object>} - 物件陣列，例如 [{header1: value1, header2: value2}, ...]。
 */
function sheetDataToObjects_(data) {
  if (!data || data.length < 2) {
    return [];
  }
  const headers = data[0].map(header => header.trim()); // 取得標頭並去除前後空白
  return data.slice(1).map(row => {
    const obj = {};
    headers.forEach((header, index) => {
      // 只有當標頭名稱非空時才加入物件
      if (header) {
        obj[header] = row[index];
      }
    });
    return obj;
  });
}

/**
 * [效能優化] 帶有快取機制的 sheetDataToObjects_ 版本。
 * @param {GoogleAppsScript.Spreadsheet.Sheet} sheet - 要讀取的工作表物件。
 * @param {string} cacheKey - 此工作表在快取中的唯一鍵值。
 * @param {number} expirationInSeconds - 快取的有效時間（秒）。
 * @returns {Array<Object>} - 物件陣列。
 */
function getCachedSheetData_(sheet, cacheKey, expirationInSeconds) {
  const cache = CacheService.getScriptCache();
  const cachedData = cache.get(cacheKey);

  if (cachedData != null) {
    // Logger.log(`快取命中: ${cacheKey}`);
    return JSON.parse(cachedData);
  }

  // Logger.log(`快取未命中: ${cacheKey}`);
  const data = sheet.getDataRange().getValues();
  const objects = sheetDataToObjects_(data);
  cache.put(cacheKey, JSON.stringify(objects), expirationInSeconds);
  return objects;
}

function doGet(e) {
  // 檢查是否有 'page' 參數，若有，則視為頁面請求
  const page = e.parameter.page;
  if (page) {
    let template;
    switch (page) {
      case 'courses':
        template = HtmlService.createTemplateFromFile('courses');
        break;
      case 'schedule':
        template = HtmlService.createTemplateFromFile('schedule');
        break;
      case 'booking-details':
        template = HtmlService.createTemplateFromFile('booking-details');
        break;
      case 'manager':
        template = HtmlService.createTemplateFromFile('manager');
        break;
      case 'admin': // 為了舊版 admin.html 保留
        template = HtmlService.createTemplateFromFile('admin');
        break;
      default:
        // 如果 page 參數無效，也回到首頁
        template = HtmlService.createTemplateFromFile('index');
        break;
    }
    return template.evaluate().addMetaTag('viewport', 'width=device-width, initial-scale=1.0');
  }

  // 如果沒有 'page' 參數，則執行原有的 API 路由器邏輯
  const action = e.parameter.action;
  try {
    switch (action) {
      case 'getSchedule': return createJsonResponse(getWeeklySchedule(e.parameter));
      case 'getBookingDetails': return createJsonResponse(getBookingDetails(e.parameter));
      case 'getAllBookings': return createJsonResponse(getAllBookings(e.parameter));
      case 'getClassesForManager': return createJsonResponse(getClassesForManager(e.parameter));
      case 'getManagerFormData': return createJsonResponse(getManagerFormData());
      case 'getClassDetails': return createJsonResponse(getClassDetails(e.parameter));
      case 'getAllCoursesForManager': return createJsonResponse(getAllCoursesForManager());
      case 'getCourseDetailsForManager': return createJsonResponse(getCourseDetailsForManager(e.parameter));
      case 'getAllCoachesForManager': return createJsonResponse(getAllCoachesForManager());
      case 'getCoachDetailsForManager': return createJsonResponse(getCoachDetailsForManager(e.parameter));
      case 'getAllUsersForManager': return createJsonResponse(getAllUsersForManager(e.parameter));
      case 'getUserDetailsForManager': return createJsonResponse(getUserDetailsForManager(e.parameter));
      case 'getPendingBookings': return getPendingBookings();
      case 'test': return testDataRead();
      // 當 action 為空或未定義時，有兩種可能：
      // 1. 舊的 index.html (現在是 courses.html) 請求課程列表
      // 2. 直接在瀏覽器打開 /exec 網址
      default:
        // 如果沒有 action，但也沒有 page，就顯示首頁
        if (!action) {
          return HtmlService.createTemplateFromFile('index').evaluate().addMetaTag('viewport', 'width=device-width, initial-scale=1.0');
        }
        // 為了相容舊的 courses.html，如果 action 是空的，就回傳課程列表
        return getCourses(); // getCourses() 會回傳 JSON
    }
  } catch (error) {
    return createJsonResponse({ status: 'error', message: '處理 GET 請求時發生錯誤: ' + error.toString() });
  }
}

function getDeploymentInfo() {
  // 為了讓前端的 PROD_GAS_URL 可以正確被替換，我們需要一個輔助函式
  // 這個函式會被用在 HtmlService.createTemplateFromFile(fileName) 中
  // 雖然這裡沒有直接使用，但保留這個概念很重要
  return ContentService
    .createTextOutput(JSON.stringify({ 
      version: VERSION,
      deploymentTime: new Date().toISOString()
    }))
    .setMimeType(ContentService.MimeType.JSON);
}

/**
 * [核心] 處理來自前端的 GET 請求。
 * 根據 URL 中的 'page' 或 'action' 參數決定回傳 HTML 頁面或 JSON 資料。
 *
 * 路由邏輯：
 * 1. 如果有 `page` 參數 (e.g., `?page=courses`)：回傳對應的 HTML 頁面。
 *    - 這是 LIFF 或管理者直接存取特定頁面的主要方式。
 * 2. 如果沒有 `page` 參數，但有 `action` 參數 (e.g., `?action=getAllBookings`)：
 *    - 執行 API 邏輯，回傳 JSON 資料。
 * 3. 如果 `page` 和 `action` 都沒有 (直接存取 `.../exec`)：
 *    - 回傳專案首頁 `index.html`。
 * 4. 如果 `action` 參數為空 (相容舊版 `courses.html` 的 fetch(GAS_URL))：
 *    - 執行 `getCourses()`，回傳課程列表 JSON。
 */



// 測試資料讀取
function testDataRead() {
  try {
    const classData = CLASS_SHEET.getDataRange().getValues();
    return ContentService
      .createTextOutput(JSON.stringify({ 
        success: true, 
        dataLength: classData.length,
        firstRow: classData[0],
        secondRow: classData[1]
      }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService
      .createTextOutput(JSON.stringify({ 
        success: false, 
        error: error.toString() 
      }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

// 檢查資料格式的函式
function checkDataFormat() {
  const classData = CLASS_SHEET.getDataRange().getValues();
  const coachData = COACH_SHEET.getDataRange().getValues();
  
  const result = {
    classData: classData,
    coachData: coachData,
    classDataLength: classData.length,
    coachDataLength: coachData.length
  };
  
  return ContentService
    .createTextOutput(JSON.stringify(result, null, 2))
    .setMimeType(ContentService.MimeType.JSON);
}

function buildClassMap_() {
  const classObjects = sheetDataToObjects_(CLASS_SHEET.getDataRange().getValues());
  const coachObjects = sheetDataToObjects_(COACH_SHEET.getDataRange().getValues());
  
  const coachMap = {};
  coachObjects.forEach(coach => {
    if (coach.coach_id) {
      coachMap[coach.coach_id] = coach.coach_name;
    }
  });

  const classMap = {};
  classObjects.forEach(cls => {
    if (cls.class_id) {
      const classDate = Utilities.formatDate(new Date(cls.class_date), "GMT+8", "yyyy-MM-dd");
      const startTime = Utilities.formatDate(new Date(cls.start_time), "GMT+8", "HH:mm");
      const coachName = coachMap[cls.coach_id] || '未知教練';
      // 讓 classMap 儲存更完整的資訊，方便各處使用
      classMap[cls.class_id] = `${classDate} ${startTime} (${coachName})`;
    }
  });
  return classMap;
}

/**
 * [新功能] 根據 bookingId 取得單筆預約的詳細資訊
 * @param {object} params - 包含 bookingId 的請求參數
 */
function getBookingDetails(params) {
  const bookingId = params.bookingId;
  if (!bookingId) {
    throw new Error("缺少 bookingId 參數");
  }

  const bookingObjects = sheetDataToObjects_(BOOKING_SHEET.getDataRange().getValues());
  const targetBooking = bookingObjects.find(b => b.booking_id === bookingId);

  if (!targetBooking) {
    return { status: 'error', message: '找不到此預約紀錄' };
  }

  // 為了取得完整資訊，我們需要所有表格的資料
  const classObjects = sheetDataToObjects_(CLASS_SHEET.getDataRange().getValues());
  const courseObjects = sheetDataToObjects_(COURSE_SHEET.getDataRange().getValues());
  const userObjects = sheetDataToObjects_(USER_SHEET.getDataRange().getValues());

  const targetClass = classObjects.find(c => c.class_id === targetBooking.class_id);
  const targetCourse = targetClass ? courseObjects.find(co => co.course_id === targetClass.course_id) : null;
  const targetUser = userObjects.find(u => u.line_user_id === targetBooking.line_user_id);

  if (!targetClass || !targetCourse || !targetUser) {
    return { status: 'error', message: '預約相關資料不完整' };
  }

  const classDate = Utilities.formatDate(new Date(targetClass.class_date), "GMT+8", "yyyy-MM-dd");
  const startTime = Utilities.formatDate(new Date(targetClass.start_time), "GMT+8", "HH:mm");

  return {
    status: 'success',
    bookingId: targetBooking.booking_id,
    courseName: targetCourse.course_name,
    courseId: targetCourse.course_id,
    classId: targetClass.class_id,
    classTime: `${classDate} ${startTime}`,
    userName: targetUser.line_display_name,
    bookingStatus: targetBooking.status
  };
}

function getPendingBookings() {
  const classMap = buildClassMap_(); // 直接呼叫輔助函式

  const userObjects = sheetDataToObjects_(USER_SHEET.getDataRange().getValues());
  const userMap = {};
  userObjects.forEach(user => {
    if (user.line_user_id) {
      userMap[user.line_user_id] = user.line_display_name;
    }
  });
  
  const bookingObjects = sheetDataToObjects_(BOOKING_SHEET.getDataRange().getValues());
  const pendingBookings = [];

  // 從後往前遍歷以獲得最新的預約
  for (let i = bookingObjects.length - 1; i >= 0; i--) {
    const booking = bookingObjects[i];
    // 使用 .trim() 移除前後空白，讓比對更穩健
    if (booking.status && booking.status.trim() === '已預約') { // 撈取新狀態 "已預約" 的單據
      pendingBookings.push({
        bookingId: booking.booking_id,
        classInfo: classMap[booking.class_id] || `未知課程(ID: ${booking.class_id})`,
        userName: userMap[booking.line_user_id] || '未知用戶'
      });
    }
  }

  return ContentService
    .createTextOutput(JSON.stringify({ bookings: pendingBookings }))
    .setMimeType(ContentService.MimeType.JSON);
}

/**
 * [新功能] 取得所有有效的課程型錄資訊
 * @returns {object} - 包含所有課程資訊的 JSON 物件
 */
function getCourses() {
  if (!COURSE_SHEET) {
    return createJsonResponse({ status: 'error', message: '找不到名為 "Courses" 的工作表' });
  }
  // 優化：使用快取讀取課程資料，快取 5 分鐘
  const courseObjects = getCachedSheetData_(COURSE_SHEET, 'active_courses_data', 300);

  const activeCourses = [];

  courseObjects.forEach(course => {
    // 只回傳狀態為 Active 的課程
    if (course.course_id && course.status === 'Active') {
      activeCourses.push(course);
    }
  });
  
  return createJsonResponse({ courses: activeCourses });
}


function getClassSchedule() {
  const coachObjects = sheetDataToObjects_(COACH_SHEET.getDataRange().getValues());
  const coachMap = {};
  coachObjects.forEach(coach => {
    if (coach.coach_id) {
      coachMap[coach.coach_id] = coach.coach_name;
    }
  });

  const classObjects = sheetDataToObjects_(CLASS_SHEET.getDataRange().getValues());
  const schedule = [];

  classObjects.forEach(cls => {
    if (cls.class_id && cls.status === '開放中') {
      schedule.push({
        classId: cls.class_id,
        className: cls.class_name || '未命名課程',
        coachName: coachMap[cls.coach_id] || '未知教練',
        date: cls.class_date,
        startTime: cls.start_time,
        endTime: cls.end_time,
        remaining: cls.max_students - cls.current_students,
      });
    }
  });
  
  return ContentService
    .createTextOutput(JSON.stringify({ classes: schedule }))
    .setMimeType(ContentService.MimeType.JSON);
}

/**
 * [新功能] 根據課程 ID，取得未來一週的時間表網格資料
 * @param {object} params - 包含 courseId 的請求參數
 * @returns {object} - 符合前端網格需求的資料結構
 */
function getWeeklySchedule(params) {
  const courseId = params.courseId;
  const userId = params.userId; // 接收 userId
  if (!courseId) {
    throw new Error("缺少 courseId 參數");
  }
  // 為了讓開發模式也能運作，我們先不強制檢查 userId
  // if (!userId) {
  //   throw new Error("缺少 userId 參數");
  // }

  // 1. 準備時間範圍和基本資料結構
  const scheduleData = {};
  const today = new Date();
  today.setHours(0, 0, 0, 0); // 標準化到當天零點
  const hours = Array.from({length: 13}, (_, i) => (i + 9).toString().padStart(2, '0') + ':00'); // 09:00 to 21:00

  // 初始化未來七天的網格，全部預設為 'no_class'
  for (let i = 0; i < 7; i++) {
    const date = new Date(today);
    date.setDate(today.getDate() + i);
    const dateString = Utilities.formatDate(date, "GMT+8", "yyyy-MM-dd");
    
    scheduleData[dateString] = {};
    hours.forEach(hour => {
      scheduleData[dateString][hour] = { status: 'no_class' };
    });
  }

  // 建立使用者已預約課程的 Set，方便快速查詢
  const userBookings = new Map(); // 改用 Map 來同時儲存 bookingId
  if (userId) {
    const bookingObjects = sheetDataToObjects_(BOOKING_SHEET.getDataRange().getValues());
    bookingObjects.forEach(booking => {
      if (booking.line_user_id === userId && (booking.status.trim() === '已預約' || booking.status.trim() === '已扣款')) {
        // key: class_id, value: booking_id
        userBookings.set(booking.class_id, booking.booking_id);
      }
    });
  }

  // 2. 讀取所有課程資料
  const classObjects = sheetDataToObjects_(CLASS_SHEET.getDataRange().getValues());
  const sevenDaysLater = new Date(today);
  sevenDaysLater.setDate(today.getDate() + 7);

  // 3. 遍歷課程，將符合條件的課程填入網格
  classObjects.forEach(cls => {
    // 篩選條件：課程 ID 相符、狀態為開放中、在未來七天內
    const classDate = new Date(cls.class_date);
    if (cls.course_id === courseId && cls.status === '開放中' && classDate >= today && classDate < sevenDaysLater) {
      const dateString = Utilities.formatDate(classDate, "GMT+8", "yyyy-MM-dd");
      const startTimeString = Utilities.formatDate(new Date(cls.start_time), "GMT+8", "HH:00"); // 只取整點小時

      // 確保日期和時間存在於我們的網格結構中
      if (scheduleData[dateString] && scheduleData[dateString][startTimeString]) {
        // 優先判斷是否為使用者已預約
        if (userBookings.has(cls.class_id)) {
          scheduleData[dateString][startTimeString] = {
            status: 'booked_by_me',
            schedule_id: cls.class_id,
            booking_id: userBookings.get(cls.class_id) // 附上 booking_id
          };
        } else {
          const remaining = cls.max_students - cls.current_students;
          const status = remaining > 0 ? 'available' : 'full';
          scheduleData[dateString][startTimeString] = {
            status: status,
            schedule_id: cls.class_id, // 前端預約時需要這個 ID
            remaining: remaining // 新增：回傳剩餘名額
          };
        }
      }
    }
  });

  return scheduleData;
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
    // 仍然回傳一個成功的 quickReply 給 LINE，避免 LINE 不斷重試
    console.error(err.toString());
  }
  
  return quickReply;
}

// 新增一個專門處理網頁請求的函式，讓 doPost 更清晰 ---
function handleWebAppActions(request) {
    switch (request.action) {
      case 'createBooking':
        return createBooking(request.data);
      case 'saveClass': // 新增：管理後台儲存課堂 (新增/更新)
        return saveClass(request.data);
      case 'reviewBooking':
        return reviewBooking(request.data);
      case 'saveCourse': // 新增：管理後台儲存課程型錄 (新增/更新)
        return saveCourse(request.data);
      case 'deleteCourse': // 新增：管理後台刪除課程型錄
        return deleteCourse(request.data);
      case 'saveCoach': // 新增：管理後台儲存教練 (新增/更新)
        return saveCoach(request.data);
      case 'updateUserPoints': // 新增：管理後台更新使用者點數
        return updateUserPoints(request.data);
      case 'deleteCoach': // 新增：管理後台刪除教練
        return deleteCoach(request.data);
      case 'deleteClass': // 新增：管理後台刪除課堂
        return deleteClass(request.data);
      default:
        return { status: 'error', message: '無效的網頁操作' };
    }
}

/**
 * 處理新增預約的核心函式
 * @param {object} data - 包含 classId 和 liffData (使用者資訊)
 */
function createBooking(data) {
  const { classId, liffData } = data;
  const { userId, displayName } = liffData;

  const bookingObjects = sheetDataToObjects_(BOOKING_SHEET.getDataRange().getValues());
  const hasBooked = bookingObjects.some(booking => 
    booking.line_user_id === userId && 
    booking.class_id === classId &&
    (booking.status === '已預約' || booking.status === '已扣款')); // 檢查新狀態

  if (hasBooked) {
      return { status: 'error', message: '您已預約此課程，請勿重複預約。' };
  }

  const lock = LockService.getScriptLock();
  lock.waitLock(15000);

  try {
    const classValues = CLASS_SHEET.getDataRange().getValues();
    const classHeaders = classValues[0];
    const currentStudentsColIndex = classHeaders.indexOf('current_students') + 1;

    let targetClassRow = -1;
    let classInfo = {};

    for (let i = 1; i < classValues.length; i++) {
      // class_id is in the first column (index 0)
      if (classValues[i][classHeaders.indexOf('class_id')] === classId) {
        targetClassRow = i + 1;
        classInfo = { 
          max: classValues[i][classHeaders.indexOf('max_students')], 
          current: classValues[i][classHeaders.indexOf('current_students')] 
        };
        break;
      }
    }

    if (targetClassRow === -1 || classInfo.current >= classInfo.max) {
      return { status: 'error', message: '課程已額滿或不存在' };
    }

    // 更新已報名人數
    CLASS_SHEET.getRange(targetClassRow, currentStudentsColIndex).setValue(classInfo.current + 1);
    
    const userObjects = sheetDataToObjects_(USER_SHEET.getDataRange().getValues());
    const userExists = userObjects.some(user => user.line_user_id === userId);

    if (!userExists) {
      // 注意：這裡的 appendRow 順序必須和 Users 工作表欄位完全一致
      USER_SHEET.appendRow([userId, displayName, new Date(), 0, '', '']); // points, line_id, phone_number
    }

    // --- 新的預約編號生成邏輯 ---
    const now = new Date();
    const year = now.getFullYear(); // YYYY
    const month = (now.getMonth() + 1).toString().padStart(2, '0'); // MM
    const idPrefix = `BK${year}${month}`;

    // 找出該月份已存在的最大流水號
    const bookingIdColIndex = bookingObjects[0] ? Object.keys(bookingObjects[0]).indexOf('booking_id') : -1;
    const bookingIdsForMonth = bookingObjects
      .map(b => b.booking_id)
      .filter(id => id && typeof id === 'string' && id.startsWith(idPrefix));

    let maxNum = 0;
    bookingIdsForMonth.forEach(id => {
      const numPart = parseInt(id.substring(idPrefix.length), 10);
      if (!isNaN(numPart) && numPart > maxNum) {
        maxNum = numPart;
      }
    });

    const newNum = maxNum + 1;
    // 格式化為五位數流水號，例如 "00001"
    const bookingId = idPrefix + String(newNum).padStart(5, '0');

    // 注意：這裡的 appendRow 順序必須和 Bookings 工作表欄位完全一致
    BOOKING_SHEET.appendRow([
      bookingId, 
      classId, 
      userId, 
      now, 
      '已預約', // 狀態直接設為 "已預約"
      new Date(), // create_time
      displayName, // create_user
      '', // update_time
      '' // update_user
    ]);

    return { status: 'success', message: '預約成功！', bookingId: bookingId };

  } catch (error) {
    return { status: 'error', message: '處理預約時發生錯誤: ' + error.toString() };
  } finally {
    lock.releaseLock();
  }
}

/**
 * [管理後台] 取得所有使用者資料
 * @param {object} params - 包含篩選條件的請求參數 (例如 query)
 * @returns {object} - 包含所有使用者的物件
 */
function getAllUsersForManager(params) {
  try {
    // 優化：使用快取讀取使用者資料，快取 5 分鐘
    const userObjects = getCachedSheetData_(USER_SHEET, 'users_data', 300);
    
    let filteredUsers = userObjects;

    // 關鍵字搜尋 (可搜尋暱稱或ID)
    if (params && params.query) {
      const queryLower = params.query.toLowerCase();
      filteredUsers = userObjects.filter(u => 
        (u.line_display_name && u.line_display_name.toLowerCase().includes(queryLower)) ||
        (u.line_user_id && u.line_user_id.toLowerCase().includes(queryLower))
      );
    }

    return { status: 'success', users: filteredUsers.reverse() }; // 預設讓最新的在最上面
  } catch (error) {
    Logger.log('getAllUsersForManager 發生錯誤: ' + error.toString());
    return { status: 'error', message: '讀取使用者資料時發生錯誤: ' + error.toString() };
  }
}

/**
 * [管理後台] 取得單一使用者的詳細資料
 * @param {object} params - 包含 userId 的請求參數
 * @returns {object} - 包含使用者詳細資訊的物件
 */
function getUserDetailsForManager(params) {
  try {
    const { userId } = params;
    if (!userId) {
      throw new Error("缺少 userId 參數");
    }

    // 優化：使用快取讀取使用者資料
    const userObjects = getCachedSheetData_(USER_SHEET, 'users_data', 300);
    const targetUser = userObjects.find(u => u.line_user_id === userId);

    if (!targetUser) {
      return { status: 'error', message: '找不到指定的使用者' };
    }

    return { status: 'success', details: targetUser };
  } catch (error) {
    Logger.log('getUserDetailsForManager 發生錯誤: ' + error.toString());
    return { status: 'error', message: '讀取使用者詳細資料時發生錯誤: ' + error.toString() };
  }
}

/**
 * [管理後台] 更新使用者的點數
 * @param {object} data - 包含 userId 和 points 的物件
 * @returns {object} - 操作結果
 */
function updateUserPoints(data) {
  const lock = LockService.getScriptLock();
  lock.waitLock(15000);

  try {
    const { userId, points } = data;
    if (!userId || points === undefined || points === null) {
      throw new Error("缺少 userId 或 points 參數");
    }

    const userValues = USER_SHEET.getDataRange().getValues();
    const headers = userValues[0];
    const userIdColIndex = headers.indexOf('line_user_id');
    const pointsColIndex = headers.indexOf('points');

    let targetRow = -1;
    for (let i = 1; i < userValues.length; i++) {
      if (userValues[i][userIdColIndex] === userId) {
        targetRow = i + 1;
        break;
      }
    }

    if (targetRow === -1) return { status: 'error', message: '找不到要更新的使用者' };

    USER_SHEET.getRange(targetRow, pointsColIndex + 1).setValue(points);
    return { status: 'success', message: '使用者點數更新成功！' };

  } catch (error) {
    Logger.log('updateUserPoints 發生錯誤: ' + error.toString());
    return { status: 'error', message: '更新使用者點數時發生錯誤: ' + error.toString() };
  } finally {
    lock.releaseLock();
  }
}

/**
 * [管理後台] 取得所有教練資料
 * @returns {object} - 包含所有教練的物件
 */
function getAllCoachesForManager() {
  try {
    // 優化：使用快取讀取教練資料，快取 10 分鐘
    const coachObjects = getCachedSheetData_(COACH_SHEET, 'coaches_data', 600);
    // 管理後台需要看到所有教練，所以不過濾狀態
    return { status: 'success', coaches: coachObjects.reverse() }; // 讓最新的在最上面
  } catch (error) {
    Logger.log('getAllCoachesForManager 發生錯誤: ' + error.toString());
    return { status: 'error', message: '讀取教練資料時發生錯誤: ' + error.toString() };
  }
}

/**
 * [管理後台] 取得單一教練的詳細資料
 * @param {object} params - 包含 coachId 的請求參數
 * @returns {object} - 包含教練詳細資訊的物件
 */
function getCoachDetailsForManager(params) {
  try {
    const { coachId } = params;
    if (!coachId) {
      throw new Error("缺少 coachId 參數");
    }

    // 優化：使用快取讀取教練資料
    const coachObjects = getCachedSheetData_(COACH_SHEET, 'coaches_data', 600);
    const targetCoach = coachObjects.find(c => c.coach_id === coachId);

    if (!targetCoach) {
      return { status: 'error', message: '找不到指定的教練' };
    }

    return { status: 'success', details: targetCoach };
  } catch (error) {
    Logger.log('getCoachDetailsForManager 發生錯誤: ' + error.toString());
    return { status: 'error', message: '讀取教練詳細資料時發生錯誤: ' + error.toString() };
  }
}

/**
 * [管理後台] 新增或更新一筆教練資料
 * @param {object} data - 包含教練資訊的物件
 * @returns {object} - 操作結果
 */
function saveCoach(data) {
  const lock = LockService.getScriptLock();
  lock.waitLock(15000);

  // 在寫入操作前，清除相關快取
  const cache = CacheService.getScriptCache();
  cache.remove('coaches_data');

  try {
    const coachValues = COACH_SHEET.getDataRange().getValues();
    const headers = coachValues[0];
    const coachIdColIndex = headers.indexOf('coach_id');

    const { coachId, coachName, specialty, lineId, phone } = data;

    if (!coachName) {
      throw new Error("缺少必要的教練資訊 (姓名)");
    }

    if (coachId) {
      // --- 更新模式 ---
      let targetRow = -1;
      for (let i = 1; i < coachValues.length; i++) {
        if (coachValues[i][coachIdColIndex] === coachId) {
          targetRow = i + 1;
          break;
        }
      }

      if (targetRow === -1) return { status: 'error', message: '找不到要更新的教練' };

      const updates = {
        'coach_name': coachName, 'specialty': specialty, 'line_id': lineId, 'phone_number': phone
      };

      headers.forEach((header, index) => {
        if (updates.hasOwnProperty(header)) {
          COACH_SHEET.getRange(targetRow, index + 1).setValue(updates[header]);
        }
      });

      return { status: 'success', message: '教練資料更新成功！' };

    } else {
      // --- 新增模式 ---
      const coachIds = coachValues.slice(1).map(row => row[coachIdColIndex]);
      let maxNum = 0;
      coachIds.forEach(id => {
        if (id && typeof id === 'string' && id.startsWith('C')) {
          const numPart = parseInt(id.substring(1), 10);
          if (!isNaN(numPart) && numPart > maxNum) maxNum = numPart;
        }
      });

      const newNum = maxNum + 1;
      if (newNum > 999) {
        return { status: 'error', message: '教練ID已達上限 (999)，無法新增。' };
      }
      const newCoachId = "C" + String(newNum).padStart(3, '0');
      COACH_SHEET.appendRow([newCoachId, coachName, specialty, lineId, phone]);
      return { status: 'success', message: '教練新增成功！' };
    }
  } catch (error) {
    Logger.log('saveCoach 發生錯誤: ' + error.toString());
    return { status: 'error', message: '儲存教練資料時發生錯誤: ' + error.toString() };
  } finally {
    lock.releaseLock();
  }
}

/**
 * [管理後台] 刪除一筆教練資料
 * @param {object} data - 包含 coachId 的物件
 * @returns {object} - 操作結果
 */
function deleteCoach(data) {
  const lock = LockService.getScriptLock();
  lock.waitLock(15000);

  // 在寫入操作前，清除相關快取
  const cache = CacheService.getScriptCache();
  cache.remove('coaches_data');

  try {
    const { coachId } = data;
    if (!coachId) {
      throw new Error("缺少 coachId");
    }

    // 1. 安全檢查：檢查是否有任何課堂(Classes)正在使用此教練
    const classObjects = sheetDataToObjects_(CLASS_SHEET.getDataRange().getValues());
    const isCoachInUse = classObjects.some(cls => cls.coach_id === coachId);

    if (isCoachInUse) {
      return { status: 'error', message: '無法刪除：此教練已被指派至某些課堂。請先將相關課堂的教練更換或刪除。' };
    }

    // 2. 尋找並刪除教練
    const coachValues = COACH_SHEET.getDataRange().getValues();
    const coachIdColIndex = coachValues[0].indexOf('coach_id');
    let targetRow = -1;
    for (let i = 1; i < coachValues.length; i++) {
      if (coachValues[i][coachIdColIndex] === coachId) {
        targetRow = i + 1;
        break;
      }
    }

    if (targetRow !== -1) {
      COACH_SHEET.deleteRow(targetRow);
      return { status: 'success', message: '教練刪除成功！' };
    } else {
      return { status: 'error', message: '找不到要刪除的教練。' };
    }
  } catch (error) {
    Logger.log('deleteCoach 發生錯誤: ' + error.toString());
    return { status: 'error', message: '刪除教練時發生錯誤: ' + error.toString() };
  } finally {
    lock.releaseLock();
  }
}

/**
 * [管理後台] 刪除一筆課程型錄資料
 * @param {object} data - 包含 courseId 的物件
 * @returns {object} - 操作結果
 */
function deleteCourse(data) {
  const lock = LockService.getScriptLock();
  lock.waitLock(15000);

  // 在寫入操作前，清除相關快取
  const cache = CacheService.getScriptCache();
  cache.remove('courses_data');
  cache.remove('active_courses_data');

  try {
    const { courseId } = data;
    if (!courseId) {
      throw new Error("缺少 courseId");
    }

    // 1. 安全檢查：檢查是否有任何課堂(Classes)正在使用此課程型錄
    const classObjects = sheetDataToObjects_(CLASS_SHEET.getDataRange().getValues());
    const isCourseInUse = classObjects.some(cls => cls.course_id === courseId);

    if (isCourseInUse) {
      return { status: 'error', message: '無法刪除：此課程型錄已被用於排課。請先刪除所有相關的課堂安排。' };
    }

    // 2. 尋找並刪除課程型錄
    const courseValues = COURSE_SHEET.getDataRange().getValues();
    const courseIdColIndex = courseValues[0].indexOf('course_id');
    let targetRow = -1;
    for (let i = 1; i < courseValues.length; i++) {
      if (courseValues[i][courseIdColIndex] === courseId) {
        targetRow = i + 1;
        break;
      }
    }

    if (targetRow !== -1) {
      COURSE_SHEET.deleteRow(targetRow);
      return { status: 'success', message: '課程型錄刪除成功！' };
    } else {
      return { status: 'error', message: '找不到要刪除的課程型錄。' };
    }
  } catch (error) {
    Logger.log('deleteCourse 發生錯誤: ' + error.toString());
    return { status: 'error', message: '刪除課程型錄時發生錯誤: ' + error.toString() };
  } finally {
    lock.releaseLock();
  }
}

/**
 * [管理後台] 取得所有課程型錄資料 (包含非啟用)
 * @returns {object} - 包含所有課程型錄的物件
 */
function getAllCoursesForManager() {
  try {
    // 優化：使用快取讀取課程型錄資料，快取 10 分鐘
    const courseObjects = getCachedSheetData_(COURSE_SHEET, 'courses_data', 600);
    // 管理後台需要看到所有課程，所以不過濾狀態
    return { status: 'success', courses: courseObjects.reverse() }; // 讓最新的在最上面
  } catch (error) {
    Logger.log('getAllCoursesForManager 發生錯誤: ' + error.toString());
    return { status: 'error', message: '讀取課程型錄資料時發生錯誤: ' + error.toString() };
  }
}

/**
 * [管理後台] 取得單一課程型錄的詳細資料
 * @param {object} params - 包含 courseId 的請求參數
 * @returns {object} - 包含課程詳細資訊的物件
 */
function getCourseDetailsForManager(params) {
  try {
    const { courseId } = params;
    if (!courseId) {
      throw new Error("缺少 courseId 參數");
    }

    // 優化：使用快取讀取課程型錄資料
    const courseObjects = getCachedSheetData_(COURSE_SHEET, 'courses_data', 600);
    const targetCourse = courseObjects.find(c => c.course_id === courseId);

    if (!targetCourse) {
      return { status: 'error', message: '找不到指定的課程型錄' };
    }

    return { status: 'success', details: targetCourse };
  } catch (error) {
    Logger.log('getCourseDetailsForManager 發生錯誤: ' + error.toString());
    return { status: 'error', message: '讀取課程型錄詳細資料時發生錯誤: ' + error.toString() };
  }
}

/**
 * [管理後台] 新增或更新一筆課程型錄資料
 * @param {object} data - 包含課程型錄資訊的物件
 * @returns {object} - 操作結果
 */
function saveCourse(data) {
  const lock = LockService.getScriptLock();
  lock.waitLock(15000);

  // 在寫入操作前，清除相關快取
  const cache = CacheService.getScriptCache();
  cache.remove('courses_data');
  cache.remove('active_courses_data');

  try {
    const courseValues = COURSE_SHEET.getDataRange().getValues();
    const headers = courseValues[0];
    const courseIdColIndex = headers.indexOf('course_id');

    // 從 data 中解構出所有欄位
    const { courseId, courseName, price, status, shortDesc, longDesc, image, color } = data;

    if (!courseName || !price || !status) {
      throw new Error("缺少必要的課程資訊 (名稱、價格、狀態)");
    }

    if (courseId) {
      // --- 更新模式 ---
      let targetRow = -1;
      for (let i = 1; i < courseValues.length; i++) {
        if (courseValues[i][courseIdColIndex] === courseId) {
          targetRow = i + 1;
          break;
        }
      }

      if (targetRow === -1) {
        return { status: 'error', message: '找不到要更新的課程型錄' };
      }

      // 建立一個要更新的欄位和值的對應
      const updates = {
        'course_name': courseName,
        'price': price,
        'status': status,
        'short_description': shortDesc,
        'long_description': longDesc,
        'image_url': image,
        'color': color // 新增：更新顏色欄位
      };

      // 遍歷 headers 來設定對應欄位的值
      headers.forEach((header, index) => {
        if (updates.hasOwnProperty(header)) { // 使用 hasOwnProperty 更嚴謹
          COURSE_SHEET.getRange(targetRow, index + 1).setValue(updates[header]);
        }
      });

      return { status: 'success', message: '課程型錄更新成功！' };

    } else {
      // --- 新增模式 ---
      // 找出目前最大的課程ID數字部分
      const courseIds = courseValues.slice(1).map(row => row[courseIdColIndex]);
      let maxNum = 0;
      courseIds.forEach(id => {
        if (id && typeof id === 'string' && id.startsWith('CRS')) {
          const numPart = parseInt(id.substring(3), 10);
          if (!isNaN(numPart) && numPart > maxNum) {
            maxNum = numPart;
          }
        }
      });

      // 新的ID數字為最大值+1
      const newNum = maxNum + 1;
      if (newNum > 999) {
        return { status: 'error', message: '課程ID已達上限 (999)，無法新增。' };
      }

      // 格式化為三位數流水號，例如 "CRS001"
      const newCourseId = "CRS" + String(newNum).padStart(3, '0');
      
      // 注意：appendRow 的順序必須和 Courses 工作表欄位完全一致
      COURSE_SHEET.appendRow([
        newCourseId, courseName, shortDesc, longDesc, image, price, status, color
      ]);

      return { status: 'success', message: '課程型錄新增成功！' };
    }
  } catch (error) {
    Logger.log('saveCourse 發生錯誤: ' + error.toString());
    return { status: 'error', message: '儲存課程型錄時發生錯誤: ' + error.toString() };
  } finally {
    lock.releaseLock();
  }
}

/**
 * [管理後台] 取得單一課堂的詳細資料，用於編輯表單
 * @param {object} params - 包含 classId 的請求參數
 * @returns {object} - 包含課堂詳細資訊的物件
 */
function getClassDetails(params) {
  try {
    const { classId } = params;
    if (!classId) {
      throw new Error("缺少 classId 參數");
    }

    const classObjects = sheetDataToObjects_(CLASS_SHEET.getDataRange().getValues());
    const targetClass = classObjects.find(c => c.class_id === classId);

    if (!targetClass) {
      return { status: 'error', message: '找不到指定的課堂' };
    }

    // 格式化日期和時間以符合前端需求
    const classDate = Utilities.formatDate(new Date(targetClass.class_date), "GMT+8", "yyyy-MM-dd");
    const startTime = Utilities.formatDate(new Date(targetClass.start_time), "GMT+8", "HH:00");

    const classDetails = {
      classId: targetClass.class_id,
      courseId: targetClass.course_id,
      coachId: targetClass.coach_id,
      className: targetClass.class_name,
      maxStudents: targetClass.max_students,
      dateTime: `${classDate} ${startTime}`
    };

    return { status: 'success', details: classDetails };
  } catch (error) {
    Logger.log('getClassDetails 發生錯誤: ' + error.toString());
    return { status: 'error', message: '讀取課堂詳細資料時發生錯誤: ' + error.toString() };
  }
}

/**
 * 處理審核預約的核心函式
 * @param {object} data - 包含 bookingId 和 decision ('approve' or 'reject')
 */
function reviewBooking(data) {
  const { bookingId, decision } = data;
  // 對應新的狀態流程
  // approve -> 已扣款
  // reject -> 已取消
  const newStatus = (decision === 'approve') ? '已扣款' : '已取消';

  const lock = LockService.getScriptLock();
  lock.waitLock(15000);

  try {
    const bookingValues = BOOKING_SHEET.getDataRange().getValues();
    const bookingHeaders = bookingValues[0];
    const statusColIndex = bookingHeaders.indexOf('status') + 1;
    const updateTimeColIndex = bookingHeaders.indexOf('update_time') + 1;
    const updateUserColIndex = bookingHeaders.indexOf('update_user') + 1;

    let targetBookingRow = -1;
    let currentStatus = '';
    let classId = '';
    for (let i = 1; i < bookingValues.length; i++) {
      if (bookingValues[i][bookingHeaders.indexOf('booking_id')] === bookingId) {
        currentStatus = bookingValues[i][statusColIndex - 1];
        // 防止重複操作已取消或已扣款的單據
        if (currentStatus !== '已預約') {
          return { status: 'error', message: `此預約狀態為「${currentStatus}」，無法執行此操作。` };
        }
        targetBookingRow = i + 1;
        classId = bookingValues[i][bookingHeaders.indexOf('class_id')];
        break;
      }
    }

    if (targetBookingRow === -1) {
      return { status: 'error', message: '找不到該筆預約紀錄' };
    }

    // 更新預約狀態、更新時間、更新者
    BOOKING_SHEET.getRange(targetBookingRow, statusColIndex).setValue(newStatus);
    BOOKING_SHEET.getRange(targetBookingRow, updateTimeColIndex).setValue(new Date());
    BOOKING_SHEET.getRange(targetBookingRow, updateUserColIndex).setValue('Admin'); // 假設是管理者操作

    // 如果是「取消預約」，則需要將課程名額釋放 (current_students - 1)
    if (decision === 'reject') { // 'reject' 對應到 '已取消'
      const classValues = CLASS_SHEET.getDataRange().getValues();
      const classHeaders = classValues[0];
      const currentStudentsColIndex = classHeaders.indexOf('current_students') + 1;
      let targetClassRow = -1;
      let currentStudents = 0;
      for (let i = 1; i < classValues.length; i++) {
        if (classValues[i][classHeaders.indexOf('class_id')] === classId) {
          targetClassRow = i + 1;
          currentStudents = classValues[i][classHeaders.indexOf('current_students')];
          break;
        }
      }
      if (targetClassRow !== -1 && currentStudents > 0) {
        CLASS_SHEET.getRange(targetClassRow, currentStudentsColIndex).setValue(currentStudents - 1);
      }
    }
    
    return { status: 'success', message: `操作成功：${newStatus}` };

  } catch (error) {
    return { status: 'error', message: '處理時發生錯誤: ' + error.toString() };
  } finally {
    lock.releaseLock();
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
    const classObjects = sheetDataToObjects_(CLASS_SHEET.getDataRange().getValues());
    const coachObjects = sheetDataToObjects_(COACH_SHEET.getDataRange().getValues());
    const coachMap = {};
    coachObjects.forEach(coach => { coachMap[coach.coach_id] = coach.coach_name; });
    
    classMap = {}; // 初始化
    classObjects.forEach(cls => {
      if (cls.class_id) {
        const classDate = Utilities.formatDate(new Date(cls.class_date), "GMT+8", "yyyy-MM-dd");
        const startTime = Utilities.formatDate(new Date(cls.start_time), "GMT+8", "HH:mm");
        const coachName = coachMap[cls.coach_id] || '未知教練';
        classMap[cls.class_id] = `${classDate} ${startTime} (${coachName})`;
      }
    });
    
    // --- 優化步驟 2: 將新建立的 classMap 存入快取，設定 10 分鐘 (600秒) 的有效期 ---
    // 這樣 10 分鐘內的下一次請求就能直接使用快取了
    cache.put(CACHE_KEY_CLASSMAP, JSON.stringify(classMap), 600);
  }

  // --- 後續邏輯不變，但現在 classMap 的取得速度非常快 ---
  const bookingObjects = sheetDataToObjects_(BOOKING_SHEET.getDataRange().getValues());
  const userRecords = [];
  bookingObjects.forEach(booking => {
    if (booking.line_user_id === userId) {
      userRecords.push({
        classInfo: classMap[booking.class_id] || '未知課程',
        status: booking.status
      });
    }
  });

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

/**
 * 產生所有工作表(Sheet)的結構描述。
 * 執行此函式後，請將日誌(Log)中的內容完整複製出來。
 * 這份描述可以幫助 AI 助手順利理解您目前的資料庫結構。
 */
function generateSchemaDescription() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheets = ss.getSheets();
  let schemaDescription = "# Google Sheet 結構描述\n\n";
  schemaDescription += `試算表名稱: ${ss.getName()}\n`;
  schemaDescription += `產生時間: ${new Date().toLocaleString('sv-SE')}\n\n---\n\n`;

  sheets.forEach(sheet => {
    const sheetName = sheet.getName();
    // 忽略開頭是底線的隱藏工作表
    if (sheetName.startsWith('_')) {
      return;
    }
    
    const dataRange = sheet.getDataRange();
    const values = dataRange.getValues();
    
    if (values.length === 0) {
      schemaDescription += `## 工作表: ${sheetName}\n\n`;
      schemaDescription += "此工作表沒有任何資料。\n\n---\n\n";
      return;
    }
    
    const headers = values[0];
    
    schemaDescription += `## 工作表: ${sheetName}\n\n`;
    schemaDescription += `**欄位 (共 ${headers.length} 個):**\n`;
    schemaDescription += `\`\`\`\n${headers.join(', ')}\n\`\`\`\n\n`;
    
    // 顯示前 3 筆範例資料 (如果有的話)
    if (values.length > 1) {
      schemaDescription += "**範例資料 (最多 3 筆):**\n";
      schemaDescription += "```tsv\n"; // 使用 TSV (Tab-separated values) 格式更清晰
      schemaDescription += headers.join('\t') + '\n';
      const sampleRows = values.slice(1, 4);
      sampleRows.forEach(row => {
        schemaDescription += row.map(cell => `"${String(cell).replace(/"/g, '""')}"`).join('\t') + '\n';
      });
      schemaDescription += "```\n\n";
    }
    schemaDescription += "---\n\n";
  });
  
  // 將最終結果輸出到日誌中，方便複製
  Logger.log(schemaDescription);
}

/**
 * [管理後台] 取得所有預約紀錄，並關聯相關資訊
 * @param {object} params - 包含篩選條件的請求參數 (未來可用於 status, date, query)
 * @returns {object} - 包含 bookings 陣列的物件
 */
function getAllBookings(params) {
  try {
    // 1. 讀取所有需要的資料並轉換為物件 (預約紀錄通常變動快，不建議快取)
    const bookingObjects = sheetDataToObjects_(BOOKING_SHEET.getDataRange().getValues());
    const classObjects = getCachedSheetData_(CLASS_SHEET, 'classes_data', 60); // 課表快取 1 分鐘
    const userObjects = getCachedSheetData_(USER_SHEET, 'users_data', 300); // 使用者快取 5 分鐘
    const courseObjects = getCachedSheetData_(COURSE_SHEET, 'courses_data', 600); // 課程型錄快取 10 分鐘
    const coachObjects = getCachedSheetData_(COACH_SHEET, 'coaches_data', 600); // 教練快取 10 分鐘

    // 2. 建立 Map 以提高查詢效率
    const userMap = new Map(userObjects.map(u => [u.line_user_id, u.line_display_name]));
    const classMap = new Map(classObjects.map(c => [c.class_id, { 
        course_id: c.course_id, // 新增：需要 course_id 來查找顏色
        className: c.class_name, // 使用 class_name 作為課堂名稱
        coach_id: c.coach_id,
        class_date: c.class_date, 
        start_time: c.start_time 
    }]));
    const coachMap = new Map(coachObjects.map(coach => [coach.coach_id, coach.coach_name]));
    const courseMap = new Map(courseObjects.map(course => [course.course_id, { color: course.color }])); // 新增：建立課程顏色 Map

    // 3. 組合預約資料，從最新的一筆開始處理
    const allBookings = bookingObjects.reverse().map(booking => {
      const classInfo = classMap.get(booking.class_id);
      let className = '未知課堂';
      let classTime = '未知時間';
      let coachName = '未知教練';
      let courseColor = '#ccc'; // 新增：預設顏色
      let originalClassDate = null; // 新增一個欄位來儲存原始格式的日期，以便篩選

      if (classInfo) {
        className = classInfo.className || '課堂名稱未設定';
        coachName = coachMap.get(classInfo.coach_id) || '教練未設定';

        const classDateObj = new Date(classInfo.class_date);
        originalClassDate = Utilities.formatDate(classDateObj, "GMT+8", "yyyy-MM-dd"); // 用於篩選的日期

        const displayClassDate = Utilities.formatDate(classDateObj, "GMT+8", "MM/dd"); // 用於顯示的日期
        const startTime = Utilities.formatDate(new Date(classInfo.start_time), "GMT+8", "HH:mm");
        classTime = `${displayClassDate} ${startTime}`;

        // 從 courseMap 查找顏色
        const courseInfo = courseMap.get(classInfo.course_id);
        if (courseInfo && courseInfo.color) {
          courseColor = courseInfo.color;
        }
      }

      return {
        bookingId: booking.booking_id,
        className: className, // 回傳 className
        courseColor: courseColor, // 新增：回傳顏色
        coachName: coachName, // 新增：回傳 coachName
        classTime: classTime,
        originalClassDate: originalClassDate, // 將原始日期格式一起回傳
        userName: userMap.get(booking.line_user_id) || '未知用戶',
        bookingTime: Utilities.formatDate(new Date(booking.booking_time), "GMT+8", "MM/dd HH:mm"),
        status: booking.status
      };
    });

    // 4. 根據 params 進行篩選或搜尋
    let filteredBookings = allBookings;

    // 狀態篩選
    if (params.status) {
      filteredBookings = filteredBookings.filter(b => b.status === params.status);
    }

    // 日期篩選
    if (params.classDate) {
      // 使用新的 originalClassDate 欄位進行精準比對
      filteredBookings = filteredBookings.filter(b => b.originalClassDate === params.classDate);
    }

    // 關鍵字搜尋
    if (params.query) {
      const queryLower = params.query.toLowerCase();
      filteredBookings = filteredBookings.filter(b => 
        b.userName.toLowerCase().includes(queryLower) || 
        b.bookingId.toLowerCase().includes(queryLower)
      );
    }

    return { status: 'success', bookings: filteredBookings };

  } catch (error) {
    Logger.log('getAllBookings 發生錯誤: ' + error.toString());
    return { status: 'error', message: '讀取預約資料時發生錯誤: ' + error.toString() };
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
