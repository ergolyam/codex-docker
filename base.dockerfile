FROM docker.io/rust:1.96.0-alpine3.23 AS builder

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
    python3 \
    sccache

WORKDIR /build

RUN wget -qO - https://github.com/openai/codex/archive/refs/tags/${VERSION}.tar.gz | \
    tar xz -f - --strip-components=1

COPY codex-bind.patch ./codex-bind.patch
RUN git apply codex-bind.patch

COPY setup-alpine-rusty-v8.sh ./setup-alpine-rusty-v8.sh
RUN ./setup-alpine-rusty-v8.sh

RUN cargo build --manifest-path=codex-rs/Cargo.toml \
        --release \
        -p codex-cli \
        -p codex-code-mode-host && \
    mkdir -p /out && \
    cp /cargo-cache/target/release/codex /out/codex && \
    cp /cargo-cache/target/release/codex-code-mode-host /out/codex-code-mode-host


FROM scratch AS main

COPY --from=builder /out /out
