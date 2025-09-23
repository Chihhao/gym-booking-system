# gym-booking-system
A gym booking system with LINE Bot and Google Apps Script.

## 安全性 (Security)

本專案在設計上特別注重金鑰與機敏資料的安全性，遵循前端與後端分離的最佳實踐。

### 1. 前端金鑰管理 (Frontend Key Management)

所有面向使用者的前端頁面 (`courses.html`, `schedule.html`, `manager.html` 等) 均採用以下安全策略：

*   **使用公開金鑰 (Public `anon` Key)**：前端僅使用 Supabase 的 `anon` (公開) 金鑰。此金鑰本身是設計給瀏覽器等公開環境使用的，其權限受到後端嚴格控管。
*   **權限控管依賴 RLS**：資料的讀取權限完全由 Supabase 的 **RLS (Row Level Security)** 政策來控制。這確保了使用者即使擁有 `anon` 金鑰，也只能存取到他們被授權的資料。
*   **寫入操作透過 RPC**：所有需要更高權限的寫入、修改、刪除操作，都不是由前端直接執行，而是透過呼叫安全的後端 **RPC (Remote Procedure Call)** 函式 (`SECURITY DEFINER` function) 來完成。這避免了在前端洩漏任何具有寫入權限的金鑰。
*   **設定檔集中管理**：所有的前端設定（如 `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `LIFF_ID`）都統一存放在 `config.js` 檔案中，避免了在多個檔案中硬編碼 (hardcode)，方便統一管理與更換。

### 2. 後端金鑰管理 (Backend Key Management - Google Apps Script)

後端邏輯由 Google Apps Script (`Code.gs`) 處理，所有機密金鑰都受到妥善保護：

*   **嚴禁在程式碼中存放金鑰**：高度機密的金鑰，如 **`CHANNEL_ACCESS_TOKEN`** (LINE Bot 的完整權限金鑰) 和 **`SUPABASE_SERVICE_KEY`** (Supabase 的後台管理員金鑰)，**絕對不會**直接寫在 `.gs` 程式碼檔案中。
*   **使用指令碼屬性 (Script Properties)**：所有機密金鑰皆存放在 Google Apps Script 提供的「**指令碼屬性 (Script Properties)**」中。
    *   這是一個與 Apps Script 專案綁定的安全鍵值儲存區。
    *   儲存在此處的資料**不會**被包含在原始碼檔案裡。
    *   因此，即使將專案程式碼推送到公開的 GitHub 儲存庫，這些機密金鑰也**不會外洩**。

---

透過上述設計，我們確保了：
- **前端**：只持有最低權限的公開金鑰，負責呈現資料和觸發後端函式。
- **後端**：安全地保管擁有高權限的機密金鑰，並透過封裝好的函式提供有限、安全的服務給前端呼叫。
