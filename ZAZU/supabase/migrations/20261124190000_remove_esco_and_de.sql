-- ============================================================
-- ZAZU – Fokus Schweiz: ESCO-Berufe und Deutschland entfernen
-- ============================================================
--
-- Vorerst konzentriert sich ZAZU auf die Schweiz:
--   * ESCO-Berufe und -Berufskategorien werden gelöscht, es bleibt CH-ISCO-19.
--   * Institutionstypen nur für Deutschland werden gelöscht.
--   * Bei Ausbildungs- und Institutionstypen für CH und DE wird DE entfernt.
--
-- Vor dem Löschen geprüft (Produktion, 24.11.2026): Keine Jobs, Zuordnungen,
-- Beruf-Skills, Institutionen oder Kandidaten-Ausbildungen verweisen auf die
-- betroffenen Einträge. Die Daten sind lokal gesichert (JSON).
--
-- Die CHECK-Constraints erlauben 'esco' weiterhin, damit ein späterer
-- Re-Import ohne Schema-Änderung möglich bleibt.

BEGIN;

DELETE FROM public.occupations
WHERE source = 'esco';

-- parent_id ist ON DELETE RESTRICT: von den Blättern nach oben löschen
DO $$
DECLARE
    deleted integer;
BEGIN
    LOOP
        DELETE FROM public.occupation_categories c
        WHERE c.source = 'esco'
          AND NOT EXISTS (
              SELECT 1
              FROM public.occupation_categories child
              WHERE child.parent_id = c.id
          );
        GET DIAGNOSTICS deleted = ROW_COUNT;
        EXIT WHEN deleted = 0;
    END LOOP;

    IF EXISTS (SELECT 1 FROM public.occupation_categories WHERE source = 'esco') THEN
        RAISE EXCEPTION 'ESCO-Kategorien konnten nicht vollständig gelöscht werden';
    END IF;
END $$;

DELETE FROM public.education_institution_types
WHERE countries = ARRAY['DE'];

UPDATE public.education_institution_types
SET countries = array_remove(countries, 'DE')
WHERE 'DE' = ANY(countries);

UPDATE public.education_types
SET countries = array_remove(countries, 'DE')
WHERE 'DE' = ANY(countries);

COMMIT;
