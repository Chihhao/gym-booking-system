### 已完成的里程碑 (Completed Milestones)

-   [x] **大挑戰：課程時間改為 15 分鐘單位**：完成後端資料庫、管理後台（畫布課表、拖曳互動）、學員介面（互動式展開）的全面改造。
-   [x] **為 `manager.html` 實作 Google 登入驗證**：整合 Supabase Auth，並透過 RLS 政策確保只有授權管理者能存取後台資料。
-   [x] **優化預約憑證頁面 (Phase I)**: 採用票券式設計，並透過安全的 RPC 函式 `get_booking_details_for_user` 實現了「僅限本人查看」的權限控管。
-   [x] **架構遷移：從 Google Apps Script 到 Supabase**：將 Webhook 核心邏輯與圖文選單管理腳本從 GAS 遷移至 Supabase Edge Functions，統一了後端技術棧。

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

### 未來規劃 (Future Plans)

-   [ ] **部署與文件**：將前端靜態檔案部署至 GitHub Pages，並在 `README.md` 中補充完整的部署流程與環境變數設定說明。
