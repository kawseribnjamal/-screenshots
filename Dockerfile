FROM python:3.10-slim

WORKDIR /app
COPY . /app

# Install necessary tools and dependencies
RUN apt-get update && apt-get install -y \
    wget gnupg curl unzip fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 \
    libcups2 libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 \
    xdg-utils libu2f-udev libvulkan1 libdrm2 libgbm1 libgtk-3-0 chromium \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome and Chromedriver manually (fixed version)
RUN wget https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_122.0.6261.57-1_amd64.deb \
    && apt install -y ./google-chrome-stable_122.0.6261.57-1_amd64.deb \
    && rm google-chrome-stable_122.0.6261.57-1_amd64.deb

RUN wget https://chromedriver.storage.googleapis.com/122.0.6261.57/chromedriver_linux64.zip \
    && unzip chromedriver_linux64.zip -d /usr/local/bin/ \
    && rm chromedriver_linux64.zip

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

EXPOSE 8080

CMD ["gunicorn", "app:app", "--bind=0.0.0.0:8080", "--timeout", "120"]
