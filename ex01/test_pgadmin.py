#!/usr/bin/env python3
"""
Exercise 01: pgAdmin Database Visualization Test
Selenium test to validate pgAdmin is accessible and functional
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

# pgAdmin configuration (from .env)
PGADMIN_URL = "http://localhost:5050"
PGADMIN_EMAIL = "admin@admin.com"
PGADMIN_PASSWORD = "admin"

# Database configuration
DB_NAME = "piscineds"
DB_USER = "asoler"
DB_PASSWORD = "mysecretpassword"
DB_HOST = "postgres_db"
DB_PORT = "5432"


def setup_driver(headless=True):
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


def test_pgadmin_access():
    """Test pgAdmin web interface accessibility and login"""

    print("\n" + "="*60)
    print("  Exercise 01: pgAdmin Accessibility Test")
    print("="*60)

    driver = setup_driver(headless=True)

    try:
        # Step 1: Navigate to pgAdmin
        print(f"\n[1/4] Connecting to pgAdmin at {PGADMIN_URL}...")
        driver.get(PGADMIN_URL)

        # Wait for login page
        print("[2/4] Waiting for login page...")
        email_field = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.NAME, "email"))
        )
        print("✓ pgAdmin login page loaded")

        # Step 2: Login
        print(f"\n[3/4] Logging in as {PGADMIN_EMAIL}...")
        password_field = driver.find_element(By.NAME, "password")

        email_field.clear()
        email_field.send_keys(PGADMIN_EMAIL)
        password_field.clear()
        password_field.send_keys(PGADMIN_PASSWORD)

        # Submit form
        password_field.submit()

        # Wait for dashboard
        print("[4/4] Waiting for dashboard to load...")
        time.sleep(5)

        # Check for successful login (look for pgAdmin interface elements)
        try:
            # Wait for browser tree or any pgAdmin element
            WebDriverWait(driver, 10).until(
                lambda d: "browser" in d.page_source.lower() or
                          "dashboard" in d.page_source.lower() or
                          "server" in d.page_source.lower()
            )
            print("✓ Successfully logged into pgAdmin")

            # Take screenshot
            screenshot_path = "ex01_pgadmin_dashboard.png"
            driver.save_screenshot(screenshot_path)
            print(f"✓ Screenshot saved: {screenshot_path}")

            print("\n" + "="*60)
            print("  ✓ Exercise 01: All tests passed!")
            print("="*60)
            print(f"\npgAdmin is accessible at: {PGADMIN_URL}")
            print(f"Credentials: {PGADMIN_EMAIL} / {PGADMIN_PASSWORD}")
            print("\nYou can now use pgAdmin to visualize your databases.")

            return True

        except Exception as e:
            print(f"✗ Failed to verify dashboard: {e}")
            driver.save_screenshot("ex01_error.png")
            return False

    except Exception as e:
        print(f"✗ Error: {e}")
        driver.save_screenshot("ex01_error.png")
        return False

    finally:
        driver.quit()


if __name__ == "__main__":
    success = test_pgadmin_access()
    sys.exit(0 if success else 1)
