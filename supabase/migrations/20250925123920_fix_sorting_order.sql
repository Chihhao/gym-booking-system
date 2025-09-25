CREATE OR REPLACE FUNCTION "public"."get_manager_form_data"() RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
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
END;
$$;