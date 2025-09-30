-- 目的：清理並統一所有與管理者相關的 RLS (Row Level Security) 策略。
--
-- 執行步驟：
-- 1. 刪除所有舊的、分散的、或授權給錯誤角色 (public) 的管理者策略。
-- 2. 建立一組乾淨、統一的管理者策略，明確授權給 `authenticated` 角色，並賦予完整的 CRUD 權限。

-- 步驟 1: 清理所有舊的管理者相關策略

-- 刪除在 `20250929..._remote_schema.sql` 中建立的、授權給 `public` 角色的寬鬆策略
DROP POLICY IF EXISTS "Allow admin full access" ON public.bookings;
DROP POLICY IF EXISTS "Allow admin full access" ON public.classes;
DROP POLICY IF EXISTS "Allow admin full access" ON public.coaches;
DROP POLICY IF EXISTS "Allow admin full access" ON public.courses;
DROP POLICY IF EXISTS "Allow admin full access" ON public.users;

-- 刪除在 `20251004120000_setup_admin_rls.sql` 中建立的、僅有讀取權限的策略，以便被下方更完整的策略取代
DROP POLICY IF EXISTS "Allow admin read access to all bookings" ON public.bookings;
DROP POLICY IF EXISTS "Allow admin read access to all users" ON public.users;


-- 步驟 2: 為 `authenticated` 角色建立統一的、具備完整權限的管理者策略

-- 定義一個包含所有管理者 email 的陣列
-- 註：直接在 SQL 中定義此陣列比在每個策略中重複撰寫更易於維護。
-- 雖然 SQL 中無法直接宣告變數給 RLS policy 使用，但我們將此陣列複製到每個 policy 中。
-- CONSTANT admin_emails TEXT[] := ARRAY['junesnow39@gmail.com', 'kaypeng1234@gmail.com'];

-- 為 `bookings` 資料表建立管理者策略
CREATE POLICY "Allow admin full access on bookings"
ON "public"."bookings"
AS permissive FOR ALL
TO authenticated
USING (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))
WITH CHECK (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]));

-- 為 `classes` 資料表建立管理者策略
CREATE POLICY "Allow admin full access on classes"
ON "public"."classes"
AS permissive FOR ALL
TO authenticated
USING (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))
WITH CHECK (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]));

-- 為 `coaches` 資料表建立管理者策略
CREATE POLICY "Allow admin full access on coaches"
ON "public"."coaches"
AS permissive FOR ALL
TO authenticated
USING (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))
WITH CHECK (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]));

-- 為 `courses` 資料表建立管理者策略
CREATE POLICY "Allow admin full access on courses"
ON "public"."courses"
AS permissive FOR ALL
TO authenticated
USING (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))
WITH CHECK (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]));

-- 為 `users` 資料表建立管理者策略
CREATE POLICY "Allow admin full access on users"
ON "public"."users"
AS permissive FOR ALL
TO authenticated
USING (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))
WITH CHECK (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]));