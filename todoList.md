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
    -   [ ] **優化拖曳體驗**：重新實作拖曳過程中的即時吸附功能 (snap-while-dragging)，提供更精準的視覺回饋。
-   [ ] **Part 2.5: 整合與樣式統一 (Integration & Styling)**
    -   [ ] **樣式統一**: 調整 `manager-schedule.html` 的樣式（如按鈕、標題、顏色），使其與 `manager.html` 的整體風格保持一致。
    -   [ ] **整合畫布課表**: 將 `manager-schedule.html` 的功能完全整合進 `manager.html`，並移除舊的表格課表，讓新版課表成為預設。

#### Part 3: 學員介面調整 (User UI - `schedule.html`)

-   [ ] **改造學員課表 (`schedule.html`) - 互動式展開方案**:
    -   [ ] **Part 3.1: 後端資料準備 (`fetchSchedule`)**:
        -   [ ] 修改 `fetchSchedule` 函式，使其能處理並回傳包含精確 `start_time` 和 `end_time` 的課堂資料。
        -   [ ] 在資料處理階段，需要判斷每個「小時」的格子內是否包含多於一堂課，或是否有非整點開始的課。新增一個標記（例如 `has_multiple: true`）到對應的小時格子資料中。
    -   [ ] **Part 3.2: 前端初始渲染 (`renderScheduleGrid`)**:
        -   [ ] 維持現有的「每日每小時」格子檢視作為初始畫面。
        -   [ ] 當渲染格子時，檢查後端傳來的資料標記。如果某個小時的格子 `has_multiple` 為 `true`，則在原有的圖示（如圈圈）下方，額外渲染一個向下箭頭「v」圖示，並為該儲存格 (`<td>`) 加上一個特定的 class (例如 `expandable`)。
    -   [ ] **Part 3.3: 前端互動邏輯 (JavaScript)**:
        -   [ ] 綁定點擊事件到所有 class 為 `expandable` 的儲存格 (`<td>`)。
        -   [ ] 點擊時，觸發一個 `expandHour` 函式，在被點擊的橫列 (`<tr>`) 下方動態插入四個新的子橫列 (`<tr>`)。
        -   [ ] 這四個新橫列分別代表該小時的 `:00`, `:15`, `:30`, `:45` 時段，並使用稍微不同的背景色以作區分。
        -   [ ] 根據完整的課堂資料，將原本藏在該小時內的所有課堂，精確地渲染到對應的 15 分鐘小格子中。
        -   [ ] 再次點擊同一個格子或箭頭時，應能收合這四個子橫列。

### 優化預約憑證頁面 (`booking-details.html`)

-   [x] 調整 UI/UX，採用票券式卡片設計。
-   [x] 解決 QR Code 過大導致版面跑版的問題。
-   [x-failed] **安全性強化實驗 (RLS)**：
    -   **目標**：實作「只能由預約者本人查看」的安全規則。
    -   **過程**：嘗試透過前端傳遞使用者 ID (LINE User ID) 給後端 RLS 政策進行驗證。歷經了偽造 JWT、傳遞自訂 HTTP Header 等多種方式。
    -   **結果**：**失敗**。由於前端 (`anon` key 環境) 無法產生一個可被後端 RLS 安全信任的身份證明，導致實作過程極為複雜且最終無法穩定運作。為求系統穩定，已將相關程式碼與資料庫規則恢復至公開讀取狀態。
-   [ ] **待辦事項：重新實作憑證頁面安全性**
    -   **方向**：未來應採用更標準、更安全的後端驗證流程。建議方案是建立一個 Supabase Edge Function：
        1.  前端 (`booking-details.html`) 透過 LIFF 取得 `ID Token`。
        2.  前端呼叫 Edge Function，並將 `ID Token` 作為驗證憑證。
        3.  Edge Function 在後端驗證 `ID Token` 的有效性，確認使用者身份。
        4.  驗證成功後，Edge Function 使用 `service_role_key` 安全地查詢資料庫，並將結果回傳給前端。
    -   **優點**：此方案能徹底解決前端身份不可信的問題，是實現此類安全需求的最佳實踐。




---

### 到 Supabase 查看系統建議

---

### 為 `manager.html` 實作 Google 登入驗證

目標：只有指定的 Google 帳號可以登入後台，並存取所有管理資料。

#### Part 1: Supabase 後端設定

1.  **啟用 Google 驗證提供者**
    *   [ ] 前往 Supabase 儀表板 > Authentication > Providers。
    *   [ ] 啟用 `Google` 提供者。
    *   [ ] 依照官方文件指示，前往 Google Cloud Console 建立 OAuth 2.0 Client ID。
    *   [ ] 將 Google Cloud Console 提供的 `Client ID` 和 `Client Secret` 填回 Supabase。
    *   [ ] **重要**：將 Supabase 提供的 `Redirect URI` 複製並貼到 Google Cloud Console 的「已授權的重新導向 URI」欄位中。

#### Part 2: 強化 RLS (Row Level Security) 安全策略

1.  **刪除臨時的公開讀取策略**
    *   [ ] 執行 SQL，刪除之前為了讓 `manager.html` 運作而建立的公開讀取策略。
        ```sql
        DROP POLICY "Allow public read-only access to users" ON public.users;
        DROP POLICY "Allow public read-only access to coaches" ON public.coaches;
        ```
2.  **建立僅限管理者存取的策略**
    *   [ ] 執行 SQL，建立新的 RLS 策略，只允許 email 為特定管理者信箱的已登入使用者讀取資料。
        ```sql
        -- 假設管理者的 email 是 'your.admin.email@gmail.com'
        CREATE POLICY "Allow managers to read all users" ON public.users FOR SELECT USING (auth.email() = 'your.admin.email@gmail.com');
        CREATE POLICY "Allow managers to read all coaches" ON public.coaches FOR SELECT USING (auth.email() = 'your.admin.email@gmail.com');
        ```

#### Part 3: 前端 `manager.html` 頁面修改

1.  **建立登入畫面**
    *   [ ] 在 `<body>` 中建立一個登入畫面的 `<div>` (例如 `#login-view`)，內含一個「使用 Google 登入」的按鈕。
    *   [ ] 將原本的主要內容區 (`<nav class="sidebar">` 和 `<main class="main-content">`) 用另一個 `<div>` (例如 `#main-view`) 包起來。
    *   [ ] 預設情況下，`#login-view` 顯示，`#main-view` 隱藏。

2.  **修改 JavaScript 邏輯**
    *   [ ] 在 `DOMContentLoaded` 事件中，加入 `supabase.auth.onAuthStateChange` 監聽器。
    *   [ ] **監聽器邏輯**：
        *   如果 `event` 是 `SIGNED_IN` 且 `session.user.email` 是管理者信箱：
            *   隱藏 `#login-view`，顯示 `#main-view`。
            *   執行 `handleNavigation()` 來載入預設頁面資料。
        *   如果 `event` 是 `SIGNED_OUT` 或使用者不是管理者：
            *   顯示 `#login-view`，隱藏 `#main-view`。
    *   [ ] **登入按鈕**：為「使用 Google 登入」按鈕綁定點擊事件，呼叫 `supabaseClient.auth.signInWithOAuth({ provider: 'google' })`。
    *   [ ] **登出功能**：在側邊欄或頁首新增一個「登出」按鈕，綁定點擊事件呼叫 `supabaseClient.auth.signOut()`。