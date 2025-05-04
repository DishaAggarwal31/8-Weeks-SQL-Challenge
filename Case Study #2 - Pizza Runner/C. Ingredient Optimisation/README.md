# 🍕 Ingredient Optimisation – Danny’s Diner SQL Case Study

This section of the case study focuses on understanding the ingredient usage patterns at Danny’s Diner, including standard pizza compositions, popular customizations, and total ingredient consumption. These insights help optimize inventory, reduce waste, and personalize the customer experience.

---

## 📌 Objectives

1. Identify the **standard ingredients** used in each type of pizza.
2. Analyze **most commonly added extras** to pizzas.
3. Determine the **most commonly excluded ingredients**.
4. Generate a **detailed order item description** for each customer order, including exclusions and extras.
5. Produce an **alphabetically ordered ingredient list** per order, with quantity indications.
6. Calculate the **total quantity of each ingredient** used in all delivered pizzas.

---

## ❓ Ingredient Optimisation Questions

**1. What are the standard ingredients for each pizza?**  
Return a table with `pizza_id`, `pizza_name`, and a comma-separated list of `standard_ingredients`.

**2. What is the most commonly added extra?**  
Determine which extra topping is most frequently added across all orders.

**3. What is the most common exclusion?**  
Find out which ingredient is excluded most frequently in customer orders.

**4. Generate an order item description for each record in the `customer_orders` table.**  
Format:  
`<pizza name> - Exclude <ingredient_1>, <ingredient_2> - Extra <extra_1>, <extra_2>`

**5. Generate an alphabetically ordered ingredient list for each customer order.**  
Show full list of ingredients used in each order, including extras and excluding removed items, and repeat ingredients if used multiple times.

**6. What is the total quantity of each ingredient used in all delivered pizzas?**  
Calculate how many times each ingredient was actually used, considering standard ingredients, exclusions, and extras.

---

## 🧩 SQL Concepts Used

- **Recursive Common Table Expressions (CTEs)** for splitting comma-separated values.
- **Window Functions** (`ROW_NUMBER`) to uniquely identify items.
- **String manipulation**: `SUBSTR`, `INSTR`, `GROUP_CONCAT`, `TRIM`, `REPLACE`.
- **CASE statements** for conditional formatting.
- **JOINs** to connect toppings with pizza recipes and orders.
- **Aggregation**: `COUNT`, `GROUP BY`.

---

## 🗃️ Data Sources

- `pizza_names`: Contains pizza names and `pizza_id`.
- `pizza_recipes`: Maps each `pizza_id` to a list of `topping_ids`.
- `pizza_toppings`: Provides `topping_name` for each `topping_id`.
- `customer_orders`: Each row contains `order_id`, `pizza_id`, with optional `exclusions` and `extras`.

---

## 📊 Sample Outputs

- **Standard Ingredients**  
  `Meat Lovers → Bacon, Cheese, Chicken, Pepperoni`

- **Order Description**  
  `Meat Lovers - Exclude Cheese - Extra Mushroom, Salami`

- **Alphabetical Ingredient List**  
  `Bacon, Chicken, Mushroom, Pepperoni, Salami`

- **Top Extra Topping**  
  `Mushroom (added 5 times)`

---
