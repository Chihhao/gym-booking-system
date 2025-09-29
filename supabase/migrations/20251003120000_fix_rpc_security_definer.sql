-- 修正目的：將使用者資料查詢相關的 RPC 函式設定為 SECURITY DEFINER。
--
-- 問題說明：
-- 預設的函式安全性為 SECURITY INVOKER，這會導致函式以呼叫者（前端的 anon 角色）的權限執行。
-- 由於我們已經移除了 anon 角色對 bookings 和 users 資料表的直接讀取權限，
-- 這使得函式無法查詢到資料，進而導致 schedule.html 無法正確顯示已預約的綠色勾勾。
--
-- 解決方案：
-- 將函式改為 SECURITY DEFINER，使其以函式擁有者（擁有更高權限）的身份執行。
-- 這樣函式就可以繞過 RLS 進行查詢，同時函式內部的 WHERE 條件（p_user_id）確保了使用者只能看到自己的資料，維持了安全性。

-- 步驟 1: 修正 `get_user_bookings` 函式

CREATE OR REPLACE FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[])
RETURNS TABLE(class_id text, booking_id text)
LANGUAGE plpgsql
SECURITY DEFINER -- 關鍵修正：新增此行
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

-- 步驟 2: 修正 `get_booking_details_for_user` 函式

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
SECURITY DEFINER -- 關鍵修正：新增此行
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