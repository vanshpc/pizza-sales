-- Retrieve the total number of orders placed.

SELECT count(order_id) as total_orders
from orders

-- Calculate the total revenue generated from pizza sales.

SELECT 
ROUND(SUM(order_details.quantity * pizzas.price),2) AS total_sales
from 
order_details 
JOIN 
pizzas 
ON 
pizzas.pizza_id = order_details.pizza_id


--Identify the highest-priced pizza.

SELECT top 1
pizza_types.name ,
pizzas.price
from pizza_types join  pizzas 
on
pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price desc

--Identify the most common pizza size ordered.

SELECT pizzas.size , count(order_details.order_details_id) as order_count
from pizzas join order_details 
on pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count desc

--List the top 5 most ordered pizza types 
--along with their quantities.

SELECT  TOP 5
pizza_types.name ,
SUM(order_details.quantity) as total_order
from pizza_types join pizzas
on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join 
order_details
on pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_order desc

--Join the necessary tables to 
--find the total quantity of each pizza category ordered.

SELECT 
pizza_types.category,
SUM(order_details.quantity) as total_quantity
FROM pizzas JOIN pizza_types
ON
pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details
ON
pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category

--Determine the distribution of orders by hour of the day.

SELECT 
    DATEPART(HOUR, time) AS hour,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY DATEPART(HOUR, time)
ORDER BY hour;

--Join relevant tables to 
--find the category-wise distribution of pizzas.

SELECT 
category , count(name) 
from pizza_types
GROUP BY category

--Group the orders by date and 
--calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(quantity),0)  as avg_pizza_ordered
FROM
(SELECT 
orders.date , SUM(order_details.quantity) as quantity
FROM orders join order_details
on 
orders.order_id = order_details.order_id
GROUP BY orders.date ) as order_quantity

--Determine the top 3 most ordered pizza types based on revenue.

SELECT  top 3
pizza_types.name,
SUM(order_details.quantity * pizzas.price) as revenue
FROM
pizza_types join pizzas
ON
pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON
pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue desc

--Calculate the percentage contribution of 
--each pizza type to total revenue.

SELECT  
pizza_types.name,
ROUND(SUM(order_details.quantity * pizzas.price)  /
(SELECT 
ROUND(SUM(order_details.quantity*pizzas.price),2) AS total_sales
FROM 
order_details join pizzas 
on
order_details.pizza_id = pizzas.pizza_id
)*100,2) as revenue
FROM
pizza_types join pizzas
ON
pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON
pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue desc


--Analyze the cumulative revenue generated over time.

SELECT date,
ROUND(SUM(revenue) over (order by date),2) as cum_revenue
FROM
(SELECT 
orders.date,
SUM(order_details.quantity * pizzas.price) as revenue
FROM
order_details join pizzas
ON
order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON
order_details.order_id = orders.order_id
GROUP BY orders.date) AS sales

--Determine the top 3 most ordered pizza types 
--based on revenue for each pizza category.

SELECT category, name , revenue , rank 
FROM
(SELECT category, name, revenue,
rank() over (partition by category order by revenue desc) as rank
FROM
(SELECT  
pizza_types.category,pizza_types.name ,
SUM(order_details.quantity * pizzas.price) as revenue
FROM pizza_types JOIN pizzas
ON
pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON
order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category,pizza_types.name) AS a) AS b
WHERE rank <=3

