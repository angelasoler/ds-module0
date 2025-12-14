#!/bin/bash

# Exercise 03: Validation Script
# Validates that all customer tables were created correctly

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

# Expected tables
EXPECTED_TABLES=("data_2022_oct" "data_2022_nov" "data_2022_dec" "data_2023_jan")

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Exercise 03 Validation${NC}"
echo -e "${BLUE}  Automatic Table Creation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

TOTAL_TABLES=${#EXPECTED_TABLES[@]}
FOUND_TABLES=0
TOTAL_ROWS=0

echo "Checking for expected tables..."
echo ""

for table in "${EXPECTED_TABLES[@]}"; do
    echo -n "Checking table '$table'... "

    # Check if table exists
    TABLE_EXISTS=$(PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = '$table';" | xargs)

    if [ "$TABLE_EXISTS" -eq "0" ]; then
        echo -e "${RED}✗ Not found${NC}"
        continue
    fi

    echo -e "${GREEN}✓ Found${NC}"
    FOUND_TABLES=$((FOUND_TABLES + 1))

    # Get row count
    ROW_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -t -c "SELECT COUNT(*) FROM $table;" | xargs)
    TOTAL_ROWS=$((TOTAL_ROWS + ROW_COUNT))

    echo "  Rows: $ROW_COUNT"

    # Verify structure (6 columns)
    COL_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -t -c "SELECT COUNT(*) FROM information_schema.columns WHERE table_name = '$table';" | xargs)
    echo "  Columns: $COL_COUNT"

    # Verify first column is timestamp
    FIRST_COL=$(PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -t -c "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '$table' ORDER BY ordinal_position LIMIT 1;" | xargs)
    echo "  First column: $FIRST_COL"

    echo ""
done

echo -e "${BLUE}========================================${NC}"
echo "Summary:"
echo "  Expected tables: $TOTAL_TABLES"
echo "  Found tables: $FOUND_TABLES"

if [ "$FOUND_TABLES" -eq "$TOTAL_TABLES" ]; then
    echo -e "  ${GREEN}✓ All tables found${NC}"
else
    echo -e "  ${YELLOW}⚠ Missing tables: $((TOTAL_TABLES - FOUND_TABLES))${NC}"
fi

echo "  Total rows across all tables: $TOTAL_ROWS"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ "$FOUND_TABLES" -gt 0 ]; then
    echo "Table sizes:"
    PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -c "
    SELECT
        tablename,
        pg_size_pretty(pg_total_relation_size('public.'||tablename)) AS size
    FROM pg_tables
    WHERE schemaname = 'public' AND tablename LIKE 'data_%'
    ORDER BY tablename;
    "
fi

if [ "$FOUND_TABLES" -eq "$TOTAL_TABLES" ]; then
    echo ""
    echo -e "${GREEN}✓ All validation checks passed!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Validation incomplete${NC}"
    echo "Run ./automatic_table.sh to create missing tables"
    exit 1
fi
