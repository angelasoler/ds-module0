# Exercise 01: Database Visualization

This exercise demonstrates the use of pgAdmin as a database visualization tool.

## Requirements

- pgAdmin running on `http://localhost:5050`
- Python 3.x
- Google Chrome browser

## Setup

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

## Running the Test

Execute the Selenium test to validate pgAdmin accessibility:

```bash
python test_pgadmin.py
```

Or using pytest:

```bash
pytest test_pgadmin.py -v
```

## Expected Output

The test will:
- ✓ Connect to pgAdmin at localhost:5050
- ✓ Verify the login page is accessible
- ✓ Perform automated login
- ✓ Verify successful authentication
- ✓ Take a screenshot of the dashboard

## Manual Access

You can also access pgAdmin manually:

**URL:** http://localhost:5050

**Credentials:**
- Email: `admin@admin.com`
- Password: `admin`

## Screenshots

After running the test, screenshots will be saved in this directory:
- `ex01_pgadmin_dashboard.png` - Dashboard view (on success)
- `ex01_error.png` - Error state (on failure)

## What the Test Validates

1. **pgAdmin Accessibility** - Confirms web interface is running
2. **Login Functionality** - Automated authentication test
3. **Dashboard Loading** - Verifies successful navigation
4. **Screenshot Capture** - Visual proof for evaluation

This test demonstrates that Exercise 01 requirement is met: a database visualization tool (pgAdmin) is properly configured and accessible.
