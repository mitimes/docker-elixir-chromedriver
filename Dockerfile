FROM elixir:1.8-otp-22

#
#
# Add Elixir tools hex and rebar
# ... and libs required when building code from Elixir packages
# ... and netcat for scripts
#
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    unzip curl wget git make build-essential libfontconfig1 \
    erlang-tools netcat

RUN mix do \
  local.hex --force, \
  local.rebar --force

#
#
# Install node
#
#
# Node.js and NPM in order to satisfy brunch.io dependencies
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt-get install -y inotify-tools nodejs

# Create a default user
RUN useradd automation --shell /bin/bash --create-home

RUN \
  npm config set user 0 && \
  npm config set unsafe-perm true && \
  npm install -g yarn


#
#
# Set the locale
#
#
run apt-get install -y locales
RUN sed -i -e 's/# \(en_AU\.UTF-8 .*\)/\1/' /etc/locale.gen && \
    locale-gen en_AU.UTF-8
ENV LANG en_AU.UTF-8
ENV LANGUAGE en_AU:en
ENV LC_ALL en_AU.UTF-8


#
#
# Cypress dependencies (including xvfb)
#
#
RUN apt-get install -y \
  xvfb \
  libgtk2.0-0 libgtk-3-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2

#
#
# INSTALL CHROME
#
#

# Install Chrome WebDriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    rm /tmp/chromedriver_linux64.zip && \
    chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver && \
    ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver

# Install Google Chrome
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get -yqq update && \
    apt-get -yqq install google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Seems to be required or ELM builds can fail with
#    FailedConnectionException2 "github.com" 443 True getProtocolByName: does not exist (no such protocol name: tcp)
RUN apt-get -yqq install netbase

WORKDIR /app
