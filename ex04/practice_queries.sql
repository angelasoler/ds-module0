-- Practice Queries for Exercise 04: Items Table
-- Focus: Working with product catalog data, handling NULLs, text analysis
-- Run these after loading the items table

-- ============================================================================
-- BASIC EXPLORATION: Understanding the items table
-- ============================================================================

-- 1. Basic statistics
SELECT
    COUNT(*) as total_rows,
    COUNT(DISTINCT product_id) as unique_products,
    COUNT(DISTINCT category_id) as unique_categories,
    COUNT(DISTINCT brand) as unique_brands,
    COUNT(*) - COUNT(brand) as null_brands,
    COUNT(*) - COUNT(category_code) as null_category_codes
FROM items;

-- 2. Sample of the data
SELECT * FROM items LIMIT 20;

-- ============================================================================
-- HANDLING NULL VALUES: Important for data quality
-- ============================================================================

-- 3. Find all NULL patterns
-- Shows which columns have missing data
SELECT
    'brand' as column_name,
    COUNT(*) as null_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM items), 2) as null_percentage
FROM items
WHERE brand IS NULL OR brand = ''
UNION ALL
SELECT
    'category_code',
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM items), 2)
FROM items
WHERE category_code IS NULL OR category_code = ''
ORDER BY null_count DESC;

-- 4. Products with complete data
-- COALESCE returns first non-NULL value
SELECT
    product_id,
    COALESCE(brand, 'Unknown') as brand,
    COALESCE(category_code, 'Uncategorized') as category
FROM items
WHERE brand IS NOT NULL
  AND brand != ''
  AND category_code IS NOT NULL
  AND category_code != ''
LIMIT 20;

-- ============================================================================
-- TEXT ANALYSIS: Working with VARCHAR and TEXT fields
-- ============================================================================

-- 5. Brand name lengths
-- Understanding data characteristics
SELECT
    brand,
    LENGTH(brand) as brand_length,
    COUNT(*) as products
FROM items
WHERE brand IS NOT NULL AND brand != ''
GROUP BY brand, LENGTH(brand)
ORDER BY brand_length DESC
LIMIT 20;

-- 6. Category hierarchy analysis
-- category_code is hierarchical like: "electronics.smartphone.apple"
SELECT
    category_code,
    COUNT(*) as products,
    -- Count dots to determine hierarchy depth
    LENGTH(category_code) - LENGTH(REPLACE(category_code, '.', '')) + 1 as hierarchy_depth
FROM items
WHERE category_code IS NOT NULL AND category_code != ''
GROUP BY category_code
ORDER BY products DESC
LIMIT 20;

-- 7. Top-level categories
-- Extract first part before first dot
SELECT
    SPLIT_PART(category_code, '.', 1) as top_category,
    COUNT(*) as products,
    COUNT(DISTINCT brand) as brands_in_category
FROM items
WHERE category_code IS NOT NULL AND category_code != ''
GROUP BY top_category
ORDER BY products DESC;

-- ============================================================================
-- BRAND ANALYSIS: Understanding product distribution
-- ============================================================================

-- 8. Brands with most products
SELECT
    brand,
    COUNT(*) as product_count
FROM items
WHERE brand IS NOT NULL AND brand != ''
GROUP BY brand
ORDER BY product_count DESC
LIMIT 20;

-- 9. Brands across multiple categories
-- Multi-category brands show diversity
SELECT
    brand,
    COUNT(DISTINCT category_id) as categories,
    COUNT(*) as total_products,
    STRING_AGG(DISTINCT SPLIT_PART(category_code, '.', 1), ', ')
        as example_categories
FROM items
WHERE brand IS NOT NULL AND brand != ''
  AND category_code IS NOT NULL
GROUP BY brand
HAVING COUNT(DISTINCT category_id) > 5
ORDER BY categories DESC
LIMIT 20;

-- 10. Brand dominance in categories
-- Which brand leads each category?
WITH category_brand_counts AS (
    SELECT
        SPLIT_PART(category_code, '.', 1) as category,
        brand,
        COUNT(*) as products
    FROM items
    WHERE category_code IS NOT NULL
      AND brand IS NOT NULL
      AND brand != ''
    GROUP BY category, brand
),
ranked_brands AS (
    SELECT
        category,
        brand,
        products,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY products DESC) as rank
    FROM category_brand_counts
)
SELECT category, brand, products
FROM ranked_brands
WHERE rank = 1
ORDER BY products DESC;

-- ============================================================================
-- CATEGORY ANALYSIS: Product organization
-- ============================================================================

-- 11. Most specific categories (deepest hierarchy)
SELECT
    category_code,
    LENGTH(category_code) - LENGTH(REPLACE(category_code, '.', '')) + 1 as depth,
    COUNT(*) as products
FROM items
WHERE category_code IS NOT NULL AND category_code != ''
GROUP BY category_code, depth
HAVING depth >= 3
ORDER BY depth DESC, products DESC
LIMIT 20;

-- 12. Category coverage by hierarchy level
SELECT
    CASE
        WHEN category_code IS NULL OR category_code = '' THEN 'No category'
        WHEN LENGTH(category_code) - LENGTH(REPLACE(category_code, '.', '')) + 1 = 1 THEN 'Level 1'
        WHEN LENGTH(category_code) - LENGTH(REPLACE(category_code, '.', '')) + 1 = 2 THEN 'Level 2'
        WHEN LENGTH(category_code) - LENGTH(REPLACE(category_code, '.', '')) + 1 = 3 THEN 'Level 3'
        ELSE 'Level 4+'
    END as category_depth,
    COUNT(*) as products,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM items
GROUP BY category_depth
ORDER BY
    CASE category_depth
        WHEN 'No category' THEN 0
        WHEN 'Level 1' THEN 1
        WHEN 'Level 2' THEN 2
        WHEN 'Level 3' THEN 3
        ELSE 4
    END;

-- ============================================================================
-- DATA QUALITY: Finding issues
-- ============================================================================

-- 13. Duplicate products
-- Products appearing multiple times
SELECT
    product_id,
    COUNT(*) as occurrences,
    STRING_AGG(DISTINCT brand, ', ') as brands,
    STRING_AGG(DISTINCT category_code, ' | ') as categories
FROM items
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;

-- 14. Products with conflicting information
-- Same product_id with different brands
SELECT
    product_id,
    COUNT(DISTINCT brand) as brand_count,
    STRING_AGG(DISTINCT brand, ', ') as different_brands
FROM items
WHERE brand IS NOT NULL AND brand != ''
GROUP BY product_id
HAVING COUNT(DISTINCT brand) > 1
LIMIT 20;

-- 15. Find unusual category codes
-- Categories with weird patterns
SELECT
    category_code,
    COUNT(*) as products,
    LENGTH(category_code) as length
FROM items
WHERE category_code IS NOT NULL
  AND category_code != ''
  AND (
      LENGTH(category_code) > 100  -- Very long
      OR category_code LIKE '%  %'  -- Double spaces
      OR category_code LIKE '%..'  -- Double dots
  )
GROUP BY category_code, length
ORDER BY length DESC;

-- ============================================================================
-- JOINING WITH EVENT DATA: Combining tables
-- ============================================================================

-- 16. Join items with events (if you completed ex02)
-- Shows product details for events
-- Only works if you have data_2022_oct table!
/*
SELECT
    e.event_time,
    e.event_type,
    e.product_id,
    e.price,
    i.brand,
    i.category_code
FROM data_2022_oct e
LEFT JOIN items i ON e.product_id = i.product_id
LIMIT 20;
*/

-- 17. Find events for products without catalog info
-- Data quality check
/*
SELECT
    e.product_id,
    COUNT(*) as events,
    ROUND(AVG(e.price), 2) as avg_price
FROM data_2022_oct e
LEFT JOIN items i ON e.product_id = i.product_id
WHERE i.product_id IS NULL
GROUP BY e.product_id
ORDER BY events DESC
LIMIT 20;
*/

-- 18. Brand performance in events
-- Which brands get most interactions?
/*
SELECT
    i.brand,
    COUNT(*) as total_events,
    COUNT(DISTINCT e.user_id) as unique_users,
    ROUND(AVG(e.price), 2) as avg_price,
    SUM(CASE WHEN e.event_type = 'cart' THEN 1 ELSE 0 END) as cart_adds
FROM data_2022_oct e
JOIN items i ON e.product_id = i.product_id
WHERE i.brand IS NOT NULL AND i.brand != ''
GROUP BY i.brand
ORDER BY total_events DESC
LIMIT 20;
*/

-- ============================================================================
-- TEXT SEARCH: Finding specific products
-- ============================================================================

-- 19. Search for specific brands
-- ILIKE is case-insensitive LIKE
SELECT
    product_id,
    brand,
    category_code
FROM items
WHERE LOWER(brand) LIKE '%samsung%'
   OR LOWER(category_code) LIKE '%samsung%'
LIMIT 20;

-- 20. Products in specific category
SELECT
    product_id,
    brand,
    category_code
FROM items
WHERE category_code LIKE 'electronics%'
ORDER BY brand
LIMIT 20;

-- ============================================================================
-- ADVANCED ANALYTICS
-- ============================================================================

-- 21. Brand portfolio diversity
-- Brands with products in many different categories
WITH brand_categories AS (
    SELECT
        brand,
        SPLIT_PART(category_code, '.', 1) as top_category,
        COUNT(*) as products
    FROM items
    WHERE brand IS NOT NULL
      AND brand != ''
      AND category_code IS NOT NULL
      AND category_code != ''
    GROUP BY brand, top_category
)
SELECT
    brand,
    COUNT(DISTINCT top_category) as category_diversity,
    SUM(products) as total_products,
    STRING_AGG(top_category || '(' || products || ')', ', '
        ORDER BY products DESC) as category_breakdown
FROM brand_categories
GROUP BY brand
HAVING COUNT(DISTINCT top_category) > 3
ORDER BY category_diversity DESC, total_products DESC
LIMIT 20;

-- 22. Category-Brand matrix summary
SELECT
    SPLIT_PART(category_code, '.', 1) as category,
    COUNT(DISTINCT CASE WHEN brand IS NOT NULL AND brand != '' THEN brand END) as unique_brands,
    COUNT(*) as total_products,
    ROUND(AVG(CASE WHEN brand IS NOT NULL AND brand != '' THEN 1.0 ELSE 0.0 END) * 100, 2) as brand_coverage_pct
FROM items
WHERE category_code IS NOT NULL AND category_code != ''
GROUP BY category
ORDER BY total_products DESC;

-- ============================================================================
-- CHALLENGES: Practice on your own!
-- ============================================================================

-- Challenge 1: Find the longest category path (most dots in category_code)
-- Hint: Use LENGTH() - LENGTH(REPLACE()) to count dots

-- Challenge 2: Calculate what percentage of each brand's products are in their top category
-- Hint: Use window functions with PARTITION BY

-- Challenge 3: Find "orphan" products (in events but not in items catalog)
-- Hint: Use LEFT JOIN and check WHERE items.product_id IS NULL

-- Challenge 4: Create a category tree showing parent-child relationships
-- Hint: Use SPLIT_PART and self-join (advanced!)

-- Challenge 5: Find brands that only appear in one specific category
-- Hint: Use HAVING with COUNT(DISTINCT category_code) = 1
