ARG DIST=alpine
ARG RUST_IMAGE=rust:alpine
ARG BASE_IMAGE=alpine:latest

FROM docker.io/${RUST_IMAGE} AS builder

ARG DIST

COPY install-deps.sh ./install-deps.sh
RUN ./install-deps.sh ${DIST} builder

RUN git clone https://github.com/openai/codex -b rust-v0.77.0 /build

WORKDIR /build

RUN cargo build --manifest-path=codex-rs/cli/Cargo.toml --release


FROM docker.io/${BASE_IMAGE} as main

COPY install-deps.sh ./install-deps.sh
RUN ./install-deps.sh ${DIST} main

COPY --from=builder /build/codex-rs/target/release/codex /usr/bin

ENV CODEX_HOME=/data

WORKDIR /work

CMD [ "codex" ]
