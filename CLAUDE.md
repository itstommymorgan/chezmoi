# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is Tommy Morgan's personal [chezmoi](https://www.chezmoi.io/)-managed dotfiles repository for macOS. It is the *source* state that chezmoi renders into the actual home directory (`~`). There is no build, lint, or test suite — "correctness" here means valid shell/Lua syntax and files that render/apply cleanly with chezmoi.

## chezmoi mechanics (important before editing filenames)

chezmoi uses filename prefixes/suffixes to encode behavior. Get these wrong and a file either won't apply where intended or won't be treated as a template:

- `dot_foo` → applies to `~/.foo` (e.g. `dot_zshrc` → `~/.zshrc`, `dot_config/` → `~/.config/`).
- `*.tmpl` → the file is a Go-template; rendered using chezmoi data (see `.chezmoi.toml.tmpl`) before being written.
- `run_once_*` → script runs exactly once ever (tracked by chezmoi state).
- `run_onchange_*` → script re-runs whenever its own content hash changes. These embed a hash comment of another file's contents (e.g. `# Brewfile hash: {{ include "Brewfile" | sha256sum }}`) specifically so they re-run when *that* file changes — see `run_onchange_before_10-install-homebrew.sh.tmpl` (hashes `Brewfile`) and `run_onchange_after_10-install-mise.sh.tmpl` (hashes `dot_config/mise/config.toml.tmpl`). If you edit `Brewfile` or the mise config, don't touch the hash by hand — chezmoi recomputes it from the template on apply.
- `run_before_*` / `run_after_*` (no `_once`/`_onchange`) → run on every `chezmoi apply`.
- Ordering is lexical by the numeric prefix (`00`, `10`, `20`, `90`, `91`, `99`), which is why e.g. company-folder creation is `00` (before) and login items are `99` (after).
- `.chezmoiignore` files scope which paths under a directory chezmoi manages (e.g. `dot_config/nvim/.chezmoiignore` excludes `lazy-lock.json`; `dot_config/karabiner/.chezmoiignore` excludes `automatic_backups`).

Common commands (run from anywhere, chezmoi finds the source dir):
- `chezmoi apply` — render templates and run applicable `run_*` scripts against `~`.
- `chezmoi diff` — preview what `apply` would change.
- `chezmoi cd` — drop into this source directory (equivalent to being here already).
- `chezmoi execute-template < file.tmpl` — render a single template for debugging without applying.

## `.chezmoi.toml.tmpl` — machine-specific prompts

On first run on a new machine, chezmoi prompts for `hostname`, `email` (git commit email, defaults to `tommy@tommymorgan.name`), and `companyName` (creates `~/projects/<companyName>` if set, and is otherwise blank). These values are referenced via `.hostname`, `.email`, `.companyName` in templates (e.g. `dot_gitconfig.tmpl`, `run_once_before_00-create-company-projects-folder.sh.tmpl`, the hostname-setting block in `run_onchange_before_10-install-homebrew.sh.tmpl`).

## Provisioning flow (fresh machine bootstrap order)

1. `run_once_before_20-use-1password-for-ssh.sh.tmpl` — interactively walks through enabling the 1Password SSH agent (blocks on user confirmation).
2. `run_once_before_99-disable-spotlight-shortcut.sh.tmpl` — frees the Spotlight shortcut via `PlistBuddy`.
3. `run_onchange_before_10-install-homebrew.sh.tmpl` — installs Xcode CLT, Homebrew, Rosetta (arm64 only), runs `brew bundle` against `Brewfile`, and sets the machine hostname.
4. `run_onchange_after_10-install-mise.sh.tmpl` — installs mise-managed tool versions (`dot_config/mise/config.toml.tmpl`: ruby, node).
5. `run_after_90-update-zplug.sh.tmpl` — installs/updates zsh plugins via zplug.
6. `run_after_91-update-nvim-lazy.sh.tmpl` — headless-syncs Neovim's `lazy.nvim` plugins.
7. `run_once_after_01-auth-gh.sh.tmpl` — `gh auth login`.
8. `run_once_after_99-loginitems.sh.tmpl` — registers GUI apps as macOS login items.

## Shell (zsh)

Split across `dot_zshenv` and `dot_zshrc` deliberately, not redundantly: `.zshenv` loads for *every* shell invocation (including non-interactive/scripts), so it only sets up Homebrew's PATH (`__tm_setup_homebrew`, arch-aware: `/opt/homebrew` on arm64 vs `/usr/local`) and mise shims — needed for scripts to resolve tools correctly. `.zshrc` (interactive-only) does the heavier lifting: activates mise, sources zplug and the zplug plugin list, sources every custom script, and sets interactive-only env vars (`BAT_THEME`, `KEYTIMEOUT`, `LC_ALL`). See `dot_zsh/CLAUDE.md` for the zplug/custom-script details.

## Per-tool docs

Tool-specific details live in nested `CLAUDE.md` files, which Claude Code loads automatically once it touches a file in that subtree: `dot_zsh/CLAUDE.md`, `dot_config/nvim/CLAUDE.md`, `dot_hammerspoon/CLAUDE.md`, `dot_config/karabiner/CLAUDE.md`.

## Editing templates

When editing a `*.tmpl` file, remember the `{{ .field }}` values come from `.chezmoi.toml.tmpl`'s prompts (`hostname`, `email`, `companyName`) or from `.chezmoi.*` built-ins (e.g. `.chezmoi.arch` used for the Rosetta check). Use `chezmoi execute-template` to sanity-check a template renders as expected before relying on `chezmoi diff`/`apply`.
