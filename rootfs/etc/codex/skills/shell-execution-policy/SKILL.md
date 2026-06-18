---
name: shell-execution-policy
description: Use only before executing real shell/terminal commands. Do not use for writing or editing shell scripts.
---

# Shell execution policy

This policy applies only to commands executed directly in the shell/terminal. It does not apply to shell syntax inside scripts, files, or code examples.

## Command execution

- Execute exactly one shell command per execution.
- Do not chain shell commands.

## Forbidden

- Do not use:
  - `&&`
  - `;`
  - `||`

- Forbidden examples:
```sh
cmd1 && cmd2
```
```sh
cmd1; cmd2
```
```sh
cmd1 || cmd2
```

## Allowed

- Pipes are allowed:
```sh
cat file | grep text
```

Redirection is allowed:
```sh
echo text > file.txt
```
```sh
cat input.txt > output.txt
```

- Append redirection is allowed:
```sh
echo text >> file.txt
```

## File removal

- If `rm -rf` is unavailable or blocked, use `rm -r` instead.
- This exception does not change the one-command-per-execution rule.
