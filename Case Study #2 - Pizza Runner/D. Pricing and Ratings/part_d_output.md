# 🍕 Pizza Runner Case Study  
## Part D: Pricing and Ratings

---

### 1. How much money has Pizza Runner made so far if there are no delivery fees?

Assumption:
- Meat Lovers pizza: `$12`
- Vegetarian pizza: `$10`
- No additional charges for exclusions or extras.

```sql
SELECT '$' || SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS total_earnings 
FROM customer_orders 
WHERE order_id IN (
  SELECT order_id FROM runner_orders WHERE cancellation IS NULL
);
```

### Output
| total_earnings |
|----------------|
| $138           |


### 2. What if there was an additional $1 charge for any pizza extras?

Assumption:
This query adds $1 for every extra topping (e.g., extra cheese).

```sql
WITH base_items AS (
  SELECT order_id, pizza_id, extras
  FROM customer_orders
  WHERE order_id IN (SELECT order_id FROM runner_orders WHERE cancellation IS NULL)
),

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

extras_per_order AS (
  SELECT order_id, COUNT(*) AS extra_count
  FROM split_extras
  GROUP BY order_id
),

earnings AS (
  SELECT 
    bi.order_id,
    CASE WHEN bi.pizza_id = 1 THEN 12 ELSE 10 END AS base_price,
    COALESCE(ep.extra_count, 0) AS extra_count,
    CASE WHEN bi.pizza_id = 1 THEN 12 ELSE 10 END + COALESCE(ep.extra_count, 0) AS total_price
  FROM base_items bi
  LEFT JOIN extras_per_order ep 
    ON bi.order_id = ep.order_id 
    AND bi.extras IS NOT NULL 
)

SELECT '$' || SUM(total_price) AS total_earnings
FROM earnings;
```

### Output
| total_earnings |
|----------------|
| $142           |


### 3. How would you design a customer rating table and insert ratings from 1 to 5?
```sql
CREATE TABLE customer_rating (
    order_id INTEGER,
    rating INTEGER
);

-- Insert random ratings for successful orders
INSERT INTO customer_rating
SELECT ro.order_id, ABS(RANDOM() % 5) + 1 AS rating
FROM runner_orders ro
WHERE ro.cancellation IS NULL;

SELECT * FROM customer_rating;
```

### Output
| order_id | rating |
|----------|--------|
| 1        | 5      |
| 2        | 3      |
| 3        | 5      |
| 4        | 4      |
| 5        | 1      |
| 7        | 2      |
| 8        | 5      |
| 10       | 2      |


### 4. Join all the information together for successful deliveries
Required Columns:
* customer_id
* order_id
* runner_id
* rating
* order_time
* pickup_time
* Time between order and pickup
* Delivery duration
* Average speed
* Total number of pizzas

```sql
SELECT 
  co.customer_id, 
  co.order_id, 
  ro.runner_id, 
  cr.rating, 
  co.order_time, 
  ro.pickup_time, 
  ROUND((julianday(pickup_time) - julianday(order_time)) * 24 * 60, 2) || ' mins' AS order_and_pickup_difference, 
  duration_in_min || ' mins' AS delivery_duration, 
  ROUND(ro.distance_in_km / duration_in_min, 2) || ' km/min' AS average_speed,
  COUNT(*) AS total_pizzas_delivered
FROM customer_orders co 
JOIN runner_orders ro ON ro.order_id = co.order_id 
JOIN customer_rating cr ON cr.order_id = co.order_id
WHERE ro.cancellation IS NULL 
GROUP BY co.order_id
ORDER BY co.order_id, co.customer_id, ro.runner_id;
```

### Output
| customer_id | order_id | runner_id | rating | order_time           | pickup_time          | order_and_pickup_difference | delivery_duration | avergae_speed  | total_pizzas_delivered |
|-------------|----------|-----------|--------|----------------------|----------------------|----------------------------|-------------------|-----------------|------------------------|
| 101         | 1        | 1         | 5      | 2020-01-01 18:05:02  | 2020-01-01 18:15:34  | 10.53 mins                | 32.0 mins         | 0.63 km/min     | 1                      |
| 101         | 2        | 1         | 3      | 2020-01-01 19:00:52  | 2020-01-01 19:10:54  | 10.03 mins                | 27.0 mins         | 0.74 km/min     | 1                      |
| 102         | 3        | 1         | 5      | 2020-01-02 23:51:23  | 2020-01-03 00:12:37  | 21.23 mins                | 20.0 mins         | 0.67 km/min     | 2                      |
| 103         | 4        | 2         | 4      | 2020-01-04 13:23:46  | 2020-01-04 13:53:03  | 29.28 mins                | 40.0 mins         | 0.58 km/min     | 3                      |
| 104         | 5        | 3         | 1      | 2020-01-08 21:00:29  | 2020-01-08 21:10:57  | 10.47 mins                | 15.0 mins         | 0.67 km/min     | 1                      |
| 105         | 7        | 2         | 2      | 2020-01-08 21:20:29  | 2020-01-08 21:30:45  | 10.27 mins                | 25.0 mins         | 1.0 km/min      | 1                      |
| 102         | 8        | 2         | 5      | 2020-01-09 23:54:33  | 2020-01-10 00:15:02  | 20.48 mins                | 15.0 mins         | 1.56 km/min     | 1                      |
| 104         | 10       | 1         | 2      | 2020-01-11 18:34:49  | 2020-01-11 18:50:20  | 15.52 mins                | 10.0 mins         | 1.0 km/min      | 2                      |


### 5. How much money does Pizza Runner have left after paying runners $0.30/km?
```sql
SELECT 
  '$' || (SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) - (ro.distance_in_km * 0.30)) AS total_earnings_after_payment_to_runner
FROM customer_orders co 
JOIN runner_orders ro ON ro.order_id = co.order_id 
WHERE ro.cancellation IS NULL;
```

### Output
| total_earnings_after_payment_to_runner |
|----------------------------------------|
| $132.0                                 |
