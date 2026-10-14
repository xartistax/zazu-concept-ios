begin;

drop function public.create_employer_company(
    text,
    text,
    text,
    text,
    text,
    text,
    text,
    text,
    text,
    text
);

create function public.create_employer_company(
    p_name text,
    p_description text default null,
    p_industry text default null,
    p_company_size text default null,
    p_website text default null,
    p_location text default null,
    p_contact_first_name text default null,
    p_contact_last_name text default null,
    p_contact_email text default null,
    p_contact_phone text default null,
    p_legal_form text default null,
    p_location_latitude double precision default null,
    p_location_longitude double precision default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
    v_user_id uuid;
    v_company_id uuid;
begin
    v_user_id := auth.uid();

    if v_user_id is null then
        raise exception 'Not authenticated';
    end if;

    if not exists (
        select 1
        from public.profiles
        where id = v_user_id
          and account_role = 'employer'
    ) then
        raise exception 'Employer account required';
    end if;

    if exists (
        select 1
        from public.company_memberships
        where user_id = v_user_id
    ) then
        raise exception 'Employer already belongs to a company';
    end if;

    if nullif(trim(p_name), '') is null then
        raise exception 'Company name is required';
    end if;

    if nullif(trim(p_industry), '') is null then
        raise exception 'Industry is required';
    end if;

    if nullif(trim(p_location), '') is null then
        raise exception 'Location is required';
    end if;

    if nullif(trim(p_contact_first_name), '') is null then
        raise exception 'Contact first name is required';
    end if;

    if nullif(trim(p_contact_last_name), '') is null then
        raise exception 'Contact last name is required';
    end if;

    if nullif(trim(p_contact_email), '') is null then
        raise exception 'Contact email is required';
    end if;

    insert into public.companies (
        name,
        description,
        industry,
        company_size,
        legal_form,
        website,
        location,
        location_latitude,
        location_longitude,
        contact_first_name,
        contact_last_name,
        contact_email,
        contact_phone,
        onboarding_completed
    )
    values (
        trim(p_name),
        nullif(trim(p_description), ''),
        trim(p_industry),
        nullif(trim(p_company_size), ''),
        nullif(trim(p_legal_form), ''),
        nullif(trim(p_website), ''),
        trim(p_location),
        p_location_latitude,
        p_location_longitude,
        trim(p_contact_first_name),
        trim(p_contact_last_name),
        trim(p_contact_email),
        nullif(trim(p_contact_phone), ''),
        true
    )
    returning id into v_company_id;

    insert into public.company_memberships (
        company_id,
        user_id,
        role,
        verification_status
    )
    values (
        v_company_id,
        v_user_id,
        'admin',
        'unverified'
    );

    return v_company_id;
end;
$function$;

revoke all on function public.create_employer_company(
    text, text, text, text, text, text, text,
    text, text, text, text, double precision, double precision
) from public;

grant execute on function public.create_employer_company(
    text, text, text, text, text, text, text,
    text, text, text, text, double precision, double precision
) to authenticated;

commit;
