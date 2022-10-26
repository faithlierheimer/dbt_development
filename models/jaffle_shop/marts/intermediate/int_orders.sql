with orders as (
  select
    *
  from
    {{ ref('stg_orders') }}
),
payments as (
  select
    *
  from
    {{ ref('stg_payments') }}
),
--remake the "total_amount_paid" cte
total_amount_paid as (
  select
    order_id,
    max(created) as payment_finalized_date,
    sum(payment_amount) / 100.0 as total_amount_paid
  from
    payments
  where
    payment_status <> 'fail'
  group by
    1
),
paid_orders as (
  select
    o.customer_id,
    o.order_id,
    o.order_date,
    o.order_status,
    p.total_amount_paid,
    p.payment_finalized_date
  from
    orders o
    left join total_amount_paid p on o.order_id = p.order_id
)

select * from paid_orders