with raw_availability as (
    SELECT hut_id, availability_data_list FROM {{source("raw_alpine_huts", "availability")}}
),

unnested as (
    select 
        {{ dbt_utils.generate_surrogate_key(['hut_id', 'availability_data.date']) }} as hut_availability_id,
        hut_id,
        availability_data.hut_status,  
        availability_data.free_beds,
        availability_data.total_sleeping_places,
        cast(from_iso8601_timestamp(availability_data.date) as TIMESTAMP) as availability_date
    from raw_availability
    cross join unnest(availability_data_list) as t(availability_data)
)

select * from unnested;
