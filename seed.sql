INSERT INTO food_type (name) 
                VALUES 
                    ('meat'),
                    ('vegetable')
                ON CONFLICT (name) DO NOTHING;

INSERT INTO store (name) 
                VALUES 
                    ('rema1000'),
                    ('netto');

INSERT INTO product (name, sku, is_organic, base_unit, base_amount, food_type_id)
                VALUES
                    ('ground_beef', 'A12345', TRUE, 'g', 400, (SELECT food_type_id FROM food_type WHERE name='meat')),
                    ('ground_beef', 'B12345', FALSE, 'g', 500, (SELECT food_type_id FROM food_type WHERE name='meat')),
                    ('ground_beef', 'C12345', TRUE, 'g', 500, (SELECT food_type_id FROM food_type WHERE name='meat')),
                    ('cucumber', '12346', FALSE, 'g', 300, (SELECT food_type_id FROM food_type WHERE name='vegetable'));



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
    (SELECT shopping_list_id FROM shopping_list WHERE name = 'Weekly groceries'),
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
    (SELECT shopping_list_id FROM shopping_list WHERE name = 'High protein week'),
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
