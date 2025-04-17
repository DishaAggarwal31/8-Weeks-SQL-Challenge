--Data cleaning and standarization

--***Table customer_orders***
SELECT * FROM customer_orders;

--lets take a backup of the original table in case.
CREATE TABLE customer_orders_original AS SELECT * FROM customer_orders;
SELECT * FROM customer_orders_original;

---***Table customer_orders***

--To replace the null or blanks values in exclusions column with null
SELECT * FROM customer_orders
WHERE exclusions IS NULL OR TRIM(exclusions) == '' OR UPPER(exclusions) = 'NULL';

UPDATE customer_orders SET exclusions = NULL
WHERE exclusions IS NULL OR TRIM(exclusions) == '' OR UPPER(exclusions) = 'NULL';

SELECT * FROM customer_orders;

--To replace the null or blanks values in extras column with null
SELECT * FROM customer_orders
WHERE extras IS NULL OR TRIM(extras) == '' OR UPPER(extras) = 'NULL';

UPDATE customer_orders SET extras = NULL
WHERE extras IS NULL OR TRIM(extras) == '' OR UPPER(extras) = 'NULL';

---***Table runner_orders***
SELECT * FROM runner_orders;

--lets take a backup of the original table in case.
CREATE TABLE runner_orders_original AS SELECT * FROM runner_orders;
SELECT * FROM runner_orders_original;

--Clean distance column - replace null with 0 and convert them all in one unit and format
SELECT * FROM runner_orders WHERE cancellation IS NULL OR TRIM(cancellation) == '' OR UPPER(cancellation) = 'NULL';
UPDATE runner_orders
SET cancellation = NULL WHERE cancellation IS NULL OR TRIM(cancellation) == '' OR UPPER(cancellation) = 'NULL';

SELECT * FROM runner_orders;

SELECT * FROM runner_orders WHERE distance IS NULL OR TRIM(distance) == '' OR UPPER(distance) = 'NULL';
UPDATE runner_orders
SET distance = 0 WHERE distance IS NULL OR TRIM(distance) == '' OR UPPER(distance) = 'NULL';

SELECT * FROM runner_orders;

SELECT * FROM runner_orders WHERE duration IS NULL OR TRIM(duration) == '' OR UPPER(duration) = 'NULL';
UPDATE runner_orders
SET duration = 0 WHERE duration IS NULL OR TRIM(duration) == '' OR UPPER(duration) = 'NULL';

SELECT * FROM runner_orders;

--Remove unnecessary characters from distance and duration
SELECT distance, TRIM(SUBSTR(TRIM(distance),0, LENGTH(distance)-1)) FROM runner_orders WHERE lower(distance) LIKE '%km%';

UPDATE runner_orders
SET distance = TRIM(SUBSTR(TRIM(distance),0, LENGTH(distance)-1)) WHERE lower(distance) LIKE '%km%';

--Can do if required ****
--SELECT distance, distance || ' km' FROM runner_orders;
--UPDATE runner_orders SET distance = distance || ' km';

ALTER TABLE runner_orders RENAME distance TO distance_in_km;
SELECT distance_in_km, CAST(distance_in_km AS REAL) FROM runner_orders;
UPDATE runner_orders SET distance_in_km = CAST(distance_in_km AS REAL);

SELECT * FROM runner_orders;

SELECT duration, CAST(duration AS REAL)
FROM runner_orders;

UPDATE runner_orders
SET duration = CAST(duration AS REAL);

ALTER TABLE runner_orders RENAME duration TO duration_in_min;

SELECT * FROM runner_orders;

--***Other tables - As of now, no changes required***
SELECT * FROM runners;
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;
