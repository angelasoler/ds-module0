-- Exercise 04: Load Items Data from CSV
-- Load data from item.csv into items table

-- Load data using \copy command (client-side)
-- Note: Adjust the path according to your setup
\copy items(product_id, category_id, category_code, brand) FROM '/home/angela/desktop/documents/42/specialization/ds-picine/module0/utils/subject/item/item.csv' DELIMITER ',' CSV HEADER;

-- Verify data loaded
SELECT COUNT(*) as total_rows FROM items;

-- Show sample data
SELECT * FROM items LIMIT 10;

-- Show items with brands
SELECT brand, COUNT(*) as count
FROM items
WHERE brand IS NOT NULL AND brand != ''
GROUP BY brand
ORDER BY count DESC
LIMIT 10;
