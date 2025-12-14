# Exercise 02: First Table (Manual Creation)

This exercise demonstrates manual creation of a PostgreSQL table from a CSV file.

## Objective

Create a table named `data_2022_oct` from the CSV file:
- **Source:** `utils/subject/customer/data_2022_oct.csv`
- **Table name:** Must match CSV filename (without `.csv` extension)
- **Columns:** Must exactly match CSV headers
- **Data types:** Use at least 6 different PostgreSQL data types
- **First column:** Must be a DATETIME/TIMESTAMP type

## Table Structure

The table uses **6 different PostgreSQL data types**:

1. `TIMESTAMP WITH TIME ZONE` - event_time (first column, required)
2. `TEXT` - event_type
3. `INTEGER` - product_id
4. `NUMERIC(10,2)` - price (decimal with precision)
5. `BIGINT` - user_id
6. `UUID` - user_session

## Files

- **create_table.sql** - Creates the table structure
- **load_data.sql** - Loads data from CSV file
- **validate.sh** - Validates table in PostgreSQL
- **test_table_pgadmin.py** - Selenium test for pgAdmin visualization
- **requirements.txt** - Python dependencies

## Usage

### Step 1: Create table and load data

```bash
# Create the table
psql -U asoler -d piscineds -h localhost < create_table.sql

# Load data from CSV
psql -U asoler -d piscineds -h localhost < load_data.sql
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
python test_table_pgadmin.py
```

## Selenium Test for pgAdmin

The `test_table_pgadmin.py` script:
- Logs into pgAdmin automatically
- Verifies the database `piscineds` is visible
- Checks for table `data_2022_oct` in the interface
- Takes screenshots at each step for evaluation
- Provides manual navigation instructions

**Screenshots generated:**
- `ex02_step1_dashboard.png` - pgAdmin dashboard
- `ex02_step2_browser_tree.png` - Browser tree view
- `ex02_step3_final.png` - Final state
- `ex02_error.png` - Error state (if any)

## Manual Verification in pgAdmin

1. Open pgAdmin at `http://localhost:5050`
2. Login with `admin@admin.com` / `admin`
3. Navigate: **Servers > PostgreSQL > Databases > piscineds**
4. Expand: **Schemas > public > Tables**
5. Right-click `data_2022_oct` > **View/Edit Data > First 100 Rows**

## Expected Results

- **Rows:** 4,102,283 rows (from data_2022_oct.csv)
- **Columns:** 6 columns matching CSV headers exactly
- **Data types:** 6 different PostgreSQL types as specified

## Verification

Connect to the database and verify:

```bash
psql -U asoler -d piscineds -h localhost
```

```sql
-- Check table structure
\d data_2022_oct

-- Count rows
SELECT COUNT(*) FROM data_2022_oct;

-- View sample data
SELECT * FROM data_2022_oct LIMIT 10;
```

## Notes

- The Selenium test runs with browser visible (not headless) for demonstration
- Screenshots provide visual proof for evaluations
- The test keeps the browser open for 5 seconds to review
- Use `validate.sh` for quick PostgreSQL validation
- Use `test_table_pgadmin.py` for pgAdmin visualization proof
