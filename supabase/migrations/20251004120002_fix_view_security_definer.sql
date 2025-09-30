-- 步驟 1: 重新定義 classes_with_details 視圖，移除 SECURITY DEFINER 屬性
-- 透過 ALTER VIEW ... SET (security_invoker = true)，明確指定其為安全的 SECURITY INVOKER 模式。
-- 這樣可以確保所有對此視圖的查詢都會遵循呼叫者自身的 RLS (Row Level Security) 政策。
CREATE OR REPLACE VIEW public.classes_with_details WITH (security_invoker = true) AS
SELECT
  cls.class_id,
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
FROM (
  (
    classes cls
    LEFT JOIN courses co ON ((cls.course_id = co.course_id))
  )
  LEFT JOIN coaches c ON ((cls.coach_id = c.coach_id))
);

-- 步驟 2: 建立一個新的、安全的 RPC 函式來取代前端直接查詢 View
-- 這個函式讓前端 (schedule.html) 在確認預約時，可以安全地取得單一課堂的詳細資訊。
-- 設定為 SECURITY DEFINER 是安全的，因為函式內部邏輯固定，只會回傳必要的公開資訊，且由 class_id 限制範圍。
CREATE OR REPLACE FUNCTION public.get_class_details (p_class_id text)
RETURNS TABLE (
  course_name text,
  class_date date,
  start_time time,
  coach_name text
)
LANGUAGE plpgsql
SECURITY DEFINER
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
END;
$$;
