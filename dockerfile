ARG FINAL_IMAGE
ARG SSH_VERSION=10.4p1

FROM docker.io/alpine:3.24 AS builder_ssh

ARG SSH_VERSION

RUN apk add --no-cache \
    gcc \
    make \
    musl-dev \
    openssl-dev \
    openssl-libs-static \
    zlib-dev \
    zlib-static

WORKDIR /build

RUN wget -qO - https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${SSH_VERSION}.tar.gz | tar xz -f - --strip-components=1

ENV CC=gcc
ENV LD="${CC}"
ENV CFLAGS="-Os -pipe -ffunction-sections -fdata-sections"
ENV LDFLAGS="-static -Wl,--gc-sections"

RUN ./configure \
        --prefix=/usr \
        --bindir=/usr/local/bin \
        --sysconfdir=/etc/ssh \
        --libexecdir=/usr/lib/ssh \
        --with-ssl-dir=/usr \
        --with-zlib=/usr \
        --without-pam \
        --without-kerberos5 \
        --without-libedit \
        --disable-utmp \
        --disable-wtmp \
        --disable-lastlog \
        --disable-strip \
        --with-cflags="${CFLAGS}" \
        --with-ldflags="${LDFLAGS}"

RUN make -j"$(nproc)" ssh scp && \
    strip --strip-unneeded ./ssh ./scp && \
    install -Dm755 ./ssh /out/ssh && \
    install -Dm755 ./scp /out/scp


FROM ${FINAL_IMAGE} as main

ARG BASE_IMAGE

COPY install-deps.sh ./install-deps.sh
RUN ./install-deps.sh

COPY --from=${BASE_IMAGE} /codex /usr/local/bin/codex
COPY --from=builder_ssh /out/ /usr/local/bin/

ARG TARGETARCH
RUN wget -O- https://github.com/podman-container-tools/podman/releases/download/v5.8.4/podman-remote-static-linux_${TARGETARCH}.tar.gz | \
    tar -xOz "bin/podman-remote-static-linux_${TARGETARCH}" > /usr/local/bin/podman-remote && \
    chmod +x /usr/local/bin/podman-remote

COPY rootfs /

ENV CODEX_HOME=/data

WORKDIR /work

ENTRYPOINT [ "/usr/local/bin/codex" ]
