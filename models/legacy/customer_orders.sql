
--this cte performs column renames from the orders table, filters payments down to non-failed payments only, and adds up the total payment amount per order at the latest payment date. 
WITH paid_orders as (select Orders.ID as order_id,
        Orders.USER_ID    as customer_id,
        Orders.ORDER_DATE AS order_placed_at,
            Orders.STATUS AS order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        C.FIRST_NAME    as customer_first_name,
            C.LAST_NAME as customer_last_name
    FROM default.jaffle_shop_orders as Orders
    left join (select ORDERID as order_id, max(CREATED) as payment_finalized_date, sum(AMOUNT) / 100.0 as total_amount_paid
from default.stripe_payments
where STATUS <> 'fail'
group by 1) p ON orders.ID = p.order_id
left join default.jaffle_shop_customers C on orders.USER_ID = C.ID ),

--this cte grabs all customer ids and grabs the first and most recent order date for each custoemr, and counts up the number of orders they made
customer_orders 
    as (select C.ID as customer_id
        , min(ORDER_DATE) as first_order_date
        , max(ORDER_DATE) as most_recent_order_date
        , count(ORDERS.ID) AS number_of_orders
    from default.jaffle_shop_customers C 
    left join default.jaffle_shop_orders as Orders
    on orders.USER_ID = C.ID 
    group by 1)

--this numbers order rows as transaction sequence numbers, and assigns a customer sales sequence number per customer and order id. 
-- also assigns an nsvr column as new if a first order date matches an order placed at date, otherwise it's returned. 
--it also calculates customer lifetime value
-- if also renames first orrer date as fdos.
select
    p.*,
    ROW_NUMBER() OVER (ORDER BY p.order_id) as transaction_seq,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY p.order_id) as customer_sales_seq,
    CASE WHEN c.first_order_date = p.order_placed_at
    THEN 'new'
    ELSE 'return' END as nvsr,
    x.clv_bad as customer_lifetime_value,
    c.first_order_date as fdos
    FROM paid_orders p
    left join customer_orders as c USING (customer_id)
    LEFT OUTER JOIN 
    (
        --this query calculates customer lifetime value by adding up all the payment amounts for an individual order
            select
            p.order_id,
            sum(t2.total_amount_paid) as clv_bad
        from paid_orders p
        left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
        group by 1
        order by p.order_id
    ) x on x.order_id = p.order_id
    ORDER BY order_id