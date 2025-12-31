-- Practice Queries for Exercise 02
-- Run these after loading data to explore and learn SQL
-- Each query demonstrates different SQL concepts and techniques

-- ============================================================================
-- BASIC QUERIES: Understanding your data
-- ============================================================================

-- 1. Count total events
-- Shows how many rows are in the table
SELECT COUNT(*) as total_events FROM data_2022_oct;

-- 2. See the date range of your data
-- Useful to understand your dataset's time span
SELECT
    MIN(event_time) as first_event,
    MAX(event_time) as last_event,
    MAX(event_time) - MIN(event_time) as time_span
FROM data_2022_oct;

-- 3. What types of events exist?
-- GROUP BY counts occurrences of each unique value
-- OVER() creates a window for calculating percentages
SELECT
    event_type,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM data_2022_oct
GROUP BY event_type
ORDER BY count DESC;

-- ============================================================================
-- FILTERING: Finding specific data with WHERE
-- ============================================================================

-- 4. Find expensive products (price > $1000)
SELECT
    product_id,
    price,
    event_type,
    event_time
FROM data_2022_oct
WHERE price > 1000
ORDER BY price DESC
LIMIT 20;

-- 5. Events from a specific day
-- DATE_TRUNC rounds timestamps down to start of day
SELECT
    DATE_TRUNC('day', event_time) as day,
    COUNT(*) as events
FROM data_2022_oct
WHERE DATE_TRUNC('day', event_time) = '2022-10-01'
GROUP BY day;

-- 6. Multiple conditions with AND
-- Find cart events for expensive products
SELECT *
FROM data_2022_oct
WHERE event_type = 'cart'
  AND price > 500
ORDER BY price DESC
LIMIT 10;

-- ============================================================================
-- AGGREGATION: Summarizing data
-- ============================================================================

-- 7. Daily event counts
-- Shows traffic patterns over time
SELECT
    DATE_TRUNC('day', event_time) as day,
    COUNT(*) as events,
    COUNT(DISTINCT user_id) as unique_users,
    ROUND(AVG(price), 2) as avg_price
FROM data_2022_oct
GROUP BY day
ORDER BY day;

-- 8. Most popular products
-- Products with most interactions
SELECT
    product_id,
    COUNT(*) as interactions,
    COUNT(DISTINCT user_id) as unique_users,
    ROUND(AVG(price), 2) as avg_price,
    MAX(price) as max_price,
    MIN(price) as min_price
FROM data_2022_oct
GROUP BY product_id
ORDER BY interactions DESC
LIMIT 20;

-- 9. User behavior patterns
-- How many events per user on average?
SELECT
    ROUND(AVG(events_per_user), 2) as avg_events,
    MAX(events_per_user) as max_events,
    MIN(events_per_user) as min_events
FROM (
    SELECT user_id, COUNT(*) as events_per_user
    FROM data_2022_oct
    GROUP BY user_id
) user_stats;

-- ============================================================================
-- TIME ANALYSIS: Understanding patterns over time
-- ============================================================================

-- 10. Busiest hours of the day
-- EXTRACT pulls out hour from timestamp
SELECT
    EXTRACT(HOUR FROM event_time) as hour,
    COUNT(*) as events
FROM data_2022_oct
GROUP BY hour
ORDER BY hour;

-- 11. Weekday vs Weekend traffic
-- DOW = Day Of Week: 0=Sunday, 1=Monday, ... 6=Saturday
SELECT
    CASE
        WHEN EXTRACT(DOW FROM event_time) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END as day_type,
    COUNT(*) as events,
    ROUND(AVG(price), 2) as avg_price
FROM data_2022_oct
GROUP BY day_type;

-- 12. Week-over-week growth
-- Compare each week to the previous using LAG window function
SELECT
    DATE_TRUNC('week', event_time) as week,
    COUNT(*) as events,
    LAG(COUNT(*)) OVER (ORDER BY DATE_TRUNC('week', event_time)) as previous_week,
    COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY DATE_TRUNC('week', event_time)) as change
FROM data_2022_oct
GROUP BY week
ORDER BY week;

-- ============================================================================
-- PRICE ANALYSIS: Understanding pricing patterns
-- ============================================================================

-- 13. Price distribution by buckets
-- Categorize products into price ranges
SELECT
    CASE
        WHEN price < 50 THEN 'Under $50'
        WHEN price < 100 THEN '$50-$100'
        WHEN price < 500 THEN '$100-$500'
        WHEN price < 1000 THEN '$500-$1000'
        ELSE 'Over $1000'
    END as price_range,
    COUNT(*) as events,
    ROUND(AVG(price), 2) as avg_price
FROM data_2022_oct
GROUP BY price_range
ORDER BY MIN(price);

-- 14. Most expensive products added to cart
SELECT
    product_id,
    price,
    COUNT(*) as times_added_to_cart,
    COUNT(DISTINCT user_id) as unique_users
FROM data_2022_oct
WHERE event_type = 'cart'
GROUP BY product_id, price
ORDER BY price DESC
LIMIT 20;

-- ============================================================================
-- USER SESSION ANALYSIS: Understanding user journeys
-- ============================================================================

-- 15. Session length (events per session)
SELECT
    user_session,
    COUNT(*) as events_in_session,
    MIN(event_time) as session_start,
    MAX(event_time) as session_end,
    MAX(event_time) - MIN(event_time) as session_duration
FROM data_2022_oct
GROUP BY user_session
ORDER BY events_in_session DESC
LIMIT 20;

-- 16. Cart abandonment analysis
-- Sessions with cart events but also removals
SELECT
    user_session,
    COUNT(CASE WHEN event_type = 'cart' THEN 1 END) as cart_adds,
    COUNT(CASE WHEN event_type = 'view' THEN 1 END) as views,
    COUNT(CASE WHEN event_type = 'remove_from_cart' THEN 1 END) as removes
FROM data_2022_oct
GROUP BY user_session
HAVING COUNT(CASE WHEN event_type = 'cart' THEN 1 END) > 0
   AND COUNT(CASE WHEN event_type = 'remove_from_cart' THEN 1 END) > 0
LIMIT 20;

-- ============================================================================
-- ADVANCED: Combining multiple concepts
-- ============================================================================

-- 17. Top users by total potential purchase value
-- Sum of prices for cart events per user
SELECT
    user_id,
    COUNT(*) as total_events,
    COUNT(CASE WHEN event_type = 'cart' THEN 1 END) as cart_events,
    ROUND(SUM(CASE WHEN event_type = 'cart' THEN price ELSE 0 END), 2) as potential_revenue
FROM data_2022_oct
GROUP BY user_id
ORDER BY potential_revenue DESC
LIMIT 20;

-- 18. Hourly patterns by event type
-- See when different activities peak
SELECT
    EXTRACT(HOUR FROM event_time) as hour,
    event_type,
    COUNT(*) as events
FROM data_2022_oct
GROUP BY hour, event_type
ORDER BY hour, event_type;

-- ============================================================================
-- PERFORMANCE: Understanding indexes
-- ============================================================================

-- 19. Compare query performance with and without indexes
-- See execution plan (should use index on user_id)
EXPLAIN ANALYZE
SELECT * FROM data_2022_oct
WHERE user_id = 1515915625;

-- This query should be fast because we have:
-- CREATE INDEX idx_data_2022_oct_user_id ON data_2022_oct(user_id);

-- 20. Query that would benefit from a new index
-- Try this and see it's slower (might do sequential scan)
EXPLAIN ANALYZE
SELECT * FROM data_2022_oct
WHERE event_type = 'cart' AND price > 1000;

-- To speed it up, you could create:
-- CREATE INDEX idx_data_2022_oct_event_type_price
-- ON data_2022_oct(event_type, price);

-- ============================================================================
-- CHALLENGES: Try to solve these yourself!
-- ============================================================================

-- Challenge 1: Find the average time between events for each user
-- Hint: Use LAG() window function to get previous event_time, then subtract

-- Challenge 2: Identify users who viewed a product but never added to cart
-- Hint: Use NOT EXISTS or LEFT JOIN with WHERE event_type = 'cart' IS NULL

-- Challenge 3: Find products that were added to cart and later removed in same session
-- Hint: Self-join on product_id and user_session with different event_types

-- Challenge 4: Calculate conversion rate (cart adds / views) per product
-- Hint: Use CASE statements inside COUNT() and divide

-- Challenge 5: Find the busiest hour for each day of the week
-- Hint: Use ROW_NUMBER() window function with PARTITION BY day of week
