# gym-booking-system

這是一個為健身房或自由教練工作室設計的預約系統。它結合了 LINE LIFF 應用程式，讓學員可以方便地瀏覽課程、預約時段；同時提供一個功能完整的網頁後台，供管理者處理預約、排課與客戶管理。

後端完全採用 Supabase 進行資料庫、核心業務邏輯，以及 LINE Webhook 事件的接收與處理。

---

## 核心功能 (Core Features)

### 學員端 (LINE LIFF)
*   **課程型錄**：瀏覽所有可預約的課程。
*   **視覺化課表**：以週為單位查看課表並即時預約。
*   **預約憑證**：顯示預約成功的 QR Code 憑證。
*   **LINE Bot 互動**：透過圖文選單查詢個人預約紀錄。

### 管理後台
*   **預約管理**：審核學員預約 (扣款/取消)。
*   **課表管理**：視覺化的排課介面，可新增、編輯、刪除課堂。
*   **資料管理**：統一管理課程型錄、教練與客戶資料。
*   **安全登入**：透過 Google 帳號驗證，確保只有管理者能存取後台。

---

## 技術棧 (Tech Stack)

*   **後端**: Supabase (PostgreSQL, Auth, RLS, RPC Functions)
*   **Webhook 服務**: Supabase Edge Functions
*   **前端**: HTML, CSS, JavaScript, LIFF SDK
*   **部署**: Supabase CLI (for database migrations & edge functions)
