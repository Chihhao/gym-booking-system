-- 目的：修復 update_user_points 函式的 search_path 安全性警告。
-- 透過在函式定義中加入 `SET search_path = 'public'`，
-- 我們可以確保函式在執行時只會尋找 'public' schema 中的物件，
-- 從而防止惡意使用者透過操縱 search_path 來執行非預期的程式碼。

CREATE OR REPLACE FUNCTION public.update_user_points(p_user_id text, p_points integer)
 RETURNS TABLE(status text, message text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
BEGIN
    -- 檢查必要參數
    IF p_user_id IS NULL OR p_points IS NULL THEN
        RETURN QUERY SELECT 'error'::TEXT, '缺少使用者 ID 或點數。'::TEXT;
        RETURN;
    END IF;

    -- 執行更新
    UPDATE public.users
    SET points = p_points
    WHERE line_user_id = p_user_id;

    IF FOUND THEN
        RETURN QUERY SELECT 'success'::TEXT, '使用者點數更新成功！'::TEXT;
    ELSE
        RETURN QUERY SELECT 'error'::TEXT, '找不到要更新的使用者。'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'error'::TEXT, '更新使用者點數時發生未預期錯誤: ' || SQLERRM;
END; $function$;