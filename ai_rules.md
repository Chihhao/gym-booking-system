# 專案 AI 助理規則

## Supabase 資料庫管理

### 備份/同步遠端資料庫結構 (Schema)

當需要將遠端 Supabase 資料庫的最新結構同步到本地時，請依照以下步驟操作：

1.  **初始化 (僅限首次)**: 如果是第一次在此專案執行，需先初始化。
    ```bash
    supabase init
    ```
2.  **連結專案 (僅限首次)**: 初始化後，需連結到遠端的 Supabase 專案。`<project-ref>` 要替換成實際的專案 ID。
    ```bash
    supabase link --project-ref <project-ref>
    ```
3.  **拉取結構**: 執行 `db pull` 來抓取最新的資料庫結構。這會將 schema 儲存為一個新的 migration 檔案。
    ```bash
    supabase db pull
    ```

---

## 開發原則

- **Schema 變更**: 每次修改應用程式程式碼時，如果有更動到資料庫結構 (例如：新增 table、修改 column)，都必須執行資料庫 migration 來記錄這些變更。
