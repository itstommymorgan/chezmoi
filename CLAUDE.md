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
- Any path component starting with a literal `.` (not `dot_`) is invisible to chezmoi — it's never applied, anywhere in the tree. This is why global Claude Code settings live in `dot_claude/` (translated to `~/.claude`, scoped down by its own `.chezmoiignore` to just `settings.json`, `statusline-command.sh`, `keybindings.json`) rather than a literal `.claude/`, and why the repo-root `.claude/` and any nested `.claude/` (e.g. `dot_config/nvim/.claude/`) are safe, chezmoi-invisible spots for Claude Code's own project config/skills.

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
9. `run_once_after_99z-manual-checklist.sh.tmpl` — prints the steps chezmoi can't perform (macOS TCC grants, account logins) and blocks on Enter when interactive. Content lives in `MANUAL-SETUP.md`, which is `.chezmoiignore`d so it stays repo-only.

## Shell (zsh)

Split across `dot_zshenv` and `dot_zshrc` deliberately, not redundantly: `.zshenv` loads for *every* shell invocation (including non-interactive/scripts), so it only sets up Homebrew's PATH (`__tm_setup_homebrew`, arch-aware: `/opt/homebrew` on arm64 vs `/usr/local`) and mise shims — needed for scripts to resolve tools correctly. `.zshrc` (interactive-only) does the heavier lifting: activates mise, sources zplug and the zplug plugin list, sources every custom script, and sets interactive-only env vars (`BAT_THEME`, `KEYTIMEOUT`, `LC_ALL`). See `dot_zsh/CLAUDE.md` for the zplug/custom-script details.

## Per-tool docs

Tool-specific details live in nested `CLAUDE.md` files, which Claude Code loads automatically once it touches a file in that subtree: `dot_zsh/CLAUDE.md`, `dot_config/nvim/CLAUDE.md`, `dot_hammerspoon/CLAUDE.md`, `dot_config/karabiner/CLAUDE.md`.

## Claude Code config in this repo

Two distinct things share the `.claude` name here, and conflating them is the easy mistake:

- **`dot_claude/`** → applied to `~/.claude`. This is *global user config* for Claude Code itself (`modify_settings.json`, `keybindings.json`, `statusline-command.sh`, `CLAUDE.md`, `themes/`). Its `.chezmoiignore` is an allowlist (`*` then `!`-exceptions), so **a new file here is ignored until explicitly allowlisted**. Everything else under `~/.claude` (sessions, projects, auto memory, plugins) is machine-local runtime state and deliberately unmanaged.
- **`.claude/`** (repo root, and nested ones like `dot_config/nvim/.claude/`) → chezmoi-invisible, never applied. This is *this repo's own* Claude Code config: skills, settings.local.json.

Note the root `.chezmoiignore` blocks `**/CLAUDE.md` to keep repo docs out of `~`, with a single negation for `.claude/CLAUDE.md` (the user-scope one). Patterns there match **target** paths, so the negation reads `.claude/`, not `dot_claude/`.

**`~/.claude/settings.json` is co-managed**, because Claude Code rewrites it at runtime (`/model`, `/theme`, `/config` toggles). It is therefore not a static source file but a `modify_` script, `dot_claude/modify_settings.json`: chezmoi pipes the live file in on stdin and takes the script's stdout as the new contents (stdin is empty on a fresh machine, so the script generates the whole file). The script jq-merges a block of repo-declared keys over the live file.

The contract: **keys declared in that script are repo-authoritative and overwrite live values; every other key is preserved untouched.** So a `/theme` change gets reverted on the next apply (theme is declared), while an undeclared key Claude Code invents later survives. To let a key float, delete it from the `managed` block. Edit settings by editing that script, not with `chezmoi re-add`.

### Choosing between CLAUDE.md, rules, and skills

- **`CLAUDE.md`** — always loaded for its directory and below. Facts that apply to every session in that subtree. The nested per-tool files (`dot_zsh/`, `dot_config/nvim/`, …) already scope themselves this way: they load on demand when Claude reads a file in that subtree, so they need no extra path scoping.
- **`.claude/rules/*.md`** — same as CLAUDE.md, but supports `paths:` frontmatter (globs) to load only when Claude touches matching files. Worth reaching for only if instructions need to follow a *file pattern* that cuts across directories; the per-directory CLAUDE.md split above already covers the directory case, so don't convert those to rules.
- **`.claude/skills/`** — multi-step procedures, loaded on demand rather than every session. A skill only relevant to one subtree belongs in a nested `.claude/skills/` inside it (e.g. `dot_config/nvim/.claude/skills/`); the more specific skill wins if a same-named one exists at both levels.

## Editing templates

When editing a `*.tmpl` file, remember the `{{ .field }}` values come from `.chezmoi.toml.tmpl`'s prompts (`hostname`, `email`, `companyName`) or from `.chezmoi.*` built-ins (e.g. `.chezmoi.arch` used for the Rosetta check). Use `chezmoi execute-template` to sanity-check a template renders as expected before relying on `chezmoi diff`/`apply`.
