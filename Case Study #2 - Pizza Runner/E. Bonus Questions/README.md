## 🍕 E. Bonus Questions

### 1. If Danny wants to expand his range of pizzas - how would this impact the existing data design?

Adding new types of pizzas to the Pizza Runner menu requires changes to the schema that stores pizza metadata and their associated recipes. Specifically, the following tables will be affected:

- `pizza_names`: This table must include a new entry with a unique `pizza_id` and the name of the new pizza.
- `pizza_recipes`: This table must include a new entry that associates the new `pizza_id` with a comma-separated list of `topping_id`s that make up the recipe.

This change aligns with the current normalized schema and supports scalability by allowing easy addition of new pizza types.

---

### 2. Write an `INSERT` statement to demonstrate what would happen if a new **Supreme pizza** with all the toppings was added to the Pizza Runner menu?

```sql
-- Add a new pizza type to the pizza_names table
INSERT INTO pizza_names VALUES (3, 'Supreme');

-- Verify the new entry
SELECT * FROM pizza_names;

-- Add the corresponding recipe with all available toppings
INSERT INTO pizza_recipes VALUES (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');

-- Verify the new recipe entry
SELECT * FROM pizza_recipes;
```

### pizza_names:
| pizza_id | pizza_name  |
|----------|-------------|
| 1        | Meatlovers  |
| 2        | Vegetarian  |
| 3        | Supreme     |

### pizza_recipes:
| pizza_id | toppings                                |
|----------|------------------------------------------|
| 1        | 1, 2, 3, 4, 5, 6, 8, 10                   |
| 2        | 4, 6, 7, 9, 11, 12                        |
| 3        | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12     |
