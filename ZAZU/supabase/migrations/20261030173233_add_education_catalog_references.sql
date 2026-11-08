

ALTER TABLE public.educations
    ADD COLUMN IF NOT EXISTS education_type_id UUID
        REFERENCES public.education_types(id),
    ADD COLUMN IF NOT EXISTS education_type_degree_id UUID
        REFERENCES public.education_type_degrees(id);

CREATE INDEX IF NOT EXISTS idx_educations_education_type_id
    ON public.educations(education_type_id);

CREATE INDEX IF NOT EXISTS idx_educations_education_type_degree_id
    ON public.educations(education_type_degree_id);
