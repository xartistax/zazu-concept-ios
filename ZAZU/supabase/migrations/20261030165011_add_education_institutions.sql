
BEGIN;

CREATE TABLE public.education_institution_types (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name_de text NOT NULL UNIQUE,
    typical_education_type text,
    countries text[] NOT NULL DEFAULT '{}',
    note text,
    sort_order integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.education_institutions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_type_id uuid NOT NULL
        REFERENCES public.education_institution_types(id),
    name text NOT NULL,
    country_code text NOT NULL DEFAULT 'CH',
    source_url text,
    validation_status text NOT NULL DEFAULT 'review_required',
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT education_institutions_country_name_unique
        UNIQUE (country_code, name)
);

CREATE INDEX education_institutions_type_idx
    ON public.education_institutions(institution_type_id);

ALTER TABLE public.educations
    ADD COLUMN institution_type_id uuid
        REFERENCES public.education_institution_types(id),
    ADD COLUMN institution_id uuid
        REFERENCES public.education_institutions(id);

CREATE INDEX educations_institution_type_idx
    ON public.educations(institution_type_id);

CREATE INDEX educations_institution_idx
    ON public.educations(institution_id);

ALTER TABLE public.education_institution_types
    ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.education_institutions
    ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read institution types"
    ON public.education_institution_types
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "Authenticated users can read institutions"
    ON public.education_institutions
    FOR SELECT TO authenticated
    USING (true);

GRANT SELECT ON public.education_institution_types TO authenticated;
GRANT SELECT ON public.education_institutions TO authenticated;

-- GENERATED EDUCATION INSTITUTION SEEDS

INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Universität', 'Studium', ARRAY['CH', 'DE']::text[], 'Universität / universitäre Hochschule', 1);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('ETH / EPFL', 'Studium', ARRAY['CH']::text[], 'Eidgenössische Technische Hochschule', 2);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Fachhochschule (FH)', 'Studium', ARRAY['CH']::text[], 'Hochschule für angewandte Wissenschaften', 3);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Pädagogische Hochschule (PH)', 'Studium / Lehrdiplom', ARRAY['CH']::text[], 'Pädagogische Hochschule', 4);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Höhere Fachschule (HF)', 'Höhere Berufsbildung', ARRAY['CH']::text[], 'Höhere Fachschule', 5);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Berufsfachschule', 'Berufslehre / Berufsmaturität', ARRAY['CH']::text[], 'Schulischer Teil der Lehre', 6);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Lehrbetrieb', 'Berufslehre', ARRAY['CH', 'DE']::text[], 'Betrieblicher Teil der Lehre', 7);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Berufsmaturitätsschule (BMS)', 'Berufsmaturität', ARRAY['CH']::text[], 'BM1 / BM2', 8);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Gymnasium / Kantonsschule', 'Gymnasiale Maturität', ARRAY['CH']::text[], 'Allgemeinbildende Schule', 9);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Fachmittelschule (FMS)', 'Fachmittelschule / Fachmaturität', ARRAY['CH']::text[], 'Fachmittelschule', 10);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Passerellenanbieter / Prüfungsträger', 'Passerelle', ARRAY['CH']::text[], 'Kursanbieter und Prüfung getrennt', 11);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Handelsmittelschule / Wirtschaftsmittelschule', 'Berufslehre / Berufsmaturität', ARRAY['CH']::text[], 'Je nach Bildungsgang', 12);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Berufsakademie / Duale Hochschule', 'Studium / Ausbildung', ARRAY['DE']::text[], 'Je nach Bundesland und Abschluss', 13);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Berufskolleg / Berufsfachschule', 'Berufsausbildung / Schulabschluss', ARRAY['DE']::text[], 'Je nach Bundesland', 14);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Fachschule', 'Aufstiegsfortbildung', ARRAY['DE']::text[], 'Nicht mit CH-HF gleichsetzen', 15);
INSERT INTO public.education_institution_types (name_de, typical_education_type, countries, note, sort_order) VALUES ('Weiterbildungsanbieter', 'Weiterbildung', ARRAY['CH', 'DE']::text[], 'Träger / ausstellende Institution', 16);

INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Universität Basel', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Universität';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Universität Bern', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Universität';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Universität Freiburg / Université de Fribourg', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Universität';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Universität Genf / Université de Genève', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Universität';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Universität Lausanne / Université de Lausanne', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Universität';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Universität Luzern', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Universität';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Universität Neuenburg / Université de Neuchâtel', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Universität';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Universität St. Gallen (HSG)', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Universität';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Universität Zürich', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Universität';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Università della Svizzera italiana (USI)', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Universität';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'ETH Zürich', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'ETH / EPFL';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'EPFL', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'ETH / EPFL';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'FernUni Schweiz', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Universität';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Zürcher Hochschule für Angewandte Wissenschaften (ZHAW)', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Fachhochschule (FH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Zürcher Hochschule der Künste (ZHdK)', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Fachhochschule (FH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Hochschule Luzern (HSLU)', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Fachhochschule (FH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Fachhochschule Nordwestschweiz (FHNW)', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Fachhochschule (FH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'OST – Ostschweizer Fachhochschule', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Fachhochschule (FH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Berner Fachhochschule (BFH)', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Fachhochschule (FH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Fachhochschule Graubünden (FHGR)', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Fachhochschule (FH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Haute école spécialisée de Suisse occidentale (HES-SO)', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Fachhochschule (FH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Scuola universitaria professionale della Svizzera italiana (SUPSI)', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Fachhochschule (FH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Kalaidos Fachhochschule', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Fachhochschule (FH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Pädagogische Hochschule Zürich', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Pädagogische Hochschule (PH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Pädagogische Hochschule Bern', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Pädagogische Hochschule (PH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Pädagogische Hochschule Luzern', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Pädagogische Hochschule (PH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Pädagogische Hochschule St. Gallen', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Pädagogische Hochschule (PH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Pädagogische Hochschule FHNW', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Pädagogische Hochschule (PH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Pädagogische Hochschule Graubünden', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Pädagogische Hochschule (PH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Pädagogische Hochschule Schwyz', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Pädagogische Hochschule (PH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Pädagogische Hochschule Thurgau', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Pädagogische Hochschule (PH)';
INSERT INTO public.education_institutions (institution_type_id, name, country_code, source_url, validation_status) SELECT id, 'Pädagogische Hochschule Zug', 'CH', 'https://www.swissuniversities.ch/', 'review_required' FROM public.education_institution_types WHERE name_de = 'Pädagogische Hochschule (PH)';

DO $$
DECLARE
    type_count integer;
    institution_count integer;
BEGIN
    SELECT COUNT(*) INTO type_count
    FROM public.education_institution_types;
    SELECT COUNT(*) INTO institution_count
    FROM public.education_institutions;
    IF type_count <> 16 OR institution_count <> 32 THEN
        RAISE EXCEPTION
            'Institutionsimport unvollständig: % Typen, % Institutionen',
            type_count, institution_count;
    END IF;
END $$;

COMMIT;

