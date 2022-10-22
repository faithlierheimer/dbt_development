with source as (

    select * from {{ source('default', 'stripe_payments') }}

),

renamed as (

    select
        id,
        orderid order_id,
        paymentmethod payment_method,
        status payment_status,
        amount payment_amount,
        created

    from source

)

select * from renamed
