---
name: container-init-persistence
description: Use only when the user explicitly asks to create or update the project init script that restores container setup. Do not use automatically.
---

# Container init persistence

Use this skill only on explicit user request.
This skill creates or updates a project-owned POSIX shell script that is executed by the container entrypoint before Codex starts.

## Init script

- Default path: `/work/.codex-container-init.sh`.
- The script must be POSIX `sh` compatible.
- The script must be idempotent and non-interactive.
- Do not store secrets, tokens, private keys, or credentials in the script.
- Do not snapshot container state; write reproducible setup steps only.

## Required workflow

- Before creating or updating the script, inspect the current project files and the existing init script if present.
- Record only setup that is required to resume work on this project.
- Avoid duplicate setup steps; update existing commands instead of appending copies.
- Preserve user-written sections unless they conflict with the required setup.
- Keep the script minimal and deterministic.
- Do not use `shell-execution-policy`, as this involves working with a script rather than executing commands in a shell/terminal

## External files

- Store the files required to recreate the configuration in the `/work/.codex-container/` directory.
- Recreate external paths from those files during init.
- Use `mkdir -p`, `cp`, `chmod`, and redirection instead of non-POSIX helpers.
- Do not persist caches, temporary files, package databases, build outputs, or logs.

## OS packages

- For OS-level packages, use `container-package-management` first.
- Do not hard-code a package manager until the container OS has been inspected.
- Use package names verified for the current distribution.
- Make package installation safe to run repeatedly.

## Script format

- Use this header:
```sh
#!/bin/sh
set -eu
```

- Use functions for repeated setup steps.
- Use `command -v` and file existence checks before changing the system.
- Use absolute paths for files outside the project.
- Keep project-relative paths rooted in `/work`.

## Validation

- After writing the script, check POSIX shell syntax:
```sh
sh -n /work/.codex-container-init.sh
```

- Do not execute the script unless the user explicitly asks, or execution is required to validate the saved setup.
- Report the script path and the saved setup steps.
