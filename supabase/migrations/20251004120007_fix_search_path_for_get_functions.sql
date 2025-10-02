-- 目的：一次性修復所有 get_* 類型函式的 search_path 安全性警告。
-- 透過在函式定義中加入 `SET search_path = 'public'`，
-- 我們可以確保函式在執行時只會尋找 'public' schema 中的物件，
-- 從而防止惡意使用者透過操縱 search_path 來執行非預期的程式碼。

-- 修正 get_booking_details_for_user 函式
CREATE OR REPLACE FUNCTION public.get_booking_details_for_user(p_booking_id text, p_user_id text)
RETURNS TABLE (
    booking_id text,
    status text,
    class_date date,
    start_time time without time zone,
    course_name text,
    coach_name text,
    line_display_name text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public' -- 關鍵修正
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
END; $function$;

-- 修正 get_class_details 函式
CREATE OR REPLACE FUNCTION public.get_class_details(p_class_id text)
 RETURNS TABLE(course_name text, class_date date, start_time time without time zone, coach_name text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
BEGIN
  RETURN QUERY
  SELECT
    cr.course_name,
    cl.class_date,
    cl.start_time,
    co.coach_name
  FROM public.classes cl
  JOIN public.courses cr ON cl.course_id = cr.course_id
  JOIN public.coaches co ON cl.coach_id = co.coach_id
  WHERE cl.class_id = p_class_id;
END; $function$;

-- 修正 get_manager_form_data 函式
CREATE OR REPLACE FUNCTION public.get_manager_form_data()
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
DECLARE
    courses_json JSON;
    coaches_json JSON;
BEGIN
    -- 查詢所有啟用的課程，並依照 course_id 排序
    SELECT json_agg(json_build_object('courseId', c.course_id, 'courseName', c.course_name) ORDER BY c.course_id)
    INTO courses_json
    FROM public.courses c
    WHERE c.status = 'Active';

    -- 查詢所有教練，並依照 coach_id 排序
    SELECT json_agg(json_build_object('coachId', ch.coach_id, 'coachName', ch.coach_name) ORDER BY ch.coach_id)
    INTO coaches_json
    FROM public.coaches ch;

    -- 組合回傳結果
    RETURN json_build_object(
        'status', 'success',
        'courses', COALESCE(courses_json, '[]'::json),
        'coaches', COALESCE(coaches_json, '[]'::json)
    );
END; $function$;

-- 修正 get_user_bookings 函式
CREATE OR REPLACE FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[])
RETURNS TABLE(class_id text, booking_id text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public' -- 關鍵修正
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
END; $function$;