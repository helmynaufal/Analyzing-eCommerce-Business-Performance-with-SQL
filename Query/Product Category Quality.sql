-- Task 1: Revenue
CREATE TABLE IF NOT EXISTS revenue AS
   (SELECT year, 
           sum(total_price) AS revenue
    FROM
       (SELECT date_part('year', purchase_timestamp) AS year, 
               o.order_id,
               sum(price + freight_value) AS total_price
        FROM orders o
        JOIN items i 
           ON o.order_id = i.order_id
        WHERE status = 'delivered'
        GROUP BY 1, 2) price
    GROUP BY 1);

-- Task 2: Total Cancel Order
CREATE TABLE IF NOT EXISTS cancel_order AS
   (SELECT date_part('year', purchase_timestamp) AS year, 
           count(status) AS cancel_order
    FROM orders
    WHERE status = 'canceled'
    GROUP BY 1);

-- Task 3: Category with highest revenue
CREATE TABLE IF NOT EXISTS best_category AS
   (SELECT year, 
           category_name as best_cat,
           cat_revenue
    FROM
       (SELECT date_part('year', purchase_timestamp) AS year, 
               category_name,
               sum(price + freight_value) AS cat_revenue, 
               rank() over(PARTITION BY date_part('year', purchase_timestamp)
                           ORDER BY sum(price + freight_value) DESC)
        FROM items i
        JOIN products p 
           ON i.product_id = p.product_id
        JOIN orders o 
           ON o.order_id = i.order_id
        WHERE status = 'delivered'
        GROUP BY 1, 2) rank_category
    WHERE rank = 1);

-- Task 4: Most canceled category
CREATE TABLE IF NOT EXISTS most_cancel_cat AS
   (SELECT year, 
           category_name as cancel_cat, 
           num_of_cancel
    FROM
       (SELECT date_part('year', purchase_timestamp) AS YEAR, 
               category_name, 
               count(status) AS num_of_cancel,
               rank() over(PARTITION BY date_part('year', purchase_timestamp)
                           ORDER BY count(status) DESC)
        FROM orders o
        JOIN items i 
           ON i.order_id = o.order_id
        JOIN products p 
           ON p.product_id = i.product_id
        WHERE status = 'canceled'
        GROUP BY 1, 2) cancel_rank
    WHERE rank = 1);
       
-- Task 5: Join table
SELECT bc.year, 
       best_cat, 
       cat_revenue, 
       revenue, 
       cancel_cat,
       num_of_cancel, 
       cancel_order
FROM best_category bc
JOIN revenue r 
   ON bc."year" = r.year
JOIN most_cancel_cat mcc 
   ON bc.year = mcc.year
JOIN cancel_order co 
   ON bc.year = co.year