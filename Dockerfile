# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian instead of
# Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20220801-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.14.1-erlang-25.1.1-debian-bullseye-20220801-slim
#
ARG ELIXIR_VERSION=1.14.1
ARG OTP_VERSION=25.1.1
ARG DEBIAN_VERSION=bullseye-20220801-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y \
    && apt-get install -y build-essential git \
    && apt-get clean \
    && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force \
    && mix local.rebar --force

# make umbrella app directories
RUN mkdir -p apps/hello apps/hello_web

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock       ./
COPY apps/hello/mix.exs     apps/hello/
COPY apps/hello_web/mix.exs apps/hello_web/
RUN mix deps.get --only $MIX_ENV

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
RUN mkdir config
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Copy all umbrella apps/ elixir code
COPY apps/hello apps/hello/
COPY apps/hello_web apps/hello_web/

# compile assets
WORKDIR /app/apps/hello_web
RUN mix assets.deploy \
    && mix phx.gen.release

# Compile the release
WORKDIR /app
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

RUN cp -R apps/hello_web/rel ./ \
    && mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y \
    && apt-get install -y libstdc++6 openssl libncurses5 locales \
    && apt-get clean \
    && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    MIX_ENV=prod \
    PHX_SERVER=true \
    PORT=443

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/hello_web ./

USER nobody

CMD ["/app/bin/server"]