-- 1. 為 coaches 資料表新增 bio 和 image_url 欄位 (修正版)
ALTER TABLE public.coaches
ADD COLUMN bio TEXT,
ADD COLUMN image_url TEXT;

-- 2. 更新 save_coach 函式以支援新欄位
-- 更新後的函式會接收 p_bio 和 p_image_url 參數
CREATE OR REPLACE FUNCTION public.save_coach(
    p_coach_id text, 
    p_coach_name text, 
    p_specialty text, 
    p_line_id text, 
    p_phone_number text,
    p_bio text, -- 新增
    p_image_url text -- 新增
)
RETURNS TABLE(status text, message text)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
            bio = p_bio, -- 新增
            image_url = p_image_url -- 新增
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
END;
$$;
