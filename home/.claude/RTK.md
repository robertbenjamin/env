# RTK - Rust Token Killer

Token-optimized CLI proxy. A hook rewrites most commands automatically — only **single** commands;
anything with a `|` runs unproxied. `rtk rewrite '<cmd>'` shows what a command becomes.

```bash
rtk gain              # token savings analytics (--history for per-command)
rtk discover          # missed opportunities in Claude Code history
rtk proxy <cmd>       # run unfiltered
```

## Use

- Hook-automatic, real savings, do nothing: `git status` `git branch -a` `git log` `git show`
  `git diff` `ls` `wc` `find`.
- Test runs (hook does _not_ rewrite `pnpm`/`yarn`), call yourself:
  - `rtk test 'pnpm test <file>'` — is it green (suite names + counts)
  - `rtk err 'pnpm test <file>'` — it's red, show assertion diffs
- `rtk git diff` output can't feed `git apply`. Find a branch with `git branch -a --list 'PAT*'`
  (`rtk git branch -a` truncates remotes).

## Do NOT use

`rtk jest` (discards all output) ·
`rtk lint` (ESLint, breaks oxlint services — use `pnpm lint`) ·
`rtk tsc` · `rtk pnpm` · `rtk yarn` (doesn't exist, silently runs raw yarn) ·
`rtk read`/`cat`/`head`/`tail` (identical to raw — use the Read tool) ·
`rtk grep` (BSD grep, not rg: searches `node_modules`, rejects `--glob`/`-t`, needs `-r` for
directories — but if a hook-rewritten search must be exhaustive, `rtk grep -m 5000` lifts its
200-result cap).

## Search: use raw `rg`

```bash
rg -l 'pattern' .      # which files
rg -n 'pattern' .      # match sites
rg --stats 'pattern' . # counts only
```

Never hand-exclude `node_modules`/`dist` (`rg` respects `.gitignore`). No `--hidden` (hangs on
`.git`). Exclude form is `-g '!node_modules/**'`.
