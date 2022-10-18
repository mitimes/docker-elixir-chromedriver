FROM elixir:1.13.1
# Add Elixir tools hex and rebar
# ... and libs required when building code from Elixir packages
# ... and netcat for scripts
# ... postgresql-client for ecto.load sql schema
# ... netbase - for ELM builds, else fails withFailedConnectionException2 "github.com" 443 True getProtocolByName: does not exist (no such protocol name: tcp)
# ... locales - to allow setting locale
# ... xvfb (X11 display) and other bits for cypress
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    unzip curl wget git make build-essential libfontconfig1 \
    erlang-tools netcat \
    netbase \
    locales \
    xvfb libgtk2.0-0 libgtk-3-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2

RUN echo "ABC"

# Install postgresql client for load/dump
RUN curl -sS -o - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -  && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" >> /etc/apt/sources.list.d/pgdg.list && \
    apt-get -yqq update && \
    apt-get -yqq install postgresql-client-12 && \
    rm -rf /var/lib/apt/lists/*

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
RUN sed -i -e 's/# \(en_AU\.UTF-8 .*\)/\1/' /etc/locale.gen && \
    locale-gen en_AU.UTF-8
ENV LANG en_AU.UTF-8
ENV LANGUAGE en_AU:en
ENV LC_ALL en_AU.UTF-8

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


WORKDIR /app
