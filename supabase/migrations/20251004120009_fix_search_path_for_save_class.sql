-- 目的：修復 save_class 函式的 search_path 安全性警告。
-- 透過在函式定義中加入 `SET search_path = 'public'`，
-- 我們可以確保函式在執行時只會尋找 'public' schema 中的物件，
-- 從而防止惡意使用者透過操縱 search_path 來執行非預期的程式碼。

CREATE OR REPLACE FUNCTION public.save_class(p_class_id text, p_class_date text, p_start_time text, p_end_time text, p_course_id text, p_class_name text, p_coach_id text, p_max_students integer)
 RETURNS TABLE(status text, message text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
DECLARE
    v_class_date_parsed DATE;
    v_start_time_parsed TIME;
    v_end_time_parsed TIME;
    v_new_class_id TEXT;
    v_id_prefix TEXT;
    v_max_num INT;
    v_overlap_count INT;
BEGIN
    -- 1. 檢查並解析參數
    IF p_class_date IS NULL OR p_start_time IS NULL OR p_end_time IS NULL OR p_course_id IS NULL OR p_class_name IS NULL OR p_coach_id IS NULL OR p_max_students IS NULL THEN
        RETURN QUERY SELECT 'error'::TEXT, '缺少必要的課堂資訊。'::TEXT;
        RETURN;
    END IF;

    v_class_date_parsed := p_class_date::DATE;
    v_start_time_parsed := p_start_time::TIME;
    v_end_time_parsed := p_end_time::TIME;

    -- 2. 時間重疊檢查 (核心邏輯)
    SELECT COUNT(*)
    INTO v_overlap_count
    FROM public.classes c
    WHERE
        c.coach_id = p_coach_id AND
        c.class_id <> COALESCE(p_class_id, '') AND -- 排除自己
        c.class_date = v_class_date_parsed AND
        (v_start_time_parsed, v_end_time_parsed) OVERLAPS (c.start_time, c.end_time);

    IF v_overlap_count > 0 THEN
        RETURN QUERY SELECT 'error'::TEXT, '儲存失敗：該時段與此教練的其他課堂重疊。'::TEXT;
        RETURN;
    END IF;

    -- 3. 判斷是新增還是更新
    IF p_class_id IS NOT NULL AND p_class_id <> '' THEN
        -- 更新模式
        UPDATE public.classes
        SET
            class_date = v_class_date_parsed,
            start_time = v_start_time_parsed,
            end_time = v_end_time_parsed,
            course_id = p_course_id,
            coach_id = p_coach_id,
            class_name = p_class_name,
            max_students = p_max_students,
            update_time = NOW(),
            update_user = 'Admin'
        WHERE class_id = p_class_id;
        RETURN QUERY SELECT 'success'::TEXT, '課堂更新成功！'::TEXT;
    ELSE
        -- 新增模式：產生新的 class_id (格式 CLYYMMXXX)
        v_id_prefix := 'CL' || to_char(v_class_date_parsed, 'YYMM');
        SELECT COALESCE(MAX(SUBSTRING(c.class_id FROM 7 FOR 3)::INT), 0)
        INTO v_max_num
        FROM public.classes c
        WHERE c.class_id LIKE v_id_prefix || '%';

        v_new_class_id := v_id_prefix || LPAD((v_max_num + 1)::TEXT, 3, '0');

        INSERT INTO public.classes (class_id, course_id, coach_id, class_name, class_date, start_time, end_time, max_students, current_students, status, create_time, create_user)
        VALUES (v_new_class_id, p_course_id, p_coach_id, p_class_name, v_class_date_parsed, v_start_time_parsed, v_end_time_parsed, p_max_students, 0, '開放中', NOW(), 'Admin');
        RETURN QUERY SELECT 'success'::TEXT, '課堂新增成功！'::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'error'::TEXT, '儲存課堂時發生未預期錯誤: ' || SQLERRM;
END; $function$;