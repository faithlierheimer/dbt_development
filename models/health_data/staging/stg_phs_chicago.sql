with seed as (

    select * from {{ ref('phs_chicago') }}

),

renamed as (

    select
        Facility facility,
        community,
        category,
        Address street_address

    from seed

)

select * from renamed