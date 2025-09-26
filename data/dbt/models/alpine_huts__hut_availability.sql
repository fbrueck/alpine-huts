with stage_hut_availability as (
    SELECT * FROM {{ref("stage_alpine_huts__hut_availability")}}
),

hut_info as (
    SELECT hut_id, hut_name, latitude, longitude FROM {{ref("alpine_huts__hut_info")}}
),

projected as (
    select
        hut_id,
        hut_status,  
        free_beds,
        total_sleeping_places,
        availability_date,

        month(availability_date) as month,
        year(availability_date) as year,
        day_of_month(availability_date) as day,

        CASE
            WHEN day_of_week(availability_date) = 1 THEN 'Monday'
            WHEN day_of_week(availability_date) = 2 THEN 'Tuesday'
            WHEN day_of_week(availability_date) = 3 THEN 'Wednesday'
            WHEN day_of_week(availability_date) = 4 THEN 'Thursday'
            WHEN day_of_week(availability_date) = 5 THEN 'Friday'
            WHEN day_of_week(availability_date) = 6 THEN 'Saturday'
            WHEN day_of_week(availability_date) = 7 THEN 'Sunday'
        END AS day_of_week_label

    from stage_hut_availability
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
