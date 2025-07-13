FROM python:3.10-slim

WORKDIR /app
COPY . /app

RUN apt-get update && apt-get install -y \
    wget gnupg unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome & ChromeDriver
RUN wget -q -O google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update && apt-get install -y ./google-chrome.deb \
    && rm google-chrome.deb \
    && CHROME_VERSION=$(google-chrome --product-version | cut -d. -f1-3) \
    && wget -q "https://chromedriver.storage.googleapis.com/${CHROME_VERSION}/chromedriver_linux64.zip" \
    && unzip chromedriver_linux64.zip -d /usr/local/bin/ \
    && rm chromedriver_linux64.zip

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

EXPOSE 8080
CMD ["gunicorn", "app:app", "--bind=0.0.0.0:8080", "--timeout", "120"]
