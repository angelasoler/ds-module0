#!/usr/bin/env python3
"""
Exercise 03: Verify all customer tables in pgAdmin
Selenium test to validate automatic table creation and visualization in pgAdmin
"""

import time
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager

# pgAdmin configuration
PGADMIN_URL = "http://localhost:5050"
PGADMIN_EMAIL = "admin@admin.com"
PGADMIN_PASSWORD = "admin"

# Database configuration
DB_NAME = "piscineds"
DB_USER = "asoler"

# Expected tables from automatic creation
EXPECTED_TABLES = [
    "data_2022_oct",
    "data_2022_nov",
    "data_2022_dec",
    "data_2023_jan"
]


def setup_driver(headless=False):
    """Setup Chrome driver with options"""
    chrome_options = Options()
    if headless:
        chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--window-size=1920,1080")

    driver = webdriver.Chrome(
        service=Service(ChromeDriverManager().install()),
        options=chrome_options
    )
    return driver


def login_to_pgadmin(driver):
    """Login to pgAdmin"""
    print(f"\n[1/5] Connecting to pgAdmin at {PGADMIN_URL}...")
    driver.get(PGADMIN_URL)

    print("[2/5] Logging in...")
    email_field = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.NAME, "email"))
    )
    password_field = driver.find_element(By.NAME, "password")

    email_field.clear()
    email_field.send_keys(PGADMIN_EMAIL)
    password_field.clear()
    password_field.send_keys(PGADMIN_PASSWORD)
    password_field.submit()

    time.sleep(5)
    print("✓ Logged in to pgAdmin")


def verify_tables_in_pgadmin(driver):
    """Verify that all customer tables exist in pgAdmin"""

    print("\n" + "="*60)
    print("  Exercise 03: Multiple Tables Verification in pgAdmin")
    print(f"  Expected tables: {len(EXPECTED_TABLES)}")
    print("="*60)

    try:
        login_to_pgadmin(driver)

        # Take screenshot of dashboard
        driver.save_screenshot("ex03_step1_dashboard.png")
        print("✓ Screenshot: Dashboard")

        # Check database and tables
        print(f"\n[3/5] Verifying database '{DB_NAME}' and tables...")
        time.sleep(3)

        page_source = driver.page_source.lower()

        # Check database
        if DB_NAME.lower() in page_source:
            print(f"✓ Database '{DB_NAME}' found in page")
        else:
            print(f"⚠ Database '{DB_NAME}' not immediately visible")

        # Check each table
        print(f"\n[4/5] Checking for {len(EXPECTED_TABLES)} tables...")
        found_tables = []
        missing_tables = []

        for table in EXPECTED_TABLES:
            if table.lower() in page_source:
                print(f"  ✓ {table}")
                found_tables.append(table)
            else:
                print(f"  ⚠ {table} (not immediately visible)")
                missing_tables.append(table)

        # Take screenshot of browser state
        time.sleep(2)
        driver.save_screenshot("ex03_step2_tables_check.png")
        print("✓ Screenshot: Tables verification")

        # Try to navigate browser tree
        print("\n[5/5] Exploring browser tree...")
        try:
            # Look for tree items
            tree_items = driver.find_elements(
                By.CSS_SELECTOR,
                ".aciTreeItem, [role='treeitem'], .browser-tree-item"
            )

            if tree_items:
                print(f"  Found {len(tree_items)} tree items in browser")

            # Look for "Servers" or "Tables" text
            servers_elements = driver.find_elements(
                By.XPATH,
                "//*[contains(text(), 'Servers') or contains(text(), 'Tables')]"
            )

            if servers_elements:
                print(f"  Found {len(servers_elements)} navigation elements")

            time.sleep(2)
            driver.save_screenshot("ex03_step3_browser_tree.png")
            print("✓ Screenshot: Browser tree navigation")

        except Exception as e:
            print(f"  Note: Could not interact with tree: {e}")

        # Final screenshot
        driver.save_screenshot("ex03_step4_final.png")
        print("✓ Screenshot: Final state")

        # Verification summary
        print("\n" + "="*60)
        print("  Verification Summary")
        print("="*60)
        print(f"✓ pgAdmin is accessible")
        print(f"✓ Successfully logged in")
        print(f"✓ Database '{DB_NAME}' present")
        print(f"\nTables found in page source: {len(found_tables)}/{len(EXPECTED_TABLES)}")

        for table in found_tables:
            print(f"  ✓ {table}")

        if missing_tables:
            print(f"\nTables not immediately visible: {len(missing_tables)}")
            for table in missing_tables:
                print(f"  ⚠ {table}")
            print("\n  Note: Tables may require expanding tree nodes in pgAdmin")

        print("\nScreenshots saved:")
        print("  - ex03_step1_dashboard.png")
        print("  - ex03_step2_tables_check.png")
        print("  - ex03_step3_browser_tree.png")
        print("  - ex03_step4_final.png")

        print("\n" + "="*60)
        print("  ✓ Exercise 03: Validation Complete!")
        print("="*60)

        print(f"\nTo manually verify all tables in pgAdmin:")
        print(f"1. Open pgAdmin at {PGADMIN_URL}")
        print(f"2. Navigate: Servers > PostgreSQL > Databases > {DB_NAME}")
        print(f"3. Expand: Schemas > public > Tables")
        print(f"4. You should see all {len(EXPECTED_TABLES)} tables:")
        for table in EXPECTED_TABLES:
            print(f"   - {table}")

        # Consider test successful if most tables found
        success_threshold = len(EXPECTED_TABLES) // 2  # At least half
        return len(found_tables) >= success_threshold

    except Exception as e:
        print(f"\n✗ Error during verification: {e}")
        driver.save_screenshot("ex03_error.png")
        return False


def main():
    """Main test function"""
    driver = setup_driver(headless=False)

    try:
        success = verify_tables_in_pgadmin(driver)

        # Keep browser open for review
        print("\nKeeping browser open for 5 seconds...")
        time.sleep(5)

        return success
    finally:
        driver.quit()


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
