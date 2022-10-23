with source as (

    select * from {{ source('default', 'jaffle_shop_orders') }}

),

renamed as (

    select
        id order_id,
        user_id,
        order_date,
        status order_status

    from source

)

select * from renamed