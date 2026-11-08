begin;

create table public.candidate_skill_categories (
    candidate_id uuid not null
        references public.candidate_profiles(user_id)
        on delete cascade,

    category_id uuid not null
        references public.skill_categories(id)
        on delete cascade,

    created_at timestamptz not null default now(),

    primary key (candidate_id, category_id)
);

create index candidate_skill_categories_category_id_idx
    on public.candidate_skill_categories(category_id);

alter table public.candidate_skill_categories
    enable row level security;

revoke all on table public.candidate_skill_categories
    from anon, authenticated;

grant select, insert, delete
    on table public.candidate_skill_categories
    to authenticated;

create policy "Read own skill categories"
on public.candidate_skill_categories
for select
to authenticated
using (candidate_id = (select auth.uid()));

create policy "Insert own skill categories"
on public.candidate_skill_categories
for insert
to authenticated
with check (candidate_id = (select auth.uid()));

create policy "Delete own skill categories"
on public.candidate_skill_categories
for delete
to authenticated
using (candidate_id = (select auth.uid()));

commit;
