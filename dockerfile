ARG FINAL_IMAGE
FROM ${FINAL_IMAGE} as main

ARG BASE_IMAGE

COPY install-deps.sh ./install-deps.sh
RUN ./install-deps.sh

COPY --from=${BASE_IMAGE} /codex /usr/local/bin/codex

COPY rootfs /

ARG TARGETARCH
RUN wget -O- https://github.com/podman-container-tools/podman/releases/download/v5.8.4/podman-remote-static-linux_${TARGETARCH}.tar.gz | \
    tar -xOz "bin/podman-remote-static-linux_${TARGETARCH}" > /usr/local/bin/podman-remote && \
    chmod +x /usr/local/bin/podman-remote

ENV CODEX_HOME=/data

WORKDIR /work

ENTRYPOINT [ "/usr/local/bin/codex" ]
