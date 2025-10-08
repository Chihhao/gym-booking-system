## 新功能：課堂記錄 (New Feature: Class Records)

目標：實作完整的課堂記錄功能，讓教練可以記錄學員的訓練內容，學員可以查詢自己的進步歷程。

-   [ ] **Part 1: 後端資料庫建置 (Backend Database Setup)**
    -   [ ] 建立 `class_sessions` 資料表，用於儲存課堂日誌總表 (出席狀態、整體評分、總結等)。
    -   [ ] 建立 `exercise_logs` 資料表，用於儲存單一課堂中的多筆訓練動作日誌 (動作名稱、重量、次數等)。
    -   [ ] 建立相關的 RLS (Row Level Security) 政策，確保學員只能讀取自己的記錄。
    -   [ ] **設計決策**: `class_sessions` 表使用獨立的 `session_id` 作為主鍵，而非直接使用 `booking_id`。
        -   **理由 1 (職責分離)**: `booking_id` 代表「預約行為」，`session_id` 代表「課堂事件」，兩者概念不同。
        -   **理由 2 (擴充性)**: 保留未來處理「無預約的現場學員」記錄的可能性。
        -   **理由 3 (一致性)**: 與專案中其他資料表 (courses, coaches, classes) 的主鍵設計慣例保持一致。
    -   [ ] 建立後端 RPC 函式 (`upsert_session_and_logs`, `get_my_records`) 以處理資料的寫入與讀取。

-   [ ] **Part 2: 教練端介面 (Coach Interface - LIFF)**
    -   [ ] 建立新的 LIFF 頁面 `coach-record.html`，專為教練手機操作設計。
    -   [ ] 實作介面，讓教練能選擇課堂、查看學員列表。
    -   [ ] 為每位學員實作可動態新增/刪除的「訓練動作日誌」表單 (動作、KG、次數)。
    -   [ ] 整合星星評分元件與備註輸入框。
    -   [ ] 串接後端 `upsert_session_and_logs` RPC 函式以儲存記錄。

-   [ ] **Part 3: 學員端介面 (Student Interface - LIFF)**
    -   [ ] 建立新的 LIFF 頁面 `my-records.html`，用於顯示個人歷史記錄。
    -   [ ] 實作介面，以卡片列表形式呈現每堂課的記錄，並可展開查看詳細訓練動作。
    -   [ ] 串接後端 `get_my_records` RPC 函式以讀取資料。

-   [ ] **Part 4: LINE Bot 整合 (LINE Bot Integration)**
    -   [ ] 在 `line-webhook` 中新增對 `[個人記錄]` 文字訊息的處理。
    -   [ ] 當收到 `[個人記錄]` 時，回覆一個按鈕，引導使用者開啟 `my-records.html` LIFF 頁面。

-   [ ] **Part 5: 管理者後台整合 (Manager/Admin Integration)**
    -   [ ] 在 `manager.html` 新增一個「課堂記錄」的導覽頁籤與區塊。
    -   [ ] 實作一個可篩選、可搜尋的介面，用來列出**所有**的 `class_sessions` 記錄。
    -   [ ] 建立一個 Modal 或詳情頁面，讓管理者可以查看並**修改**指定的課堂記錄（包含訓練動作日誌）。
    -   [ ] 確保後端 RLS 政策允許管理者 (`ADMIN_EMAILS`) 擁有對 `class_sessions` 和 `exercise_logs` 的完整讀寫權限。

## 新功能：教練身份綁定 (New Feature: Coach Account Linking)

目標：建立一個簡單流暢的「Bot 輔助綁定」流程，讓系統能將教練的資料與他們的 LINE 帳號 (`line_user_id`) 關聯起來。

-   [ ] **Part 1: 後端建置 (Backend Setup)**
    -   [ ] 在 `coaches` 資料表新增 `line_user_id` (text) 欄位，並建立唯一索引。
    -   [ ] 建立 RPC 函式 `send_coach_linking_request(p_coach_id)`，其職責為：
        -   [ ] 根據 `coach_id` 查到教練的 `line_id` (可搜尋的 ID)。
        -   [ ] 呼叫 LINE Push API，主動推送一個「確認綁定」的卡片訊息給該教練。
-   [ ] **Part 2: LINE Webhook 整合 (Webhook Integration)**
    -   [ ] 在 `line-webhook` 中，新增處理「確認綁定」的 `postback` 事件邏輯，其職責為：
        -   [ ] 從 `postback` 事件中取得教練的 `line_user_id` 和 `coach_id`。
        -   [ ] 將 `line_user_id` 更新到 `coaches` 資料表中對應的紀錄。
        -   [ ] 回覆教練「綁定成功」的訊息。
-   [ ] **Part 3: 管理者後台介面 (Manager Interface)**
    -   [ ] 在 `manager.html` 的「教練管理」表格中，新增一欄顯示綁定狀態 (已綁定/未綁定)。
    -   [ ] 為未綁定的教練新增「傳送綁定邀請」按鈕，並串接 `send_coach_linking_request` RPC 函式。

---

## 重構 Manager 後台 (Refactoring `manager.html`)

目標：將 `manager.html` 中龐大的 JavaScript 程式碼進行模組化拆分與重構，以提高可維護性、可讀性與擴展性。

-   [ ] **Part 1: 程式碼結構與職責分離 (Code Structure & Separation of Concerns)**
    -   [ ] **建立專屬的 JavaScript 檔案**：將不同功能的程式碼拆分到獨立的檔案中。
        -   [ ] `auth.js`: 身份驗證邏輯
        -   [ ] `navigation.js`: 頁面導覽與側邊欄邏輯
        -   [ ] `data-loaders/bookings.js`: 預約管理功能
        -   [ ] `data-loaders/courses.js`: 課程型錄功能
        -   [ ] `data-loaders/coaches.js`: 教練管理功能
        -   [ ] `data-loaders/users.js`: 客戶管理功能
        -   [ ] `manager-schedule-canvas.js`: 畫布課表互動邏輯
    -   [ ] **使用 JavaScript 模組 (ESM)**：在 `manager.html` 中改用 `type="module"` 載入主腳本，並在各模組間使用 `import`/`export`。

-   [ ] **Part 2: 資料載入與狀態管理 (Data Loading & State Management)**
    -   [ ] **建立通用資料載入器**: 建立一個高階函式 `loadTableData` 來處理重複的資料載入、渲染和錯誤處理邏輯。
    -   [ ] **集中化狀態管理**: 將所有頁面的狀態（如 `currentBookings`, `sortState`）封裝在一個全域狀態物件 `managerState` 中，避免全域變數污染。

-   [ ] **Part 3: 畫布課表邏輯優化 (`manager-schedule-canvas.js`)**
    -   [ ] **抽象化時間與像素轉換**: 將 `offsetY / canvasPixelsPerMinute` 等計算封裝成獨立的輔助函式（如 `minutesToPixels`, `timeToPixels`）。
    -   [ ] **分離互動與資料更新**: 將 `interact.js` 的 `end` 事件監聽器職責簡化，只負責計算變更後的資料，並呼叫獨立的 `updateClass` 函式來執行 API 儲存。

---

## 在 readme.md 新增功能截圖
