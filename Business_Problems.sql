-- Basic:
-- 1.Retrieve the total number of orders placed.

select sum(quantity) as total_orders
from order_details

-- 2.Calculate the total revenue generated from pizza sales.

select round(sum(p.price*o.quantity)::numeric,2) as total_revenue
from pizzas p
right join order_details o
on p.pizza_id = o.pizza_id

-- 3.Identify the highest-priced pizza.

select *
from pizzas
where price = (select max(price) from pizzas)

-- 4.Identify the most common pizza size ordered.
select pizza_size as most_common_size_pizza
from pizzas
where pizza_id = (select pizza_id
					from order_details
					group by pizza_id
					order by count(pizza_id) desc
					limit 1 )


-- 5.List the top 5 most ordered pizza types along with their quantities.
with top_5_pizza as (select pizza_id,count(order_id) as total_orders,sum(quantity) as total_quantity
from order_details
group by pizza_id
order by count(order_id) desc
limit 5)
select p.pizza_type_id,t.total_orders,t.total_quantity
from pizzas p
join top_5_pizza t
on p.pizza_id = t.pizza_id
where p.pizza_id in (select pizza_id
					from order_details
					group by pizza_id
					order by count(pizza_id) desc
					limit 5)
group by p.pizza_type_id,t.total_orders,t.total_quantity

-- Intermediate:
-- 1.Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.pizza_category,sum(ot.quantity) as total_quantity
from pizzas p
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
join order_details ot
on p.pizza_id = ot.pizza_id
group by pt.pizza_category

-- 2.Determine the distribution of orders by hour of the day.
select o.order_date,extract(hour from o.order_time) as hours,ot.pizza_id,sum(ot.quantity) as total_quantity
from orders o
join order_details ot
on o.order_id = ot.order_id
group by ot.pizza_id,o.order_date,o.order_time
order by o.order_date,hours

-- 3.Join relevant tables to find the category-wise distribution of pizzas.
select pt.pizza_category,pt.pizza_name,sum(ot.quantity) as total_quantity
from pizzas p
right join order_details ot
on p.pizza_id = ot.pizza_id
left join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.pizza_category,pt.pizza_name
order by pt.pizza_category

-- 4.Group the orders by date and calculate the average number of pizzas ordered per day.
select o.order_date,avg(ot.quantity) as average_quantity
from order_details ot
left join orders o
on ot.order_id = o.order_id
group by o.order_date
order by o.order_date

-- 5.Determine the top 3 most ordered pizza types based on revenue.
select pt.pizza_category,round(sum(p.price*ot.quantity)::numeric,2) as revenue
from pizzas p
left join order_details ot
on ot.pizza_id = p.pizza_id
left join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.pizza_category
order by revenue desc
limit 3

-- Advanced:
-- 1.Calculate the percentage contribution of each pizza type to total revenue.
select p.pizza_type_id as pizza_type,
		round(sum(p.price*ot.quantity)::numeric*100/
		(select round(sum(p.price*o.quantity)::numeric,2) as total_revenue
			from pizzas p
			right join order_details o
			on p.pizza_id = o.pizza_id),2) as revenue_percantage
from order_details ot
left join pizzas p
on p.pizza_id = ot.pizza_id
group by p.pizza_type_id
order by revenue_percantage desc



--2. Analyze the cumulative revenue generated over time.
select 
    order_date,
    round(sum(daily_revenue) over (order by order_date)::numeric,2) as cumulative_revenue
from (
    select 
        o.order_date,
        sum(p.price * ot.quantity) as daily_revenue
    from order_details ot
    join orders o on o.order_id = ot.order_id
    left join pizzas p on ot.pizza_id = p.pizza_id
    group by o.order_date
) subquery
order by order_date;

-- 3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with top_pizza_categories as (select pt.pizza_category as category,
		p.pizza_type_id as pizza_type,
		round(sum(p.price*ot.quantity)::numeric,2) as revenue,
		rank () over (partition by pt.pizza_category order by sum(p.price*ot.quantity) desc) as rnk
		from pizzas p
		right join order_details ot
		on ot.pizza_id = p.pizza_id
		left join pizza_types pt
		on p.pizza_type_id = pt.pizza_type_id
		group by pt.pizza_category,p.pizza_type_id)
select category,pizza_type,revenue
from top_pizza_categories
where rnk<=3