-- View: public.v_assignment_results

CREATE OR REPLACE VIEW public.v_assignment_results
 AS
 SELECT a.id AS assignment_id,
    a.title AS assignment_title,
    s.id AS submission_id,
    su.full_name AS student_name,
    g.score,
    g.graded_at
   FROM assignment a
     LEFT JOIN submission s ON s.assignment_id = a.id
     LEFT JOIN grade g ON g.submission_id = s.id
     LEFT JOIN app_user su ON su.id = s.student_id
  WHERE a.is_deleted = false;

ALTER TABLE public.v_assignment_results
    OWNER TO postgres;

-- View: public.v_courses_active

CREATE OR REPLACE VIEW public.v_courses_active
 AS
 SELECT id,
    category_id,
    title,
    description,
    level,
    start_date,
    end_date,
    created_at,
    created_by,
    updated_at,
    updated_by,
    is_deleted,
    deleted_at,
    deleted_by,
    search_vector
   FROM course c
  WHERE is_deleted = false;

ALTER TABLE public.v_courses_active
    OWNER TO postgres;

-- View: public.v_enrollments_detailed

CREATE OR REPLACE VIEW public.v_enrollments_detailed
 AS
 SELECT e.id AS enrollment_id,
    c.id AS course_id,
    c.title AS course_title,
    u.id AS student_id,
    u.full_name AS student_name,
    e.status,
    e.enrolled_at,
    e.last_access_at
   FROM enrollment e
     JOIN course c ON c.id = e.course_id
     JOIN app_user u ON u.id = e.student_id
  WHERE c.is_deleted = false AND u.is_deleted = false;

ALTER TABLE public.v_enrollments_detailed
    OWNER TO postgres;

-- View: public.v_lessons_active

CREATE OR REPLACE VIEW public.v_lessons_active
 AS
 SELECT l.id,
    l.module_id,
    l.title,
    l.content,
    l.video_url,
    l.order_no,
    l.created_at,
    l.created_by,
    l.updated_at,
    l.updated_by,
    l.is_deleted,
    l.deleted_at,
    l.deleted_by,
    m.course_id
   FROM lesson l
     JOIN module m ON m.id = l.module_id
  WHERE l.is_deleted = false AND m.is_deleted = false;

ALTER TABLE public.v_lessons_active
    OWNER TO postgres;


