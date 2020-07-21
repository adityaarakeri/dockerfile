#############
# BASE
#############

FROM debian:buster-slim AS base
LABEL maintaner="Aditya Arakeri <aditya005@gmail.com>"

# lts version of nodejs
ENV NODE_VERSION setup_12.x

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install the base requirements
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install --no-install-recommends --no-install-suggests -y \
    xvfb \
    xauth \
    ca-certificates \
    x11vnc \
    fluxbox \
    rxvt-unicode \
    curl \
    gcc \
    g++ \
    make \
    netcat \
  # Remove obsolete files:
    && apt-get clean \
    && rm -rf \
    /tmp/* \
    /usr/share/doc/* \
    /var/cache/* \
    /var/lib/apt/lists/* \
    /var/tmp/*
  
WORKDIR /home/webdriver

RUN curl -sL https://deb.nodesource.com/$NODE_VERSION -o nodesource_setup.sh \
    && bash nodesource_setup.sh \
RUN apt update \
    && apt install --no-install-recommends --no-install-suggests -y \
    nodejs \
    # smoke tests
    && node --version \
    && npm --version


# create a webdriver user
RUN useradd -u 1000 -m -U webdriver
WORKDIR /home/webdriver
RUN usermod -s /bin/bash webdriver

# needed scripts on the base
COPY entrypoint.sh /usr/local/bin/entrypoint
COPY vnc-start.sh /usr/local/bin/vnc-start
COPY wait-for-hosts.sh /usr/local/bin/wait-for-hosts


ENTRYPOINT [ "/bin/bash" ]

##############
# CHROMEDRIVER
##############

FROM base AS chromedriver
LABEL maintaner="Aditya Arakeri <aditya005@gmail.com>"

# Install the latest versions of Google Chrome and Chromedriver:
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
    unzip \
    gnupg \
  && GOOGLE_LINUX_DL=https://dl.google.com/linux \
  && curl -sL "$GOOGLE_LINUX_DL/linux_signing_key.pub" | apt-key add - \
  && curl -sL "$GOOGLE_LINUX_DL/direct/google-chrome-stable_current_amd64.deb" \
    > /tmp/chrome.deb \
  && apt install --no-install-recommends --no-install-suggests -y \
    /tmp/chrome.deb \
  && CHROMIUM_FLAGS='--no-sandbox --disable-dev-shm-usage' \
  # Patch Chrome launch script and append CHROMIUM_FLAGS to the last line:
  && sed -i '${s/$/'" $CHROMIUM_FLAGS"'/}' /opt/google/chrome/google-chrome \
  && BASE_URL=https://chromedriver.storage.googleapis.com \
  && VERSION=$(curl -sL "$BASE_URL/LATEST_RELEASE") \
  && curl -sL "$BASE_URL/$VERSION/chromedriver_linux64.zip" -o /tmp/driver.zip \
  && unzip /tmp/driver.zip \
  && chmod 755 chromedriver \
  && mv chromedriver /usr/local/bin/ \
  # Remove obsolete files:
  && apt-get autoremove --purge -y \
    unzip \
    gnupg \
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /usr/share/doc/* \
    /var/cache/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# Patch xvfb-run to support TCP port listening (disabled by default):
RUN sed -i 's/LISTENTCP=""/LISTENTCP="-listen tcp"/' /usr/bin/xvfb-run

# Configure Xvfb via environment variables:
ENV SCREEN_WIDTH 1440
ENV SCREEN_HEIGHT 900
ENV SCREEN_DEPTH 24
ENV DISPLAY :0

USER webdriver

ENTRYPOINT ["entrypoint", "chromedriver"]

CMD ["--port=4444", "--whitelisted-ips="]

EXPOSE 4444
