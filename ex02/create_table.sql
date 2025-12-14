-- Exercise 02: First Table - Manual Creation
-- Table: data_2022_oct
-- Created from: utils/subject/customer/data_2022_oct.csv

-- Drop table if exists (for clean recreation)
DROP TABLE IF EXISTS data_2022_oct;

-- Create table with appropriate data types
-- Required: At least 6 different PostgreSQL data types
-- Required: TIMESTAMP as first column
CREATE TABLE data_2022_oct (
    event_time TIMESTAMP WITH TIME ZONE,  -- Type 1: TIMESTAMP WITH TIME ZONE (first column, required)
    event_type TEXT,                      -- Type 2: TEXT
    product_id INTEGER,                   -- Type 3: INTEGER
    price NUMERIC(10,2),                  -- Type 4: NUMERIC (decimal with precision)
    user_id BIGINT,                       -- Type 5: BIGINT
    user_session UUID                     -- Type 6: UUID
);

-- Optional: Add indexes for better query performance
CREATE INDEX idx_data_2022_oct_event_time ON data_2022_oct(event_time);
CREATE INDEX idx_data_2022_oct_user_id ON data_2022_oct(user_id);
CREATE INDEX idx_data_2022_oct_product_id ON data_2022_oct(product_id);

-- Display table structure
\d data_2022_oct
