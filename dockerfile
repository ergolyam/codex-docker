ARG DIST=alpine
ARG BUILD_IMAGE=rust:alpine
ARG BASE_IMAGE=alpine:latest
ARG CODEX_TAG=rust-v0.80.0

FROM ${BUILD_IMAGE} AS builder

ARG DIST
ARG CODEX_TAG

ENV CARGO_HOME=/cargo-cache/cargo
ENV CARGO_TARGET_DIR=/cargo-cache/target

COPY install-deps.sh ./install-deps.sh
RUN ./install-deps.sh ${DIST} builder

RUN git clone https://github.com/openai/codex -b ${CODEX_TAG} /build

WORKDIR /build

COPY codex-bind.patch ./codex-bind.patch

RUN git apply codex-bind.patch

RUN mkdir -p /build-out /cargo-cache/cargo /cargo-cache/target
RUN cargo build --manifest-path=codex-rs/cli/Cargo.toml --release
RUN cp /cargo-cache/target/release/codex /build-out/codex


FROM ${BASE_IMAGE} as main

ARG DIST

COPY install-deps.sh ./install-deps.sh
RUN ./install-deps.sh ${DIST} main

COPY --from=builder /build-out/codex /usr/bin

ENV CODEX_HOME=/data

WORKDIR /work

ENTRYPOINT [ "/usr/bin/codex" ]
