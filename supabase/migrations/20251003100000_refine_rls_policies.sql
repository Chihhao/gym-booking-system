-- 步驟 1: 移除所有資料表上過於寬鬆的公開讀取原則 (public read policies)。
-- 這些原則允許任何人讀取資料，存在安全風險。

DROP POLICY IF EXISTS "Allow public read for all bookings" ON public.bookings;
DROP POLICY IF EXISTS "Disallow all write operations for public" ON public.bookings;

DROP POLICY IF EXISTS "Allow public read for all classes" ON public.classes;
DROP POLICY IF EXISTS "Disallow all write operations for public" ON public.classes;

DROP POLICY IF EXISTS "Allow public read for all coaches" ON public.coaches;
DROP POLICY IF EXISTS "Disallow all access for public" ON public.coaches;

DROP POLICY IF EXISTS "Disallow all write operations for public" ON public.courses;

DROP POLICY IF EXISTS "Allow public read for all users" ON public.users;
DROP POLICY IF EXISTS "Disallow all access for public" ON public.users;


-- 步驟 2: 建立新的、更安全的 RLS 原則。
-- 根據您的說明，前端使用者介面 (如課程列表、教練列表) 是以匿名 (anon) 角色查詢資料。
-- 因此，我們需要明確地為 `anon` 角色建立唯讀權限。

-- 課程 (courses): 允許任何人讀取狀態為 'Active' 的課程。
-- (此原則已存在且正確，無需變更，僅為註解說明)
-- create policy "Allow public read for active courses" on "public"."courses" as permissive for select to public using ((status = 'Active'::text));

-- 課堂 (classes): 允許任何人讀取狀態為 '開放中' 且日期未過期的課堂。
-- (此原則已存在且正確，無需變更，僅為註解說明)
-- create policy "Allow public read for available classes" on "public"."classes" as permissive for select to public using (((status = '開放中'::text) AND (class_date >= (now())::date)));

-- 教練 (coaches): 允許任何人 (anon) 讀取所有教練資料。
-- 這對於 `coaches.html` 頁面是必要的。
CREATE POLICY "Allow anonymous read access to all coaches"
ON "public"."coaches"
AS permissive
FOR select
TO anon
USING (true);

-- 使用者 (users) & 預約 (bookings):
-- 這兩張表包含敏感個資，不應允許匿名讀取。
-- `booking-details.html` 和 `schedule.html` 已透過 LIFF 登入取得 userId，
-- 並在查詢時加入 `.eq('line_user_id', userId)` 條件，這已在前端實現了基本的資料隔離。
-- 我們可以新增一條後端原則來強化這一點。

CREATE POLICY "Allow individual user to read their own bookings"
ON "public"."bookings"
AS permissive
FOR select
TO authenticated
USING ((auth.uid()::text = line_user_id));