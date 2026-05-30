FROM docker.io/rust:1.95.0-alpine3.23 AS builder

ARG VERSION

ENV CARGO_HOME=/cargo-cache/cargo
ENV CARGO_TARGET_DIR=/cargo-cache/target
ENV CARGO_PROFILE_RELEASE_LTO=false
ENV CARGO_PROFILE_RELEASE_CODEGEN_UNITS=16
ENV RUSTC_WRAPPER=sccache
ENV SCCACHE_DIR=/cargo-cache/sccache
ENV SCCACHE_CACHE_SIZE=3G

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

RUN cargo build --manifest-path=codex-rs/cli/Cargo.toml --release \
    && sccache --show-stats \
    && cp /cargo-cache/target/release/codex /codex


FROM scratch AS main

COPY --from=builder /codex /codex
