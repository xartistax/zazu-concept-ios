-- ============================================================
-- ZAZU – CH-ISCO-19 + ESCO Taxonomy Foundation
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. Offizielle Berufskategorien
-- ------------------------------------------------------------

CREATE TABLE public.occupation_categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    source text NOT NULL
        CHECK (source IN ('ch_isco_19', 'esco')),

    code text NOT NULL,

    name_de text NOT NULL,

    parent_id uuid
        REFERENCES public.occupation_categories(id)
        ON DELETE RESTRICT,

    level integer NOT NULL
        CHECK (level BETWEEN 1 AND 5),

    created_at timestamptz NOT NULL DEFAULT now(),

    UNIQUE (source, code)
);

CREATE INDEX idx_occupation_categories_parent
ON public.occupation_categories(parent_id);


-- ------------------------------------------------------------
-- 2. Offizielle Berufe
-- ------------------------------------------------------------

CREATE TABLE public.occupations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    source text NOT NULL
        CHECK (source IN ('ch_isco_19', 'esco')),

    source_code text NOT NULL,

    name_de text NOT NULL,

    category_id uuid
        REFERENCES public.occupation_categories(id)
        ON DELETE RESTRICT,

    isco_08_code text,

    source_uri text,

    created_at timestamptz NOT NULL DEFAULT now(),

    UNIQUE (source, source_code)
);

CREATE INDEX idx_occupations_category
ON public.occupations(category_id);

CREATE INDEX idx_occupations_isco
ON public.occupations(isco_08_code);

CREATE INDEX idx_occupations_name
ON public.occupations(name_de);


-- ------------------------------------------------------------
-- 3. CH-ISCO / ESCO Zuordnungen
-- ------------------------------------------------------------

CREATE TABLE public.occupation_mappings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    source_occupation_id uuid NOT NULL
        REFERENCES public.occupations(id)
        ON DELETE CASCADE,

    target_occupation_id uuid NOT NULL
        REFERENCES public.occupations(id)
        ON DELETE CASCADE,

    mapping_type text NOT NULL
        CHECK (
            mapping_type IN (
                'exact',
                'close',
                'isco_group'
            )
        ),

    created_at timestamptz NOT NULL DEFAULT now(),

    UNIQUE (
        source_occupation_id,
        target_occupation_id
    ),

    CHECK (
        source_occupation_id <> target_occupation_id
    )
);


-- ------------------------------------------------------------
-- 4. Offizielle Skills pro Beruf
-- ------------------------------------------------------------

CREATE TABLE public.occupation_skills (
    occupation_id uuid NOT NULL
        REFERENCES public.occupations(id)
        ON DELETE CASCADE,

    skill_id uuid NOT NULL
        REFERENCES public.skills(id)
        ON DELETE CASCADE,

    relation_type text NOT NULL
        CHECK (
            relation_type IN (
                'essential',
                'optional'
            )
        ),

    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (
        occupation_id,
        skill_id
    )
);

CREATE INDEX idx_occupation_skills_skill
ON public.occupation_skills(skill_id);


-- ------------------------------------------------------------
-- 5. Bestehende Skill-Taxonomie erweitern
-- ------------------------------------------------------------

ALTER TABLE public.skills
ADD COLUMN IF NOT EXISTS esco_uri text;

CREATE UNIQUE INDEX IF NOT EXISTS idx_skills_esco_uri
ON public.skills(esco_uri)
WHERE esco_uri IS NOT NULL;


-- ------------------------------------------------------------
-- 6. Jobs mit offiziellen Berufen verknüpfen
-- ------------------------------------------------------------

ALTER TABLE public.jobs
ADD COLUMN IF NOT EXISTS occupation_id uuid
REFERENCES public.occupations(id)
ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_jobs_occupation
ON public.jobs(occupation_id);


-- ------------------------------------------------------------
-- 7. Row Level Security
-- ------------------------------------------------------------

ALTER TABLE public.occupation_categories
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.occupations
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.occupation_mappings
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.occupation_skills
ENABLE ROW LEVEL SECURITY;


-- Berufskategorien dürfen angemeldete Benutzer lesen.
CREATE POLICY "Authenticated users can read occupation categories"
ON public.occupation_categories
FOR SELECT
TO authenticated
USING (true);


-- Berufe dürfen angemeldete Benutzer lesen.
CREATE POLICY "Authenticated users can read occupations"
ON public.occupations
FOR SELECT
TO authenticated
USING (true);


-- Zuordnungen dürfen angemeldete Benutzer lesen.
CREATE POLICY "Authenticated users can read occupation mappings"
ON public.occupation_mappings
FOR SELECT
TO authenticated
USING (true);


-- Berufsskills dürfen angemeldete Benutzer lesen.
CREATE POLICY "Authenticated users can read occupation skills"
ON public.occupation_skills
FOR SELECT
TO authenticated
USING (true);


-- Keine INSERT-/UPDATE-/DELETE-Policies.
-- Taxonomiedaten werden ausschliesslich durch
-- kontrollierte Backend-Importe verwaltet.

COMMIT;
