# gym-booking-system 現代化改造藍圖

本文件旨在追蹤將系統後端從 Google Sheets 遷移至 Supabase 的所有待辦事項。

## 核心理念

- **讀取操作 (Read)**: 盡可能讓前端 (HTML) 直接向 Supabase 請求資料，以獲得最佳效能。透過 RLS (Row Level Security) 確保資料安全。
- **寫入操作 (Write)**: 所有涉及資料新增、修改、刪除的敏感操作，保留在後端 Google Apps Script (`Code.gs`) 中處理，以確保交易的原子性和安全性。

---

## ✅ 已完成 (Phase 1 & 2)

### Phase 1: 讀取操作革命

- [x] **資料庫與基礎建設**
  - [x] 完成資料庫遷移 (Google Sheets -> Supabase)。
  - [x] 為使用者端頁面 (`courses`, `schedule`) 設定 RLS 安全規則。
  - [x] 建立 `classes_with_details` View 以簡化課表查詢。
  - [x] 建立 `search_bookings` RPC 函式以優化預約查詢。
- [x] **使用者端 (前端直連 Supabase)**
  - [x] `courses.html` (課程列表)
  - [x] `schedule.html` (課表頁)
- [x] **管理後台 (前端直連 Supabase)**
  - [x] `manager.html` - 預約管理 (讀取)
  - [x] `manager.html` - 課表管理 (讀取)
  - [x] `manager.html` - 課程型錄 (讀取)
  - [x] `manager.html` - 客戶管理 (讀取)
  - [x] `manager.html` - 教練管理 (讀取)

### Phase 2: 核心寫入操作遷移

- [x] **使用者端 - 建立預約 (`createBooking`)**
  - [x] 建立 `create_booking_atomic` RPC 函式，確保預約的原子性。
  - [x] 改造 `Code.gs` 中的 `createBooking`，使其呼叫 RPC 函式。
- [x] **管理後台 - 預約管理 (寫入)**
  - [x] 建立 `review_booking_atomic` RPC 函式，處理扣款與取消操作。
  - [x] 改造 `reviewBooking` 函式，使其呼叫 RPC 函式。

---

## ⏳ 待辦事項 (Phase 3: 後台寫入操作完善)

### 🚀 下一階段目標

### 💻 管理後台 (`manager.html`)

- [ ] **課表管理**:
  - [ ] 改造 `saveClass` 和 `deleteClass` (寫入)。
- [ ] **課程型錄管理**:
  - [ ] 改造 `saveCourse` 和 `deleteCourse` (寫入)。
- [ ] **客戶管理**:
  - [ ] 改造 `updateUserPoints` (寫入)。
- [ ] **教練管理**:
  - [ ] 改造 `saveCoach` 和 `deleteCoach` (寫入)。