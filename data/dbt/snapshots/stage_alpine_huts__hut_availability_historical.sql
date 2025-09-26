{% snapshot stage_alpine_huts__hut_availability_historical %}
    {{ config(
        check_cols=['hut_status',  'free_beds', 'total_sleeping_places'], 
        unique_key='hut_availability_id', 
        strategy='check',
        table_type='iceberg',
    ) }}
    select * from {{ ref('stage_alpine_huts__hut_availability') }}
{% endsnapshot %}
