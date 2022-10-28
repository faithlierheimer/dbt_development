{#This table is primarily from coding along with the dbt learn on demand course on Jinja.#}
{%- set payment_methods = ['bank_transfer', 'coupon', 'credit_card', 'gift_card'] -%}
with payments as (
    select * from {{ ref('stg_payments') }}
),

pivoted as (
    select
        order_id,
        {#- Set statement lets me set a list of items to iterate over. -#}
        {% for method in payment_methods -%}
            {% if loop.last == false %}
            sum(case when payment_method = '{{ method }}' then payment_amount else 0 end) {{ method }}_amount,
            {% else %}
            sum(case when payment_method = '{{ method }}' then payment_amount else 0 end) {{ method }}_amount
            {% endif %}
        {% endfor %}
    from
        payments
    where
        payment_status = 'success'
    group by 1
)

select * from pivoted