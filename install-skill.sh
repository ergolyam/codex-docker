#!/usr/bin/env sh

set -eu

: "${DISTRO:?DISTRO build argument is required}"

case "${DISTRO}" in
  alpine|void|debian|fedora|nix)
    ;;
  *)
    echo "Unsupported DISTRO: ${DISTRO}" >&2
    exit 1
    ;;
esac

SKILL_DIR="/etc/codex/skills/container-package-management"
SKILL_TEMPLATE="${SKILL_DIR}/SKILL.md.template"
SKILL_FILE="${SKILL_DIR}/SKILL.md"

sed "s/@DISTRO@/${DISTRO}/g" "${SKILL_TEMPLATE}" > "${SKILL_FILE}"
rm -f -- "${SKILL_TEMPLATE}"

echo "Cleaning up: removing $0"
rm -f -- "$0"
