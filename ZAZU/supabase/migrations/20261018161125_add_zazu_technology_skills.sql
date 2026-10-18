-- ZAZU: Ergänzende Technologie- und Systemkenntnisse
-- Bestehende ESCO-Skills bleiben unverändert.
-- esco_uri bleibt NULL, da diese Einträge ZAZU-Ergänzungen sind.

INSERT INTO public.skills (
    name,
    category
)

SELECT
    new_skill.name,
    'knowledge'
FROM (
    VALUES
        ('Microsoft Excel'),
        ('React'),
        ('React Native')

) AS new_skill(name)

WHERE NOT EXISTS (
    SELECT 1
    FROM public.skills AS existing_skill
    WHERE lower(trim(existing_skill.name)) = lower(trim(new_skill.name))

);
