--
-- PostgreSQL database dump
--

\restrict 2u2riUIijPrYI9YrNvzt1mjqlMIcuv7cs8aO5q1dU5aImkLt2Yv0NAEb4I6gcLT

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: create_booking_atomic(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_booking_atomic(p_class_id text, p_user_id text, p_display_name text) RETURNS TABLE(status text, message text, booking_id text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.create_booking_atomic(p_class_id text, p_user_id text, p_display_name text) OWNER TO postgres;

--
-- Name: delete_class(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_class(p_class_id text) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.delete_class(p_class_id text) OWNER TO postgres;

--
-- Name: delete_coach(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_coach(p_coach_id text) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.delete_coach(p_coach_id text) OWNER TO postgres;

--
-- Name: delete_course(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_course(p_course_id text) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.delete_course(p_course_id text) OWNER TO postgres;

--
-- Name: get_booking_details_for_user(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_booking_details_for_user(p_booking_id text, p_user_id text) RETURNS TABLE(booking_id text, status text, class_date date, start_time time without time zone, course_name text, coach_name text, line_display_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.get_booking_details_for_user(p_booking_id text, p_user_id text) OWNER TO postgres;

--
-- Name: get_class_details(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_class_details(p_class_id text) RETURNS TABLE(course_name text, class_date date, start_time time without time zone, coach_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.get_class_details(p_class_id text) OWNER TO postgres;

--
-- Name: get_manager_form_data(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_manager_form_data() RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.get_manager_form_data() OWNER TO postgres;

--
-- Name: get_user_bookings(text, text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[]) RETURNS TABLE(class_id text, booking_id text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[]) OWNER TO postgres;

--
-- Name: review_booking_atomic(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.review_booking_atomic(p_booking_id text, p_decision text) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.review_booking_atomic(p_booking_id text, p_decision text) OWNER TO postgres;

--
-- Name: save_class(text, text, text, text, text, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.save_class(p_class_id text, p_class_date text, p_start_time text, p_end_time text, p_course_id text, p_class_name text, p_coach_id text, p_max_students integer) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.save_class(p_class_id text, p_class_date text, p_start_time text, p_end_time text, p_course_id text, p_class_name text, p_coach_id text, p_max_students integer) OWNER TO postgres;

--
-- Name: save_coach(text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.save_coach(p_coach_id text, p_coach_name text, p_specialty text, p_line_id text, p_phone_number text, p_bio text, p_image_url text) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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
END; $$;


ALTER FUNCTION public.save_coach(p_coach_id text, p_coach_name text, p_specialty text, p_line_id text, p_phone_number text, p_bio text, p_image_url text) OWNER TO postgres;

--
-- Name: save_course(text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.save_course(p_course_id text, p_course_name text, p_price text, p_status text, p_short_desc text, p_long_desc text, p_image_url text, p_color text) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.save_course(p_course_id text, p_course_name text, p_price text, p_status text, p_short_desc text, p_long_desc text, p_image_url text, p_color text) OWNER TO postgres;

--
-- Name: search_bookings(text, date, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.search_bookings(p_status text DEFAULT NULL::text, p_class_date date DEFAULT NULL::date, p_query text DEFAULT NULL::text) RETURNS TABLE(booking_id text, booking_time timestamp with time zone, status text, class_name text, class_date date, start_time time without time zone, coach_name text, course_name text, color text, line_display_name text)
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.search_bookings(p_status text, p_class_date date, p_query text) OWNER TO postgres;

--
-- Name: update_user_points(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_user_points(p_user_id text, p_points integer) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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
END; $$;


ALTER FUNCTION public.update_user_points(p_user_id text, p_points integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bookings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bookings (
    booking_id text NOT NULL,
    class_id text NOT NULL,
    line_user_id text NOT NULL,
    booking_time timestamp with time zone DEFAULT now() NOT NULL,
    status text DEFAULT '已預約'::text NOT NULL,
    create_time timestamp with time zone DEFAULT now() NOT NULL,
    create_user text,
    update_time timestamp with time zone,
    update_user text
);


ALTER TABLE public.bookings OWNER TO postgres;

--
-- Name: TABLE bookings; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.bookings IS '儲存使用者的預約紀錄';


--
-- Name: classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.classes (
    class_id text NOT NULL,
    course_id text NOT NULL,
    coach_id text NOT NULL,
    class_name text NOT NULL,
    class_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone,
    max_students integer DEFAULT 1 NOT NULL,
    current_students integer DEFAULT 0 NOT NULL,
    status text DEFAULT '開放中'::text NOT NULL,
    points integer DEFAULT 0,
    create_time timestamp with time zone DEFAULT now() NOT NULL,
    create_user text,
    update_time timestamp with time zone,
    update_user text,
    CONSTRAINT students_check CHECK ((current_students <= max_students))
);


ALTER TABLE public.classes OWNER TO postgres;

--
-- Name: TABLE classes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.classes IS '儲存實際開設的課堂';


--
-- Name: coaches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coaches (
    coach_id text NOT NULL,
    coach_name text NOT NULL,
    specialty text,
    line_id text,
    phone_number text,
    bio text,
    image_url text
);


ALTER TABLE public.coaches OWNER TO postgres;

--
-- Name: TABLE coaches; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.coaches IS '儲存教練資訊';


--
-- Name: courses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.courses (
    course_id text NOT NULL,
    course_name text NOT NULL,
    short_description text,
    long_description text,
    image_url text,
    price numeric NOT NULL,
    status text DEFAULT 'Active'::text NOT NULL,
    color text DEFAULT '#64748b'::text
);


ALTER TABLE public.courses OWNER TO postgres;

--
-- Name: TABLE courses; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.courses IS '儲存課程型錄';


--
-- Name: classes_with_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.classes_with_details WITH (security_invoker='true') AS
 SELECT cls.class_id,
    cls.class_date,
    cls.start_time,
    cls.end_time,
    cls.class_name,
    cls.current_students,
    cls.max_students,
    cls.course_id,
    cls.coach_id,
    co.course_name,
    co.color,
    c.coach_name
   FROM ((public.classes cls
     LEFT JOIN public.courses co ON ((cls.course_id = co.course_id)))
     LEFT JOIN public.coaches c ON ((cls.coach_id = c.coach_id)));


ALTER VIEW public.classes_with_details OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    line_user_id text NOT NULL,
    line_display_name text,
    registration_date timestamp with time zone DEFAULT now() NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    line_id text,
    phone_number text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.users IS '儲存所有使用者資訊';


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bookings (booking_id, class_id, line_user_id, booking_time, status, create_time, create_user, update_time, update_user) FROM stdin;
BK20250900006	CL2509007	U_DEV_000000000000000000000000001	2025-09-23 13:40:07.798956+00	已取消	2025-09-23 13:40:07.798956+00	開發者AA	2025-09-23 13:42:27.328317+00	Admin
BK20250900005	CL2509006	U_DEV_000000000000000000000000001	2025-09-23 13:39:08.544581+00	已取消	2025-09-23 13:39:08.544581+00	開發者AA	2025-09-23 13:42:29.067261+00	Admin
BK20250900010	CL2509008	U_DEV_000000000000000000000000001	2025-09-23 13:45:48.606453+00	已取消	2025-09-23 13:45:48.606453+00	開發者AA	2025-09-23 13:46:07.651048+00	Admin
BK20250900009	CL2509007	U_DEV_000000000000000000000000001	2025-09-23 13:43:00.140772+00	已取消	2025-09-23 13:43:00.140772+00	開發者AA	2025-09-23 13:46:09.585641+00	Admin
BK20250900008	CL2509006	U_DEV_000000000000000000000000001	2025-09-23 13:42:35.577153+00	已取消	2025-09-23 13:42:35.577153+00	開發者AA	2025-09-23 13:46:11.361663+00	Admin
BK20250900012	CL2509007	U_DEV_000000000000000000000000001	2025-09-23 13:56:57.820041+00	已取消	2025-09-23 13:56:57.820041+00	開發者AA	2025-09-23 13:57:14.143364+00	Admin
BK20250900011	CL2509006	U_DEV_000000000000000000000000001	2025-09-23 13:56:21.895601+00	已取消	2025-09-23 13:56:21.895601+00	開發者AA	2025-09-23 13:57:16.072576+00	Admin
BK20250900014	CL2509004	U_DEV_000000000000000000000000001	2025-09-23 14:08:04.315277+00	已取消	2025-09-23 14:08:04.315277+00	開發者AA	2025-09-23 14:10:54.630029+00	Admin
BK20250900015	CL2509007	U_DEV_000000000000000000000000001	2025-09-23 14:10:41.442612+00	已取消	2025-09-23 14:10:41.442612+00	開發者AA	2025-09-23 14:10:56.86331+00	Admin
BK20250900013	CL2509006	U_DEV_000000000000000000000000001	2025-09-23 14:02:54.925206+00	已取消	2025-09-23 14:02:54.925206+00	開發者AA	2025-09-23 14:10:58.567974+00	Admin
BK20250900018	CL2509008	U_DEV_000000000000000000000000001	2025-09-23 14:16:07.917195+00	已取消	2025-09-23 14:16:07.917195+00	開發者AA	2025-09-23 14:17:33.113971+00	Admin
BK20250900017	CL2509007	U_DEV_000000000000000000000000001	2025-09-23 14:14:24.271417+00	已取消	2025-09-23 14:14:24.271417+00	開發者AA	2025-09-23 14:17:35.089655+00	Admin
BK20250900002	CL2509006	U_DEV_000000000000000000000000001	2025-09-23 13:29:41.191136+00	已取消	2025-09-23 13:29:41.191136+00	開發者AA	2025-09-23 13:33:36.143458+00	Admin
BK20250900001	CL2509003	U_DEV_000000000000000000000000001	2025-09-23 13:24:44.31395+00	已扣款	2025-09-23 13:24:44.31395+00	開發者AA	2025-09-23 13:33:40.096046+00	Admin
BK20250900004	CL2509008	U_DEV_000000000000000000000000001	2025-09-23 13:37:48.751937+00	已取消	2025-09-23 13:37:48.751937+00	開發者AA	2025-09-23 13:38:02.025106+00	Admin
BK20250900003	CL2509007	U_DEV_000000000000000000000000001	2025-09-23 13:37:34.439396+00	已取消	2025-09-23 13:37:34.439396+00	開發者AA	2025-09-23 13:38:04.016047+00	Admin
BK20250900007	CL2509008	U_DEV_000000000000000000000000001	2025-09-23 13:42:20.289856+00	已取消	2025-09-23 13:42:20.289856+00	開發者AA	2025-09-23 13:42:25.774133+00	Admin
BK20250900016	CL2509006	U_DEV_000000000000000000000000001	2025-09-23 14:12:25.860558+00	已取消	2025-09-23 14:12:25.860558+00	開發者AA	2025-09-23 14:17:36.320149+00	Admin
BK20250900020	CL2509008	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-23 14:18:30.006698+00	已扣款	2025-09-23 14:18:30.006698+00	志皓	2025-09-23 14:22:45.5098+00	Admin
BK20250900021	CL2509007	U_DEV_000000000000000000000000001	2025-09-23 14:22:27.387415+00	已取消	2025-09-23 14:22:27.387415+00	開發者AA	2025-09-23 14:22:47.938269+00	Admin
BK20250900019	CL2509006	U_DEV_000000000000000000000000001	2025-09-23 14:17:46.898665+00	已取消	2025-09-23 14:17:46.898665+00	開發者AA	2025-09-23 14:22:50.026574+00	Admin
BK20250900024	CL2509008	U_DEV_000000000000000000000000001	2025-09-23 14:38:22.283105+00	已取消	2025-09-23 14:38:22.283105+00	開發者AA	2025-09-23 14:38:42.154748+00	Admin
BK20250900023	CL2509007	U_DEV_000000000000000000000000001	2025-09-23 14:32:45.275142+00	已取消	2025-09-23 14:32:45.275142+00	開發者AA	2025-09-23 14:38:43.982575+00	Admin
BK20250900022	CL2509006	U_DEV_000000000000000000000000001	2025-09-23 14:32:10.699915+00	已取消	2025-09-23 14:32:10.699915+00	開發者AA	2025-09-23 14:38:45.67368+00	Admin
BK20250900030	CL2509012	U_DEV_000000000000000000000000001	2025-09-24 13:59:10.181511+00	已取消	2025-09-24 13:59:10.181511+00	開發者AA	2025-09-24 13:59:43.404359+00	Admin
BK20250900029	CL2509010	U_DEV_000000000000000000000000001	2025-09-24 13:56:48.492127+00	已取消	2025-09-24 13:56:48.492127+00	開發者AA	2025-09-24 13:59:45.315901+00	Admin
BK20250900028	CL2509011	U_DEV_000000000000000000000000001	2025-09-24 13:55:38.455352+00	已取消	2025-09-24 13:55:38.455352+00	開發者AA	2025-09-24 13:59:50.724606+00	Admin
BK20250900027	CL2509006	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-23 14:43:28.912855+00	已取消	2025-09-23 14:43:28.912855+00	志皓	2025-09-24 13:59:52.509064+00	Admin
BK20250900026	CL2509007	U_DEV_000000000000000000000000001	2025-09-23 14:40:45.551206+00	已取消	2025-09-23 14:40:45.551206+00	開發者AA	2025-09-24 13:59:53.996083+00	Admin
BK20250900025	CL2509008	U_DEV_000000000000000000000000001	2025-09-23 14:39:10.273581+00	已取消	2025-09-23 14:39:10.273581+00	開發者AA	2025-09-24 13:59:55.136132+00	Admin
BK20250900031	CL2509012	U_DEV_000000000000000000000000001	2025-09-24 14:01:06.271103+00	已扣款	2025-09-24 14:01:06.271103+00	開發者AA	2025-09-24 14:11:21.184965+00	Admin
BK20250900033	CL2509008	U_DEV_000000000000000000000000001	2025-09-26 13:30:23.231068+00	已取消	2025-09-26 13:30:23.231068+00	開發者AA	2025-09-26 13:30:39.375756+00	Admin
BK20250900032	CL2509007	U_DEV_000000000000000000000000001	2025-09-24 14:51:41.77283+00	已取消	2025-09-24 14:51:41.77283+00	開發者AA	2025-09-26 13:30:43.3982+00	Admin
BK20250900034	CL2509021	U_DEV_000000000000000000000000001	2025-09-26 13:31:00.08268+00	已取消	2025-09-26 13:31:00.08268+00	開發者AA	2025-09-26 13:32:41.564153+00	Admin
BK20250900037	CL2509016	U_DEV_000000000000000000000000001	2025-09-26 13:38:55.540034+00	已取消	2025-09-26 13:38:55.540034+00	開發者AA	2025-09-26 13:44:59.367166+00	Admin
BK20250900036	CL2509017	U_DEV_000000000000000000000000001	2025-09-26 13:35:08.181748+00	已取消	2025-09-26 13:35:08.181748+00	開發者AA	2025-09-26 13:45:01.530084+00	Admin
BK20250900035	CL2509008	U_DEV_000000000000000000000000001	2025-09-26 13:32:54.771878+00	已取消	2025-09-26 13:32:54.771878+00	開發者AA	2025-09-26 13:45:03.840904+00	Admin
BK20250900043	CL2509008	U_DEV_000000000000000000000000001	2025-09-27 00:54:06.832988+00	已取消	2025-09-27 00:54:06.832988+00	開發者AA	2025-09-27 00:54:27.92814+00	Admin
BK20250900041	CL2509023	U_DEV_000000000000000000000000001	2025-09-26 14:06:25.650143+00	已取消	2025-09-26 14:06:25.650143+00	開發者AA	2025-09-27 00:54:32.102675+00	Admin
BK20250900040	CL2509021	U_DEV_000000000000000000000000001	2025-09-26 14:02:55.851796+00	已取消	2025-09-26 14:02:55.851796+00	開發者AA	2025-09-27 00:54:33.714174+00	Admin
BK20250900039	CL2509022	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-26 13:56:50.268385+00	已取消	2025-09-26 13:56:50.268385+00	志皓	2025-09-27 00:54:36.473841+00	Admin
BK20250900038	CL2509022	U_DEV_000000000000000000000000001	2025-09-26 13:46:21.458051+00	已取消	2025-09-26 13:46:21.458051+00	開發者AA	2025-09-27 00:54:40.345769+00	Admin
BK20250900047	CL2510002	U_DEV_000000000000000000000000001	2025-09-27 03:28:11.398471+00	已取消	2025-09-27 03:28:11.398471+00	開發者AA	2025-09-27 03:28:25.037272+00	Admin
BK20250900046	CL2510001	U_DEV_000000000000000000000000001	2025-09-27 03:25:50.434571+00	已取消	2025-09-27 03:25:50.434571+00	開發者AA	2025-09-27 03:28:26.631992+00	Admin
BK20250900045	CL2509023	U_DEV_000000000000000000000000001	2025-09-27 01:13:25.157308+00	已取消	2025-09-27 01:13:25.157308+00	開發者AA	2025-09-27 03:28:27.937361+00	Admin
BK20250900044	CL2509022	U_DEV_000000000000000000000000001	2025-09-27 00:58:42.677249+00	已取消	2025-09-27 00:58:42.677249+00	開發者AA	2025-09-27 03:28:29.919455+00	Admin
BK20250900049	CL2509023	U_DEV_000000000000000000000000001	2025-09-27 03:46:06.059963+00	已取消	2025-09-27 03:46:06.059963+00	開發者AA	2025-09-27 04:02:15.672205+00	Admin
BK20250900054	CL2509022	U_DEV_000000000000000000000000001	2025-09-27 04:48:10.269157+00	已取消	2025-09-27 04:48:10.269157+00	開發者AA	2025-09-27 04:49:59.575636+00	Admin
BK20250900053	CL2509023	U_DEV_000000000000000000000000001	2025-09-27 04:45:24.945116+00	已取消	2025-09-27 04:45:24.945116+00	開發者AA	2025-09-27 04:50:00.991678+00	Admin
BK20250900052	CL2510002	U_DEV_000000000000000000000000001	2025-09-27 04:35:50.701672+00	已取消	2025-09-27 04:35:50.701672+00	開發者AA	2025-09-27 04:50:02.179669+00	Admin
BK20250900051	CL2510001	U_DEV_000000000000000000000000001	2025-09-27 04:04:52.452788+00	已取消	2025-09-27 04:04:52.452788+00	開發者AA	2025-09-27 04:50:03.477259+00	Admin
BK20250900055	CL2510001	U_DEV_000000000000000000000000001	2025-09-27 04:50:21.0741+00	已取消	2025-09-27 04:50:21.0741+00	開發者AA	2025-09-27 05:15:32.257219+00	Admin
BK20250900056	CL2509023	U_DEV_000000000000000000000000001	2025-09-27 05:15:22.527107+00	已取消	2025-09-27 05:15:22.527107+00	開發者AA	2025-09-27 05:15:33.85793+00	Admin
BK20250900062	CL2510001	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-27 08:20:28.80532+00	已扣款	2025-09-27 08:20:28.80532+00	志皓	2025-09-27 08:25:08.388951+00	Admin
BK20250900061	CL2509012	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-27 07:08:28.197683+00	已取消	2025-09-27 07:08:28.197683+00	志皓	2025-09-27 08:25:10.526936+00	Admin
BK20250900063	CL2510002	U_DEV_000000000000000000000000001	2025-09-27 08:24:45.957765+00	已取消	2025-09-27 08:24:45.957765+00	開發者AA	2025-09-27 08:25:12.188549+00	Admin
BK20250900059	CL2509022	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-27 06:13:20.301245+00	已取消	2025-09-27 06:13:20.301245+00	志皓	2025-09-27 08:25:15.345748+00	Admin
BK20250900058	CL2509023	U_DEV_000000000000000000000000001	2025-09-27 06:03:24.358092+00	已取消	2025-09-27 06:03:24.358092+00	開發者AA	2025-09-27 08:25:16.817063+00	Admin
BK20250900057	CL2509022	U_DEV_000000000000000000000000001	2025-09-27 05:38:51.883681+00	已取消	2025-09-27 05:38:51.883681+00	開發者AA	2025-09-27 08:25:18.248079+00	Admin
BK20250900067	CL2510002	U_DEV_000000000000000000000000001	2025-09-29 02:48:24.844761+00	已取消	2025-09-29 02:48:24.844761+00	開發者AA	2025-09-29 05:11:43.277331+00	Admin
BK20250900066	CL2510002	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-29 02:48:15.607446+00	已取消	2025-09-29 02:48:15.607446+00	志皓	2025-09-29 05:11:46.428407+00	Admin
BK20250900070	CL2510002	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-29 08:05:11.896955+00	已取消	2025-09-29 08:05:11.896955+00	志皓	2025-09-29 08:05:45.820031+00	Admin
BK20250900069	CL2509028	U_DEV_000000000000000000000000001	2025-09-29 07:12:54.532029+00	已取消	2025-09-29 07:12:54.532029+00	開發者AA	2025-09-29 08:05:48.534492+00	Admin
BK20250900068	CL2509022	U_DEV_000000000000000000000000001	2025-09-29 05:11:22.767336+00	已取消	2025-09-29 05:11:22.767336+00	開發者AA	2025-09-29 08:05:50.760555+00	Admin
BK20250900065	CL2510003	U_DEV_000000000000000000000000001	2025-09-28 14:25:09.096692+00	已取消	2025-09-28 14:25:09.096692+00	開發者AA	2025-09-29 08:05:52.613912+00	Admin
BK20250900073	CL2509026	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-29 11:43:57.09561+00	已取消	2025-09-29 11:43:57.09561+00	志皓	2025-09-29 11:44:09.992419+00	Admin
BK20250900072	CL2510002	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-29 08:36:08.999397+00	已取消	2025-09-29 08:36:08.999397+00	志皓	2025-09-29 11:44:16.932261+00	Admin
BK20250900071	CL2510002	U_DEV_000000000000000000000000001	2025-09-29 08:09:25.172613+00	已取消	2025-09-29 08:09:25.172613+00	開發者AA	2025-09-29 11:44:19.549964+00	Admin
BK20250900074	CL2510006	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-29 11:50:14.462131+00	已取消	2025-09-29 11:50:14.462131+00	志皓	2025-09-29 11:50:26.000971+00	Admin
BK20250900078	CL2510004	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-29 13:34:59.921839+00	已取消	2025-09-29 13:34:59.921839+00	志皓	2025-09-29 14:00:01.207902+00	Admin
BK20250900077	CL2510007	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-29 13:24:04.861446+00	已取消	2025-09-29 13:24:04.861446+00	志皓	2025-09-29 14:00:03.763667+00	Admin
BK20250900076	CL2510002	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-29 13:23:13.908544+00	已取消	2025-09-29 13:23:13.908544+00	志皓	2025-09-29 14:00:06.003224+00	Admin
BK20250900075	CL2510005	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-29 12:43:49.627723+00	已取消	2025-09-29 12:43:49.627723+00	志皓	2025-09-29 14:00:08.319058+00	Admin
BK20250900080	CL2510002	U_DEV_000000000000000000000000001	2025-09-30 14:29:54.630226+00	已取消	2025-09-30 14:29:54.630226+00	開發者AA	2025-10-02 11:55:07.993726+00	Admin
BK20250900079	CL2510007	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-30 04:14:54.963718+00	已取消	2025-09-30 04:14:54.963718+00	志皓	2025-10-02 11:55:10.125967+00	Admin
BK20251000001	CL2510002	U_DEV_000000000000000000000000001	2025-10-02 11:56:17.861606+00	已預約	2025-10-02 11:56:17.861606+00	開發者AA	\N	\N
\.


--
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.classes (class_id, course_id, coach_id, class_name, class_date, start_time, end_time, max_students, current_students, status, points, create_time, create_user, update_time, update_user) FROM stdin;
CL2509013	CRS005	C003	打狗棒法	2025-09-24	20:00:00	21:00:00	4	0	開放中	0	2025-09-24 13:39:49.561511+00	Admin	\N	\N
CL2509014	CRS005	C003	打狗棒法	2025-09-25	20:00:00	21:00:00	4	0	開放中	0	2025-09-24 13:39:57.556734+00	Admin	\N	\N
CL2509015	CRS005	C003	打狗棒法	2025-09-26	20:00:00	21:00:00	4	0	開放中	0	2025-09-24 13:40:05.150186+00	Admin	\N	\N
CL2509018	CRS003	C001	一對一教學	2025-09-25	15:00:00	16:00:00	1	0	開放中	0	2025-09-24 13:40:36.596034+00	Admin	\N	\N
CL2509019	CRS004	C003	秘密課程	2025-09-26	15:00:00	16:00:00	2	0	開放中	0	2025-09-24 13:40:46.722282+00	Admin	\N	\N
CL2509020	CRS003	C002	一對一教學	2025-09-26	10:00:00	11:00:00	1	0	開放中	0	2025-09-24 13:41:10.192425+00	Admin	\N	\N
CL2510007	CRS001	C001	龜派氣功	2025-10-03	16:00:00	17:00:00	4	0	開放中	0	2025-09-29 11:45:28.298284+00	Admin	2025-10-02 11:55:23.484165+00	Admin
CL2509012	CRS001	C001	龜派氣功	2025-09-27	17:00:00	18:00:00	4	1	開放中	0	2025-09-24 13:39:29.328059+00	Admin	\N	\N
CL2509010	CRS001	C001	龜派氣功	2025-09-25	17:00:00	18:00:00	4	0	開放中	0	2025-09-24 13:39:15.283335+00	Admin	\N	\N
CL2509011	CRS001	C001	龜派氣功	2025-09-26	17:00:00	18:00:00	4	0	開放中	0	2025-09-24 13:39:22.598645+00	Admin	\N	\N
CL2509016	CRS005	C003	打狗棒法	2025-09-27	20:00:00	21:00:00	4	0	開放中	0	2025-09-24 13:40:12.007341+00	Admin	\N	\N
CL2509017	CRS004	C002	秘密課程	2025-09-27	15:00:00	16:00:00	1	0	開放中	0	2025-09-24 13:40:25.501608+00	Admin	\N	\N
CL2509021	CRS003	C002	一對一教學	2025-09-27	10:00:00	11:00:00	1	0	開放中	0	2025-09-24 13:41:23.191958+00	Admin	\N	\N
CL2509025	CRS003	C004	一對一教學	2025-09-23	13:15:00	14:30:00	1	0	開放中	0	2025-09-27 10:45:19.165038+00	Admin	2025-09-27 14:26:36.893217+00	Admin
CL2510003	CRS005	C003	打狗棒法	2025-10-04	09:00:00	10:00:00	4	0	開放中	0	2025-09-27 12:42:22.50143+00	Admin	2025-10-02 11:55:31.241971+00	Admin
CL2510006	CRS001	C001	龜派氣功	2025-10-04	16:00:00	17:00:00	3	0	開放中	0	2025-09-29 11:45:15.596552+00	Admin	2025-10-02 11:55:35.684429+00	Admin
CL2509029	CRS003	C001	一對一教學	2025-10-03	17:00:00	18:00:00	1	0	開放中	0	2025-09-28 12:14:30.3151+00	Admin	2025-10-02 11:55:39.225466+00	Admin
CL2510008	CRS002	C002	夢遊仙境	2025-10-06	11:30:00	12:30:00	4	0	開放中	0	2025-10-02 12:17:55.4632+00	Admin	\N	\N
CL2510009	CRS002	C002	夢遊仙境	2025-10-07	11:30:00	12:30:00	4	0	開放中	0	2025-10-02 12:18:04.11639+00	Admin	2025-10-02 12:18:06.775616+00	Admin
CL2509027	CRS005	C003	打狗棒法	2025-10-04	10:00:00	11:00:00	4	0	開放中	0	2025-09-27 12:42:08.930363+00	Admin	2025-09-29 12:44:48.484781+00	Admin
CL2510004	CRS002	C002	夢遊仙境	2025-10-03	10:00:00	11:00:00	4	0	開放中	0	2025-09-27 13:54:20.777691+00	Admin	2025-09-28 12:50:59.557933+00	Admin
CL2510005	CRS002	C002	夢遊仙境	2025-10-03	14:00:00	15:00:00	4	0	開放中	0	2025-09-27 14:02:55.993118+00	Admin	2025-10-02 01:23:35.561971+00	Admin
CL2509028	CRS002	C002	夢遊仙境	2025-10-04	14:00:00	15:00:00	4	0	開放中	0	2025-09-27 12:43:13.2289+00	Admin	2025-10-02 11:55:26.480884+00	Admin
CL2509026	CRS003	C004	一對一教學	2025-10-04	17:00:00	18:30:00	1	0	開放中	0	2025-09-27 10:50:33.252674+00	Admin	2025-10-02 11:55:42.358131+00	Admin
CL2510002	CRS001	C001	龜派氣功	2025-10-04	12:00:00	13:00:00	4	1	開放中	0	2025-09-26 13:45:46.503152+00	Admin	2025-10-02 11:55:18.169031+00	Admin
CL2509022	CRS001	C001	龜派氣功	2025-10-03	09:00:00	10:00:00	4	0	開放中	0	2025-09-26 13:45:15.324884+00	Admin	2025-10-02 12:17:41.033627+00	Admin
CL2510010	CRS002	C002	夢遊仙境	2025-10-08	11:30:00	12:30:00	4	0	開放中	0	2025-10-02 12:18:14.136291+00	Admin	2025-10-02 12:18:16.038583+00	Admin
CL2510001	CRS001	C001	龜派氣功	2025-10-03	12:00:00	13:00:00	1	1	開放中	0	2025-09-26 13:45:37.596229+00	Admin	2025-09-29 12:45:03.735876+00	Admin
CL2509023	CRS001	C001	龜派氣功	2025-09-28	12:00:00	13:00:00	1	0	開放中	0	2025-09-26 13:45:23.041818+00	Admin	2025-09-29 12:45:09.397683+00	Admin
CL2509003	CRS002	C002	夢遊仙境	2025-09-24	11:00:00	12:00:00	5	1	開放中	0	2025-09-23 13:23:01.30018+00	Admin	2025-09-27 14:26:34.419118+00	Admin
CL2410002	CRS001	C001	下午的測試課	2024-10-01	14:00:00	15:30:00	5	0	開放中	0	2025-09-27 09:00:27.379804+00	Admin	\N	\N
CL2509006	CRS002	C002	夢遊仙境	2025-09-25	12:00:00	13:00:00	4	0	開放中	0	2025-09-23 13:24:20.478422+00	Admin	\N	\N
CL2509009	CRS005	C003	打狗棒法	2025-09-23	20:00:00	21:00:00	4	0	開放中	0	2025-09-23 13:29:24.619114+00	Admin	2025-09-27 13:09:05.020695+00	Admin
CL2509007	CRS002	C002	夢遊仙境	2025-09-26	12:00:00	13:00:00	4	0	開放中	0	2025-09-23 13:24:29.364747+00	Admin	\N	\N
CL2509005	CRS003	C003	一對一教學	2025-09-21	17:00:00	18:00:00	1	0	開放中	0	2025-09-23 13:23:45.351295+00	Admin	\N	\N
CL2509001	CRS002	C002	夢遊仙境	2025-09-23	09:00:00	10:15:00	4	0	開放中	0	2025-09-23 13:22:38.248425+00	Admin	2025-09-28 00:10:56.255866+00	Admin
CL2509008	CRS002	C002	夢遊仙境	2025-09-27	12:00:00	13:00:00	4	1	開放中	0	2025-09-23 13:24:37.676636+00	Admin	\N	\N
CL2509004	CRS001	C001	龜派氣功	2025-09-24	17:00:00	18:00:00	4	0	開放中	0	2025-09-23 13:23:28.73331+00	Admin	2025-09-23 13:32:48.552484+00	Admin
\.


--
-- Data for Name: coaches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.coaches (coach_id, coach_name, specialty, line_id, phone_number, bio, image_url) FROM stdin;
C002	艾莉絲	夢遊	alice_a	0955321123	皇家體育學院畢業	C002.png
C003	黃蓉	打狗棒法			洪七公首席弟子	C003.png
C004	虎哥	打毛線			很會打毛線	C004.png
C001	陳教練	龜派氣功	chen_c	0922123321	擁有 KAY GYM 國際級證照。帶你一起動茲動茲！	C001.png
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.courses (course_id, course_name, short_description, long_description, image_url, price, status, color) FROM stdin;
CRS003	一對一教學	享受頂級的個人化指導，讓專業教練為您客製化課程，高效達成健身目標。	在一對一的專屬教學環境中，您的所有需求與目標都將是我們關注的唯一焦點。這堂課提供最極致的客製化體驗，無論您的起點在哪裡、目標是什麼，我們的專業教練都將為您量身打造獨一無二的訓練計畫。課程內容包含：深度個人評估、客製化訓練內容、即時動作矯正與指導，以及彈性的時間安排。這不僅僅是一堂課，更是一項為您量身打造的投資。如果您希望以最高效率、最安全的方式達成目標，『一對一教學』將是您的最佳選擇。	CRS003.png	2000	Active	#3b82f6
CRS004	秘密課程	不可言喻的祕密任務		CRS004.png	9999	Active	#84cc16
CRS005	打狗棒法	丐幫絕學，天下第一棒法		CRS005.png	1000	Active	#eab308
CRS002	夢遊仙境	跟隨白兔先生，進入一場奇幻的伸展與放鬆之旅，找回身體的柔軟與心靈的平靜。	喝下「變小藥水」，穿過神秘的樹洞，歡迎來到『夢遊仙境』。這是一堂結合了流動瑜伽、深度伸展與冥想引導的沉浸式課程。我們將在充滿想像力的音樂與場景中，模仿柴郡貓的慵懶伸展、毛毛蟲的緩慢蠕動。這堂課旨在幫助您釋放身體的僵硬與壓力，提升柔軟度，並讓思緒從現實的煩惱中暫時抽離，如同愛麗絲般進行一場心靈的奇幻冒險。適合所有程度，特別是希望在運動中尋找創意與平靜的您。	CRS002.png	200	Active	#8b5cf6
CRS001	龜派氣功	凝聚宇宙能量，釋放你的潛能！一堂充滿力量與專注的核心訓練課。	源自經典的傳奇招式，『龜派氣功』課程將帶您體驗前所未有的能量集中與釋放。這堂課不僅僅是模仿動作，而是透過獨特的呼吸技巧與核心肌群訓練，教您如何凝聚身體內在的力量，並在瞬間爆發出來。課程將有效提升您的核心穩定性、身體協調性與爆發力，同時也是一個極佳的壓力釋放管道。無論您是資深粉絲還是尋求新穎訓練方式的健身愛好者，都能在這裡找到樂趣與挑戰。準備好，與我們一起大喊『KA-ME-HA-ME-HA』！	CRS001.png	1000	Active	#ef4444
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (line_user_id, line_display_name, registration_date, points, line_id, phone_number) FROM stdin;
U8b8c9f515de548d1627f62612e6b4f3a	志皓	2025-09-18 07:50:43.028+00	20000		
Ua0dc63b9e0cbe2d0fe5db273d19f3ce1	彭凱(Wally自由教練工作室)	2025-09-18 08:37:59.888+00	200000		
U_DEV_000000000000000000000000001	小明	2025-09-19 02:12:37.796+00	5001		
\.


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (booking_id);


--
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (class_id);


--
-- Name: coaches coaches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coaches
    ADD CONSTRAINT coaches_pkey PRIMARY KEY (coach_id);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (course_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (line_user_id);


--
-- Name: idx_bookings_class_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bookings_class_id ON public.bookings USING btree (class_id);


--
-- Name: idx_bookings_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bookings_user_id ON public.bookings USING btree (line_user_id);


--
-- Name: idx_classes_class_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classes_class_date ON public.classes USING btree (class_date);


--
-- Name: idx_classes_course_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classes_course_id ON public.classes USING btree (course_id);


--
-- Name: bookings bookings_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(class_id) ON DELETE CASCADE;


--
-- Name: bookings bookings_line_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_line_user_id_fkey FOREIGN KEY (line_user_id) REFERENCES public.users(line_user_id) ON DELETE CASCADE;


--
-- Name: classes classes_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_coach_id_fkey FOREIGN KEY (coach_id) REFERENCES public.coaches(coach_id) ON DELETE RESTRICT;


--
-- Name: classes classes_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(course_id) ON DELETE RESTRICT;


--
-- Name: bookings Allow admin full access on bookings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin full access on bookings" ON public.bookings TO authenticated USING ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))) WITH CHECK ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])));


--
-- Name: classes Allow admin full access on classes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin full access on classes" ON public.classes TO authenticated USING ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))) WITH CHECK ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])));


--
-- Name: coaches Allow admin full access on coaches; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin full access on coaches" ON public.coaches TO authenticated USING ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))) WITH CHECK ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])));


--
-- Name: courses Allow admin full access on courses; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin full access on courses" ON public.courses TO authenticated USING ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))) WITH CHECK ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])));


--
-- Name: users Allow admin full access on users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin full access on users" ON public.users TO authenticated USING ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))) WITH CHECK ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])));


--
-- Name: coaches Allow anonymous read access to all coaches; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow anonymous read access to all coaches" ON public.coaches FOR SELECT TO anon USING (true);


--
-- Name: courses Allow public read for active courses; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read for active courses" ON public.courses FOR SELECT USING ((status = 'Active'::text));


--
-- Name: classes Allow public read for available classes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read for available classes" ON public.classes FOR SELECT USING (((status = '開放中'::text) AND (class_date >= (now())::date)));


--
-- Name: bookings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

--
-- Name: classes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;

--
-- Name: coaches; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.coaches ENABLE ROW LEVEL SECURITY;

--
-- Name: courses; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: FUNCTION create_booking_atomic(p_class_id text, p_user_id text, p_display_name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_booking_atomic(p_class_id text, p_user_id text, p_display_name text) TO anon;
GRANT ALL ON FUNCTION public.create_booking_atomic(p_class_id text, p_user_id text, p_display_name text) TO authenticated;
GRANT ALL ON FUNCTION public.create_booking_atomic(p_class_id text, p_user_id text, p_display_name text) TO service_role;


--
-- Name: FUNCTION delete_class(p_class_id text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.delete_class(p_class_id text) TO anon;
GRANT ALL ON FUNCTION public.delete_class(p_class_id text) TO authenticated;
GRANT ALL ON FUNCTION public.delete_class(p_class_id text) TO service_role;


--
-- Name: FUNCTION delete_coach(p_coach_id text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.delete_coach(p_coach_id text) TO anon;
GRANT ALL ON FUNCTION public.delete_coach(p_coach_id text) TO authenticated;
GRANT ALL ON FUNCTION public.delete_coach(p_coach_id text) TO service_role;


--
-- Name: FUNCTION delete_course(p_course_id text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.delete_course(p_course_id text) TO anon;
GRANT ALL ON FUNCTION public.delete_course(p_course_id text) TO authenticated;
GRANT ALL ON FUNCTION public.delete_course(p_course_id text) TO service_role;


--
-- Name: FUNCTION get_booking_details_for_user(p_booking_id text, p_user_id text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_booking_details_for_user(p_booking_id text, p_user_id text) TO anon;
GRANT ALL ON FUNCTION public.get_booking_details_for_user(p_booking_id text, p_user_id text) TO authenticated;
GRANT ALL ON FUNCTION public.get_booking_details_for_user(p_booking_id text, p_user_id text) TO service_role;


--
-- Name: FUNCTION get_class_details(p_class_id text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_class_details(p_class_id text) TO anon;
GRANT ALL ON FUNCTION public.get_class_details(p_class_id text) TO authenticated;
GRANT ALL ON FUNCTION public.get_class_details(p_class_id text) TO service_role;


--
-- Name: FUNCTION get_manager_form_data(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_manager_form_data() TO anon;
GRANT ALL ON FUNCTION public.get_manager_form_data() TO authenticated;
GRANT ALL ON FUNCTION public.get_manager_form_data() TO service_role;


--
-- Name: FUNCTION get_user_bookings(p_user_id text, p_class_ids text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[]) TO anon;
GRANT ALL ON FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[]) TO authenticated;
GRANT ALL ON FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[]) TO service_role;


--
-- Name: FUNCTION review_booking_atomic(p_booking_id text, p_decision text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.review_booking_atomic(p_booking_id text, p_decision text) TO anon;
GRANT ALL ON FUNCTION public.review_booking_atomic(p_booking_id text, p_decision text) TO authenticated;
GRANT ALL ON FUNCTION public.review_booking_atomic(p_booking_id text, p_decision text) TO service_role;


--
-- Name: FUNCTION save_class(p_class_id text, p_class_date text, p_start_time text, p_end_time text, p_course_id text, p_class_name text, p_coach_id text, p_max_students integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.save_class(p_class_id text, p_class_date text, p_start_time text, p_end_time text, p_course_id text, p_class_name text, p_coach_id text, p_max_students integer) TO anon;
GRANT ALL ON FUNCTION public.save_class(p_class_id text, p_class_date text, p_start_time text, p_end_time text, p_course_id text, p_class_name text, p_coach_id text, p_max_students integer) TO authenticated;
GRANT ALL ON FUNCTION public.save_class(p_class_id text, p_class_date text, p_start_time text, p_end_time text, p_course_id text, p_class_name text, p_coach_id text, p_max_students integer) TO service_role;


--
-- Name: FUNCTION save_coach(p_coach_id text, p_coach_name text, p_specialty text, p_line_id text, p_phone_number text, p_bio text, p_image_url text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.save_coach(p_coach_id text, p_coach_name text, p_specialty text, p_line_id text, p_phone_number text, p_bio text, p_image_url text) TO anon;
GRANT ALL ON FUNCTION public.save_coach(p_coach_id text, p_coach_name text, p_specialty text, p_line_id text, p_phone_number text, p_bio text, p_image_url text) TO authenticated;
GRANT ALL ON FUNCTION public.save_coach(p_coach_id text, p_coach_name text, p_specialty text, p_line_id text, p_phone_number text, p_bio text, p_image_url text) TO service_role;


--
-- Name: FUNCTION save_course(p_course_id text, p_course_name text, p_price text, p_status text, p_short_desc text, p_long_desc text, p_image_url text, p_color text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.save_course(p_course_id text, p_course_name text, p_price text, p_status text, p_short_desc text, p_long_desc text, p_image_url text, p_color text) TO anon;
GRANT ALL ON FUNCTION public.save_course(p_course_id text, p_course_name text, p_price text, p_status text, p_short_desc text, p_long_desc text, p_image_url text, p_color text) TO authenticated;
GRANT ALL ON FUNCTION public.save_course(p_course_id text, p_course_name text, p_price text, p_status text, p_short_desc text, p_long_desc text, p_image_url text, p_color text) TO service_role;


--
-- Name: FUNCTION search_bookings(p_status text, p_class_date date, p_query text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.search_bookings(p_status text, p_class_date date, p_query text) TO anon;
GRANT ALL ON FUNCTION public.search_bookings(p_status text, p_class_date date, p_query text) TO authenticated;
GRANT ALL ON FUNCTION public.search_bookings(p_status text, p_class_date date, p_query text) TO service_role;


--
-- Name: FUNCTION update_user_points(p_user_id text, p_points integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_user_points(p_user_id text, p_points integer) TO anon;
GRANT ALL ON FUNCTION public.update_user_points(p_user_id text, p_points integer) TO authenticated;
GRANT ALL ON FUNCTION public.update_user_points(p_user_id text, p_points integer) TO service_role;


--
-- Name: TABLE bookings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.bookings TO anon;
GRANT ALL ON TABLE public.bookings TO authenticated;
GRANT ALL ON TABLE public.bookings TO service_role;


--
-- Name: TABLE classes; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.classes TO anon;
GRANT ALL ON TABLE public.classes TO authenticated;
GRANT ALL ON TABLE public.classes TO service_role;


--
-- Name: TABLE coaches; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.coaches TO anon;
GRANT ALL ON TABLE public.coaches TO authenticated;
GRANT ALL ON TABLE public.coaches TO service_role;


--
-- Name: TABLE courses; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.courses TO anon;
GRANT ALL ON TABLE public.courses TO authenticated;
GRANT ALL ON TABLE public.courses TO service_role;


--
-- Name: TABLE classes_with_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.classes_with_details TO anon;
GRANT ALL ON TABLE public.classes_with_details TO authenticated;
GRANT ALL ON TABLE public.classes_with_details TO service_role;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.users TO anon;
GRANT ALL ON TABLE public.users TO authenticated;
GRANT ALL ON TABLE public.users TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- PostgreSQL database dump complete
--

\unrestrict 2u2riUIijPrYI9YrNvzt1mjqlMIcuv7cs8aO5q1dU5aImkLt2Yv0NAEb4I6gcLT

