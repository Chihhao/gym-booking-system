-- 目的：為透過 Google 登入的管理者建立讀取敏感資料的 RLS (Row Level Security) 策略。
--
-- 問題說明：
-- 在先前的步驟中，我們為了使用者端的安全，移除了 bookings 和 users 資料表的公開讀取權限。
-- 這導致管理者即使登入後台，也因為缺乏對應的 RLS 策略而無法看到這些資料。
--
-- 解決方案：
-- 建立新的 RLS 策略，明確授權給在管理者列表中的已驗證使用者 (`authenticated` 角色)。

-- 步驟 1: 為 bookings 資料表建立管理者讀取策略
-- 允許 email 在管理者列表中的已驗證使用者，讀取所有預約紀錄。
CREATE POLICY "Allow admin read access to all bookings"
ON "public"."bookings"
AS permissive
FOR select
TO authenticated
USING (
    (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))
);

-- 步驟 2: 為 users 資料表建立管理者讀取策略
-- 允許 email 在管理者列表中的已驗證使用者，讀取所有客戶資料。
CREATE POLICY "Allow admin read access to all users"
ON "public"."users"
AS permissive
FOR select
TO authenticated
USING (
    (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))
);