with source as (

    select * from {{ source('default', 'dbt_pnormile_usda_commodity_volume_report') }}

),

renamed as (

    select
        commodity,
        mode,
        origin,
        range_type,
        start_time,
        end_time,
        units,
        units_value,
        value value_dollars,
        file_date,
        link_name,
        time time_scraped

    from source

)

select * from renamed