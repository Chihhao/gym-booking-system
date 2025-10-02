-- 目的：修復 delete_class 函式的 search_path 安全性警告。
-- 透過在函式定義中加入 `SET search_path = 'public'`，
-- 我們可以確保函式在執行時只會尋找 'public' schema 中的物件，
-- 從而防止惡意使用者透過操縱 search_path 來執行非預期的程式碼。

CREATE OR REPLACE FUNCTION public.delete_class(p_class_id text)
 RETURNS TABLE(status text, message text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
DECLARE
    v_booking_count INT;
BEGIN
    IF p_class_id IS NULL OR p_class_id = '' THEN
        RETURN QUERY SELECT 'error'::TEXT, '缺少 classId。'::TEXT;
        RETURN;
    END IF;

    -- 安全檢查：檢查是否有任何有效預約 ('已預約', '已扣款')
    SELECT COUNT(*) INTO v_booking_count
    FROM public.bookings
    WHERE public.bookings.class_id = p_class_id AND public.bookings.status IN ('已預約', '已扣款');

    IF v_booking_count > 0 THEN
        RETURN QUERY SELECT 'error'::TEXT, '無法刪除：此課堂已有學員預約。請先將相關預約取消。'::TEXT;
        RETURN;
    END IF;

    -- 執行刪除
    DELETE FROM public.classes WHERE class_id = p_class_id;

    IF FOUND THEN
        RETURN QUERY SELECT 'success'::TEXT, '課堂刪除成功！'::TEXT;
    ELSE
        RETURN QUERY SELECT 'error'::TEXT, '找不到要刪除的課堂。'::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'error'::TEXT, '刪除課堂時發生未預期錯誤: ' || SQLERRM;
END; $function$;