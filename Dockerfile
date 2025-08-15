# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20250317-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.18.3-erlang-27.3-debian-bullseye-20250317-slim
#
ARG ELIXIR_VERSION="1.18.3"
ARG OTP_VERSION="27.3"
ARG DEBIAN_VERSION="bullseye-20250317-slim"
ARG NODEJS_VERSION="22.17-bullseye"
ARG RUST_VERSION="1.88-bullseye"

ARG BUILDER_IMAGE_NODEJS="node:${NODEJS_VERSION}"
ARG BUILDER_IMAGE_TECTONIC="rust:${RUST_VERSION}"
ARG BUILDER_IMAGE_ELIXIR="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

ARG TECTONIC_VERSION="0.15.0"

FROM ${BUILDER_IMAGE_NODEJS} as builder_js

RUN mkdir -p /app/assets
WORKDIR /app

COPY assets/package.json assets/package-lock.json ./assets/

RUN cd assets && npm ci

FROM ${BUILDER_IMAGE_TECTONIC} as builder_tectonic

WORKDIR "/app"

RUN apt-get update && apt-get install -y \
  libfontconfig1-dev \
  libgraphite2-dev \
  libharfbuzz-dev \
  libicu-dev \
  zlib1g-dev

RUN cargo install --git https://github.com/ChillyBwoy/tectonic --rev 6933a8ced7abcf55c5dc3fa86e51104471b82a52 tectonic

COPY priv/data/sample.tex sample.tex

RUN tectonic --keep-intermediates --reruns 0 sample.tex

FROM ${BUILDER_IMAGE_ELIXIR} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

COPY --from=builder_js /app/assets/node_modules ./assets/node_modules

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

ENV TZ=""
ENV PHX_PORT=""
ENV PHX_HOST="127.0.0.1"
ENV SECRET_KEY_BASE=""
ENV DATABASE_URL="ecto://username:password@host:port/database"
ENV AUTH_GITHUB_CLIENT_ID=""
ENV AUTH_GITHUB_CLIENT_SECRET=""
ENV AUTH_GOOGLE_CLIENT_ID=""
ENV AUTH_GOOGLE_CLIENT_SECRET=""

RUN apt-get update -y && apt-get install -y --no-install-recommends \
  libstdc++6 \
  openssl \
  libncurses5 \
  locales \
  ca-certificates \
  libfontconfig1 \
  libgraphite2-3 \
  libharfbuzz0b \
  libicu67 \
  zlib1g \
  libharfbuzz-icu0 \
  libssl1.1 \
  ca-certificates \
  && apt-get clean && rm -rf /var/lib/apt/lists/* 


# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN adduser --disabled-password --gecos "" simplecv

WORKDIR "/app"
RUN chown simplecv:simplecv /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=simplecv:simplecv /app/_build/${MIX_ENV}/rel/modern_resume ./

# copy tectonic binary to new image
COPY --from=builder_tectonic --chown=simplecv:simplecv /usr/local/cargo/bin/tectonic /usr/bin/
COPY --from=builder_tectonic --chown=simplecv:simplecv /root/.cache/Tectonic/ /home/simplecv/.cache/Tectonic/

USER simplecv

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]

CMD ["/app/bin/server"]
