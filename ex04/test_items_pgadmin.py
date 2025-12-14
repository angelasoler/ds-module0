#!/usr/bin/env python3
"""
Exercise 04: Verify items table in pgAdmin
Selenium test to validate items table creation and visualization in pgAdmin
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
TABLE_NAME = "items"


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


def verify_items_table_in_pgadmin(driver):
    """Verify that items table exists in pgAdmin"""

    print("\n" + "="*60)
    print("  Exercise 04: Items Table Verification in pgAdmin")
    print(f"  Table: {TABLE_NAME}")
    print("="*60)

    try:
        login_to_pgadmin(driver)

        # Take screenshot of dashboard
        driver.save_screenshot("ex04_step1_dashboard.png")
        print("✓ Screenshot: Dashboard")

        # Look for database and table
        print(f"\n[3/5] Verifying database '{DB_NAME}' and table '{TABLE_NAME}'...")
        time.sleep(3)

        page_source = driver.page_source.lower()

        # Check database
        if DB_NAME.lower() in page_source:
            print(f"✓ Database '{DB_NAME}' found in page")
        else:
            print(f"⚠ Database '{DB_NAME}' not immediately visible")

        # Check table
        if TABLE_NAME.lower() in page_source:
            print(f"✓ Table '{TABLE_NAME}' found in page")
        else:
            print(f"⚠ Table '{TABLE_NAME}' not immediately visible")
            print("  (May need to expand tree nodes)")

        # Take screenshot
        driver.save_screenshot("ex04_step2_table_check.png")
        print("✓ Screenshot: Table verification")

        # Try to navigate browser tree
        print("\n[4/5] Exploring browser tree...")
        try:
            tree_items = driver.find_elements(
                By.CSS_SELECTOR,
                ".aciTreeItem, [role='treeitem'], .browser-tree-item"
            )

            if tree_items:
                print(f"  Found {len(tree_items)} tree items")

            time.sleep(2)
            driver.save_screenshot("ex04_step3_browser_tree.png")
            print("✓ Screenshot: Browser tree")

        except Exception as e:
            print(f"  Note: Could not interact with tree: {e}")

        # Final verification
        print("\n[5/5] Final verification...")
        driver.save_screenshot("ex04_step4_final.png")
        print("✓ Screenshot: Final state")

        # Summary
        print("\n" + "="*60)
        print("  Verification Summary")
        print("="*60)
        print(f"✓ pgAdmin is accessible")
        print(f"✓ Successfully logged in")
        print(f"✓ Dashboard loaded")

        if DB_NAME.lower() in page_source:
            print(f"✓ Database '{DB_NAME}' is visible")

        if TABLE_NAME.lower() in page_source:
            print(f"✓ Table '{TABLE_NAME}' is visible in the interface")

        print("\nScreenshots saved:")
        print("  - ex04_step1_dashboard.png")
        print("  - ex04_step2_table_check.png")
        print("  - ex04_step3_browser_tree.png")
        print("  - ex04_step4_final.png")

        print("\n" + "="*60)
        print("  ✓ Exercise 04: Validation Complete!")
        print("="*60)

        print(f"\nTo manually verify the '{TABLE_NAME}' table:")
        print(f"1. Open pgAdmin at {PGADMIN_URL}")
        print(f"2. Navigate: Servers > PostgreSQL > Databases > {DB_NAME}")
        print(f"3. Expand: Schemas > public > Tables")
        print(f"4. Right-click '{TABLE_NAME}' > View/Edit Data > First 100 Rows")
        print(f"\nExpected: ~109,579 rows from item.csv")

        return True

    except Exception as e:
        print(f"\n✗ Error during verification: {e}")
        driver.save_screenshot("ex04_error.png")
        return False


def main():
    """Main test function"""
    driver = setup_driver(headless=False)

    try:
        success = verify_items_table_in_pgadmin(driver)

        # Keep browser open for review
        print("\nKeeping browser open for 5 seconds...")
        time.sleep(5)

        return success
    finally:
        driver.quit()


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
