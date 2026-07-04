# syntax=docker/dockerfile:1

ARG baseimage=debian:trixie-slim
FROM ${baseimage} AS builder-stage

ARG buildoptions

# workaround for memory bug https://github.com/rust-lang/cargo/issues/10583
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
  set -eu

  apt-get update
  apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    sudo \
    git \
    lintian \
    pkg-config \
    libudev-dev \
    libssl-dev \
    libapt-pkg-dev \
    libclang-dev \
    libpam0g-dev \
    zlib1g-dev \
    nettle-dev

  # Install Rust
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
EOF

COPY . /build/
WORKDIR /build

SHELL ["/bin/bash", "-c"]
RUN chmod +x ./build.sh
RUN source ~/.cargo/env && ./build.sh ${buildoptions}
RUN touch /build/build.log

FROM scratch
COPY --from=builder-stage /build/*.log /build/packages/* /
