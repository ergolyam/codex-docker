FROM ${BASE_IMAGE} as main

COPY install-deps.sh ./install-deps.sh
RUN ./install-deps.sh ${DIST} main

COPY --from=ghcr.io/ergolyam/codex-docker:base /usr/bin/codex /usr/bin

ENV CODEX_HOME=/data

WORKDIR /work

CMD [ "codex" ]
