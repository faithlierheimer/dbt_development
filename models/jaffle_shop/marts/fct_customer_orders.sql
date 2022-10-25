with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
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
  1),

paid_orders as (
    select 
        o.customer_id,
        o.order_id,
        c.first_name,
        c.last_name,
        o.order_date,
        o.order_status,
        p.total_amount_paid,
        p.payment_finalized_date
    from
        orders o
    left join total_amount_paid p on o.order_id = p.order_id
    join customers c on c.customer_id = o.customer_id
  ),
--customer orders cte redo
customer_orders as (
select
  c.customer_id,
  min(order_date) as first_order_date,
  max(order_date) as most_recent_order_date,
  count(o.order_id) as number_of_orders
from
  customers c
  left join orders o on o.customer_id = c.customer_id
group by
  1

),

---cte on lifetime value, aka "x" in the og query. 
lifetime_value as (
select
  p.order_id,
  sum(t2.total_amount_paid) as customer_lifetime_value
from
  paid_orders p
  left join paid_orders t2 on p.customer_id = t2.customer_id
  and p.order_id >= t2.order_id
group by
  1
order by
  p.order_id
),

final as (
select p.*,
    row_number() over (order by p.order_id) as transaction_seq,
    row_number() over (partition by c.customer_id order by p.order_id ) customer_sales_seq,
    case
        when c.first_order_date = p.order_date then 'new'
        else 'return'
    end nsvr,
    l.customer_lifetime_value,
    c.first_order_date
from paid_orders p 
left join customer_orders c on p.customer_id = c.customer_id
left outer join lifetime_value l on l.order_id = p.order_id 
order by order_id
)

select * from final 