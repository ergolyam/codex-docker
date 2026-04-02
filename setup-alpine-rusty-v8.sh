#!/usr/bin/env sh

set -eu

arch="$(uname -m)"

case "${arch}" in
    x86_64)
        target="x86_64-unknown-linux-musl"
        ;;
    aarch64|arm64)
        target="aarch64-unknown-linux-musl"
        ;;
    *)
        echo "Unsupported alpine builder arch: ${arch}" >&2
        exit 1
        ;;
esac

v8_version="$(sed -n 's/^v8 = "=\([^"]*\)"$/\1/p' codex-rs/Cargo.toml)"

if [ -z "${v8_version}" ]; then
    echo "Failed to detect v8 version from codex-rs/Cargo.toml" >&2
    exit 1
fi

binding="/tmp/src_binding_release_${target}.rs"
config_dir=".cargo"
config_file="${config_dir}/config.toml"

python3 -c "from urllib.request import urlretrieve; urlretrieve('https://github.com/openai/codex/releases/download/rusty-v8-v${v8_version}/src_binding_release_${target}.rs', '${binding}')"

mkdir -p "${config_dir}"

cat <<EOF >> "${config_file}"

[env]
RUSTY_V8_ARCHIVE = "https://github.com/openai/codex/releases/download/rusty-v8-v${v8_version}/librusty_v8_release_${target}.a.gz"
RUSTY_V8_SRC_BINDING_PATH = "${binding}"
EOF
