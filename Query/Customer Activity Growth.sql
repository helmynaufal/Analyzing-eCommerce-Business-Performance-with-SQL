-- Task 1: Monthly Active User
SELECT year, round(avg(total), 2) as avg_mau
FROM
   (SELECT date_part('year', o.purchase_timestamp) AS YEAR,
           date_part('month', o.purchase_timestamp) AS MONTH, 
           count(c.unique_id) AS total
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY 1, 2) AS mau
GROUP BY 1;

-- Task 2: Total New Customers
SELECT date_part('year', first_order) AS YEAR, count(1) AS new_customers
FROM
   (SELECT c.customer_id,
           min(o.purchase_timestamp) AS first_order
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY 1) AS first_order
GROUP BY 1
order by 1;

-- Task 3: Total Repeat Order
SELECT YEAR, count(1) AS repeat_order
FROM
   (SELECT date_part('year', purchase_timestamp) AS YEAR, 
           c.unique_id, 
           count(2) AS total_order
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY 1, 2
    HAVING count(2) > 1) total_order
GROUP BY 1;

-- Task 4: Average Order
SELECT YEAR, round(avg(freq_order), 2) as avg_order
FROM
   (SELECT date_part('year', purchase_timestamp) AS YEAR, 
           c.unique_id, 
           count(2) AS freq_order
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY 1, 2) frequency
GROUP BY 1;

-- Task 5: Combine all tasks
WITH mau AS
   (SELECT YEAR, round(avg(total), 2) AS avg_mau
    FROM
       (SELECT date_part('year', o.purchase_timestamp) AS YEAR,
               date_part('month', o.purchase_timestamp) AS MONTH, 
               count(c.unique_id) AS total
        FROM customers c
        JOIN orders o ON o.customer_id = c.customer_id
        GROUP BY 1, 2) AS mau
    GROUP BY 1),
     new_customer AS
   (SELECT date_part('year', first_order) AS YEAR, count(1) AS new_customers
    FROM
       (SELECT c.customer_id, 
               min(o.purchase_timestamp) AS first_order
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        GROUP BY 1) AS first_order
    GROUP BY 1
    ORDER BY 1),
     repeat_order AS
   (SELECT YEAR, count(1) AS repeat_order
    FROM
       (SELECT date_part('year', purchase_timestamp) AS YEAR, 
               c.unique_id, 
               count(2) AS total_order
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        GROUP BY 1, 2
        HAVING count(2) > 1) total_order
    GROUP BY 1),
     avg_order AS
   (SELECT YEAR, round(avg(freq_order), 2) AS avg_order
    FROM
       (SELECT date_part('year', purchase_timestamp) AS YEAR, 
               c.unique_id, 
               count(2) AS freq_order
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        GROUP BY 1, 2) frequency
    GROUP BY 1)
SELECT m.year, avg_mau, new_customers, repeat_order, avg_order
FROM mau m
JOIN new_customer nc ON m.year = nc.year
JOIN repeat_order ro ON m.year = ro.year
JOIN avg_order ao ON m.year = ao.year;