--D. Pricing and Ratings

--1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT '$' || SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS total_earnings FROM customer_orders WHERE order_id IN (SELECT order_id FROM runner_orders WHERE cancellation IS NULL);

--2. What if there was an additional $1 charge for any pizza extras? --> Add cheese is $1 extra
WITH base_items AS (
  SELECT 
    order_id,
    pizza_id,
    extras
  FROM customer_orders
  WHERE order_id IN (SELECT order_id FROM runner_orders WHERE cancellation IS NULL)
),

-- Step 1: Split extras
split_extras AS (
  SELECT 
    order_id,
    pizza_id,
    CAST(SUBSTR(extras || ',', 1, INSTR(extras || ',', ',') - 1) AS INTEGER) AS topping_id,
    SUBSTR(extras || ',', INSTR(extras || ',', ',') + 1) AS rest
  FROM base_items
  WHERE extras IS NOT NULL AND extras != ''

  UNION ALL

  SELECT 
    order_id,
    pizza_id,
    CAST(SUBSTR(rest, 1, INSTR(rest, ',') - 1) AS INTEGER),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM split_extras
  WHERE rest != ''
),

-- Step 2: Count extras per order
extras_per_order AS (
  SELECT 
    order_id,
    COUNT(*) AS extra_count
  FROM split_extras
  GROUP BY order_id
),

-- Step 3: Combine base pizza cost and extra cost
earnings AS (
  SELECT 
    bi.order_id,
    CASE WHEN bi.pizza_id = 1 THEN 12 ELSE 10 END AS base_price,
    COALESCE(ep.extra_count, 0) AS extra_count,
    CASE WHEN bi.pizza_id = 1 THEN 12 ELSE 10 END + COALESCE(ep.extra_count, 0) AS total_price
  FROM base_items bi
  LEFT JOIN extras_per_order ep ON bi.order_id = ep.order_id 
  --Added this conditon for specific joining..
  AND bi.extras IS NOT NULL 
)

-- Final: Sum all prices
--SELECT * FROM extras_per_order;
SELECT '$' || SUM(total_price) AS total_earnings
FROM earnings;


--3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset 
-- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
CREATE TABLE customer_rating (
    order_id INETEGR,
    --customer_id INTEGER,
    rating INTEGER
);

--DROP TABLE customer_rating;
--DELETE FROM customer_rating;

SELECT * FROM customer_rating; --empty

INSERT INTO customer_rating
SELECT ro.order_id, /*co.customer_id, */ ABS(RANDOM() % 5) + 1 as rating FROM runner_orders ro
--customer_orders co JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL;

SELECT * FROM customer_rating; --8 records

--Although we dont need to have customer id column as well as already each order id is associated with a single customer and we can get that info from customer_orders

--4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
/*customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas*/

SELECT co.customer_id, co.order_id, ro.runner_id, cr.rating, co.order_time, ro.pickup_time, 
ROUND((julianday(pickup_time) - julianday(order_time)) * 24 * 60, 2) || ' mins'  as order_and_pickup_difference, 
duration_in_min || ' mins' AS delivery_duration, 
ROUND(ro.distance_in_km / duration_in_min, 2) || ' km/min' as avergae_speed,
COUNT(*) as total_pizzas_delivered
FROM customer_orders co JOIN runner_orders ro ON ro.order_id = co.order_id JOIN customer_rating cr ON cr.order_id = co.order_id
WHERE ro.cancellation IS NULL 
GROUP BY co.order_id
ORDER BY co.order_id, co.customer_id, ro.runner_id;

--5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
SELECT '$' || (SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) - (ro.distance_in_km * 0.30)) AS total_earnings_after_payemnt_to_runner
FROM customer_orders co JOIN runner_orders ro ON ro.order_id = co.order_id WHERE ro.cancellation IS NULL;