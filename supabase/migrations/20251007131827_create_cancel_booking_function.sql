-- 目的: 建立一個新的 RPC 函式 `cancel_booking_atomic`，用於以原子方式處理使用者取消預約的請求。

-- 函式說明:
-- 1. 安全性: 函式為 SECURITY DEFINER，以擁有者的權限執行，確保可以更新 bookings 和 classes 資料表。
-- 2. 原子性: 整個流程包裹在一個交易區塊中，確保「更新預約狀態」和「減少課堂人數」要嘛同時成功，要嘛同時失敗。
-- 3. 驗證:
--    - 驗證 booking_id 是否存在。
--    - 驗證 booking_id 是否屬於傳入的 p_user_id。
--    - 驗證預約狀態是否為可取消的 '已預約'。
--    - 驗證課堂是否尚未開始。
-- 4. 操作:
--    - 將 bookings 資料表的 status 更新為 '已取消'。
--    - 將 classes 資料表的 current_students 減 1。
-- 5. 回傳: 回傳一個包含 status 和 message 的 JSON 物件。

CREATE OR REPLACE FUNCTION public.cancel_booking_atomic(p_booking_id text, p_user_id text)
RETURNS TABLE(status text, message text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_booking_info RECORD;
    v_class_info RECORD;
BEGIN
    -- 1. 檢查並鎖定預約紀錄，防止競爭條件
    SELECT * INTO v_booking_info
    FROM public.bookings
    WHERE booking_id = p_booking_id
    FOR UPDATE;

    -- 2. 執行多重驗證
    IF v_booking_info IS NULL THEN
        RETURN QUERY SELECT 'error'::TEXT, '找不到此預約紀錄。'::TEXT;
        RETURN;
    END IF;

    IF v_booking_info.line_user_id <> p_user_id THEN
        RETURN QUERY SELECT 'error'::TEXT, '您沒有權限取消此預約。'::TEXT;
        RETURN;
    END IF;

    IF v_booking_info.status <> '已預約' THEN
        RETURN QUERY SELECT 'error'::TEXT, '此預約狀態為「' || v_booking_info.status || '」，無法取消。'::TEXT;
        RETURN;
    END IF;

    -- 3. 檢查課堂時間是否已過
    SELECT * INTO v_class_info
    FROM public.classes
    WHERE class_id = v_booking_info.class_id;

    IF v_class_info IS NULL THEN
        RETURN QUERY SELECT 'error'::TEXT, '找不到對應的課堂資料。'::TEXT;
        RETURN;
    END IF;

    IF v_class_info.class_date < current_date OR (v_class_info.class_date = current_date AND v_class_info.start_time < current_time) THEN
        RETURN QUERY SELECT 'error'::TEXT, '此課程已開始或已結束，無法取消。'::TEXT;
        RETURN;
    END IF;

    -- 4. 執行更新操作
    -- 將預約狀態改為 '已取消'
    UPDATE public.bookings
    SET status = '已取消', update_time = NOW(), update_user = 'User'
    WHERE booking_id = p_booking_id;

    -- 將課堂目前人數減 1
    UPDATE public.classes
    SET current_students = current_students - 1
    WHERE class_id = v_booking_info.class_id AND current_students > 0;

    -- 5. 回傳成功訊息
    RETURN QUERY SELECT 'success'::TEXT, '您的預約已成功取消。'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        -- 如果發生任何未預期的錯誤，回傳通用錯誤訊息
        RETURN QUERY SELECT 'error'::TEXT, '處理取消時發生未預期錯誤: ' || SQLERRM;
END;
$$;
