
alter table public.candidate_profiles
    add column if not exists region_latitude double precision,
    add column if not exists region_longitude double precision;

alter table public.candidate_profiles
    add constraint candidate_region_coordinates_pair_check
    check (
        (region_latitude is null and region_longitude is null)
        or
        (region_latitude is not null and region_longitude is not null)
    );

alter table public.candidate_profiles
    add constraint candidate_region_latitude_range_check
    check (
        region_latitude is null
        or region_latitude between -90 and 90
    );

alter table public.candidate_profiles
    add constraint candidate_region_longitude_range_check
    check (
        region_longitude is null
        or region_longitude between -180 and 180
    );
