-- ============================================================
-- ZAZU – Admin-Panel: Benutzerverwaltung
-- ============================================================
--
-- Admins dürfen
--   * alle Profile und Kandidaten-Daten lesen,
--   * Profile (Name, Telefon, Rolle) bearbeiten,
--   * Benutzer sperren, entsperren und löschen,
--   * andere Benutzer zu Admins machen oder die Rechte entziehen.
--
-- auth.users ist über die Data API nicht erreichbar. Die admin_*-Funktionen
-- laufen deshalb als SECURITY DEFINER und prüfen zuerst public.is_admin().
-- Ein Service-Role-Key ist nicht nötig.

BEGIN;

-- ------------------------------------------------------------
-- Lesezugriff auf Benutzerdaten
-- ------------------------------------------------------------

DO $$
DECLARE
    user_table text;
BEGIN
    FOREACH user_table IN ARRAY ARRAY[
        'profiles',
        'candidate_profiles',
        'candidate_skills',
        'candidate_custom_skills',
        'candidate_languages',
        'educations',
        'work_experiences'
    ]
    LOOP
        IF NOT EXISTS (
            SELECT 1
            FROM pg_class c
            JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = 'public'
              AND c.relname = user_table
              AND c.relrowsecurity
        ) THEN
            RAISE EXCEPTION
                'RLS ist auf public.% nicht aktiv – Migration abgebrochen',
                user_table;
        END IF;

        EXECUTE format(
            'CREATE POLICY %I ON public.%I FOR SELECT TO authenticated '
            'USING ((SELECT public.is_admin()))',
            'Admins can read ' || user_table,
            user_table
        );
    END LOOP;
END $$;

CREATE POLICY "Admins can update profiles"
    ON public.profiles
    FOR UPDATE TO authenticated
    USING ((SELECT public.is_admin()))
    WITH CHECK ((SELECT public.is_admin()));


-- ------------------------------------------------------------
-- Benutzerliste inkl. E-Mail, Login und Status aus auth.users
-- ------------------------------------------------------------
-- p_filter: NULL, 'candidate', 'employer', 'admin' oder 'banned'
-- p_user_id: liefert genau einen Benutzer (Detailseite)

CREATE FUNCTION public.admin_list_users(
    p_search text DEFAULT NULL,
    p_filter text DEFAULT NULL,
    p_user_id uuid DEFAULT NULL,
    p_limit integer DEFAULT 50,
    p_offset integer DEFAULT 0
)
RETURNS TABLE (
    id uuid,
    email text,
    first_name text,
    last_name text,
    phone_number text,
    account_role text,
    created_at timestamptz,
    last_sign_in_at timestamptz,
    email_confirmed_at timestamptz,
    banned_until timestamptz,
    is_admin boolean,
    total_count bigint
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
#variable_conflict use_column
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Keine Berechtigung' USING ERRCODE = '42501';
    END IF;

    RETURN QUERY
    SELECT
        u.id,
        u.email::text,
        p.first_name,
        p.last_name,
        p.phone_number,
        p.account_role,
        u.created_at,
        u.last_sign_in_at,
        u.email_confirmed_at,
        u.banned_until,
        a.user_id IS NOT NULL,
        count(*) OVER ()
    FROM auth.users u
    LEFT JOIN public.profiles p ON p.id = u.id
    LEFT JOIN public.admin_users a ON a.user_id = u.id
    WHERE (p_user_id IS NULL OR u.id = p_user_id)
      AND (
          NULLIF(trim(p_search), '') IS NULL
          OR concat_ws(' ', u.email, p.first_name, p.last_name, p.phone_number)
             ILIKE '%' || trim(p_search) || '%'
      )
      AND (
          p_filter IS NULL
          OR (p_filter IN ('candidate', 'employer') AND p.account_role = p_filter)
          OR (p_filter = 'admin' AND a.user_id IS NOT NULL)
          OR (p_filter = 'banned' AND u.banned_until > now())
      )
    ORDER BY u.created_at DESC
    LIMIT least(greatest(p_limit, 1), 200)
    OFFSET greatest(p_offset, 0);
END;
$$;


-- ------------------------------------------------------------
-- Sperren / Entsperren
-- ------------------------------------------------------------
-- GoTrue lehnt Logins und Token-Refresh ab, solange banned_until in der
-- Zukunft liegt. Bestehende Sessions werden gelöscht; ein bereits
-- ausgestelltes Access-Token bleibt bis zu seinem Ablauf (max. 1 h) gültig.

CREATE FUNCTION public.admin_set_user_banned(
    p_user_id uuid,
    p_banned boolean
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Keine Berechtigung' USING ERRCODE = '42501';
    END IF;

    IF p_user_id = (SELECT auth.uid()) THEN
        RAISE EXCEPTION 'Du kannst dein eigenes Konto nicht sperren.';
    END IF;

    UPDATE auth.users
    SET banned_until = CASE WHEN p_banned THEN now() + interval '100 years' END,
        updated_at = now()
    WHERE id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Benutzer nicht gefunden' USING ERRCODE = 'P0002';
    END IF;

    IF p_banned THEN
        DELETE FROM auth.sessions WHERE user_id = p_user_id;
    END IF;
END;
$$;


-- ------------------------------------------------------------
-- Löschen
-- ------------------------------------------------------------
-- Profile, Kandidaten-Daten, Matches und Firmen-Mitgliedschaften
-- werden über ON DELETE CASCADE mitgelöscht.

CREATE FUNCTION public.admin_delete_user(p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Keine Berechtigung' USING ERRCODE = '42501';
    END IF;

    IF p_user_id = (SELECT auth.uid()) THEN
        RAISE EXCEPTION 'Du kannst dein eigenes Konto nicht löschen.';
    END IF;

    DELETE FROM auth.users WHERE id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Benutzer nicht gefunden' USING ERRCODE = 'P0002';
    END IF;
END;
$$;


-- ------------------------------------------------------------
-- Admin-Rechte vergeben / entziehen
-- ------------------------------------------------------------

CREATE FUNCTION public.admin_set_user_admin(
    p_user_id uuid,
    p_admin boolean
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Keine Berechtigung' USING ERRCODE = '42501';
    END IF;

    IF p_user_id = (SELECT auth.uid()) AND NOT p_admin THEN
        RAISE EXCEPTION 'Du kannst dir die Admin-Rechte nicht selbst entziehen.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = p_user_id) THEN
        RAISE EXCEPTION 'Benutzer nicht gefunden' USING ERRCODE = 'P0002';
    END IF;

    IF p_admin THEN
        INSERT INTO public.admin_users (user_id)
        VALUES (p_user_id)
        ON CONFLICT (user_id) DO NOTHING;
    ELSE
        DELETE FROM public.admin_users WHERE user_id = p_user_id;
    END IF;
END;
$$;


REVOKE ALL ON FUNCTION public.admin_list_users(text, text, uuid, integer, integer) FROM public, anon;
REVOKE ALL ON FUNCTION public.admin_set_user_banned(uuid, boolean) FROM public, anon;
REVOKE ALL ON FUNCTION public.admin_delete_user(uuid) FROM public, anon;
REVOKE ALL ON FUNCTION public.admin_set_user_admin(uuid, boolean) FROM public, anon;

GRANT EXECUTE ON FUNCTION public.admin_list_users(text, text, uuid, integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_set_user_banned(uuid, boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_delete_user(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_set_user_admin(uuid, boolean) TO authenticated;

COMMIT;
