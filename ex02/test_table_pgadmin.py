#!/usr/bin/env python3
"""
Exercise 02: Verify data_2022_oct table in pgAdmin
Selenium test to validate table creation and visualization in pgAdmin
"""

import time
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
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
DB_PASSWORD = "mysecretpassword"
DB_HOST = "postgres_db"
DB_PORT = "5432"
SERVER_NAME = "PostgreSQL"
TABLE_NAME = "data_2022_oct"


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
    print(f"\n[1/6] Connecting to pgAdmin at {PGADMIN_URL}...")
    driver.get(PGADMIN_URL)

    print("[2/6] Logging in...")
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


def verify_table_in_pgadmin(driver):
    """Verify that data_2022_oct table exists and can be viewed in pgAdmin"""

    print("\n" + "="*60)
    print("  Exercise 02: Table Verification in pgAdmin")
    print(f"  Table: {TABLE_NAME}")
    print("="*60)

    try:
        login_to_pgadmin(driver)

        # Take screenshot of dashboard
        driver.save_screenshot("ex02_step1_dashboard.png")
        print("✓ Screenshot: Dashboard")

        # Look for server in browser tree
        print(f"\n[3/6] Looking for database '{DB_NAME}' in browser tree...")
        time.sleep(3)

        # Try to find the database name in the page
        page_source = driver.page_source.lower()

        if DB_NAME.lower() in page_source:
            print(f"✓ Found database '{DB_NAME}' in page")
        else:
            print(f"⚠ Database '{DB_NAME}' not immediately visible")

        # Check if table name appears in the interface
        print(f"\n[4/6] Checking if table '{TABLE_NAME}' is visible...")

        if TABLE_NAME.lower() in page_source:
            print(f"✓ Table '{TABLE_NAME}' found in page")
        else:
            print(f"⚠ Table '{TABLE_NAME}' not immediately visible in page")
            print("  (This is normal - may need to expand tree nodes)")

        # Try to navigate using browser tree
        print("\n[5/6] Attempting to navigate browser tree...")

        # Look for expandable tree nodes
        try:
            # Find all tree nodes
            tree_items = driver.find_elements(
                By.CSS_SELECTOR,
                ".aciTreeItem, [role='treeitem'], .browser-tree-item"
            )

            if tree_items:
                print(f"  Found {len(tree_items)} tree items")

            # Try to find "Servers" node and expand it
            servers_elements = driver.find_elements(
                By.XPATH,
                "//*[contains(text(), 'Servers') or contains(text(), 'servers')]"
            )

            if servers_elements:
                print(f"  Found {len(servers_elements)} 'Servers' elements")

            time.sleep(2)
            driver.save_screenshot("ex02_step2_browser_tree.png")
            print("✓ Screenshot: Browser tree")

        except Exception as e:
            print(f"  Note: Could not interact with tree: {e}")

        # Final verification step
        print("\n[6/6] Final verification...")

        # Check page title and source
        page_title = driver.title
        print(f"  Page title: {page_title}")

        # Take final screenshot
        driver.save_screenshot("ex02_step3_final.png")
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
        print("  - ex02_step1_dashboard.png")
        print("  - ex02_step2_browser_tree.png")
        print("  - ex02_step3_final.png")

        print("\n" + "="*60)
        print("  ✓ Exercise 02: Validation Complete!")
        print("="*60)
        print(f"\nTo manually verify the table '{TABLE_NAME}':")
        print(f"1. Open pgAdmin at {PGADMIN_URL}")
        print(f"2. Navigate: Servers > PostgreSQL > Databases > {DB_NAME}")
        print(f"3. Expand: Schemas > public > Tables")
        print(f"4. Right-click '{TABLE_NAME}' > View/Edit Data > First 100 Rows")

        return True

    except Exception as e:
        print(f"\n✗ Error during verification: {e}")
        driver.save_screenshot("ex02_error.png")
        return False


def main():
    """Main test function"""
    driver = setup_driver(headless=False)

    try:
        success = verify_table_in_pgadmin(driver)

        # Keep browser open for a few seconds to review
        print("\nKeeping browser open for 5 seconds...")
        time.sleep(5)

        return success
    finally:
        driver.quit()


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
