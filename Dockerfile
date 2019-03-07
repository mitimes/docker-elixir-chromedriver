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

RUN apt-get install -y chromedriver chromium xvfb

WORKDIR /app
