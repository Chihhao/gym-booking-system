-- 步驟 1: 移除在 `...refine_rls_policies.sql` 中建立的、無法對 LIFF 使用者生效的 RLS 原則。
-- 這個原則要求 `authenticated` 角色，但 LIFF 使用者是 `anon` 角色。

DROP POLICY IF EXISTS "Allow individual user to read their own bookings" ON public.bookings;


-- 步驟 2: 建立一個新的 RPC 函式 `get_user_bookings`。
-- 這個函式讓前端可以傳入 line_user_id，並安全地在後端查詢該使用者在特定課堂中的預約。
-- 這樣前端 (schedule.html) 就能知道哪些時段已經被預約，並顯示綠色勾勾。
-- 函式設定為 SECURITY INVOKER，但因為我們沒有為 bookings 表設定 `anon` 的 SELECT 權限，所以匿名使用者無法直接查詢。
-- 這是一個安全的折衷方案，邏輯由我們可信的函式控制。

CREATE OR REPLACE FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[])
RETURNS TABLE(class_id text, booking_id text)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        b.class_id,
        b.booking_id
    FROM
        public.bookings b
    WHERE
        b.line_user_id = p_user_id
        AND b.class_id = ANY(p_class_ids)
        AND b.status IN ('已預約', '已扣款');
END;
$function$
;


-- 步驟 3: 建立一個新的 RPC 函式 `get_booking_details_for_user`。
-- 這個函式讓 booking-details.html 和 booking-complete.html 可以安全地取得憑證資料。
-- 它會同時驗證 booking_id 和 line_user_id，確保使用者只能看到自己的憑證。

CREATE OR REPLACE FUNCTION public.get_booking_details_for_user(p_booking_id text, p_user_id text)
RETURNS TABLE (
    booking_id text,
    status text,
    class_date date,
    start_time time,
    course_name text,
    coach_name text,
    line_display_name text
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        b.booking_id, b.status, cl.class_date, cl.start_time,
        cr.course_name, co.coach_name, u.line_display_name
    FROM public.bookings b
    JOIN public.classes cl ON b.class_id = cl.class_id
    JOIN public.courses cr ON cl.course_id = cr.course_id
    JOIN public.coaches co ON cl.coach_id = co.coach_id
    JOIN public.users u ON b.line_user_id = u.line_user_id
    WHERE b.booking_id = p_booking_id AND b.line_user_id = p_user_id;
END;
$function$
;