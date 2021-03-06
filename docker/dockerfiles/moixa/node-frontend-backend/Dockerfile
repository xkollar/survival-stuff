FROM ubuntu:18.04

RUN true \
    && sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\/\?\s/mirror:\/\/mirrors.ubuntu.com\/mirrors.txt /' /etc/apt/sources.list \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        bc \
        build-essential \
        curl \
        daemontools \
        docker.io \
        gawk \
        git \
        grep \
        gnupg \
        jq \
        less \
        libasound2 \
        libgtk-3-0 \
        libnss3 \
        libx11-xcb1 \
        libxss1 \
        libxtst6 \
        man \
        python3 \
        python3-pip \
        python3-setuptools \
        python-dev \
        rsync \
        screen \
        unzip \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && echo "deb https://deb.nodesource.com/node_12.x xenial main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
        nodejs \
    && pip3 install --upgrade \
        pip \
        pyyaml \
        awscli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && npm install --global yarn@1.22.0 \
    && yarn global add \
        pnpm@3.8.1 \
        serverless \
    && yarn cache clean

CMD ["/bin/bash"]
