# CLAUDE.md

Guidance for the zplug/custom-script layer of the zsh config. See the repo-root `CLAUDE.md` for the `.zshenv`/`.zshrc` split this directory plugs into.

`dot_zshrc` (repo root) sources every file under `custom/*.zsh` automatically and sources `plug.zsh` for the zplug plugin list.

- To add a new interactive-only tool/alias, drop a file in `custom/`; no registration needed.
- To add a zplug plugin, edit `plug.zsh`.

`zsh-vi-mode` resets the keymaps when it initializes, so any plugin that binds a key in the
`emacs` keymap (the zsh default) silently loses it — you end up in `viins` with the builtin
binding. `zsh-fzf-history-search` did exactly this to `Ctrl+R`. Bindings that must survive go
through ZVM's post-init hook, appended as strings so they compose:
`zvm_after_init_commands+=('bindkey -M viins "^R" fzf_history_search')` (see `custom/fzf.zsh`).
Check a binding actually took with `bindkey -M viins '^R'`, not plain `bindkey`.

History options live in `custom/history.zsh` and exist mainly to override macOS `/etc/zshrc`,
which sets `SAVEHIST=1000` and truncates without warning.
