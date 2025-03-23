/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT S.customer_id, SUM(M.price) as total_amount
FROM dannys_diner.menu M LEFT JOIN dannys_diner.sales S ON M.product_id = S.product_id
GROUP BY S.customer_id ORDER BY S.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT S.customer_id, COALESCE(COUNT(DISTINCT S.order_date), 0) as days
FROM dannys_diner.sales S
GROUP BY S.customer_id ORDER BY S.customer_id;

-- 3. What was the first item from the menu purchased by each customer? 
SELECT DISTINCT S.customer_id, M.product_name FROM 
dannys_diner.sales S JOIN dannys_diner.menu M ON S.product_id = M.product_id
WHERE (S.customer_id, S.order_date) =
(SELECT SS.customer_id, MIN(SS.order_date) FROM dannys_diner.sales SS
 WHERE SS.customer_id = S.customer_id
GROUP BY SS.customer_id) ;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT P.product_name, COUNT(S.customer_id) as purchase_count
FROM dannys_diner.sales S JOIN dannys_diner.menu P ON P.product_id = S.product_id
GROUP BY P.product_name 
ORDER BY purchase_count DESC
LIMIT 1;
                      
-- 5. Which item was the most popular for each customer?
WITH Rank as (SELECT S.customer_id, M.product_name,
DENSE_RANK() OVER (PARTITION BY S.customer_id ORDER BY COUNT(S.product_id) DESC) as rnk
FROM dannys_diner.sales S JOIN dannys_diner.menu M ON S.product_id = M.product_id
GROUP BY S.customer_id, S.product_id, M.product_name)

SELECT customer_id, product_name as popular_product FROM Rank WHERE rnk = 1;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT DISTINCT S.customer_id, M.product_name FROM 
dannys_diner.sales S JOIN dannys_diner.menu M ON S.product_id = M.product_id
WHERE (S.customer_id, S.order_date) =
(SELECT SS.customer_id, MIN(SS.order_date) 
FROM dannys_diner.sales SS JOIN Members M ON M.customer_id = SS.customer_id AND SS.order_date >= M.join_date
WHERE SS.customer_id = S.customer_id
GROUP BY SS.customer_id) ;

-- 7. Which item was purchased just before the customer became a member?
SELECT DISTINCT S.customer_id, M.product_name FROM 
dannys_diner.sales S JOIN dannys_diner.menu M ON S.product_id = M.product_id
WHERE (S.customer_id, S.order_date) =
(SELECT SS.customer_id, MIN(SS.order_date) 
FROM dannys_diner.sales SS JOIN Members M ON M.customer_id = SS.customer_id AND SS.order_date < M.join_date
WHERE SS.customer_id = S.customer_id
GROUP BY SS.customer_id) ;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT S.customer_id, COUNT(S.product_id) as total_items, SUM(MU.price) as amount_spent
FROM dannys_diner.sales S JOIN dannys_diner.members M ON S.customer_id = M.customer_id AND S.order_date < M.join_date
JOIN dannys_diner.menu MU ON MU.product_id = S.product_id
GROUP BY S.customer_id ORDER BY S.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT S.customer_id, 
SUM((CASE WHEN lower(M.product_name) = 'sushi' THEN 20*M.price ELSE 10*M.price END)) as points 
FROM dannys_diner.sales S JOIN dannys_diner.menu M ON M.product_id = S.product_id
GROUP BY S.customer_id ORDER BY S.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT S.customer_id, 
SUM((CASE WHEN lower(M.product_name) = 'sushi' OR S.order_date BETWEEN ME.join_date AND ME.join_date+6 THEN 20*M.price ELSE 10*M.price END)) as points 
FROM dannys_diner.sales S JOIN dannys_diner.menu M ON M.product_id = S.product_id JOIN dannys_diner.members ME ON ME.customer_id = S.customer_id
WHERE TO_CHAR(S.order_date,'MM') = '01'
GROUP BY S.customer_id ORDER BY S.customer_id;


