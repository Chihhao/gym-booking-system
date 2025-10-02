-- 目的：一次性修復 save_coach 和 save_course 函式的 search_path 安全性警告。
-- 透過在函式定義中加入 `SET search_path = 'public'`，
-- 我們可以確保函式在執行時只會尋找 'public' schema 中的物件，
-- 從而防止惡意使用者透過操縱 search_path 來執行非預期的程式碼。

-- 修正 save_coach 函式
CREATE OR REPLACE FUNCTION public.save_coach(p_coach_id text, p_coach_name text, p_specialty text, p_line_id text, p_phone_number text, p_bio text, p_image_url text)
 RETURNS TABLE(status text, message text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
DECLARE
    v_new_coach_id TEXT;
    v_max_num INT;
BEGIN
    -- 檢查必要參數
    IF p_coach_name IS NULL OR p_coach_name = '' THEN
        RETURN QUERY SELECT 'error'::TEXT, '缺少必要的教練資訊 (姓名)。'::TEXT;
        RETURN;
    END IF;

    -- 判斷是新增還是更新
    IF p_coach_id IS NOT NULL AND p_coach_id <> '' THEN
        -- 更新模式
        UPDATE public.coaches
        SET
            coach_name = p_coach_name,
            specialty = p_specialty,
            line_id = p_line_id,
            phone_number = p_phone_number,
            bio = p_bio,
            image_url = p_image_url
        WHERE coach_id = p_coach_id;

        RETURN QUERY SELECT 'success'::TEXT, '教練資料更新成功！'::TEXT;
    ELSE
        -- 新增模式：產生新的 coach_id (格式 C001)
        SELECT COALESCE(MAX(SUBSTRING(c.coach_id FROM 2 FOR 3)::INT), 0)
        INTO v_max_num
        FROM public.coaches c
        WHERE c.coach_id LIKE 'C%';

        v_new_coach_id := 'C' || LPAD((v_max_num + 1)::TEXT, 3, '0');

        INSERT INTO public.coaches (coach_id, coach_name, specialty, line_id, phone_number, bio, image_url)
        VALUES (v_new_coach_id, p_coach_name, p_specialty, p_line_id, p_phone_number, p_bio, p_image_url);

        RETURN QUERY SELECT 'success'::TEXT, '教練新增成功！'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'error'::TEXT, '儲存教練資料時發生未預期錯誤: ' || SQLERRM;
END; $function$;

-- 修正 save_course 函式
CREATE OR REPLACE FUNCTION public.save_course(p_course_id text, p_course_name text, p_price text, p_status text, p_short_desc text, p_long_desc text, p_image_url text, p_color text)
 RETURNS TABLE(status text, message text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
DECLARE
    v_new_course_id TEXT;
    v_max_num INT;
BEGIN
    IF p_course_name IS NULL OR p_price IS NULL OR p_status IS NULL THEN
        RETURN QUERY SELECT 'error'::TEXT, '缺少必要的課程資訊 (名稱、價格、狀態)。'::TEXT;
        RETURN;
    END IF;

    IF p_course_id IS NOT NULL AND p_course_id <> '' THEN
        UPDATE public.courses SET course_name = p_course_name, price = p_price::numeric, status = p_status, short_description = p_short_desc, long_description = p_long_desc, image_url = p_image_url, color = p_color WHERE course_id = p_course_id;
        RETURN QUERY SELECT 'success'::TEXT, '課程型錄更新成功！'::TEXT;
    ELSE
        SELECT COALESCE(MAX(SUBSTRING(c.course_id FROM 4 FOR 3)::INT), 0) INTO v_max_num FROM public.courses c WHERE c.course_id LIKE 'CRS%';
        v_new_course_id := 'CRS' || LPAD((v_max_num + 1)::TEXT, 3, '0');
        INSERT INTO public.courses (course_id, course_name, price, status, short_description, long_description, image_url, color) VALUES (v_new_course_id, p_course_name, p_price::numeric, p_status, p_short_desc, p_long_desc, p_image_url, p_color);
        RETURN QUERY SELECT 'success'::TEXT, '課程型錄新增成功！'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'error'::TEXT, '儲存課程型錄時發生未預期錯誤: ' || SQLERRM;
END; $function$;