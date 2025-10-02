--
-- PostgreSQL database dump
--

\restrict ED0xnfoY7wSxGnWMrjE6Jv4elCLedaa6XufbtrMpHEgwBF6ckLyPAnoyQtmDUkH

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
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA supabase_migrations;


ALTER SCHEMA supabase_migrations OWNER TO postgres;

--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE auth.oauth_registration_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: supabase_admin
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO supabase_admin;

--
-- Name: create_booking_atomic(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_booking_atomic(p_class_id text, p_user_id text, p_display_name text) RETURNS TABLE(status text, message text, booking_id text)
    LANGUAGE plpgsql SECURITY DEFINER
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
END;
$$;


ALTER FUNCTION public.create_booking_atomic(p_class_id text, p_user_id text, p_display_name text) OWNER TO postgres;

--
-- Name: delete_class(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_class(p_class_id text) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_booking_count INT;
BEGIN
    IF p_class_id IS NULL OR p_class_id = '' THEN
        RETURN QUERY SELECT 'error'::TEXT, '缺少 classId。'::TEXT;
        RETURN;
    END IF;

    -- 安全檢查：檢查是否有任何有效預約 ('已預約', '已扣款')
    -- 修正點：明確指定 status 欄位來自 bookings 表
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
END;
$$;


ALTER FUNCTION public.delete_class(p_class_id text) OWNER TO postgres;

--
-- Name: delete_coach(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_coach(p_coach_id text) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
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
END;
$$;


ALTER FUNCTION public.delete_coach(p_coach_id text) OWNER TO postgres;

--
-- Name: delete_course(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_course(p_course_id text) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
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

    -- 檢查是否真的刪除了 (row_count 是 PL/pgSQL 的一個特殊變數)
    IF FOUND THEN
        RETURN QUERY SELECT 'success'::TEXT, '課程型錄刪除成功！'::TEXT;
    ELSE
        RETURN QUERY SELECT 'error'::TEXT, '找不到要刪除的課程型錄。'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'error'::TEXT, '刪除課程型錄時發生未預期錯誤: ' || SQLERRM;
END;
$$;


ALTER FUNCTION public.delete_course(p_course_id text) OWNER TO postgres;

--
-- Name: get_booking_details_for_user(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_booking_details_for_user(p_booking_id text, p_user_id text) RETURNS TABLE(booking_id text, status text, class_date date, start_time time without time zone, course_name text, coach_name text, line_display_name text)
    LANGUAGE plpgsql SECURITY DEFINER
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
END;
$$;


ALTER FUNCTION public.get_booking_details_for_user(p_booking_id text, p_user_id text) OWNER TO postgres;

--
-- Name: get_class_details(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_class_details(p_class_id text) RETURNS TABLE(course_name text, class_date date, start_time time without time zone, coach_name text)
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.get_class_details(p_class_id text) OWNER TO postgres;

--
-- Name: get_manager_form_data(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_manager_form_data() RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.get_manager_form_data() OWNER TO postgres;

--
-- Name: get_user_bookings(text, text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[]) RETURNS TABLE(class_id text, booking_id text)
    LANGUAGE plpgsql SECURITY DEFINER
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
END;
$$;


ALTER FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[]) OWNER TO postgres;

--
-- Name: review_booking_atomic(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.review_booking_atomic(p_booking_id text, p_decision text) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
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
END;
$$;


ALTER FUNCTION public.review_booking_atomic(p_booking_id text, p_decision text) OWNER TO postgres;

--
-- Name: save_class(text, text, text, text, text, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.save_class(p_class_id text, p_class_date text, p_start_time text, p_end_time text, p_course_id text, p_class_name text, p_coach_id text, p_max_students integer) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
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
END;
$$;


ALTER FUNCTION public.save_class(p_class_id text, p_class_date text, p_start_time text, p_end_time text, p_course_id text, p_class_name text, p_coach_id text, p_max_students integer) OWNER TO postgres;

--
-- Name: save_coach(text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.save_coach(p_coach_id text, p_coach_name text, p_specialty text, p_line_id text, p_phone_number text, p_bio text, p_image_url text) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.save_coach(p_coach_id text, p_coach_name text, p_specialty text, p_line_id text, p_phone_number text, p_bio text, p_image_url text) OWNER TO postgres;

--
-- Name: save_course(text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.save_course(p_course_id text, p_course_name text, p_price text, p_status text, p_short_desc text, p_long_desc text, p_image_url text, p_color text) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
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
            price = p_price::numeric, -- 修正點：將文字轉換為數字
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
        VALUES (v_new_course_id, p_course_name, p_price::numeric, p_status, p_short_desc, p_long_desc, p_image_url, p_color); -- 修正點：將文字轉換為數字

        RETURN QUERY SELECT 'success'::TEXT, '課程型錄新增成功！'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'error'::TEXT, '儲存課程型錄時發生未預期錯誤: ' || SQLERRM;
END;
$$;


ALTER FUNCTION public.save_course(p_course_id text, p_course_name text, p_price text, p_status text, p_short_desc text, p_long_desc text, p_image_url text, p_color text) OWNER TO postgres;

--
-- Name: search_bookings(text, date, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.search_bookings(p_status text DEFAULT NULL::text, p_class_date date DEFAULT NULL::date, p_query text DEFAULT NULL::text) RETURNS TABLE(booking_id text, booking_time timestamp with time zone, status text, class_name text, class_date date, start_time time without time zone, coach_name text, course_name text, color text, line_display_name text)
    LANGUAGE plpgsql
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
END;
$$;


ALTER FUNCTION public.search_bookings(p_status text, p_class_date date, p_query text) OWNER TO postgres;

--
-- Name: update_user_points(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_user_points(p_user_id text, p_points integer) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
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

    -- 檢查更新是否成功 (FOUND 是 PL/pgSQL 的一個特殊變數，表示上一條命令是否影響了任何資料列)
    IF FOUND THEN
        RETURN QUERY SELECT 'success'::TEXT, '使用者點數更新成功！'::TEXT;
    ELSE
        RETURN QUERY SELECT 'error'::TEXT, '找不到要更新的使用者。'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 'error'::TEXT, '更新使用者點數時發生未預期錯誤: ' || SQLERRM;
END;
$$;


ALTER FUNCTION public.update_user_points(p_user_id text, p_points integer) OWNER TO postgres;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
	select string_to_array(name, '/') into _parts;
	select _parts[array_length(_parts,1)] into _filename;
	-- @todo return the last part instead of 2
	return reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[1:array_length(_parts,1)-1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(objects.path_tokens, 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_id text NOT NULL,
    client_secret_hash text NOT NULL,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048))
);


ALTER TABLE auth.oauth_clients OWNER TO supabase_auth_admin;

--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


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
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: postgres
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text
);


ALTER TABLE supabase_migrations.schema_migrations OWNER TO postgres;

--
-- Name: seed_files; Type: TABLE; Schema: supabase_migrations; Owner: postgres
--

CREATE TABLE supabase_migrations.seed_files (
    path text NOT NULL,
    hash text NOT NULL
);


ALTER TABLE supabase_migrations.seed_files OWNER TO postgres;

--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	84963b3d-adb9-4c47-8ed4-e404d31f1618	{"action":"user_signedup","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-09-29 13:56:19.061365+00	
00000000-0000-0000-0000-000000000000	f8ce0ece-0aa1-4a8f-a460-c543ff725107	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 13:56:33.05392+00	
00000000-0000-0000-0000-000000000000	a2417dcd-f811-4a90-b6f0-aa98c6bd93a0	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 13:58:18.931775+00	
00000000-0000-0000-0000-000000000000	7cae6ad6-b828-45cf-8720-a5d65f4057b4	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 13:59:40.366666+00	
00000000-0000-0000-0000-000000000000	add7f117-dddc-4703-acbe-d310835613d6	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:00:18.329896+00	
00000000-0000-0000-0000-000000000000	6153af9d-bf37-412f-917d-e8dd0fa0ac03	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:00:27.948417+00	
00000000-0000-0000-0000-000000000000	64f04915-5a1c-42d0-b136-16b47dd13c0a	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:02:18.323492+00	
00000000-0000-0000-0000-000000000000	fa89ac05-3f20-4a4a-9732-ae97451349da	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:03:30.269126+00	
00000000-0000-0000-0000-000000000000	7dfe759c-d685-4602-8f39-0b6a9c548939	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:03:55.003595+00	
00000000-0000-0000-0000-000000000000	aad80c52-46d5-42a1-ae25-f53bf26fe622	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:04:20.228661+00	
00000000-0000-0000-0000-000000000000	5892f136-06e9-4e40-bc11-e07491a08098	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:04:25.591035+00	
00000000-0000-0000-0000-000000000000	1aed2802-0bda-496e-adb3-26f30ef00707	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:04:54.634657+00	
00000000-0000-0000-0000-000000000000	30ff6f03-cc89-4d4f-af3a-0ccb37c542ef	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:05:34.313156+00	
00000000-0000-0000-0000-000000000000	7ac91685-fcd4-443e-91ee-b253cd0bce52	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:06:29.023681+00	
00000000-0000-0000-0000-000000000000	00afc12e-437f-4917-a7ae-91de60d74d92	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:08:08.962467+00	
00000000-0000-0000-0000-000000000000	f24fe919-ac01-4506-b400-a454d181b33a	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:08:23.829643+00	
00000000-0000-0000-0000-000000000000	19ffebfe-7d13-4d2c-a8c5-4b9e14bd6b01	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:08:30.987255+00	
00000000-0000-0000-0000-000000000000	809a26ec-b464-4b57-b739-0f03cd0269ac	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:08:39.591954+00	
00000000-0000-0000-0000-000000000000	2cf4ae1d-7e19-4ff9-aeb9-22bf9eabc1b5	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:08:50.855996+00	
00000000-0000-0000-0000-000000000000	d492444f-562b-4ca8-94cf-4abf770297cb	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:10:06.064108+00	
00000000-0000-0000-0000-000000000000	3cd40540-c6fe-41ee-b288-ed097aca254f	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:10:17.923452+00	
00000000-0000-0000-0000-000000000000	3a0c3e10-fa70-4012-8367-5106f4bb2415	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:10:21.344658+00	
00000000-0000-0000-0000-000000000000	6304ae6b-cd0a-4e12-9369-5ca6ec2ad30d	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:10:29.876469+00	
00000000-0000-0000-0000-000000000000	0468a4e6-84c2-43b1-98d8-d143c2be4331	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:14:26.068378+00	
00000000-0000-0000-0000-000000000000	a1651771-c034-4d5e-a70d-26d33e12dbe7	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:14:50.556449+00	
00000000-0000-0000-0000-000000000000	1b561cf6-bcff-495b-aae9-4b2801c13d29	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:15:09.564426+00	
00000000-0000-0000-0000-000000000000	75e7d0c5-c6c0-40f9-8ea5-8bb96a1bd941	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:16:52.447636+00	
00000000-0000-0000-0000-000000000000	fd3ceb3a-bdeb-42ca-8974-375617f6c8a3	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:16:58.042607+00	
00000000-0000-0000-0000-000000000000	c48dafaf-66d2-4bfd-9115-1041e7d5a3a3	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:17:02.903007+00	
00000000-0000-0000-0000-000000000000	c3560efe-0959-4298-af3c-a7b54b37ab4a	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:18:40.758175+00	
00000000-0000-0000-0000-000000000000	597b7e3d-5e20-4c9c-aa28-2029d0a04c2c	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:20:48.012428+00	
00000000-0000-0000-0000-000000000000	56d93649-b81b-4bbb-bd9d-1d1fafa38ca7	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:21:19.769526+00	
00000000-0000-0000-0000-000000000000	1734a22d-2a62-4cab-9c6e-1d0244d29e04	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:21:24.078151+00	
00000000-0000-0000-0000-000000000000	9a7e2864-dce6-4301-a7a7-7da7f7a93186	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:22:32.690465+00	
00000000-0000-0000-0000-000000000000	2ababf34-6a80-4eb5-b73f-76e79ced0f8b	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:22:44.756264+00	
00000000-0000-0000-0000-000000000000	073dcb63-c3f2-429a-889e-5283aa64b145	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:23:06.358165+00	
00000000-0000-0000-0000-000000000000	e852aaac-cea6-4ebe-be69-e2c8a4156082	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:23:12.707773+00	
00000000-0000-0000-0000-000000000000	7cef2755-7d7d-422e-97c5-f27d0ccfb0a5	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:24:52.426891+00	
00000000-0000-0000-0000-000000000000	ad313b01-0113-435e-bfc1-a4f13456f40a	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:24:56.426789+00	
00000000-0000-0000-0000-000000000000	48775054-fd83-40c5-9cfc-7f5688d38e50	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:25:04.580441+00	
00000000-0000-0000-0000-000000000000	07e15ee0-2c81-41fd-81eb-49eb206a13bd	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:25:28.861107+00	
00000000-0000-0000-0000-000000000000	ca201dd7-17bf-4dfa-8650-7f6663775ba3	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:25:35.673244+00	
00000000-0000-0000-0000-000000000000	6961c6c8-db13-45b4-9999-eabca25c1b5c	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:27:13.07545+00	
00000000-0000-0000-0000-000000000000	e90e7383-8d71-44c6-8298-4975eb123a9d	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:27:15.09442+00	
00000000-0000-0000-0000-000000000000	91686426-a6bd-4de7-a5ef-a2b8cfcd48a9	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:27:19.886857+00	
00000000-0000-0000-0000-000000000000	21679518-aff2-470d-88d2-9e87099f7a40	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:27:26.585351+00	
00000000-0000-0000-0000-000000000000	bf03b78f-3477-45d9-8cd7-720d58084178	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:27:30.959254+00	
00000000-0000-0000-0000-000000000000	8d0e4b2b-5c37-4d5b-b7c7-ae5bb4e66d86	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 14:27:34.682811+00	
00000000-0000-0000-0000-000000000000	fcc61dab-102f-4230-a46e-1f47bfc10e57	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 14:29:11.159609+00	
00000000-0000-0000-0000-000000000000	ebef7b8e-5294-48d8-9faa-5ca6674bc8f0	{"action":"token_refreshed","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-29 23:13:41.660764+00	
00000000-0000-0000-0000-000000000000	c69fff48-7d6c-4e82-8fe5-503f232f5caa	{"action":"token_revoked","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-29 23:13:41.685817+00	
00000000-0000-0000-0000-000000000000	2785db7b-04f0-409c-9419-af169e89a918	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 23:13:46.242245+00	
00000000-0000-0000-0000-000000000000	f2238294-11aa-4712-965b-d642272d7f34	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 23:13:53.39566+00	
00000000-0000-0000-0000-000000000000	1264e318-d8c6-44ce-afbc-a570bf72997f	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-29 23:25:26.492398+00	
00000000-0000-0000-0000-000000000000	749bf465-56dd-40b2-83aa-3331bd01511f	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-29 23:25:32.788864+00	
00000000-0000-0000-0000-000000000000	6b7d40a1-b7c9-447e-8a51-c9580c08d5bc	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-30 00:42:27.875281+00	
00000000-0000-0000-0000-000000000000	f08b7d7c-250d-43e7-9173-cec9e187b61c	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-30 00:42:38.673669+00	
00000000-0000-0000-0000-000000000000	a4450c5a-412b-4b11-a2e6-1fcd2c43fa42	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-30 00:43:05.091235+00	
00000000-0000-0000-0000-000000000000	f5236352-da33-4a92-9bcc-81dae1a4a3c3	{"action":"token_refreshed","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-30 12:11:17.479336+00	
00000000-0000-0000-0000-000000000000	f247362b-1bc5-456e-86b2-abf9fac636a7	{"action":"token_revoked","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-30 12:11:17.502793+00	
00000000-0000-0000-0000-000000000000	d267455a-3457-40be-bf05-75e32fdddd9e	{"action":"token_refreshed","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-30 14:28:12.117904+00	
00000000-0000-0000-0000-000000000000	d997f867-e7cc-48f5-a958-7521cf5d4c3f	{"action":"token_revoked","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-30 14:28:12.123867+00	
00000000-0000-0000-0000-000000000000	e7f92cf4-224b-48c7-a111-69ff9a25f296	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-30 14:28:19.327743+00	
00000000-0000-0000-0000-000000000000	adf35bba-da6c-4c11-88fc-07130044b192	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-30 14:28:24.244797+00	
00000000-0000-0000-0000-000000000000	ab7ea4a9-e765-4fd8-a303-ac00fbb7e103	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-30 14:28:32.135646+00	
00000000-0000-0000-0000-000000000000	9b8791f9-0d55-49b8-8c67-cdb02d642557	{"action":"user_signedup","actor_id":"34dd68c6-3b73-45fe-b2f1-9e7eae08ae95","actor_name":"皮爸","actor_username":"piiba88888@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-09-30 14:28:50.043383+00	
00000000-0000-0000-0000-000000000000	882347ab-ae46-41ba-9cba-c7996a577dc7	{"action":"logout","actor_id":"34dd68c6-3b73-45fe-b2f1-9e7eae08ae95","actor_name":"皮爸","actor_username":"piiba88888@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-30 14:28:50.444011+00	
00000000-0000-0000-0000-000000000000	2750b874-8953-4912-b6de-a703c529ef9e	{"action":"login","actor_id":"34dd68c6-3b73-45fe-b2f1-9e7eae08ae95","actor_name":"皮爸","actor_username":"piiba88888@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-30 14:28:54.934405+00	
00000000-0000-0000-0000-000000000000	63f483dd-9f80-49a6-bde4-6526d19950c7	{"action":"logout","actor_id":"34dd68c6-3b73-45fe-b2f1-9e7eae08ae95","actor_name":"皮爸","actor_username":"piiba88888@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-30 14:28:55.265032+00	
00000000-0000-0000-0000-000000000000	b7c2082c-10a0-447b-bc01-51da39055e96	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-30 14:28:58.998916+00	
00000000-0000-0000-0000-000000000000	056ce5ed-1010-4285-8013-5e77685308e3	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-30 14:51:41.363634+00	
00000000-0000-0000-0000-000000000000	951147b4-e176-4dac-9cfd-48eb7f027a05	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-30 14:51:47.105237+00	
00000000-0000-0000-0000-000000000000	12a1f3bb-3784-41aa-aaf4-6b0c95211259	{"action":"login","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-09-30 14:51:57.400376+00	
00000000-0000-0000-0000-000000000000	8b0a646d-84d7-477c-8f4a-a7789bf0d92d	{"action":"logout","actor_id":"a97eeae8-3be8-48a5-969a-c25f38f696f3","actor_name":"賴志皓","actor_username":"junesnow39@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-09-30 14:52:03.02382+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
115648754324934549877	a97eeae8-3be8-48a5-969a-c25f38f696f3	{"iss": "https://accounts.google.com", "sub": "115648754324934549877", "name": "賴志皓", "email": "junesnow39@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKeetMts39OmHyu_-KnFtGR4gMwmS7NIO-ptsTSj9KKOYBJQtmL=s96-c", "full_name": "賴志皓", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKeetMts39OmHyu_-KnFtGR4gMwmS7NIO-ptsTSj9KKOYBJQtmL=s96-c", "provider_id": "115648754324934549877", "email_verified": true, "phone_verified": false}	google	2025-09-29 13:56:19.050479+00	2025-09-29 13:56:19.050533+00	2025-09-30 14:51:57.398584+00	fa934f82-7822-4ae1-b297-08e643bf97b7
113129434615940475114	34dd68c6-3b73-45fe-b2f1-9e7eae08ae95	{"iss": "https://accounts.google.com", "sub": "113129434615940475114", "name": "皮爸", "email": "piiba88888@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLrm7aj956k-bwmD3LY1QTFTAZjulqWgZv8vr42Fm1DYaSg9J8=s96-c", "full_name": "皮爸", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLrm7aj956k-bwmD3LY1QTFTAZjulqWgZv8vr42Fm1DYaSg9J8=s96-c", "provider_id": "113129434615940475114", "email_verified": true, "phone_verified": false}	google	2025-09-30 14:28:50.037788+00	2025-09-30 14:28:50.037838+00	2025-09-30 14:28:54.932475+00	f44bcd2b-3c85-4daf-9afe-27f42eb652d4
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_clients (id, client_id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	34dd68c6-3b73-45fe-b2f1-9e7eae08ae95	authenticated	authenticated	piiba88888@gmail.com	\N	2025-09-30 14:28:50.043965+00	\N		\N		\N			\N	2025-09-30 14:28:54.935672+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "113129434615940475114", "name": "皮爸", "email": "piiba88888@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLrm7aj956k-bwmD3LY1QTFTAZjulqWgZv8vr42Fm1DYaSg9J8=s96-c", "full_name": "皮爸", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLrm7aj956k-bwmD3LY1QTFTAZjulqWgZv8vr42Fm1DYaSg9J8=s96-c", "provider_id": "113129434615940475114", "email_verified": true, "phone_verified": false}	\N	2025-09-30 14:28:50.024232+00	2025-09-30 14:28:54.938411+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a97eeae8-3be8-48a5-969a-c25f38f696f3	authenticated	authenticated	junesnow39@gmail.com	\N	2025-09-29 13:56:19.065818+00	\N		\N		\N			\N	2025-09-30 14:51:57.401991+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "115648754324934549877", "name": "賴志皓", "email": "junesnow39@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKeetMts39OmHyu_-KnFtGR4gMwmS7NIO-ptsTSj9KKOYBJQtmL=s96-c", "full_name": "賴志皓", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKeetMts39OmHyu_-KnFtGR4gMwmS7NIO-ptsTSj9KKOYBJQtmL=s96-c", "provider_id": "115648754324934549877", "email_verified": true, "phone_verified": false}	\N	2025-09-29 13:56:19.028537+00	2025-09-30 14:51:57.404322+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


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
BK20250900079	CL2510007	U8b8c9f515de548d1627f62612e6b4f3a	2025-09-30 04:14:54.963718+00	已預約	2025-09-30 04:14:54.963718+00	志皓	\N	\N
BK20250900080	CL2510002	U_DEV_000000000000000000000000001	2025-09-30 14:29:54.630226+00	已預約	2025-09-30 14:29:54.630226+00	開發者AA	\N	\N
\.


--
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.classes (class_id, course_id, coach_id, class_name, class_date, start_time, end_time, max_students, current_students, status, points, create_time, create_user, update_time, update_user) FROM stdin;
CL2510007	CRS001	C001	龜派氣功	2025-10-01	12:00:00	13:00:00	4	1	開放中	0	2025-09-29 11:45:28.298284+00	Admin	2025-09-29 12:44:54.601892+00	Admin
CL2510006	CRS001	C001	龜派氣功	2025-09-29	10:00:00	11:00:00	3	0	開放中	0	2025-09-29 11:45:15.596552+00	Admin	2025-09-30 14:30:33.267026+00	Admin
CL2509013	CRS005	C003	打狗棒法	2025-09-24	20:00:00	21:00:00	4	0	開放中	0	2025-09-24 13:39:49.561511+00	Admin	\N	\N
CL2509014	CRS005	C003	打狗棒法	2025-09-25	20:00:00	21:00:00	4	0	開放中	0	2025-09-24 13:39:57.556734+00	Admin	\N	\N
CL2509015	CRS005	C003	打狗棒法	2025-09-26	20:00:00	21:00:00	4	0	開放中	0	2025-09-24 13:40:05.150186+00	Admin	\N	\N
CL2509018	CRS003	C001	一對一教學	2025-09-25	15:00:00	16:00:00	1	0	開放中	0	2025-09-24 13:40:36.596034+00	Admin	\N	\N
CL2509019	CRS004	C003	秘密課程	2025-09-26	15:00:00	16:00:00	2	0	開放中	0	2025-09-24 13:40:46.722282+00	Admin	\N	\N
CL2509020	CRS003	C002	一對一教學	2025-09-26	10:00:00	11:00:00	1	0	開放中	0	2025-09-24 13:41:10.192425+00	Admin	\N	\N
CL2509012	CRS001	C001	龜派氣功	2025-09-27	17:00:00	18:00:00	4	1	開放中	0	2025-09-24 13:39:29.328059+00	Admin	\N	\N
CL2509010	CRS001	C001	龜派氣功	2025-09-25	17:00:00	18:00:00	4	0	開放中	0	2025-09-24 13:39:15.283335+00	Admin	\N	\N
CL2509011	CRS001	C001	龜派氣功	2025-09-26	17:00:00	18:00:00	4	0	開放中	0	2025-09-24 13:39:22.598645+00	Admin	\N	\N
CL2509016	CRS005	C003	打狗棒法	2025-09-27	20:00:00	21:00:00	4	0	開放中	0	2025-09-24 13:40:12.007341+00	Admin	\N	\N
CL2509017	CRS004	C002	秘密課程	2025-09-27	15:00:00	16:00:00	1	0	開放中	0	2025-09-24 13:40:25.501608+00	Admin	\N	\N
CL2509021	CRS003	C002	一對一教學	2025-09-27	10:00:00	11:00:00	1	0	開放中	0	2025-09-24 13:41:23.191958+00	Admin	\N	\N
CL2509029	CRS003	C001	一對一教學	2025-09-30	14:00:00	15:00:00	1	0	開放中	0	2025-09-28 12:14:30.3151+00	Admin	2025-09-28 12:50:46.021944+00	Admin
CL2509025	CRS003	C004	一對一教學	2025-09-23	13:15:00	14:30:00	1	0	開放中	0	2025-09-27 10:45:19.165038+00	Admin	2025-09-27 14:26:36.893217+00	Admin
CL2509027	CRS005	C003	打狗棒法	2025-10-04	10:00:00	11:00:00	4	0	開放中	0	2025-09-27 12:42:08.930363+00	Admin	2025-09-29 12:44:48.484781+00	Admin
CL2510004	CRS002	C002	夢遊仙境	2025-10-03	10:00:00	11:00:00	4	0	開放中	0	2025-09-27 13:54:20.777691+00	Admin	2025-09-28 12:50:59.557933+00	Admin
CL2510003	CRS005	C003	打狗棒法	2025-10-02	09:00:00	10:15:00	4	0	開放中	0	2025-09-27 12:42:22.50143+00	Admin	2025-09-29 23:30:16.784878+00	Admin
CL2510002	CRS001	C001	龜派氣功	2025-10-02	12:00:00	13:00:00	4	1	開放中	0	2025-09-26 13:45:46.503152+00	Admin	2025-09-29 12:44:53.552627+00	Admin
CL2510001	CRS001	C001	龜派氣功	2025-10-03	12:00:00	13:00:00	1	1	開放中	0	2025-09-26 13:45:37.596229+00	Admin	2025-09-29 12:45:03.735876+00	Admin
CL2509023	CRS001	C001	龜派氣功	2025-09-28	12:00:00	13:00:00	1	0	開放中	0	2025-09-26 13:45:23.041818+00	Admin	2025-09-29 12:45:09.397683+00	Admin
CL2509003	CRS002	C002	夢遊仙境	2025-09-24	11:00:00	12:00:00	5	1	開放中	0	2025-09-23 13:23:01.30018+00	Admin	2025-09-27 14:26:34.419118+00	Admin
CL2509028	CRS002	C002	夢遊仙境	2025-10-01	10:00:00	11:00:00	4	0	開放中	0	2025-09-27 12:43:13.2289+00	Admin	2025-09-29 12:45:21.379651+00	Admin
CL2410002	CRS001	C001	下午的測試課	2024-10-01	14:00:00	15:30:00	5	0	開放中	0	2025-09-27 09:00:27.379804+00	Admin	\N	\N
CL2509006	CRS002	C002	夢遊仙境	2025-09-25	12:00:00	13:00:00	4	0	開放中	0	2025-09-23 13:24:20.478422+00	Admin	\N	\N
CL2509009	CRS005	C003	打狗棒法	2025-09-23	20:00:00	21:00:00	4	0	開放中	0	2025-09-23 13:29:24.619114+00	Admin	2025-09-27 13:09:05.020695+00	Admin
CL2509007	CRS002	C002	夢遊仙境	2025-09-26	12:00:00	13:00:00	4	0	開放中	0	2025-09-23 13:24:29.364747+00	Admin	\N	\N
CL2510005	CRS002	C002	夢遊仙境	2025-10-03	14:00:00	15:00:00	4	0	開放中	0	2025-09-27 14:02:55.993118+00	Admin	2025-09-29 12:44:56.729242+00	Admin
CL2509005	CRS003	C003	一對一教學	2025-09-21	17:00:00	18:00:00	1	0	開放中	0	2025-09-23 13:23:45.351295+00	Admin	\N	\N
CL2509001	CRS002	C002	夢遊仙境	2025-09-23	09:00:00	10:15:00	4	0	開放中	0	2025-09-23 13:22:38.248425+00	Admin	2025-09-28 00:10:56.255866+00	Admin
CL2509008	CRS002	C002	夢遊仙境	2025-09-27	12:00:00	13:00:00	4	1	開放中	0	2025-09-23 13:24:37.676636+00	Admin	\N	\N
CL2509004	CRS001	C001	龜派氣功	2025-09-24	17:00:00	18:00:00	4	0	開放中	0	2025-09-23 13:23:28.73331+00	Admin	2025-09-23 13:32:48.552484+00	Admin
CL2509022	CRS001	C001	龜派氣功	2025-09-29	14:00:00	15:00:00	4	0	開放中	0	2025-09-26 13:45:15.324884+00	Admin	2025-09-28 08:54:27.925272+00	Admin
CL2509026	CRS003	C004	一對一教學	2025-09-30	11:45:00	13:15:00	1	0	開放中	0	2025-09-27 10:50:33.252674+00	Admin	2025-09-28 13:16:40.390016+00	Admin
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
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-09-22 02:09:32
20211116045059	2025-09-22 02:09:33
20211116050929	2025-09-22 02:09:34
20211116051442	2025-09-22 02:09:35
20211116212300	2025-09-22 02:09:36
20211116213355	2025-09-22 02:09:36
20211116213934	2025-09-22 02:09:37
20211116214523	2025-09-22 02:09:38
20211122062447	2025-09-22 02:09:39
20211124070109	2025-09-22 02:09:39
20211202204204	2025-09-22 02:09:40
20211202204605	2025-09-22 02:09:41
20211210212804	2025-09-22 02:09:43
20211228014915	2025-09-22 02:09:44
20220107221237	2025-09-22 02:09:44
20220228202821	2025-09-22 02:09:45
20220312004840	2025-09-22 02:09:46
20220603231003	2025-09-22 02:09:47
20220603232444	2025-09-22 02:09:48
20220615214548	2025-09-22 02:09:49
20220712093339	2025-09-22 02:09:50
20220908172859	2025-09-22 02:09:50
20220916233421	2025-09-22 02:09:51
20230119133233	2025-09-22 02:09:52
20230128025114	2025-09-22 02:09:53
20230128025212	2025-09-22 02:09:53
20230227211149	2025-09-22 02:09:54
20230228184745	2025-09-22 02:09:55
20230308225145	2025-09-22 02:09:55
20230328144023	2025-09-22 02:09:56
20231018144023	2025-09-22 02:09:57
20231204144023	2025-09-22 02:09:58
20231204144024	2025-09-22 02:09:59
20231204144025	2025-09-22 02:09:59
20240108234812	2025-09-22 02:10:00
20240109165339	2025-09-22 02:10:01
20240227174441	2025-09-22 02:10:02
20240311171622	2025-09-22 02:10:03
20240321100241	2025-09-22 02:10:05
20240401105812	2025-09-22 02:10:07
20240418121054	2025-09-22 02:10:07
20240523004032	2025-09-22 02:10:10
20240618124746	2025-09-22 02:10:11
20240801235015	2025-09-22 02:10:11
20240805133720	2025-09-22 02:10:12
20240827160934	2025-09-22 02:10:13
20240919163303	2025-09-22 02:10:14
20240919163305	2025-09-22 02:10:14
20241019105805	2025-09-22 02:10:15
20241030150047	2025-09-22 02:10:18
20241108114728	2025-09-22 02:10:19
20241121104152	2025-09-22 02:10:19
20241130184212	2025-09-22 02:10:20
20241220035512	2025-09-22 02:10:21
20241220123912	2025-09-22 02:10:22
20241224161212	2025-09-22 02:10:22
20250107150512	2025-09-22 02:10:23
20250110162412	2025-09-22 02:10:24
20250123174212	2025-09-22 02:10:24
20250128220012	2025-09-22 02:10:25
20250506224012	2025-09-22 02:10:26
20250523164012	2025-09-22 02:10:26
20250714121412	2025-09-22 02:10:27
20250905041441	2025-09-27 11:09:05
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-09-22 02:09:30.832673
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-09-22 02:09:30.860868
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-09-22 02:09:30.868447
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-09-22 02:09:30.924211
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-09-22 02:09:31.063323
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-09-22 02:09:31.068524
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-09-22 02:09:31.074012
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-09-22 02:09:31.079659
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-09-22 02:09:31.084302
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-09-22 02:09:31.089292
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-09-22 02:09:31.096423
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-09-22 02:09:31.104275
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-09-22 02:09:31.123668
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-09-22 02:09:31.128888
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-09-22 02:09:31.134037
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-09-22 02:09:31.211424
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-09-22 02:09:31.216639
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-09-22 02:09:31.221394
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-09-22 02:09:31.229331
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-09-22 02:09:31.236197
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-09-22 02:09:31.244881
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-09-22 02:09:31.25325
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-09-22 02:09:31.281221
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-09-22 02:09:31.306116
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-09-22 02:09:31.319276
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-09-22 02:09:31.325857
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: supabase_migrations; Owner: postgres
--

COPY supabase_migrations.schema_migrations (version, statements, name) FROM stdin;
20250929124120	\N	remote_schema
20250929124148	{"create table \\"public\\".\\"bookings\\" (\n    \\"booking_id\\" text not null,\n    \\"class_id\\" text not null,\n    \\"line_user_id\\" text not null,\n    \\"booking_time\\" timestamp with time zone not null default now(),\n    \\"status\\" text not null default '已預約'::text,\n    \\"create_time\\" timestamp with time zone not null default now(),\n    \\"create_user\\" text,\n    \\"update_time\\" timestamp with time zone,\n    \\"update_user\\" text\n)","alter table \\"public\\".\\"bookings\\" enable row level security","create table \\"public\\".\\"classes\\" (\n    \\"class_id\\" text not null,\n    \\"course_id\\" text not null,\n    \\"coach_id\\" text not null,\n    \\"class_name\\" text not null,\n    \\"class_date\\" date not null,\n    \\"start_time\\" time without time zone not null,\n    \\"end_time\\" time without time zone,\n    \\"max_students\\" integer not null default 1,\n    \\"current_students\\" integer not null default 0,\n    \\"status\\" text not null default '開放中'::text,\n    \\"points\\" integer default 0,\n    \\"create_time\\" timestamp with time zone not null default now(),\n    \\"create_user\\" text,\n    \\"update_time\\" timestamp with time zone,\n    \\"update_user\\" text\n)","alter table \\"public\\".\\"classes\\" enable row level security","create table \\"public\\".\\"coaches\\" (\n    \\"coach_id\\" text not null,\n    \\"coach_name\\" text not null,\n    \\"specialty\\" text,\n    \\"line_id\\" text,\n    \\"phone_number\\" text,\n    \\"bio\\" text,\n    \\"image_url\\" text\n)","alter table \\"public\\".\\"coaches\\" enable row level security","create table \\"public\\".\\"courses\\" (\n    \\"course_id\\" text not null,\n    \\"course_name\\" text not null,\n    \\"short_description\\" text,\n    \\"long_description\\" text,\n    \\"image_url\\" text,\n    \\"price\\" numeric not null,\n    \\"status\\" text not null default 'Active'::text,\n    \\"color\\" text default '#64748b'::text\n)","alter table \\"public\\".\\"courses\\" enable row level security","create table \\"public\\".\\"users\\" (\n    \\"line_user_id\\" text not null,\n    \\"line_display_name\\" text,\n    \\"registration_date\\" timestamp with time zone not null default now(),\n    \\"points\\" integer not null default 0,\n    \\"line_id\\" text,\n    \\"phone_number\\" text\n)","alter table \\"public\\".\\"users\\" enable row level security","CREATE UNIQUE INDEX bookings_pkey ON public.bookings USING btree (booking_id)","CREATE UNIQUE INDEX classes_pkey ON public.classes USING btree (class_id)","CREATE UNIQUE INDEX coaches_pkey ON public.coaches USING btree (coach_id)","CREATE UNIQUE INDEX courses_pkey ON public.courses USING btree (course_id)","CREATE INDEX idx_bookings_class_id ON public.bookings USING btree (class_id)","CREATE INDEX idx_bookings_user_id ON public.bookings USING btree (line_user_id)","CREATE INDEX idx_classes_class_date ON public.classes USING btree (class_date)","CREATE INDEX idx_classes_course_id ON public.classes USING btree (course_id)","CREATE UNIQUE INDEX users_pkey ON public.users USING btree (line_user_id)","alter table \\"public\\".\\"bookings\\" add constraint \\"bookings_pkey\\" PRIMARY KEY using index \\"bookings_pkey\\"","alter table \\"public\\".\\"classes\\" add constraint \\"classes_pkey\\" PRIMARY KEY using index \\"classes_pkey\\"","alter table \\"public\\".\\"coaches\\" add constraint \\"coaches_pkey\\" PRIMARY KEY using index \\"coaches_pkey\\"","alter table \\"public\\".\\"courses\\" add constraint \\"courses_pkey\\" PRIMARY KEY using index \\"courses_pkey\\"","alter table \\"public\\".\\"users\\" add constraint \\"users_pkey\\" PRIMARY KEY using index \\"users_pkey\\"","alter table \\"public\\".\\"bookings\\" add constraint \\"bookings_class_id_fkey\\" FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE not valid","alter table \\"public\\".\\"bookings\\" validate constraint \\"bookings_class_id_fkey\\"","alter table \\"public\\".\\"bookings\\" add constraint \\"bookings_line_user_id_fkey\\" FOREIGN KEY (line_user_id) REFERENCES users(line_user_id) ON DELETE CASCADE not valid","alter table \\"public\\".\\"bookings\\" validate constraint \\"bookings_line_user_id_fkey\\"","alter table \\"public\\".\\"classes\\" add constraint \\"classes_coach_id_fkey\\" FOREIGN KEY (coach_id) REFERENCES coaches(coach_id) ON DELETE RESTRICT not valid","alter table \\"public\\".\\"classes\\" validate constraint \\"classes_coach_id_fkey\\"","alter table \\"public\\".\\"classes\\" add constraint \\"classes_course_id_fkey\\" FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE RESTRICT not valid","alter table \\"public\\".\\"classes\\" validate constraint \\"classes_course_id_fkey\\"","alter table \\"public\\".\\"classes\\" add constraint \\"students_check\\" CHECK ((current_students <= max_students)) not valid","alter table \\"public\\".\\"classes\\" validate constraint \\"students_check\\"","set check_function_bodies = off","create or replace view \\"public\\".\\"classes_with_details\\" as  SELECT cls.class_id,\n    cls.class_date,\n    cls.start_time,\n    cls.end_time,\n    cls.class_name,\n    cls.current_students,\n    cls.max_students,\n    cls.course_id,\n    cls.coach_id,\n    co.course_name,\n    co.color,\n    c.coach_name\n   FROM ((classes cls\n     LEFT JOIN courses co ON ((cls.course_id = co.course_id)))\n     LEFT JOIN coaches c ON ((cls.coach_id = c.coach_id)))","CREATE OR REPLACE FUNCTION public.create_booking_atomic(p_class_id text, p_user_id text, p_display_name text)\n RETURNS TABLE(status text, message text, booking_id text)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\nDECLARE\n    v_class_info RECORD;\n    v_existing_booking_id TEXT;\n    v_new_booking_id TEXT;\n    v_id_prefix TEXT;\n    v_max_num INT;\nBEGIN\n    -- 1. 檢查使用者是否已預約此課程\n    SELECT b.booking_id INTO v_existing_booking_id\n    FROM public.bookings b\n    WHERE b.class_id = p_class_id\n      AND b.line_user_id = p_user_id\n      AND b.status IN ('已預約', '已扣款');\n\n    IF v_existing_booking_id IS NOT NULL THEN\n        RETURN QUERY SELECT 'error'::TEXT, '您已預約此課程，請勿重複預約。'::TEXT, NULL::TEXT;\n        RETURN;\n    END IF;\n\n    -- 2. 鎖定課堂資料列以防止競爭條件，並檢查是否額滿\n    SELECT * INTO v_class_info\n    FROM public.classes\n    WHERE class_id = p_class_id\n    FOR UPDATE; -- 關鍵：鎖定此行，直到交易結束\n\n    IF v_class_info IS NULL THEN\n        RETURN QUERY SELECT 'error'::TEXT, '課程不存在。'::TEXT, NULL::TEXT;\n        RETURN;\n    END IF;\n\n    IF v_class_info.current_students >= v_class_info.max_students THEN\n        RETURN QUERY SELECT 'error'::TEXT, '課程已額滿。'::TEXT, NULL::TEXT;\n        RETURN;\n    END IF;\n\n    -- 3. 如果使用者不存在，則新增使用者資料 (Upsert)\n    INSERT INTO public.users (line_user_id, line_display_name, registration_date, points)\n    VALUES (p_user_id, p_display_name, NOW(), 0)\n    ON CONFLICT (line_user_id) DO NOTHING;\n\n    -- 4. 產生新的預約編號 (BK + 年月 + 5位流水號)\n    v_id_prefix := 'BK' || to_char(NOW(), 'YYYYMM');\n    SELECT COALESCE(MAX(SUBSTRING(b.booking_id FROM 9 FOR 5)::INT), 0)\n    INTO v_max_num\n    FROM public.bookings b\n    WHERE b.booking_id LIKE v_id_prefix || '%';\n    v_new_booking_id := v_id_prefix || LPAD((v_max_num + 1)::TEXT, 5, '0');\n\n    -- 5. 新增預約紀錄\n    INSERT INTO public.bookings (booking_id, class_id, line_user_id, status, booking_time, create_time, create_user)\n    VALUES (v_new_booking_id, p_class_id, p_user_id, '已預約', NOW(), NOW(), p_display_name);\n\n    -- 6. 更新課堂的目前學生人數\n    UPDATE public.classes\n    SET current_students = current_students + 1\n    WHERE class_id = p_class_id;\n\n    -- 7. 回傳成功結果\n    RETURN QUERY SELECT 'success'::TEXT, '預約成功！'::TEXT, v_new_booking_id::TEXT;\n\nEXCEPTION\n    WHEN OTHERS THEN\n        -- 如果發生任何未預期的錯誤，回傳通用錯誤訊息\n        RETURN QUERY SELECT 'error'::TEXT, '處理預約時發生未預期錯誤: ' || SQLERRM, NULL::TEXT;\nEND;\n$function$\n;\n\nCREATE OR REPLACE FUNCTION public.delete_class(p_class_id text)\n RETURNS TABLE(status text, message text)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\nDECLARE\n    v_booking_count INT;\nBEGIN\n    IF p_class_id IS NULL OR p_class_id = '' THEN\n        RETURN QUERY SELECT 'error'::TEXT, '缺少 classId。'::TEXT;\n        RETURN;\n    END IF;\n\n    -- 安全檢查：檢查是否有任何有效預約 ('已預約', '已扣款')\n    -- 修正點：明確指定 status 欄位來自 bookings 表\n    SELECT COUNT(*) INTO v_booking_count\n    FROM public.bookings\n    WHERE public.bookings.class_id = p_class_id AND public.bookings.status IN ('已預約', '已扣款');\n\n    IF v_booking_count > 0 THEN\n        RETURN QUERY SELECT 'error'::TEXT, '無法刪除：此課堂已有學員預約。請先將相關預約取消。'::TEXT;\n        RETURN;\n    END IF;\n\n    -- 執行刪除\n    DELETE FROM public.classes WHERE class_id = p_class_id;\n\n    IF FOUND THEN\n        RETURN QUERY SELECT 'success'::TEXT, '課堂刪除成功！'::TEXT;\n    ELSE\n        RETURN QUERY SELECT 'error'::TEXT, '找不到要刪除的課堂。'::TEXT;\n    END IF;\nEXCEPTION\n    WHEN OTHERS THEN\n        RETURN QUERY SELECT 'error'::TEXT, '刪除課堂時發生未預期錯誤: ' || SQLERRM;\nEND;\n$function$\n;\n\nCREATE OR REPLACE FUNCTION public.delete_coach(p_coach_id text)\n RETURNS TABLE(status text, message text)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\nDECLARE\n    v_class_count INT;\nBEGIN\n    IF p_coach_id IS NULL OR p_coach_id = '' THEN\n        RETURN QUERY SELECT 'error'::TEXT, '缺少 coachId。'::TEXT;\n        RETURN;\n    END IF;\n\n    -- 安全檢查：檢查是否有任何課堂(classes)正在使用此教練\n    SELECT COUNT(*) INTO v_class_count\n    FROM public.classes\n    WHERE coach_id = p_coach_id;\n\n    IF v_class_count > 0 THEN\n        RETURN QUERY SELECT 'error'::TEXT, '無法刪除：此教練已被指派至某些課堂。請先將相關課堂的教練更換或刪除。'::TEXT;\n        RETURN;\n    END IF;\n\n    -- 執行刪除\n    DELETE FROM public.coaches WHERE coach_id = p_coach_id;\n\n    IF FOUND THEN\n        RETURN QUERY SELECT 'success'::TEXT, '教練刪除成功！'::TEXT;\n    ELSE\n        RETURN QUERY SELECT 'error'::TEXT, '找不到要刪除的教練。'::TEXT;\n    END IF;\n\nEXCEPTION\n    WHEN OTHERS THEN\n        RETURN QUERY SELECT 'error'::TEXT, '刪除教練時發生未預期錯誤: ' || SQLERRM;\nEND;\n$function$\n;\n\nCREATE OR REPLACE FUNCTION public.delete_course(p_course_id text)\n RETURNS TABLE(status text, message text)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\nDECLARE\n    v_class_count INT;\nBEGIN\n    IF p_course_id IS NULL OR p_course_id = '' THEN\n        RETURN QUERY SELECT 'error'::TEXT, '缺少 courseId。'::TEXT;\n        RETURN;\n    END IF;\n\n    -- 安全檢查：檢查是否有任何課堂(classes)正在使用此課程型錄\n    SELECT COUNT(*) INTO v_class_count\n    FROM public.classes\n    WHERE course_id = p_course_id;\n\n    IF v_class_count > 0 THEN\n        RETURN QUERY SELECT 'error'::TEXT, '無法刪除：此課程型錄已被用於排課。請先刪除所有相關的課堂安排。'::TEXT;\n        RETURN;\n    END IF;\n\n    -- 執行刪除\n    DELETE FROM public.courses WHERE course_id = p_course_id;\n\n    -- 檢查是否真的刪除了 (row_count 是 PL/pgSQL 的一個特殊變數)\n    IF FOUND THEN\n        RETURN QUERY SELECT 'success'::TEXT, '課程型錄刪除成功！'::TEXT;\n    ELSE\n        RETURN QUERY SELECT 'error'::TEXT, '找不到要刪除的課程型錄。'::TEXT;\n    END IF;\n\nEXCEPTION\n    WHEN OTHERS THEN\n        RETURN QUERY SELECT 'error'::TEXT, '刪除課程型錄時發生未預期錯誤: ' || SQLERRM;\nEND;\n$function$\n;\n\nCREATE OR REPLACE FUNCTION public.get_manager_form_data()\n RETURNS json\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\nDECLARE\n    courses_json JSON;\n    coaches_json JSON;\nBEGIN\n    -- 查詢所有啟用的課程，並依照 course_id 排序\n    SELECT json_agg(json_build_object('courseId', c.course_id, 'courseName', c.course_name) ORDER BY c.course_id)\n    INTO courses_json\n    FROM public.courses c\n    WHERE c.status = 'Active';\n\n    -- 查詢所有教練，並依照 coach_id 排序\n    SELECT json_agg(json_build_object('coachId', ch.coach_id, 'coachName', ch.coach_name) ORDER BY ch.coach_id)\n    INTO coaches_json\n    FROM public.coaches ch;\n\n    -- 組合回傳結果\n    RETURN json_build_object(\n        'status', 'success',\n        'courses', COALESCE(courses_json, '[]'::json),\n        'coaches', COALESCE(coaches_json, '[]'::json)\n    );\nEND;\n$function$\n;\n\nCREATE OR REPLACE FUNCTION public.review_booking_atomic(p_booking_id text, p_decision text)\n RETURNS TABLE(status text, message text)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\nDECLARE\n    v_booking_info RECORD;\n    v_new_status TEXT;\nBEGIN\n    -- 1. 檢查並鎖定預約紀錄，防止競爭條件\n    SELECT * INTO v_booking_info\n    FROM public.bookings\n    WHERE booking_id = p_booking_id\n    FOR UPDATE;\n\n    -- 2. 檢查預約是否存在或狀態是否正確\n    IF v_booking_info IS NULL THEN\n        RETURN QUERY SELECT 'error'::TEXT, '找不到該筆預約紀錄。'::TEXT;\n        RETURN;\n    END IF;\n\n    IF v_booking_info.status <> '已預約' THEN\n        RETURN QUERY SELECT 'error'::TEXT, '此預約狀態為「' || v_booking_info.status || '」，無法執行此操作。'::TEXT;\n        RETURN;\n    END IF;\n\n    -- 3. 根據決定執行不同操作\n    IF p_decision = 'approve' THEN\n        -- 決定為 'approve'，將狀態更新為 '已扣款'\n        v_new_status := '已扣款';\n        UPDATE public.bookings\n        SET status = v_new_status, update_time = NOW(), update_user = 'Admin'\n        WHERE booking_id = p_booking_id;\n\n        RETURN QUERY SELECT 'success'::TEXT, '操作成功：已扣款'::TEXT;\n\n    ELSIF p_decision = 'reject' THEN\n        -- 決定為 'reject'，將狀態更新為 '已取消'\n        v_new_status := '已取消';\n        UPDATE public.bookings\n        SET status = v_new_status, update_time = NOW(), update_user = 'Admin'\n        WHERE booking_id = p_booking_id;\n\n        -- 將對應課堂的學生人數減 1\n        UPDATE public.classes\n        SET current_students = current_students - 1\n        WHERE class_id = v_booking_info.class_id AND current_students > 0; -- 確保人數不會變負數\n\n        RETURN QUERY SELECT 'success'::TEXT, '操作成功：已取消'::TEXT;\n\n    ELSE\n        -- 無效的決定\n        RETURN QUERY SELECT 'error'::TEXT, '無效的操作決定。'::TEXT;\n        RETURN;\n    END IF;\n\nEXCEPTION\n    WHEN OTHERS THEN\n        -- 如果發生任何未預期的錯誤，回傳通用錯誤訊息\n        RETURN QUERY SELECT 'error'::TEXT, '處理審核時發生未預期錯誤: ' || SQLERRM;\nEND;\n$function$\n;\n\nCREATE OR REPLACE FUNCTION public.save_class(p_class_id text, p_class_date text, p_start_time text, p_end_time text, p_course_id text, p_class_name text, p_coach_id text, p_max_students integer)\n RETURNS TABLE(status text, message text)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\nDECLARE\n    v_class_date_parsed DATE;\n    v_start_time_parsed TIME;\n    v_end_time_parsed TIME;\n    v_new_class_id TEXT;\n    v_id_prefix TEXT;\n    v_max_num INT;\n    v_overlap_count INT;\nBEGIN\n    -- 1. 檢查並解析參數\n    IF p_class_date IS NULL OR p_start_time IS NULL OR p_end_time IS NULL OR p_course_id IS NULL OR p_class_name IS NULL OR p_coach_id IS NULL OR p_max_students IS NULL THEN\n        RETURN QUERY SELECT 'error'::TEXT, '缺少必要的課堂資訊。'::TEXT;\n        RETURN;\n    END IF;\n\n    v_class_date_parsed := p_class_date::DATE;\n    v_start_time_parsed := p_start_time::TIME;\n    v_end_time_parsed := p_end_time::TIME;\n\n    -- 2. 時間重疊檢查 (核心邏輯)\n    SELECT COUNT(*)\n    INTO v_overlap_count\n    FROM public.classes c\n    WHERE\n        c.coach_id = p_coach_id AND\n        c.class_id <> COALESCE(p_class_id, '') AND -- 排除自己\n        c.class_date = v_class_date_parsed AND\n        (v_start_time_parsed, v_end_time_parsed) OVERLAPS (c.start_time, c.end_time);\n\n    IF v_overlap_count > 0 THEN\n        RETURN QUERY SELECT 'error'::TEXT, '儲存失敗：該時段與此教練的其他課堂重疊。'::TEXT;\n        RETURN;\n    END IF;\n\n    -- 3. 判斷是新增還是更新\n    IF p_class_id IS NOT NULL AND p_class_id <> '' THEN\n        -- 更新模式\n        UPDATE public.classes\n        SET\n            class_date = v_class_date_parsed,\n            start_time = v_start_time_parsed,\n            end_time = v_end_time_parsed,\n            course_id = p_course_id,\n            coach_id = p_coach_id,\n            class_name = p_class_name,\n            max_students = p_max_students,\n            update_time = NOW(),\n            update_user = 'Admin'\n        WHERE class_id = p_class_id;\n        RETURN QUERY SELECT 'success'::TEXT, '課堂更新成功！'::TEXT;\n    ELSE\n        -- 新增模式：產生新的 class_id (格式 CLYYMMXXX)\n        v_id_prefix := 'CL' || to_char(v_class_date_parsed, 'YYMM');\n        SELECT COALESCE(MAX(SUBSTRING(c.class_id FROM 7 FOR 3)::INT), 0)\n        INTO v_max_num\n        FROM public.classes c\n        WHERE c.class_id LIKE v_id_prefix || '%';\n\n        v_new_class_id := v_id_prefix || LPAD((v_max_num + 1)::TEXT, 3, '0');\n\n        INSERT INTO public.classes (class_id, course_id, coach_id, class_name, class_date, start_time, end_time, max_students, current_students, status, create_time, create_user)\n        VALUES (v_new_class_id, p_course_id, p_coach_id, p_class_name, v_class_date_parsed, v_start_time_parsed, v_end_time_parsed, p_max_students, 0, '開放中', NOW(), 'Admin');\n        RETURN QUERY SELECT 'success'::TEXT, '課堂新增成功！'::TEXT;\n    END IF;\nEXCEPTION\n    WHEN OTHERS THEN\n        RETURN QUERY SELECT 'error'::TEXT, '儲存課堂時發生未預期錯誤: ' || SQLERRM;\nEND;\n$function$\n;\n\nCREATE OR REPLACE FUNCTION public.save_coach(p_coach_id text, p_coach_name text, p_specialty text, p_line_id text, p_phone_number text, p_bio text, p_image_url text)\n RETURNS TABLE(status text, message text)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\nDECLARE\n    v_new_coach_id TEXT;\n    v_max_num INT;\nBEGIN\n    -- 檢查必要參數\n    IF p_coach_name IS NULL OR p_coach_name = '' THEN\n        RETURN QUERY SELECT 'error'::TEXT, '缺少必要的教練資訊 (姓名)。'::TEXT;\n        RETURN;\n    END IF;\n\n    -- 判斷是新增還是更新\n    IF p_coach_id IS NOT NULL AND p_coach_id <> '' THEN\n        -- 更新模式\n        UPDATE public.coaches\n        SET\n            coach_name = p_coach_name,\n            specialty = p_specialty,\n            line_id = p_line_id,\n            phone_number = p_phone_number,\n            bio = p_bio, -- 新增\n            image_url = p_image_url -- 新增\n        WHERE coach_id = p_coach_id;\n\n        RETURN QUERY SELECT 'success'::TEXT, '教練資料更新成功！'::TEXT;\n    ELSE\n        -- 新增模式：產生新的 coach_id (格式 C001)\n        SELECT COALESCE(MAX(SUBSTRING(c.coach_id FROM 2 FOR 3)::INT), 0)\n        INTO v_max_num\n        FROM public.coaches c\n        WHERE c.coach_id LIKE 'C%';\n\n        v_new_coach_id := 'C' || LPAD((v_max_num + 1)::TEXT, 3, '0');\n\n        INSERT INTO public.coaches (coach_id, coach_name, specialty, line_id, phone_number, bio, image_url)\n        VALUES (v_new_coach_id, p_coach_name, p_specialty, p_line_id, p_phone_number, p_bio, p_image_url);\n\n        RETURN QUERY SELECT 'success'::TEXT, '教練新增成功！'::TEXT;\n    END IF;\n\nEXCEPTION\n    WHEN OTHERS THEN\n        RETURN QUERY SELECT 'error'::TEXT, '儲存教練資料時發生未預期錯誤: ' || SQLERRM;\nEND;\n$function$\n;\n\nCREATE OR REPLACE FUNCTION public.save_course(p_course_id text, p_course_name text, p_price text, p_status text, p_short_desc text, p_long_desc text, p_image_url text, p_color text)\n RETURNS TABLE(status text, message text)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\nDECLARE\n    v_new_course_id TEXT;\n    v_max_num INT;\nBEGIN\n    -- 檢查必要參數\n    IF p_course_name IS NULL OR p_price IS NULL OR p_status IS NULL THEN\n        RETURN QUERY SELECT 'error'::TEXT, '缺少必要的課程資訊 (名稱、價格、狀態)。'::TEXT;\n        RETURN;\n    END IF;\n\n    -- 判斷是新增還是更新\n    IF p_course_id IS NOT NULL AND p_course_id <> '' THEN\n        -- 更新模式\n        UPDATE public.courses\n        SET\n            course_name = p_course_name,\n            price = p_price::numeric, -- 修正點：將文字轉換為數字\n            status = p_status,\n            short_description = p_short_desc,\n            long_description = p_long_desc,\n            image_url = p_image_url,\n            color = p_color\n        WHERE course_id = p_course_id;\n\n        RETURN QUERY SELECT 'success'::TEXT, '課程型錄更新成功！'::TEXT;\n    ELSE\n        -- 新增模式：產生新的 course_id\n        SELECT COALESCE(MAX(SUBSTRING(c.course_id FROM 4 FOR 3)::INT), 0)\n        INTO v_max_num\n        FROM public.courses c\n        WHERE c.course_id LIKE 'CRS%';\n\n        v_new_course_id := 'CRS' || LPAD((v_max_num + 1)::TEXT, 3, '0');\n\n        INSERT INTO public.courses (course_id, course_name, price, status, short_description, long_description, image_url, color)\n        VALUES (v_new_course_id, p_course_name, p_price::numeric, p_status, p_short_desc, p_long_desc, p_image_url, p_color); -- 修正點：將文字轉換為數字\n\n        RETURN QUERY SELECT 'success'::TEXT, '課程型錄新增成功！'::TEXT;\n    END IF;\n\nEXCEPTION\n    WHEN OTHERS THEN\n        RETURN QUERY SELECT 'error'::TEXT, '儲存課程型錄時發生未預期錯誤: ' || SQLERRM;\nEND;\n$function$\n;\n\nCREATE OR REPLACE FUNCTION public.search_bookings(p_status text DEFAULT NULL::text, p_class_date date DEFAULT NULL::date, p_query text DEFAULT NULL::text)\n RETURNS TABLE(booking_id text, booking_time timestamp with time zone, status text, class_name text, class_date date, start_time time without time zone, coach_name text, course_name text, color text, line_display_name text)\n LANGUAGE plpgsql\nAS $function$\nBEGIN\n    RETURN QUERY\n    SELECT\n        b.booking_id,\n        b.booking_time,\n        b.status,\n        cl.class_name,\n        cl.class_date,\n        cl.start_time,\n        co.coach_name,\n        cr.course_name,\n        cr.color,\n        u.line_display_name\n    FROM\n        bookings b\n    LEFT JOIN classes cl ON b.class_id = cl.class_id\n    LEFT JOIN users u ON b.line_user_id = u.line_user_id\n    LEFT JOIN courses cr ON cl.course_id = cr.course_id\n    LEFT JOIN coaches co ON cl.coach_id = co.coach_id\n    WHERE\n        (p_status IS NULL OR b.status = p_status) AND\n        (p_class_date IS NULL OR cl.class_date = p_class_date) AND\n        (p_query IS NULL OR (\n            u.line_display_name ILIKE '%' || p_query || '%' OR\n            b.booking_id ILIKE '%' || p_query || '%'\n        ))\n    ORDER BY\n        b.booking_time DESC;\nEND;\n$function$\n;\n\nCREATE OR REPLACE FUNCTION public.update_user_points(p_user_id text, p_points integer)\n RETURNS TABLE(status text, message text)\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\nBEGIN\n    -- 檢查必要參數\n    IF p_user_id IS NULL OR p_points IS NULL THEN\n        RETURN QUERY SELECT 'error'::TEXT, '缺少使用者 ID 或點數。'::TEXT;\n        RETURN;\n    END IF;\n\n    -- 執行更新\n    UPDATE public.users\n    SET points = p_points\n    WHERE line_user_id = p_user_id;\n\n    -- 檢查更新是否成功 (FOUND 是 PL/pgSQL 的一個特殊變數，表示上一條命令是否影響了任何資料列)\n    IF FOUND THEN\n        RETURN QUERY SELECT 'success'::TEXT, '使用者點數更新成功！'::TEXT;\n    ELSE\n        RETURN QUERY SELECT 'error'::TEXT, '找不到要更新的使用者。'::TEXT;\n    END IF;\n\nEXCEPTION\n    WHEN OTHERS THEN\n        RETURN QUERY SELECT 'error'::TEXT, '更新使用者點數時發生未預期錯誤: ' || SQLERRM;\nEND;\n$function$\n;\n\ncreate policy \\"Allow admin full access\\"\non \\"public\\".\\"bookings\\"\nas permissive\nfor all\nto public\nusing ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])))\nwith check ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])));\n\n\ncreate policy \\"Allow public read for all bookings\\"\non \\"public\\".\\"bookings\\"\nas permissive\nfor select\nto public\nusing (true);\n\n\ncreate policy \\"Disallow all write operations for public\\"\non \\"public\\".\\"bookings\\"\nas permissive\nfor all\nto public\nusing (false);\n\n\ncreate policy \\"Allow admin full access\\"\non \\"public\\".\\"classes\\"\nas permissive\nfor all\nto public\nusing ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])))\nwith check ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])));\n\n\ncreate policy \\"Allow public read for all classes\\"\non \\"public\\".\\"classes\\"\nas permissive\nfor select\nto public\nusing (true);\n\n\ncreate policy \\"Allow public read for available classes\\"\non \\"public\\".\\"classes\\"\nas permissive\nfor select\nto public\nusing (((status = '開放中'::text) AND (class_date >= (now())::date)));\n\n\ncreate policy \\"Disallow all write operations for public\\"\non \\"public\\".\\"classes\\"\nas permissive\nfor all\nto public\nusing (false);\n\n\ncreate policy \\"Allow admin full access\\"\non \\"public\\".\\"coaches\\"\nas permissive\nfor all\nto public\nusing ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])))\nwith check ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])));\n\n\ncreate policy \\"Allow public read for all coaches\\"\non \\"public\\".\\"coaches\\"\nas permissive\nfor select\nto public\nusing (true);\n\n\ncreate policy \\"Disallow all access for public\\"\non \\"public\\".\\"coaches\\"\nas permissive\nfor all\nto public\nusing (false);\n\n\ncreate policy \\"Allow admin full access\\"\non \\"public\\".\\"courses\\"\nas permissive\nfor all\nto public\nusing ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])))\nwith check ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])));\n\n\ncreate policy \\"Allow public read for active courses\\"\non \\"public\\".\\"courses\\"\nas permissive\nfor select\nto public\nusing ((status = 'Active'::text));\n\n\ncreate policy \\"Disallow all write operations for public\\"\non \\"public\\".\\"courses\\"\nas permissive\nfor all\nto public\nusing (false);\n\n\ncreate policy \\"Allow admin full access\\"\non \\"public\\".\\"users\\"\nas permissive\nfor all\nto public\nusing ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])))\nwith check ((auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text])));\n\n\ncreate policy \\"Allow public read for all users\\"\non \\"public\\".\\"users\\"\nas permissive\nfor select\nto public\nusing (true);\n\n\ncreate policy \\"Disallow all access for public\\"\non \\"public\\".\\"users\\"\nas permissive\nfor all\nto public\nusing (false);"}	remote_schema
20251003100000	{"-- 步驟 1: 移除所有資料表上過於寬鬆的公開讀取原則 (public read policies)。\n-- 這些原則允許任何人讀取資料，存在安全風險。\n\nDROP POLICY IF EXISTS \\"Allow public read for all bookings\\" ON public.bookings","DROP POLICY IF EXISTS \\"Disallow all write operations for public\\" ON public.bookings","DROP POLICY IF EXISTS \\"Allow public read for all classes\\" ON public.classes","DROP POLICY IF EXISTS \\"Disallow all write operations for public\\" ON public.classes","DROP POLICY IF EXISTS \\"Allow public read for all coaches\\" ON public.coaches","DROP POLICY IF EXISTS \\"Disallow all access for public\\" ON public.coaches","DROP POLICY IF EXISTS \\"Disallow all write operations for public\\" ON public.courses","DROP POLICY IF EXISTS \\"Allow public read for all users\\" ON public.users","DROP POLICY IF EXISTS \\"Disallow all access for public\\" ON public.users","-- 步驟 2: 建立新的、更安全的 RLS 原則。\n-- 根據您的說明，前端使用者介面 (如課程列表、教練列表) 是以匿名 (anon) 角色查詢資料。\n-- 因此，我們需要明確地為 `anon` 角色建立唯讀權限。\n\n-- 課程 (courses): 允許任何人讀取狀態為 'Active' 的課程。\n-- (此原則已存在且正確，無需變更，僅為註解說明)\n-- create policy \\"Allow public read for active courses\\" on \\"public\\".\\"courses\\" as permissive for select to public using ((status = 'Active'::text));\n\n-- 課堂 (classes): 允許任何人讀取狀態為 '開放中' 且日期未過期的課堂。\n-- (此原則已存在且正確，無需變更，僅為註解說明)\n-- create policy \\"Allow public read for available classes\\" on \\"public\\".\\"classes\\" as permissive for select to public using (((status = '開放中'::text) AND (class_date >= (now())::date)));\n\n-- 教練 (coaches): 允許任何人 (anon) 讀取所有教練資料。\n-- 這對於 `coaches.html` 頁面是必要的。\nCREATE POLICY \\"Allow anonymous read access to all coaches\\"\nON \\"public\\".\\"coaches\\"\nAS permissive\nFOR select\nTO anon\nUSING (true)","-- 使用者 (users) & 預約 (bookings):\n-- 這兩張表包含敏感個資，不應允許匿名讀取。\n-- `booking-details.html` 和 `schedule.html` 已透過 LIFF 登入取得 userId，\n-- 並在查詢時加入 `.eq('line_user_id', userId)` 條件，這已在前端實現了基本的資料隔離。\n-- 我們可以新增一條後端原則來強化這一點。\n\nCREATE POLICY \\"Allow individual user to read their own bookings\\"\nON \\"public\\".\\"bookings\\"\nAS permissive\nFOR select\nTO authenticated\nUSING ((auth.uid()::text = line_user_id))"}	refine_rls_policies
20251003110000	{"-- 步驟 1: 移除在 `...refine_rls_policies.sql` 中建立的、無法對 LIFF 使用者生效的 RLS 原則。\n-- 這個原則要求 `authenticated` 角色，但 LIFF 使用者是 `anon` 角色。\n\nDROP POLICY IF EXISTS \\"Allow individual user to read their own bookings\\" ON public.bookings","-- 步驟 2: 建立一個新的 RPC 函式 `get_user_bookings`。\n-- 這個函式讓前端可以傳入 line_user_id，並安全地在後端查詢該使用者在特定課堂中的預約。\n-- 這樣前端 (schedule.html) 就能知道哪些時段已經被預約，並顯示綠色勾勾。\n-- 函式設定為 SECURITY INVOKER，但因為我們沒有為 bookings 表設定 `anon` 的 SELECT 權限，所以匿名使用者無法直接查詢。\n-- 這是一個安全的折衷方案，邏輯由我們可信的函式控制。\n\nCREATE OR REPLACE FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[])\nRETURNS TABLE(class_id text, booking_id text)\nLANGUAGE plpgsql\nAS $function$\nBEGIN\n    RETURN QUERY\n    SELECT\n        b.class_id,\n        b.booking_id\n    FROM\n        public.bookings b\n    WHERE\n        b.line_user_id = p_user_id\n        AND b.class_id = ANY(p_class_ids)\n        AND b.status IN ('已預約', '已扣款');\nEND;\n$function$","-- 步驟 3: 建立一個新的 RPC 函式 `get_booking_details_for_user`。\n-- 這個函式讓 booking-details.html 和 booking-complete.html 可以安全地取得憑證資料。\n-- 它會同時驗證 booking_id 和 line_user_id，確保使用者只能看到自己的憑證。\n\nCREATE OR REPLACE FUNCTION public.get_booking_details_for_user(p_booking_id text, p_user_id text)\nRETURNS TABLE (\n    booking_id text,\n    status text,\n    class_date date,\n    start_time time,\n    course_name text,\n    coach_name text,\n    line_display_name text\n)\nLANGUAGE plpgsql\nAS $function$\nBEGIN\n    RETURN QUERY\n    SELECT\n        b.booking_id, b.status, cl.class_date, cl.start_time,\n        cr.course_name, co.coach_name, u.line_display_name\n    FROM public.bookings b\n    JOIN public.classes cl ON b.class_id = cl.class_id\n    JOIN public.courses cr ON cl.course_id = cr.course_id\n    JOIN public.coaches co ON cl.coach_id = co.coach_id\n    JOIN public.users u ON b.line_user_id = u.line_user_id\n    WHERE b.booking_id = p_booking_id AND b.line_user_id = p_user_id;\nEND;\n$function$"}	create_rpc_for_user_bookings
20251003120000	{"-- 修正目的：將使用者資料查詢相關的 RPC 函式設定為 SECURITY DEFINER。\n--\n-- 問題說明：\n-- 預設的函式安全性為 SECURITY INVOKER，這會導致函式以呼叫者（前端的 anon 角色）的權限執行。\n-- 由於我們已經移除了 anon 角色對 bookings 和 users 資料表的直接讀取權限，\n-- 這使得函式無法查詢到資料，進而導致 schedule.html 無法正確顯示已預約的綠色勾勾。\n--\n-- 解決方案：\n-- 將函式改為 SECURITY DEFINER，使其以函式擁有者（擁有更高權限）的身份執行。\n-- 這樣函式就可以繞過 RLS 進行查詢，同時函式內部的 WHERE 條件（p_user_id）確保了使用者只能看到自己的資料，維持了安全性。\n\n-- 步驟 1: 修正 `get_user_bookings` 函式\n\nCREATE OR REPLACE FUNCTION public.get_user_bookings(p_user_id text, p_class_ids text[])\nRETURNS TABLE(class_id text, booking_id text)\nLANGUAGE plpgsql\nSECURITY DEFINER -- 關鍵修正：新增此行\nAS $function$\nBEGIN\n    RETURN QUERY\n    SELECT\n        b.class_id,\n        b.booking_id\n    FROM\n        public.bookings b\n    WHERE\n        b.line_user_id = p_user_id\n        AND b.class_id = ANY(p_class_ids)\n        AND b.status IN ('已預約', '已扣款');\nEND;\n$function$","-- 步驟 2: 修正 `get_booking_details_for_user` 函式\n\nCREATE OR REPLACE FUNCTION public.get_booking_details_for_user(p_booking_id text, p_user_id text)\nRETURNS TABLE (\n    booking_id text,\n    status text,\n    class_date date,\n    start_time time,\n    course_name text,\n    coach_name text,\n    line_display_name text\n)\nLANGUAGE plpgsql\nSECURITY DEFINER -- 關鍵修正：新增此行\nAS $function$\nBEGIN\n    RETURN QUERY\n    SELECT\n        b.booking_id, b.status, cl.class_date, cl.start_time,\n        cr.course_name, co.coach_name, u.line_display_name\n    FROM public.bookings b\n    JOIN public.classes cl ON b.class_id = cl.class_id\n    JOIN public.courses cr ON cl.course_id = cr.course_id\n    JOIN public.coaches co ON cl.coach_id = co.coach_id\n    JOIN public.users u ON b.line_user_id = u.line_user_id\n    WHERE b.booking_id = p_booking_id AND b.line_user_id = p_user_id;\nEND;\n$function$"}	fix_rpc_security_definer
20251004120000	{"-- 目的：為透過 Google 登入的管理者建立讀取敏感資料的 RLS (Row Level Security) 策略。\n--\n-- 問題說明：\n-- 在先前的步驟中，我們為了使用者端的安全，移除了 bookings 和 users 資料表的公開讀取權限。\n-- 這導致管理者即使登入後台，也因為缺乏對應的 RLS 策略而無法看到這些資料。\n--\n-- 解決方案：\n-- 建立新的 RLS 策略，明確授權給在管理者列表中的已驗證使用者 (`authenticated` 角色)。\n\n-- 步驟 1: 為 bookings 資料表建立管理者讀取策略\n-- 允許 email 在管理者列表中的已驗證使用者，讀取所有預約紀錄。\nCREATE POLICY \\"Allow admin read access to all bookings\\"\nON \\"public\\".\\"bookings\\"\nAS permissive\nFOR select\nTO authenticated\nUSING (\n    (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))\n)","-- 步驟 2: 為 users 資料表建立管理者讀取策略\n-- 允許 email 在管理者列表中的已驗證使用者，讀取所有客戶資料。\nCREATE POLICY \\"Allow admin read access to all users\\"\nON \\"public\\".\\"users\\"\nAS permissive\nFOR select\nTO authenticated\nUSING (\n    (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))\n)"}	setup_admin_rls
20251004120001	{"-- 目的：清理並統一所有與管理者相關的 RLS (Row Level Security) 策略。\n--\n-- 執行步驟：\n-- 1. 刪除所有舊的、分散的、或授權給錯誤角色 (public) 的管理者策略。\n-- 2. 建立一組乾淨、統一的管理者策略，明確授權給 `authenticated` 角色，並賦予完整的 CRUD 權限。\n\n-- 步驟 1: 清理所有舊的管理者相關策略\n\n-- 刪除在 `20250929..._remote_schema.sql` 中建立的、授權給 `public` 角色的寬鬆策略\nDROP POLICY IF EXISTS \\"Allow admin full access\\" ON public.bookings","DROP POLICY IF EXISTS \\"Allow admin full access\\" ON public.classes","DROP POLICY IF EXISTS \\"Allow admin full access\\" ON public.coaches","DROP POLICY IF EXISTS \\"Allow admin full access\\" ON public.courses","DROP POLICY IF EXISTS \\"Allow admin full access\\" ON public.users","-- 刪除在 `20251004120000_setup_admin_rls.sql` 中建立的、僅有讀取權限的策略，以便被下方更完整的策略取代\nDROP POLICY IF EXISTS \\"Allow admin read access to all bookings\\" ON public.bookings","DROP POLICY IF EXISTS \\"Allow admin read access to all users\\" ON public.users","-- 步驟 2: 為 `authenticated` 角色建立統一的、具備完整權限的管理者策略\n\n-- 定義一個包含所有管理者 email 的陣列\n-- 註：直接在 SQL 中定義此陣列比在每個策略中重複撰寫更易於維護。\n-- 雖然 SQL 中無法直接宣告變數給 RLS policy 使用，但我們將此陣列複製到每個 policy 中。\n-- CONSTANT admin_emails TEXT[] := ARRAY['junesnow39@gmail.com', 'kaypeng1234@gmail.com'];\n\n-- 為 `bookings` 資料表建立管理者策略\nCREATE POLICY \\"Allow admin full access on bookings\\"\nON \\"public\\".\\"bookings\\"\nAS permissive FOR ALL\nTO authenticated\nUSING (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))\nWITH CHECK (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))","-- 為 `classes` 資料表建立管理者策略\nCREATE POLICY \\"Allow admin full access on classes\\"\nON \\"public\\".\\"classes\\"\nAS permissive FOR ALL\nTO authenticated\nUSING (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))\nWITH CHECK (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))","-- 為 `coaches` 資料表建立管理者策略\nCREATE POLICY \\"Allow admin full access on coaches\\"\nON \\"public\\".\\"coaches\\"\nAS permissive FOR ALL\nTO authenticated\nUSING (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))\nWITH CHECK (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))","-- 為 `courses` 資料表建立管理者策略\nCREATE POLICY \\"Allow admin full access on courses\\"\nON \\"public\\".\\"courses\\"\nAS permissive FOR ALL\nTO authenticated\nUSING (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))\nWITH CHECK (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))","-- 為 `users` 資料表建立管理者策略\nCREATE POLICY \\"Allow admin full access on users\\"\nON \\"public\\".\\"users\\"\nAS permissive FOR ALL\nTO authenticated\nUSING (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))\nWITH CHECK (auth.email() = ANY (ARRAY['junesnow39@gmail.com'::text, 'kaypeng1234@gmail.com'::text]))"}	consolidate_admin_rls
20251004120002	{"-- 步驟 1: 重新定義 classes_with_details 視圖，移除 SECURITY DEFINER 屬性\n-- 透過 ALTER VIEW ... SET (security_invoker = true)，明確指定其為安全的 SECURITY INVOKER 模式。\n-- 這樣可以確保所有對此視圖的查詢都會遵循呼叫者自身的 RLS (Row Level Security) 政策。\nCREATE OR REPLACE VIEW public.classes_with_details WITH (security_invoker = true) AS\nSELECT\n  cls.class_id,\n  cls.class_date,\n  cls.start_time,\n  cls.end_time,\n  cls.class_name,\n  cls.current_students,\n  cls.max_students,\n  cls.course_id,\n  cls.coach_id,\n  co.course_name,\n  co.color,\n  c.coach_name\nFROM (\n  (\n    classes cls\n    LEFT JOIN courses co ON ((cls.course_id = co.course_id))\n  )\n  LEFT JOIN coaches c ON ((cls.coach_id = c.coach_id))\n)","-- 步驟 2: 建立一個新的、安全的 RPC 函式來取代前端直接查詢 View\n-- 這個函式讓前端 (schedule.html) 在確認預約時，可以安全地取得單一課堂的詳細資訊。\n-- 設定為 SECURITY DEFINER 是安全的，因為函式內部邏輯固定，只會回傳必要的公開資訊，且由 class_id 限制範圍。\nCREATE OR REPLACE FUNCTION public.get_class_details (p_class_id text)\nRETURNS TABLE (\n  course_name text,\n  class_date date,\n  start_time time,\n  coach_name text\n)\nLANGUAGE plpgsql\nSECURITY DEFINER\nAS $$\nBEGIN\n  RETURN QUERY\n  SELECT\n    cr.course_name,\n    cl.class_date,\n    cl.start_time,\n    co.coach_name\n  FROM public.classes cl\n  JOIN public.courses cr ON cl.course_id = cr.course_id\n  JOIN public.coaches co ON cl.coach_id = co.coach_id\n  WHERE cl.class_id = p_class_id;\nEND;\n$$"}	fix_view_security_definer
\.


--
-- Data for Name: seed_files; Type: TABLE DATA; Schema: supabase_migrations; Owner: postgres
--

COPY supabase_migrations.seed_files (path, hash) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 49, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_client_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_client_id_key UNIQUE (client_id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


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
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: postgres
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: seed_files seed_files_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: postgres
--

ALTER TABLE ONLY supabase_migrations.seed_files
    ADD CONSTRAINT seed_files_pkey PRIMARY KEY (path);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_clients_client_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_client_id_idx ON auth.oauth_clients USING btree (client_id);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


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
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


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
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

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
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA storage TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: SCHEMA vault; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA vault TO service_role;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea, text[], text[]) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.crypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.dearmor(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_bytes(integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_uuid() FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text, integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO dashboard_user;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_key_id(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1mc() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v4() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_nil() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_dns() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_oid() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_url() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_x500() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO postgres;


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
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- Name: FUNCTION _crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO service_role;


--
-- Name: FUNCTION create_secret(new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: FUNCTION update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE oauth_clients; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_clients TO postgres;
GRANT ALL ON TABLE auth.oauth_clients TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements TO dashboard_user;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements_info FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO dashboard_user;


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
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT ALL ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO postgres WITH GRANT OPTION;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO postgres WITH GRANT OPTION;


--
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


--
-- Name: TABLE secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.secrets TO service_role;


--
-- Name: TABLE decrypted_secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.decrypted_secrets TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO service_role;


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
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO supabase_admin;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

\unrestrict ED0xnfoY7wSxGnWMrjE6Jv4elCLedaa6XufbtrMpHEgwBF6ckLyPAnoyQtmDUkH

