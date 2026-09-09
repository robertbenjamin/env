## Background Job Guidelines

For background jobs (automated runs that don't require user interaction):

- **Do NOT create worktrees** — make changes directly on the current branch
- **Do NOT create pull requests** — only commit changes to the local branch
- Only create PRs if explicitly requested by the user in the task

## Shell

- **No `timeout`/`gtimeout` on this machine** (no GNU coreutils). Never prefix a command with it
  — the prefix fails with `command not found` and the real command never runs, printing nothing.
  That is indistinguishable from a genuine zero-result. Bound long commands with the Bash tool's
  own `timeout` parameter (ms) or `run_in_background` instead.
- Checking an exit code: put `echo "rc=$?"` immediately after the binary, not after a pipeline —
  a pipeline reports only its _last_ stage, so a failed command reads as success.
