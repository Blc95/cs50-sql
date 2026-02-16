-- Get cheapest product price pr. 100g
CREATE VIEW product_price_per_100g AS
SELECT
    p.product_id,
    p.name AS product,
    s.name AS store,
    p.is_organic,
    p.base_amount,
    po.price_dkk,
    ROUND(po.price_dkk / p.base_amount * 100, 2) AS dkk_per_100g,
    po.observed_at
FROM price_observation po
JOIN product p ON p.product_id = po.product_id
JOIN store s ON s.store_id = po.store_id;

 -- View to find product and store with higest nutritional value per dkk --
CREATE VIEW nutrition_price_per_dkk_full AS
SELECT 
    p.product_id,
    s.store_id,
    p.name AS product,
    s.name AS store,
    p.is_organic,
    po.price_dkk,
    p.base_amount,
    n.protein,
    n.fat,
    n.sugar,
    n.fiber,
    po.observed_at
FROM price_observation po
    JOIN product p ON p.product_id = po.product_id
    JOIN store s ON s.store_id = po.store_id
    JOIN nutrition_pr_100_unit n ON p.product_id = n.product_id;

-- Cheapest store for a given shopping_list
CREATE VIEW shopping_list_total_by_store AS
WITH latest_price AS (
    SELECT DISTINCT ON (po.product_id, po.store_id)
        po.product_id,
        po.store_id,
        po.price_dkk,
        po.observed_at
    FROM price_observation po
    ORDER BY
        po.product_id,
        po.store_id,
        po.observed_at DESC
),
items_from_sl AS (
    SELECT
        sli.shopping_list_id,
        sli.product_id,
        sli.quantity,
        lp.price_dkk,
        lp.store_id,
        lp.observed_at
    FROM shopping_list_item sli
    JOIN latest_price lp
        ON lp.product_id = sli.product_id
)
SELECT
    i.shopping_list_id,
    s.store_id,
    s.name AS store,
    SUM(i.quantity * i.price_dkk) AS total_price,
    MAX(i.observed_at) AS price_as_of
FROM items_from_sl i
JOIN store s
    ON s.store_id = i.store_id
GROUP BY
    i.shopping_list_id, s.store_id, s.name;