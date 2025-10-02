-- 目的：一次性修復 delete_coach 和 delete_course 函式的 search_path 安全性警告。
-- 透過在函式定義中加入 `SET search_path = 'public'`，
-- 我們可以確保函式在執行時只會尋找 'public' schema 中的物件，
-- 從而防止惡意使用者透過操縱 search_path 來執行非預期的程式碼。

-- 修正 delete_coach 函式
CREATE OR REPLACE FUNCTION public.delete_coach(p_coach_id text)
 RETURNS TABLE(status text, message text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
DECLARE
    v_class_count INT;
BEGIN
    IF p_coach_id IS NULL OR p_coach_id = '' THEN
        RETURN QUERY SELECT 'error'::TEXT, '缺少 coachId。'::TEXT;
        RETURN;
    END IF;

    -- 安全檢查：檢查是否有任何課堂(classes)正在使用此教練
    SELECT COUNT(*) INTO v_class_count
    FROM public.classes
    WHERE coach_id = p_coach_id;

    IF v_class_count > 0 THEN
        RETURN QUERY SELECT 'error'::TEXT, '無法刪除：此教練已被指派至某些課堂。請先將相關課堂的教練更換或刪除。'::TEXT;
        RETURN;
    END IF;

    -- 執行刪除
    DELETE FROM public.coaches WHERE coach_id = p_coach_id;

    IF FOUND THEN
        RETURN QUERY SELECT 'success'::TEXT, '教練刪除成功！'::TEXT;
    ELSE
        RETURN QUERY SELECT 'error'::TEXT, '找不到要刪除的教練。'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'error'::TEXT, '刪除教練時發生未預期錯誤: ' || SQLERRM;
END; $function$;

-- 修正 delete_course 函式
CREATE OR REPLACE FUNCTION public.delete_course(p_course_id text)
 RETURNS TABLE(status text, message text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
DECLARE
    v_class_count INT;
BEGIN
    IF p_course_id IS NULL OR p_course_id = '' THEN
        RETURN QUERY SELECT 'error'::TEXT, '缺少 courseId。'::TEXT;
        RETURN;
    END IF;

    -- 安全檢查：檢查是否有任何課堂(classes)正在使用此課程型錄
    SELECT COUNT(*) INTO v_class_count
    FROM public.classes
    WHERE course_id = p_course_id;

    IF v_class_count > 0 THEN
        RETURN QUERY SELECT 'error'::TEXT, '無法刪除：此課程型錄已被用於排課。請先刪除所有相關的課堂安排。'::TEXT;
        RETURN;
    END IF;

    -- 執行刪除
    DELETE FROM public.courses WHERE course_id = p_course_id;

    IF FOUND THEN
        RETURN QUERY SELECT 'success'::TEXT, '課程型錄刪除成功！'::TEXT;
    ELSE
        RETURN QUERY SELECT 'error'::TEXT, '找不到要刪除的課程型錄。'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'error'::TEXT, '刪除課程型錄時發生未預期錯誤: ' || SQLERRM;
END; $function$;