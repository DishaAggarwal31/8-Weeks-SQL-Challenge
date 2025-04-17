--A. Pizza Metrics

--1. How many pizzas were ordered?
SELECT COUNT(pizza_id) as total_pizzas_ordered FROM customer_orders;

--2. How many unique customer orders were made?
-- If Unique as in unqiue number of orders
SELECT COUNT(DISTINCT order_id) as unique_customer_orders FROM customer_orders;

/*
Solution - If Unique as in how orders with different ingredients or components! -> This might work if asked for unique pizzas I guess
WITH unique_pizza AS
(SELECT DISTINCT pizza_id, exclusions, extras FROM customer_orders)
SELECT COUNT(*) AS unique_pizza_orders FROM unique_pizza;
*/

--3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS delivered_orders FROM runner_orders 
WHERE cancellation IS NULL GROUP BY runner_id;

--4. How many of each type of pizza was delivered?
WITH ORDERED_PIZZA AS (
SELECT DISTINCT CO.pizza_id, COUNT(pizza_id) as orders 
FROM customer_orders CO LEFT JOIN runner_orders RO ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL GROUP BY CO.pizza_id ORDER BY CO.pizza_id)
SELECT PN.pizza_id, PN.pizza_name,
(CASE WHEN OP.pizza_id IS NULL THEN 0 ELSE OP.orders END) AS delivered_orders
FROM pizza_names PN LEFT JOIN ORDERED_PIZZA OP ON PN.pizza_id = OP.pizza_id;

--5. How many Vegetarian and Meatlovers were ordered by each customer?
WITH ORDERED_PIZZA AS (
SELECT DISTINCT  CO.customer_id, CO.pizza_id, COUNT(pizza_id) as orders 
FROM customer_orders CO LEFT JOIN runner_orders RO ON CO.order_id = RO.order_id
GROUP BY CO.customer_id, CO.pizza_id ORDER BY CO.customer_id, CO.pizza_id)
SELECT OP.customer_id, PN.pizza_name,
(CASE WHEN OP.pizza_id IS NULL THEN 0 ELSE OP.orders END) AS no_of_orders
FROM pizza_names PN LEFT JOIN ORDERED_PIZZA OP ON PN.pizza_id = OP.pizza_id
ORDER BY OP.customer_id, OP.pizza_id;

--6. What was the maximum number of pizzas delivered in a single order?
WITH ORDER_COUNT AS (
SELECT CO.order_id, COUNT(CO.pizza_id) as pizza_count
FROM customer_orders CO JOIN runner_orders RO ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL GROUP BY CO.order_id)
SELECT order_id, MAX(pizza_count) as pizzas_delivered FROM ORDER_COUNT;

/*
OR 
SELECT CO.order_id, COUNT(CO.pizza_id) as pizzas_delivered
FROM customer_orders CO JOIN runner_orders RO ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL GROUP BY CO.order_id 
ORDER BY COUNT(CO.pizza_id) DESC
LIMIT 1;
*/

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH ORDER_COUNTS AS (
SELECT CO.customer_id,
SUM(CASE WHEN CO.exclusions IS NULL AND CO.extras IS NULL THEN 1 ELSE 0 END) AS no_changes_delivered_orders,
COUNT(CO.order_id) AS total_delivered_orders FROM 
runner_orders RO JOIN customer_orders CO ON RO.order_id = CO.order_id
WHERE RO.cancellation IS NULL GROUP BY CO.customer_id)

SELECT customer_id,total_delivered_orders - no_changes_delivered_orders AS atleast_one_change_delivered_orders, no_changes_delivered_orders
FROM ORDER_COUNTS;


--8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(CO.order_id) AS pizzas_delivered_with_exclusions_and_extras 
FROM runner_orders RO JOIN customer_orders CO ON RO.order_id = CO.order_id
WHERE exclusions IS NOT NULL AND extras IS NOT NULL AND RO.cancellation IS NULL;

--9. What was the total volume of pizzas ordered for each hour of the day?
SELECT STRFTIME('%d', order_time) AS order_day, 
STRFTIME('%H', order_time) AS order_hour, 
COUNT(pizza_id) as volumne_of_pizzas_ordered FROM customer_orders
GROUP BY order_day, order_hour;

--or (whichever suits the requirement)

SELECT STRFTIME('%H', order_time) AS order_hour, 
COUNT(pizza_id) as volumne_of_pizzas_ordered FROM customer_orders
GROUP BY order_hour;

--10. What was the volume of orders for each day of the week?
SELECT STRFTIME('%w', order_time) AS order_day_of_week, 
COUNT(pizza_id) as volumne_of_pizzas_ordered 
FROM customer_orders
GROUP BY order_day_of_week;

--OR (If want to make results more understandable, add day name

SELECT 
CASE CAST(STRFTIME('%w', order_time) AS integer)
WHEN 0 THEN 'SUNDAY' 
WHEN 1 THEN 'MONDAY' 
WHEN 2 THEN 'TUESDAY'
WHEN 3 THEN 'WEDNESDAY'
WHEN 4 THEN 'THURSDAY'
WHEN 5 THEN 'FRIDAY'
ELSE 'SATURDAY' END
AS order_day_of_week, 
COUNT(pizza_id) as volume_of_pizzas_ordered 
FROM customer_orders
GROUP BY order_day_of_week;

--rerference for STRFTIME function - https://support.atlassian.com/analytics/docs/sqlite-date-and-time-functions/