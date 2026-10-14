


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE OR REPLACE FUNCTION "public"."create_employer_company"("p_name" "text", "p_description" "text" DEFAULT NULL::"text", "p_industry" "text" DEFAULT NULL::"text", "p_company_size" "text" DEFAULT NULL::"text", "p_website" "text" DEFAULT NULL::"text", "p_location" "text" DEFAULT NULL::"text", "p_contact_first_name" "text" DEFAULT NULL::"text", "p_contact_last_name" "text" DEFAULT NULL::"text", "p_contact_email" "text" DEFAULT NULL::"text", "p_contact_phone" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
declare
    v_user_id uuid;
    v_company_id uuid;
begin
    v_user_id := auth.uid();

    if v_user_id is null then
        raise exception 'Not authenticated';
    end if;

    if not exists (
        select 1
        from public.profiles
        where id = v_user_id
          and account_role = 'employer'
    ) then
        raise exception 'Employer account required';
    end if;

    if exists (
        select 1
        from public.company_memberships
        where user_id = v_user_id
    ) then
        raise exception 'Employer already belongs to a company';
    end if;

    if nullif(trim(p_name), '') is null then
        raise exception 'Company name is required';
    end if;

    if nullif(trim(p_industry), '') is null then
        raise exception 'Industry is required';
    end if;

    if nullif(trim(p_location), '') is null then
        raise exception 'Location is required';
    end if;

    if nullif(trim(p_contact_first_name), '') is null then
        raise exception 'Contact first name is required';
    end if;

    if nullif(trim(p_contact_last_name), '') is null then
        raise exception 'Contact last name is required';
    end if;

    if nullif(trim(p_contact_email), '') is null then
        raise exception 'Contact email is required';
    end if;

    insert into public.companies (
        name,
        description,
        industry,
        company_size,
        website,
        location,
        contact_first_name,
        contact_last_name,
        contact_email,
        contact_phone,
        onboarding_completed
    )
    values (
        trim(p_name),
        nullif(trim(p_description), ''),
        trim(p_industry),
        nullif(trim(p_company_size), ''),
        nullif(trim(p_website), ''),
        trim(p_location),
        trim(p_contact_first_name),
        trim(p_contact_last_name),
        trim(p_contact_email),
        nullif(trim(p_contact_phone), ''),
        true
    )
    returning id into v_company_id;

    insert into public.company_memberships (
        company_id,
        user_id,
        role,
        verification_status
    )
    values (
        v_company_id,
        v_user_id,
        'admin',
        'unverified'
    );

    return v_company_id;
end;
$$;


ALTER FUNCTION "public"."create_employer_company"("p_name" "text", "p_description" "text", "p_industry" "text", "p_company_size" "text", "p_website" "text", "p_location" "text", "p_contact_first_name" "text", "p_contact_last_name" "text", "p_contact_email" "text", "p_contact_phone" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_employer_interview_slot"("p_match_id" "uuid", "p_starts_at" timestamp with time zone, "p_ends_at" timestamp with time zone) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
declare
    v_slot_id uuid;
begin
    if auth.uid() is null then
        raise exception 'Not authenticated';
    end if;

    if p_starts_at <= now() then
        raise exception 'Interview slot must be in the future';
    end if;

    if p_ends_at <= p_starts_at then
        raise exception 'Interview end must be after start';
    end if;

    if not exists (
        select 1
        from public.matches m
        join public.jobs j
            on j.id = m.job_id
        join public.company_memberships cm
            on cm.company_id = j.company_id
        where m.id = p_match_id
          and cm.user_id = auth.uid()
    ) then
        raise exception 'Match does not belong to employer';
    end if;

    if exists (
        select 1
        from public.interviews i
        where i.match_id = p_match_id
    ) then
        raise exception 'Interview already confirmed';
    end if;

    insert into public.interview_slots (
        match_id,
        starts_at,
        ends_at
    )
    values (
        p_match_id,
        p_starts_at,
        p_ends_at
    )
    returning id into v_slot_id;

    return v_slot_id;
end;
$$;


ALTER FUNCTION "public"."create_employer_interview_slot"("p_match_id" "uuid", "p_starts_at" timestamp with time zone, "p_ends_at" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_mutual_match_if_eligible"("p_job_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
declare
    v_candidate_id uuid := auth.uid();
begin
    if v_candidate_id is null then
        raise exception 'Authentication required';
    end if;

    -- Nur Kandidaten dürfen diesen Einstieg verwenden.
    if not exists (
        select 1
        from public.profiles p
        where p.id = v_candidate_id
          and p.account_role = 'candidate'
    ) then
        raise exception 'Candidate account required';
    end if;

    return public.create_mutual_match_internal(
        p_job_id,
        v_candidate_id
    );
end;
$$;


ALTER FUNCTION "public"."create_mutual_match_if_eligible"("p_job_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_mutual_match_internal"("p_job_id" "uuid", "p_candidate_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$declare
    v_match_id uuid;
begin
    -- Kandidat muss MATCH gewählt haben.
    if not exists (
        select 1
        from public.candidate_job_interactions
        where candidate_id = p_candidate_id
          and job_id = p_job_id
          and decision = 'match'
    ) then
        return null;
    end if;

    -- Arbeitgeber muss MATCH gewählt haben.
    if not exists (
        select 1
        from public.employer_job_interactions
        where candidate_id = p_candidate_id
          and job_id = p_job_id
          and decision = 'match'
    ) then
        return null;
    end if;

    -- Mutual Match erzeugen / vorhandenen Match wiederverwenden.
    insert into public.matches (
        candidate_id,
        job_id
    )
    values (
        p_candidate_id,
        p_job_id
    )
    on conflict (candidate_id, job_id)
    do update set
        updated_at = pg_catalog.now()
    returning id into v_match_id;

    -- Interview-Slots werden ab jetzt ausschließlich
    -- vom Arbeitgeber vorgeschlagen.
    return v_match_id;
end;$$;


ALTER FUNCTION "public"."create_mutual_match_internal"("p_job_id" "uuid", "p_candidate_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_own_matches_for_poc"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
declare
    v_candidate_id uuid := auth.uid();
begin
    if v_candidate_id is null then
        raise exception 'Authentication required';
    end if;

    delete from public.matches
    where candidate_id = v_candidate_id;
end;
$$;


ALTER FUNCTION "public"."delete_own_matches_for_poc"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_confirmed_candidate_contact"("p_match_id" "uuid") RETURNS TABLE("first_name" "text", "last_name" "text", "phone_number" "text")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    select
        p.first_name,
        p.last_name,
        p.phone_number
    from public.matches m
    join public.jobs j
        on j.id = m.job_id
    join public.company_memberships cm
        on cm.company_id = j.company_id
    join public.interviews i
        on i.match_id = m.id
    join public.profiles p
        on p.id = m.candidate_id
    where m.id = p_match_id
      and cm.user_id = auth.uid()
      and p.account_role = 'candidate';
$$;


ALTER FUNCTION "public"."get_confirmed_candidate_contact"("p_match_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_employer_candidate_educations"("p_job_id" "uuid") RETURNS TABLE("id" "uuid", "candidate_id" "uuid", "institution_name" "text", "degree" "text", "field_of_study" "text", "start_date" "date", "end_date" "date", "is_current" boolean, "description" "text")
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
    if not public.is_own_company_job(p_job_id) then
        raise exception 'Not authorized for this job';
    end if;

    return query
    select
        e.id,
        e.candidate_id,

        -- Privacy-safe placeholder
        ''::text as institution_name,

        e.degree,
        e.field_of_study,

        -- Für Matching nicht erforderlich
        null::date as start_date,
        null::date as end_date,
        false::boolean as is_current,
        null::text as description

    from public.educations e
    join public.candidate_profiles cp
        on cp.user_id = e.candidate_id
    where cp.onboarding_completed = true;
end;
$$;


ALTER FUNCTION "public"."get_employer_candidate_educations"("p_job_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_employer_candidate_languages"("p_job_id" "uuid") RETURNS TABLE("candidate_id" "uuid", "language_id" "uuid", "proficiency" "text")
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
    if not public.is_own_company_job(p_job_id) then
        raise exception 'Not authorized for this job';
    end if;

    return query
    select
        cl.candidate_id,
        cl.language_id,
        cl.proficiency
    from public.candidate_languages cl
    join public.candidate_profiles cp
        on cp.user_id = cl.candidate_id
    where cp.onboarding_completed = true;
end;
$$;


ALTER FUNCTION "public"."get_employer_candidate_languages"("p_job_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_employer_candidate_skills"("p_job_id" "uuid") RETURNS TABLE("candidate_id" "uuid", "skill_id" "uuid", "proficiency" "text")
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
    if not public.is_own_company_job(p_job_id) then
        raise exception 'Not authorized for this job';
    end if;

    return query
    select
        cs.candidate_id,
        cs.skill_id,
        cs.proficiency
    from public.candidate_skills cs
    join public.candidate_profiles cp
        on cp.user_id = cs.candidate_id
    where cp.onboarding_completed = true;
end;
$$;


ALTER FUNCTION "public"."get_employer_candidate_skills"("p_job_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_employer_candidate_work_experiences"("p_job_id" "uuid") RETURNS TABLE("id" "uuid", "candidate_id" "uuid", "job_title" "text", "employer_name" "text", "location" "text", "start_date" "date", "end_date" "date", "is_current" boolean, "description" "text")
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
    if not public.is_own_company_job(p_job_id) then
        raise exception 'Not authorized for this job';
    end if;

    return query
    select
        we.id,
        we.candidate_id,

        -- Privacy-safe placeholders.
        -- MatchingService benötigt diese Felder nicht.
        ''::text as job_title,
        ''::text as employer_name,
        null::text as location,

        we.start_date,
        we.end_date,
        we.is_current,

        null::text as description

    from public.work_experiences we
    join public.candidate_profiles cp
        on cp.user_id = we.candidate_id
    where cp.onboarding_completed = true;
end;
$$;


ALTER FUNCTION "public"."get_employer_candidate_work_experiences"("p_job_id" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."interviews" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "match_id" "uuid" NOT NULL,
    "interview_slot_id" "uuid" NOT NULL,
    "confirmed_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."interviews" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_employer_interview"("p_match_id" "uuid") RETURNS SETOF "public"."interviews"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    select i.*
    from public.interviews i
    join public.matches m
        on m.id = i.match_id
    join public.jobs j
        on j.id = m.job_id
    join public.company_memberships cm
        on cm.company_id = j.company_id
    where i.match_id = p_match_id
      and cm.user_id = auth.uid();
$$;


ALTER FUNCTION "public"."get_employer_interview"("p_match_id" "uuid") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."interview_slots" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "match_id" "uuid" NOT NULL,
    "starts_at" timestamp with time zone NOT NULL,
    "ends_at" timestamp with time zone NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "interview_slots_valid_time" CHECK (("ends_at" > "starts_at"))
);


ALTER TABLE "public"."interview_slots" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_employer_interview_slots"("p_match_id" "uuid") RETURNS SETOF "public"."interview_slots"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    select s.*
    from public.interview_slots s
    join public.matches m
        on m.id = s.match_id
    join public.jobs j
        on j.id = m.job_id
    join public.company_memberships cm
        on cm.company_id = j.company_id
    where s.match_id = p_match_id
      and cm.user_id = auth.uid()
    order by s.starts_at asc;
$$;


ALTER FUNCTION "public"."get_employer_interview_slots"("p_match_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_employer_matched_candidate"("p_match_id" "uuid") RETURNS TABLE("user_id" "uuid", "has_work_authorization" boolean, "desired_workload_min" integer, "desired_workload_max" integer, "desired_work_latitude" double precision, "desired_work_longitude" double precision, "work_radius_km" integer, "willing_to_commute" boolean, "willing_to_relocate" boolean, "preferred_work_model" "text", "homeoffice_preference" "text", "desired_homeoffice_days" integer, "preferred_homeoffice_schedule" "text", "accepts_fully_remote" boolean, "salary_min" integer, "salary_max" integer)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    select
        cp.user_id,
        cp.has_work_authorization,
        cp.desired_workload_min,
        cp.desired_workload_max,
        cp.desired_work_latitude,
        cp.desired_work_longitude,
        cp.work_radius_km,
        cp.willing_to_commute,
        cp.willing_to_relocate,
        cp.preferred_work_model::text,
        cp.homeoffice_preference::text,
        cp.desired_homeoffice_days,
        cp.preferred_homeoffice_schedule::text,
        cp.accepts_fully_remote,
        cp.salary_min,
        cp.salary_max
    from public.matches m
    join public.jobs j
        on j.id = m.job_id
    join public.company_memberships cm
        on cm.company_id = j.company_id
       and cm.user_id = auth.uid()
    join public.candidate_profiles cp
        on cp.user_id = m.candidate_id
    where m.id = p_match_id
      and auth.uid() is not null
    limit 1;
$$;


ALTER FUNCTION "public"."get_employer_matched_candidate"("p_match_id" "uuid") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."matches" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "candidate_id" "uuid" NOT NULL,
    "job_id" "uuid" NOT NULL,
    "matched_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."matches" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_employer_matches"() RETURNS SETOF "public"."matches"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    select m.*
    from public.matches m
    join public.jobs j
        on j.id = m.job_id
    join public.company_memberships cm
        on cm.company_id = j.company_id
    where cm.user_id = auth.uid()
    order by m.matched_at desc;
$$;


ALTER FUNCTION "public"."get_employer_matches"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_employer_matching_candidates"("p_job_id" "uuid") RETURNS TABLE("user_id" "uuid", "has_work_authorization" boolean, "desired_workload_min" integer, "desired_workload_max" integer, "desired_work_latitude" double precision, "desired_work_longitude" double precision, "work_radius_km" integer, "willing_to_commute" boolean, "willing_to_relocate" boolean, "preferred_work_model" "text", "homeoffice_preference" "text", "desired_homeoffice_days" integer, "preferred_homeoffice_schedule" "text", "accepts_fully_remote" boolean, "salary_min" integer, "salary_max" integer)
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
    if not public.is_own_company_job(p_job_id) then
        raise exception 'Not authorized for this job';
    end if;

    return query
    select
        cp.user_id,
        cp.has_work_authorization,
        cp.desired_workload_min,
        cp.desired_workload_max,
        cp.desired_work_latitude,
        cp.desired_work_longitude,
        cp.work_radius_km,
        cp.willing_to_commute,
        cp.willing_to_relocate,
        cp.preferred_work_model,
        cp.homeoffice_preference,
        cp.desired_homeoffice_days,
        cp.preferred_homeoffice_schedule,
        cp.accepts_fully_remote,
        cp.salary_min,
        cp.salary_max
    from public.candidate_profiles cp
    where cp.onboarding_completed = true
      and not exists (
          select 1
          from public.employer_job_interactions eji
          where eji.job_id = p_job_id
            and eji.candidate_id = cp.user_id
      );
end;
$$;


ALTER FUNCTION "public"."get_employer_matching_candidates"("p_job_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
declare
    v_account_role text;
begin
    v_account_role :=
        case
            when new.raw_user_meta_data ->> 'account_role' = 'employer'
                then 'employer'
            else 'candidate'
        end;

    insert into public.profiles (
        id,
        account_role
    )
    values (
        new.id,
        v_account_role
    );

    if v_account_role = 'candidate' then
        insert into public.candidate_profiles (
            user_id
        )
        values (
            new.id
        );
    end if;

    return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_own_company_job"("p_job_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    select exists (
        select 1
        from public.jobs j
        join public.company_memberships cm
            on cm.company_id = j.company_id
        where j.id = p_job_id
          and cm.user_id = auth.uid()
    );
$$;


ALTER FUNCTION "public"."is_own_company_job"("p_job_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."reset_employer_for_poc"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
declare
    v_employer_id uuid := auth.uid();
    v_company_id uuid;
begin
    if v_employer_id is null then
        raise exception 'Authentication required';
    end if;

    if not exists (
        select 1
        from public.profiles p
        where p.id = v_employer_id
          and p.account_role = 'employer'
    ) then
        raise exception 'Employer account required';
    end if;

    select cm.company_id
    into v_company_id
    from public.company_memberships cm
    where cm.user_id = v_employer_id
    limit 1;

    if v_company_id is null then
        raise exception 'Employer company required';
    end if;

    -- Interviews zuerst explizit entfernen, damit die
    -- RESTRICT-Beziehung zu interview_slots nicht stört.
    delete from public.interviews i
    where exists (
        select 1
        from public.matches m
        join public.jobs j
          on j.id = m.job_id
        where m.id = i.match_id
          and j.company_id = v_company_id
    );

    -- Jobs löschen.
    -- Abhängige Requirements, Interactions, Matches und
    -- Interview-Slots werden über die vorhandenen CASCADE-FKs entfernt.
    delete from public.jobs j
    where j.company_id = v_company_id;

    -- Company-Profil auf den Zustand vor abgeschlossenem
    -- Employer-Onboarding zurücksetzen.
    update public.companies
    set
        description = null,
        industry = null,
        company_size = null,
        website = null,
        location = null,
        contact_first_name = null,
        contact_last_name = null,
        contact_email = null,
        contact_phone = null,
        onboarding_completed = false,
        updated_at = now()
    where id = v_company_id;
end;
$$;


ALTER FUNCTION "public"."reset_employer_for_poc"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."save_employer_candidate_decision"("p_job_id" "uuid", "p_candidate_id" "uuid", "p_decision" "text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
declare
    v_match_id uuid;
begin
    if p_decision not in ('match', 'pass') then
        raise exception 'Invalid employer decision';
    end if;

    if not public.is_own_company_job(p_job_id) then
        raise exception 'Not authorized for this job';
    end if;

    if not exists (
        select 1
        from public.profiles p
        where p.id = p_candidate_id
          and p.account_role = 'candidate'
    ) then
        raise exception 'Invalid candidate';
    end if;

    insert into public.employer_job_interactions (
        job_id,
        candidate_id,
        decision,
        updated_at
    )
    values (
        p_job_id,
        p_candidate_id,
        p_decision,
        pg_catalog.now()
    )
    on conflict (job_id, candidate_id)
    do update set
        decision = excluded.decision,
        updated_at = pg_catalog.now();

    if p_decision = 'match' then
        v_match_id := public.create_mutual_match_internal(
            p_job_id,
            p_candidate_id
        );
    end if;

    return v_match_id;
end;
$$;


ALTER FUNCTION "public"."save_employer_candidate_decision"("p_job_id" "uuid", "p_candidate_id" "uuid", "p_decision" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."seed_employer_jobs_for_poc"() RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
declare
    v_employer_id uuid := auth.uid();
    v_company_id uuid;

    v_job_software uuid;
    v_job_product uuid;
    v_job_hr uuid;
    v_job_accountant uuid;
    v_job_sales uuid;
    v_job_marketing uuid;
    v_job_project uuid;
    v_job_analyst uuid;
    v_job_customer uuid;
    v_job_operations uuid;

    v_german uuid;
    v_english uuid;
begin
    -- Auth prüfen
    if v_employer_id is null then
        raise exception 'Authentication required';
    end if;

    -- Employer-Rolle prüfen
    if not exists (
        select 1
        from public.profiles p
        where p.id = v_employer_id
          and p.account_role = 'employer'
    ) then
        raise exception 'Employer account required';
    end if;

    -- Eigene Firma bestimmen
    select cm.company_id
    into v_company_id
    from public.company_memberships cm
    where cm.user_id = v_employer_id
    limit 1;

    if v_company_id is null then
        raise exception 'Employer company required';
    end if;

    if not exists (
        select 1
        from public.companies c
        where c.id = v_company_id
          and c.onboarding_completed = true
    ) then
        raise exception 'Employer onboarding required';
    end if;

    -- Taxonomien auflösen
    select id
    into v_german
    from public.languages
    where name = 'Deutsch (Hochdeutsch)'
    limit 1;

    select id
    into v_english
    from public.languages
    where name = 'Englisch'
    limit 1;

    if v_german is null or v_english is null then
        raise exception 'Required language taxonomy missing';
    end if;

    -- 1 Software Engineer
    insert into public.jobs (
        company_id,
        title,
        description,
        activity_area,
        location,
        work_model,
        workload_min,
        workload_max,
        salary_min,
        salary_max,
        required_work_experience_years,
        work_experience_requirement_type,
        requires_work_authorization,
        work_authorization_requirement_type,
        homeoffice_available,
        homeoffice_days,
        homeoffice_schedule,
        fully_remote_available,
        homeoffice_requirement_type,
        work_model_requirement_type,
        is_active
    )
    values (
        v_company_id,
        'Software Engineer',
        'Entwicklung moderner Web-Anwendungen und APIs in einem interdisziplinären Produktteam.',
        'Softwareentwicklung',
        'Zürich',
        'hybrid',
        80,
        100,
        105000,
        135000,
        3,
        'must',
        true,
        'must',
        true,
        2,
        'flexible',
        false,
        'optional',
        'optional',
        true
    )
    returning id into v_job_software;

    -- 2 Product Manager
    insert into public.jobs (
        company_id, title, description, activity_area, location,
        work_model, workload_min, workload_max,
        salary_min, salary_max,
        required_work_experience_years,
        work_experience_requirement_type,
        requires_work_authorization,
        work_authorization_requirement_type,
        homeoffice_available, homeoffice_days,
        homeoffice_schedule, fully_remote_available,
        homeoffice_requirement_type,
        work_model_requirement_type,
        is_active
    )
    values (
        v_company_id,
        'Product Manager',
        'Verantwortung für Produktstrategie, Priorisierung und Zusammenarbeit mit Design und Engineering.',
        'Produktmanagement',
        'Zürich',
        'hybrid',
        80,
        100,
        110000,
        140000,
        4,
        'must',
        true,
        'must',
        true,
        2,
        'flexible',
        false,
        'optional',
        'optional',
        true
    )
    returning id into v_job_product;

    -- 3 HR Specialist
    insert into public.jobs (
        company_id, title, description, activity_area, location,
        work_model, workload_min, workload_max,
        salary_min, salary_max,
        required_work_experience_years,
        work_experience_requirement_type,
        requires_work_authorization,
        work_authorization_requirement_type,
        homeoffice_available, homeoffice_days,
        homeoffice_schedule, fully_remote_available,
        homeoffice_requirement_type,
        work_model_requirement_type,
        is_active
    )
    values (
        v_company_id,
        'HR Specialist',
        'Betreuung von Mitarbeitenden und Unterstützung entlang des gesamten Employee Lifecycles.',
        'Human Resources',
        'Winterthur',
        'hybrid',
        60,
        100,
        85000,
        105000,
        2,
        'optional',
        true,
        'must',
        true,
        2,
        'flexible',
        false,
        'optional',
        'optional',
        true
    )
    returning id into v_job_hr;

    -- 4 Accountant
    insert into public.jobs (
        company_id, title, description, activity_area, location,
        work_model, workload_min, workload_max,
        salary_min, salary_max,
        required_work_experience_years,
        work_experience_requirement_type,
        requires_work_authorization,
        work_authorization_requirement_type,
        homeoffice_available, homeoffice_days,
        homeoffice_schedule, fully_remote_available,
        homeoffice_requirement_type,
        work_model_requirement_type,
        is_active
    )
    values (
        v_company_id,
        'Accountant',
        'Verantwortung für Finanzbuchhaltung, Monatsabschlüsse und Unterstützung bei Finanzprozessen.',
        'Finanzen',
        'Zürich',
        'onsite',
        80,
        100,
        90000,
        115000,
        3,
        'must',
        true,
        'must',
        true,
        1,
        'fixed',
        false,
        'optional',
        'must',
        true
    )
    returning id into v_job_accountant;

    -- 5 Sales Manager
    insert into public.jobs (
        company_id, title, description, activity_area, location,
        work_model, workload_min, workload_max,
        salary_min, salary_max,
        required_work_experience_years,
        work_experience_requirement_type,
        requires_work_authorization,
        work_authorization_requirement_type,
        homeoffice_available, homeoffice_days,
        homeoffice_schedule, fully_remote_available,
        homeoffice_requirement_type,
        work_model_requirement_type,
        is_active
    )
    values (
        v_company_id,
        'Sales Manager',
        'Aufbau langfristiger Kundenbeziehungen und Entwicklung neuer Geschäftsmöglichkeiten.',
        'Sales',
        'Zürich',
        'hybrid',
        80,
        100,
        100000,
        135000,
        3,
        'must',
        true,
        'must',
        true,
        2,
        'flexible',
        false,
        'optional',
        'optional',
        true
    )
    returning id into v_job_sales;

    -- 6 Marketing Manager
    insert into public.jobs (
        company_id, title, description, activity_area, location,
        work_model, workload_min, workload_max,
        salary_min, salary_max,
        required_work_experience_years,
        work_experience_requirement_type,
        requires_work_authorization,
        work_authorization_requirement_type,
        homeoffice_available, homeoffice_days,
        homeoffice_schedule, fully_remote_available,
        homeoffice_requirement_type,
        work_model_requirement_type,
        is_active
    )
    values (
        v_company_id,
        'Marketing Manager',
        'Planung und Umsetzung digitaler Marketingkampagnen sowie Weiterentwicklung unserer Marke.',
        'Marketing',
        'Winterthur',
        'hybrid',
        80,
        100,
        95000,
        120000,
        3,
        'optional',
        true,
        'must',
        true,
        2,
        'flexible',
        false,
        'optional',
        'optional',
        true
    )
    returning id into v_job_marketing;

    -- 7 Project Manager
    insert into public.jobs (
        company_id, title, description, activity_area, location,
        work_model, workload_min, workload_max,
        salary_min, salary_max,
        required_work_experience_years,
        work_experience_requirement_type,
        requires_work_authorization,
        work_authorization_requirement_type,
        homeoffice_available, homeoffice_days,
        homeoffice_schedule, fully_remote_available,
        homeoffice_requirement_type,
        work_model_requirement_type,
        is_active
    )
    values (
        v_company_id,
        'Project Manager',
        'Planung und Steuerung bereichsübergreifender Projekte von der Konzeption bis zur Umsetzung.',
        'Projektmanagement',
        'Zürich',
        'hybrid',
        80,
        100,
        100000,
        130000,
        4,
        'must',
        true,
        'must',
        true,
        2,
        'flexible',
        false,
        'optional',
        'optional',
        true
    )
    returning id into v_job_project;

    -- 8 Business Analyst
    insert into public.jobs (
        company_id, title, description, activity_area, location,
        work_model, workload_min, workload_max,
        salary_min, salary_max,
        required_work_experience_years,
        work_experience_requirement_type,
        requires_work_authorization,
        work_authorization_requirement_type,
        homeoffice_available, homeoffice_days,
        homeoffice_schedule, fully_remote_available,
        homeoffice_requirement_type,
        work_model_requirement_type,
        is_active
    )
    values (
        v_company_id,
        'Business Analyst',
        'Analyse von Geschäftsprozessen, Daten und Anforderungen sowie Entwicklung umsetzbarer Lösungen.',
        'Business Analysis',
        'Zürich',
        'remote',
        80,
        100,
        100000,
        125000,
        2,
        'must',
        true,
        'must',
        true,
        5,
        'flexible',
        true,
        'must',
        'optional',
        true
    )
    returning id into v_job_analyst;

    -- 9 Customer Success Manager
    insert into public.jobs (
        company_id, title, description, activity_area, location,
        work_model, workload_min, workload_max,
        salary_min, salary_max,
        required_work_experience_years,
        work_experience_requirement_type,
        requires_work_authorization,
        work_authorization_requirement_type,
        homeoffice_available, homeoffice_days,
        homeoffice_schedule, fully_remote_available,
        homeoffice_requirement_type,
        work_model_requirement_type,
        is_active
    )
    values (
        v_company_id,
        'Customer Success Manager',
        'Begleitung unserer Kunden nach dem Onboarding und langfristige Sicherstellung ihres Erfolgs.',
        'Customer Success',
        'Winterthur',
        'hybrid',
        80,
        100,
        90000,
        115000,
        2,
        'optional',
        true,
        'must',
        true,
        2,
        'flexible',
        false,
        'optional',
        'optional',
        true
    )
    returning id into v_job_customer;

    -- 10 Operations Manager
    insert into public.jobs (
        company_id, title, description, activity_area, location,
        work_model, workload_min, workload_max,
        salary_min, salary_max,
        required_work_experience_years,
        work_experience_requirement_type,
        requires_work_authorization,
        work_authorization_requirement_type,
        homeoffice_available, homeoffice_days,
        homeoffice_schedule, fully_remote_available,
        homeoffice_requirement_type,
        work_model_requirement_type,
        is_active
    )
    values (
        v_company_id,
        'Operations Manager',
        'Optimierung operativer Abläufe und Koordination bereichsübergreifender Prozesse.',
        'Operations',
        'Zürich',
        'onsite',
        80,
        100,
        100000,
        130000,
        4,
        'must',
        true,
        'must',
        false,
        null,
        null,
        false,
        'optional',
        'must',
        true
    )
    returning id into v_job_operations;

    -- =====================================================
    -- SKILLS
    -- =====================================================

    -- Software Engineer
    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_software, id, 'very_good', 'must'
    from public.skills
    where name = 'JavaScript / TypeScript';

    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_software, id, 'good', 'must'
    from public.skills
    where name = 'Git';

    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_software, id, 'good', 'optional'
    from public.skills
    where name = 'Docker';

    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_software, id, 'good', 'optional'
    from public.skills
    where name = 'React';

    -- Product Manager
    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_product, id, 'good', 'must'
    from public.skills
    where name = 'Jira';

    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_product, id, 'good', 'optional'
    from public.skills
    where name = 'Figma';

    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_product, id, 'good', 'optional'
    from public.skills
    where name = 'Confluence';

    -- HR
    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_hr, id, 'good', 'must'
    from public.skills
    where name = 'Microsoft Excel';

    -- Accountant
    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_accountant, id, 'very_good', 'must'
    from public.skills
    where name = 'Microsoft Excel';

    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_accountant, id, 'good', 'optional'
    from public.skills
    where name = 'SAP';

    -- Sales
    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_sales, id, 'good', 'must'
    from public.skills
    where name = 'Salesforce';

    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_sales, id, 'good', 'optional'
    from public.skills
    where name = 'Microsoft Excel';

    -- Marketing
    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_marketing, id, 'good', 'must'
    from public.skills
    where name = 'WordPress';

    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_marketing, id, 'basic', 'optional'
    from public.skills
    where name = 'Figma';

    -- Project Manager
    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_project, id, 'very_good', 'must'
    from public.skills
    where name = 'Jira';

    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_project, id, 'good', 'optional'
    from public.skills
    where name = 'Confluence';

    -- Business Analyst
    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_analyst, id, 'very_good', 'must'
    from public.skills
    where name = 'Microsoft Excel';

    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_analyst, id, 'good', 'must'
    from public.skills
    where name = 'SQL';

    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_analyst, id, 'good', 'optional'
    from public.skills
    where name = 'Microsoft Power BI';

    -- Customer Success
    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_customer, id, 'good', 'must'
    from public.skills
    where name = 'Salesforce';

    -- Operations
    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_operations, id, 'very_good', 'must'
    from public.skills
    where name = 'Microsoft Excel';

    insert into public.job_skills
        (job_id, skill_id, minimum_proficiency, requirement_type)
    select v_job_operations, id, 'good', 'optional'
    from public.skills
    where name = 'SAP';

    -- =====================================================
    -- LANGUAGES
    -- =====================================================

    -- Software
    insert into public.job_languages
        (job_id, language_id, minimum_proficiency, requirement_type)
    values
        (v_job_software, v_english, 'b2', 'must'),
        (v_job_software, v_german, 'b1', 'optional');

    -- Product
    insert into public.job_languages
        (job_id, language_id, minimum_proficiency, requirement_type)
    values
        (v_job_product, v_german, 'c1', 'must'),
        (v_job_product, v_english, 'b2', 'must');

    -- HR
    insert into public.job_languages
        (job_id, language_id, minimum_proficiency, requirement_type)
    values
        (v_job_hr, v_german, 'c1', 'must'),
        (v_job_hr, v_english, 'b1', 'optional');

    -- Accountant
    insert into public.job_languages
        (job_id, language_id, minimum_proficiency, requirement_type)
    values
        (v_job_accountant, v_german, 'c1', 'must'),
        (v_job_accountant, v_english, 'b1', 'optional');

    -- Sales
    insert into public.job_languages
        (job_id, language_id, minimum_proficiency, requirement_type)
    values
        (v_job_sales, v_german, 'c1', 'must'),
        (v_job_sales, v_english, 'b2', 'must');

    -- Marketing
    insert into public.job_languages
        (job_id, language_id, minimum_proficiency, requirement_type)
    values
        (v_job_marketing, v_german, 'b2', 'must'),
        (v_job_marketing, v_english, 'b2', 'optional');

    -- Project
    insert into public.job_languages
        (job_id, language_id, minimum_proficiency, requirement_type)
    values
        (v_job_project, v_german, 'c1', 'must'),
        (v_job_project, v_english, 'b2', 'optional');

    -- Analyst
    insert into public.job_languages
        (job_id, language_id, minimum_proficiency, requirement_type)
    values
        (v_job_analyst, v_english, 'c1', 'must'),
        (v_job_analyst, v_german, 'b1', 'optional');

    -- Customer Success
    insert into public.job_languages
        (job_id, language_id, minimum_proficiency, requirement_type)
    values
        (v_job_customer, v_german, 'c1', 'must'),
        (v_job_customer, v_english, 'b2', 'must');

    -- Operations
    insert into public.job_languages
        (job_id, language_id, minimum_proficiency, requirement_type)
    values
        (v_job_operations, v_german, 'c1', 'must'),
        (v_job_operations, v_english, 'b1', 'optional');

    return 10;
end;
$$;


ALTER FUNCTION "public"."seed_employer_jobs_for_poc"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."select_interview_slot"("p_match_id" "uuid", "p_interview_slot_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$declare
    v_candidate_id uuid := auth.uid();
    v_interview_id uuid;
begin
    if v_candidate_id is null then
        raise exception 'Authentication required';
    end if;

    -- Match muss dem eingeloggten Kandidaten gehören.
    if not exists (
        select 1
        from public.matches
        where id = p_match_id
          and candidate_id = v_candidate_id
    ) then
        raise exception 'Match not found or access denied';
    end if;

    -- Ein bereits bestätigter Interviewtermin ist im PoC endgültig.
    if exists (
        select 1
        from public.interviews
        where match_id = p_match_id
    ) then
        raise exception 'Interview already confirmed';
    end if;

    -- Slot muss zu genau diesem Match gehören.
    if not exists (
        select 1
        from public.interview_slots
        where id = p_interview_slot_id
          and match_id = p_match_id
    ) then
        raise exception 'Interview slot not found or access denied';
    end if;

    insert into public.interviews (
        match_id,
        interview_slot_id
    )
    values (
        p_match_id,
        p_interview_slot_id
    )
    returning id into v_interview_id;

    return v_interview_id;
end;$$;


ALTER FUNCTION "public"."select_interview_slot"("p_match_id" "uuid", "p_interview_slot_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
begin
    new.updated_at = now();
    return new;
end;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."candidate_custom_skills" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "candidate_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "proficiency" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "candidate_custom_skills_name_not_empty" CHECK (("length"(TRIM(BOTH FROM "name")) > 0)),
    CONSTRAINT "candidate_custom_skills_proficiency_check" CHECK (("proficiency" = ANY (ARRAY['basic'::"text", 'good'::"text", 'very_good'::"text", 'expert'::"text"])))
);


ALTER TABLE "public"."candidate_custom_skills" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."candidate_job_interactions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "candidate_id" "uuid" NOT NULL,
    "job_id" "uuid" NOT NULL,
    "decision" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "candidate_job_interactions_decision_check" CHECK (("decision" = ANY (ARRAY['match'::"text", 'pass'::"text"])))
);


ALTER TABLE "public"."candidate_job_interactions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."candidate_languages" (
    "candidate_id" "uuid" NOT NULL,
    "language_id" "uuid" NOT NULL,
    "proficiency" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "candidate_languages_proficiency_check" CHECK (("proficiency" = ANY (ARRAY['a1'::"text", 'a2'::"text", 'b1'::"text", 'b2'::"text", 'c1'::"text", 'c2'::"text", 'native'::"text"])))
);


ALTER TABLE "public"."candidate_languages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."candidate_profiles" (
    "user_id" "uuid" NOT NULL,
    "region" "text",
    "nationality" "text",
    "has_work_authorization" boolean,
    "work_authorization_details" "text",
    "onboarding_step" integer DEFAULT 0 NOT NULL,
    "onboarding_completed" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "desired_workload_min" integer,
    "desired_workload_max" integer,
    "desired_work_location" "text",
    "work_radius_km" integer,
    "willing_to_commute" boolean,
    "willing_to_relocate" boolean,
    "earliest_start_date" "date",
    "preferred_work_model" "text",
    "homeoffice_preference" "text",
    "desired_homeoffice_days" integer,
    "preferred_homeoffice_schedule" "text",
    "accepts_fully_remote" boolean,
    "salary_min" integer,
    "salary_max" integer,
    "desired_work_latitude" double precision,
    "desired_work_longitude" double precision,
    CONSTRAINT "candidate_desired_work_latitude_range" CHECK ((("desired_work_latitude" IS NULL) OR (("desired_work_latitude" >= ('-90'::integer)::double precision) AND ("desired_work_latitude" <= (90)::double precision)))),
    CONSTRAINT "candidate_desired_work_longitude_range" CHECK ((("desired_work_longitude" IS NULL) OR (("desired_work_longitude" >= ('-180'::integer)::double precision) AND ("desired_work_longitude" <= (180)::double precision)))),
    CONSTRAINT "candidate_homeoffice_days_valid" CHECK ((("desired_homeoffice_days" IS NULL) OR (("desired_homeoffice_days" >= 0) AND ("desired_homeoffice_days" <= 5)))),
    CONSTRAINT "candidate_homeoffice_preference_valid" CHECK ((("homeoffice_preference" IS NULL) OR ("homeoffice_preference" = ANY (ARRAY['yes'::"text", 'no'::"text", 'either'::"text"])))),
    CONSTRAINT "candidate_homeoffice_schedule_valid" CHECK ((("preferred_homeoffice_schedule" IS NULL) OR ("preferred_homeoffice_schedule" = ANY (ARRAY['fixed'::"text", 'flexible'::"text", 'either'::"text"])))),
    CONSTRAINT "candidate_profiles_onboarding_step_check" CHECK ((("onboarding_step" >= 0) AND ("onboarding_step" <= 8))),
    CONSTRAINT "candidate_salary_max_valid" CHECK ((("salary_max" IS NULL) OR ("salary_max" >= 0))),
    CONSTRAINT "candidate_salary_min_valid" CHECK ((("salary_min" IS NULL) OR ("salary_min" >= 0))),
    CONSTRAINT "candidate_salary_range_valid" CHECK ((("salary_min" IS NULL) OR ("salary_max" IS NULL) OR ("salary_max" >= "salary_min"))),
    CONSTRAINT "candidate_work_model_valid" CHECK ((("preferred_work_model" IS NULL) OR ("preferred_work_model" = ANY (ARRAY['onsite'::"text", 'hybrid'::"text", 'remote'::"text"])))),
    CONSTRAINT "candidate_work_radius_valid" CHECK ((("work_radius_km" IS NULL) OR ("work_radius_km" >= 0))),
    CONSTRAINT "candidate_workload_max_valid" CHECK ((("desired_workload_max" IS NULL) OR (("desired_workload_max" >= 10) AND ("desired_workload_max" <= 100)))),
    CONSTRAINT "candidate_workload_min_valid" CHECK ((("desired_workload_min" IS NULL) OR (("desired_workload_min" >= 10) AND ("desired_workload_min" <= 100)))),
    CONSTRAINT "candidate_workload_range_valid" CHECK ((("desired_workload_min" IS NULL) OR ("desired_workload_max" IS NULL) OR ("desired_workload_max" >= "desired_workload_min")))
);


ALTER TABLE "public"."candidate_profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."candidate_skills" (
    "candidate_id" "uuid" NOT NULL,
    "skill_id" "uuid" NOT NULL,
    "proficiency" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "candidate_skills_proficiency_check" CHECK (("proficiency" = ANY (ARRAY['basic'::"text", 'good'::"text", 'very_good'::"text", 'expert'::"text"])))
);


ALTER TABLE "public"."candidate_skills" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."companies" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "industry" "text",
    "company_size" "text",
    "website" "text",
    "location" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "contact_first_name" "text",
    "contact_last_name" "text",
    "contact_email" "text",
    "contact_phone" "text",
    "onboarding_completed" boolean DEFAULT false NOT NULL,
    CONSTRAINT "companies_name_check" CHECK (("char_length"(TRIM(BOTH FROM "name")) > 0))
);


ALTER TABLE "public"."companies" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."company_memberships" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "company_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'member'::"text" NOT NULL,
    "verification_status" "text" DEFAULT 'unverified'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "company_memberships_role_check" CHECK (("role" = ANY (ARRAY['admin'::"text", 'member'::"text"]))),
    CONSTRAINT "company_memberships_verification_status_check" CHECK (("verification_status" = ANY (ARRAY['unverified'::"text", 'pending'::"text", 'verified'::"text"])))
);


ALTER TABLE "public"."company_memberships" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."educations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "candidate_id" "uuid" NOT NULL,
    "institution_name" "text" NOT NULL,
    "degree" "text" NOT NULL,
    "field_of_study" "text",
    "start_date" "date",
    "end_date" "date",
    "is_current" boolean DEFAULT false NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "current_education_has_no_end_date" CHECK (((("is_current" = true) AND ("end_date" IS NULL)) OR ("is_current" = false))),
    CONSTRAINT "education_dates_valid" CHECK ((("start_date" IS NULL) OR ("end_date" IS NULL) OR ("end_date" >= "start_date"))),
    CONSTRAINT "educations_degree_check" CHECK (("char_length"(TRIM(BOTH FROM "degree")) > 0)),
    CONSTRAINT "educations_institution_name_check" CHECK (("char_length"(TRIM(BOTH FROM "institution_name")) > 0))
);


ALTER TABLE "public"."educations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."employer_job_interactions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "job_id" "uuid" NOT NULL,
    "candidate_id" "uuid" NOT NULL,
    "decision" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "employer_job_interactions_decision_check" CHECK (("decision" = ANY (ARRAY['match'::"text", 'pass'::"text"])))
);


ALTER TABLE "public"."employer_job_interactions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."job_education_requirements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "job_id" "uuid" NOT NULL,
    "degree" "text" NOT NULL,
    "field_of_study" "text",
    "requirement_type" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "job_education_requirements_degree_not_empty" CHECK (("length"(TRIM(BOTH FROM "degree")) > 0)),
    CONSTRAINT "job_education_requirements_requirement_type_check" CHECK (("requirement_type" = ANY (ARRAY['must'::"text", 'optional'::"text"])))
);


ALTER TABLE "public"."job_education_requirements" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."job_languages" (
    "job_id" "uuid" NOT NULL,
    "language_id" "uuid" NOT NULL,
    "minimum_proficiency" "text" NOT NULL,
    "requirement_type" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "job_languages_minimum_proficiency_check" CHECK (("minimum_proficiency" = ANY (ARRAY['a1'::"text", 'a2'::"text", 'b1'::"text", 'b2'::"text", 'c1'::"text", 'c2'::"text", 'native'::"text"]))),
    CONSTRAINT "job_languages_requirement_type_check" CHECK (("requirement_type" = ANY (ARRAY['must'::"text", 'optional'::"text"])))
);


ALTER TABLE "public"."job_languages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."job_skills" (
    "job_id" "uuid" NOT NULL,
    "skill_id" "uuid" NOT NULL,
    "minimum_proficiency" "text" NOT NULL,
    "requirement_type" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "job_skills_minimum_proficiency_check" CHECK (("minimum_proficiency" = ANY (ARRAY['basic'::"text", 'good'::"text", 'very_good'::"text", 'expert'::"text"]))),
    CONSTRAINT "job_skills_requirement_type_check" CHECK (("requirement_type" = ANY (ARRAY['must'::"text", 'optional'::"text"])))
);


ALTER TABLE "public"."job_skills" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."jobs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "company_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text" NOT NULL,
    "activity_area" "text",
    "location" "text" NOT NULL,
    "work_model" "text" NOT NULL,
    "workload_min" integer NOT NULL,
    "workload_max" integer NOT NULL,
    "earliest_start_date" "date",
    "salary_min" integer,
    "salary_max" integer,
    "required_work_experience_years" integer,
    "work_experience_requirement_type" "text" DEFAULT 'optional'::"text" NOT NULL,
    "requires_work_authorization" boolean DEFAULT true NOT NULL,
    "work_authorization_requirement_type" "text" DEFAULT 'must'::"text" NOT NULL,
    "homeoffice_available" boolean DEFAULT false NOT NULL,
    "homeoffice_days" integer,
    "homeoffice_schedule" "text",
    "fully_remote_available" boolean DEFAULT false NOT NULL,
    "work_model_requirement_type" "text" DEFAULT 'optional'::"text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "latitude" double precision,
    "longitude" double precision,
    "homeoffice_requirement_type" "text" DEFAULT 'optional'::"text" NOT NULL,
    CONSTRAINT "jobs_description_check" CHECK (("char_length"(TRIM(BOTH FROM "description")) > 0)),
    CONSTRAINT "jobs_homeoffice_days_check" CHECK ((("homeoffice_days" IS NULL) OR (("homeoffice_days" >= 0) AND ("homeoffice_days" <= 5)))),
    CONSTRAINT "jobs_homeoffice_requirement_type_check" CHECK (("homeoffice_requirement_type" = ANY (ARRAY['must'::"text", 'optional'::"text"]))),
    CONSTRAINT "jobs_homeoffice_schedule_check" CHECK ((("homeoffice_schedule" IS NULL) OR ("homeoffice_schedule" = ANY (ARRAY['fixed'::"text", 'flexible'::"text"])))),
    CONSTRAINT "jobs_latitude_range" CHECK ((("latitude" IS NULL) OR (("latitude" >= ('-90'::integer)::double precision) AND ("latitude" <= (90)::double precision)))),
    CONSTRAINT "jobs_location_check" CHECK (("char_length"(TRIM(BOTH FROM "location")) > 0)),
    CONSTRAINT "jobs_longitude_range" CHECK ((("longitude" IS NULL) OR (("longitude" >= ('-180'::integer)::double precision) AND ("longitude" <= (180)::double precision)))),
    CONSTRAINT "jobs_required_work_experience_years_check" CHECK ((("required_work_experience_years" IS NULL) OR ("required_work_experience_years" >= 0))),
    CONSTRAINT "jobs_salary_max_check" CHECK ((("salary_max" IS NULL) OR ("salary_max" >= 0))),
    CONSTRAINT "jobs_salary_min_check" CHECK ((("salary_min" IS NULL) OR ("salary_min" >= 0))),
    CONSTRAINT "jobs_salary_range_check" CHECK ((("salary_min" IS NULL) OR ("salary_max" IS NULL) OR ("salary_min" <= "salary_max"))),
    CONSTRAINT "jobs_title_check" CHECK (("char_length"(TRIM(BOTH FROM "title")) > 0)),
    CONSTRAINT "jobs_work_authorization_requirement_type_check" CHECK (("work_authorization_requirement_type" = ANY (ARRAY['must'::"text", 'optional'::"text"]))),
    CONSTRAINT "jobs_work_experience_requirement_type_check" CHECK (("work_experience_requirement_type" = ANY (ARRAY['must'::"text", 'optional'::"text"]))),
    CONSTRAINT "jobs_work_model_check" CHECK (("work_model" = ANY (ARRAY['onsite'::"text", 'hybrid'::"text", 'remote'::"text"]))),
    CONSTRAINT "jobs_work_model_requirement_type_check" CHECK (("work_model_requirement_type" = ANY (ARRAY['must'::"text", 'optional'::"text"]))),
    CONSTRAINT "jobs_workload_max_check" CHECK ((("workload_max" >= 10) AND ("workload_max" <= 100))),
    CONSTRAINT "jobs_workload_min_check" CHECK ((("workload_min" >= 10) AND ("workload_min" <= 100))),
    CONSTRAINT "jobs_workload_range_check" CHECK (("workload_min" <= "workload_max"))
);


ALTER TABLE "public"."jobs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."languages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "languages_name_not_empty" CHECK (("char_length"(TRIM(BOTH FROM "name")) > 0))
);


ALTER TABLE "public"."languages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "first_name" "text",
    "last_name" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "phone_number" "text",
    "account_role" "text" DEFAULT 'candidate'::"text" NOT NULL,
    CONSTRAINT "profiles_account_role_check" CHECK (("account_role" = ANY (ARRAY['candidate'::"text", 'employer'::"text"])))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."skills" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "category" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "skills_category_not_empty" CHECK (("char_length"(TRIM(BOTH FROM "category")) > 0)),
    CONSTRAINT "skills_name_not_empty" CHECK (("char_length"(TRIM(BOTH FROM "name")) > 0))
);


ALTER TABLE "public"."skills" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."work_experiences" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "candidate_id" "uuid" NOT NULL,
    "job_title" "text" NOT NULL,
    "employer_name" "text" NOT NULL,
    "location" "text",
    "start_date" "date" NOT NULL,
    "end_date" "date",
    "is_current" boolean DEFAULT false NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "current_work_experience_has_no_end_date" CHECK (((("is_current" = true) AND ("end_date" IS NULL)) OR ("is_current" = false))),
    CONSTRAINT "work_experience_dates_valid" CHECK ((("end_date" IS NULL) OR ("end_date" >= "start_date"))),
    CONSTRAINT "work_experiences_employer_name_check" CHECK (("char_length"(TRIM(BOTH FROM "employer_name")) > 0)),
    CONSTRAINT "work_experiences_job_title_check" CHECK (("char_length"(TRIM(BOTH FROM "job_title")) > 0))
);


ALTER TABLE "public"."work_experiences" OWNER TO "postgres";


ALTER TABLE ONLY "public"."candidate_custom_skills"
    ADD CONSTRAINT "candidate_custom_skills_candidate_name_unique" UNIQUE ("candidate_id", "name");



ALTER TABLE ONLY "public"."candidate_custom_skills"
    ADD CONSTRAINT "candidate_custom_skills_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."candidate_job_interactions"
    ADD CONSTRAINT "candidate_job_interactions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."candidate_job_interactions"
    ADD CONSTRAINT "candidate_job_interactions_unique" UNIQUE ("candidate_id", "job_id");



ALTER TABLE ONLY "public"."candidate_languages"
    ADD CONSTRAINT "candidate_languages_pkey" PRIMARY KEY ("candidate_id", "language_id");



ALTER TABLE ONLY "public"."candidate_profiles"
    ADD CONSTRAINT "candidate_profiles_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."candidate_skills"
    ADD CONSTRAINT "candidate_skills_pkey" PRIMARY KEY ("candidate_id", "skill_id");



ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."company_memberships"
    ADD CONSTRAINT "company_memberships_company_id_user_id_key" UNIQUE ("company_id", "user_id");



ALTER TABLE ONLY "public"."company_memberships"
    ADD CONSTRAINT "company_memberships_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."educations"
    ADD CONSTRAINT "educations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."employer_job_interactions"
    ADD CONSTRAINT "employer_job_interactions_job_id_candidate_id_key" UNIQUE ("job_id", "candidate_id");



ALTER TABLE ONLY "public"."employer_job_interactions"
    ADD CONSTRAINT "employer_job_interactions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interview_slots"
    ADD CONSTRAINT "interview_slots_match_id_starts_at_key" UNIQUE ("match_id", "starts_at");



ALTER TABLE ONLY "public"."interview_slots"
    ADD CONSTRAINT "interview_slots_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interviews"
    ADD CONSTRAINT "interviews_interview_slot_id_key" UNIQUE ("interview_slot_id");



ALTER TABLE ONLY "public"."interviews"
    ADD CONSTRAINT "interviews_match_id_key" UNIQUE ("match_id");



ALTER TABLE ONLY "public"."interviews"
    ADD CONSTRAINT "interviews_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."job_education_requirements"
    ADD CONSTRAINT "job_education_requirements_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."job_languages"
    ADD CONSTRAINT "job_languages_pkey" PRIMARY KEY ("job_id", "language_id");



ALTER TABLE ONLY "public"."job_skills"
    ADD CONSTRAINT "job_skills_pkey" PRIMARY KEY ("job_id", "skill_id");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."languages"
    ADD CONSTRAINT "languages_name_unique" UNIQUE ("name");



ALTER TABLE ONLY "public"."languages"
    ADD CONSTRAINT "languages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."matches"
    ADD CONSTRAINT "matches_candidate_id_job_id_key" UNIQUE ("candidate_id", "job_id");



ALTER TABLE ONLY "public"."matches"
    ADD CONSTRAINT "matches_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."skills"
    ADD CONSTRAINT "skills_name_unique" UNIQUE ("name");



ALTER TABLE ONLY "public"."skills"
    ADD CONSTRAINT "skills_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."work_experiences"
    ADD CONSTRAINT "work_experiences_pkey" PRIMARY KEY ("id");



CREATE INDEX "candidate_custom_skills_candidate_id_idx" ON "public"."candidate_custom_skills" USING "btree" ("candidate_id");



CREATE INDEX "candidate_job_interactions_candidate_id_idx" ON "public"."candidate_job_interactions" USING "btree" ("candidate_id");



CREATE INDEX "candidate_job_interactions_job_id_idx" ON "public"."candidate_job_interactions" USING "btree" ("job_id");



CREATE INDEX "candidate_languages_candidate_id_idx" ON "public"."candidate_languages" USING "btree" ("candidate_id");



CREATE INDEX "candidate_languages_language_id_idx" ON "public"."candidate_languages" USING "btree" ("language_id");



CREATE INDEX "candidate_skills_candidate_id_idx" ON "public"."candidate_skills" USING "btree" ("candidate_id");



CREATE INDEX "candidate_skills_skill_id_idx" ON "public"."candidate_skills" USING "btree" ("skill_id");



CREATE INDEX "company_memberships_company_id_idx" ON "public"."company_memberships" USING "btree" ("company_id");



CREATE INDEX "company_memberships_user_id_idx" ON "public"."company_memberships" USING "btree" ("user_id");



CREATE INDEX "educations_candidate_id_idx" ON "public"."educations" USING "btree" ("candidate_id");



CREATE INDEX "educations_candidate_start_date_idx" ON "public"."educations" USING "btree" ("candidate_id", "start_date" DESC);



CREATE INDEX "employer_job_interactions_candidate_id_idx" ON "public"."employer_job_interactions" USING "btree" ("candidate_id");



CREATE INDEX "employer_job_interactions_job_id_idx" ON "public"."employer_job_interactions" USING "btree" ("job_id");



CREATE INDEX "interview_slots_match_id_idx" ON "public"."interview_slots" USING "btree" ("match_id");



CREATE INDEX "interview_slots_starts_at_idx" ON "public"."interview_slots" USING "btree" ("starts_at");



CREATE INDEX "interviews_match_id_idx" ON "public"."interviews" USING "btree" ("match_id");



CREATE INDEX "job_education_requirements_job_id_idx" ON "public"."job_education_requirements" USING "btree" ("job_id");



CREATE INDEX "job_languages_language_id_idx" ON "public"."job_languages" USING "btree" ("language_id");



CREATE INDEX "job_skills_skill_id_idx" ON "public"."job_skills" USING "btree" ("skill_id");



CREATE INDEX "jobs_active_idx" ON "public"."jobs" USING "btree" ("is_active");



CREATE INDEX "jobs_company_id_idx" ON "public"."jobs" USING "btree" ("company_id");



CREATE INDEX "jobs_location_idx" ON "public"."jobs" USING "btree" ("location");



CREATE INDEX "matches_candidate_id_idx" ON "public"."matches" USING "btree" ("candidate_id");



CREATE INDEX "matches_job_id_idx" ON "public"."matches" USING "btree" ("job_id");



CREATE INDEX "work_experiences_candidate_id_idx" ON "public"."work_experiences" USING "btree" ("candidate_id");



CREATE INDEX "work_experiences_candidate_start_date_idx" ON "public"."work_experiences" USING "btree" ("candidate_id", "start_date" DESC);



CREATE OR REPLACE TRIGGER "candidate_languages_set_updated_at" BEFORE UPDATE ON "public"."candidate_languages" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "candidate_profiles_set_updated_at" BEFORE UPDATE ON "public"."candidate_profiles" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "candidate_skills_set_updated_at" BEFORE UPDATE ON "public"."candidate_skills" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "educations_set_updated_at" BEFORE UPDATE ON "public"."educations" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "profiles_set_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "work_experiences_set_updated_at" BEFORE UPDATE ON "public"."work_experiences" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



ALTER TABLE ONLY "public"."candidate_custom_skills"
    ADD CONSTRAINT "candidate_custom_skills_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."candidate_job_interactions"
    ADD CONSTRAINT "candidate_job_interactions_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."candidate_job_interactions"
    ADD CONSTRAINT "candidate_job_interactions_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."candidate_languages"
    ADD CONSTRAINT "candidate_languages_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "public"."candidate_profiles"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."candidate_languages"
    ADD CONSTRAINT "candidate_languages_language_id_fkey" FOREIGN KEY ("language_id") REFERENCES "public"."languages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."candidate_profiles"
    ADD CONSTRAINT "candidate_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."candidate_skills"
    ADD CONSTRAINT "candidate_skills_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "public"."candidate_profiles"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."candidate_skills"
    ADD CONSTRAINT "candidate_skills_skill_id_fkey" FOREIGN KEY ("skill_id") REFERENCES "public"."skills"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."company_memberships"
    ADD CONSTRAINT "company_memberships_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."company_memberships"
    ADD CONSTRAINT "company_memberships_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."educations"
    ADD CONSTRAINT "educations_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "public"."candidate_profiles"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."employer_job_interactions"
    ADD CONSTRAINT "employer_job_interactions_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."employer_job_interactions"
    ADD CONSTRAINT "employer_job_interactions_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."interview_slots"
    ADD CONSTRAINT "interview_slots_match_id_fkey" FOREIGN KEY ("match_id") REFERENCES "public"."matches"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."interviews"
    ADD CONSTRAINT "interviews_interview_slot_id_fkey" FOREIGN KEY ("interview_slot_id") REFERENCES "public"."interview_slots"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."interviews"
    ADD CONSTRAINT "interviews_match_id_fkey" FOREIGN KEY ("match_id") REFERENCES "public"."matches"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."job_education_requirements"
    ADD CONSTRAINT "job_education_requirements_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."job_languages"
    ADD CONSTRAINT "job_languages_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."job_languages"
    ADD CONSTRAINT "job_languages_language_id_fkey" FOREIGN KEY ("language_id") REFERENCES "public"."languages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."job_skills"
    ADD CONSTRAINT "job_skills_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."job_skills"
    ADD CONSTRAINT "job_skills_skill_id_fkey" FOREIGN KEY ("skill_id") REFERENCES "public"."skills"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."matches"
    ADD CONSTRAINT "matches_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."matches"
    ADD CONSTRAINT "matches_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."work_experiences"
    ADD CONSTRAINT "work_experiences_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "public"."candidate_profiles"("user_id") ON DELETE CASCADE;



CREATE POLICY "Authenticated users can read active job education requirements" ON "public"."job_education_requirements" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."jobs"
  WHERE (("jobs"."id" = "job_education_requirements"."job_id") AND ("jobs"."is_active" = true)))));



CREATE POLICY "Authenticated users can read active jobs" ON "public"."jobs" FOR SELECT TO "authenticated" USING (("is_active" = true));



CREATE POLICY "Authenticated users can read companies" ON "public"."companies" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can read languages" ON "public"."languages" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can read languages of active jobs" ON "public"."job_languages" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."jobs"
  WHERE (("jobs"."id" = "job_languages"."job_id") AND ("jobs"."is_active" = true)))));



CREATE POLICY "Authenticated users can read skills" ON "public"."skills" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can read skills of active jobs" ON "public"."job_skills" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."jobs"
  WHERE (("jobs"."id" = "job_skills"."job_id") AND ("jobs"."is_active" = true)))));



CREATE POLICY "Candidates can create own educations" ON "public"."educations" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can create own job interactions" ON "public"."candidate_job_interactions" FOR INSERT TO "authenticated" WITH CHECK (("candidate_id" = "auth"."uid"()));



CREATE POLICY "Candidates can create own languages" ON "public"."candidate_languages" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can create own skills" ON "public"."candidate_skills" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can create own work experiences" ON "public"."work_experiences" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can delete own custom skills" ON "public"."candidate_custom_skills" FOR DELETE TO "authenticated" USING (("candidate_id" = "auth"."uid"()));



CREATE POLICY "Candidates can delete own educations" ON "public"."educations" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can delete own interactions" ON "public"."candidate_job_interactions" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "candidate_id"));



CREATE POLICY "Candidates can delete own languages" ON "public"."candidate_languages" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can delete own skills" ON "public"."candidate_skills" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can delete own work experiences" ON "public"."work_experiences" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can insert own custom skills" ON "public"."candidate_custom_skills" FOR INSERT TO "authenticated" WITH CHECK (("candidate_id" = "auth"."uid"()));



CREATE POLICY "Candidates can read own candidate profile" ON "public"."candidate_profiles" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Candidates can read own custom skills" ON "public"."candidate_custom_skills" FOR SELECT TO "authenticated" USING (("candidate_id" = "auth"."uid"()));



CREATE POLICY "Candidates can read own educations" ON "public"."educations" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can read own job interactions" ON "public"."candidate_job_interactions" FOR SELECT TO "authenticated" USING (("candidate_id" = "auth"."uid"()));



CREATE POLICY "Candidates can read own languages" ON "public"."candidate_languages" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can read own skills" ON "public"."candidate_skills" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can read own work experiences" ON "public"."work_experiences" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can update own candidate profile" ON "public"."candidate_profiles" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Candidates can update own custom skills" ON "public"."candidate_custom_skills" FOR UPDATE TO "authenticated" USING (("candidate_id" = "auth"."uid"())) WITH CHECK (("candidate_id" = "auth"."uid"()));



CREATE POLICY "Candidates can update own educations" ON "public"."educations" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "candidate_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can update own job interactions" ON "public"."candidate_job_interactions" FOR UPDATE TO "authenticated" USING (("candidate_id" = "auth"."uid"())) WITH CHECK (("candidate_id" = "auth"."uid"()));



CREATE POLICY "Candidates can update own languages" ON "public"."candidate_languages" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "candidate_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can update own skills" ON "public"."candidate_skills" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "candidate_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can update own work experiences" ON "public"."work_experiences" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "candidate_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "candidate_id"));



CREATE POLICY "Candidates can view own interview slots" ON "public"."interview_slots" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."matches"
  WHERE (("matches"."id" = "interview_slots"."match_id") AND ("matches"."candidate_id" = "auth"."uid"())))));



CREATE POLICY "Candidates can view own interviews" ON "public"."interviews" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."matches"
  WHERE (("matches"."id" = "interviews"."match_id") AND ("matches"."candidate_id" = "auth"."uid"())))));



CREATE POLICY "Candidates can view own matches" ON "public"."matches" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "candidate_id"));



CREATE POLICY "Company members can create education requirements for own jobs" ON "public"."job_education_requirements" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."jobs" "j"
     JOIN "public"."company_memberships" "cm" ON (("cm"."company_id" = "j"."company_id")))
  WHERE (("j"."id" = "job_education_requirements"."job_id") AND ("cm"."user_id" = "auth"."uid"())))));



CREATE POLICY "Company members can create language requirements for own jobs" ON "public"."job_languages" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."jobs" "j"
     JOIN "public"."company_memberships" "cm" ON (("cm"."company_id" = "j"."company_id")))
  WHERE (("j"."id" = "job_languages"."job_id") AND ("cm"."user_id" = "auth"."uid"())))));



CREATE POLICY "Company members can create own company jobs" ON "public"."jobs" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."company_memberships" "cm"
  WHERE (("cm"."company_id" = "jobs"."company_id") AND ("cm"."user_id" = "auth"."uid"())))));



CREATE POLICY "Company members can create skill requirements for own jobs" ON "public"."job_skills" FOR INSERT TO "authenticated" WITH CHECK ("public"."is_own_company_job"("job_id"));



CREATE POLICY "Company members can delete education requirements for own jobs" ON "public"."job_education_requirements" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."jobs" "j"
     JOIN "public"."company_memberships" "cm" ON (("cm"."company_id" = "j"."company_id")))
  WHERE (("j"."id" = "job_education_requirements"."job_id") AND ("cm"."user_id" = "auth"."uid"())))));



CREATE POLICY "Company members can delete language requirements for own jobs" ON "public"."job_languages" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."jobs" "j"
     JOIN "public"."company_memberships" "cm" ON (("cm"."company_id" = "j"."company_id")))
  WHERE (("j"."id" = "job_languages"."job_id") AND ("cm"."user_id" = "auth"."uid"())))));



CREATE POLICY "Company members can delete skill requirements for own jobs" ON "public"."job_skills" FOR DELETE TO "authenticated" USING ("public"."is_own_company_job"("job_id"));



CREATE POLICY "Company members can read all own company jobs" ON "public"."jobs" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."company_memberships" "cm"
  WHERE (("cm"."company_id" = "jobs"."company_id") AND ("cm"."user_id" = "auth"."uid"())))));



CREATE POLICY "Company members can read education requirements for own jobs" ON "public"."job_education_requirements" FOR SELECT TO "authenticated" USING ("public"."is_own_company_job"("job_id"));



CREATE POLICY "Company members can read language requirements for own jobs" ON "public"."job_languages" FOR SELECT TO "authenticated" USING ("public"."is_own_company_job"("job_id"));



CREATE POLICY "Company members can read skill requirements for own jobs" ON "public"."job_skills" FOR SELECT TO "authenticated" USING ("public"."is_own_company_job"("job_id"));



CREATE POLICY "Company members can update education requirements for own jobs" ON "public"."job_education_requirements" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."jobs" "j"
     JOIN "public"."company_memberships" "cm" ON (("cm"."company_id" = "j"."company_id")))
  WHERE (("j"."id" = "job_education_requirements"."job_id") AND ("cm"."user_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."jobs" "j"
     JOIN "public"."company_memberships" "cm" ON (("cm"."company_id" = "j"."company_id")))
  WHERE (("j"."id" = "job_education_requirements"."job_id") AND ("cm"."user_id" = "auth"."uid"())))));



CREATE POLICY "Company members can update language requirements for own jobs" ON "public"."job_languages" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."jobs" "j"
     JOIN "public"."company_memberships" "cm" ON (("cm"."company_id" = "j"."company_id")))
  WHERE (("j"."id" = "job_languages"."job_id") AND ("cm"."user_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."jobs" "j"
     JOIN "public"."company_memberships" "cm" ON (("cm"."company_id" = "j"."company_id")))
  WHERE (("j"."id" = "job_languages"."job_id") AND ("cm"."user_id" = "auth"."uid"())))));



CREATE POLICY "Company members can update own company" ON "public"."companies" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."company_memberships" "cm"
  WHERE (("cm"."company_id" = "companies"."id") AND ("cm"."user_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."company_memberships" "cm"
  WHERE (("cm"."company_id" = "companies"."id") AND ("cm"."user_id" = "auth"."uid"())))));



CREATE POLICY "Company members can update own company jobs" ON "public"."jobs" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."company_memberships" "cm"
  WHERE (("cm"."company_id" = "jobs"."company_id") AND ("cm"."user_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."company_memberships" "cm"
  WHERE (("cm"."company_id" = "jobs"."company_id") AND ("cm"."user_id" = "auth"."uid"())))));



CREATE POLICY "Company members can update skill requirements for own jobs" ON "public"."job_skills" FOR UPDATE TO "authenticated" USING ("public"."is_own_company_job"("job_id")) WITH CHECK ("public"."is_own_company_job"("job_id"));



CREATE POLICY "Employer members can read interview slots for own jobs" ON "public"."interview_slots" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM (("public"."matches" "m"
     JOIN "public"."jobs" "j" ON (("j"."id" = "m"."job_id")))
     JOIN "public"."company_memberships" "cm" ON (("cm"."company_id" = "j"."company_id")))
  WHERE (("m"."id" = "interview_slots"."match_id") AND ("cm"."user_id" = "auth"."uid"())))));



CREATE POLICY "Users can read own company memberships" ON "public"."company_memberships" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can read own profile" ON "public"."profiles" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "Users can update own profile" ON "public"."profiles" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "id"));



ALTER TABLE "public"."candidate_custom_skills" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."candidate_job_interactions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."candidate_languages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."candidate_profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."candidate_skills" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."companies" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."company_memberships" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."educations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."employer_job_interactions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."interview_slots" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."interviews" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."job_education_requirements" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."job_languages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."job_skills" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."jobs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."languages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."matches" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."skills" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."work_experiences" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



REVOKE ALL ON FUNCTION "public"."create_employer_company"("p_name" "text", "p_description" "text", "p_industry" "text", "p_company_size" "text", "p_website" "text", "p_location" "text", "p_contact_first_name" "text", "p_contact_last_name" "text", "p_contact_email" "text", "p_contact_phone" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."create_employer_company"("p_name" "text", "p_description" "text", "p_industry" "text", "p_company_size" "text", "p_website" "text", "p_location" "text", "p_contact_first_name" "text", "p_contact_last_name" "text", "p_contact_email" "text", "p_contact_phone" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_employer_company"("p_name" "text", "p_description" "text", "p_industry" "text", "p_company_size" "text", "p_website" "text", "p_location" "text", "p_contact_first_name" "text", "p_contact_last_name" "text", "p_contact_email" "text", "p_contact_phone" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_employer_company"("p_name" "text", "p_description" "text", "p_industry" "text", "p_company_size" "text", "p_website" "text", "p_location" "text", "p_contact_first_name" "text", "p_contact_last_name" "text", "p_contact_email" "text", "p_contact_phone" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."create_employer_interview_slot"("p_match_id" "uuid", "p_starts_at" timestamp with time zone, "p_ends_at" timestamp with time zone) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."create_employer_interview_slot"("p_match_id" "uuid", "p_starts_at" timestamp with time zone, "p_ends_at" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_employer_interview_slot"("p_match_id" "uuid", "p_starts_at" timestamp with time zone, "p_ends_at" timestamp with time zone) TO "service_role";



REVOKE ALL ON FUNCTION "public"."create_mutual_match_if_eligible"("p_job_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."create_mutual_match_if_eligible"("p_job_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_mutual_match_if_eligible"("p_job_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."create_mutual_match_internal"("p_job_id" "uuid", "p_candidate_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."create_mutual_match_internal"("p_job_id" "uuid", "p_candidate_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."delete_own_matches_for_poc"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."delete_own_matches_for_poc"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_own_matches_for_poc"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_confirmed_candidate_contact"("p_match_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_confirmed_candidate_contact"("p_match_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_confirmed_candidate_contact"("p_match_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_employer_candidate_educations"("p_job_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_employer_candidate_educations"("p_job_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_employer_candidate_educations"("p_job_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_employer_candidate_languages"("p_job_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_employer_candidate_languages"("p_job_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_employer_candidate_languages"("p_job_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_employer_candidate_skills"("p_job_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_employer_candidate_skills"("p_job_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_employer_candidate_skills"("p_job_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_employer_candidate_work_experiences"("p_job_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_employer_candidate_work_experiences"("p_job_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_employer_candidate_work_experiences"("p_job_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."interviews" TO "anon";
GRANT ALL ON TABLE "public"."interviews" TO "authenticated";
GRANT ALL ON TABLE "public"."interviews" TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_employer_interview"("p_match_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_employer_interview"("p_match_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_employer_interview"("p_match_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."interview_slots" TO "anon";
GRANT ALL ON TABLE "public"."interview_slots" TO "authenticated";
GRANT ALL ON TABLE "public"."interview_slots" TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_employer_interview_slots"("p_match_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_employer_interview_slots"("p_match_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_employer_interview_slots"("p_match_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_employer_matched_candidate"("p_match_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_employer_matched_candidate"("p_match_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_employer_matched_candidate"("p_match_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."matches" TO "anon";
GRANT ALL ON TABLE "public"."matches" TO "authenticated";
GRANT ALL ON TABLE "public"."matches" TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_employer_matches"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_employer_matches"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_employer_matches"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_employer_matching_candidates"("p_job_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_employer_matching_candidates"("p_job_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_employer_matching_candidates"("p_job_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."is_own_company_job"("p_job_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."is_own_company_job"("p_job_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_own_company_job"("p_job_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_own_company_job"("p_job_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."reset_employer_for_poc"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."reset_employer_for_poc"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."reset_employer_for_poc"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."save_employer_candidate_decision"("p_job_id" "uuid", "p_candidate_id" "uuid", "p_decision" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."save_employer_candidate_decision"("p_job_id" "uuid", "p_candidate_id" "uuid", "p_decision" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."save_employer_candidate_decision"("p_job_id" "uuid", "p_candidate_id" "uuid", "p_decision" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."seed_employer_jobs_for_poc"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."seed_employer_jobs_for_poc"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."seed_employer_jobs_for_poc"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."select_interview_slot"("p_match_id" "uuid", "p_interview_slot_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."select_interview_slot"("p_match_id" "uuid", "p_interview_slot_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."select_interview_slot"("p_match_id" "uuid", "p_interview_slot_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";



GRANT ALL ON TABLE "public"."candidate_custom_skills" TO "anon";
GRANT ALL ON TABLE "public"."candidate_custom_skills" TO "authenticated";
GRANT ALL ON TABLE "public"."candidate_custom_skills" TO "service_role";



GRANT ALL ON TABLE "public"."candidate_job_interactions" TO "anon";
GRANT ALL ON TABLE "public"."candidate_job_interactions" TO "authenticated";
GRANT ALL ON TABLE "public"."candidate_job_interactions" TO "service_role";



GRANT ALL ON TABLE "public"."candidate_languages" TO "anon";
GRANT ALL ON TABLE "public"."candidate_languages" TO "authenticated";
GRANT ALL ON TABLE "public"."candidate_languages" TO "service_role";



GRANT ALL ON TABLE "public"."candidate_profiles" TO "anon";
GRANT ALL ON TABLE "public"."candidate_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."candidate_profiles" TO "service_role";



GRANT ALL ON TABLE "public"."candidate_skills" TO "anon";
GRANT ALL ON TABLE "public"."candidate_skills" TO "authenticated";
GRANT ALL ON TABLE "public"."candidate_skills" TO "service_role";



GRANT ALL ON TABLE "public"."companies" TO "anon";
GRANT ALL ON TABLE "public"."companies" TO "authenticated";
GRANT ALL ON TABLE "public"."companies" TO "service_role";



GRANT ALL ON TABLE "public"."company_memberships" TO "anon";
GRANT ALL ON TABLE "public"."company_memberships" TO "authenticated";
GRANT ALL ON TABLE "public"."company_memberships" TO "service_role";



GRANT ALL ON TABLE "public"."educations" TO "anon";
GRANT ALL ON TABLE "public"."educations" TO "authenticated";
GRANT ALL ON TABLE "public"."educations" TO "service_role";



GRANT ALL ON TABLE "public"."employer_job_interactions" TO "anon";
GRANT ALL ON TABLE "public"."employer_job_interactions" TO "authenticated";
GRANT ALL ON TABLE "public"."employer_job_interactions" TO "service_role";



GRANT ALL ON TABLE "public"."job_education_requirements" TO "anon";
GRANT ALL ON TABLE "public"."job_education_requirements" TO "authenticated";
GRANT ALL ON TABLE "public"."job_education_requirements" TO "service_role";



GRANT ALL ON TABLE "public"."job_languages" TO "anon";
GRANT ALL ON TABLE "public"."job_languages" TO "authenticated";
GRANT ALL ON TABLE "public"."job_languages" TO "service_role";



GRANT ALL ON TABLE "public"."job_skills" TO "anon";
GRANT ALL ON TABLE "public"."job_skills" TO "authenticated";
GRANT ALL ON TABLE "public"."job_skills" TO "service_role";



GRANT ALL ON TABLE "public"."jobs" TO "anon";
GRANT ALL ON TABLE "public"."jobs" TO "authenticated";
GRANT ALL ON TABLE "public"."jobs" TO "service_role";



GRANT ALL ON TABLE "public"."languages" TO "anon";
GRANT ALL ON TABLE "public"."languages" TO "authenticated";
GRANT ALL ON TABLE "public"."languages" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."skills" TO "anon";
GRANT ALL ON TABLE "public"."skills" TO "authenticated";
GRANT ALL ON TABLE "public"."skills" TO "service_role";



GRANT ALL ON TABLE "public"."work_experiences" TO "anon";
GRANT ALL ON TABLE "public"."work_experiences" TO "authenticated";
GRANT ALL ON TABLE "public"."work_experiences" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







