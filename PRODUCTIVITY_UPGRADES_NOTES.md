# Notes on items not fully implemented

## chezmoi migration — scoped down to this plan, not executed

Migrating to chezmoi would mean replacing install.sh's whole symlink +
backup system with chezmoi's templating engine, and restructuring every
config file to live under chezmoi's `dot_` naming convention. That's a
rewrite of the entire repo structure, not an additive change — high risk
of breaking the Windows support, the `today` function paths, and the
Obsidian/starship/atuin/direnv work just added, all for a tool upgrade
with no urgent need yet (this repo only manages ~6 config targets).

Recommended path if/when this is worth doing:
1. `chezmoi init` in a scratch directory first, `chezmoi add` each config
   one at a time, verify `chezmoi diff` matches current behavior.
2. Convert OS-specific logic (the install.sh case statements) into
   chezmoi's `.chezmoi.toml.tmpl` + Go template conditionals.
3. Only cut over once the chezmoi-based repo round-trips cleanly on all
   3 platforms (macOS, Linux, Windows) — don't delete install.sh until
   then.
4. This is a half-day-plus task on its own; worth doing once the repo
   has more than ~10 config targets, not before.

## shellcheck CI — real limitation worth knowing

`install.sh` is zsh (shebang `#!/usr/bin/env zsh`), but shellcheck does
not officially support zsh as a dialect — only sh/bash/dash/ksh. The CI
workflow forces `-s bash` so it runs at all, which means:

- Zsh-only syntax (`${(%):-%x}`, `${(k)ASSOC_ARRAY}`, associative arrays
  in general) will likely trigger false-positive warnings under the
  bash dialect checker.
- The workflow suppresses the most common false-positive codes, but
  expect some noise — review failures with that in mind, don't assume
  every red X is a real bug.
- The clean long-term fix is either: (a) rewrite install.sh in POSIX
  sh/bash (loses associative array convenience, the original reason zsh
  was chosen), or (b) accept shellcheck as a bash-dialect lint that
  catches *most* real issues (unquoted vars, command injection, etc.)
  while tolerating some zsh-specific false positives.
