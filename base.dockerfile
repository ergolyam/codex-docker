FROM docker.io/rust:alpine3.23 AS builder

ARG VERSION

ENV CARGO_HOME=/cargo-cache/cargo
ENV CARGO_TARGET_DIR=/cargo-cache/target

RUN apk add --no-cache \
    build-base \
    pkgconf \
    git \
    perl \
    openssl-dev \
    libcap-dev \
    libcap-static \
    python

WORKDIR /build

RUN wget -qO - https://github.com/openai/codex/archive/refs/tags/${VERSION}.tar.gz | \
    tar xzv -f - --strip-components=1

COPY codex-bind.patch ./codex-bind.patch
RUN git apply codex-bind.patch

COPY setup-alpine-rusty-v8.sh ./setup-alpine-rusty-v8.sh
RUN ./setup-alpine-rusty-v8.sh

RUN cargo build --manifest-path=codex-rs/cli/Cargo.toml --release


FROM scratch AS main

COPY --from=builder /cargo-cache/target/release/codex /codex
