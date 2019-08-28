FROM elixir:1.8

# Update and install base tools & libs
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    unzip curl wget git make build-essential libfontconfig1 \
    erlang-tools

RUN mix do \
  local.hex --force, \
  local.rebar --force

#
#
# Install node
#
#
# Node.js (>= 8.0.0) and NPM in order to satisfy brunch.io dependencies
# See https://hexdocs.pm/phoenix/installation.html#node-js-5-0-0
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
  apt-get install -y inotify-tools nodejs

# Create a default user
RUN useradd automation --shell /bin/bash --create-home

RUN \
  npm config set user 0 && \
  npm config set unsafe-perm true && \
  npm install -g yarn

# Set the locale
run apt-get install -y locales

RUN sed -i -e 's/# \(en_AU\.UTF-8 .*\)/\1/' /etc/locale.gen && \
    locale-gen en_AU.UTF-8
ENV LANG en_AU.UTF-8
ENV LANGUAGE en_AU:en
ENV LC_ALL en_AU.UTF-8

# Second line are dependencies for Cypress + xvfb.
RUN apt-get install -y chromedriver chromium chromium-l10n xvfb \
  libgtk2.0-0 libgtk-3-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2

WORKDIR /app
