# gym-booking-system 現代化改造藍圖

本文件旨在追蹤將系統後端從 Google Sheets 遷移至 Supabase 的所有待辦事項。

## 核心理念

- **讀取操作 (Read)**: 盡可能讓前端 (HTML) 直接向 Supabase 請求資料，以獲得最佳效能。透過 RLS (Row Level Security) 確保資料安全。
- **寫入操作 (Write)**: 所有涉及資料新增、修改、刪除的敏感操作，保留在後端 Google Apps Script (`Code.gs`) 中處理，以確保交易的原子性和安全性。

---

## ✅ 已完成 (Phase 1: 讀取操作革命)

- [x] **資料庫遷移**:
  - [x] 在 Supabase 中建立所有資料表 (`users`, `courses`, `classes` 等)。
  - [x] 透過一次性 GAS 腳本將所有資料從 Google Sheets 遷移至 Supabase。
- [x] **使用者端 - 課程列表 (`courses.html`)**:
  - [x] 升級為前端直連 Supabase。
  - [x] 為 `courses` 表設定 RLS 安全規則。
- [x] **使用者端 - 課表頁 (`schedule.html`)**:
  - [x] 升級為前端直連 Supabase。
  - [x] 為 `classes` 表設定 RLS 安全規則。
  - [x] 解決時區問題，確保課表時間顯示正確。
- [x] **使用者端 - 預約憑證 (`booking-details.html`)**:
  - [x] 升級後端 `getBookingDetails` 函式，改為從 Supabase 讀取資料，解決資料不一致問題。
- [x.5] **管理後台 - 預約管理 (`manager.html` - 查詢部分)**:
  - [x] 建立 `search_bookings` RPC 函式，處理複雜的關聯查詢與篩選。
  - [x] 將「預約管理」分頁的資料讀取升級為前端直連，呼叫 RPC 函式。

---

## ⏳ 待辦事項 (Phase 2: 寫入操作遷移 & 後台完善)

### 🚀 最高優先級

- [ ] **使用者端 - 建立預約 (`createBooking`)**:
  - [ ] **目標**: 改造 `Code.gs` 中的 `createBooking` 函式。
  - [ ] **作法**:
    - [ ] 建立一個 Supabase RPC 函式 `create_booking_atomic`，該函式能以「原子性」方式完成以下操作：
      1. 檢查課堂 (`classes`) 是否額滿。
      2. 新增一筆預約紀錄到 `bookings` 表。
      3. 更新 `classes` 表的 `current_students` 人數。
    - [ ] 修改 `Code.gs` 中的 `createBooking`，讓它呼叫這個新的 RPC 函式。

### 💻 管理後台 (`manager.html`)

- [ ] **預約管理 (寫入)**:
  - [ ] 改造 `reviewBooking` 函式，將「確認扣款」和「取消預約」的邏輯改為直接操作 Supabase。
- [ ] **課表管理**:
  - [ ] 升級 `loadManagerSchedule` (讀取) 為前端直連。
  - [ ] 改造 `saveClass` 和 `deleteClass` (寫入)。
- [ ] **課程型錄管理**:
  - [ ] 升級 `loadCourses` (讀取) 為前端直連。
  - [ ] 改造 `saveCourse` 和 `deleteCourse` (寫入)。
- [ ] **客戶管理**:
  - [ ] 升級 `loadUsers` (讀取) 為前端直連。
  - [ ] 改造 `updateUserPoints` (寫入)。
- [ ] **教練管理**:
  - [ ] 升級 `loadCoaches` (讀取) 為前端直連。
  - [ ] 改造 `saveCoach` 和 `deleteCoach` (寫入)。