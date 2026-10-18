BEGIN;

-- ============================================================
-- 1. Abschlussarten und Bildungsniveaus
-- ============================================================

CREATE TABLE public.education_levels (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    code text NOT NULL UNIQUE,

    name_de text NOT NULL,

    -- Beispielsweise CH oder ISCED
    source text NOT NULL,

    -- Optionaler internationaler Vergleichscode
    isced_level text,

    created_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- 2. Fachrichtungen
-- ============================================================

CREATE TABLE public.education_fields (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- ISCED-F 2013
    code text NOT NULL UNIQUE,

    name_de text NOT NULL,

    parent_id uuid
        REFERENCES public.education_fields(id)
        ON DELETE RESTRICT,

    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_education_fields_parent
ON public.education_fields(parent_id);

-- ============================================================
-- 3. Kandidatenausbildungen erweitern
-- ============================================================

ALTER TABLE public.educations
ADD COLUMN IF NOT EXISTS education_level_id uuid
REFERENCES public.education_levels(id)
ON DELETE SET NULL;

ALTER TABLE public.educations
ADD COLUMN IF NOT EXISTS education_field_id uuid
REFERENCES public.education_fields(id)
ON DELETE SET NULL;

-- ============================================================
-- 4. Jobanforderungen erweitern
-- ============================================================

ALTER TABLE public.job_education_requirements
ADD COLUMN IF NOT EXISTS education_level_id uuid
REFERENCES public.education_levels(id)
ON DELETE SET NULL;

ALTER TABLE public.job_education_requirements
ADD COLUMN IF NOT EXISTS education_field_id uuid
REFERENCES public.education_fields(id)
ON DELETE SET NULL;

-- ============================================================
-- 5. Indizes
-- ============================================================

CREATE INDEX idx_educations_level
ON public.educations(education_level_id);

CREATE INDEX idx_educations_field
ON public.educations(education_field_id);

CREATE INDEX idx_job_education_level
ON public.job_education_requirements(education_level_id);

CREATE INDEX idx_job_education_field
ON public.job_education_requirements(education_field_id);

-- ============================================================
-- 6. RLS
-- ============================================================

ALTER TABLE public.education_levels
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.education_fields
ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read education levels"
ON public.education_levels
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Authenticated users can read education fields"
ON public.education_fields
FOR SELECT
TO authenticated
USING (true);

COMMIT;
