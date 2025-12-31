# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **ds-module0**, a PostgreSQL learning project designed to teach database fundamentals from the ground up. The project assumes no prior knowledge and progressively introduces core concepts through hands-on exercises (ex00-ex04).

**Learning Objectives:**
- Understanding PostgreSQL data types and when to use them
- Creating tables with proper schema design
- Loading data from CSV files into PostgreSQL
- Creating indexes for query performance
- Using pgAdmin for database visualization and management
- Automating database operations with shell scripts

## Environment Setup

The project uses Docker Compose to provide a complete PostgreSQL + pgAdmin environment:

**Services:**
- PostgreSQL 16 (port 5432)
- pgAdmin 4 (port 5050, accessible at http://localhost:5050)

**Environment Configuration:**
- Copy [.env.example](.env.example) to `.env` and fill in credentials
- Required variables: `PGADMIN_DEFAULT_EMAIL`, `PGADMIN_DEFAULT_PASSWORD`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`

**Common Commands:**
```bash
# Start services (detached)
make up
# Or: docker compose up -d

# Stop services (preserves data)
make stop

# Start stopped services
make start

# View running containers
make ps

# Stop and remove containers (preserves volumes)
make down

# Complete cleanup (removes volumes and all data)
make clean
```

## Data Files

Located in [utils/](utils/):

**Customer Data** ([utils/customer/](utils/customer/)):
- 4 large CSV files (~1.5GB total) containing e-commerce event data
- Files: `data_2022_oct.csv`, `data_2022_nov.csv`, `data_2022_dec.csv`, `data_2023_jan.csv`
- Schema: `event_time, event_type, product_id, price, user_id, user_session`
- Event types include: cart, view, remove_from_cart
- Timestamp format: "YYYY-MM-DD HH:MM:SS UTC"

**Item Data** ([utils/item/](utils/item/)):
- Single CSV file (~2.6MB) with product catalog
- File: `item.csv`
- Schema: `product_id, category_id, category_code, brand`
- Contains product metadata including brands and categories

## Exercise Structure

### ex00: Docker Environment Setup
- Contains basic [docker-compose.yml](ex00/docker-compose.yml)
- First introduction to containerized database

### ex01: Database Connection
- Practice connecting to PostgreSQL via pgAdmin
- Understanding database server vs client relationship

### ex02: Manual Table Creation
- [table.sql](ex02/table.sql): Creates `data_2022_oct` table manually
- **Key Learning**: PostgreSQL data types and their use cases
- Uses 6 different data types (requirement):
  1. `TIMESTAMP WITH TIME ZONE` - stores time with timezone info (always first column)
  2. `TEXT` - variable-length strings without limit
  3. `INTEGER` - standard 4-byte integer
  4. `NUMERIC(10,2)` - decimal numbers with precision (for money)
  5. `BIGINT` - 8-byte integer for large IDs
  6. `UUID` - universally unique identifier for sessions
- Creates indexes on frequently queried columns
- Uses `\copy` command to load CSV data

### ex03: Automated Table Creation
- [automatic_table.sh](ex03/automatic_table.sh): Bash script that automatically creates tables for ALL customer CSV files
- **Key Learning**: Automation, loops, dynamic SQL generation
- Iterates through `utils/customer/*.csv` files
- Generates table creation SQL dynamically
- Uses `psql` command-line tool with PGPASSWORD
- Shows progress with colored output
- Provides summary with table sizes using `pg_total_relation_size()`

### ex04: Items Table
- [items_table.sql](ex04/items_table.sql): Creates `items` table for product catalog
- **Key Learning**: Different data types for strings (VARCHAR vs TEXT)
- Uses `VARCHAR(255)` for category_code and `VARCHAR(100)` for brand
- Note: No PRIMARY KEY due to duplicates in source data
- Includes example GROUP BY query to analyze brand distribution

## SQL Concepts and Syntax

**Table Management:**
```sql
-- Always use IF EXISTS for idempotent scripts
DROP TABLE IF EXISTS table_name;

-- Create table with explicit data types
CREATE TABLE table_name (
    column1 TYPE,
    column2 TYPE
);
```

**Data Types Selection Guide:**
- `TIMESTAMP WITH TIME ZONE`: For datetime values where timezone matters
- `TEXT`: For strings without known length limit
- `VARCHAR(n)`: For strings with known max length (more restrictive than TEXT)
- `INTEGER`: For whole numbers -2B to +2B
- `BIGINT`: For large whole numbers (user IDs, large counts)
- `NUMERIC(precision, scale)`: For exact decimal numbers (money, measurements)
- `UUID`: For unique identifiers (better than sequential IDs for distributed systems)

**Index Creation:**
```sql
CREATE INDEX idx_tablename_columnname ON tablename(columnname);
```
Create indexes on columns used in WHERE clauses, JOINs, or ORDER BY for better performance.

**Loading Data:**
```sql
-- \copy runs on client side, works with relative paths
\copy table_name(col1, col2) FROM 'path/to/file.csv' DELIMITER ',' CSV HEADER;
```

**Useful Meta-commands (psql):**
- `\d table_name` - Describe table structure
- `\dt` - List all tables
- `\l` - List all databases
- `\c database_name` - Connect to database

**Common Query Patterns:**
```sql
-- Count rows
SELECT COUNT(*) as total_rows FROM table_name;

-- Sample data
SELECT * FROM table_name LIMIT 10;

-- Aggregation with grouping
SELECT column_name, COUNT(*) as count
FROM table_name
WHERE condition
GROUP BY column_name
ORDER BY count DESC;
```

## Database Connection from Scripts

When writing shell scripts that connect to PostgreSQL:

```bash
# Set password as environment variable
PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -c "SQL COMMAND"

# Execute SQL file
PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -f script.sql

# Get output for parsing
PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -h $DB_HOST -t -c "SELECT COUNT(*) FROM table;" | xargs
```

Flags:
- `-U`: Username
- `-d`: Database name
- `-h`: Host
- `-c`: Execute command
- `-f`: Execute file
- `-t`: Tuple-only mode (no headers/footers)

## Testing and Validation

Python scripts for testing are referenced but not yet implemented. When creating them:
- Use `psycopg2` or `psycopg` library for PostgreSQL connections
- Read database credentials from environment variables
- Test table existence, row counts, data types, and indexes
- Validate data integrity and constraints

Validation scripts should be named: `test_*_pgadmin.py` or `validate.sh`

## Writing Educational Documentation

When creating README files for exercises:
- **Assume zero prior knowledge** - define all terms and concepts
- Use proper terminology with clear explanations
- Include the "why" behind each decision (e.g., why BIGINT vs INTEGER)
- Provide visual examples when possible
- Structure as: Concept → Syntax → Example → Explanation
- List "Key Learnings" section highlighting main takeaways
- Show both the SQL commands and expected outcomes

## Project Patterns

1. **Idempotent Scripts**: All SQL files use `DROP TABLE IF EXISTS` before creation
2. **Indexes as Standard**: Create indexes on foreign keys and frequently queried columns
3. **Absolute Paths in Scripts**: Use `realpath` in bash scripts for CSV loading
4. **Verification Queries**: Always include COUNT(*) and LIMIT queries to verify data loading
5. **Comments in SQL**: Document purpose, source file, and requirements clearly
6. **Error Handling**: Scripts check for file existence before processing
7. **User Feedback**: Use colored output in bash scripts for better UX

## Common Gotchas

- **CSV Paths**: `\copy` uses client-side paths; may need absolute paths or correct relative path from execution directory
- **Timezone**: Always use `TIMESTAMP WITH TIME ZONE` for datetime columns to preserve timezone information
- **Duplicates**: Check for duplicate keys before adding PRIMARY KEY constraints
- **Case Sensitivity**: PostgreSQL table/column names are case-insensitive unless quoted
- **NULL vs Empty String**: They are different; use appropriate checks (IS NULL vs = '')
