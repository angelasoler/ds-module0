#!/bin/bash

# Exercise 03: Automatic Table Creation
# Automatically creates tables for all CSV files in the customer folder

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Database configuration - Load from .env file
ENV_FILE="../.env"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}✗ .env file not found: $ENV_FILE${NC}"
    echo -e "${YELLOW}Please create .env from .env.example${NC}"
    exit 1
fi

# Source environment variables from .env
# Filter out comments and export all variables
export $(cat "$ENV_FILE" | grep -v '^#' | grep -v '^$' | xargs)

# Use environment variables
DB_USER="${POSTGRES_USER}"
DB_NAME="${POSTGRES_DB}"
DB_PASSWORD="${POSTGRES_PASSWORD}"
DB_HOST="${DB_HOST:-localhost}"

# Validate required variables
if [ -z "$DB_USER" ] || [ -z "$DB_NAME" ] || [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}✗ Missing required environment variables${NC}"
    echo -e "${YELLOW}Required: POSTGRES_USER, POSTGRES_DB, POSTGRES_PASSWORD${NC}"
    echo -e "${YELLOW}Check your .env file has all values filled in${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Database config loaded from .env${NC}"
echo -e "${BLUE}  Database: $DB_NAME${NC}"
echo -e "${BLUE}  User: $DB_USER${NC}"
echo -e "${BLUE}  Host: $DB_HOST${NC}"
echo ""

# Path to customer CSV files
CSV_DIR="../utils/customer"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Exercise 03: Automatic Table Creation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if CSV directory exists
if [ ! -d "$CSV_DIR" ]; then
    echo -e "${RED}✗ Customer directory not found: $CSV_DIR${NC}"
    exit 1
fi

# Count CSV files
CSV_COUNT=$(ls -1 "$CSV_DIR"/*.csv 2>/dev/null | wc -l)

if [ "$CSV_COUNT" -eq 0 ]; then
    echo -e "${RED}✗ No CSV files found in $CSV_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}Found $CSV_COUNT CSV files${NC}"
echo ""

# Process each CSV file
for csv_file in "$CSV_DIR"/*.csv; do
    # Extract filename without path and extension
    filename=$(basename "$csv_file" .csv)

    echo -e "${BLUE}Processing: $filename${NC}"
    echo "  CSV file: $csv_file"

    # Create table SQL
    cat > /tmp/create_${filename}.sql << EOF
-- Auto-generated table creation for $filename
DROP TABLE IF EXISTS $filename;

CREATE TABLE $filename (
    event_time TIMESTAMP WITH TIME ZONE,
    event_type TEXT,
    product_id INTEGER,
    price NUMERIC(10,2),
    user_id BIGINT,
    user_session UUID
);

CREATE INDEX idx_${filename}_event_time ON $filename(event_time);
CREATE INDEX idx_${filename}_user_id ON $filename(user_id);
CREATE INDEX idx_${filename}_product_id ON $filename(product_id);
EOF

    # Create table
    echo "  Creating table..."
    if PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -f /tmp/create_${filename}.sql > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓ Table created${NC}"
    else
        echo -e "  ${RED}✗ Failed to create table${NC}"
        continue
    fi

    # Load data
    echo "  Loading data..."
    ABSOLUTE_PATH=$(realpath "$csv_file")

    if PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -c "\copy $filename(event_time, event_type, product_id, price, user_id, user_session) FROM '$ABSOLUTE_PATH' DELIMITER ',' CSV HEADER;" > /dev/null 2>&1; then
        # Count rows
        ROW_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -t -c "SELECT COUNT(*) FROM $filename;" | xargs)
        echo -e "  ${GREEN}✓ Data loaded: $ROW_COUNT rows${NC}"
    else
        echo -e "  ${RED}✗ Failed to load data${NC}"
    fi

    # Clean up temp file
    rm -f /tmp/create_${filename}.sql

    echo ""
done

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  All tables created successfully!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Show summary
echo "Summary of created tables:"
PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -c "
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public' AND tablename LIKE 'data_%'
ORDER BY tablename;
"
