ARG FINAL_IMAGE
FROM ${FINAL_IMAGE} as main

ARG BASE_IMAGE

COPY install-deps.sh ./install-deps.sh
RUN ./install-deps.sh

COPY --from=${BASE_IMAGE} /codex /usr/bin/codex

COPY rootfs /

ENV CODEX_HOME=/data

WORKDIR /work

ENTRYPOINT [ "/usr/bin/codex" ]
