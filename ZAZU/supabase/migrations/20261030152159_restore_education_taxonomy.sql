BEGIN;

-- Bestehende Education-Taxonomie wiederherstellen

CREATE TABLE IF NOT EXISTS public.education_levels (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code text NOT NULL UNIQUE,
    name_de text NOT NULL,
    source text NOT NULL,
    isced_level text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.education_fields (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code text NOT NULL UNIQUE,
    name_de text NOT NULL,
    parent_id uuid
        REFERENCES public.education_fields(id)
        ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_education_fields_parent
    ON public.education_fields(parent_id);

-- Fehlende Referenzen ergänzen

ALTER TABLE public.educations
    ADD COLUMN IF NOT EXISTS education_level_id uuid
        REFERENCES public.education_levels(id)
        ON DELETE SET NULL;

ALTER TABLE public.educations
    ADD COLUMN IF NOT EXISTS education_field_id uuid
        REFERENCES public.education_fields(id)
        ON DELETE SET NULL;

ALTER TABLE public.job_education_requirements
    ADD COLUMN IF NOT EXISTS education_level_id uuid
        REFERENCES public.education_levels(id)
        ON DELETE SET NULL;

ALTER TABLE public.job_education_requirements
    ADD COLUMN IF NOT EXISTS education_field_id uuid
        REFERENCES public.education_fields(id)
        ON DELETE SET NULL;

-- Indizes

CREATE INDEX IF NOT EXISTS idx_educations_level
    ON public.educations(education_level_id);

CREATE INDEX IF NOT EXISTS idx_educations_field
    ON public.educations(education_field_id);

CREATE INDEX IF NOT EXISTS idx_job_education_level
    ON public.job_education_requirements(education_level_id);

CREATE INDEX IF NOT EXISTS idx_job_education_field
    ON public.job_education_requirements(education_field_id);

-- RLS für beide Katalogtabellen

ALTER TABLE public.education_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.education_fields ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read education levels"
    ON public.education_levels
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "Authenticated users can read education fields"
    ON public.education_fields
    FOR SELECT TO authenticated
    USING (true);

COMMIT;
