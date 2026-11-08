BEGIN;

ALTER TABLE public.education_fields
    ADD COLUMN IF NOT EXISTS field_kind text,
    ADD COLUMN IF NOT EXISTS country_code text,
    ADD COLUMN IF NOT EXISTS source_name text,
    ADD COLUMN IF NOT EXISTS validation_status text;

CREATE TABLE IF NOT EXISTS public.education_degree_fields (
    education_type_degree_id uuid NOT NULL
        REFERENCES public.education_type_degrees(id)
        ON DELETE RESTRICT,
    education_field_id uuid NOT NULL
        REFERENCES public.education_fields(id)
        ON DELETE RESTRICT,
    PRIMARY KEY (
        education_type_degree_id,
        education_field_id
    )
);

CREATE INDEX IF NOT EXISTS idx_education_degree_fields_field
    ON public.education_degree_fields(education_field_id);

ALTER TABLE public.education_degree_fields
    ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read education degree fields"
    ON public.education_degree_fields
    FOR SELECT TO authenticated
    USING (true);

GRANT SELECT ON public.education_degree_fields TO authenticated;
GRANT SELECT ON public.education_fields TO authenticated;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_area_7a11c196cecff4c99b58',
    'Bildung / Sonderpädagogik',
    NULL,
    'study_area',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_3597e3751f4ef5d12e9d',
    'Erziehungswissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_7a11c196cecff4c99b58'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_f5dd9a7d2e6c1b881c0d',
    'Fachdidaktik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_7a11c196cecff4c99b58'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_29467830b15916f8dd2d',
    'Kunstvermittlung',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_7a11c196cecff4c99b58'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_39ea50dbcec710b85a7e',
    'Logopädie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_7a11c196cecff4c99b58'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_40ef1ea29a6397b36920',
    'Psychomotoriktherapie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_7a11c196cecff4c99b58'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_b11f826afff9a6cd69e6',
    'Sonderpädagogik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_7a11c196cecff4c99b58'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_ef10b3b1997f50394af6',
    'Unterricht Mittelschulen / Berufsfachschulen',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_7a11c196cecff4c99b58'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_16907659c817a3cf7c13',
    'Unterricht Sekundarstufe I',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_7a11c196cecff4c99b58'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_23f89345a34d4b703022',
    'Unterricht Vorschulstufe / Primarstufe',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_7a11c196cecff4c99b58'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_area_40b86bc0078a90254c1b',
    'Gesundheit / Medizin',
    NULL,
    'study_area',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_9c1cb6c69d9438d52fe8',
    'Biomedizinische Wissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_559bf7904d7d9b41c507',
    'Biotechnologie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_79817c54392860986ae2',
    'Chiropraktik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_8b76a2bb9388aa1ba5c8',
    'Ergotherapie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_ecdd2717094e63ef7cf5',
    'Ernährung und Diätetik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_727e9bb8db2036f63267',
    'Gesundheitswissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_84800ecf6bc3b99fde32',
    'Hebamme',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_b73d4eb5d30bad98a63c',
    'Humanmedizin',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_4e88b699e369911f1b17',
    'Medizinisch-technische Radiologie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_6edf0f084e0bee4b14bd',
    'Medizintechnik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_44b1afd865c28e492455',
    'Optometrie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_4cf67b85eaf80d84232a',
    'Osteopathie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_8a8f42c81b593c3fe70d',
    'Pflege / Pflegewissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_0311eed710fb65dcff7d',
    'Pharmazie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_7065eb114b79783e8f5c',
    'Physiotherapie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_505a1a155a7f01be8c46',
    'Sport / Sportwissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_2a0fa56db484a4d1f008',
    'Veterinärmedizin',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_a54fd770e081cb882fcc',
    'Zahnmedizin',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_40b86bc0078a90254c1b'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_area_724a7f333c23c8390032',
    'Informatik / Mathematik',
    NULL,
    'study_area',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_fc4ed216d46483a82f35',
    'Computerlinguistik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_724a7f333c23c8390032'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_f68826d8da585cb6cff8',
    'Informatik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_724a7f333c23c8390032'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_2a568fc5ceb595870a64',
    'Informationswissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_724a7f333c23c8390032'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_bf76e55cddf1de118b4c',
    'Mathematik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_724a7f333c23c8390032'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_aaa9ecdf699677621c2e',
    'Rechnergestützte Wissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_724a7f333c23c8390032'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_f2868d5157229ac6a941',
    'Wirtschaftsinformatik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_724a7f333c23c8390032'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_area_fd65863600a93b800d02',
    'Ingenieurwissenschaften / Technik',
    NULL,
    'study_area',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_9c7ad893ad96a702b80c',
    'Agrarwissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_bd445c9aedaeaf8a8d09',
    'Architektur',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_882f3c7da651a6bb2dcb',
    'Aviatik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_0a60ae38ad5df54cda09',
    'Bauingenieurwissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_c9cca009c7ea346af353',
    'Biotechnologie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_31e8986a02a6e0d321a7',
    'Elektrotechnik / Informationstechnologie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_df9c9385d6875befc7da',
    'Gebäudetechnik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_dbcb773bc8eade97cadd',
    'Holztechnik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_5bcc19374c0219ead9d6',
    'Landschaftsarchitektur',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_0d79ba80959a5de9bb4f',
    'Lebensmittelwissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_73e2d381d818f853a855',
    'Maschineningenieurwissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_740b8908c8c442831299',
    'Materialwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_dda7ad4c13d3fbbbe10b',
    'Mechatronik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_32dbd647f0db717e60b0',
    'Medizintechnik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_99436df431af16dd6a44',
    'Mikrotechnik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_c4160534aac8adc132b8',
    'Raumplanung / Geomatik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_c4e209bc13d5f0cdc834',
    'Systemtechnik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_9ff43b987810812ad429',
    'Umweltingenieurwissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_9fcde19728c9f602467e',
    'Umweltwissenschaften / Waldwissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_f0dee350fea703065031',
    'Wirtschaftsingenieurwesen',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_fd65863600a93b800d02'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_area_21db2a576e7092b5358d',
    'Kulturen / Geschichte',
    NULL,
    'study_area',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_f0df55e3120bf3b01db0',
    'Archäologie / Ägyptologie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_3fe477974aa28640b273',
    'Chinesische Sprachen und Kulturen',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_267e47eb914c999a1222',
    'Geschichte',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_db99961d969142093e2c',
    'Indische Sprachen und Kulturen',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_472487cbbe5c0a854f25',
    'Islamische Kulturen / Arabisch',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_da48e6654aa57484493c',
    'Japanische Sprache und Kulturen',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_36d31041e761614fe74a',
    'Jüdische Kulturen / Hebräisch',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_515becc187cf2c3de3df',
    'Kunstgeschichte',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_71146e8b6a26ec2b9727',
    'Osteuropa-Studien',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_da716d8b411647387658',
    'Philosophie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_c48e3925293f020ede95',
    'Religionswissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_200715b874a05bf066a9',
    'Sozialanthropologie / Kulturanthropologie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_0ee22c9ecd4647d06bcf',
    'Theologie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_21db2a576e7092b5358d'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_area_5b392c98206541872059',
    'Kunst / Design',
    NULL,
    'study_area',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_6fe0caf109a47a1a8cb1',
    'Bildende Kunst',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_c2d7f02e854a43624719',
    'Design',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_1759e86c23f84aaace1c',
    'Film',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_49a721c6e6e2c92b06e8',
    'Filmwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_75505282c4cf032c05a1',
    'Innenarchitektur',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_5490deffffbdd25507cb',
    'Konservierung / Restaurierung',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_155ce5905e5f54a2af99',
    'Kunstgeschichte',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_cefa511d219c6cde05a9',
    'Kunstvermittlung',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_5788d4113bf115de452c',
    'Literarisches Schreiben',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_de960dc74eb1edc3364e',
    'Musik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_3cb74109b882f1ee16bf',
    'Musikwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_ac6242ced0ba7228015d',
    'Theater / Tanz',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_da15fd9a1a4156b8c63c',
    'Theaterwissenschaft / Tanzwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_560f17d0bb9196326f61',
    'Visuelle Kommunikation',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_5b392c98206541872059'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_area_cff1b4a817eecfbd5b31',
    'Naturwissenschaften / Umwelt',
    NULL,
    'study_area',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_b9274b046b85c8d52f4d',
    'Agrarwissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_cff1b4a817eecfbd5b31'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_0f05c2f02dffc81b4655',
    'Biochemie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_cff1b4a817eecfbd5b31'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_379e096e4219cd3f5f81',
    'Biologie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_cff1b4a817eecfbd5b31'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_7c8b51ec426e49857643',
    'Chemie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_cff1b4a817eecfbd5b31'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_aaff5f5c9e79a49ed61b',
    'Erdwissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_cff1b4a817eecfbd5b31'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_61e44e469434e3a1c4ae',
    'Forensische Wissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_cff1b4a817eecfbd5b31'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_5553a4051e09c19251d8',
    'Geographie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_cff1b4a817eecfbd5b31'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_a08c8a03b83b6964d0bd',
    'Physik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_cff1b4a817eecfbd5b31'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_e9c5cfb9f431b7cd805a',
    'Umweltwissenschaften / Waldwissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_cff1b4a817eecfbd5b31'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_area_f42365d4a81d72333554',
    'Sozialwissenschaften',
    NULL,
    'study_area',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_0c0c623ad609c5e688f7',
    'Erziehungswissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_f42365d4a81d72333554'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_83f3def63905dadad998',
    'Gender Studies',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_f42365d4a81d72333554'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_616b8c02888b0cae3322',
    'Internationale Studien',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_f42365d4a81d72333554'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_a605ff03dd1b9a5c6ccd',
    'Politikwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_f42365d4a81d72333554'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_d79e625e951499c6dee1',
    'Psychologie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_f42365d4a81d72333554'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_6a2113b0999b84ff89a8',
    'Sozialanthropologie / Kulturanthropologie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_f42365d4a81d72333554'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_3b32fd3892afd2ad5724',
    'Soziale Arbeit',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_f42365d4a81d72333554'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_32b85d41661c22f9eb44',
    'Soziologie',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_f42365d4a81d72333554'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_area_095bd01d2885b438a241',
    'Sprache / Kommunikation',
    NULL,
    'study_area',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_dc9c38783e11aac845cf',
    'Allgemeine Sprachwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_d8af48d66280155b41ba',
    'Armenische Sprach- und Literaturwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_c452b216dd328561097e',
    'Chinesische Sprachen und Kulturen',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_236b02b9e1cf81bc5f18',
    'Computerlinguistik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_97f1c0ef743f4775f777',
    'Deutsche Sprach- und Literaturwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_d45fef9fdbbb8b62d8aa',
    'Englische Sprach- und Literaturwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_4e9259b5bebd8ee705ef',
    'Französische Sprach- und Literaturwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_494633d21d83091348ca',
    'Indische Sprachen und Kulturen',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_3f47aa4480066cc890a3',
    'Informationswissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_b56fcb6c61710a10dc1a',
    'Islamische Kulturen / Arabisch',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_ae189700719e0f62aa10',
    'Italienische Sprach- und Literaturwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_3c216a1bb4137aec54ef',
    'Japanische Sprache und Kulturen',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_72c6a76dbb4ce5510320',
    'Jüdische Kulturen / Hebräisch',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_01fc56f6f7e8d39d2c5a',
    'Kommunikation / Medien',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_b211d638f992c679b4b9',
    'Latein / Griechisch',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_19447e8194bd97e8e1c7',
    'Literarisches Schreiben',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_522c538afec9bb597f69',
    'Neugriechische Sprach- und Literaturwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_5bbdb9e58a1617581cf5',
    'Nordische Sprach- und Literaturwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_0a2c2d3756c809b54c46',
    'Rätoromanische Sprach- und Literaturwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_49dfcde429e5cc952f08',
    'Slavische Sprach- und Literaturwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_34aae6965c719fd72243',
    'Spanische Sprach- und Literaturwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_eb0eb402d59b3ca31dff',
    'Übersetzen / Dolmetschen',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_f85c6830071b7d836d60',
    'Vergleichende Literaturwissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_095bd01d2885b438a241'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_area_692af4cb8bf486eef757',
    'Wirtschaft / Recht',
    NULL,
    'study_area',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_40535c99cc391efdce69',
    'Betriebswirtschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_692af4cb8bf486eef757'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_e76dd63b1035331132f5',
    'Facility Management',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_692af4cb8bf486eef757'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_851a02ece6953d54b2c9',
    'Forensische Wissenschaften',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_692af4cb8bf486eef757'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_0b11806f0b4af05292d5',
    'Hospitality Management',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_692af4cb8bf486eef757'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_992a0c9eb5cef544a867',
    'Internationale Studien',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_692af4cb8bf486eef757'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_49b6d06a70033f81cfbc',
    'Osteuropa-Studien',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_692af4cb8bf486eef757'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_3bf0441dc78a6b3d9d6d',
    'Rechtswissenschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_692af4cb8bf486eef757'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_3d9e6bf6933884aeed2c',
    'Tourismus',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_692af4cb8bf486eef757'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_93d5580db9d78c22a11d',
    'Volkswirtschaft',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_692af4cb8bf486eef757'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_966810edb723ba12b87c',
    'Wirtschaftsinformatik',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_692af4cb8bf486eef757'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'study_field_bdfaa003ca76dedaff43',
    'Wirtschaftsingenieurwesen',
    (SELECT id FROM public.education_fields WHERE code = 'study_area_692af4cb8bf486eef757'),
    'study_field',
    'CH',
    'https://www.berufsberatung.ch/de/studienbereiche',
    'reference_category'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_00802b6628e1691c27be',
    'Abdichtungspraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_00802b6628e1691c27be'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_a17586a5d3b37d31c17f',
    'Agrarpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_a17586a5d3b37d31c17f'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_12a874e0305afb692ce8',
    'Assistent/in Gesundheit und Soziales EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_12a874e0305afb692ce8'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_5fe03e5882519b79fa20',
    'Automobil-Assistent/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_5fe03e5882519b79fa20'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_e11ee20d339ebecad7f3',
    'Baupraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e11ee20d339ebecad7f3'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_bf45728f6d41350f9213',
    'Bekleidungsnäher/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_bf45728f6d41350f9213'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_32f4903ddae8706f5176',
    'Bäcker/in-Konditor/in-Confiseur/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_32f4903ddae8706f5176'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_3a528cf85c12c2a60137',
    'Chemie- und Pharmapraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_3a528cf85c12c2a60137'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_e5fb3e478f6f88bb013c',
    'Coiffeur/Coiffeuse EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e5fb3e478f6f88bb013c'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_a67ebf064b3fbf8f142d',
    'Dachdeckerpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_a67ebf064b3fbf8f142d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_9b6c1fb05f8276995c12',
    'Dekorationsnäher/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_9b6c1fb05f8276995c12'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_861eb712a6b1d4e1ff59',
    'Detailhandelsassistent/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_861eb712a6b1d4e1ff59'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_c8deed8220c9d482d3aa',
    'Entwässerungspraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_c8deed8220c9d482d3aa'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_5b81a1a65e08b58afba5',
    'Fassadenbaupraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_5b81a1a65e08b58afba5'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f9b63a76e237a52be935',
    'Fleischfachassistent/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f9b63a76e237a52be935'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_af5c6c1e2086ae9976cb',
    'Florist/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_af5c6c1e2086ae9976cb'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_c328aea2d1f650be11db',
    'Formenpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_c328aea2d1f650be11db'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_1904b51164a3e1a1972e',
    'Forstpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_1904b51164a3e1a1972e'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_27ea291eb06c41cd1287',
    'Gebäudereiniger/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_27ea291eb06c41cd1287'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_68fcdc1e08a6c52f8866',
    'Gerüstbaupraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_68fcdc1e08a6c52f8866'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_fef8614d87777417c442',
    'Gipserpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_fef8614d87777417c442'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_39ff812242c5e3d58244',
    'Gleisbaupraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_39ff812242c5e3d58244'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_55b8baa49318a0e07bda',
    'Grundbaupraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_55b8baa49318a0e07bda'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_edfc26c1c0d5a773bcf9',
    'Gärtner/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_edfc26c1c0d5a773bcf9'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_d23bc2388fac7c5f56ba',
    'Hauswirtschaftspraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_d23bc2388fac7c5f56ba'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_5cc26df1f7ee5c052efc',
    'Heizungspraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_5cc26df1f7ee5c052efc'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_3d56a3bc5ffb4b2b25dc',
    'Holzbearbeiter/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_3d56a3bc5ffb4b2b25dc'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_494b87b107835e9d99d1',
    'Hotellerieangestellte/r EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_494b87b107835e9d99d1'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_267c56bfc8e927ab482d',
    'Industrie- und Unterlagsbodenbaupraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_267c56bfc8e927ab482d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_d0658c4e06528dddc412',
    'Kaufmann/-frau EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_d0658c4e06528dddc412'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_79c046045ba65be8872e',
    'Kunststoffpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_79c046045ba65be8872e'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_eb9fc85f840698a67829',
    'Kältemontage-Praktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_eb9fc85f840698a67829'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_bccee617f610e6af21f0',
    'Küchenangestellte/r EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_bccee617f610e6af21f0'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_c1a8cb5e577e1e2be382',
    'Lackierassistent/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_c1a8cb5e577e1e2be382'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f8ac0700f47df2db7b5a',
    'Lebensmittelpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f8ac0700f47df2db7b5a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_fe4bf1d87111fa3c4316',
    'Logistiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_fe4bf1d87111fa3c4316'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_5f30b954a8fe3c757d48',
    'Lüftungsanlagenpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_5f30b954a8fe3c757d48'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_43c3f8749ef140c6139c',
    'Malerpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_43c3f8749ef140c6139c'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_38273e5cfbf8f4656b6a',
    'Maurer/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_38273e5cfbf8f4656b6a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_d45efe5dd4a6ae952316',
    'Mechanikpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_d45efe5dd4a6ae952316'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_ec79b00a6af5971da9a4',
    'Metallbaupraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_ec79b00a6af5971da9a4'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_b15821877cc4a374603c',
    'Milchpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_b15821877cc4a374603c'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_94490e46fa7891c12827',
    'Montagepraktiker/in Sonnenschutz und Storentechnik EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_94490e46fa7891c12827'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_39091d979091f3340df9',
    'Oberflächenpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_39091d979091f3340df9'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_b482c337ef8c614f0a40',
    'Pferdewart/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_b482c337ef8c614f0a40'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_9b3046d91e218517f860',
    'Plattenlegerpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_9b3046d91e218517f860'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_ea01733a868f445f74a5',
    'Polisseur/Polisseuse EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_ea01733a868f445f74a5'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_3eb742aa925ad0cfb277',
    'Praktiker/in Hotellerie-Hauswirtschaft EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_3eb742aa925ad0cfb277'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_cc1b1bffccddd62e9595',
    'Praktiker/in Reinigungstechnik EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_cc1b1bffccddd62e9595'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_75b39ffb96d57ab441d1',
    'Reifenpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_75b39ffb96d57ab441d1'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_838acd0ff198a348af8f',
    'Restaurantangestellte/r EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_838acd0ff198a348af8f'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_a205e29563bee533c588',
    'Sanitärpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_a205e29563bee533c588'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_a02c77cbdc7d0418d3c5',
    'Schreinerpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_a02c77cbdc7d0418d3c5'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f94b78924b53be65dc07',
    'Seilbahner/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f94b78924b53be65dc07'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_d9b4fcf6171dc0562097',
    'Solarmonteur/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_d9b4fcf6171dc0562097'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_ad6a752f4db27cd985c3',
    'Spenglerpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_ad6a752f4db27cd985c3'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f529b9a217a80896e9f8',
    'Steinsetzer/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f529b9a217a80896e9f8'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f807d412f266583737d4',
    'Strassenbaupraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f807d412f266583737d4'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_6dc79f1facd35b2c7d18',
    'Strassentransportpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_6dc79f1facd35b2c7d18'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_bb29b767fd2d3fcb6503',
    'Systemgastronomiepraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_bb29b767fd2d3fcb6503'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f6e405287b680f39a592',
    'Textilpraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f6e405287b680f39a592'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_354b5f0c3402a7c896ec',
    'Uhrenarbeiter/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_354b5f0c3402a7c896ec'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_92407b500bd0bc8c8e39',
    'Unterhaltspraktiker/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_92407b500bd0bc8c8e39'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_81352d30838145f8275f',
    'Zweirad-Assistent/in EBA',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_81352d30838145f8275f'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Berufsattest (EBA)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_522d82f1173a76bc371a',
    'Abdichter/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_522d82f1173a76bc371a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_57b85b19f421576d866a',
    'Anlagen- und Apparatebauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_57b85b19f421576d866a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_b7efbea1b3b51fd7770a',
    'Anlagenführer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_b7efbea1b3b51fd7770a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_6c82a858f6ab5daf4675',
    'Architekturmodellbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_6c82a858f6ab5daf4675'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_140fea466b8bc4153e95',
    'Augenoptiker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_140fea466b8bc4153e95'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_e9b32f5557b5ed534263',
    'Automatiker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e9b32f5557b5ed534263'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_443902eebf3ae388a1a9',
    'Automatikmonteur/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_443902eebf3ae388a1a9'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_8c0369dfc642b4df45f9',
    'Automobil-Fachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_8c0369dfc642b4df45f9'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_8c0369dfc642b4df45f9'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_d75e98cabfa3c61ab7ee',
    'Nutzfahrzeuge',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_8c0369dfc642b4df45f9'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_8c0369dfc642b4df45f9'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_5f391c7e26dd48800b74',
    'Personenwagen',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_8c0369dfc642b4df45f9'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_edc04884ca39da8731f1',
    'Automobil-Mechatroniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_edc04884ca39da8731f1'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_edc04884ca39da8731f1'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_5eda3cea9d08606b857a',
    'Nutzfahrzeuge',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_edc04884ca39da8731f1'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_edc04884ca39da8731f1'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_46d6c60fb34ac6544386',
    'Personenwagen',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_edc04884ca39da8731f1'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_ab4b1d5f5cc70df813a1',
    'Baumaschinenmechaniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_ab4b1d5f5cc70df813a1'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_d612d2d00456463f4adc',
    'Bauwerktrenner/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_d612d2d00456463f4adc'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_35f8ee42600fa108cd4f',
    'Bekleidungsgestalter/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_35f8ee42600fa108cd4f'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_b58367311515727654bb',
    'Betonwerker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_b58367311515727654bb'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_1cc8b2d7cc6718d7f82d',
    'Bindetechnologe/-login EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_1cc8b2d7cc6718d7f82d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_928c2af0ff9cd433e99d',
    'Boden-Parkettleger/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_928c2af0ff9cd433e99d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_5d0ca594740759e35dba',
    'Bootbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_5d0ca594740759e35dba'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_cac25fecfc0be6e27407',
    'Bootfachwart/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_cac25fecfc0be6e27407'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_336224930e0148f97da2',
    'Buchhändler/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_336224930e0148f97da2'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_2fd87142973785d76b31',
    'Bäcker/in-Konditor/in-Confiseur/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_2fd87142973785d76b31'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_6fd80b4cdd48583f04ca',
    'Büchsenmacher/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_6fd80b4cdd48583f04ca'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_4f0975276345febe90d7',
    'Bühnentänzer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_4f0975276345febe90d7'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_12053243db1402a1f46a',
    'Carrosserielackierer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_12053243db1402a1f46a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_08bbcb705d58c09d7f2d',
    'Carrosseriespengler/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_08bbcb705d58c09d7f2d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_dd027aed84a60bd49c40',
    'Chemie- und Pharmatechnologe/-login EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_dd027aed84a60bd49c40'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_c8135a71aa912fc3b827',
    'Coiffeur/Coiffeuse EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_c8135a71aa912fc3b827'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_7cf8ede8c9044769fe02',
    'Dachdecker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_7cf8ede8c9044769fe02'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_841a116e71967e303122',
    'Dentalassistent/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_841a116e71967e303122'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_50b8e400027f01b9abad',
    'Detailhandelsfachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_50b8e400027f01b9abad'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_754e9b79e0c6ef494bf0',
    'Drogist/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_754e9b79e0c6ef494bf0'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f2c70a08335ce2028b25',
    'Elektroinstallateur/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f2c70a08335ce2028b25'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_5a44aae3d97e6a29d084',
    'Elektroniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_5a44aae3d97e6a29d084'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f71cbdeac5a3cfa93417',
    'Elektroplaner/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f71cbdeac5a3cfa93417'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_23e6587ccd863a41eaa5',
    'Entwickler/in digitales Business EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_23e6587ccd863a41eaa5'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_31e7dedfd45d7e2e7188',
    'Entwässerungstechnologe/-login EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_31e7dedfd45d7e2e7188'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_eb94f5adebb95ac8b272',
    'Fachfrau/Fachmann Apotheke EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_eb94f5adebb95ac8b272'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_403f05e0cc6ca3093cd2',
    'Fachfrau/Fachmann Betreuung EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_403f05e0cc6ca3093cd2'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_eb1aebe9cdec48033220',
    'Fachmann/-frau Bahntransport EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_eb1aebe9cdec48033220'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_b7465e3532fc25dc8a2a',
    'Fachmann/-frau Betriebsunterhalt EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_b7465e3532fc25dc8a2a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_b771619cab0b3234ddaf',
    'Fachmann/-frau Bewegungs- und Gesundheitsförderung EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_b771619cab0b3234ddaf'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_96167b2db3ab7adaab6a',
    'Fachmann/-frau Gesundheit EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_96167b2db3ab7adaab6a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_7776c1fed865b12e1bf7',
    'Fachmann/-frau Hotellerie-Hauswirtschaft EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_7776c1fed865b12e1bf7'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_0367e4a4e6f826f4affc',
    'Fachmann/-frau Information und Dokumentation EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_0367e4a4e6f826f4affc'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_a8beac86e85e2da32d17',
    'Fachmann/-frau Leder und Textil EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_a8beac86e85e2da32d17'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_ef617d867095827507f2',
    'Fachmann/-frau Reinigungstechnik EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_ef617d867095827507f2'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_b8afaaab8703aa7a261d',
    'Fachmann/-frau Sonnenschutz und Storentechnik EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_b8afaaab8703aa7a261d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_c72f5add2b8672d667d7',
    'Fachmann/-frau Textilpflege EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_c72f5add2b8672d667d7'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_6cd7aaa5b6ca646f0e97',
    'Fahrradmechaniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_6cd7aaa5b6ca646f0e97'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_16ced3464a624504c876',
    'Fahrzeugschlosser/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_16ced3464a624504c876'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_00db379c2acb3364b1bd',
    'Fassadenbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_00db379c2acb3364b1bd'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_cff400921f8d0f12a136',
    'Feinwerkoptiker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_cff400921f8d0f12a136'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_a85b189e76b699f7549c',
    'Fleischfachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_a85b189e76b699f7549c'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_847630b4f1a48aa0f7ab',
    'Florist/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_847630b4f1a48aa0f7ab'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_855bd01d6abe2dc7c179',
    'Formenbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_855bd01d6abe2dc7c179'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f0b32e29ff9c35fe62df',
    'Forstwart/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f0b32e29ff9c35fe62df'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_8a96699993b3a2bb669c',
    'Fotograf/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_8a96699993b3a2bb669c'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_024fb3d6b86cc82fe7c3',
    'Fotomedienfachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_024fb3d6b86cc82fe7c3'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_103ddf88ede96715cbc5',
    'Gebäudeinformatiker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_103ddf88ede96715cbc5'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_2c55365c545f64822780',
    'Gebäudetechnikplaner/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_2c55365c545f64822780'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_2c55365c545f64822780'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_b2aa0a3585ace0bee1bc',
    'Heizung',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_2c55365c545f64822780'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_2c55365c545f64822780'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_bdbba60aa6999f9c5f78',
    'Lüftung',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_2c55365c545f64822780'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_2c55365c545f64822780'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_fbfb299f1105cda02d01',
    'Sanitär',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_2c55365c545f64822780'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_389759ec54126369fced',
    'Geigenbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_389759ec54126369fced'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_0b0ac3f40ef498ea6b50',
    'Gemüsegärtner/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_0b0ac3f40ef498ea6b50'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_873315f323b0d0261016',
    'Geomatiker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_873315f323b0d0261016'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_ccb0a43f03e3a7a8c96b',
    'Gerüstbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_ccb0a43f03e3a7a8c96b'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_a2ec5e2adce74acece8c',
    'Gestalter/in Werbetechnik EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_a2ec5e2adce74acece8c'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_4b88fa8038b7c82fa91a',
    'Gewebegestalter/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_4b88fa8038b7c82fa91a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_b28e64ca982ca0802246',
    'Gipser/in-Trockenbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_b28e64ca982ca0802246'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_9b9e3c018674b55656c7',
    'Glaser/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_9b9e3c018674b55656c7'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_c2315e73855f5776d614',
    'Glasmaler/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_c2315e73855f5776d614'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_7557b9800997f6d69be4',
    'Gleisbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_7557b9800997f6d69be4'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_104acb2138b9ddf43776',
    'Goldschmied/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_104acb2138b9ddf43776'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_3dfaf8542d8b95dafe5f',
    'Grafiker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_3dfaf8542d8b95dafe5f'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_cab28033e79871f7b649',
    'Graveur/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_cab28033e79871f7b649'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_212643a49f77bc5eb16d',
    'Grundbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_212643a49f77bc5eb16d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_2072425c72c2143d6f7a',
    'Gusstechnologe/-login EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_2072425c72c2143d6f7a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_a2c8552e022dc297472a',
    'Gärtner/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_a2c8552e022dc297472a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_1cfa65d513e2bbfa7469',
    'Heizungsinstallateur/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_1cfa65d513e2bbfa7469'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_c6c83770730b709594a0',
    'Holzbildhauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_c6c83770730b709594a0'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_cc1fa9031f2ac6c99d17',
    'Holzhandwerker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_cc1fa9031f2ac6c99d17'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_0e12f34443d87c9f1e90',
    'Holzindustriefachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_0e12f34443d87c9f1e90'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_5ef8fffbd6999f6ccf57',
    'Hufschmied/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_5ef8fffbd6999f6ccf57'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_075906b30443fdbfbcb6',
    'ICT-Fachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_075906b30443fdbfbcb6'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_dd58a42d5ee6bf3ec350',
    'Industrie- und Unterlagsbodenbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_dd58a42d5ee6bf3ec350'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_e9bbdefb6b475f035784',
    'Industriekeramiker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e9bbdefb6b475f035784'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_01cb60dc660bda4038c4',
    'Industrielackierer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_01cb60dc660bda4038c4'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_dd0a80eb70f31c7aa071',
    'Industriepolsterer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_dd0a80eb70f31c7aa071'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_6ca6b47055acdfe023f7',
    'Informatiker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_6ca6b47055acdfe023f7'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_6ca6b47055acdfe023f7'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_303481ec40f318309db2',
    'Applikationsentwicklung',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_6ca6b47055acdfe023f7'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_6ca6b47055acdfe023f7'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_0af6c19f1fb8489ef031',
    'Plattformentwicklung',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_6ca6b47055acdfe023f7'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_5a966ea35a3a72858dfc',
    'Isolierspengler/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_5a966ea35a3a72858dfc'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_7715d50892f49d82d2ca',
    'Kaminfeger/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_7715d50892f49d82d2ca'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_e7263d59d9454cea2cfe',
    'Kaufmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e7263d59d9454cea2cfe'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e7263d59d9454cea2cfe'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'training_context_9c25b365459dbf17c843',
    'Bank',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e7263d59d9454cea2cfe'),
    'training_context',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Branche / Ausbildungskontext'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e7263d59d9454cea2cfe'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'training_context_c87d33b62ef8d470f17a',
    'Dienstleistung und Administration',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e7263d59d9454cea2cfe'),
    'training_context',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Branche / Ausbildungskontext'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e7263d59d9454cea2cfe'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'training_context_ae8ebe29d91cb4776b01',
    'Handel',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e7263d59d9454cea2cfe'),
    'training_context',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Branche / Ausbildungskontext'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e7263d59d9454cea2cfe'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'search_alias_3545948f6bdc4e17e6b3',
    'Profil B',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e7263d59d9454cea2cfe'),
    'search_alias',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Frühere KV-Ausbildungsordnung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e7263d59d9454cea2cfe'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'search_alias_c5d7c5d1f87836728ee6',
    'Profil E',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e7263d59d9454cea2cfe'),
    'search_alias',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Frühere KV-Ausbildungsordnung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e7263d59d9454cea2cfe'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'search_alias_55053a98bd841a441752',
    'Profil M / mit Berufsmaturität',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e7263d59d9454cea2cfe'),
    'search_alias',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Auch als Suchbegriff; BM separat erfassen'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e7263d59d9454cea2cfe'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'training_context_b724333a68da0b23f95b',
    'Reisen',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e7263d59d9454cea2cfe'),
    'training_context',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Branche / Ausbildungskontext'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e7263d59d9454cea2cfe'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'training_context_d8a37f8766de6584ec61',
    'Treuhand / Immobilien',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e7263d59d9454cea2cfe'),
    'training_context',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Branche / Ausbildungskontext'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e7263d59d9454cea2cfe'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'training_context_3acb582243f77e46d3e6',
    'Versicherung',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e7263d59d9454cea2cfe'),
    'training_context',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Branche / Ausbildungskontext'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e7263d59d9454cea2cfe'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'training_context_1f549fafaba9a089b680',
    'Öffentliche Verwaltung',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e7263d59d9454cea2cfe'),
    'training_context',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Branche / Ausbildungskontext'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_0fbe91e6a5549d8e983a',
    'Koch/Köchin EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_0fbe91e6a5549d8e983a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_788dc4368d4b33285f81',
    'Konstrukteur/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_788dc4368d4b33285f81'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_cd28c57a8ecbe9f12026',
    'Kosmetiker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_cd28c57a8ecbe9f12026'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_b726cbd648a03f5bedad',
    'Kunststofftechnologe/-login EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_b726cbd648a03f5bedad'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_2b2145affffccc983faa',
    'Kältesystem-Monteur/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_2b2145affffccc983faa'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_26f8d390d82fd95eaeb5',
    'Kältesystem-Planer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_26f8d390d82fd95eaeb5'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_ad7c6123b26e37866649',
    'Laborant/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_ad7c6123b26e37866649'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_ad7c6123b26e37866649'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_c3dd15c2a0c97c8abaf6',
    'Chemie',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_ad7c6123b26e37866649'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_40e1fcaf155e24076343',
    'Landmaschinenmechaniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_40e1fcaf155e24076343'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_330d460704e064c96e9f',
    'Landwirt/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_330d460704e064c96e9f'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_68336824332d43b0ad45',
    'Lebensmitteltechnologe/-login EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_68336824332d43b0ad45'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_31f4a8f51d6f9e13f791',
    'Logistiker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_31f4a8f51d6f9e13f791'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_530ba4cffc666097a51d',
    'Lüftungsanlagenbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_530ba4cffc666097a51d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_69389d5f8537c697d06a',
    'Maler/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_69389d5f8537c697d06a'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_84d67477821c5e8b7906',
    'Maurer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_84d67477821c5e8b7906'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_d6842110c9ece263b512',
    'Mediamatiker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_d6842110c9ece263b512'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_80bd36dbacb7526a0766',
    'Medientechnologe/-login EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_80bd36dbacb7526a0766'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_8a9a0c32f22dcb7220cc',
    'Medizinische/r Praxisassistent/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_8a9a0c32f22dcb7220cc'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_16d24e880fdd58d57ac4',
    'Metallbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_16d24e880fdd58d57ac4'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_9c296be4863ebbd6886d',
    'Metallbaukonstrukteur/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_9c296be4863ebbd6886d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f52c1f427bf4057deb01',
    'Mikromechaniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f52c1f427bf4057deb01'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_dd54843d58dc7fb3fee7',
    'Mikrozeichner/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_dd54843d58dc7fb3fee7'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_1b8c202269aef21471c1',
    'Milchtechnologe/-login EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_1b8c202269aef21471c1'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_40182f2de1a7df224fb1',
    'Montage-Elektriker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_40182f2de1a7df224fb1'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_318c9329ec9651870e34',
    'Motorgerätemechaniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_318c9329ec9651870e34'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_c665915921dafb85f64b',
    'Motorradmechaniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_c665915921dafb85f64b'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_7f9c10c9916967c5701c',
    'Multimediaelektroniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_7f9c10c9916967c5701c'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_e139191464b71b18be31',
    'Nautische/r Fachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e139191464b71b18be31'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_20956beda6dc80cebf82',
    'Netzelektriker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_20956beda6dc80cebf82'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_95e6083995b26ae16ca9',
    'Oberflächenbeschichter/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_95e6083995b26ae16ca9'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_02b5804c5e9fa1e7fbfb',
    'Oberflächenveredler/in Uhren und Schmuck EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_02b5804c5e9fa1e7fbfb'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_d690192c48ed34bcf4b2',
    'Obstfachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_d690192c48ed34bcf4b2'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_5676419002e7011cfe15',
    'Ofenbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_5676419002e7011cfe15'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_298d19e116f4e5b6c551',
    'Orthopädieschuhmacher/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_298d19e116f4e5b6c551'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_45500b26eb0ce80f7dc2',
    'Papiertechnologe/-login EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_45500b26eb0ce80f7dc2'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_b5742c5772da8d2badab',
    'Pferdefachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_b5742c5772da8d2badab'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_7d2978b5b833d401e4f4',
    'Pflästerer/Pflästerin EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_7d2978b5b833d401e4f4'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_7148a946fdb005971e2f',
    'Pharma-Assistent/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'historical_review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_7148a946fdb005971e2f'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_1547a4fa75e0ed5a1341',
    'Physiklaborant/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_1547a4fa75e0ed5a1341'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_2eee7db3a961be17cc9d',
    'Plattenleger/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_2eee7db3a961be17cc9d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_fc93c434c040dca3324b',
    'Podologe/Podologin EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_fc93c434c040dca3324b'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_6dd50076e9629aabb6e5',
    'Polydesigner/in 3D EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_6dd50076e9629aabb6e5'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_9abf13f1a817dfd78796',
    'Polygraf/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_9abf13f1a817dfd78796'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_79946d1d65844a851ab8',
    'Polymechaniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_79946d1d65844a851ab8'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_e85e009793478489a5b0',
    'Produktionsmechaniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e85e009793478489a5b0'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_13b77cae3712354e9162',
    'Raumausstatter/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_13b77cae3712354e9162'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_053e42d98b0d1dc0ab23',
    'Recyclist/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_053e42d98b0d1dc0ab23'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_38c0b32c86b5e40b89f8',
    'Restaurantfachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_38c0b32c86b5e40b89f8'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_88888551902d33243ed9',
    'Sanitärinstallateur/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_88888551902d33243ed9'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_a9877c689aefbc246c8c',
    'Schreiner/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_a9877c689aefbc246c8c'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_664cc89c07652ddc6f39',
    'Schuhmacher/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_664cc89c07652ddc6f39'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f24a32ccf53e769ff162',
    'Seilbahn-Mechatroniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f24a32ccf53e769ff162'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_b60fc8b89b8d931fa7f6',
    'Solarinstallateur/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_b60fc8b89b8d931fa7f6'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_6764580ca52db3eca2ab',
    'Spengler/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_6764580ca52db3eca2ab'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f282e1f1b7cb1531384d',
    'Steinmetz/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f282e1f1b7cb1531384d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_e923abf40f750a9d61f2',
    'Strassenbauer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e923abf40f750a9d61f2'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_2776e7c9ec1d09a3ec5b',
    'Strassentransportfachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_2776e7c9ec1d09a3ec5b'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_3499a635e0d9856fb6e1',
    'Systemgastronomiefachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_3499a635e0d9856fb6e1'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_e74f71c015c9029b556d',
    'Textiltechnologe/-login EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e74f71c015c9029b556d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e74f71c015c9029b556d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_441729548a22aa264aee',
    'Design',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e74f71c015c9029b556d'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e74f71c015c9029b556d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_819d67472c4eed2af904',
    'Seil- und Hebetechnik',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e74f71c015c9029b556d'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e74f71c015c9029b556d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_b30a07d2e2cc0c83c13e',
    'Verarbeitung',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e74f71c015c9029b556d'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_e74f71c015c9029b556d'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'specialization_c0552cbf98002587860e',
    'Veredlung',
    (SELECT id FROM public.education_fields WHERE code = 'apprenticeship_e74f71c015c9029b556d'),
    'specialization',
    'CH',
    'SBFI / Berufsberatung / KV',
    'Fachrichtung'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_9b287bd9727209db4937',
    'Theatermaler/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_9b287bd9727209db4937'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_d62c8a01f5b49ceacb28',
    'Tiermedizinische/r Praxisassistent/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_d62c8a01f5b49ceacb28'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_ea8a96d9bafed6baf40b',
    'Tierpfleger/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_ea8a96d9bafed6baf40b'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_d39cb5b531dc7cad7107',
    'Uhrmacher/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_d39cb5b531dc7cad7107'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_b079e75d5a7602e3e991',
    'Uhrmacher/in Produktion EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_b079e75d5a7602e3e991'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_86335e2d8750dfcde5dd',
    'Veranstaltungsfachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_86335e2d8750dfcde5dd'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_7f373701a131f1dac6e4',
    'Vergolder/in-Einrahmer/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_7f373701a131f1dac6e4'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_de7897be310c7afb5049',
    'Verpackungsdrucker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_de7897be310c7afb5049'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_a901f57f6cee2a98fd8b',
    'Verpackungstechnologe/-login EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_a901f57f6cee2a98fd8b'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_f222e960a6634b8d67c8',
    'Weinfachmann/-frau EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_f222e960a6634b8d67c8'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_cce7e7a5cfd1471627ea',
    'Wohntextilgestalter/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_cce7e7a5cfd1471627ea'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_cadcf8fdd2a5e385c4c4',
    'Zahntechniker/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_cadcf8fdd2a5e385c4c4'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_fd77c5460e57b369e0ea',
    'Zeichner/in EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_fd77c5460e57b369e0ea'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;


INSERT INTO public.education_fields
    (
        code,
        name_de,
        parent_id,
        field_kind,
        country_code,
        source_name,
        validation_status
    )
VALUES (
    'apprenticeship_60534f37d9113478dab6',
    'Zimmermann/Zimmerin EFZ',
    NULL,
    'apprenticeship',
    'CH',
    'SBFI / berufsberatung.ch',
    'review_required'
)
ON CONFLICT (code) DO NOTHING;


INSERT INTO public.education_degree_fields
    (education_type_degree_id, education_field_id)
SELECT d.id, f.id
FROM public.education_type_degrees d
JOIN public.education_types t
    ON t.id = d.education_type_id
JOIN public.education_fields f
    ON f.code = 'apprenticeship_60534f37d9113478dab6'
WHERE t.code = 'A02'
  AND d.name_de = 'Eidgenössisches Fähigkeitszeugnis (EFZ)'
ON CONFLICT DO NOTHING;








-- Validierung der importierten Education-Taxonomie.
-- Diese Prüfung läuft innerhalb derselben Transaktion.

DO $$
DECLARE
    v_apprenticeships integer;
    v_degree_links integer;
    v_missing_degree_links integer;
    v_missing_parents integer;
    v_study_fields integer;
BEGIN
    SELECT COUNT(*)
    INTO v_apprenticeships
    FROM public.education_fields
    WHERE field_kind = 'apprenticeship'
      AND code LIKE 'apprenticeship_%';

    IF v_apprenticeships <> 224 THEN
        RAISE EXCEPTION
            'Erwartet: 224 Lehrberufe; gefunden: %',
            v_apprenticeships;
    END IF;

    SELECT COUNT(*)
    INTO v_degree_links
    FROM public.education_degree_fields edf
    JOIN public.education_fields f
        ON f.id = edf.education_field_id
    JOIN public.education_type_degrees d
        ON d.id = edf.education_type_degree_id
    JOIN public.education_types t
        ON t.id = d.education_type_id
    WHERE f.field_kind = 'apprenticeship'
      AND f.code LIKE 'apprenticeship_%'
      AND t.code = 'A02'
      AND d.name_de IN (
          'Eidgenössisches Fähigkeitszeugnis (EFZ)',
          'Eidgenössisches Berufsattest (EBA)'
      );

    IF v_degree_links <> 224 THEN
        RAISE EXCEPTION
            'Erwartet: 224 EFZ/EBA-Zuordnungen; gefunden: %',
            v_degree_links;
    END IF;

    SELECT COUNT(*)
    INTO v_missing_degree_links
    FROM public.education_fields f
    WHERE f.field_kind = 'apprenticeship'
      AND f.code LIKE 'apprenticeship_%'
      AND NOT EXISTS (
          SELECT 1
          FROM public.education_degree_fields edf
          WHERE edf.education_field_id = f.id
      );

    IF v_missing_degree_links <> 0 THEN
        RAISE EXCEPTION
            '% Lehrberufe ohne Abschlusszuordnung',
            v_missing_degree_links;
    END IF;

    SELECT COUNT(*)
    INTO v_missing_parents
    FROM public.education_fields
    WHERE field_kind IN (
        'study_field',
        'specialization',
        'training_context',
        'search_alias'
    )
      AND parent_id IS NULL;

    IF v_missing_parents <> 0 THEN
        RAISE EXCEPTION
            '% Untereinträge ohne Elternknoten',
            v_missing_parents;
    END IF;

    SELECT COUNT(*)
    INTO v_study_fields
    FROM public.education_fields
    WHERE field_kind = 'study_field'
      AND code LIKE 'study_field_%';

    IF v_study_fields <> 131 THEN
        RAISE EXCEPTION
            'Erwartet: 131 Studienrichtungen; gefunden: %',
            v_study_fields;
    END IF;

    RAISE NOTICE
        'Education-Import validiert: % Lehrberufe, % Abschlusszuordnungen, % Studienrichtungen',
        v_apprenticeships,
        v_degree_links,
        v_study_fields;
END $$;



COMMIT;



