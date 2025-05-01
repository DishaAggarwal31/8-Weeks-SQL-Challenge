## 🍕 Pizza Runner Case Study – Part B: Runner and Customer Experience

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
```sql
SELECT CAST((julianday(registration_date) - julianday('2021-01-01')) / 7 AS INTEGER) AS week_number,
COUNT(runner_id) AS runners_signed_up
FROM runners
GROUP BY week_number
ORDER BY week_number;
```
**Output:**
| week_number | runners_signed_up |
|-------------|-------------------|
| 0           | 2                 |
| 1           | 1                 |
| 2           | 1                 |

---

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```sql
WITH arrival_times AS (
  SELECT ro.runner_id,
    ((JULIANDAY(ro.pickup_time) - JULIANDAY(co.order_time)) * 24 * 60) AS arrival_time_mins
  FROM runner_orders ro
  JOIN customer_orders co ON ro.order_id = co.order_id
  WHERE ro.cancellation IS NULL AND ro.pickup_time IS NOT NULL
)

SELECT runner_id, ROUND(AVG(arrival_time_mins), 2) AS avg_arrival_time_in_mins
FROM arrival_times
GROUP BY runner_id
ORDER BY runner_id;
```
**Output:**
| runner_id | avg_arrival_time_in_mins |
|-----------|--------------------------|
| 1         | 15.68                    |
| 2         | 23.72                    |
| 3         | 10.47                    |

---

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
```sql
-- Based on available data, the relationship cannot be clearly determined.
-- Estimated time is from order to pickup.
WITH pizza_counts AS (
  SELECT order_id, COUNT(*) AS num_pizzas
  FROM customer_orders
  GROUP BY order_id
),
order_timings AS (
  SELECT co.order_id, ro.runner_id, co.order_time, ro.pickup_time,
    ((JULIANDAY(ro.pickup_time) - JULIANDAY(co.order_time)) * 24 * 60) AS total_time_minutes
  FROM customer_orders co
  JOIN runner_orders ro ON co.order_id = ro.order_id
  WHERE ro.cancellation IS NULL
)

SELECT DISTINCT pc.num_pizzas, ROUND(ot.total_time_minutes, 2) AS prep_time_mins
FROM order_timings ot
JOIN pizza_counts pc ON ot.order_id = pc.order_id
ORDER BY ot.total_time_minutes;
```
**Output:**
| num_pizzas | prep_time_mins |
|-------------|----------------|
| 1           | 10.03          |
| 1           | 10.27          |
| 1           | 10.47          |
| 1           | 10.53          |
| 2           | 15.52          |
| 1           | 20.48          |
| 2           | 21.23          |
| 3           | 29.28          |

---

### 4. What was the average distance travelled for each customer?
```sql
WITH CTE AS (
  SELECT DISTINCT RO.order_id, CO.customer_id, RO.distance_in_km
  FROM runner_orders RO
  JOIN customer_orders CO ON RO.order_id = CO.order_id
  WHERE RO.cancellation IS NULL
)

SELECT customer_id, AVG(distance_in_km) AS avg_distance
FROM CTE
GROUP BY customer_id
ORDER BY customer_id;
```
**Output:**
| customer_id | avg_distance |
|-------------|--------------|
| 101         | 20.00        |
| 102         | 18.40        |
| 103         | 23.40        |
| 104         | 10.00        |
| 105         | 25.00        |

---

### 5. What was the difference between the longest and shortest delivery times for all orders?
```sql
SELECT
  MIN(duration_in_min) as shortest_delivery_time,
  MAX(duration_in_min) as longest_delivery_time,
  MAX(duration_in_min) - MIN(duration_in_min) as difference
FROM runner_orders
WHERE cancellation IS NULL;
```
**Output:**
| shortest_delivery_time | longest_delivery_time | difference |
|------------------------|------------------------|------------|
| 10.0                   | 40.0                   | 30         |

---

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
```sql
SELECT runner_id, order_id, ROUND(SUM(distance_in_km) / SUM(duration_in_min), 2) as average_speed
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id, order_id;
```
**Output:**
| runner_id | order_id | average_speed |
|-----------|----------|---------------|
| 1         | 1        | 0.63          |
| 1         | 2        | 0.74          |
| 1         | 3        | 0.67          |
| 1         | 10       | 1.00          |
| 2         | 4        | 0.58          |
| 2         | 7        | 1.00          |
| 2         | 8        | 1.56          |
| 3         | 5        | 0.67          |

---

### 7. What is the successful delivery percentage for each runner?
```sql
SELECT runner_id,
  ROUND((SUM(CASE WHEN cancellation IS NOT NULL THEN 0.00 ELSE 1.00 END) / COUNT(order_id)) * 100, 2) AS success_delivery_percentage
FROM runner_orders
GROUP BY runner_id;
```
**Output:**
| runner_id | success_delivery_percentage |
|-----------|-----------------------------|
| 1         | 100                         |
| 2         | 75                          |
| 3         | 50                          |

---

### 🔁 Final Note
There can be more than one way to solve a problem. Feel free to explore alternate SQL approaches and evaluate their efficiency or readability!

