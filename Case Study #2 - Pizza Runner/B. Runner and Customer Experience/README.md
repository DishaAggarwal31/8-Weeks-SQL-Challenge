# 🍕 Pizza Runner - Part B: Runner and Customer Experience

This folder contains SQL solutions for **Part B** of the [Pizza Runner case study](https://8weeksqlchallenge.com/case-study-2/) from the 8-Week SQL Challenge by Danny Ma.

The focus of this part is to explore and analyze the delivery side of operations — understanding how runners and customer experience metrics are performing based on available data.

---

## 📊 Dataset Overview

In this section, we dive into operational insights involving:

- Runner registrations  
- Delivery timings and behavior  
- Preparation vs. order size relationships  
- Distance and speed trends  
- Delivery success metrics

---

## 🔍 Key Questions Answered

1. **How many runners signed up for each 1 week period?**  
   Analyze registration trends weekly starting from `2021-01-01`.

2. **What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**  
   Use timestamps to estimate average arrival efficiency.

3. **Is there any relationship between the number of pizzas and how long the order takes to prepare?**  
   Investigate if order size impacts preparation time.

4. **What was the average distance travelled for each customer?**  
   Aggregate delivery distances per customer.

5. **What was the difference between the longest and shortest delivery times for all orders?**  
   Examine consistency and variability in delivery performance.

6. **What was the average speed for each runner for each delivery and do you notice any trend for these values?**  
   Analyze delivery speed and identify patterns.

7. **What is the successful delivery percentage for each runner?**  
   Evaluate runner performance based on success rate.

---

## 🛠️ Tools Used

- SQLite
- Common Table Expressions (CTEs)
- Aggregations, window functions, date/time calculations

---

## ▶️ Getting Started

1. Clone the repository or navigate to this folder.
2. Use any SQL IDE or platform (e.g., PostgreSQL, SQLite with minor modifications).
3. This folder contains:
   - `part_b_runner_experience.sql`: All SQL queries written for this part.
   - `part_b_runner_experience.md`: Each question with the corresponding query and output table for reference.
4. Run queries from the SQL file or explore the Markdown file for a documented walkthrough of the solutions and results.

---

## 📝 Notes

- The analysis assumes clean and transformed datasets.
- Calculations are based on approximations due to limited timestamp granularity.

---

Feel free to fork this and explore alternate methods or optimizations!
