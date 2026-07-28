# codex-docker
This project builds a **small container image for the Codex CLI** (from the official `openai/codex` repo) and ships it as a runnable appliance. It uses a multi-stage build to compile the Rust CLI and keeps the runtime slim (just the binary + CA certs).

## Use from registry

- Pull the published image:
    ```bash
    docker pull ghcr.io/ergolyam/codex-docker:latest
    ```

- Run it (mount your workspace + state):
    ```bash
    docker run -it --rm \
      -v "${PWD}":/work \
      -v codex-data:/data \
      -p 127.0.0.1:1455:1455 \
      ghcr.io/ergolyam/codex-docker:latest
    ```
    - The container starts `codex` by default, so you drop straight into the CLI.
    - Use `:void`, `:debian`, `:fedora` if you prefer those base layers.

## Build & run locally

- Build the Codex binary layer:
    ```bash
    docker build -t codex-base \
      --build-arg VERSION=rust-v0.80.0 \
      -f base.dockerfile .
    ```

- Build the runnable image:
    ```bash
    docker build -t codex-cli \
      --build-arg FINAL_IMAGE=alpine:3.24 \
      --build-arg BASE_IMAGE=codex-base \
      --build-arg DISTRO=alpine \
      -f dockerfile .
    ```

- Build with a different base distro:
    ```bash
    docker build -t codex-cli \
      --build-arg FINAL_IMAGE=debian:trixie-slim \
      --build-arg BASE_IMAGE=codex-base \
      --build-arg DISTRO=debian \
      -f dockerfile .
    ```

- Run it (mount your workspace + state):
    ```bash
    docker run -it --rm \
      -v "${PWD}":/work \
      -v codex-data:/data \
      -p 127.0.0.1:1455:1455 \
      codex-cli
    ```
    - The container starts `codex` by default, so you drop straight into the CLI.

## Build arguments

| Argument      | Description                                                                    |
|---------------|--------------------------------------------------------------------------------|
| `FINAL_IMAGE` | Runtime image (minimal OS for the final layer).                                |
| `BASE_IMAGE`  | Image that provides the compiled `/codex` binary.                              |
| `DISTRO`      | Runtime distribution: `alpine`, `void`, `debian`, or `fedora`.                 |
| `VERSION`     | Upstream `openai/codex` tag to build (example: `rust-v0.80.0`).                |

## Environment Variables

| Variable     | Description                                                     |
|--------------|-----------------------------------------------------------------|
| `CODEX_HOME` | Set to `/data` inside the image (Codex state/config directory). |

## Features

- **Slim runtime**: only the Codex binary and CA certificates in the final stage.
- **Multi‑distro builds**: Alpine, Void, Debian, and Fedora supported via build args.
- **Multi‑arch publishing**: GitHub Actions builds and publishes amd64 + arm64 manifests.
- **Pinned upstream**: builds from `openai/codex` at `rust` plus a local patch.
