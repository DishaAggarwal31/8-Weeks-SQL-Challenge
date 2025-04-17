
# A. Pizza Metrics

## Solution
[Click here for all queries](https://github.com/DishaAggarwal31/8-Weeks-SQL-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/A.%20Pizza%20Metrics/A-Pizza%20Metrics%20Solution.sql)
***


### 1. How many pizzas were ordered?
`````SQL
SELECT COUNT(pizza_id) as total_pizzas_ordered FROM customer_orders;
`````

#### Answer:
| total_pizzas_ordered |
| ---------------------|
| 14                   |

### 2. How many unique customer orders were made?

If Unique as in unqiue number of orders
````sql
SELECT COUNT(DISTINCT order_id) as unique_customer_orders FROM customer_orders;
````

#### Answer:
| unique_customer_orders |
|------------------------|
| 10                     |


***Solution - If Unique as in how orders with different ingredients or components! -> This might work if asked for unique pizzas I guess
WITH unique_pizza AS
(SELECT DISTINCT pizza_id, exclusions, extras FROM customer_orders)
SELECT COUNT(*) AS unique_pizza_orders FROM unique_pizza;***

### 3. How many successful orders were delivered by each runner?
````sql
SELECT runner_id, COUNT(order_id) AS delivered_orders FROM runner_orders 
WHERE cancellation IS NULL GROUP BY runner_id;
````

#### Answer:
| runner_id | delivered_orders |
|-----------|------------------|
| 1         | 4                |
| 2         | 3                |
| 3         | 1                |


### 4. How many of each type of pizza was delivered?
`````sql
WITH ORDERED_PIZZA AS (
SELECT DISTINCT CO.pizza_id, COUNT(pizza_id) as orders 
FROM customer_orders CO LEFT JOIN runner_orders RO ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL GROUP BY CO.pizza_id ORDER BY CO.pizza_id)
SELECT PN.pizza_id, PN.pizza_name,
(CASE WHEN OP.pizza_id IS NULL THEN 0 ELSE OP.orders END) AS delivered_orders
FROM pizza_names PN LEFT JOIN ORDERED_PIZZA OP ON PN.pizza_id = OP.pizza_id;
`````

#### Answer:
| pizza_id | pizza_name  | delivered_orders |
|----------|-------------|------------------|
| 1        | Meatlovers  | 9                |
| 2        | Vegetarian  | 3                |


### 5. How many Vegetarian and Meatlovers were ordered by each customer?
`````sql
WITH ORDERED_PIZZA AS (
SELECT DISTINCT  CO.customer_id, CO.pizza_id, COUNT(pizza_id) as orders 
FROM customer_orders CO LEFT JOIN runner_orders RO ON CO.order_id = RO.order_id
GROUP BY CO.customer_id, CO.pizza_id ORDER BY CO.customer_id, CO.pizza_id)
SELECT OP.customer_id, PN.pizza_name,
(CASE WHEN OP.pizza_id IS NULL THEN 0 ELSE OP.orders END) AS no_of_orders
FROM pizza_names PN LEFT JOIN ORDERED_PIZZA OP ON PN.pizza_id = OP.pizza_id
ORDER BY OP.customer_id, OP.pizza_id;
`````

#### Answer:
| customer_id | pizza_name  | no_of_orders |
|-------------|-------------|--------------|
| 101         | Meatlovers  | 2            |
| 101         | Vegetarian  | 1            |
| 102         | Meatlovers  | 2            |
| 102         | Vegetarian  | 1            |
| 103         | Meatlovers  | 3            |
| 103         | Vegetarian  | 1            |
| 104         | Meatlovers  | 3            |
| 105         | Vegetarian  | 1            |


### 6. What was the maximum number of pizzas delivered in a single order?
`````sql
WITH ORDER_COUNT AS (
SELECT CO.order_id, COUNT(CO.pizza_id) as pizza_count
FROM customer_orders CO JOIN runner_orders RO ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL GROUP BY CO.order_id)
SELECT order_id, MAX(pizza_count) as pizzas_delivered FROM ORDER_COUNT;
`````
OR
`````sql
SELECT CO.order_id, COUNT(CO.pizza_id) as pizzas_delivered
FROM customer_orders CO JOIN runner_orders RO ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL GROUP BY CO.order_id 
ORDER BY COUNT(CO.pizza_id) DESC
LIMIT 1;
`````

#### Answer:
| order_id | pizzas_delivered |
|----------|------------------|
| 4        | 3                |


### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
`````sql
WITH ORDER_COUNTS AS (
SELECT CO.customer_id,
SUM(CASE WHEN CO.exclusions IS NULL AND CO.extras IS NULL THEN 1 ELSE 0 END) AS no_changes_delivered_orders,
COUNT(CO.order_id) AS total_delivered_orders FROM 
runner_orders RO JOIN customer_orders CO ON RO.order_id = CO.order_id
WHERE RO.cancellation IS NULL GROUP BY CO.customer_id)

SELECT customer_id,total_delivered_orders - no_changes_delivered_orders AS atleast_one_change_delivered_orders, no_changes_delivered_orders
FROM ORDER_COUNTS;
`````

#### Answer:
| customer_id | atleast_one_change_delivered_orders | no_changes_delivered_orders |
|-------------|-------------------------------------|------------------------------|
| 101         | 0                                   | 2                            |
| 102         | 0                                   | 3                            |
| 103         | 3                                   | 0                            |
| 104         | 2                                   | 1                            |
| 105         | 1                                   | 0                            |


### 8. How many pizzas were delivered that had both exclusions and extras?
`````sql
SELECT COUNT(CO.order_id) AS pizzas_delivered_with_exclusions_and_extras 
FROM runner_orders RO JOIN customer_orders CO ON RO.order_id = CO.order_id
WHERE exclusions IS NOT NULL AND extras IS NOT NULL AND RO.cancellation IS NULL;
`````

#### Answer:
| pizzas_delivered_with_exclusions_and_extras |
|---------------------------------------------|
|1                                            |

### 9. What was the total volume of pizzas ordered for each hour of the day?
`````sql
SELECT STRFTIME('%d', order_time) AS order_day, 
STRFTIME('%H', order_time) AS order_hour, 
COUNT(pizza_id) as volumne_of_pizzas_ordered FROM customer_orders
GROUP BY order_day, order_hour;
`````

#### Answer:
| order_day | order_hour | volumne_of_pizzas_ordered |
|-----------|------------|---------------------------|
| 01        | 18         | 1                         |
| 01        | 19         | 1                         |
| 02        | 23         | 2                         |
| 04        | 13         | 3                         |
| 08        | 21         | 3                         |
| 09        | 23         | 1                         |
| 10        | 11         | 1                         |
| 11        | 18         | 2                         |


OR (whichever suits the requirement)

`````sql
SELECT STRFTIME('%H', order_time) AS order_hour, 
COUNT(pizza_id) as volumne_of_pizzas_ordered FROM customer_orders
GROUP BY order_hour;
`````

#### Answer:
| order_hour | volumne_of_pizzas_ordered |
|------------|---------------------------|
| 11         | 1                         |
| 13         | 3                         |
| 18         | 3                         |
| 19         | 1                         |
| 21         | 3                         |
| 23         | 3                         |


### 10. What was the volume of orders for each day of the week?
`````sql
SELECT STRFTIME('%w', order_time) AS order_day_of_week, 
COUNT(pizza_id) as volumne_of_pizzas_ordered 
FROM customer_orders
GROUP BY order_day_of_week;
`````

#### Answer:
| order_day_of_week | volumne_of_pizzas_ordered |
|-------------------|---------------------------|
| 3                 | 5                         |
| 4                 | 3                         |
| 5                 | 1                         |
| 6                 | 5                         |


OR (If want to make results more understandable, add day name

`````sql
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
`````

#### Answer:
| order_day_of_week | volume_of_pizzas_ordered |
|-------------------|--------------------------|
| FRIDAY            | 1                        |
| SATURDAY          | 5                        |
| THURSDAY          | 3                        |
| WEDNESDAY         | 5                        |
