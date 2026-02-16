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



