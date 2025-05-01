--B. Runner and Customer Experience

--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT CAST((julianday(registration_date) - julianday('2021-01-01')) / 7 AS INTEGER) AS week_number,
COUNT(runner_id) AS runners_signed_up
FROM runners GROUP BY week_number ORDER BY week_number;
-- Note - The julianday() function returns the Julian day - the fractional number of days since noon in Greenwich on November 24, 4714 B.C. (Proleptic Gregorian calendar).

--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH arrival_times AS (
SELECT ro.runner_id,
((JULIANDAY(ro.pickup_time) - JULIANDAY(co.order_time)) * 24 * 60) AS arrival_time_mins
FROM runner_orders ro JOIN customer_orders co ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL AND ro.pickup_time IS NOT NULL
)

SELECT runner_id, ROUND(AVG(arrival_time_mins), 2) AS avg_arrival_time_in_mins
FROM arrival_times GROUP BY runner_id
ORDER BY runner_id;


--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
--Ans- No I dont think so, as we have order time and runner's pickup time only and so if pizza could be ready at the pickup time or before that, there is not clarity on that based on given data! Based on the order date and pickup dates only, we can have an estimated time of pizza preparation
WITH pizza_counts AS (
SELECT order_id, COUNT(*) AS num_pizzas FROM customer_orders GROUP BY order_id),
order_timings AS (
SELECT co.order_id, ro.runner_id, co.order_time, ro.pickup_time, ((JULIANDAY(ro.pickup_time) - JULIANDAY(co.order_time)) * 24 * 60) AS total_time_minutes
FROM customer_orders co JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL)

SELECT DISTINCT pc.num_pizzas, ROUND(ot.total_time_minutes, 2) AS prep_time_mins--, AVG(ot.total_time_minutes) AS avg_minutes
FROM order_timings ot JOIN pizza_counts pc ON ot.order_id = pc.order_id-- GROUP BY pc.num_pizzas;
ORDER BY ot.total_time_minutes;

--4. What was the average distance travelled for each customer?
WITH CTE AS (
SELECT DISTINCT RO.order_id, CO.customer_id, RO.distance_in_km
FROM runner_orders RO JOIN customer_orders CO ON RO.order_id = CO.order_id
WHERE RO.cancellation IS NULL ORDER BY CO.customer_id)

SELECT customer_id, 
--SUM(distance_in_km) / COUNT(order_id) AS avg_distance
AVG(distance_in_km) AS avg_distance
FROM CTE GROUP BY customer_id ORDER BY customer_id;

--5. What was the difference between the longest and shortest delivery times for all orders?
SELECT min(duration_in_min) as shortest_delivery_time, max(duration_in_min) as longest_delivery_time, max(duration_in_min) - min(duration_in_min) as difference
FROM runner_orders WHERE cancellation IS NULL;

--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
--avergae speed = total distance / total time
SELECT runner_id, order_id, ROUND(SUM(distance_in_km) / SUM(duration_in_min), 2) as average_speed
--SUM(distance_in_km) as total_distance, SUM(duration_in_min) as total_time
FROM runner_orders WHERE cancellation IS NULL 
GROUP BY runner_id, order_id;

--7. What is the successful delivery percentage for each runner?
--successful delivery percentage = Number of successful (non cancelled) deliveries / Number of total delivery orders * 100
SELECT runner_id, ROUND((SUM(CASE WHEN cancellation IS NOT NULL THEN 0.00 ELSE 1.00 END) / COUNT(order_id)) * 100, 2) AS success_delivery_percentage
FROM runner_orders GROUP BY runner_id; 
