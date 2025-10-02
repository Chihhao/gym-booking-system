-- 目的：修復 review_booking_atomic 函式的 search_path 安全性警告。
-- 透過在函式定義中加入 `SET search_path = 'public'`，
-- 我們可以確保函式在執行時只會尋找 'public' schema 中的物件，
-- 從而防止惡意使用者透過操縱 search_path 來執行非預期的程式碼。

CREATE OR REPLACE FUNCTION public.review_booking_atomic(p_booking_id text, p_decision text)
 RETURNS TABLE(status text, message text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
DECLARE
    v_booking_info RECORD;
    v_new_status TEXT;
BEGIN
    -- 1. 檢查並鎖定預約紀錄，防止競爭條件
    SELECT * INTO v_booking_info
    FROM public.bookings
    WHERE booking_id = p_booking_id
    FOR UPDATE;

    -- 2. 檢查預約是否存在或狀態是否正確
    IF v_booking_info IS NULL THEN
        RETURN QUERY SELECT 'error'::TEXT, '找不到該筆預約紀錄。'::TEXT;
        RETURN;
    END IF;

    IF v_booking_info.status <> '已預約' THEN
        RETURN QUERY SELECT 'error'::TEXT, '此預約狀態為「' || v_booking_info.status || '」，無法執行此操作。'::TEXT;
        RETURN;
    END IF;

    -- 3. 根據決定執行不同操作
    IF p_decision = 'approve' THEN
        UPDATE public.bookings
        SET status = '已扣款', update_time = NOW(), update_user = 'Admin'
        WHERE booking_id = p_booking_id;
        RETURN QUERY SELECT 'success'::TEXT, '操作成功：已扣款'::TEXT;

    ELSIF p_decision = 'reject' THEN
        UPDATE public.bookings
        SET status = '已取消', update_time = NOW(), update_user = 'Admin'
        WHERE booking_id = p_booking_id;

        UPDATE public.classes
        SET current_students = current_students - 1
        WHERE class_id = v_booking_info.class_id AND current_students > 0;
        RETURN QUERY SELECT 'success'::TEXT, '操作成功：已取消'::TEXT;
    ELSE
        RETURN QUERY SELECT 'error'::TEXT, '無效的操作決定。'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'error'::TEXT, '處理審核時發生未預期錯誤: ' || SQLERRM;
END; $function$;