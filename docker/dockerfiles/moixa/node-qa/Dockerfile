FROM node:slim

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        bc \
        ca-certificates \
        curl \
        fonts-liberation \
        gconf-service \
        git \
        jq \
        libappindicator3-1 \
        libasound2 \
        libatk1.0-0 \
        libatk1.0-0 \
        libdbus-1-3 \
        libgconf-2-4 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libx11-xcb1 \
        libxss1 \
        libxtst6 \
        lsb-release \
        man \
        python-pip \
        python-setuptools \
        python-wheel \
        wget \
        xdg-utils \
        xz-utils \
    && apt-get install -f \
    && apt-get clean autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && pip install awscli \
    && npm install -g yarn
