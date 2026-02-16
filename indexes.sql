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


