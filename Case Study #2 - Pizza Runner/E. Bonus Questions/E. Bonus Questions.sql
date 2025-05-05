--E. Bonus Questions

--If Danny wants to expand his range of pizzas - how would this impact the existing data design?
--Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

--If Danny wants to add a new pizza, then we will have to update the pizza_names and pizza_recipes table.

INSERT INTO pizza_names VALUES (3, 'Supreme');

SELECT * FROM pizza_names;

INSERT INTO pizza_recipes VALUES (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');

SELECT * FROM pizza_recipes;