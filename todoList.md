### 已完成的里程碑 (Completed Milestones)

-   [x] **大挑戰：課程時間改為 15 分鐘單位**：完成後端資料庫、管理後台（畫布課表、拖曳互動）、學員介面（互動式展開）的全面改造。
-   [x] **為 `manager.html` 實作 Google 登入驗證**：整合 Supabase Auth，並透過 RLS 政策確保只有授權管理者能存取後台資料。
-   [x] **優化預約憑證頁面 (Phase I)**: 採用票券式設計，並透過安全的 RPC 函式 `get_booking_details_for_user` 實現了「僅限本人查看」的權限控管。
-   [x] **架構遷移與簡化**
    -   [x] **Webhook 核心邏輯遷移**: 將 Webhook 核心邏輯從 GAS 遷移至 Supabase Edge Function (`line-webhook`)。
    -   [x] **圖文選單管理流程簡化**: 不再使用 `manage-rich-menu` Edge Function。圖文選單的建立與設定已移至 LINE Official Account Manager 後台，透過視覺化介面直接管理，大幅簡化流程。
-   [x] **專案清理 (Final Cleanup)**
    -   [x] 從專案中移除了舊的 `Code.gs` 和 `appsscript.json` 檔案。
    -   [x] 從專案中移除了 GAS 設定檔 `.clasp.json`。
    -   [x] 更新 `config.js`，移除了不再使用的 `GAS_URL` 變數。

---

### 進行中與未來規劃 (In Progress & Future Plans)

### 重構 Manager 後台 (Refactoring `manager.html`)

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

### 為 `manager.html` 實作 Google 登入驗證

目標：只有指定的 Google 帳號可以登入後台，並存取所有管理資料。

#### Part 1: Supabase 後端設定

1.  **[x] 啟用 Google 驗證提供者**
    *   [ ] 前往 Supabase 儀表板 > Authentication > Providers。
    *   [x] 啟用 `Google` 提供者。
    *   [x] 依照官方文件指示，前往 Google Cloud Console 建立 OAuth 2.0 Client ID。
    *   [x] 將 Google Cloud Console 提供的 `Client ID` 和 `Client Secret` 填回 Supabase。
    *   [x] **重要**：將 Supabase 提供的 `Redirect URI` 複製並貼到 Google Cloud Console 的「已授權的重新導向 URI」欄位中。

#### Part 2: 強化 RLS (Row Level Security) 安全策略

1.  **[x] 刪除臨時的公開讀取策略**
    *   [x] **(已完成)** 透過 `20251003100000_refine_rls_policies.sql` 移除了所有資料表上過於寬鬆的公開讀取策略。

2.  **[x] 建立僅限管理者存取的策略**
    *   [x] 執行 SQL，建立新的 RLS 策略，只允許 email 為特定管理者信箱的已登入使用者存取資料。
        ```sql
        -- 假設管理者的 email 是 'your.admin.email@gmail.com'
        CREATE POLICY "Allow managers to read all users" ON public.users FOR SELECT USING (auth.email() = 'your.admin.email@gmail.com');
        CREATE POLICY "Allow managers to read all coaches" ON public.coaches FOR SELECT USING (auth.email() = 'your.admin.email@gmail.com');
        ```
3.  **[x] RLS 策略重構**
    *   [x] **(已完成)** 透過 `20251004120001_consolidate_admin_rls.sql` 進行了全面的策略清理與重構。
    *   [x] **結果**: 刪除了所有舊的、分散的管理者策略，並為所有核心資料表 (`bookings`, `classes`, `courses`, `coaches`, `users`) 建立了一組乾淨、統一的 `FOR ALL` (CRUD) 策略。
    *   [x] **標準化**: 所有新的管理者策略都明確授權給 `authenticated` 角色，確保只有透過 Google 登入的管理者才能觸發。

#### Part 3: 前端 `manager.html` 頁面修改

1.  **[x] 建立登入畫面**
    *   [x] 在 `<body>` 中建立一個登入畫面的 `<div>` (例如 `#login-view`)，內含一個「使用 Google 登入」的按鈕。
    *   [x] 將原本的主要內容區 (`<nav class="sidebar">` 和 `<main class="main-content">`) 用另一個 `<div>` (例如 `#main-view`) 包起來。
    *   [x] 預設情況下，`#login-view` 顯示，`#main-view` 隱藏。

2.  **[x] 修改 JavaScript 邏輯**
    *   [x] 加入 `supabase.auth.onAuthStateChange` 監聽器。
    *   [x] **監聽器邏輯**：
        *   如果 `event` 是 `SIGNED_IN` 且 `session.user.email` 是管理者信箱：
            *   隱藏 `#login-view`，顯示 `#main-view`。
            *   執行 `handleNavigation()` 來載入預設頁面資料。
        *   如果 `event` 是 `SIGNED_OUT` 或使用者不是管理者：
            *   顯示 `#login-view`，隱藏 `#main-view`。
    *   [x] **登入按鈕**：為「使用 Google 登入」按鈕綁定點擊事件，呼叫 `supabaseClient.auth.signInWithOAuth({ provider: 'google' })`。
    *   [x] **登出功能**：在側邊欄或頁首新增一個「登出」按鈕，綁定點擊事件呼叫 `supabaseClient.auth.signOut()`。

---

### 未來規劃 (Future Plans) & 文件

-   [ ] **部署與文件 (Deployment & Documentation)**
    -   [x] **前端部署**: 將前端靜態檔案 (`.html`, `.css`, `.js`) 部署至 GitHub Pages。
    -   [ ] **撰寫部署與設定文件**: 在 `README.md` 中補充完整的部署與設定流程，包含：
        -   [ ] 前端 `config.js` 的設定方式。
        -   [ ] Supabase Edge Functions (`line-webhook`) 所需的環境變數 (Secrets)。
        -   [ ] 在 LINE Official Account Manager 中設定圖文選單的步驟。
