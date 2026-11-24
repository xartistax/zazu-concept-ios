-- ============================================================
-- ZAZU – Admin-Panel: Prüfliste für importierte Kataloge
-- ============================================================
--
-- education_fields und education_institutions wurden aus externen
-- Quellen importiert und tragen einen Prüfstatus:
--   review_required     – noch nicht kontrolliert
--   verified            – von einem Admin geprüft
--   reference_category  – Referenzkategorie der Quelle, keine Prüfung nötig
--                         (nur education_fields)
--
-- Bereinigung: Beim Import sind bei einigen Fachrichtungen Notizen aus
-- der Quelltabelle in validation_status gelandet. Sie wandern in die
-- neue Spalte note, die Einträge werden auf review_required gesetzt.
--
-- reviewed_at / reviewed_by werden per Trigger gesetzt, sobald ein
-- Eintrag auf verified wechselt, und beim Zurücksetzen wieder geleert.

BEGIN;

ALTER TABLE public.education_fields
    ADD COLUMN note text,
    ADD COLUMN reviewed_at timestamptz,
    ADD COLUMN reviewed_by uuid
        REFERENCES auth.users(id)
        ON DELETE SET NULL;

ALTER TABLE public.education_institutions
    ADD COLUMN reviewed_at timestamptz,
    ADD COLUMN reviewed_by uuid
        REFERENCES auth.users(id)
        ON DELETE SET NULL;


-- ------------------------------------------------------------
-- Bereinigung der Importfehler
-- ------------------------------------------------------------

UPDATE public.education_fields
SET note = CASE validation_status
               WHEN 'historical_review_required'
                   THEN 'Historischer Lehrberuf – prüfen, ob er noch angeboten wird.'
               ELSE validation_status
           END,
    validation_status = 'review_required'
WHERE validation_status IS NULL
   OR validation_status NOT IN ('review_required', 'verified', 'reference_category');

ALTER TABLE public.education_fields
    ALTER COLUMN validation_status SET DEFAULT 'review_required',
    ALTER COLUMN validation_status SET NOT NULL,
    ADD CONSTRAINT education_fields_validation_status_check
        CHECK (validation_status IN ('review_required', 'verified', 'reference_category'));

ALTER TABLE public.education_institutions
    ADD CONSTRAINT education_institutions_validation_status_check
        CHECK (validation_status IN ('review_required', 'verified'));


-- ------------------------------------------------------------
-- Wer hat wann geprüft
-- ------------------------------------------------------------

CREATE FUNCTION public.set_catalog_review()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    IF NEW.validation_status = 'verified' THEN
        IF TG_OP = 'INSERT' OR OLD.validation_status IS DISTINCT FROM 'verified' THEN
            NEW.reviewed_at := now();
            NEW.reviewed_by := (SELECT auth.uid());
        ELSE
            -- Bleibt geprüft: Prüfvermerk nicht überschreiben lassen
            NEW.reviewed_at := OLD.reviewed_at;
            NEW.reviewed_by := OLD.reviewed_by;
        END IF;
    ELSE
        NEW.reviewed_at := NULL;
        NEW.reviewed_by := NULL;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER education_fields_set_review
    BEFORE INSERT OR UPDATE ON public.education_fields
    FOR EACH ROW EXECUTE FUNCTION public.set_catalog_review();

CREATE TRIGGER education_institutions_set_review
    BEFORE INSERT OR UPDATE ON public.education_institutions
    FOR EACH ROW EXECUTE FUNCTION public.set_catalog_review();

CREATE INDEX education_fields_validation_status_idx
    ON public.education_fields(validation_status);

CREATE INDEX education_institutions_validation_status_idx
    ON public.education_institutions(validation_status);

COMMIT;
