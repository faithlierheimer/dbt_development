with customers as (
  select
    *
  from
    {{ ref('stg_customers') }}
),

paid_orders as (
  select
    *
  from
    {{ ref('int_orders') }}
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
    left join paid_orders o on o.customer_id = c.customer_id
  group by
    1
),
---cte on lifetime value, aka "x" in the og query.

final as (
  select
    p.*,
    row_number() over (
      order by
        p.order_id
    ) as transaction_seq,
    row_number() over (
      partition by c.customer_id
      order by
        p.order_id
    ) customer_sales_seq,
    case  
      when (
      rank() over (
      partition by p.customer_id
      order by order_date, order_id
      ) = 1
    ) then 'new'
    else 'return' end as new_vs_return_customer,
    sum(total_amount_paid) over (
      partition by p.customer_id
      order by order_date
      ) as customer_lifetime_value,
    first_value(order_date) over (
      partition by p.customer_id
      order by order_date
      ) as fdos,
      {{ calculate_running_total('total_amount_paid', 'order_id')}} running_total_tablewide
  from
    paid_orders p
    left join customer_orders c on p.customer_id = c.customer_id  order by
    order_id
)
select
  *
from
  final