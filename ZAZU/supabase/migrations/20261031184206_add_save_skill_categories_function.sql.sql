begin;

create function public.save_candidate_skill_categories(
    p_category_ids uuid[]
)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
declare
    v_candidate_id uuid := auth.uid();
begin
    if v_candidate_id is null then
        raise exception 'Anmeldung erforderlich';
    end if;

    -- Gleichzeitige Speichervorgänge desselben Nutzers nacheinander ausführen.
    perform pg_catalog.pg_advisory_xact_lock(
        pg_catalog.hashtextextended(v_candidate_id::text, 0)
    );

    delete from public.candidate_skill_categories
    where candidate_id = v_candidate_id;

    insert into public.candidate_skill_categories (
        candidate_id,
        category_id
    )
    select distinct
        v_candidate_id,
        category_id
    from pg_catalog.unnest(
        coalesce(p_category_ids, '{}'::uuid[])
    ) as selected_categories(category_id);
end;
$$;

revoke all on function public.save_candidate_skill_categories(uuid[])
    from public, anon;

grant execute on function public.save_candidate_skill_categories(uuid[])
    to authenticated;

commit;SkillRepository.swift
