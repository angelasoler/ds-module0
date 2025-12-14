-- Exercise 02: Load Data from CSV
-- Load data from data_2022_oct.csv into table

-- Method 1: Using COPY command (requires file path accessible to PostgreSQL)
-- Note: Adjust the path according to your setup
\copy data_2022_oct(event_time, event_type, product_id, price, user_id, user_session) FROM '/home/angela/desktop/documents/42/specialization/ds-picine/module0/utils/subject/customer/data_2022_oct.csv' DELIMITER ',' CSV HEADER;

-- Verify data loaded
SELECT COUNT(*) as total_rows FROM data_2022_oct;

-- Show sample data
SELECT * FROM data_2022_oct LIMIT 10;
