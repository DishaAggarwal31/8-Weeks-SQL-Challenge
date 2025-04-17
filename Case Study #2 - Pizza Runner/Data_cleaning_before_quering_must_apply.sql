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