ARG DIST=alpine
ARG BUILD_IMAGE=rust:alpine
ARG BASE_IMAGE=alpine:latest
ARG CODEX_TAG=rust-v0.80.0

FROM ${BUILD_IMAGE} AS builder

ARG DIST
ARG CODEX_TAG

COPY install-deps.sh ./install-deps.sh
RUN ./install-deps.sh ${DIST} builder

RUN git clone https://github.com/openai/codex -b ${CODEX_TAG} /build

WORKDIR /build

COPY codex-bind.patch ./codex-bind.patch

RUN git apply codex-bind.patch

RUN cargo build --manifest-path=codex-rs/cli/Cargo.toml --release


FROM ${BASE_IMAGE} as main

COPY install-deps.sh ./install-deps.sh
RUN ./install-deps.sh ${DIST} main

COPY --from=builder /build/codex-rs/target/release/codex /usr/bin

ENV CODEX_HOME=/data

WORKDIR /work

ENTRYPOINT [ "/usr/bin/codex" ]
