### 大挑戰：課程時間改為 15 分鐘單位

目標：將課程時間從固定的一小時時段，改為以 15 分鐘為單位的彈性起訖時間。

#### Part 1: 後端先行 (Backend First)

-   [x] **資料庫 `classes` 資料表**：
    -   [x] 正式啟用 `end_time` 欄位，確保所有課堂都有精確的開始與結束時間。
-   [x] **修改 `save_class` RPC 函式**：
    -   [x] 修改函式參數，從 `p_date_time` 改為接收獨立的 `p_class_date`, `p_start_time`, `p_end_time`。
    -   [x] **核心**：在函式中加入「時間重疊檢查」邏輯。當為同一位教練新增或修改課堂時，使用 PostgreSQL 的 `OVERLAPS` 運算子檢查新時段是否與該教練已有的其他課堂重疊。如果重疊，則回傳錯誤。

#### Part 2: 管理後台跟進 (Admin UI - `manager.html`)

-   [x] **改造課堂編輯 Modal**:
    -   [x] 將 Modal 表單改為獨立的「日期」、「開始時間」、「結束時間」輸入框。
    -   [x] 修改 `openClassModal` 函式，使其能正確載入與填充彈性的起訖時間。
    -   [x] 修改表單提交邏輯，呼叫新版 `save_class` RPC 函式。
    -   [x] 修正 `classes_with_details` 視圖，確保編輯時能正確帶入課程與教練 ID。
-   [x] **重新設計課表介面 (視覺化時間軸)**：
    -   [x] **Part 2.1: HTML/CSS 結構重塑 (畫布系統)**
        -   [x] 移除 `manager.html` 中舊的 `schedule-grid` `<table>` 樣式。(已在新版 `manager-schedule.html` 中完成)
        -   [x] 建立新的 `div` 畫布結構樣式：
            -   [x] `.schedule-canvas-grid`: Flex 容器，包含時間軸和所有日期欄。
            -   [x] `.time-axis`: 左側時間軸欄。
            -   [x] `.day-column`: 每日的「畫布」容器，設定 `position: relative`。
            -   [x] `.class-item`: 課堂區塊，設定 `position: absolute`。
            -   [x] (可選) 在 `.day-column` 內加入代表小時的水平線 `div` 作為視覺輔助。
    -   [x] **Part 2.2: JavaScript 渲染邏輯重構**
        -   [x] 修改 `loadManagerSchedule`，直接獲取一週內所有課堂的完整列表，不再按小時分組。
        -   [x] 重構 `renderManagerScheduleGrid` 函式：
            -   [x] 動態生成時間軸和空的「每日畫布」(`div.day-column`)。
            -   [x] 遍歷課堂資料，為每堂課計算其 `top` (開始時間) 和 `height` (持續時間) 的像素值。
            -   [x] 動態建立課堂 `div` (`.class-item`)，將計算出的 `style` 賦予它，並將其附加到對應日期的畫布中。
    -   [x] **Part 2.3: 處理重疊課堂 (進階)**
        -   [x] 在渲染邏輯中加入演算法，偵測同一天內的重疊課堂。
        -   [x] 當偵測到重疊時，動態調整這些課堂的 `width` 和 `left` 樣式，使其並排顯示。
-   [x] **實作新的互動方式 (UX)**：
    -   [x] **新增課堂**：允許管理員透過在時間軸上「點擊」來快速設定新課堂的起訖時間。
    -   [x] **修改課堂**：允許管理員拖曳課堂區塊的頂部/底部來調整時間，或拖曳整個區塊來移動時間點。
    -   [x] **優化拖曳體驗**：重新實作拖曳過程中的即時吸附功能 (snap-while-dragging)，提供更精準的視覺回饋。
-   [x] **Part 2.5: 整合與樣式統一 (Integration & Styling)**
    -   [x] **樣式統一**: 調整 `manager-schedule.html` 的樣式（如按鈕、標題、顏色），使其與 `manager.html` 的整體風格保持一致。
    -   [x] **整合畫布課表**: 將 `manager-schedule.html` 的功能完全整合進 `manager.html`，並移除舊的表格課表，讓新版課表成為預設。

#### Part 3: 學員介面調整 (User UI - `schedule.html`)

-   [x] **改造學員課表 (`schedule.html`) - 互動式展開方案**:
    -   **核心原則**：為了確保使用者介面的一致性和可預測性，任何有課的時段都應該是可展開的，使用者必須先點擊箭頭，然後才能在展開的 15 分鐘子時段中進行預約。
    -   [x] **Part 3.1: 後端資料準備 (`fetchSchedule`)**:
        -   [x] 修改 `fetchSchedule` 函式，使其能處理並回傳包含精確 `start_time` 和 `end_time` 的課堂資料。
        -   [x] **(已完成)** 在資料處理階段，只要某個「小時」的格子內有任何課堂，就新增一個標記 (`has_multiple: true`) 到對應的格子資料中。
    -   [x] **Part 3.2: 前端初始渲染 (`renderScheduleGrid`)**:
        -   [x] 維持現有的「每日每小時」格子檢視作為初始畫面。
        -   [x] **(已完成)** 當渲染格子時，若 `has_multiple` 為 `true`，則**只顯示**一個向下箭頭 `▼` 圖示，並為該儲存格 (`<td>`) 加上 `expandable` class，點擊後觸發 `expandHour` 函式。
    -   [x] **Part 3.3: 前端互動邏輯 (`expandHour` 函式)**:
        -   [x] **展開操作 (第一次點擊)**:
            -   [x] 使用者點擊帶有箭頭的整點格子 (`<td>`)。
            -   [x] 在該格子的橫列 (`<tr>`) 下方，動態**插入四個新的橫列**。
            -   [x] **新橫列樣式**:
                -   [x] **背景色**: 統一使用**暗黃色底色**以示區別。
                -   [x] **時間標籤**: 左側時間欄位分別顯示 `:00`, `:15`, `:30`, `:45`。
            -   [x] **新橫列內容**:
                -   [x] 根據 `scheduleData` 中儲存的完整課堂資料，將課堂圖示（如黃色圈圈 `○`）精確地渲染到對應的 15 分鐘格子中。
                -   [x] 只有這些 15 分鐘格子內的圖示才能觸發預約 (`selectTimeslot`)。
            -   [x] **視覺效果**: 畫面中會暫時出現兩行相同的小時（如 10:00），這是正常設計。
        -   [x] **收合操作 (第二次點擊)**:
            -   [x] 使用者再次點擊同一個帶有箭頭的整點格子。
            -   [x] 將先前動態插入的四個暗黃色橫列**全部移除**。
            -   [x] 畫面恢復到初始狀態。
        -   [x] **狀態管理**:
            -   [x] 需要一個機制來追蹤哪些時段是已展開的，以便實現「收合」功能。
            -   [x] (已完成) 最終決定不變換箭頭圖示，以簡化邏輯。

### 優化預約憑證頁面 (`booking-details.html`)

-   [x] 調整 UI/UX，採用票券式卡片設計。
-   [x] 解決 QR Code 過大導致版面跑版的問題。
-   [x] **安全性強化實驗 (RLS)**：
    -   **目標**：實作「只能由預約者本人查看」的安全規則。
    -   **過程**：嘗試透過前端傳遞使用者 ID (LINE User ID) 給後端 RLS 政策進行驗證。歷經了偽造 JWT、傳遞自訂 HTTP Header 等多種方式。
    -   **結果**：**已透過 RPC 函式實現**。由於前端 (`anon` key 環境) 無法產生一個可被後端 RLS 安全信任的身份證明，最終採用了更安全的 RPC 函式方案。
-   [x] **重新實作憑證頁面安全性**
    -   [x] **Phase I: UserID Auth 檢核**
        -   **目標**: 讓使用者只能讀取自己的資料。
        -   **實作**: 在 `booking-details.html` 和 `booking-complete.html` 中，透過 LIFF 取得 `userId`，並呼叫安全的 RPC 函式 `get_booking_details_for_user`，由後端進行權限校驗，成功防止使用者透過修改 URL 參數查看他人資料。
    -   [ ] **Phase II: Edge Function + ID Token 檢核 (未來規劃)**
        -   **目標**: 建立一個名為 `get-booking-details` 的 Edge Function，由它代替前端來執行資料庫查詢，達到最高安全性。
        -   [ ] **前端修改 (`booking-details.html`)**:
            -   [ ] 將資料查詢從 `supabaseClient.from(...).select(...)` 改為呼叫 `supabaseClient.functions.invoke('get-booking-details', ...)`。
            -   [ ] 在呼叫時，將 `bookingId` 和從 LIFF 取得的 `ID Token` 一起作為參數傳遞。
        -   [ ] **後端開發 (Edge Function)**:
            -   [ ] 建立一個新的 Edge Function (`/supabase/functions/get-booking-details/index.ts`)。
            -   [ ] **函式邏輯**: 驗證傳入的 `ID Token`，確認使用者身份後，使用 `service_role_key` 安全地查詢資料庫，並回傳結果。




---

### 到 Supabase 查看系統建議

---

### 為 `manager.html` 實作 Google 登入驗證

目標：只有指定的 Google 帳號可以登入後台，並存取所有管理資料。

#### Part 1: Supabase 後端設定

1.  **啟用 Google 驗證提供者**
    *   [ ] 前往 Supabase 儀表板 > Authentication > Providers。
    *   [x] 啟用 `Google` 提供者。
    *   [x] 依照官方文件指示，前往 Google Cloud Console 建立 OAuth 2.0 Client ID。
    *   [x] 將 Google Cloud Console 提供的 `Client ID` 和 `Client Secret` 填回 Supabase。
    *   [x] **重要**：將 Supabase 提供的 `Redirect URI` 複製並貼到 Google Cloud Console 的「已授權的重新導向 URI」欄位中。

#### Part 2: 強化 RLS (Row Level Security) 安全策略

1.  **刪除臨時的公開讀取策略**
    *   [ ] **(待辦)** 執行 SQL，刪除之前為了讓 `manager.html` 運作而建立的公開讀取策略。
        ```sql
        DROP POLICY "Allow public read-only access to users" ON public.users;
        DROP POLICY "Allow public read-only access to coaches" ON public.coaches;
        ```
2.  **建立僅限管理者存取的策略**
    *   [x] 執行 SQL，建立新的 RLS 策略，只允許 email 為特定管理者信箱的已登入使用者讀取資料。
        ```sql
        -- 假設管理者的 email 是 'your.admin.email@gmail.com'
        CREATE POLICY "Allow managers to read all users" ON public.users FOR SELECT USING (auth.email() = 'your.admin.email@gmail.com');
        CREATE POLICY "Allow managers to read all coaches" ON public.coaches FOR SELECT USING (auth.email() = 'your.admin.email@gmail.com');
        ```

#### Part 3: 前端 `manager.html` 頁面修改

1.  **建立登入畫面**
    *   [x] 在 `<body>` 中建立一個登入畫面的 `<div>` (例如 `#login-view`)，內含一個「使用 Google 登入」的按鈕。
    *   [x] 將原本的主要內容區 (`<nav class="sidebar">` 和 `<main class="main-content">`) 用另一個 `<div>` (例如 `#main-view`) 包起來。
    *   [x] 預設情況下，`#login-view` 顯示，`#main-view` 隱藏。

2.  **修改 JavaScript 邏輯**
    *   [x] 在 `DOMContentLoaded` 事件中，加入 `supabase.auth.onAuthStateChange` 監聽器。
    *   [x] **監聽器邏輯**：
        *   如果 `event` 是 `SIGNED_IN` 且 `session.user.email` 是管理者信箱：
            *   隱藏 `#login-view`，顯示 `#main-view`。
            *   執行 `handleNavigation()` 來載入預設頁面資料。
        *   如果 `event` 是 `SIGNED_OUT` 或使用者不是管理者：
            *   顯示 `#login-view`，隱藏 `#main-view`。
    *   [x] **登入按鈕**：為「使用 Google 登入」按鈕綁定點擊事件，呼叫 `supabaseClient.auth.signInWithOAuth({ provider: 'google' })`。
    *   [x] **登出功能**：在側邊欄或頁首新增一個「登出」按鈕，綁定點擊事件呼叫 `supabaseClient.auth.signOut()`。