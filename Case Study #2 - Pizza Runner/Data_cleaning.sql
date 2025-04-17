--Data cleaning and standarization

--***Table customer_orders***
SELECT * FROM customer_orders;

--lets take a backup of the original table in case.
CREATE TABLE customer_orders_original AS SELECT * FROM customer_orders;
SELECT * FROM customer_orders_original;

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

SELECT DISTINCT * FROM customer_orders;

--undoing below not required changes --
CREATE TABLE customer_orders_staging_practice AS SELECT * FROM customer_orders;
SELECT * FROM customer_orders_staging_practice;
--DELETE FROM customer_orders;
INSERT INTO customer_orders SELECT * FROM customer_orders_original;
SELECT * FROM customer_orders;
----------------------------------------------------------------------------------

--Not required Code** but Good for practice so not removing :)

--Before splitting the CSV columns, we need to make sure there are no duplicates (As its giving extra rows while splitting)
--Depends on the situation , either make rows unique or delete duplicates. I am choosing to delete the duplicates as it makes no sense in keeping two identical orders.
SELECT order_id, customer_id, pizza_id, exclusions, extras, order_time, COUNT(*) FROM customer_orders
GROUP BY order_id, customer_id, pizza_id, exclusions, extras, order_time HAVING COUNT(*) > 1;

--Here we need to delete one duplicate entry as we extracted from above table
WITH CTE AS (
SELECT order_id, customer_id, pizza_id, exclusions, extras, order_time,
ROW_NUMBER() OVER (PARTITION BY order_id, customer_id, pizza_id, exclusions, extras, order_time) AS row_num FROM customer_orders)
SELECT * FROM CTE;

--first i will add this column to my table by creating a staging table
CREATE TABLE customer_orders_staging AS
WITH CTE AS (
SELECT order_id, customer_id, pizza_id, exclusions, extras, order_time,
ROW_NUMBER() OVER (PARTITION BY order_id, customer_id, pizza_id, exclusions, extras, order_time) AS row_num FROM customer_orders)
SELECT * FROM CTE;

SELECT * FROM customer_orders_staging;

--I will delete the entry with rownum as 2 since its a duplicate
SELECT * FROM customer_orders_staging WHERE row_num >= 2;
DELETE FROM customer_orders_staging WHERE row_num >= 2;
SELECT * FROM customer_orders_staging;

--Update the customer_orders table as per customer_orders_staging
CREATE TABLE customer_orders_bkp as SELECT * FROM customer_orders;
SELECT * FROM  customer_orders_bkp;
SELECT * FROM customer_orders;
DELETE FROM customer_orders;
INSERT INTO customer_orders SELECT order_id, customer_id, pizza_id, exclusions, extras, order_time FROM customer_orders_staging;
SELECT * FROM customer_orders;
DROP TABLE customer_orders_staging;
DROP TABLE customer_orders_bkp;

SELECT * FROM customer_orders;

--Lets create one staging table for accomodating exclusions and extras splitted values
CREATE TABLE customer_orders_staging AS SELECT * FROM customer_orders WHERE 1=2;
SELECT * FROM customer_orders_staging;

--Convert the extras and exclusions column to integer and spilt them based on ','
INSERT INTO customer_orders_staging
WITH customer_orders_rec(i1,i2,i3,i4,i5, i6, l, c, r) AS (
      SELECT order_id, customer_id, pizza_id, exclusions, extras, order_time, 1,
             exclusions||',', '' -- Forcing a space at the end of ssvCol removes complicated checking later
        FROM customer_orders
       WHERE 1
    UNION ALL
      SELECT i1,i2,i3,i4,i5,i6,
             instr( c, ',' ) AS vLength,
             substr( c, instr( c, ',' ) + 1) AS vRemainder,
             trim( substr( c, 1, instr( c, ',' ) - 1) ) AS vSSV
        FROM customer_orders_rec
       WHERE vLength > 0
    )
  SELECT order_id, customer_id, pizza_id, r as exclusions, extras, order_time
    FROM customer_orders, customer_orders_rec
  WHERE order_id = i1 AND customer_id = i2 AND pizza_id = i3 AND exclusions = i4 AND extras = i5 AND order_time = i6 AND
  r <> ''
  ORDER BY order_id, customer_id, pizza_id;

SELECT * FROM customer_orders_staging;

--Applying similar split to 'extras' column
SELECT * FROM customer_orders_staging;
CREATE TABLE customer_orders_staging2 AS SELECT * FROM customer_orders_staging WHERE 1=2;
SELECT * FROM customer_orders_staging2;

--Convert the extras and exclusions column to integer and spilt them based on ','
INSERT INTO customer_orders_staging2
WITH customer_orders_rec(i1,i2,i3,i4,i5, i6, l, c, r) AS (
      SELECT order_id, customer_id, pizza_id, exclusions, extras, order_time, 1,
             extras||',', '' -- Forcing a space at the end of ssvCol removes complicated checking later
        FROM customer_orders_staging
       WHERE 1
    UNION ALL
      SELECT i1,i2,i3,i4,i5,i6,
             instr( c, ',' ) AS vLength,
             substr( c, instr( c, ',' ) + 1) AS vRemainder,
             trim( substr( c, 1, instr( c, ',' ) - 1) ) AS vSSV
        FROM customer_orders_rec
       WHERE vLength > 0
    )
  SELECT order_id, customer_id, pizza_id, exclusions, r as extras, order_time
    FROM customer_orders_staging, customer_orders_rec
  WHERE order_id = i1 AND customer_id = i2 AND pizza_id = i3 AND exclusions = i4 AND extras = i5 AND order_time = i6 AND
  r <> ''
  ORDER BY order_id, customer_id, pizza_id;

SELECT * FROM customer_orders_staging2;

--load the updated data from staging table to original table
CREATE TABLE customer_orders_bkp as SELECT * FROM customer_orders;
SELECT * FROM  customer_orders_bkp;
SELECT * FROM customer_orders;
DELETE FROM customer_orders;
INSERT INTO customer_orders SELECT order_id, customer_id, pizza_id, exclusions, extras, order_time FROM customer_orders_staging2;
SELECT * FROM customer_orders;
DROP TABLE customer_orders_staging;
DROP TABLE customer_orders_staging2;
DROP TABLE customer_orders_bkp;

--Finally, if required we can update the datatype of our extras and exclusion column as well (currently unable to execute in SQLite
--ALTER TABLE customer_orders MODIFY COLUMN exclusions INTEGER;  

-------------------------------------------------------------------------------------------------------------------------------------

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
