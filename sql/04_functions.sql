-- FUNCTION: public.fn_create_course(text, text, integer, integer)

CREATE OR REPLACE FUNCTION public.fn_create_course(
	p_title text,
	p_description text,
	p_category_id integer,
	p_creator_id integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO course(title, description, category_id, created_by)
    VALUES (p_title, p_description, p_category_id, p_creator_id)
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$BODY$;

ALTER FUNCTION public.fn_create_course(text, text, integer, integer)
    OWNER TO postgres;

-- FUNCTION: public.fn_enroll_student(integer, integer, integer)

CREATE OR REPLACE FUNCTION public.fn_enroll_student(
	p_course_id integer,
	p_student_id integer,
	p_actor_id integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_enrollment_id INT;
BEGIN
    -- Перевірка, що курс активний
    IF NOT EXISTS (
        SELECT 1 FROM course c
        WHERE c.id = p_course_id AND c.is_deleted = FALSE
    ) THEN
        RAISE EXCEPTION 'Course % not found or deleted', p_course_id;
    END IF;

    -- Якщо вже є запис – повертаємо існуючий
    SELECT id INTO v_enrollment_id
    FROM enrollment
    WHERE course_id = p_course_id AND student_id = p_student_id;

    IF v_enrollment_id IS NULL THEN
        INSERT INTO enrollment(course_id, student_id, enrolled_at, status, updated_by)
        VALUES (p_course_id, p_student_id, NOW(), 'enrolled', p_actor_id)
        RETURNING id INTO v_enrollment_id;
    END IF;

    RETURN v_enrollment_id;
END;
$BODY$;

ALTER FUNCTION public.fn_enroll_student(integer, integer, integer)
    OWNER TO postgres;

-- FUNCTION: public.fn_soft_delete_course(integer, integer)

CREATE OR REPLACE FUNCTION public.fn_soft_delete_course(
	p_course_id integer,
	p_actor_id integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    UPDATE course
    SET is_deleted = TRUE,
        deleted_at = NOW(),
        deleted_by = p_actor_id
    WHERE id = p_course_id
      AND is_deleted = FALSE;
END;
$BODY$;

ALTER FUNCTION public.fn_soft_delete_course(integer, integer)
    OWNER TO postgres;

-- FUNCTION: public.fn_soft_delete_lesson(integer, integer)

CREATE OR REPLACE FUNCTION public.fn_soft_delete_lesson(
	p_lesson_id integer,
	p_actor_id integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    UPDATE lesson
    SET is_deleted = TRUE,
        deleted_at = NOW(),
        deleted_by = p_actor_id
    WHERE id = p_lesson_id
      AND is_deleted = FALSE;
END;
$BODY$;

ALTER FUNCTION public.fn_soft_delete_lesson(integer, integer)
    OWNER TO postgres;

-- FUNCTION: public.fn_unenroll_student(integer, integer, integer)

CREATE OR REPLACE FUNCTION public.fn_unenroll_student(
	p_course_id integer,
	p_student_id integer,
	p_actor_id integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    UPDATE enrollment
    SET status = 'dropped',
        updated_at = NOW(),
        updated_by = p_actor_id
    WHERE course_id = p_course_id
      AND student_id = p_student_id;
END;
$BODY$;

ALTER FUNCTION public.fn_unenroll_student(integer, integer, integer)
    OWNER TO postgres;

-- FUNCTION: public.fn_update_submission_grade(integer, numeric, text, integer)

CREATE OR REPLACE FUNCTION public.fn_update_submission_grade(
	p_submission_id integer,
	p_score numeric,
	p_feedback text,
	p_grader_id integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_grade_id INT;
BEGIN
    IF EXISTS (SELECT 1 FROM grade WHERE submission_id = p_submission_id) THEN
        UPDATE grade
        SET score      = p_score,
            feedback   = p_feedback,
            updated_at = NOW(),
            updated_by = p_grader_id
        WHERE submission_id = p_submission_id
        RETURNING id INTO v_grade_id;
    ELSE
        INSERT INTO grade(submission_id, grader_id, score, feedback)
        VALUES (p_submission_id, p_grader_id, p_score, p_feedback)
        RETURNING id INTO v_grade_id;
    END IF;

    RETURN v_grade_id;
END;
$BODY$;

ALTER FUNCTION public.fn_update_submission_grade(integer, numeric, text, integer)
    OWNER TO postgres;


