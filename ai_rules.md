# 專案 AI 助理規則

這份文件定義了與 AI 協作開發此專案時應遵循的規則與最佳實踐，旨在確保程式碼品質、可維護性與安全性。

---
## 0. 基本原則
* 用繁體中文回覆

## 1. 核心開發原則 (Core Principles)

*   **1.1. Supabase 優先 (Supabase First)**: 新功能應優先考慮使用 Supabase 的內建功能實現，例如：資料庫函式 (RPC)、視圖 (View)、RLS 政策等，以減少前端和 Google Apps Script 的複雜性。
*   **1.2. 前後端分離 (Frontend/Backend Separation)**: 嚴格遵守前後端分離原則。前端 (`.html`) 僅負責 UI 呈現與使用者互動，並透過 Supabase JS SDK 與後端溝通。所有業務邏輯和資料驗證應在 Supabase 後端 (RPC/RLS) 完成。
*   **1.3. 安全第一 (Security First)**: 始終將安全性作為最高優先級。遵循 `README.md` 中定義的安全模型，嚴禁在前端程式碼中洩漏任何服務金鑰 (`service_key`)。
    *   **前端金鑰管理 (Frontend Key Management)**
        *   **使用公開金鑰 (Public `anon` Key)**：前端僅使用 Supabase 的 `anon` (公開) 金鑰。此金鑰本身是設計給瀏覽器等公開環境使用的，其權限受到後端嚴格控管。
        *   **權限控管依賴 RLS**：資料的讀取權限完全由 Supabase 的 **RLS (Row Level Security)** 政策來控制。這確保了使用者即使擁有 `anon` 金鑰，也只能存取到他們被授權的資料。
        *   **寫入操作透過 RPC**：所有需要更高權限的寫入、修改、刪除操作，都不是由前端直接執行，而是透過呼叫安全的後端 **RPC (Remote Procedure Call)** 函式 (`SECURITY DEFINER` function) 來完成。這避免了在前端洩漏任何具有寫入權限的金鑰。
        *   **設定檔集中管理**：所有的前端設定（如 `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `LIFF_ID`）都統一存放在 `config.js` 檔案中，避免了在多個檔案中硬編碼 (hardcode)，方便統一管理與更換。
    *   **後端金鑰管理 (Backend Key Management - Google Apps Script)**
        *   **嚴禁在程式碼中存放金鑰**：高度機密的金鑰，如 **`CHANNEL_ACCESS_TOKEN`** (LINE Bot 的完整權限金鑰) 和 **`SUPABASE_SERVICE_KEY`** (Supabase 的後台管理員金鑰)，**絕對不會**直接寫在 `.gs` 程式碼檔案中。
        *   **使用指令碼屬性 (Script Properties)**：所有機密金鑰皆存放在 Google Apps Script 提供的「**指令碼屬性 (Script Properties)**」中。
            *   這是一個與 Apps Script 專案綁定的安全鍵值儲存區。
            *   儲存在此處的資料**不會**被包含在原始碼檔案裡。
            *   因此，即使將專案程式碼推送到公開的 GitHub 儲存庫，這些機密金鑰也**不會外洩**。
*   **1.4. 程式碼即文件 (Code as Documentation)**: 撰寫清晰、可讀性高的程式碼。使用有意義的變數和函式命名，並在複雜的邏輯區塊加上簡要註解。

---

## 2. 前端開發規範 (Frontend Development)

*   **2.1. JavaScript 規範**
    *   **語法 (Syntax)**: 優先使用現代 JavaScript (ES6+) 語法。
        *   預設使用 `const`，僅在變數需要被重新賦值時才使用 `let`。避免使用 `var`。
        *   積極使用 `async/await` 處理非同步操作，以提高程式碼的可讀性。
    *   **DOM 操作**: 所有 DOM 操作和事件監聽都應在 `DOMContentLoaded` 事件觸發後執行，確保 HTML 元素已完全載入。
        ```javascript
        // 良好範例
        document.addEventListener('DOMContentLoaded', () => {
            // 所有程式碼的進入點
            const filterButton = document.getElementById('filter-btn');
            if (filterButton) {
                filterButton.addEventListener('click', applyFilters);
            }
            // ... 其他初始化程式碼
        });
        ```
    *   **函式組織**:
        *   將相關功能的函式組織在一起。
        *   使用 `// ---` 或 `// =================` 作為註解分隔符，區分不同功能的程式碼區塊。
        *   為複雜的函式提供 JSDoc 風格的註解。
        ```javascript
        // --- 預約管理 (Bookings) 相關函式 ---

        /**
         * 根據篩選條件載入並渲染預約列表
         * @param {object} filters - 篩選條件，例如 { status: '已預約', query: 'John' }
         */
        async function loadBookings(filters = {}) {
            // ... 函式實作
        }
        ```
    *   **命名規範**:
        *   函式與變數使用小駝峰命名法 (camelCase)，例如 `loadBookings`。
        *   常數使用全大寫蛇形命名法 (UPPER_SNAKE_CASE)，例如 `AppConfig.SUPABASE_URL`。

*   **2.2. HTML 規範**
    *   **語意化**: 保持 HTML 結構語意化，使用正確的標籤。這有助於無障礙性 (Accessibility) 和搜尋引擎優化 (SEO)。
        ```html
        <!-- 良好範例 -->
        <body>
            <nav class="sidebar">...</nav>
            <main class="main-content">
                <section id="bookings">
                    <h1>預約管理</h1>
                    ...
                </section>
            </main>
        </body>
        ```
    *   **ID 與 Class**:
        *   `id` 在整個頁面中必須是唯一的，主要用於 JavaScript 選取特定單一元素。
        *   `class` 可以重複使用，主要用於 CSS 樣式定義和 JavaScript 選取多個元素。

*   **2.3. 錯誤處理與 UI 狀態**
    *   **非同步錯誤處理**: 所有對 Supabase 的請求都必須用 `try...catch` 包裹，並在 `catch` 區塊中處理錯誤。
    *   **使用者反饋**:
        *   在 `try` 區塊開始時，應提供即時的 UI 反饋，例如顯示「載入中...」訊息或禁用按鈕。
        *   在 `catch` 區塊中，應向使用者顯示友善的錯誤提示 (例如 `alert()` 或更新頁面元素)，並在控制台 (`console.error`) 記錄詳細的錯誤物件。
        *   在 `finally` 區塊中，無論成功或失敗，都應恢復 UI 狀態（例如隱藏「載入中」訊息、恢復按鈕）。
    ```javascript
    // 良好範例
    async function saveCourse() {
        const submitBtn = document.getElementById('submit-course-btn');
        const originalBtnText = submitBtn.textContent;
        submitBtn.disabled = true;
        submitBtn.textContent = '儲存中...';

        try {
            const { data, error } = await supabaseClient.rpc('save_course', { /* ... */ });
            if (error) throw error; // 將 Supabase 回傳的 error 拋到 catch 區塊

            alert('儲存成功！');
            // ... 執行成功後的其他操作

        } catch (err) {
            console.error('儲存課程時發生錯誤:', err);
            alert(`操作失敗：${err.message}`);
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = originalBtnText;
        }
    }
    ```
*   **2.4. 進階 CSS 佈局：含固定頁首/頁尾的垂直置中 (Advanced CSS: Vertical Centering with Fixed Header/Footer)**
    *   **情境 (Scenario)**: 當頁面有使用 `position: fixed` 的頁首和頁尾時，如何讓主要內容區塊在剩餘的可視空間內實現完美的垂直與水平置中。
    *   **挑戰 (Challenge)**: `body` 上的 `padding`（為了避開頁首/頁尾）會干擾子元素的高度計算，使得傳統的 `height: 100%` 或 `justify-content: center` 失效。
    *   **解決方案 (Solution)**: 採用一個由外到內的巢狀 Flexbox 佈局。
        1.  **HTML 結構**:
            ```html
            <body>
                <div class="main-container">
                    <div id="header-container">... (e.g., Progress Bar)</div>
                    <div id="content-container">... (The content to be centered)</div>
                </div>
            </body>
            ```
        2.  **CSS 樣式**:
            *   **`body`**: 負責撐滿整個螢幕，並處理為頁首/頁尾預留的空間。
                ```css
                body {
                    height: 100dvh; /* 關鍵：撐滿可視高度 */
                    display: flex;
                    flex-direction: column;
                    align-items: center; /* 水平置中 .main-container */
                    padding: 40px 0; /* 為 Header/Footer 預留空間 */
                    box-sizing: border-box; /* 關鍵：確保 padding 不會讓總高超出 100dvh */
                    margin: 0;
                }
                ```
            *   **`.main-container`**: 負責填滿 `body` 內部的剩餘空間。
                ```css
                .main-container {
                    flex-grow: 1; /* 關鍵：填滿 body 內部的所有可用垂直空間 */
                    min-height: 0; /* Flexbox 安全設置，防止內容溢出 */
                    display: flex;
                    flex-direction: column;
                    width: 100%;
                    max-width: 480px; /* 限制最大寬度 */
                }
                ```
            *   **`#content-container`**: 負責在 `.main-container` 的剩餘空間內，將自己的內容垂直置中。
                ```css
                #content-container {
                    flex-grow: 1; /* 關鍵：填滿 header-container 以外的剩餘空間 */
                    display: flex;
                    flex-direction: column;
                    justify-content: center; /* 關鍵：將內容垂直置中 */
                }
                ```
*   **2.5. CSS 開發原則與版面一致性 (CSS Principles & Layout Consistency)**
    *   **問題根源 (Root Cause of Inconsistency)**: 專案初期，各頁面獨立開發，導致樣式分散在各自的 `<style>` 標籤中，缺乏統一規範。這造成了「改東壞西」的維護困難，且難以實現全站一致的視覺體驗。

    *   **解決方案與未來原則 (Solution & Future Principles)**:
        1.  **貫徹元件化與集中化 (Embrace Componentization & Centralization)**:
            *   **識別通用元件**: 在開發新功能前，先思考 UI 元件（如卡片、按鈕、容器）是否可重用。
            *   **優先使用 `common.css`**: 將所有可重用的樣式（如 `.main-container`, `.card`, `.btn`）全部集中到 `common.css`。
            *   **避免頁面級樣式**: 盡量避免在個別 HTML 檔案的 `<style>` 標籤中編寫通用或可重用的樣式。

        3.  **保持 HTML 結構的一致性 (Maintain Consistent HTML Structure)**:
            *   所有主要頁面都應遵循一個標準的 HTML 骨架，特別是使用通用的容器 class，例如：
                ```html
                <body>
                    <div class="main-container">
                        <!-- Page content goes here -->
                    </div>
                </body>
                ```
            *   一致的結構不僅讓版面統一，也讓 CSS 和 JavaScript 的操作更可預測、更穩定。

---

## 3. Supabase 後端開發規範 (Backend Development)

*   **3.1. 資料庫結構 (Schema)**:
    *   任何資料庫結構的變更（新增/修改資料表、欄位）都必須透過 Supabase Migration 來管理。
    *   在修改後，需執行 `supabase db pull` 將變更同步到本地 migration 檔案。
*   **3.2. 資料庫函式 (RPC)**:
    *   複雜的資料庫操作（特別是涉及多個步驟或需要交易安全性的寫入操作）應封裝在 `SECURITY DEFINER` 的 RPC 函式中。
    *   函式應包含錯誤處理，並回傳統一格式的物件，例如 `{ status: 'success' | 'error', message: '...' }`。

*   **3.3. 安全性 (RLS)**:
    *   所有資料表都應啟用 RLS (Row Level Security)。
    *   預設應拒絕所有操作，並根據需求為特定角色 (`anon`, `authenticated`) 建立最小權限的 `POLICY`。

*   **3.4. 資料庫變更流程 (Migration Workflow)**:
    *   **原則 (Principle)**: 為了確保版本控制的清晰與安全，我們採用**「本地優先 (Local-First)」**作為標準開發流程。所有資料庫的變更都應從本地開始，並透過建立一個**新的** migration 檔案來記錄，最後再推送到雲端。

    *   **操作步驟 (Steps)**:
        1.  **建立新的 Migration 檔案**: 當您需要修改資料庫結構（例如修改 `FUNCTION`, `VIEW`, 或 `TABLE`）時，請在終端機執行以下指令，為您的變更取一個有意義的名稱。
            ```bash
            supabase migration new <your_change_description>
            ```
            例如：`supabase migration new add_sorting_to_manager_functions`

        2.  **在本地撰寫變更**: 使用 VS Code 等編輯器打開上一步建立的 SQL 檔案，在裡面只寫入您**實際變更**的 SQL 指令。
            *   **修改函式/視圖**: 貼上完整的 `CREATE OR REPLACE FUNCTION ...` 或 `CREATE OR REPLACE VIEW ...` 區塊。
            *   **修改資料表**: 寫入 `ALTER TABLE ...` 指令。

        3.  **推送至雲端**: 儲存檔案後，執行以下指令將本地的變更「部署」到 Supabase 雲端資料庫。
            ```bash
            supabase db push
            ```

    *   **`db push` 的作用**:
        *   Supabase CLI 會比對本地 `migrations` 資料夾與雲端資料庫的執行紀錄，只執行尚未被執行的**新** migration 檔案。
        *   您的雲端資料庫結構會被更新。
        *   您本地的 `supabase/migrations` 資料夾現在會包含多個 SQL 檔案（一個初始檔 + 數個變更檔），這代表了您資料庫的完整演進歷史，是完全正常且正確的行為。

    *   **還原方法 (Rollback)**: 如果 `push` 之後發現功能錯誤，**切勿**修改舊的 migration 檔案。您應該建立一個**新的** migration 檔案來「反向操作」或修正錯誤，然後再次 `db push`。這確保了所有變更歷史都是可追溯的。

---
*   **3.5. 替代工作流程：雲端優先原型開發 (Alternative Workflow: Cloud-First Prototyping)**
    *   **情境 (Scenario)**: 此工作流程適用於需要快速迭代、測試想法的原型製作階段。它允許開發者直接在 Supabase Studio（網站介面）上修改，然後將變更同步回本地。**此流程不建議用於正式或多人協作的環境**，因為它缺乏清晰的還原路徑。
    *   **核心原則 (Core Principle)**: 雲端是唯一的真相來源 (Single Source of Truth)。本地的 migration 檔案僅作為雲端狀態的備份。

    *   **操作步驟 (Steps)**:
        1.  **在雲端修改 (Modify in the Cloud)**: 使用 Supabase Studio 的 SQL Editor 或圖形化介面進行資料庫變更。
        2.  **同步回本地 (Sync to Local)**: 在雲端完成修改並測試後，**立即**在本地終端機執行以下指令，將雲端的變更拉回本地：
            ```bash
            supabase db pull
            ```
        3.  **結果 (Result)**: `db pull` 會自動比較雲端與本地的差異，並在 `supabase/migrations` 資料夾中建立一個新的 SQL 檔案，記錄您剛剛的所有變更。

    *   **疑難排解 (Troubleshooting)**:
        *   **`connection refused`**: 當 CLI 工具無法連線到資料庫時發生。可能原因有：
            1.  **專案已暫停 (Project Paused)**: 免費專案若一週無活動會被暫停。**解決方案**: 在執行 CLI 指令前，先登入 Supabase 儀表板以「喚醒」專案。
            2.  **網路不穩定 (Network Instability)**: 您與 Supabase 伺服器之間的連線暫時不通。**解決方案**: 等待幾秒後重試指令。CLI 的內建重試機制通常能解決此問題。
            3.  **防火牆 (Firewall)**: 公司或家用網路的防火牆阻擋了 `5432` 或 `6543` 連接埠。**解決方案**: 暫時更換到手機熱點網路進行測試。
        *   **`migration history does not match`**: 如果在 `pull` 時遇到此錯誤，通常是因為雲端的歷史紀錄表 (`supabase.schema_migrations`) 記住了一些舊的、不存在於本地的變更。
            *   **解決方案**: 根據錯誤訊息提示，使用 `supabase migration repair --status reverted <MIGRATION_ID>` 指令，將雲端多餘的歷史紀錄逐一標記為無效，然後再重新執行 `supabase db pull`。

---

## 4. Google Apps Script (GAS) 維護
*   **4.1. 職責單一**: `Code.gs` 目前的唯一職責是接收 LINE Webhook 事件 (例如：使用者點擊圖文選單)，並根據事件內容回覆訊息。
*   **4.2. 避免新邏輯**: 除非與 LINE Webhook 直接相關，否則應避免在 `Code.gs` 中添加新的業務邏輯。所有資料庫相關操作應在 Supabase 中完成。
*   **4.3. 金鑰管理**: 再次強調，所有機密金鑰（如 `CHANNEL_ACCESS_TOKEN`）必須儲存在「指令碼屬性」中，絕不能硬編碼在程式碼裡。

---

## 5. 部署流程 (Deployment Process)

*   **5.1. Google Apps Script (GAS) 部署**:
    *   當 `Code.gs` 或任何 `.html` 檔案有修改時，需要將變更部署到線上環境。
    *   請在專案根目錄執行以下指令：
        ```bash
        clasp push && clasp deploy --deploymentId AKfycbzsR-H8MM9LLrAxeHPK97qJtLNL-YweksnKpA6Io14RyOrZ8NENTQ7uZ3Bd2ng6Ht3G
        ```
    *   `clasp push`：將本地的程式碼檔案上傳到 Google Apps Script 專案。
    *   `clasp deploy ...`：將上傳的程式碼更新到指定的線上版本 (Deployment)。
