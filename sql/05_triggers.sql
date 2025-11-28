-- FUNCTION: public.course_search_vector_update()

CREATE OR REPLACE FUNCTION public.course_search_vector_update()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('simple', coalesce(NEW.title, '')), 'A') ||
        setweight(to_tsvector('simple', coalesce(NEW.description, '')), 'B');
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.course_search_vector_update()
    OWNER TO postgres;
-- FUNCTION: public.set_audit_fields()

CREATE OR REPLACE FUNCTION public.set_audit_fields()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN

    IF TG_OP = 'INSERT' THEN
        IF to_jsonb(NEW) ? 'created_at' THEN
            IF NEW.created_at IS NULL THEN
                NEW.created_at := NOW();
            END IF;
        END IF;
    END IF;

    IF to_jsonb(NEW) ? 'updated_at' THEN
        NEW.updated_at := NOW();
    END IF;

    IF to_jsonb(NEW) ? 'updated_by' THEN
        NEW.updated_by :=
            COALESCE(current_setting('app.current_user_id', true)::INT, NULL);
    END IF;

    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.set_audit_fields()
    OWNER TO postgres;
-- FUNCTION: public.soft_delete_row()

CREATE OR REPLACE FUNCTION public.soft_delete_row()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    -- UPDATE тієї ж таблиці замість фізичного DELETE
    EXECUTE format(
        'UPDATE %I.%I SET is_deleted = TRUE, deleted_at = NOW(), deleted_by = $1 WHERE id = $2',
        TG_TABLE_SCHEMA,
        TG_TABLE_NAME
    )
    USING COALESCE(current_setting('app.current_user_id', TRUE)::INT, NULL), OLD.id;

    RETURN NULL; 
END;
$BODY$;

ALTER FUNCTION public.soft_delete_row()
    OWNER TO postgres;
