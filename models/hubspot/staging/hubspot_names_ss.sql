with snapshot as (

    select * from {{ ref('hubspot_names_snapshot') }}

),

renamed as (

    select
        hubspot_id,
        hubspot_name,
        hubspot_website,
        company_id,
        dbt_scd_id,
        dbt_updated_at,
        dbt_valid_from,
        dbt_valid_to

    from snapshot

)

select * from renamed