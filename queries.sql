-- INSERTING PRODUCTS INTO DB --

-- Insert food types
INSERT INTO food_type (name) 
                VALUES 
                    ('meat'),
                    ('vegetable');

-- Insert names of stores
INSERT INTO store (name) 
                VALUES 
                    ('rema1000'),
                    ('netto');

-- Insert products
INSERT INTO product (name, sku, is_organic, base_unit, base_amount, food_type_id)
                VALUES
                    ('ground_beef', 'A12345', TRUE, 'g', 400, 1),
                    ('ground_beef', 'B12345', FALSE, 'g', 500, 1),
                    ('ground_beef', 'C12345', TRUE, 'g', 500, 1),
                    ('cucumber', '12346', FALSE, 'g', 300, 2);

-- Insert product nutrition
INSERT INTO nutrition_pr_100_unit (product_id, calories, fat, protein, sugar, fiber)
VALUES
(
  (SELECT product_id FROM product WHERE sku = 'A12345'),
  290, 20, 22, 0, 0
),
(
  (SELECT product_id FROM product WHERE sku = 'B12345'),
  200, 7, 25, 0, 0
),
(
  (SELECT product_id FROM product WHERE sku = 'C12345'),
  290, 20, 22, 0, 0
),
(
  (SELECT product_id FROM product WHERE sku = '12346'),
  12, 0, 1, 1.4, 0.9
);

-- Insert price observations
INSERT INTO price_observation (product_id, store_id, price_dkk, observed_at)
VALUES
-- Ground beef 7% 400g (A12345)
(
  (SELECT p.product_id FROM product p WHERE p.sku = 'A12345'),
  (SELECT s.store_id FROM store s WHERE s.name = 'rema1000'),
  65, '2026-01-07 10:00+01'
),
(
  (SELECT p.product_id FROM product p WHERE p.sku = 'A12345'),
  (SELECT s.store_id FROM store s WHERE s.name = 'netto'),
  62, '2026-01-07 10:00+01'
),

-- Ground beef 20% 500g (B12345)
(
  (SELECT p.product_id FROM product p WHERE p.sku = 'B12345'),
  (SELECT s.store_id FROM store s WHERE s.name = 'rema1000'),
  75, '2026-01-07 10:00+01'
),
(
  (SELECT p.product_id FROM product p WHERE p.sku = 'B12345'),
  (SELECT s.store_id FROM store s WHERE s.name = 'netto'),
  72, '2026-01-07 10:00+01'
),

-- Cucumber
(
  (SELECT p.product_id FROM product p WHERE p.sku = '12346'),
  (SELECT s.store_id FROM store s WHERE s.name = 'rema1000'),
  15, '2026-01-07 10:00+01'
)
;

-- Adds many varieties of chicken breast into DB
INSERT INTO product (name, sku, is_organic, base_unit, base_amount, food_type_id)
SELECT
    'chicken_breast' AS name,
    'CHICKEN_' || g AS sku,
    (g % 2 = 0) AS is_organic,
    'g' AS base_unit,
    300 + (g % 4) * 100 AS base_amount,
    (SELECT food_type_id FROM food_type WHERE name = 'meat')
FROM generate_series(1, 30) AS g;

-- Adds nutrtional value for the checking breasts
INSERT INTO nutrition_pr_100_unit (product_id, calories, fat, protein, sugar, fiber)
SELECT
    p.product_id,
    165,
    3.6,
    31,
    0,
    0
FROM product p
WHERE p.name = 'chicken_breast'
  AND p.sku LIKE 'CHICKEN_%';

-- Adding price observations
INSERT INTO price_observation (product_id, store_id, price_dkk, observed_at)
SELECT
    p.product_id,
    s.store_id,
    ROUND((40 + random() * 20)::numeric, 2) AS price_dkk,
    '2026-01-07 10:00+01'
FROM product p
CROSS JOIN store s
WHERE p.name = 'chicken_breast';




-- Adds many varieties of tomatoes into DB
INSERT INTO product (name, sku, is_organic, base_unit, base_amount, food_type_id)
SELECT
    'tomato' AS name,
    'TOMATO_' || g AS sku,
    (g % 2 = 0) AS is_organic,
    'g' AS base_unit,
    300 + (g % 4) * 100 AS base_amount,
    (SELECT food_type_id FROM food_type WHERE name = 'vegetable')
FROM generate_series(1, 30) AS g;


-- Adds nutrtional value for the tomatoes
INSERT INTO nutrition_pr_100_unit (product_id, calories, fat, protein, sugar, fiber)
SELECT
    p.product_id,
    20,
    0.2,
    0.9,
    2.6,
    1.5
FROM product p
WHERE p.name = 'tomato'
  AND p.sku LIKE 'TOMATO_%';

-- Adding price observations for tomatoes
INSERT INTO price_observation (product_id, store_id, price_dkk, observed_at)
SELECT
    p.product_id,
    s.store_id,
    ROUND(5 + random() * 2)::numeric AS price_dkk,
    '2026-01-07 10:00+01'
FROM product p
CROSS JOIN store s
WHERE p.name = 'tomato';

INSERT INTO shopping_list (name)
VALUES
    ('Weekly groceries'),
    ('High protein week');


INSERT INTO shopping_list_item (shopping_list_id, product_id, quantity)
SELECT
    1,
    p.product_id,
    q.quantity
FROM (
    VALUES
        ('A12345', 2),       -- ground_beef
        ('CHICKEN_1', 2),    -- chicken_breast
        ('TOMATO_1', 4),     -- tomato
        ('12346', 1)         -- cucumber
) AS q(sku, quantity)
JOIN product p
    ON p.sku = q.sku;


INSERT INTO shopping_list_item (shopping_list_id, product_id, quantity)
SELECT
    2,
    p.product_id,
    q.quantity
FROM (
    VALUES
        ('B12345', 3),       -- ground_beef (different variant)
        ('CHICKEN_2', 4),    -- chicken_breast
        ('TOMATO_2', 2)      -- tomato
) AS q(sku, quantity)
JOIN product p
    ON p.sku = q.sku;


-- QUERIES -- 


-- Get cheapest product via the use of our view
-- Here, we search for ground beef, but this could easely be changed
SELECT *
FROM product_price_per_100g
WHERE product = 'ground_beef'
ORDER BY dkk_per_100g
LIMIT 1;


-- Query to find product with higest nutritional value per dkk.
-- Simply change protein to differnt nutritional value
-- It's also easy to filter pr. store by using the WHERE clause
-- OBS! This query does not consider obsered at. If we wanted the latest date, we would need to know it
-- To include the latest observed at dynamically, we would need to create a window function
SELECT
    store,
    product,
    ROUND(protein / (price_dkk / base_amount * 100), 2) AS protein_pr_dkk,
    observed_at
FROM
    nutrition_price_per_dkk_full
ORDER BY
    protein_pr_dkk DESC
LIMIT 1;


-- Another example where we filter for fiber and only in "rema1000" (danish retailer)
-- If we have a local retail type
SELECT
    store,
    product,
    ROUND(fiber / (price_dkk / base_amount * 100), 2) AS fiber_pr_dkk,
    observed_at
FROM
    nutrition_price_per_dkk_full
WHERE
    store = 'rema1000'
ORDER BY
    fiber_pr_dkk DESC
LIMIT 1;

-- Query to select cheapest store for shoppling with with id = 1
-- Just change id of shopping list to get the cheapest store
SELECT
    *
FROM shopping_list_total_by_store
WHERE
    shopping_list_id = 1
ORDER BY 
    total_price ASC
LIMIT 1;



