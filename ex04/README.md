# Exercise 04: Items Table

This exercise demonstrates creating the `items` table from the item catalog CSV file.

## Objective

Create a table named `items` from the CSV file:
- **Source:** `utils/subject/item/item.csv`
- **Table name:** `items`
- **Columns:** Must match CSV headers exactly
- **Data types:** Use at least 3 different PostgreSQL data types

## Table Structure

The table uses **3 different PostgreSQL data types**:

1. `INTEGER` - product_id (PRIMARY KEY)
2. `BIGINT` - category_id
3. `VARCHAR` - category_code, brand

**Columns:**
- `product_id` - Product identifier
- `category_id` - Category identifier
- `category_code` - Category code (may be empty)
- `brand` - Brand name (may be empty)

**Note:** The source CSV contains duplicate product_ids, so no PRIMARY KEY constraint is used.

## Files

- **items_table.sql** - Creates the items table structure
- **load_items.sql** - Loads data from CSV file
- **validate.sh** - Validates table in PostgreSQL
- **test_items_pgadmin.py** - Selenium test for pgAdmin visualization
- **requirements.txt** - Python dependencies
- **README.md** - This file

## Usage

### Step 1: Create table and load data

```bash
# Create the table
psql -U asoler -d piscineds -h localhost < items_table.sql

# Load data from CSV
psql -U asoler -d piscineds -h localhost < load_items.sql
```

### Step 2: Validate in PostgreSQL

```bash
./validate.sh
```

### Step 3: Verify in pgAdmin (Selenium)

```bash
# Install dependencies
pip install -r requirements.txt

# Run Selenium test
python test_items_pgadmin.py
```

## Selenium Test for pgAdmin

The `test_items_pgadmin.py` script:
- Logs into pgAdmin automatically
- Verifies the database `piscineds` is visible
- Checks for table `items` in the interface
- Takes screenshots at each step for evaluation
- Provides manual navigation instructions
- Runs with browser visible for demonstration

**Screenshots generated:**
- `ex04_step1_dashboard.png` - pgAdmin dashboard
- `ex04_step2_table_check.png` - Table verification
- `ex04_step3_browser_tree.png` - Browser tree view
- `ex04_step4_final.png` - Final state
- `ex04_error.png` - Error state (if any)

## Manual Verification in pgAdmin

1. Open pgAdmin at `http://localhost:5050`
2. Login with `admin@admin.com` / `admin`
3. Navigate: **Servers > PostgreSQL > Databases > piscineds**
4. Expand: **Schemas > public > Tables**
5. Right-click `items` > **View/Edit Data > First 100 Rows**

## Expected Results

- **Rows:** 109,579 rows (from item.csv)
- **Columns:** 4 columns matching CSV headers
- **Data types:** 3 different PostgreSQL types as specified
- **Indexes:** product_id, category_id, brand

## Verification Queries

Connect to the database:

```bash
psql -U asoler -d piscineds -h localhost
```

Run verification queries:

```sql
-- Check table structure
\d items

-- Count rows
SELECT COUNT(*) FROM items;

-- View sample data
SELECT * FROM items LIMIT 10;

-- Count items with brands
SELECT COUNT(*) FROM items WHERE brand IS NOT NULL AND brand != '';

-- Top 10 brands by product count
SELECT brand, COUNT(*) as count
FROM items
WHERE brand IS NOT NULL AND brand != ''
GROUP BY brand
ORDER BY count DESC
LIMIT 10;
```

## Data Characteristics

- **Total items:** ~109,579
- Many items have empty `category_code` and `brand` fields
- Contains product catalog information
- Links to customer transaction data via `product_id`

## Notes

- The CSV file contains product metadata
- Some fields may be empty (NULL or empty string)
- The CSV contains duplicate product_ids (not suitable for PRIMARY KEY)
- Indexes on `product_id`, `category_id` and `brand` for query performance
- Use `validate.sh` for quick PostgreSQL validation
- Use `test_items_pgadmin.py` for pgAdmin visualization proof
