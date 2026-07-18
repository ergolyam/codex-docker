#!/usr/bin/env sh

set -eu

PACKAGES="ca-certificates bubblewrap ripgrep git"

if command -v apk; then
  apk add --no-cache ${PACKAGES}
elif command -v apt-get; then
  apt-get update
  apt-get install -y --no-install-recommends ${PACKAGES} wget
  rm -rf /var/lib/apt/lists/*
elif command -v dnf; then
  dnf install -y ${PACKAGES} wget tar gzip
  dnf clean all
elif command -v xbps-install; then
  xbps-install -SyuM -y ${PACKAGES}
  rm -rf /var/cache/xbps/*
else
  echo "Unsupported distro"
  exit 1
fi

echo "Cleaning up: removing $0"
rm -f -- "$0"
