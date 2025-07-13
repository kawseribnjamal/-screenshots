FROM python:3.10-slim

WORKDIR /app
COPY . /app

RUN apt-get update && apt-get install -y wget gnupg2 unzip curl fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 \
    libcups2 libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 \
    xdg-utils libu2f-udev libvulkan1 libdrm2 libgbm1 libgtk-3-0

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable

RUN wget -q "https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip" && \
    unzip chromedriver_linux64.zip -d /usr/local/bin/ && rm chromedriver_linux64.zip

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

EXPOSE 8080

CMD ["gunicorn", "app:app", "--bind=0.0.0.0:8080", "--timeout", "120"]
