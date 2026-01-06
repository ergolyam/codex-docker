#!/usr/bin/env sh

DISTRO="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
TARGET="$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')"

case "${DISTRO}-${TARGET}" in
    alpine-builder)
      apk add --no-cache \
        build-base \
        pkgconf \
        git \
        perl \
        openssl-dev || exit 1
      ;;
    alpine-main)
      apk add --no-cache \
        ca-certificates || exit 1
      ;;
    debian-builder)
      apt-get update -y
      apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        git \
        perl \
        libssl-dev || exit 1
      rm -rf /var/lib/apt/lists/*
      ;;
    debian-main)
      apt-get update -y
      apt-get install -y --no-install-recommends \
        ca-certificates || exit 1
      rm -rf /var/lib/apt/lists/*
      ;;
esac

echo "Cleaning up: removing $0"
rm -f -- "$0"
