# Exercise 03: Automatic Table Creation

This exercise automates the table creation process from Exercise 02 for **all** CSV files in the customer folder.

## Objective

Automatically retrieve all CSV files from the `customer/` folder and create a table for each one:
- **Source:** `utils/subject/customer/*.csv`
- **Expected files:**
  - `data_2022_oct.csv`
  - `data_2022_nov.csv`
  - `data_2022_dec.csv`
  - `data_2023_jan.csv`
- **Table names:** Must match CSV filename (without `.csv` extension)
- **Automation:** Process all files without manual intervention

## Files

- **automatic_table.sh** - Main automation script
- **validate.sh** - Validation script to verify all tables (PostgreSQL)
- **test_tables_pgadmin.py** - Selenium test for pgAdmin visualization
- **requirements.txt** - Python dependencies
- **README.md** - This file

## How It Works

The `automatic_table.sh` script:

1. Scans the `utils/subject/customer/` directory for all `.csv` files
2. For each CSV file:
   - Extracts the filename (e.g., `data_2022_oct`)
   - Generates a `CREATE TABLE` statement
   - Creates the table with appropriate data types
   - Adds indexes for performance
   - Loads data using `\copy` command
   - Reports row count

## Usage

### Run the automation script

```bash
cd ex03
./automatic_table.sh
```

### Validate the results in PostgreSQL

```bash
./validate.sh
```

### Verify in pgAdmin (Selenium)

```bash
# Install dependencies
pip install -r requirements.txt

# Run Selenium test
python test_tables_pgadmin.py
```

### Using Docker

```bash
cd ex03
docker exec -i postgres_db bash < automatic_table.sh
```

## Table Structure

Each table is created with the same structure:

```sql
CREATE TABLE <filename> (
    event_time TIMESTAMP WITH TIME ZONE,
    event_type TEXT,
    product_id INTEGER,
    price NUMERIC(10,2),
    user_id BIGINT,
    user_session UUID
);
```

With indexes on:
- `event_time`
- `user_id`
- `product_id`

## Expected Results

After running the script, you should have **4 tables**:

| Table Name       | CSV File              | Expected Rows |
|------------------|-----------------------|---------------|
| data_2022_oct    | data_2022_oct.csv     | 4,102,284     |
| data_2022_nov    | data_2022_nov.csv     | 4,635,838     |
| data_2022_dec    | data_2022_dec.csv     | 3,533,287     |
| data_2023_jan    | data_2023_jan.csv     | 4,264,753     |

**Total:** 16,536,162 rows across all tables

## Verification

Connect to the database and check:

```bash
psql -U asoler -d piscineds -h localhost
```

```sql
-- List all tables
\dt

-- Check row counts
SELECT 'data_2022_oct' as table_name, COUNT(*) FROM data_2022_oct
UNION ALL
SELECT 'data_2022_nov', COUNT(*) FROM data_2022_nov
UNION ALL
SELECT 'data_2022_dec', COUNT(*) FROM data_2022_dec
UNION ALL
SELECT 'data_2023_jan', COUNT(*) FROM data_2023_jan;
```

## Selenium Test for pgAdmin

The `test_tables_pgadmin.py` script:
- Logs into pgAdmin automatically
- Verifies the database `piscineds` is visible
- Checks for all 4 tables: `data_2022_oct`, `data_2022_nov`, `data_2022_dec`, `data_2023_jan`
- Takes screenshots at each step for evaluation
- Provides manual navigation instructions
- Runs with browser visible (not headless) for demonstration

**Screenshots generated:**
- `ex03_step1_dashboard.png` - pgAdmin dashboard
- `ex03_step2_tables_check.png` - Tables verification
- `ex03_step3_browser_tree.png` - Browser tree navigation
- `ex03_step4_final.png` - Final state
- `ex03_error.png` - Error state (if any)

## Manual Verification in pgAdmin

1. Open pgAdmin at `http://localhost:5050`
2. Login with `admin@admin.com` / `admin`
3. Navigate: **Servers > PostgreSQL > Databases > piscineds**
4. Expand: **Schemas > public > Tables**
5. Verify all 4 tables are present

## Notes

- The script drops existing tables before recreating them
- All CSV files must have the same column structure
- The script uses absolute paths for `\copy` command
- Progress is displayed for each table
- A summary is shown at the end with table sizes
- Use `validate.sh` for quick PostgreSQL validation
- Use `test_tables_pgadmin.py` for pgAdmin visualization proof
