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