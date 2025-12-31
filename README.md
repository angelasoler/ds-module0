# PostgreSQL Learning Module - Module 0

A hands-on, beginner-friendly project for learning PostgreSQL fundamentals from scratch. This module teaches database concepts through progressive exercises, starting with environment setup and advancing to automated table creation and data management.

## 📚 What You'll Learn

This project is designed for people with **no prior database experience**. By completing these exercises, you will understand:

- **PostgreSQL Data Types**: When and why to use different data types (TEXT, VARCHAR, INTEGER, BIGINT, NUMERIC, TIMESTAMP, UUID)
- **Database Schemas**: How to design and create tables with appropriate structure
- **Data Loading**: Loading large CSV files into PostgreSQL efficiently
- **Indexes**: Creating indexes to optimize query performance
- **pgAdmin**: Using a GUI tool to visualize and manage databases
- **Automation**: Writing bash scripts to automate database operations
- **SQL Syntax**: Core SQL commands for creating, querying, and managing data

## 🏗️ System Architecture

Understanding how the pieces fit together:

```
┌─────────────────────────────────────────────────────────┐
│                    Your Computer                         │
│                                                          │
│  ┌──────────────┐         ┌─────────────────────┐      │
│  │   Browser    │         │   Terminal/CLI      │      │
│  │ localhost:5050│        │   (SQL commands)    │      │
│  └──────┬───────┘         └──────────┬──────────┘      │
│         │                             │                  │
│         │ HTTP                        │ psql             │
│         ▼                             ▼                  │
│  ┌──────────────┐         ┌─────────────────────┐      │
│  │   pgAdmin    │◄───────►│   PostgreSQL        │      │
│  │  Container   │  Admin  │   Container         │      │
│  │  (GUI Tool)  │  Queries│   (Database)        │      │
│  └──────────────┘         └─────────┬───────────┘      │
│                                      │                  │
│                                      ▼                  │
│                           ┌─────────────────┐          │
│                           │  Persistent     │          │
│                           │  Volume         │          │
│                           │  (Your Data)    │          │
│                           └─────────────────┘          │
└─────────────────────────────────────────────────────────┘
```

**Key Points:**
- **PostgreSQL**: Database engine that stores your data
- **pgAdmin**: Web interface to interact with PostgreSQL
- **Containers**: Isolated environments managed by Docker
- **Persistent Volume**: Data survives even when containers restart

## 📊 Data Loading Process

How CSV files become database tables:

```
CSV File on Disk          PostgreSQL Table in Database
─────────────────         ─────────────────────────────

Step 1: Read CSV
utils/customer/
data_2022_oct.csv
         │
         │ \copy command reads file
         ▼
Step 2: Parse & Convert
┌─────────────────────┐
│ Header Row          │ → Column names matched
│ event_time,type,... │
│                     │
│ Data Rows           │ → Converted to SQL types
│ 2022-10-01,cart,... │   (TEXT→text, numbers→numeric)
└─────────────────────┘
         │
         ▼
Step 3: Insert into Table
┌─────────────────────────┐
│ data_2022_oct           │
│ ├─ event_time (TIMESTAMP)
│ ├─ event_type (TEXT)
│ ├─ product_id (INTEGER)
│ ├─ price (NUMERIC)
│ ├─ user_id (BIGINT)
│ └─ user_session (UUID)
└─────────────────────────┘
         │
         ▼
Step 4: Create Indexes
Makes queries fast!
```

## 🗺️ Learning Journey

Your path through the exercises:

```
ex00              ex01              ex02              ex03              ex04
────              ────              ────              ────              ────
Set up Docker  →  Connect to DB  →  Create Table  →  Automate      →  Analyze Data
& Containers      via pgAdmin       Manually          with Scripts      with Queries

Docker basics     Verify setup      Learn SQL         Bash scripting    Advanced SQL
                  works             syntax            & loops           & aggregation

⏱️  15 min         ⏱️  10 min         ⏱️  30 min         ⏱️  45 min         ⏱️  30 min
```

**Total Time**: ~2-3 hours with experimentation

## 🔀 Choosing Data Types

Decision tree for selecting PostgreSQL data types:

```
What kind of data do you have?
         │
         ├─ Numbers?
         │   ├─ Whole numbers? (no decimals)
         │   │   ├─ Small (-2B to +2B)? → INTEGER
         │   │   └─ Large (billions+)? → BIGINT
         │   └─ Decimals? (money, measurements)
         │       └─ Need exact precision? → NUMERIC(10,2)
         │
         ├─ Text/Strings?
         │   ├─ Known max length? → VARCHAR(n)
         │   │   Example: VARCHAR(100) for brand names
         │   └─ Unknown/unlimited? → TEXT
         │       Example: TEXT for descriptions
         │
         ├─ Dates/Times?
         │   └─ With timezone info? → TIMESTAMP WITH TIME ZONE
         │       Example: 2022-10-01 00:00:00 UTC
         │
         └─ Unique identifier?
             └─ Random/session ID? → UUID
                 Example: 550e8400-e29b-41d4-a716-446655440000
```

**Pro Tip**: Always use `TIMESTAMP WITH TIME ZONE` for dates. Always use `NUMERIC` for money (never FLOAT).

## 🎯 Learning Objectives by Exercise

### Exercise 00: Environment Setup
Set up a containerized PostgreSQL database and pgAdmin using Docker Compose.

**Key Concepts**: Docker, containerization, database servers

### Exercise 01: Database Connection
Connect to your PostgreSQL database through pgAdmin and understand the client-server relationship.

**Key Concepts**: Database clients, connections, authentication

### Exercise 02: Manual Table Creation
Create your first table manually and load data from a CSV file.

**Key Concepts**:
- 6 PostgreSQL data types and their use cases
- Table creation syntax (`CREATE TABLE`)
- Data loading (`\copy` command)
- Indexes for performance

**Expected Output:**

After running [table.sql](ex02/table.sql), you should see:

```sql
-- Table structure confirmation
\d data_2022_oct
```

```
                          Table "public.data_2022_oct"
    Column     |           Type            | Collation | Nullable | Default
---------------+---------------------------+-----------+----------+---------
 event_time    | timestamp with time zone  |           |          |
 event_type    | text                      |           |          |
 product_id    | integer                   |           |          |
 price         | numeric(10,2)             |           |          |
 user_id       | bigint                    |           |          |
 user_session  | uuid                      |           |          |
Indexes:
    "idx_data_2022_oct_event_time" btree (event_time)
    "idx_data_2022_oct_product_id" btree (product_id)
    "idx_data_2022_oct_user_id" btree (user_id)
```

```sql
-- Row count verification
SELECT COUNT(*) as total_rows FROM data_2022_oct;
```

```
 total_rows
------------
    4543535
(1 row)
```

**What this means**: You successfully loaded 4.5+ million event records with proper data types and indexes!

### Exercise 03: Automated Table Creation
Write a bash script that automatically creates tables for multiple CSV files.

**Key Concepts**:
- Automation with shell scripts
- Dynamic SQL generation
- Iteration and loops
- Database administration via command line

### Exercise 04: Items Table
Create a product catalog table with different column types and analyze the data.

**Key Concepts**:
- VARCHAR vs TEXT data types
- Handling NULL values
- Aggregation queries (GROUP BY, COUNT)
- Data analysis with SQL

**Expected Output:**

After running [items_table.sql](ex04/items_table.sql), the brand analysis query shows:

```sql
-- Top brands by product count
SELECT brand, COUNT(*) as count
FROM items
WHERE brand IS NOT NULL AND brand != ''
GROUP BY brand
ORDER BY count DESC
LIMIT 10;
```

```
    brand     | count
--------------+--------
 samsung      |  1548
 apple        |   896
 sokolov      |   785
 l'oreal      |   584
 xiaomi       |   562
 maybelline   |   423
 tom ford     |   387
 gucci        |   342
 puma         |   318
 nike         |   294
(10 rows)
```

**What this means**: The items catalog contains products from various brands, with Samsung having the most products. This data can be joined with event data to analyze brand performance!

## 🚀 Getting Started

### Prerequisites

- **Docker** and **Docker Compose** installed on your system
- Basic command line knowledge
- A text editor

No prior database or SQL knowledge required!

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd ds-module0
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` and fill in your desired credentials:
   ```
   PGADMIN_DEFAULT_EMAIL=your-email@example.com
   PGADMIN_DEFAULT_PASSWORD=your-secure-password
   POSTGRES_USER=your-username
   POSTGRES_PASSWORD=your-secure-password
   POSTGRES_DB=your-database-name
   ```

3. **Start the services**
   ```bash
   make up
   # Or: docker compose up -d
   ```

4. **Access pgAdmin**
   - Open your browser and go to http://localhost:5050
   - Login with the email and password you set in `.env`

### Verify Installation

```bash
# Check that containers are running
make ps

# You should see two containers:
# - postgres_db (PostgreSQL)
# - pgadmin (pgAdmin 4)
```

## 📂 Project Structure

```
ds-module0/
├── ex00/               # Docker environment setup
├── ex01/               # Database connection practice
├── ex02/               # Manual table creation
│   └── table.sql       # SQL script for creating data_2022_oct table
├── ex03/               # Automated table creation
│   └── automatic_table.sh  # Bash script for automation
├── ex04/               # Items table creation
│   └── items_table.sql # SQL script for items table
├── utils/              # Data files (not tracked in git)
│   ├── customer/       # E-commerce event data (4 CSV files, ~1.5GB)
│   └── item/           # Product catalog data (1 CSV file, ~2.6MB)
├── docker-compose.yml  # Docker services configuration
├── makefile           # Convenient commands for Docker operations
└── .env.example       # Template for environment variables
```

## 🗄️ Understanding the Data

### Customer Event Data
Located in `utils/customer/`, contains e-commerce events from Oct 2022 - Jan 2023.

**Columns:**
- `event_time`: When the event occurred (with timezone)
- `event_type`: Type of event (cart, view, remove_from_cart)
- `product_id`: Product identifier
- `price`: Product price
- `user_id`: User identifier
- `user_session`: Session UUID

**Files:**
- `data_2022_oct.csv`
- `data_2022_nov.csv`
- `data_2022_dec.csv`
- `data_2023_jan.csv`

### Item Catalog Data
Located in `utils/item/item.csv`, contains product information.

**Columns:**
- `product_id`: Product identifier
- `category_id`: Category identifier
- `category_code`: Category path/name
- `brand`: Product brand

## 🔧 Common Commands

```bash
# Start services
make up

# Stop services (keeps data)
make stop

# Restart services
make start

# Check service status
make ps

# Stop and remove containers (keeps volumes)
make down

# Complete cleanup (removes all data)
make clean
```

## 📖 Key PostgreSQL Concepts

### Data Types

Understanding when to use each data type is crucial:

| Data Type | Use Case | Example |
|-----------|----------|---------|
| `TIMESTAMP WITH TIME ZONE` | Date/time values with timezone | `2022-10-01 00:00:00 UTC` |
| `TEXT` | Variable-length strings (no limit) | Product descriptions |
| `VARCHAR(n)` | Strings with max length | `VARCHAR(100)` for brand names |
| `INTEGER` | Whole numbers (-2B to +2B) | Product IDs |
| `BIGINT` | Large whole numbers | User IDs (8 bytes) |
| `NUMERIC(p,s)` | Exact decimal numbers | `NUMERIC(10,2)` for prices |
| `UUID` | Unique identifiers | Session tokens |

### Why Indexes?

**Indexes** are like a book's index - they help the database find data quickly without scanning every row.

```sql
-- Without index: scans millions of rows
-- With index: finds data in milliseconds
CREATE INDEX idx_tablename_columnname ON tablename(columnname);
```

Create indexes on columns used in:
- `WHERE` clauses
- `JOIN` conditions
- `ORDER BY` statements

### The `\copy` Command

Loads CSV data from the client machine:

```sql
\copy table_name(col1, col2, col3)
FROM '/path/to/file.csv'
DELIMITER ','
CSV HEADER;
```

**Note**: Path is relative to where you run the command, or use absolute paths.

## 🎓 Learning Path

1. **Start with ex00**: Set up your environment
2. **Connect in ex01**: Access your database via pgAdmin
3. **Create manually in ex02**: Understand table creation step-by-step
4. **Automate in ex03**: Learn to script repetitive tasks
5. **Analyze in ex04**: Query and understand your data

Each exercise builds on previous concepts. Don't skip ahead!

## 🎯 Practice Queries

After completing exercises, practice your SQL skills with additional queries!

### Exercise 02 Practice
**File**: [ex02/practice_queries.sql](ex02/practice_queries.sql)

**Topics covered:**
- Basic SELECT and filtering (WHERE clauses)
- Aggregation functions (COUNT, AVG, SUM, MIN, MAX)
- Time-based analysis (DATE_TRUNC, EXTRACT)
- Window functions (LAG, ROW_NUMBER, OVER)
- Grouping and HAVING clauses
- Price analysis and user behavior patterns
- Performance analysis (EXPLAIN ANALYZE)

**20+ progressive queries** from basic to advanced, plus 5 challenges!

### Exercise 04 Practice
**File**: [ex04/practice_queries.sql](ex04/practice_queries.sql)

**Topics covered:**
- NULL handling (IS NULL, COALESCE)
- Text functions (LENGTH, SPLIT_PART, STRING_AGG)
- Complex grouping with CASE statements
- Common Table Expressions (CTEs)
- Data quality checks (duplicates, conflicts)
- Joining tables (linking items with events)
- Text search (LIKE, ILIKE patterns)

**22+ queries** focusing on catalog data analysis, plus 5 challenges!

### How to Use Practice Queries

**Option 1: Run entire file**
```bash
psql -U your_user -d your_db -h localhost -f ex02/practice_queries.sql
```

**Option 2: Copy-paste individual queries** (Recommended for beginners)
1. Open the practice file in your text editor
2. Copy one query at a time
3. Paste into pgAdmin Query Tool
4. Run and observe results
5. Modify and experiment!

**Learning approach:**
1. **Read** the query comment (explains what it does)
2. **Predict** what the output will be
3. **Run** the query
4. **Compare** actual vs expected results
5. **Modify** the query to explore further

**Pro tip:** Each query is numbered and self-contained - run them in any order!

## 💡 Tips for Learning

- **Read the SQL comments**: Each SQL file has detailed explanations
- **Experiment in pgAdmin**: Try modifying queries to see what happens
- **Check your work**: Use `SELECT COUNT(*)` to verify data loaded correctly
- **Understand, don't memorize**: Focus on *why* we use certain data types, not just *how*
- **Use `\d table_name`**: This psql command shows table structure - very useful!

## 🐛 Troubleshooting Guide

### Docker & Containers

#### "Cannot connect to Docker daemon"
**Symptoms:** `docker compose up` fails with connection error
**Cause:** Docker service not running
**Solution:**
```bash
# On Linux
sudo systemctl start docker
sudo systemctl status docker

# On Mac/Windows - Start Docker Desktop application
```

#### "Port 5432 already in use"
**Symptoms:** PostgreSQL container fails to start
**Cause:** Another PostgreSQL instance running
**Solution:**
```bash
# Find what's using port 5432
sudo lsof -i :5432

# Option 1: Stop conflicting process
# Option 2: Change port in docker-compose.yml
# Change "5432:5432" to "5433:5432"
```

#### "Port 5050 already in use"
**Symptoms:** pgAdmin container fails to start
**Cause:** Another service using port 5050
**Solution:**
```bash
# Change port in docker-compose.yml
# Change "5050:80" to "5051:80" (access at localhost:5051)
```

### pgAdmin Connection

#### "Unable to connect to server"
**Symptoms:** pgAdmin shows red "X" when connecting
**Cause:** Incorrect connection settings
**Solution:**
1. Right-click server → Properties → Connection
2. Verify settings:
   - **Host**: `postgres` (container name, NOT `localhost`)
   - **Port**: `5432`
   - **Username**: From `.env` (`POSTGRES_USER`)
   - **Password**: From `.env` (`POSTGRES_PASSWORD`)

**Common mistake**: Using `localhost` instead of `postgres` as host

#### "FATAL: password authentication failed"
**Symptoms:** pgAdmin rejects password
**Cause:** Mismatch between `.env` and pgAdmin
**Solution:**
```bash
# 1. Check your .env file
cat .env

# 2. Recreate containers
make clean  # Removes old data
make up     # Starts fresh
```

### CSV Loading

#### "No such file or directory"
**Symptoms:** `\copy` command can't find CSV
**Cause:** Wrong file path
**Solution:**
```bash
# Option 1: Use absolute paths
\copy table_name FROM '/full/path/to/data_2022_oct.csv' ...

# Option 2: Run from correct directory
cd /path/to/ds-module0/ex02

# Verify file exists
ls -la ../utils/customer/data_2022_oct.csv
```

#### "Permission denied reading CSV"
**Symptoms:** PostgreSQL can't read CSV file
**Cause:** File permissions too restrictive
**Solution:**
```bash
# Fix permissions
chmod 644 utils/customer/data_2022_oct.csv
```

#### "Extra data after last expected column"
**Symptoms:** CSV loading fails partway
**Cause:** CSV format doesn't match table
**Solution:**
1. Count CSV columns: `head -1 utils/customer/data_2022_oct.csv`
2. Count table columns in CREATE TABLE
3. Ensure they match exactly

### SQL Execution

#### "Relation 'table_name' does not exist"
**Symptoms:** Query fails saying table doesn't exist
**Cause:** Table not created or wrong database
**Solution:**
```sql
-- List all tables
\dt

-- Check current database
SELECT current_database();

-- Switch database
\c your_database_name
```

#### "Column does not exist"
**Symptoms:** SELECT query fails
**Cause:** Typo or column doesn't exist
**Solution:**
```sql
-- See all columns
\d table_name
```

### Bash Scripts (Exercise 03)

#### "Permission denied" running script
**Symptoms:** Can't execute `./automatic_table.sh`
**Cause:** Script not executable
**Solution:**
```bash
chmod +x ex03/automatic_table.sh
```

#### Script creates empty tables
**Symptoms:** Tables exist but have 0 rows
**Cause:** CSV path wrong or connection failed
**Solution:**
1. Check script output for errors
2. Verify CSV files exist: `ls -la utils/customer/*.csv`
3. Test connection:
```bash
psql -U your_user -d your_db -h localhost -c "SELECT 1;"
```

### Performance

#### Queries take forever
**Symptoms:** Simple SELECT runs for minutes
**Cause:** Missing indexes
**Solution:**
```sql
-- Check indexes exist
\d table_name

-- Create missing index
CREATE INDEX idx_table_col ON table_name(column_name);

-- Update statistics
ANALYZE table_name;
```

### Still Stuck?

**Check container logs:**
```bash
docker compose logs postgres
docker compose logs pgadmin
```

**Restart everything:**
```bash
make down
make up
```

**Nuclear option (deletes all data):**
```bash
make clean
make up
```

## ❓ Frequently Asked Questions (FAQ)

### General Questions

**Q: Do I need to know SQL before starting?**
A: No! This module teaches SQL from scratch. Start with ex00 and work through sequentially.

**Q: How much disk space do I need?**
A: At least 5GB free. The CSV files are ~1.5GB and PostgreSQL needs room for indexes.

**Q: Can I use this on Windows/Mac/Linux?**
A: Yes! Docker works on all three platforms. Commands are the same.

**Q: How long does this module take?**
A: Approximately 2-3 hours if you read carefully and experiment.

### Docker & Setup

**Q: What is Docker and why use it?**
A: Docker creates isolated "containers" that package PostgreSQL and pgAdmin with all dependencies. No need to install PostgreSQL directly, avoiding version conflicts.

**Q: What happens if I run `make clean`?**
A: It **deletes all data** in your database. Only use to start completely fresh. Use `make down` to stop containers but keep data.

**Q: Do containers keep running after I close the terminal?**
A: Yes, with `docker compose up -d` (the `-d` flag runs in background). Stop with `make stop` or `make down`.

### Database Concepts

**Q: What's the difference between PostgreSQL and pgAdmin?**
A:
- **PostgreSQL** = Database engine (stores and manages data)
- **pgAdmin** = Visual tool to interact with PostgreSQL (like a web browser for databases)

**Q: Why do we create indexes?**
A: Indexes help find data quickly without scanning every row.

Example: Finding `user_id=12345` in 4.5 million rows:
- Without index: ~2 seconds (scans all rows)
- With index: ~0.001 seconds (direct lookup)

**Q: When should I use TEXT vs VARCHAR?**
A:
- **TEXT**: Unknown max length (descriptions, comments)
- **VARCHAR(n)**: Known logical max (phone numbers, usernames)

In PostgreSQL, both perform similarly, so TEXT is often fine for beginners.

**Q: What's a UUID and why use it?**
A: UUID = Universally Unique Identifier. A 128-bit random value like `550e8400-e29b-41d4-a716-446655440000`.

Used for session IDs because:
- Globally unique (no duplicates even across databases)
- Hard to guess (better security)
- Can be generated anywhere

**Q: Why NUMERIC for money instead of FLOAT?**
A: FLOAT has rounding errors:

```sql
-- FLOAT (bad for money)
SELECT 0.1 + 0.2;  -- Returns 0.30000000000000004 (wrong!)

-- NUMERIC (exact)
SELECT 0.1::NUMERIC + 0.2::NUMERIC;  -- Returns 0.3 (correct!)
```

NUMERIC stores exact decimal values, critical for financial calculations.

### Working with Data

**Q: How do I know if data loaded correctly?**
A: Three checks:
```sql
-- 1. Count rows
SELECT COUNT(*) FROM table_name;

-- 2. Check for NULLs
SELECT * FROM table_name WHERE important_column IS NULL;

-- 3. Sample data
SELECT * FROM table_name LIMIT 10;
```

**Q: Can I load data multiple times?**
A: Yes, but it creates duplicates. Always `DROP TABLE IF EXISTS` first or use `TRUNCATE TABLE table_name;`.

**Q: What's the difference between \copy and COPY?**
A:
- `\copy` = Runs on client machine (psql), reads files from your computer
- `COPY` = Runs on server, reads files from server filesystem

In Docker, always use `\copy` since CSV files are on your computer.

### SQL & Queries

**Q: What does `\d table_name` do?**
A: It's a psql meta-command that **d**escribes a table (shows columns, types, indexes). Very useful!

**Q: Why do some commands end with `;` and others don't?**
A:
- SQL commands (SELECT, CREATE) **need semicolon**: `SELECT * FROM table;`
- psql meta-commands (start with `\`) **no semicolon**: `\d table_name`

**Q: What's the difference between WHERE and HAVING?**
A:
- **WHERE**: Filters rows before grouping
- **HAVING**: Filters groups after aggregation

```sql
-- WHERE filters individual rows
SELECT brand, COUNT(*) FROM items
WHERE brand IS NOT NULL
GROUP BY brand;

-- HAVING filters aggregated results
SELECT brand, COUNT(*) as count FROM items
GROUP BY brand
HAVING COUNT(*) > 1000;
```

### Scripting (Exercise 03)

**Q: Why use bash scripts for database operations?**
A: Automation! Scripts:
- Reduce human error
- Save time
- Ensure consistency
- Can be scheduled/repeated

**Q: What does `PGPASSWORD=$DB_PASSWORD` do?**
A: Sets environment variable for one command. Without it, psql prompts for password interactively (breaks automation).

### Best Practices

**Q: Should I commit my .env file to git?**
A: **NO!** Never commit credentials. The `.env` file should be in `.gitignore`. Only commit `.env.example`.

**Q: How do I backup my data?**
A:
```bash
# Export database
docker exec postgres_db pg_dump -U your_user your_db > backup.sql

# Restore
docker exec -i postgres_db psql -U your_user your_db < backup.sql
```

**Q: Is it normal for CSV loading to take minutes?**
A: Yes! Loading millions of rows takes time:
- `data_2022_oct.csv`: ~30 seconds
- `data_2022_nov.csv`: ~45 seconds
- Creating indexes: ~15 seconds each

Be patient!

## 📚 Resources

- [PostgreSQL Official Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Data Types](https://www.postgresql.org/docs/current/datatype.html)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)
- [SQL Tutorial](https://www.postgresqltutorial.com/)

## 🤝 Contributing

This is a learning project. Feel free to:
- Suggest improvements to explanations
- Add more example queries
- Report unclear instructions
- Share your learning experience

## 📝 License

This project is for educational purposes.

---

**Happy Learning! 🎉**

Remember: Everyone starts somewhere. Take your time, understand each concept, and don't hesitate to experiment!
