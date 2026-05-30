FROM docker.io/rust:1.96.0-alpine3.23 AS builder

ARG VERSION

ENV CARGO_HOME=/cargo-cache/cargo
ENV CARGO_TARGET_DIR=/cargo-cache/target
ENV RUSTC_WRAPPER=sccache
ENV SCCACHE_DIR=/cargo-cache/sccache
ENV SCCACHE_CACHE_SIZE=3G
ENV SCCACHE_IDLE_TIMEOUT=0

RUN apk add --no-cache \
    build-base \
    pkgconf \
    git \
    perl \
    openssl-dev \
    libcap-dev \
    libcap-static \
    python3 \
    sccache

WORKDIR /build

RUN wget -qO - https://github.com/openai/codex/archive/refs/tags/${VERSION}.tar.gz | \
    tar xz -f - --strip-components=1

COPY codex-bind.patch ./codex-bind.patch
RUN git apply codex-bind.patch

COPY setup-alpine-rusty-v8.sh ./setup-alpine-rusty-v8.sh
RUN ./setup-alpine-rusty-v8.sh

RUN sccache --start-server && \
    trap 'sccache --show-stats || true ; sccache --stop-server || true' EXIT && \
    (sccache --zero-stats || true) && \
    cargo build --manifest-path=codex-rs/cli/Cargo.toml --release && \
    cp /cargo-cache/target/release/codex /codex


FROM scratch AS main

COPY --from=builder /codex /codex
