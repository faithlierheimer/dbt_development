{#This table is primarily from coding along with the dbt learn on demand course on Jinja.#}

with payments as (
    select * from {{ ref('stg_payments') }}
),

pivoted as (
    select
        order_id,
        sum(case when payment_method = 'bank_transfer' then payment_amount else 0 end) bank_transfer_amount,
        sum(case when payment_method = 'coupon' then payment_amount else 0 end) coupon_amount,
        sum(case when payment_method = 'credit_card' then payment_amount else 0 end) credit_card_amount,
        sum(case when payment_method = 'gift_card' then payment_amount else 0 end) gift_card_amount
    from
        payments
    where
        payment_status = 'success'
    group by 1
)

select * from pivoted