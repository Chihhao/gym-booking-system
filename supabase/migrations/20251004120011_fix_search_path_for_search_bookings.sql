-- 目的：修復 search_bookings 函式的 search_path 安全性警告。
-- 雖然此函式非 SECURITY DEFINER，但明確設定 search_path 是一個良好的安全實踐，
-- 可以確保函式在執行時只會尋找 'public' schema 中的物件，增加程式碼的明確性與安全性。

CREATE OR REPLACE FUNCTION public.search_bookings(p_status text DEFAULT NULL::text, p_class_date date DEFAULT NULL::date, p_query text DEFAULT NULL::text)
 RETURNS TABLE(booking_id text, booking_time timestamp with time zone, status text, class_name text, class_date date, start_time time without time zone, coach_name text, course_name text, color text, line_display_name text)
 LANGUAGE plpgsql
 SET search_path TO 'public' -- 關鍵修正
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        b.booking_id,
        b.booking_time,
        b.status,
        cl.class_name,
        cl.class_date,
        cl.start_time,
        co.coach_name,
        cr.course_name,
        cr.color,
        u.line_display_name
    FROM
        bookings b
    LEFT JOIN classes cl ON b.class_id = cl.class_id
    LEFT JOIN users u ON b.line_user_id = u.line_user_id
    LEFT JOIN courses cr ON cl.course_id = cr.course_id
    LEFT JOIN coaches co ON cl.coach_id = co.coach_id
    WHERE
        (p_status IS NULL OR b.status = p_status) AND
        (p_class_date IS NULL OR cl.class_date = p_class_date) AND
        (p_query IS NULL OR (
            u.line_display_name ILIKE '%' || p_query || '%' OR
            b.booking_id ILIKE '%' || p_query || '%'
        ))
    ORDER BY
        b.booking_time DESC;
END; $function$;