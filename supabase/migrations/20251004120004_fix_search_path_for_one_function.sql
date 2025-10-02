-- 目的：修復 create_booking_atomic 函式的 search_path 安全性警告。
-- 透過在函式定義中加入 `SET search_path = 'public'`，
-- 我們可以確保函式在執行時只會尋找 'public' schema 中的物件，
-- 從而防止惡意使用者透過操縱 search_path 來執行非預期的程式碼。

CREATE OR REPLACE FUNCTION public.create_booking_atomic(p_class_id text, p_user_id text, p_display_name text)
 RETURNS TABLE(status text, message text, booking_id text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
DECLARE
    v_class_info RECORD;
    v_existing_booking_id TEXT;
    v_new_booking_id TEXT;
    v_id_prefix TEXT;
    v_max_num INT;
BEGIN
    -- 1. 檢查使用者是否已預約此課程
    SELECT b.booking_id INTO v_existing_booking_id
    FROM public.bookings b
    WHERE b.class_id = p_class_id
      AND b.line_user_id = p_user_id
      AND b.status IN ('已預約', '已扣款');

    IF v_existing_booking_id IS NOT NULL THEN
        RETURN QUERY SELECT 'error'::TEXT, '您已預約此課程，請勿重複預約。'::TEXT, NULL::TEXT;
        RETURN;
    END IF;

    -- 2. 鎖定課堂資料列以防止競爭條件，並檢查是否額滿
    SELECT * INTO v_class_info
    FROM public.classes
    WHERE class_id = p_class_id
    FOR UPDATE; -- 關鍵：鎖定此行，直到交易結束

    IF v_class_info IS NULL THEN
        RETURN QUERY SELECT 'error'::TEXT, '課程不存在。'::TEXT, NULL::TEXT;
        RETURN;
    END IF;

    IF v_class_info.current_students >= v_class_info.max_students THEN
        RETURN QUERY SELECT 'error'::TEXT, '課程已額滿。'::TEXT, NULL::TEXT;
        RETURN;
    END IF;

    -- 3. 如果使用者不存在，則新增使用者資料 (Upsert)
    INSERT INTO public.users (line_user_id, line_display_name, registration_date, points)
    VALUES (p_user_id, p_display_name, NOW(), 0)
    ON CONFLICT (line_user_id) DO NOTHING;

    -- 4. 產生新的預約編號 (BK + 年月 + 5位流水號)
    v_id_prefix := 'BK' || to_char(NOW(), 'YYYYMM');
    SELECT COALESCE(MAX(SUBSTRING(b.booking_id FROM 9 FOR 5)::INT), 0)
    INTO v_max_num
    FROM public.bookings b
    WHERE b.booking_id LIKE v_id_prefix || '%';
    v_new_booking_id := v_id_prefix || LPAD((v_max_num + 1)::TEXT, 5, '0');

    -- 5. 新增預約紀錄
    INSERT INTO public.bookings (booking_id, class_id, line_user_id, status, booking_time, create_time, create_user)
    VALUES (v_new_booking_id, p_class_id, p_user_id, '已預約', NOW(), NOW(), p_display_name);

    -- 6. 更新課堂的目前學生人數
    UPDATE public.classes
    SET current_students = current_students + 1
    WHERE class_id = p_class_id;

    -- 7. 回傳成功結果
    RETURN QUERY SELECT 'success'::TEXT, '預約成功！'::TEXT, v_new_booking_id::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        -- 如果發生任何未預期的錯誤，回傳通用錯誤訊息
        RETURN QUERY SELECT 'error'::TEXT, '處理預約時發生未預期錯誤: ' || SQLERRM, NULL::TEXT;
END; $function$;