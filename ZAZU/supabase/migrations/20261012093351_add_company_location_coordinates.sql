alter table public.companies
    add column location_latitude double precision,
    add column location_longitude double precision;

alter table public.companies
    add constraint companies_location_coordinates_pair_check
    check (
        (location_latitude is null and location_longitude is null)
        or
        (location_latitude is not null and location_longitude is not null)
    );

alter table public.companies
    add constraint companies_location_latitude_range_check
    check (
        location_latitude is null
        or location_latitude between -90 and 90
    );

alter table public.companies
    add constraint companies_location_longitude_range_check
    check (
        location_longitude is null
        or location_longitude between -180 and 180
    );
