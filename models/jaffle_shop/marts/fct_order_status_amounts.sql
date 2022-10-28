{%-set order_statuses = ['completed', 'placed', 'shipped', 'return_pending', 'returned'] -%}
with customer_orders as (
    select * from {{ ref('fct_customer_orders') }}
),

{#- In this model I want to use Jinja to add up how much money is lost vs. gained from different order statuses. And whether new or returned customers spend more in each category. -#}
new_vs_returned_order_amounts as (
select
    new_vs_return_customer,
    {% for order_status in order_statuses -%}
    {% if loop.last == false %}
        sum(case when order_status = '{{ order_status }}' then total_amount_paid else 0 end) {{ order_status }}_amount,
    {% else %}
        sum(case when order_status = '{{ order_status }}' then total_amount_paid else 0 end) {{ order_status }}_amount
    {% endif %}
    {% endfor -%}
from 
    customer_orders
group by 
    new_vs_return_customer)

select * from new_vs_returned_order_amounts
