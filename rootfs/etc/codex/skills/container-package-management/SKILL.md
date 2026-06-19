---
name: container-package-management
description: Use whenever installing, removing, upgrading, or choosing OS-level packages inside the container. Do not use for language-specific package managers unless an OS package is required.
---

# Container package management

Use this skill for OS-level packages only.
Do not use this skill for language-specific package managers, unless an OS package is also required.

## Required workflow

- Before installing, removing, upgrading, or choosing OS packages, inspect the container OS:
```sh
cat /etc/os-release
```
- Treat `/etc/os-release` as the primary source for determining the distribution and its package manager.
- After reading `/etc/os-release`, infer the package manager from the detected distribution and use it directly.
- Do not probe for package managers unless `/etc/os-release` is missing or ambiguous.

- Before the first repository search or OS package installation in the current task, always refresh the package repository indexes after detecting the OS. After one successful refresh in the same task, do not refresh them again unless there is clear evidence that the indexes became stale or invalid.
- Before installing an OS package, search the distribution repositories for the requested package or dependency.
- Verify that the package exists in the current distribution repositories and that the package name is correct for this distribution.
- If the exact package is not found, check for distribution-specific names, replacement packages, or suitable alternatives before choosing what to install.
- Do not install packages by guessing names.
- Do not ask the user for conversational permission before installing required OS packages in this environment.
- Use the package manager available in the current container. Do not assume Debian or Ubuntu.

## Safety and correctness

- If package names differ between distributions, verify the correct package name before installing.
- If the package is unavailable or the available alternatives are ambiguous, report the findings instead of trying random package names.
- Do not use `sudo` unless the container user is non-root and `sudo` is actually available.
- If the package manager fails due to permissions, report the exact error and the detected environment.
- Do not retry with random package managers.
