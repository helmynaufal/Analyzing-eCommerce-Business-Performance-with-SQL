-- Task 1: Most used payment type
SELECT payment_type, count(1)
FROM payments
GROUP BY 1
ORDER BY 2 DESC;

--  Task 2: Most used payment type for each year
WITH pymnt AS
   (SELECT date_part('year', purchase_timestamp) AS YEAR, payment_type, count(2) AS total_used
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY 1,2
    ORDER BY 1,3 DESC)
Select payment_type, 
       SUM (CASE
            WHEN YEAR = 2016 THEN total_used
            ELSE 0
            END) AS "2016", 
       SUM (CASE
            WHEN YEAR = 2017 THEN total_used
            ELSE 0
            END) AS "2017", 
       SUM (CASE
            WHEN YEAR = 2018 THEN total_used
            ELSE 0
            END) AS "2018"
FROM pymnt
GROUP BY 1
ORDER BY 4 DESC;