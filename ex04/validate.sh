#!/bin/bash

# Exercise 04: Items Table Validation Script
# Validates that the items table was created correctly

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Database configuration
DB_USER="asoler"
DB_NAME="piscineds"
DB_PASSWORD="mysecretpassword"
DB_HOST="localhost"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Exercise 04 Validation${NC}"
echo -e "${BLUE}  Table: items${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Check if table exists
echo "Checking if table exists..."
TABLE_EXISTS=$(PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'items';" | xargs)

if [ "$TABLE_EXISTS" -eq "0" ]; then
    echo -e "${RED}✗ Table 'items' does not exist${NC}"
    echo ""
    echo "Create the table first with:"
    echo "  psql -U $DB_USER -d $DB_NAME -h $DB_HOST < items_table.sql"
    exit 1
fi

echo -e "${GREEN}✓ Table exists${NC}"
echo ""

# Show table structure
echo -e "${BLUE}Table Structure:${NC}"
PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -c "\d items"

echo ""
echo -e "${BLUE}Data Type Verification:${NC}"

# Count distinct data types
DATA_TYPE_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -t -c "
SELECT COUNT(DISTINCT data_type)
FROM information_schema.columns
WHERE table_name = 'items';
" | xargs)

echo "Distinct data types used: $DATA_TYPE_COUNT"

if [ "$DATA_TYPE_COUNT" -ge "3" ]; then
    echo -e "${GREEN}✓ Requirement met: At least 3 different data types${NC}"
else
    echo -e "${RED}✗ Requirement not met: Need at least 3 different data types (found: $DATA_TYPE_COUNT)${NC}"
fi

echo ""
echo -e "${BLUE}Data Statistics:${NC}"

# Count rows
ROW_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -t -c "SELECT COUNT(*) FROM items;" | xargs)
echo "Total rows: $ROW_COUNT"

if [ "$ROW_COUNT" -eq "0" ]; then
    echo -e "${YELLOW}⚠ Table is empty. Load data with:${NC}"
    echo "  psql -U $DB_USER -d $DB_NAME -h $DB_HOST < load_items.sql"
else
    echo -e "${GREEN}✓ Table contains data${NC}"

    # Count items with brands
    BRAND_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -t -c "SELECT COUNT(*) FROM items WHERE brand IS NOT NULL AND brand != '';" | xargs)
    echo "Items with brands: $BRAND_COUNT"

    # Count unique brands
    UNIQUE_BRANDS=$(PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -t -c "SELECT COUNT(DISTINCT brand) FROM items WHERE brand IS NOT NULL AND brand != '';" | xargs)
    echo "Unique brands: $UNIQUE_BRANDS"

    echo ""
    echo -e "${BLUE}Sample Data (first 5 rows):${NC}"
    PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -c "SELECT * FROM items LIMIT 5;"
fi

echo ""
echo -e "${BLUE}======================================${NC}"
echo -e "${GREEN}  Validation Complete!${NC}"
echo -e "${BLUE}======================================${NC}"
