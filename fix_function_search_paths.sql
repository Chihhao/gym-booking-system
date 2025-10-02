-- 目的：一次性修復所有函式的 search_path 安全性警告。
-- 透過在每個函式定義中加入 `SET search_path = 'public'`，
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

CREATE OR REPLACE FUNCTION public.get_booking_details_for_user(p_booking_id text, p_user_id text)
RETURNS TABLE (
    booking_id text,
    status text,
    class_date date,
    start_time time without time zone,
    course_name text,
    coach_name text,
    line_display_name text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public' -- 關鍵修正
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        b.booking_id, b.status, cl.class_date, cl.start_time,
        cr.course_name, co.coach_name, u.line_display_name
    FROM public.bookings b
    JOIN public.classes cl ON b.class_id = cl.class_id
    JOIN public.courses cr ON cl.course_id = cr.course_id
    JOIN public.coaches co ON cl.coach_id = co.coach_id
    JOIN public.users u ON b.line_user_id = u.line_user_id
    WHERE b.booking_id = p_booking_id AND b.line_user_id = p_user_id;
END; $function$;

CREATE OR REPLACE FUNCTION public.get_class_details(p_class_id text)
 RETURNS TABLE(course_name text, class_date date, start_time time without time zone, coach_name text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
BEGIN
  RETURN QUERY
  SELECT
    cr.course_name,
    cl.class_date,
    cl.start_time,
    co.coach_name
  FROM public.classes cl
  JOIN public.courses cr ON cl.course_id = cr.course_id
  JOIN public.coaches co ON cl.coach_id = co.coach_id
  WHERE cl.class_id = p_class_id;
END; $function$;

CREATE OR REPLACE FUNCTION public.get_manager_form_data()
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public' -- 關鍵修正
AS $function$
DECLARE
    courses_json JSON;
    coaches_json JSON;
BEGIN
    -- 查詢所有啟用的課程，並依照 course_id 排序
    SELECT json_agg(json_build_object('courseId', c.course_id, 'courseName', c.course_name) ORDER BY c.course_id)
    INTO courses_json
    FROM public.courses c
    WHERE c.status = 'Active';

    -- 查詢所有教練，並依照 coach_id 排序
    SELECT json_agg(json_build_object('coachId', ch.coach_id, 'coachName', ch.coach_name) ORDER BY ch.coach_id)
    INTO coaches_json
    FROM public.coaches ch;

    -- 組合回傳結果
    RETURN json_build_object(
        'status', 'success',
        'courses', COALESCE(courses_json, '[]'::json),
        'coaches', COALESCE(coaches_json, '[]'::json)
    );
END; $function$;

CREATE OR REPLACE FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[])
RETURNS TABLE(class_id text, booking_id text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public' -- 關鍵修正
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        b.class_id,
        b.booking_id
    FROM
        public.bookings b
    WHERE
        b.line_user_id = p_user_id
        AND b.class_id = ANY(p_class_ids)
        AND b.status IN ('已預約', '已扣款');
END; $function$;

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
        -- 決定為 'approve'，將狀態更新為 '已扣款'
        v_new_status := '已扣款';
        UPDATE public.bookings
        SET status = v_new_status, update_time = NOW(), update_user = 'Admin'
        WHERE booking_id = p_booking_id;

        RETURN QUERY SELECT 'success'::TEXT, '操作成功：已扣款'::TEXT;

    ELSIF p_decision = 'reject' THEN
        -- 決定為 'reject'，將狀態更新為 '已取消'
        v_new_status := '已取消';
        UPDATE public.bookings
        SET status = v_new_status, update_time = NOW(), update_user = 'Admin'
        WHERE booking_id = p_booking_id;

        -- 將對應課堂的學生人數減 1
        UPDATE public.classes
        SET current_students = current_students - 1
        WHERE class_id = v_booking_info.class_id AND current_students > 0; -- 確保人數不會變負數

        RETURN QUERY SELECT 'success'::TEXT, '操作成功：已取消'::TEXT;

    ELSE
        -- 無效的決定
        RETURN QUERY SELECT 'error'::TEXT, '無效的操作決定。'::TEXT;
        RETURN;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- 如果發生任何未預期的錯誤，回傳通用錯誤訊息
        RETURN QUERY SELECT 'error'::TEXT, '處理審核時發生未預期錯誤: ' || SQLERRM;
END; $function$;

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
END; $function$;

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
    -- 檢查必要參數
    IF p_course_name IS NULL OR p_price IS NULL OR p_status IS NULL THEN
        RETURN QUERY SELECT 'error'::TEXT, '缺少必要的課程資訊 (名稱、價格、狀態)。'::TEXT;
        RETURN;
    END IF;

    -- 判斷是新增還是更新
    IF p_course_id IS NOT NULL AND p_course_id <> '' THEN
        -- 更新模式
        UPDATE public.courses
        SET
            course_name = p_course_name,
            price = p_price::numeric, -- 建議：加回此型別轉換，確保資料一致性
            status = p_status,
            short_description = p_short_desc,
            long_description = p_long_desc,
            image_url = p_image_url,
            color = p_color
        WHERE course_id = p_course_id;

        RETURN QUERY SELECT 'success'::TEXT, '課程型錄更新成功！'::TEXT;
    ELSE
        -- 新增模式：產生新的 course_id
        SELECT COALESCE(MAX(SUBSTRING(c.course_id FROM 4 FOR 3)::INT), 0)
        INTO v_max_num
        FROM public.courses c
        WHERE c.course_id LIKE 'CRS%';

        v_new_course_id := 'CRS' || LPAD((v_max_num + 1)::TEXT, 3, '0');

        INSERT INTO public.courses (course_id, course_name, price, status, short_description, long_description, image_url, color)
        VALUES (v_new_course_id, p_course_name, p_price::numeric, p_status, p_short_desc, p_long_desc, p_image_url, p_color); -- 建議：加回此型別轉換

        RETURN QUERY SELECT 'success'::TEXT, '課程型錄新增成功！'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'error'::TEXT, '儲存課程型錄時發生未預期錯誤: ' || SQLERRM;
END; $function$;

CREATE OR REPLACE FUNCTION public.search_bookings(p_status text DEFAULT NULL::text, p_class_date date DEFAULT NULL::date, p_query text DEFAULT NULL::text)
 RETURNS TABLE(booking_id text, booking_time timestamp with time zone, status text, class_name text, class_date date, start_time time without time zone, coach_name text, course_name text, color text, line_display_name text)
 LANGUAGE plpgsql
 SET search_path TO 'public' -- 建議：雖然非 SECURITY DEFINER，但加上可增加程式碼的明確性和安全性
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