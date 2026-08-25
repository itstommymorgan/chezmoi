# CLAUDE.md

Guidance for the zplug/custom-script layer of the zsh config. See the repo-root `CLAUDE.md` for the `.zshenv`/`.zshrc` split this directory plugs into.

`dot_zshrc` (repo root) sources every file under `custom/*.zsh` automatically and sources `plug.zsh` for the zplug plugin list.

- To add a new interactive-only tool/alias, drop a file in `custom/`; no registration needed.
- To add a zplug plugin, edit `plug.zsh`.
