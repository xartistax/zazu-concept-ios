begin;

-- Berufszuordnungen der alten ESCO-Skills entfernen.
delete from public.occupation_skills os
using public.skills s
where os.skill_id = s.id
  and nullif(trim(s.skill_code), '') is null
  and nullif(trim(s.esco_uri), '') is not null;

-- Nur die eindeutig identifizierten alten ESCO-Skills entfernen.
delete from public.skills
where nullif(trim(skill_code), '') is null
  and nullif(trim(esco_uri), '') is not null;

commit;

-- Verbleibenden Bestand prüfen.
select
    count(*) as skills_verbleibend,
    count(*) filter (
        where nullif(trim(skill_code), '') is not null
    ) as mit_katalog_id
from public.skills;
