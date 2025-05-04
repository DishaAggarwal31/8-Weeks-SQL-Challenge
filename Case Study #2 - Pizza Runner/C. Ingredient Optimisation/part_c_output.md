## Pizza Runner Case Study – Part C: Ingredient Optimisation

### 🍕 Query 1: What are the standard ingredients for each pizza?
---

###  SQL Query

```sql
-- Recursive CTE to split comma-separated topping IDs
WITH RECURSIVE split_toppings AS (
  SELECT 
    pizza_id,
    SUBSTR(toppings || ',', 1, INSTR(toppings || ',', ',') - 1) AS topping_id,
    SUBSTR(toppings || ',', INSTR(toppings || ',', ',') + 1) AS rest
  FROM pizza_recipes

  UNION ALL

  SELECT 
    pizza_id,
    SUBSTR(rest, 1, INSTR(rest, ',') - 1),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM split_toppings
  WHERE rest <> ''
)

SELECT 
  pr.pizza_id,
  p.pizza_name,
  GROUP_CONCAT(pt.topping_name, ', ') AS ingredients
FROM split_toppings pr
JOIN pizza_toppings pt ON pr.topping_id = pt.topping_id
JOIN pizza_names p ON pr.pizza_id = p.pizza_id
GROUP BY pr.pizza_id, p.pizza_name
ORDER BY pr.pizza_id;
```
### Output

| pizza_id  | pizza_name  | ingredients                                                           |
| --------- | ----------- | --------------------------------------------------------------------- |
| 1         | Meatlovers  | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 2         | Vegetarian  | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce            |


### 🍕 Query 2: What was the most commonly added extra?


### SQL Query

```sql
WITH RECURSIVE split_extra AS (
  SELECT 
    order_id, customer_id, pizza_id,
    SUBSTR(extras || ',', 1, INSTR(extras || ',', ',') - 1) AS extras,
    SUBSTR(extras || ',', INSTR(extras || ',', ',') + 1) AS rest
  FROM customer_orders

  UNION ALL

  SELECT 
    order_id, customer_id, pizza_id,
    SUBSTR(rest, 1, INSTR(rest, ',') - 1),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM split_extra
  WHERE rest <> ''
)
SELECT pt.topping_name AS most_added_extra, COUNT(*) as no_of_pizza_ordered
FROM split_extra se JOIN pizza_toppings pt ON TRIM(se.extras) = pt.topping_id
WHERE extras IS NOT NULL GROUP BY pt.topping_name
ORDER BY no_of_pizza_ordered DESC LIMIT 1;
```

### Output
| most_added_extra   | no_of_pizza_ordered    |
| ------------------ | ---------------------- |
| Bacon              | 4                      |


### 🍕 Query 3: What was the most common exclusion?

### SQL Query

```sql
WITH RECURSIVE split_exclusion AS (
  SELECT 
    order_id, customer_id, pizza_id,
    SUBSTR(exclusions || ',', 1, INSTR(exclusions || ',', ',') - 1) AS exclusions,
    SUBSTR(exclusions || ',', INSTR(exclusions || ',', ',') + 1) AS rest
  FROM customer_orders

  UNION ALL

  SELECT 
    order_id, customer_id, pizza_id,
    SUBSTR(rest, 1, INSTR(rest, ',') - 1),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM split_exclusion
  WHERE rest <> ''
)
SELECT pt.topping_name AS most_common_exclusion, COUNT(*) as no_of_pizza_ordered
FROM split_exclusion se JOIN pizza_toppings pt ON TRIM(se.exclusions) = pt.topping_id
WHERE exclusions IS NOT NULL GROUP BY pt.topping_name
ORDER BY no_of_pizza_ordered DESC LIMIT 1;
```

### Output
| most_common\_exclusion | no\_of\_pizza\_ordered |
| ----------------------- | ---------------------- |
| Cheese                  | 4                      |

## 🍕 Query 4: Generate an order item for each record in the customer_orders table

**Question:**  
Generate an order item description for each record in the `customer_orders` table, following one of these formats:  
- Meat Lovers  
- Meat Lovers - Exclude Beef  
- Meat Lovers - Extra Bacon  
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

---

### SQL Query

```sql
-- Step 1: Normalize the order items with a unique item_id
WITH base_items AS (
  SELECT 
    ROW_NUMBER() OVER (
      ORDER BY order_id, customer_id, pizza_id, exclusions, extras
    ) AS item_id,
    order_id,
    customer_id,
    pizza_id,
    exclusions,
    extras
  FROM customer_orders
),

-- Step 2: Split exclusions
split_exclusions AS (
  SELECT 
    item_id,
    customer_id,
    order_id,
    pizza_id,
    CAST(SUBSTR(exclusions || ',', 1, INSTR(exclusions || ',', ',') - 1) AS INTEGER) AS topping_id,
    SUBSTR(exclusions || ',', INSTR(exclusions || ',', ',') + 1) AS rest
  FROM base_items
  WHERE exclusions IS NOT NULL AND exclusions != ''

  UNION ALL

  SELECT 
    item_id,
    customer_id,
    order_id,
    pizza_id,
    CAST(SUBSTR(rest, 1, INSTR(rest, ',') - 1) AS INTEGER),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM split_exclusions
  WHERE rest != ''
),

-- Step 3: Split extras (similar to exclusions)
split_extras AS (
  SELECT 
    item_id,
    customer_id,
    order_id,
    pizza_id,
    CAST(SUBSTR(extras || ',', 1, INSTR(extras || ',', ',') - 1) AS INTEGER) AS topping_id,
    SUBSTR(extras || ',', INSTR(extras || ',', ',') + 1) AS rest
  FROM base_items
  WHERE extras IS NOT NULL AND extras != ''

  UNION ALL

  SELECT 
    item_id,
    customer_id,
    order_id,
    pizza_id,
    CAST(SUBSTR(rest, 1, INSTR(rest, ',') - 1) AS INTEGER),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM split_extras
  WHERE rest != ''
),

-- Map to topping names
exclusion_names AS (
  SELECT item_id, pt.topping_name
  FROM split_exclusions se
  JOIN pizza_toppings pt ON pt.topping_id = se.topping_id
),
extra_names AS (
  SELECT item_id, pt.topping_name
  FROM split_extras se
  JOIN pizza_toppings pt ON pt.topping_id = se.topping_id
),

-- Aggregate exclusions/extras per item
exclusions_agg AS (
  SELECT item_id, GROUP_CONCAT(topping_name, ', ') AS exclude_list
  FROM exclusion_names
  GROUP BY item_id
),
extras_agg AS (
  SELECT item_id, GROUP_CONCAT(topping_name, ', ') AS extra_list
  FROM extra_names
  GROUP BY item_id
)

-- Final result
SELECT 
  bi.order_id, bi.customer_id,
  CASE WHEN pn.pizza_name = 'Meatlovers' THEN 'Meat Lovers' ELSE pn.pizza_name END ||
    CASE WHEN ea.exclude_list IS NOT NULL THEN ' - Exclude ' || ea.exclude_list ELSE '' END ||
    CASE WHEN ex.extra_list IS NOT NULL THEN ' - Extra ' || ex.extra_list ELSE '' END AS order_description
FROM base_items bi
JOIN pizza_names pn ON bi.pizza_id = pn.pizza_id
LEFT JOIN exclusions_agg ea ON bi.item_id = ea.item_id
LEFT JOIN extras_agg ex ON bi.item_id = ex.item_id
ORDER BY bi.order_id, bi.customer_id, bi.item_id;
```

### Output
| order\_id | customer\_id | order\_description                                               |
| --------- | ------------ | ---------------------------------------------------------------- |
| 1         | 101          | Meat Lovers                                                      |
| 2         | 101          | Meat Lovers                                                      |
| 3         | 102          | Meat Lovers                                                      |
| 3         | 102          | Vegetarian                                                       |
| 4         | 103          | Meat Lovers - Exclude Cheese                                     |
| 4         | 103          | Meat Lovers - Exclude Cheese                                     |
| 4         | 103          | Vegetarian - Exclude Cheese                                      |
| 5         | 104          | Meat Lovers - Extra Bacon                                        |
| 6         | 101          | Vegetarian                                                       |
| 7         | 105          | Vegetarian - Extra Bacon                                         |
| 8         | 102          | Meat Lovers                                                      |
| 9         | 103          | Meat Lovers - Exclude Cheese - Extra Bacon, Chicken              |
| 10        | 104          | Meat Lovers                                                      |
| 10        | 104          | Meat Lovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |

## 🍕 Query 5: Generate an alphabetically ordered comma-separated ingredient list for each pizza order

**Question:**  
Generate a comma-separated list of ingredients for each pizza order in the `customer_orders` table. Prefix any ingredient that appears twice with "2x". The ingredients should be alphabetically ordered.

---

###  SQL Query

```sql

WITH base_items AS (
  SELECT 
    ROW_NUMBER() OVER (
      ORDER BY order_id, customer_id, pizza_id, exclusions, extras
    ) AS item_id,
    order_id,
    customer_id,
    pizza_id,
    exclusions,
    extras
  FROM customer_orders
),

-- Step 2: Split exclusions
split_exclusions AS (
  SELECT 
    item_id,
    customer_id,
    order_id,
    pizza_id,
    CAST(SUBSTR(exclusions || ',', 1, INSTR(exclusions || ',', ',') - 1) AS INTEGER) AS topping_id,
    SUBSTR(exclusions || ',', INSTR(exclusions || ',', ',') + 1) AS rest
  FROM base_items
  WHERE exclusions IS NOT NULL AND exclusions != ''

  UNION ALL

  SELECT 
    item_id,
    customer_id,
    order_id,
    pizza_id,
    CAST(SUBSTR(rest, 1, INSTR(rest, ',') - 1) AS INTEGER),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM split_exclusions
  WHERE rest != ''
),

-- Step 3: Split extras (similar to exclusions)
split_extras AS (
  SELECT 
    item_id,
    customer_id,
    order_id,
    pizza_id,
    CAST(SUBSTR(extras || ',', 1, INSTR(extras || ',', ',') - 1) AS INTEGER) AS topping_id,
    SUBSTR(extras || ',', INSTR(extras || ',', ',') + 1) AS rest
  FROM base_items
  WHERE extras IS NOT NULL AND extras != ''

  UNION ALL

  SELECT 
    item_id,
    customer_id,
    order_id,
    pizza_id,
    CAST(SUBSTR(rest, 1, INSTR(rest, ',') - 1) AS INTEGER),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM split_extras
  WHERE rest != ''
),

-- Map to topping names
exclusion_names AS (
  SELECT item_id, pt.topping_name
  FROM split_exclusions se
  JOIN pizza_toppings pt ON pt.topping_id = se.topping_id
),

extra_names AS (
  SELECT item_id, pt.topping_name
  FROM split_extras se
  JOIN pizza_toppings pt ON pt.topping_id = se.topping_id
),

-- View for standard toppings
split_toppings AS (
  SELECT 
    pizza_id,
    SUBSTR(toppings || ',', 1, INSTR(toppings || ',', ',') - 1) AS topping_id,
    SUBSTR(toppings || ',', INSTR(toppings || ',', ',') + 1) AS rest
  FROM pizza_recipes

  UNION ALL

  SELECT 
    pizza_id,
    SUBSTR(rest, 1, INSTR(rest, ',') - 1),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM split_toppings
  WHERE rest <> ''
),

standard_toppings AS (
  SELECT 
    co.item_id,
    co.order_id,
    pr.pizza_id,
    p.pizza_name,
    pt.topping_name
  FROM split_toppings pr
  JOIN pizza_toppings pt ON pr.topping_id = pt.topping_id
  JOIN pizza_names p ON pr.pizza_id = p.pizza_id
  JOIN base_items co ON co.pizza_id = pr.pizza_id
),

merged_toppings AS (
SELECT item_id, topping_name FROM standard_toppings
UNION ALL
SELECT * FROM extra_names
),

excluded_toppings AS (
-- Tip - Dont use as it removes the duplicates which are necessary for right count!!
-- SELECT * FROM merged_toppings EXCEPT SELECT * FROM exclusion_names
SELECT mt.item_id, mt.topping_name FROM 
merged_toppings mt LEFT JOIN exclusion_names exc ON exc.item_id = mt.item_id AND mt.topping_name = exc.topping_name
WHERE exc.item_id IS NULL
),

toppings_count AS(
SELECT item_id, topping_name, COUNT(*) as count FROM excluded_toppings GROUP BY item_id, topping_name
)
-- Final result
SELECT bi.order_id, bi.customer_id,
((CASE WHEN pn.pizza_name = 'Meatlovers' THEN 'Meat Lovers' ELSE pn.pizza_name END) || ': ' ||
GROUP_CONCAT(CASE WHEN tc.count > 1 THEN tc.count || 'x' || tc.topping_name ELSE  tc.topping_name END, ', ')) as order_details
FROM base_items bi LEFT JOIN toppings_count tc ON bi.item_id = tc.item_id
JOIN pizza_names pn ON pn.pizza_id = bi.pizza_id
GROUP BY bi.item_id, bi.order_id, bi.customer_id
ORDER BY bi.order_id, bi.customer_id;
```

### Output
| order\_id | customer\_id | order\_details                                                                       |
| --------- | ------------ | ------------------------------------------------------------------------------------ |
| 1         | 101          | Meat Lovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 2         | 101          | Meat Lovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3         | 102          | Meat Lovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3         | 102          | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes               |
| 4         | 103          | Meat Lovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 4         | 103          | Meat Lovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 4         | 103          | Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                       |
| 5         | 104          | Meat Lovers: BBQ Sauce, 2xBacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 6         | 101          | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes               |
| 7         | 105          | Vegetarian: Bacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes        |
| 8         | 102          | Meat Lovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 9         | 103          | Meat Lovers: BBQ Sauce, 2xBacon, Beef, 2xChicken, Mushrooms, Pepperoni, Salami       |
| 10        | 104          | Meat Lovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 10        | 104          | Meat Lovers: 2xBacon, Beef, 2xCheese, Chicken, Pepperoni, Salami                     |


## Query 6: Total Quantity of Each Ingredient Used in Delivered Pizzas

**Question:** What is the total quantity of each ingredient used in all delivered pizzas, sorted by the most frequent first?

### SQL Query:
```sql
WITH base_items AS (
  SELECT 
    ROW_NUMBER() OVER (
      ORDER BY order_id, customer_id, pizza_id, exclusions, extras
    ) AS item_id,
    order_id,
    customer_id,
    pizza_id,
    exclusions,
    extras
  FROM customer_orders
),

-- Step 2: Split exclusions
split_exclusions AS (
  SELECT 
    item_id,
    customer_id,
    order_id,
    pizza_id,
    CAST(SUBSTR(exclusions || ',', 1, INSTR(exclusions || ',', ',') - 1) AS INTEGER) AS topping_id,
    SUBSTR(exclusions || ',', INSTR(exclusions || ',', ',') + 1) AS rest
  FROM base_items
  WHERE exclusions IS NOT NULL AND exclusions != ''

  UNION ALL

  SELECT 
    item_id,
    customer_id,
    order_id,
    pizza_id,
    CAST(SUBSTR(rest, 1, INSTR(rest, ',') - 1) AS INTEGER),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM split_exclusions
  WHERE rest != ''
),

-- Step 3: Split extras (similar to exclusions)
split_extras AS (
  SELECT 
    item_id,
    customer_id,
    order_id,
    pizza_id,
    CAST(SUBSTR(extras || ',', 1, INSTR(extras || ',', ',') - 1) AS INTEGER) AS topping_id,
    SUBSTR(extras || ',', INSTR(extras || ',', ',') + 1) AS rest
  FROM base_items
  WHERE extras IS NOT NULL AND extras != ''

  UNION ALL

  SELECT 
    item_id,
    customer_id,
    order_id,
    pizza_id,
    CAST(SUBSTR(rest, 1, INSTR(rest, ',') - 1) AS INTEGER),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM split_extras
  WHERE rest != ''
),

-- Map to topping names
exclusion_names AS (
  SELECT item_id, pt.topping_name
  FROM split_exclusions se
  JOIN pizza_toppings pt ON pt.topping_id = se.topping_id
),

extra_names AS (
  SELECT item_id, pt.topping_name
  FROM split_extras se
  JOIN pizza_toppings pt ON pt.topping_id = se.topping_id
),

-- View for standard toppings
split_toppings AS (
  SELECT 
    pizza_id,
    SUBSTR(toppings || ',', 1, INSTR(toppings || ',', ',') - 1) AS topping_id,
    SUBSTR(toppings || ',', INSTR(toppings || ',', ',') + 1) AS rest
  FROM pizza_recipes

  UNION ALL

  SELECT 
    pizza_id,
    SUBSTR(rest, 1, INSTR(rest, ',') - 1),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM split_toppings
  WHERE rest <> ''
),

standard_toppings AS (
  SELECT 
    co.item_id,
    co.order_id,
    pr.pizza_id,
    p.pizza_name,
    pt.topping_name
  FROM split_toppings pr
  JOIN pizza_toppings pt ON pr.topping_id = pt.topping_id
  JOIN pizza_names p ON pr.pizza_id = p.pizza_id
  JOIN base_items co ON co.pizza_id = pr.pizza_id
),

merged_toppings AS (
  SELECT item_id, topping_name FROM standard_toppings
  UNION ALL
  SELECT * FROM extra_names
),

excluded_toppings AS (
  SELECT mt.item_id, mt.topping_name FROM 
  merged_toppings mt LEFT JOIN exclusion_names exc ON exc.item_id = mt.item_id AND mt.topping_name = exc.topping_name
  WHERE exc.item_id IS NULL
),

toppings_count AS (
  SELECT item_id, topping_name, COUNT(*) AS count FROM excluded_toppings GROUP BY item_id, topping_name
)

-- Final query to get the total quantity of ingredients used in delivered pizzas
SELECT tc.topping_name, SUM(tc.count) AS quantity_used 
FROM base_items bi 
JOIN toppings_count tc ON bi.item_id = tc.item_id
WHERE bi.order_id IN (SELECT ro.order_id FROM runner_orders ro WHERE ro.cancellation IS NULL)
GROUP BY tc.topping_name
ORDER BY SUM(tc.count) DESC, topping_name;
```

### Output
| Topping Name  | Quantity Used |
|---------------|---------------|
| **Bacon**      | 12            |
| **Mushrooms**  | 11            |
| **Cheese**     | 10            |
| **Beef**       | 9             |
| **Chicken**    | 9             |
| **Pepperoni**  | 9             |
| **Salami**     | 9             |
| **BBQ Sauce**  | 8             |
| **Onions**     | 3             |
| **Peppers**    | 3             |
| **Tomato Sauce**| 3            |
| **Tomatoes**   | 3             |
