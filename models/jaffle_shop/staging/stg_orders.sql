with source as (

    select * from {{ source('default', 'jaffle_shop_orders') }}

),

renamed as (

    select
        id order_id,
        user_id customer_id,
        order_date,
        status order_status

    from source
    {{limit_data_in_dev('order_date', 5)}}
)

select * from renamed