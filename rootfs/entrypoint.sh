#!/bin/sh
set -eu

INIT_SCRIPT=/work/.codex-container-init.sh

if [ -f "${INIT_SCRIPT}" ]; then
    echo "Running container init: ${INIT_SCRIPT}"
    /bin/sh "${INIT_SCRIPT}"
fi

exec /usr/bin/codex "$@"
