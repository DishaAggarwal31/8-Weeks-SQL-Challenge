# Case Study 1: Danny's Diner

## Solution
Full queries - 
***

### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT S.customer_id, SUM(M.price) as total_amount
FROM dannys_diner.menu M LEFT JOIN dannys_diner.sales S ON M.product_id = S.product_id
GROUP BY S.customer_id ORDER BY S.customer_id
````

#### Answer:
| Customer_id | total_amount|
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A, B and C spent $76, $74 and $36 respectivly.

***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT S.customer_id, COALESCE(COUNT(DISTINCT S.order_date), 0) as days
FROM dannys_diner.sales S
GROUP BY S.customer_id ORDER BY S.customer_id
````

#### Answer:
| Customer_id | days       |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A, B and C visited 4, 6 and 2 times respectivly.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
SELECT DISTINCT S.customer_id, M.product_name FROM 
dannys_diner.sales S JOIN dannys_diner.menu M ON S.product_id = M.product_id
WHERE (S.customer_id, S.order_date) =
(SELECT SS.customer_id, MIN(SS.order_date) FROM dannys_diner.sales SS
 WHERE SS.customer_id = S.customer_id
GROUP BY SS.customer_id)
````

#### Answer:
| Customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first order is curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT P.product_name, COUNT(S.customer_id) as purchase_count
FROM dannys_diner.sales S JOIN dannys_diner.menu P ON P.product_id = S.product_id
GROUP BY P.product_name 
ORDER BY purchase_count DESC
LIMIT 1
````



#### Answer:
| Product_name  | purchase_count | 
| ----------- | -----------       |
| ramen       | 8                 |


- Most purchased item on the menu is ramen which is 8 times.

***

### 5. Which item was the most popular for each customer?

````sql
WITH Rank as (SELECT S.customer_id, M.product_name,
DENSE_RANK() OVER (PARTITION BY S.customer_id ORDER BY COUNT(S.product_id) DESC) as rnk
FROM dannys_diner.sales S JOIN dannys_diner.menu M ON S.product_id = M.product_id
GROUP BY S.customer_id, S.product_id, M.product_name)

SELECT customer_id, product_name as popular_product FROM Rank WHERE rnk = 1
````

#### Answer:
| Customer_id | popular_product |
| ----------- | ----------   |
| A           | ramen        |
| B           | sushi        |
| B           | curry        |
| B           | ramen        |
| C           | ramen        |

- Customer A and C's favourite item is ramen while customer B savours all items on the menu. 

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
SELECT DISTINCT S.customer_id, M.product_name FROM 
dannys_diner.sales S JOIN dannys_diner.menu M ON S.product_id = M.product_id
WHERE (S.customer_id, S.order_date) =
(SELECT SS.customer_id, MIN(SS.order_date) 
FROM dannys_diner.sales SS JOIN Members M ON M.customer_id = SS.customer_id AND SS.order_date >= M.join_date
WHERE SS.customer_id = S.customer_id
GROUP BY SS.customer_id)
````


#### Answer:
| customer_id |  product_name |
| ----------- | --------------|
| A           |  curry        |
| B           |  sushi        |

After becoming a member 
- Customer A's first order was curry.
- Customer B's first order was sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
SELECT DISTINCT S.customer_id, M.product_name FROM 
dannys_diner.sales S JOIN dannys_diner.menu M ON S.product_id = M.product_id
WHERE (S.customer_id, S.order_date) =
(SELECT SS.customer_id, MIN(SS.order_date) 
FROM dannys_diner.sales SS JOIN Members M ON M.customer_id = SS.customer_id AND SS.order_date < M.join_date
WHERE SS.customer_id = S.customer_id
GROUP BY SS.customer_id)
````

#### Answer:
| customer_id |product_name |
| ----------- | ----------  |
| A           |  sushi      |
| A           |  curry      |
| B           |   sushi     |

Before becoming a member 
- Customer A’s last order was sushi and curry.
- Customer B’s last order wassushi.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
SELECT S.customer_id, COUNT(S.product_id) as total_items, SUM(MU.price) as amount_spent
FROM dannys_diner.sales S JOIN dannys_diner.members M ON S.customer_id = M.customer_id AND S.order_date < M.join_date
JOIN dannys_diner.menu MU ON MU.product_id = S.product_id
GROUP BY S.customer_id ORDER BY S.customer_id

````


#### Answer:
| customer_id |total_items | amount_spent |
| ----------- | ---------- |----------    |
| A           | 2          |  25          |
| B           | 3          |  40          |

Before becoming a member
- Customer A spent $25 on 2 items.
- Customer B spent $40 on 3 items.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
SELECT S.customer_id, 
SUM((CASE WHEN lower(M.product_name) = 'sushi' THEN 20*M.price ELSE 10*M.price END)) as points 
FROM dannys_diner.sales S JOIN dannys_diner.menu M ON M.product_id = S.product_id
GROUP BY S.customer_id ORDER BY S.customer_id
````


#### Answer:
| customer_id | points | 
| ----------- | -------|
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for customer A, B and C are 860, 940 and 360 respectivly.

***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
SELECT S.customer_id, 
SUM((CASE WHEN lower(M.product_name) = 'sushi' OR S.order_date BETWEEN ME.join_date AND ME.join_date+6 THEN 20*M.price ELSE 10*M.price END)) as points 
FROM dannys_diner.sales S JOIN dannys_diner.menu M ON M.product_id = S.product_id JOIN dannys_diner.members ME ON ME.customer_id = S.customer_id
WHERE TO_CHAR(S.order_date,'MM') = '01'
GROUP BY S.customer_id ORDER BY S.customer_id
````

#### Answer:
| Customer_id | points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 820 |

- Total points for Customer A and B are 1,370 and 820 respectivly.

***
