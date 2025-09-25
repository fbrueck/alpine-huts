with raw_availability as (
    SELECT hut_id, availability_data_list FROM {{source("raw_alpine_huts", "availability")}}
),

hut_info as (
    SELECT hut_id, hut_name, latitude, longitude FROM {{ref("hut_info")}}
),

unnested as (
    select 
        hut_id,
        availability_data,
        cast(from_iso8601_timestamp(availability_data.date) as TIMESTAMP) as availability_date
    from raw_availability
    cross join unnest(availability_data_list) as t(availability_data)
),

projected as (
    select
        hut_id,
        availability_data.hut_status,  
        availability_data.free_beds,
        availability_data.total_sleeping_places,

        month(availability_date) as month,
        year(availability_date) as year,
        day_of_month(availability_date) as day,
        availability_date,

        CASE
            WHEN day_of_week(availability_date) = 1 THEN 'Monday'
            WHEN day_of_week(availability_date) = 2 THEN 'Tuesday'
            WHEN day_of_week(availability_date) = 3 THEN 'Wednesday'
            WHEN day_of_week(availability_date) = 4 THEN 'Thursday'
            WHEN day_of_week(availability_date) = 5 THEN 'Friday'
            WHEN day_of_week(availability_date) = 6 THEN 'Saturday'
            WHEN day_of_week(availability_date) = 7 THEN 'Sunday'
        END AS day_of_week_label

    from unnested --debug
),

joined as (
    select
        projected.hut_id,
        hut_name,
        latitude,
        longitude,
        hut_status,
        free_beds,
        total_sleeping_places,
        month,
        year,
        day,
        date(availability_date) as availability_date,
        day_of_week_label
    from projected
    left join hut_info
    on projected.hut_id = hut_info.hut_id
)

select * from joined;
