{{ 
    config(
        materialized='table',
        table_type='iceberg',
        format='parquet',
    )
}}

with raw_alpine_huts as (
    SELECT hut_id, hut_info_data FROM {{source("raw_alpine_huts", "hut_info")}}
),

renamed_alpine_huts as (
    select 
        hut_id,
        hut_info_data.hut_name,
        hut_info_data.coordinates
    from raw_alpine_huts
),

coordinates_array as (
    select 
        regexp_split(coordinates, '[,|/]') as coords_array, hut_id from renamed_alpine_huts),

raw_coordinates as (
    select 
        hut_id,
        case 
            when cardinality(coords_array) != 2
            then null
            else try_cast(trim(coords_array[1]) as double) 
        end as latitude,
        case 
            when cardinality(coords_array) != 2
            then null
            else try_cast(trim(coords_array[2]) as double) 
        end as longitude
    from coordinates_array
),

coordinates_sanitized as (
    select 
        hut_id,
        if(latitude > longitude, latitude, longitude) as latitude,
        if(longitude < latitude, longitude, latitude) as longitude
    from raw_coordinates
    where latitude is not null and longitude is not null and latitude < 70 and latitude > 35 and longitude > 0 and longitude < 26 
),

joined as (
    select
        renamed_alpine_huts.hut_id,
        hut_name,
        latitude,
        longitude
    from renamed_alpine_huts 
    left join coordinates_sanitized
    on coordinates_sanitized.hut_id = renamed_alpine_huts.hut_id
)

select * from joined
