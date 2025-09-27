### 優化預約憑證頁面 (`booking-details.html`)



### 優化「回到上一頁」的按鈕顯示 (`schedules.html`, `coaches.html`)

* 將按鈕樣式調整成與 `booking-details.html` 頁面風格一致



---

* 將 Google Apps Script 中的 SERVICE_KEY 移至更安全的「指令碼屬性」中。
* 請幫我為這些資料表撰寫 Supabase 的 RLS (Row Level Security) 規則，以確保資料安全。

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