#!/usr/bin/env sh

DISTRO="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"

case "${DISTRO}" in
    alpine)
      apk add --no-cache \
        build-base \
        git \
        perl \
        openssl-dev \
        ca-certificates || exit 1
      ;;
    debian)
      apt-get update -y
      apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        git \
        perl \
        libssl-dev \
        ca-certificates || exit 1
      rm -rf /var/lib/apt/lists/*
      ;;
esac

echo "Cleaning up: removing $0"
rm -f -- "$0"
