-- Schema for food types such as meat, veteables, fruits etc.
CREATE TABLE IF NOT EXISTS food_type (
    food_type_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    name TEXT NOT NULL UNIQUE
);

-- Schema for stores. Used to compare prices of different strores
CREATE TABLE IF NOT EXISTS store (
    store_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    name TEXT NOT NULL UNIQUE
);


-- Schema for products with id, SKU, if the product is organic, base unit (e.g. kg or liters),
-- base amount (how much does the product weigh)
CREATE TABLE IF NOT EXISTS product (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    sku TEXT NOT NULL UNIQUE,
    is_organic BOOLEAN NOT NULL,
    base_unit TEXT NOT NULL CHECK (base_unit IN ('g', 'ml')),
    base_amount INTEGER NOT NULL CHECK (base_amount > 0),
    food_type_id INTEGER NOT NULL,
    FOREIGN KEY (food_type_id) REFERENCES food_type(food_type_id)
);

-- Schema for nutritional facts of the products. Used to compare different products and compare
-- price to nutritional density
CREATE TABLE IF NOT EXISTS nutrition_pr_100_unit (
    product_id INTEGER,
    calories NUMERIC(6,2),
    fat NUMERIC (6,2),
    protein NUMERIC(6,2),
    sugar NUMERIC (6,2),
    fiber NUMERIC(6,2),
    PRIMARY KEY (product_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE
);

-- Table for price observations. Used to tie everything together and enable comparisions
CREATE TABLE IF NOT EXISTS price_observation (
    price_observation_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    product_id INTEGER NOT NULL,
    store_id INTEGER NOT NULL,
    price_dkk NUMERIC(6,2) NOT NULL,
    observed_at TIMESTAMPTZ NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id)
);

-- Schema for shopping lists (e.g., "Weekly groceries", "Meal prep")
CREATE TABLE IF NOT EXISTS shopping_list (
    shopping_list_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    name TEXT NOT NULL
);

-- Bridge table: which products are in which shopping list, and how many
CREATE TABLE IF NOT EXISTS shopping_list_item (
    shopping_list_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),

    PRIMARY KEY (shopping_list_id, product_id),

    FOREIGN KEY (shopping_list_id)
        REFERENCES shopping_list(shopping_list_id)
        ON DELETE CASCADE,

    FOREIGN KEY (product_id)
        REFERENCES product(product_id)
);

-- VIEWS --

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


-- Index for joins when selecting products by food type
CREATE INDEX IF NOT EXISTS idx_product_food_type_id
    ON product (food_type_id);

-- Index for joins and lookups of price observations by product
CREATE INDEX IF NOT EXISTS idx_price_observation_product_id
    ON price_observation (product_id);

-- Index for queries that filter or aggregate price observations by store
CREATE INDEX IF NOT EXISTS idx_price_observation_store_id
    ON price_observation (store_id);

--  Index for  joins between shopping list items and products
CREATE INDEX IF NOT EXISTS idx_shopping_list_item_product_id
    ON shopping_list_item (product_id);

-- Index for retrieval of all items belonging to a specific shopping list
CREATE INDEX IF NOT EXISTS idx_shopping_list_item_shopping_list_id
    ON shopping_list_item (shopping_list_id);


