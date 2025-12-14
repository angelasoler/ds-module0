-- Exercise 04: Items Table Creation
-- Table: items
-- Created from: utils/subject/item/item.csv

-- Drop table if exists (for clean recreation)
DROP TABLE IF EXISTS items;

-- Create items table with appropriate data types
-- Required: At least 3 different PostgreSQL data types
-- Note: Removed PRIMARY KEY due to duplicates in source CSV
CREATE TABLE items (
    product_id INTEGER,                  -- Type 1: INTEGER
    category_id BIGINT,                  -- Type 2: BIGINT (large number)
    category_code VARCHAR(255),          -- Type 3: VARCHAR (variable length string)
    brand VARCHAR(100)                   -- Type 3: VARCHAR (same type but different column)
);

-- Optional: Add indexes for better query performance
CREATE INDEX idx_items_product_id ON items(product_id);
CREATE INDEX idx_items_category_id ON items(category_id);
CREATE INDEX idx_items_brand ON items(brand);

-- Display table structure
\d items
