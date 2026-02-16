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



