-- ============================================================
-- ZAZU – Admin-Panel: Admin-Rolle und Schreibrechte für Kataloge
-- ============================================================
--
-- Admins werden in public.admin_users eingetragen. Nur sie dürfen
-- die Katalogtabellen (Ausbildung, Berufe, Skills) bearbeiten.
-- Kandidaten und Arbeitgeber behalten ihren bisherigen Lesezugriff.
--
-- Ersten Admin anlegen (nach Erstellung des Users unter Auth > Users):
--   INSERT INTO public.admin_users (user_id)
--   SELECT id FROM auth.users WHERE email = 'name@example.com';

BEGIN;

CREATE TABLE public.admin_users (
    user_id uuid PRIMARY KEY
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.admin_users FROM public, anon, authenticated;
GRANT SELECT ON TABLE public.admin_users TO authenticated;

CREATE POLICY "Admins can read own admin entry"
    ON public.admin_users
    FOR SELECT TO authenticated
    USING (user_id = (SELECT auth.uid()));


CREATE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.admin_users
        WHERE user_id = (SELECT auth.uid())
    );
$$;

REVOKE ALL ON FUNCTION public.is_admin() FROM public, anon;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;


-- Schreib-Policies für alle Katalogtabellen.
-- Bricht ab, falls eine Tabelle ohne RLS ist: sonst würde das GRANT
-- jedem eingeloggten User Schreibzugriff geben.

DO $$
DECLARE
    catalog_table text;
BEGIN
    FOREACH catalog_table IN ARRAY ARRAY[
        'education_types',
        'education_type_degrees',
        'education_fields',
        'education_degree_fields',
        'education_institution_types',
        'education_institutions',
        'education_qualifications',
        'education_qualification_options',
        'occupation_categories',
        'occupations',
        'occupation_skills',
        'skill_categories',
        'skills'
    ]
    LOOP
        IF NOT EXISTS (
            SELECT 1
            FROM pg_class c
            JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = 'public'
              AND c.relname = catalog_table
              AND c.relrowsecurity
        ) THEN
            RAISE EXCEPTION
                'RLS ist auf public.% nicht aktiv – Migration abgebrochen',
                catalog_table;
        END IF;

        EXECUTE format(
            'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.%I TO authenticated',
            catalog_table
        );

        EXECUTE format(
            'CREATE POLICY %I ON public.%I FOR ALL TO authenticated '
            'USING ((SELECT public.is_admin())) '
            'WITH CHECK ((SELECT public.is_admin()))',
            'Admins can manage ' || catalog_table,
            catalog_table
        );
    END LOOP;
END $$;

COMMIT;
