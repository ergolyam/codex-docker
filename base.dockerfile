FROM docker.io/rust:slim-trixie AS builder

RUN apt-get update -y
RUN apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        git \
        perl \
        libssl-dev
RUN rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/openai/codex -b rust-v0.77.0 /build

WORKDIR /build

RUN cargo build --manifest-path=codex-rs/cli/Cargo.toml --release


FROM scratch as base

COPY --from=builder /build/codex-rs/target/release/codex /usr/bin/codex
