-- Table: public.app_user

CREATE TABLE public.app_user
(
    id integer NOT NULL DEFAULT nextval('app_user_id_seq'::regclass),
    email character varying(255) COLLATE pg_catalog."default" NOT NULL,
    password_hash text COLLATE pg_catalog."default" NOT NULL,
    full_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by integer,
    updated_at timestamp with time zone,
    updated_by integer,
    is_deleted boolean NOT NULL DEFAULT false,
    deleted_at timestamp with time zone,
    deleted_by integer,
    CONSTRAINT app_user_pkey PRIMARY KEY (id),
    CONSTRAINT app_user_email_key UNIQUE (email),
    CONSTRAINT app_user_created_by_fkey FOREIGN KEY (created_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT app_user_deleted_by_fkey FOREIGN KEY (deleted_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT app_user_updated_by_fkey FOREIGN KEY (updated_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.app_user
    OWNER to postgres;
-- Table: public.assignment

-- DROP TABLE IF EXISTS public.assignment;

CREATE TABLE IF NOT EXISTS public.assignment
(
    id integer NOT NULL DEFAULT nextval('assignment_id_seq'::regclass),
    course_id integer NOT NULL,
    title character varying(255) COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    due_date timestamp with time zone,
    max_score numeric(5,2) NOT NULL DEFAULT 100,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by integer,
    updated_at timestamp with time zone,
    updated_by integer,
    is_deleted boolean NOT NULL DEFAULT false,
    deleted_at timestamp with time zone,
    deleted_by integer,
    CONSTRAINT assignment_pkey PRIMARY KEY (id),
    CONSTRAINT assignment_course_id_fkey FOREIGN KEY (course_id)
        REFERENCES public.course (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT assignment_created_by_fkey FOREIGN KEY (created_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT assignment_deleted_by_fkey FOREIGN KEY (deleted_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT assignment_updated_by_fkey FOREIGN KEY (updated_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.assignment
    OWNER to postgres;

-- Trigger: trg_assignment_audit

-- DROP TRIGGER IF EXISTS trg_assignment_audit ON public.assignment;

CREATE OR REPLACE TRIGGER trg_assignment_audit
    BEFORE INSERT OR UPDATE 
    ON public.assignment
    FOR EACH ROW
    EXECUTE FUNCTION public.set_audit_fields();

-- Trigger: trg_assignment_soft_delete

-- DROP TRIGGER IF EXISTS trg_assignment_soft_delete ON public.assignment;

CREATE OR REPLACE TRIGGER trg_assignment_soft_delete
    BEFORE DELETE
    ON public.assignment
    FOR EACH ROW
    EXECUTE FUNCTION public.soft_delete_row();
-- Table: public.attachment

-- DROP TABLE IF EXISTS public.attachment;

CREATE TABLE IF NOT EXISTS public.attachment
(
    id integer NOT NULL DEFAULT nextval('attachment_id_seq'::regclass),
    lesson_id integer NOT NULL,
    file_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    file_url text COLLATE pg_catalog."default" NOT NULL,
    file_type character varying(100) COLLATE pg_catalog."default",
    uploaded_at timestamp with time zone NOT NULL DEFAULT now(),
    uploaded_by integer,
    is_deleted boolean NOT NULL DEFAULT false,
    deleted_at timestamp with time zone,
    deleted_by integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT attachment_pkey PRIMARY KEY (id),
    CONSTRAINT attachment_deleted_by_fkey FOREIGN KEY (deleted_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT attachment_lesson_id_fkey FOREIGN KEY (lesson_id)
        REFERENCES public.lesson (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT attachment_uploaded_by_fkey FOREIGN KEY (uploaded_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.attachment
    OWNER to postgres;

-- Trigger: trg_attachment_audit

-- DROP TRIGGER IF EXISTS trg_attachment_audit ON public.attachment;

CREATE OR REPLACE TRIGGER trg_attachment_audit
    BEFORE INSERT OR UPDATE 
    ON public.attachment
    FOR EACH ROW
    EXECUTE FUNCTION public.set_audit_fields();

-- Trigger: trg_attachment_soft_delete

-- DROP TRIGGER IF EXISTS trg_attachment_soft_delete ON public.attachment;

CREATE OR REPLACE TRIGGER trg_attachment_soft_delete
    BEFORE DELETE
    ON public.attachment
    FOR EACH ROW
    EXECUTE FUNCTION public.soft_delete_row();
-- Table: public.comment

-- DROP TABLE IF EXISTS public.comment;

CREATE TABLE IF NOT EXISTS public.comment
(
    id integer NOT NULL DEFAULT nextval('comment_id_seq'::regclass),
    lesson_id integer NOT NULL,
    author_id integer NOT NULL,
    text text COLLATE pg_catalog."default" NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    updated_by integer,
    is_deleted boolean NOT NULL DEFAULT false,
    deleted_at timestamp with time zone,
    deleted_by integer,
    CONSTRAINT comment_pkey PRIMARY KEY (id),
    CONSTRAINT comment_author_id_fkey FOREIGN KEY (author_id)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT comment_deleted_by_fkey FOREIGN KEY (deleted_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT comment_lesson_id_fkey FOREIGN KEY (lesson_id)
        REFERENCES public.lesson (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT comment_updated_by_fkey FOREIGN KEY (updated_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.comment
    OWNER to postgres;

-- Trigger: trg_comment_audit

-- DROP TRIGGER IF EXISTS trg_comment_audit ON public.comment;

CREATE OR REPLACE TRIGGER trg_comment_audit
    BEFORE INSERT OR UPDATE 
    ON public.comment
    FOR EACH ROW
    EXECUTE FUNCTION public.set_audit_fields();

-- Trigger: trg_comment_soft_delete

-- DROP TRIGGER IF EXISTS trg_comment_soft_delete ON public.comment;

CREATE OR REPLACE TRIGGER trg_comment_soft_delete
    BEFORE DELETE
    ON public.comment
    FOR EACH ROW
    EXECUTE FUNCTION public.soft_delete_row();
-- Table: public.course

-- DROP TABLE IF EXISTS public.course;

CREATE TABLE IF NOT EXISTS public.course
(
    id integer NOT NULL DEFAULT nextval('course_id_seq'::regclass),
    category_id integer,
    title character varying(255) COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    level character varying(50) COLLATE pg_catalog."default",
    start_date date,
    end_date date,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by integer,
    updated_at timestamp with time zone,
    updated_by integer,
    is_deleted boolean NOT NULL DEFAULT false,
    deleted_at timestamp with time zone,
    deleted_by integer,
    search_vector tsvector,
    CONSTRAINT course_pkey PRIMARY KEY (id),
    CONSTRAINT course_category_id_fkey FOREIGN KEY (category_id)
        REFERENCES public.course_category (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT course_created_by_fkey FOREIGN KEY (created_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT course_deleted_by_fkey FOREIGN KEY (deleted_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT course_updated_by_fkey FOREIGN KEY (updated_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.course
    OWNER to postgres;
-- Index: idx_course_search

-- DROP INDEX IF EXISTS public.idx_course_search;

CREATE INDEX IF NOT EXISTS idx_course_search
    ON public.course USING gin
    (search_vector)
    WITH (fastupdate=True, gin_pending_list_limit=4194304)
    TABLESPACE pg_default;

-- Trigger: trg_course_audit

-- DROP TRIGGER IF EXISTS trg_course_audit ON public.course;

CREATE OR REPLACE TRIGGER trg_course_audit
    BEFORE INSERT OR UPDATE 
    ON public.course
    FOR EACH ROW
    EXECUTE FUNCTION public.set_audit_fields();

-- Trigger: trg_course_search_vector

-- DROP TRIGGER IF EXISTS trg_course_search_vector ON public.course;

CREATE OR REPLACE TRIGGER trg_course_search_vector
    BEFORE INSERT OR UPDATE 
    ON public.course
    FOR EACH ROW
    EXECUTE FUNCTION public.course_search_vector_update();

-- Trigger: trg_course_soft_delete

-- DROP TRIGGER IF EXISTS trg_course_soft_delete ON public.course;

CREATE OR REPLACE TRIGGER trg_course_soft_delete
    BEFORE DELETE
    ON public.course
    FOR EACH ROW
    EXECUTE FUNCTION public.soft_delete_row();
-- Table: public.course_category

-- DROP TABLE IF EXISTS public.course_category;

CREATE TABLE IF NOT EXISTS public.course_category
(
    id integer NOT NULL DEFAULT nextval('course_category_id_seq'::regclass),
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    CONSTRAINT course_category_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.course_category
    OWNER to postgres;
-- Table: public.course_instructor

-- DROP TABLE IF EXISTS public.course_instructor;

CREATE TABLE IF NOT EXISTS public.course_instructor
(
    course_id integer NOT NULL,
    user_id integer NOT NULL,
    CONSTRAINT course_instructor_pkey PRIMARY KEY (course_id, user_id),
    CONSTRAINT course_instructor_course_id_fkey FOREIGN KEY (course_id)
        REFERENCES public.course (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT course_instructor_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.course_instructor
    OWNER to postgres;
-- Table: public.enrollment

-- DROP TABLE IF EXISTS public.enrollment;

CREATE TABLE IF NOT EXISTS public.enrollment
(
    id integer NOT NULL DEFAULT nextval('enrollment_id_seq'::regclass),
    course_id integer NOT NULL,
    student_id integer NOT NULL,
    enrolled_at timestamp with time zone NOT NULL DEFAULT now(),
    status character varying(20) COLLATE pg_catalog."default" NOT NULL DEFAULT 'enrolled'::character varying,
    last_access_at timestamp with time zone,
    updated_at timestamp with time zone,
    updated_by integer,
    CONSTRAINT enrollment_pkey PRIMARY KEY (id),
    CONSTRAINT uq_enrollment UNIQUE (course_id, student_id),
    CONSTRAINT enrollment_course_id_fkey FOREIGN KEY (course_id)
        REFERENCES public.course (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT enrollment_student_id_fkey FOREIGN KEY (student_id)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT enrollment_updated_by_fkey FOREIGN KEY (updated_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.enrollment
    OWNER to postgres;
-- Index: idx_enrollment_student_course

-- DROP INDEX IF EXISTS public.idx_enrollment_student_course;

CREATE INDEX IF NOT EXISTS idx_enrollment_student_course
    ON public.enrollment USING btree
    (student_id ASC NULLS LAST, course_id ASC NULLS LAST)
    WITH (fillfactor=100, deduplicate_items=True)
    TABLESPACE pg_default;
-- Table: public.grade

-- DROP TABLE IF EXISTS public.grade;

CREATE TABLE IF NOT EXISTS public.grade
(
    id integer NOT NULL DEFAULT nextval('grade_id_seq'::regclass),
    submission_id integer NOT NULL,
    grader_id integer NOT NULL,
    score numeric(5,2) NOT NULL,
    graded_at timestamp with time zone NOT NULL DEFAULT now(),
    feedback text COLLATE pg_catalog."default",
    updated_at timestamp with time zone,
    updated_by integer,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT grade_pkey PRIMARY KEY (id),
    CONSTRAINT grade_submission_id_key UNIQUE (submission_id),
    CONSTRAINT grade_grader_id_fkey FOREIGN KEY (grader_id)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT grade_submission_id_fkey FOREIGN KEY (submission_id)
        REFERENCES public.submission (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT grade_updated_by_fkey FOREIGN KEY (updated_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.grade
    OWNER to postgres;

-- Trigger: trg_grade_audit

-- DROP TRIGGER IF EXISTS trg_grade_audit ON public.grade;

CREATE OR REPLACE TRIGGER trg_grade_audit
    BEFORE INSERT OR UPDATE 
    ON public.grade
    FOR EACH ROW
    EXECUTE FUNCTION public.set_audit_fields();
-- Table: public.lesson

-- DROP TABLE IF EXISTS public.lesson;

CREATE TABLE IF NOT EXISTS public.lesson
(
    id integer NOT NULL DEFAULT nextval('lesson_id_seq'::regclass),
    module_id integer NOT NULL,
    title character varying(255) COLLATE pg_catalog."default" NOT NULL,
    content text COLLATE pg_catalog."default",
    video_url text COLLATE pg_catalog."default",
    order_no integer NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by integer,
    updated_at timestamp with time zone,
    updated_by integer,
    is_deleted boolean NOT NULL DEFAULT false,
    deleted_at timestamp with time zone,
    deleted_by integer,
    CONSTRAINT lesson_pkey PRIMARY KEY (id),
    CONSTRAINT lesson_created_by_fkey FOREIGN KEY (created_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lesson_deleted_by_fkey FOREIGN KEY (deleted_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lesson_module_id_fkey FOREIGN KEY (module_id)
        REFERENCES public.module (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT lesson_updated_by_fkey FOREIGN KEY (updated_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.lesson
    OWNER to postgres;

-- Trigger: trg_lesson_audit

-- DROP TRIGGER IF EXISTS trg_lesson_audit ON public.lesson;

CREATE OR REPLACE TRIGGER trg_lesson_audit
    BEFORE INSERT OR UPDATE 
    ON public.lesson
    FOR EACH ROW
    EXECUTE FUNCTION public.set_audit_fields();

-- Trigger: trg_lesson_soft_delete

-- DROP TRIGGER IF EXISTS trg_lesson_soft_delete ON public.lesson;

CREATE OR REPLACE TRIGGER trg_lesson_soft_delete
    BEFORE DELETE
    ON public.lesson
    FOR EACH ROW
    EXECUTE FUNCTION public.soft_delete_row();
-- Table: public.module

-- DROP TABLE IF EXISTS public.module;

CREATE TABLE IF NOT EXISTS public.module
(
    id integer NOT NULL DEFAULT nextval('module_id_seq'::regclass),
    course_id integer NOT NULL,
    title character varying(255) COLLATE pg_catalog."default" NOT NULL,
    order_no integer NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by integer,
    updated_at timestamp with time zone,
    updated_by integer,
    is_deleted boolean NOT NULL DEFAULT false,
    deleted_at timestamp with time zone,
    deleted_by integer,
    CONSTRAINT module_pkey PRIMARY KEY (id),
    CONSTRAINT module_course_id_fkey FOREIGN KEY (course_id)
        REFERENCES public.course (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT module_created_by_fkey FOREIGN KEY (created_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT module_deleted_by_fkey FOREIGN KEY (deleted_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT module_updated_by_fkey FOREIGN KEY (updated_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.module
    OWNER to postgres;

-- Trigger: trg_module_audit

-- DROP TRIGGER IF EXISTS trg_module_audit ON public.module;

CREATE OR REPLACE TRIGGER trg_module_audit
    BEFORE INSERT OR UPDATE 
    ON public.module
    FOR EACH ROW
    EXECUTE FUNCTION public.set_audit_fields();

-- Trigger: trg_module_soft_delete

-- DROP TRIGGER IF EXISTS trg_module_soft_delete ON public.module;

CREATE OR REPLACE TRIGGER trg_module_soft_delete
    BEFORE DELETE
    ON public.module
    FOR EACH ROW
    EXECUTE FUNCTION public.soft_delete_row();
-- Table: public.notification

-- DROP TABLE IF EXISTS public.notification;

CREATE TABLE IF NOT EXISTS public.notification
(
    id integer NOT NULL DEFAULT nextval('notification_id_seq'::regclass),
    user_id integer NOT NULL,
    title character varying(255) COLLATE pg_catalog."default" NOT NULL,
    body text COLLATE pg_catalog."default" NOT NULL,
    notif_type character varying(50) COLLATE pg_catalog."default",
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    read_at timestamp with time zone,
    CONSTRAINT notification_pkey PRIMARY KEY (id),
    CONSTRAINT notification_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.notification
    OWNER to postgres;
-- Table: public.role

-- DROP TABLE IF EXISTS public.role;

CREATE TABLE IF NOT EXISTS public.role
(
    id integer NOT NULL DEFAULT nextval('role_id_seq'::regclass),
    name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    CONSTRAINT role_pkey PRIMARY KEY (id),
    CONSTRAINT role_name_key UNIQUE (name)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.role
    OWNER to postgres;
-- Table: public.submission

-- DROP TABLE IF EXISTS public.submission;

CREATE TABLE IF NOT EXISTS public.submission
(
    id integer NOT NULL DEFAULT nextval('submission_id_seq'::regclass),
    assignment_id integer NOT NULL,
    student_id integer NOT NULL,
    submitted_at timestamp with time zone NOT NULL DEFAULT now(),
    content text COLLATE pg_catalog."default",
    file_url text COLLATE pg_catalog."default",
    updated_at timestamp with time zone,
    updated_by integer,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT submission_pkey PRIMARY KEY (id),
    CONSTRAINT uq_submission UNIQUE (assignment_id, student_id),
    CONSTRAINT submission_assignment_id_fkey FOREIGN KEY (assignment_id)
        REFERENCES public.assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT submission_student_id_fkey FOREIGN KEY (student_id)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT submission_updated_by_fkey FOREIGN KEY (updated_by)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.submission
    OWNER to postgres;

-- Trigger: trg_submission_audit

-- DROP TRIGGER IF EXISTS trg_submission_audit ON public.submission;

CREATE OR REPLACE TRIGGER trg_submission_audit
    BEFORE INSERT OR UPDATE 
    ON public.submission
    FOR EACH ROW
    EXECUTE FUNCTION public.set_audit_fields();
-- Table: public.user_role

-- DROP TABLE IF EXISTS public.user_role;

CREATE TABLE IF NOT EXISTS public.user_role
(
    user_id integer NOT NULL,
    role_id integer NOT NULL,
    CONSTRAINT user_role_pkey PRIMARY KEY (user_id, role_id),
    CONSTRAINT user_role_role_id_fkey FOREIGN KEY (role_id)
        REFERENCES public.role (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT user_role_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.app_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_role
    OWNER to postgres;
