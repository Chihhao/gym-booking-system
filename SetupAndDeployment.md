# WALLY-STUDIO

## 專案設定與部署 (Setup and Deployment)

### 1. 事前準備 (Prerequisites)

#### 軟體安裝

*   **版本控制**: [Git](https://git-scm.com/downloads/) 或 [GitHub Desktop](https://desktop.github.com/)
*   **程式碼編輯器**: [VS Code](https://code.visualstudio.com/)
*   **容器化環境**: [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Supabase CLI 本地端開發所需)
*   **Supabase CLI**: [安裝說明](https://supabase.com/docs/guides/cli)

#### 帳號申請

*   **Supabase**: [註冊 Supabase](https://supabase.com/) 並建立一個新專案。
*   **GitHub**: [註冊 GitHub](https://github.com/) 用於託管前端程式碼。
*   **LINE Developers**: [註冊 LINE Developers](https://developers.line.biz/)
    *   建立一個 `Provider`。
    *   在 Provider 下建立一個 **Messaging API** channel (用於 LINE Bot)。
    *   在 Provider 下建立一個 **LINE Login** channel，並在此 channel 中啟用 LIFF (用於前端應用)。
*   **Google Cloud**:
    *   您需要一個**一般 Google (Gmail) 帳號**作為管理者登入後台使用。
    *   前往 [Google Cloud Console](https://console.cloud.google.com/)，為專案建立一組 **OAuth 2.0 用戶端 ID**。
    *   取得 `用戶端 ID (Client ID)` 和 `用戶端密鑰 (Client Secret)`。
    *   前往您的 **Supabase 儀表板** > `Authentication` > `Providers` > `Google`。
    *   將取得的 `Client ID` 和 `Client Secret` 填入對應欄位並儲存。**此步驟為管理者能登入後台的關鍵**。

### 2. 取得專案

1.  複製 (Clone) 此專案至您的本地電腦：
    ```bash
    git clone https://github.com/Chihhao/WALLY-STUDIO.git
    ```
2.  進入專案目錄：
    ```bash
    cd WALLY-STUDIO
    ```

### 3. 後端設定 (Supabase)

#### 3.1 連結 Supabase 專案

1.  登入 Supabase CLI：
    ```bash
    supabase login
    ```
2.  在本地端初始化專案後，連結到您在 Supabase 建立的遠端專案 (請替換 `<project-id>`):
    ```bash
    supabase link --project-ref <project-id>
    ```
    > 您可以在 Supabase 專案儀表板的 `Settings` > `General` 中找到 `Project ID` (它是一串隨機字元，不是您的專案名稱)。

#### 3.2 資料庫部署

將 `supabase/migrations` 路徑下的所有資料庫結構變更，推送到您的遠端 Supabase 資料庫：
```bash
supabase db push
```

#### 3.3 環境變數設定

`line-webhook` 這個 Edge Function 需要一些機密金鑰才能與 LINE 和 Supabase 互動。

1.  在專案根目錄建立一個 `.env` 檔案，內容如下：
    ```env
    # 從 LINE Developer Console 取得
    LINE_CHANNEL_ACCESS_TOKEN="ep..."

    # 從 Supabase 儀表板 -> Settings -> API 取得
    SB_URL="https://<your-project-id>.supabase.co"
    SB_ANON_KEY="ey..."
    ```

2.  將這些環境變數設定到遠端的 Supabase 專案中：
    ```bash
    supabase secrets set --env-file ./.env
    ```

#### 3.4 部署 Edge Functions

將 `line-webhook` 函式部署到 Supabase。`--no-verify-jwt` 參數是必要的，因為請求來自 LINE 而非使用者。
```bash
supabase functions deploy line-webhook --no-verify-jwt
```
部署成功後，您會得到一個函式網址，這將是您 LINE Bot 的 Webhook URL。

### 4. LINE Bot 設定

1.  前往您的 LINE Developer Console。
2.  選擇您的 Messaging API channel。
3.  在 "Webhook settings" 中，填入您上一步驟取得的 Supabase Function URL。
4.  啟用 "Use webhook"。

### 5. 圖文選單設定 (Rich Menu)

本專案的圖文選單是透過 LINE Official Account Manager 後台手動設定，以簡化流程。

1.  前往 LINE Official Account Manager 並登入。
2.  選擇您的官方帳號，進入 `聊天室相關 > 圖文選單`。
3.  點擊 `建立`。
4.  **設定內容**:
    *   **標題**: 自訂 (例如：主選單)
    *   **狀態**: 顯示
5.  **設定版型**:
    *   點擊 `選擇版型`，選擇 `大型`，並選取「一大三小」的 `4個按鈕` 的版型。
    *   點擊 `建立圖片` > `上傳背景圖片`，選擇專案中的 `images/KAY-GYM-MENU.jpg` 檔案。
6.  **設定動作 (Action)**:
    *   **區域 A (預約課程)**: 類型選擇 `連結`，並貼上您的 `LIFF URL` (例如: `https://liff.line.me/YOUR_LIFF_ID`)。
    *   **區域 B (確認/取消)**: 類型選擇 `文字`，並輸入 `[確認/取消]`。
    *   **區域 C (個人記錄)**: 類型選擇 `文字`，並輸入 `[個人記錄]`。
    *   **區域 D (聯絡資訊)**: 類型選擇 `文字`，並輸入 `[聯絡資訊]`。
7.  儲存後，此圖文選單將會成為預設選單。

### 6. 前端設定與部署

1.  **修改 `config.js`**：
    打開根目錄的 `config.js` 檔案，將 `SUPABASE_URL` 和 `SUPABASE_ANON_KEY` 替換為您自己的 Supabase 專案資訊。同時，也請填入您自己的 `LIFF_ID`。
    ```javascript
    const AppConfig = {
        SUPABASE_URL: 'https://<your-project-id>.supabase.co',
        SUPABASE_ANON_KEY: 'YOUR_ANON_KEY',
        LIFF_ID: 'YOUR_LIFF_ID', // 從 LINE Login Channel 取得,
        IMAGE_BASE_URL: 'https://raw.githubusercontent.com/<YOUR_GITHUB_USERNAME>/WALLY-STUDIO/main/images/'
    };
    ```
    **注意**: `IMAGE_BASE_URL` 需替換為您自己的 GitHub 使用者名稱。

2.  **部署前端網頁**：
    這是一個純靜態前端專案，推薦使用 GitHub Pages 進行部署。將您的專案推送到 GitHub 儲存庫後，前往儲存庫的 `Settings > Pages`，選擇 `main` 分支並啟用。您的網址會是 `https://<YOUR_GITHUB_USERNAME>.github.io/WALLY-STUDIO/`。

3.  **設定 LIFF URL**：
    最後，回到 LINE Developer Console，在您的 LINE Login Channel 的 LIFF 分頁中，將 "Endpoint URL" 設定為您部署好的 GitHub Pages 網址 (例如: `https://<YOUR_GITHUB_USERNAME>.github.io/WALLY-STUDIO/`)。