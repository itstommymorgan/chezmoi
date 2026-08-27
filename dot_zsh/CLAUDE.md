# CLAUDE.md

Guidance for the plugin/custom-script layer of the zsh config. See the repo-root `CLAUDE.md` for the `.zshenv`/`.zshrc` split this directory plugs into.

`dot_zshrc` (repo root) sources every file under `custom/*.zsh` automatically, then sources `plugins.zsh` last.

- To add a new interactive-only tool/alias, drop a file in `custom/`; no registration needed.
- To add a plugin, add a line to `zsh_plugins.txt`. It regenerates on the next shell.
- Completion behaviour is `custom/completion.zsh`; `compinit` itself runs from `plugins.zsh`, later. That ordering is fine because `zstyle`s are read at completion time, not at load.

## Plugins (antidote, static mode)

`plugins.zsh` is the loader; the plugin lists are plain text and the `.zsh` files beside them
are generated. antidote is `autoload`ed rather than sourced, so it costs nothing on a shell
that doesn't need to regenerate. Regeneration triggers on mtime: edit a `.txt`, next shell
rebuilds. The generated files live in `~/.zsh/` and are deliberately unmanaged by chezmoi —
they are build output, and their contents are absolute paths into `~/Library/Caches/antidote`.

**There are two lists, and the split is load-bearing.** `zsh_plugins_fpath.txt` holds
completion-only plugins that must reach `fpath` *before* `compinit`; `zsh_plugins.txt` holds
everything else, which must load *after* it, because `op` and the oh-my-zsh git plugin call
`compdef` at source time and that function does not exist until `compinit` has run. Collapsing
the two lists into one breaks the shell with `command not found: compdef`.

Ordering inside `zsh_plugins.txt` is significant at **both** ends, and both were found the
hard way:

- `zsh-vi-mode` must be **first**. It defines ~46 widgets, and anything that wraps widgets
  (autosuggestions, autopair, syntax-highlighting) has to wrap ZVM's final versions. Put ZVM
  after them and it redefines already-wrapped widgets, so the wrapper calls itself:
  `_zsh_autosuggest_widget_modify: maximum nested function level reached`, spraying FUNCNEST
  errors over every prompt. zplug did not source in list order, which is why the same
  ordering was survivable there and is not here.
- autopair and syntax-highlighting bind widgets over everything above them and stay **last**.

One consequence of ZVM being first: `ZVM_INIT_MODE=sourcing` makes `zvm_init` — and with it
`zvm_after_init_commands` — run before the rest of the list is sourced, so the `Ctrl+R`
binding in `custom/fzf.zsh` is a forward reference to a widget that does not exist yet. zsh
resolves widget names at keypress rather than bind time, so this works, but it means
`bindkey -M viins '^R'` reporting the right name is not on its own proof: check
`zle -la | grep fzf_history_search` finds the widget too.

## Keybindings and zsh-vi-mode

`zsh-vi-mode` resets the keymaps when it initializes, so any plugin that binds a key in the
`emacs` keymap (the zsh default) silently loses it — you end up in `viins` with the builtin
binding. `zsh-fzf-history-search` did exactly this to `Ctrl+R`. Bindings that must survive go
through ZVM's post-init hook, appended as strings so they compose:
`zvm_after_init_commands+=('bindkey -M viins "^R" fzf_history_search')` (see `custom/fzf.zsh`).
Check a binding actually took with `bindkey -M viins '^R'`, not plain `bindkey`.

## History

History options live in `custom/history.zsh` and exist mainly to override macOS `/etc/zshrc`,
which sets `SAVEHIST=1000` and truncates without warning.
