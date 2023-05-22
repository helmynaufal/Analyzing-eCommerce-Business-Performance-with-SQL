-- create table
CREATE TABLE geolocation
(
  zip_code INT PRIMARY KEY,
  lat VARCHAR,
  lng VARCHAR,
  city VARCHAR,
  states VARCHAR
);

-- create temporary table
CREATE TEMP TABLE tmp_geo
ON COMMIT DROP AS
SELECT *
FROM geolocation
WITH NO DATA;

-- import data to temporary table
COPY tmp_geo FROM 'D:\Kuliah\Rakamin Bootcamp\Mini Project\1. Analyzing eCommerce Business Performance with SQL\Dataset\geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;

-- remove duplicate primary key column then move data from temporary table
INSERT INTO geolocation
SELECT DISTINCT ON (zip_code) *
FROM tmp_geo
ORDER BY (zip_code);

-- create table
CREATE TABLE customers
(
  customer_id VARCHAR PRIMARY KEY,
  unique_id VARCHAR,
  zip_code INT REFERENCES geolocation,
  city VARCHAR,
  states VARCHAR
);

-- create temporary table
CREATE TEMP TABLE tmp_cust
ON COMMIT DROP AS
SELECT *
FROM customers
WITH NO DATA;

-- import data to temporary table
COPY tmp_cust(customer_id, unique_id, zip_code, city, states)
FROM 'D:\Kuliah\Rakamin Bootcamp\Mini Project\1. Analyzing eCommerce Business Performance with SQL\Dataset\customers_dataset.csv'
DELIMITER ','
CSV HEADER;

-- remove missing data from the parent table then move data from temporary table
INSERT INTO customers 
SELECT t.* FROM tmp_cust t
JOIN geolocation g ON t.zip_code=g.zip_code;
     
-- create table
CREATE TABLE orders
(
  order_id VARCHAR PRIMARY KEY,
  customer_id VARCHAR REFERENCES customers,
  status VARCHAR,
  purchase_timestamp timestamp,
  approved_at timestamp,
  delivered_carrier timestamp,
  delivered_customer timestamp,
  estimated_delivery timestamp
);

-- create temporary table
CREATE TEMP TABLE tmp_order
ON COMMIT DROP AS
SELECT *
FROM orders
WITH NO DATA;

-- import data to temporary table
COPY tmp_order(order_id, customer_id, status, purchase_timestamp, approved_at, 
            delivered_carrier, delivered_customer, estimated_delivery)
FROM 'D:\Kuliah\Rakamin Bootcamp\Mini Project\1. Analyzing eCommerce Business Performance with SQL\Dataset\orders_dataset.csv'
DELIMITER ','
CSV HEADER;

-- remove missing data from the parent table then move data from temporary table
INSERT INTO orders 
SELECT t.* FROM tmp_order t
JOIN customers c ON t.customer_id=c.customer_id;
     
-- create table
CREATE TABLE reviews
(
  review_id VARCHAR PRIMARY KEY,
  order_id VARCHAR REFERENCES orders,
  score INT,
  comment_title VARCHAR,
  comment_message VARCHAR,
  creation_date timestamp,
  answer_timestamp timestamp
);

-- create temporary table
CREATE TEMP TABLE tmp_rev
ON COMMIT DROP AS
SELECT *
FROM reviews
WITH NO DATA;

-- import data to temporary table
COPY tmp_rev(review_id, order_id, score, comment_title, comment_message, creation_date, answer_timestamp)
FROM 'D:\Kuliah\Rakamin Bootcamp\Mini Project\1. Analyzing eCommerce Business Performance with SQL\Dataset\order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;

-- remove duplicate primary key column then move data from temporary table
INSERT INTO reviews
SELECT DISTINCT ON (review_id) *
FROM tmp_rev
WHERE order_id IN (
  SELECT t.order_id FROM tmp_rev t -- remove missing data from the parent table
  JOIN orders o ON t.order_id=o.order_id)
ORDER BY (review_id);

-- create table
CREATE TABLE payments
(
  order_id VARCHAR REFERENCES orders,
  payment_sequential INT,
  payment_type VARCHAR,
  installments INT,
  payment_value NUMERIC
);

-- create temporary table
CREATE TEMP TABLE tmp_pymnt
ON COMMIT DROP AS
SELECT *
FROM payments
WITH NO DATA;

-- import data to temporary table
COPY tmp_pymnt(order_id, payment_sequential, payment_type, installments, payment_value)
FROM 'D:\Kuliah\Rakamin Bootcamp\Mini Project\1. Analyzing eCommerce Business Performance with SQL\Dataset\order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;

-- remove missing data from the parent table then move data from temporary table
INSERT INTO payments 
SELECT t.* FROM tmp_pymnt t
JOIN orders g ON t.order_id = g.order_id;

-- create table
CREATE TABLE sellers
(
  seller_id VARCHAR PRIMARY KEY,
  zip_code INT REFERENCES geolocation,
  city VARCHAR,
  states VARCHAR
);

-- create temporary table
CREATE TEMP TABLE tmp_sell
ON COMMIT DROP AS
SELECT *
FROM sellers
WITH NO DATA;

-- import data to temporary table
COPY tmp_sell(seller_id, zip_code, city, states)
FROM 'D:\Kuliah\Rakamin Bootcamp\Mini Project\1. Analyzing eCommerce Business Performance with SQL\Dataset\sellers_dataset.csv'
DELIMITER ','
CSV HEADER;

-- remove missing data from the parent table then move data from temporary table
INSERT INTO sellers 
SELECT t.* FROM tmp_sell t
JOIN geolocation g ON t.zip_code=g.zip_code;

-- create table
CREATE TABLE products
(
  ids INT,
  product_id VARCHAR PRIMARY KEY,
  category_name VARCHAR,
  name_length NUMERIC,
  desc_length NUMERIC,
  photos_qty NUMERIC,
  weight_g NUMERIC,
  length_cm NUMERIC,
  height_cm NUMERIC,
  width_cm NUMERIC
);

-- import data
COPY products(ids, product_id, category_name, name_length, desc_length, photos_qty,
              weight_g, length_cm, height_cm, width_cm)
FROM 'D:\Kuliah\Rakamin Bootcamp\Mini Project\1. Analyzing eCommerce Business Performance with SQL\Dataset\product_dataset.csv'
DELIMITER ','
CSV HEADER;

ALTER TABLE products DROP COLUMN ids; -- drop copy of index

-- create table
CREATE TABLE items
(
  order_id VARCHAR REFERENCES orders,
  item_id INT,
  product_id VARCHAR REFERENCES products,
  seller_id VARCHAR REFERENCES sellers,
  shipping_limit_date timestamp,
  price NUMERIC,
  freight_value NUMERIC
);

-- create temporary table
CREATE TEMP TABLE tmp_items
ON COMMIT DROP AS
SELECT *
FROM items
WITH NO DATA;

-- import data to temporary table
COPY tmp_items(order_id, item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
FROM 'D:\Kuliah\Rakamin Bootcamp\Mini Project\1. Analyzing eCommerce Business Performance with SQL\Dataset\order_items_dataset.csv'
DELIMITER ','
CSV HEADER;

-- remove missing data from the parent table then move data from temporary table
INSERT INTO items
SELECT t.* FROM tmp_items t
JOIN orders i ON t.order_id=i.order_id
JOIN sellers s ON t.seller_id=s.seller_id;