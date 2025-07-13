from flask import Flask, render_template, request
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import time
import os

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/run', methods=['POST'])
def run_bot():
    roll_numbers = request.form['rolls'].strip().split('\n')

    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.binary_location = "/usr/bin/chromium"

    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    url = "https://sresult.bise-ctg.gov.bd/rxto2025/individual/"

    screenshot_paths = []
    folder_path = os.path.join('static', 'screenshots')
    os.makedirs(folder_path, exist_ok=True)

    for roll in roll_numbers:
        roll = roll.strip()
        if not roll:
            continue
        try:
            driver.get(url)
            time.sleep(2)

            input_box = driver.find_element(By.ID, "roll")
            input_box.clear()
            input_box.send_keys(roll)

            submit_btn = driver.find_element(By.ID, "button2")
            submit_btn.click()
            time.sleep(2)

            total_height = driver.execute_script("return document.body.scrollHeight")
            driver.set_window_size(1200, total_height)
            time.sleep(1)

            screenshot_file = f"{roll}_result.png"
            screenshot_path = os.path.join(folder_path, screenshot_file)
            driver.save_screenshot(screenshot_path)
            screenshot_paths.append(f"/static/screenshots/{screenshot_file}")

        except Exception as e:
            print(f"❌ Error for roll {roll}: {e}")

    driver.quit()
    return render_template("index.html", screenshots=screenshot_paths)

if __name__ == '__main__':
    app.run(debug=True)
