---
description: Process and gotchas for adding per-filetype LSP/lint/format/DAP/treesitter support to this chezmoi-managed Neovim config. Use when adding or auditing support for a new language/filetype in dot_config/nvim.
---

# Adding filetype support to this Neovim config

This is the accumulated process and gotcha list from building out LSP/lint/format/DAP/treesitter support filetype-by-filetype (goto-keybindings, Markdown, JSON, TOML/chezmoi-templates, ZSH/Bash, YAML, Ruby, ERB, CSS/SCSS/Sass, JavaScript/TypeScript/Node). Reload this skill before starting the next filetype.

## The process

For each filetype, propose before implementing, in three categories:

1. **Mason-installed tools** — LSP server, linter, formatter, DAP adapter.
2. **Plugins/configs/hooks** — lazy.nvim plugin specs, `mason.lua` entries, `after/lsp/<name>.lua` overrides, `format-lint.lua` entries, treesitter parser list.
3. **Sane viewing defaults** — anything LSP/lint/format doesn't cover: indentation, `iskeyword`, `commentstring`, folding. Often "nothing needed" once treesitter + global settings are checked.

Share opinions and tradeoffs in the proposal (alternatives considered and why not chosen). Get explicit approval before implementing. Only commit when told to.

## Verification methodology (do this for every change, not just at the end)

1. Syntax-check each edited file: `nvim --headless -u NONE -c "luafile <file>" -c "qa"`. Note: files that reference plugin state (`after/lsp/*.lua` needing `vim.lsp.config.<name>` to already exist, or `require("schemastore")`) will legitimately error under `-u NONE` — that's an artifact of the isolated test, not a real bug. Confirm by checking an existing known-good file fails the same way.
2. Preview: `chezmoi apply --dry-run --verbose <deployed-path>`.
3. Apply scoped to the changed files only: `chezmoi apply <deployed-path>...`.
4. Confirm source/deploy sync: `diff <deployed-path> <source-path>`.
5. Install new mason tools: `nvim --headless -c "MasonInstall <pkgs>" -c "qa"`, then confirm with `mason-registry.is_installed(...)`.
6. **Functional test in headless Neovim against a real scratch file of that filetype** — this is where most real bugs surfaced, not in the syntax check:
   - `vim.bo.filetype` is correct
   - `vim.lsp.get_clients()` shows the expected client(s) attached — and only those
   - `vim.diagnostic.get(0)` after a real lint pass, checking for **duplicate diagnostics** from two sources describing the same issue
   - `pcall(vim.treesitter.get_parser, 0)` succeeds
   - Actually run the formatter (`require("conform").format(...)`) and inspect the output, not just check for a nil error
   - For DAP: actually start a session (`dap.run(config)`) and confirm `event_initialized`/`event_terminated` fire — a config existing syntactically doesn't mean the adapter actually connects
7. Clean up scratch/test files, review the real diff (`git diff`), stage explicitly by filename (never `-A`/`.`), commit only when told to.

## Gotchas, most costly first

### An `after/lsp/<name>.lua` file cannot reference `vim.lsp.config.<name>` from inside itself
`vim.lsp.config.<name>` is a lazy accessor — indexing it triggers loading of exactly the `lsp/<name>.lua` + `after/lsp/<name>.lua` files that back it. Doing `local base = vim.lsp.config.eslint.on_attach` inside `after/lsp/eslint.lua` itself causes infinite recursion (confirmed via an actual stack overflow crash during `MasonInstall`, not a hypothetical). This breaks nvim-lspconfig's own documented "capture base on_attach, then extend it" recipe when that recipe is placed inside an `after/lsp/` file — that pattern only works when called interactively/elsewhere, never from within the file being resolved.
**Fix**: if you need to extend a server's default `on_attach` (or any function field) from `after/lsp/<name>.lua`, don't try to chain to the base — read the base server's actual `lsp/<name>.lua` source (in `nvim-lspconfig`'s repo) and replicate the specific behavior you need directly, since `on_attach`/other function fields are fully replaced (not deep-merged) by whatever you return.

### A tool with both an LSP mode and a CLI mode can double up diagnostics
Some mason packages that are primarily "linter/formatter CLI tools" (rubocop) also ship a full LSP server, and mason-lspconfig auto-enables *every* installed server by default. If you're also driving that same tool via nvim-lint/conform as a standalone CLI (the pattern used throughout this project, to keep tools independent of a specific project's Gemfile/package.json), you get the exact same diagnostic twice under two different `source` names.
**Fix**: verify empirically (open a real file, `vim.diagnostic.get(0)`, look for duplicate messages) before assuming a mason package is "just a linter." If duplicated, exclude the LSP: `mason-lspconfig` opts `automatic_enable = { exclude = { "<server-name>" } }`.
**Not every overlap is a duplicate** — `cssls` + `somesass_ls` both attaching on `.scss` is intentional and complementary (general CSS validation vs. SCSS-specific semantics), confirmed by checking their diagnostics don't actually repeat each other. Test before concluding either way.

### Don't trust tool/package existence or capability from memory — verify
Got directly corrected mid-session for wrongly claiming `shuck` wasn't mason-installable and needed cargo (it ships prebuilt binaries via mason like everything else). Since then: verify via `gh api repos/mason-org/mason-registry/contents/packages` (or fetching a specific `package.yaml` raw) before proposing any tool, and check the actual `nvim-lspconfig`/`nvim-lint`/`conform.nvim` source files under `~/.local/share/nvim/lazy/` for exact server/linter/formatter names rather than guessing.

### A "linter" that shells to a project's own bundler/gem isn't reliable as standalone tooling
`erb-lint` (Shopify) and ruby-lsp's built-in rubocop addon both only work if the *target project* has that gem in its own `Gemfile` — worthless as a global default for arbitrary files/projects. Prefer genuinely standalone, mason-installed binaries (`herb-language-server`, `rubocop` run directly) that work regardless of project setup.

### Some CLI linters have no built-in ruleset at all
`stylelint` throws `ConfigurationError: No configuration provided` on a file with no discoverable config — unlike `yamllint`/`shellcheck`, which have sane defaults out of the box. Verify by running the CLI directly (`stylelint --stdin ...`) against a bare scratch file before assuming "linter installed" means "linter useful." Not necessarily worth building a global fallback config (shareable configs like `stylelint-config-standard` aren't cleanly resolvable from mason's isolated per-package node_modules) — flag the tradeoff and leave it, since real projects with their own tooling already have their own config and mason's version is just the fallback.

### A config file's discovery mechanism depends on how the tool is invoked
`markdownlint-cli2` invoked over stdin (no real file path) only checks `$PWD` for config, not the file's real ancestor directories — silently ignoring a global `~/.markdownlint-cli2.jsonc` unless you're coincidentally in the right directory. Fix was passing `--config <path>` explicitly. Conversely, `stylelint`/`shfmt` invoked with `--stdin-filename <realpath>` walk up correctly from that real path. Check which mode a given nvim-lint/conform definition uses before assuming config discovery "just works."

### `conform.nvim`'s `formatters.<name>` table is an override, not the builtin config
It's normally `nil`/empty per key, merged via `vim.tbl_deep_extend` with the real builtin formatter config. Mutating `.args` directly assumes it's pre-populated — it isn't, and the resulting Lua error gets silently swallowed by lazy.nvim after `setup()` already ran, leaving you with a formatter that's configured but silently doesn't apply the override. Use the idiomatic `append_args`/`prepend_args` functions (can be `(self, ctx) -> args_list`, i.e. can inspect the buffer) instead of hand-rewriting `.args`.

### Treesitter parser names don't always match filetype names
`nvim-treesitter/plugin/filetypes.lua` holds the alias table (parser name → filetype list): `embedded_template → {eruby}`, `jsonc → json` is separate builtin handling. `zsh` has **no** alias to `bash` — would need `vim.treesitter.language.register` if ever pursued. Check this table before assuming a parser needs a filetype-matching name, and before writing a redundant manual alias that already exists.

### `lua_ls` root-marker resolution is two-tiered and order-sensitive
Tier 1 (`.luarc.json`/`.emmyrc.json`) is checked across the *entire* ancestor chain first; tier 2 (`.stylua.toml`, `.luacheckrc`, etc.) is only checked at all if tier 1 finds nothing *anywhere*. A global `~/.stylua.toml` (for cross-project stylua consistency) makes `lua_ls` treat all of `$HOME` as workspace root unless a `.luarc.json` sits closer to stop the ancestor search first — this bit twice in this project (once at `~/.config/nvim/.stylua.toml`, again when made truly global). Fix: add a minimal `{}` `.luarc.json` at each real Lua "project" root you care about keeping separate.

### DAP companion plugins: check if they're actually maintained before depending on them
`suketa/nvim-dap-ruby` (rdbg wiring) was the right call — genuinely fiddly logic (ephemeral port allocation, `RUBY_DEBUG_*` env-var launching, Rails/RSpec/Minitest presets) that's not worth reinventing. `mxsdev/nvim-dap-vscode-js` (js-debug-adapter wiring) turned out abandoned since 2023 (42 open issues, no commits) with no actively-maintained alternative — there, hand-rolling a `type = "server"` adapter directly (spawn the mason-installed binary on `${port}`, connect) was both safer and genuinely simple, since vscode-js-debug's protocol doesn't need the port-picking/env-var/preset complexity rdbg does.
**Check before depending on any plugin**: `gh api repos/<owner>/<repo> --jq '{pushed_at, stargazers_count, open_issues_count, archived}'`.
Resolve mason-managed binary paths programmatically, not by hardcoding: `require("mason-registry").get_package("<name>"):get_install_path()`.

### `vim.filetype.add({pattern = {...}})` for anything extension-matching misses
Chezmoi's `dot_*` naming and non-standard double extensions (`hammerspoon.json.defaults`) need explicit Lua-pattern entries in `dot_config/nvim/lua/filetypes.lua`, matched against the full path. Values can be a plain filetype string or a function for dynamic resolution (used for the chezmoi `dot_*` → real-filename delegation).

## What's already been built (don't re-propose)

Goto-keybinding framework (`gr*`), Markdown (marksman, markdownlint-cli2, table-mode, checkbox toggle), JSON/JSONC (jsonls + schemastore), TOML + chezmoi `.tmpl` templates (taplo, chezmoi-template.nvim), ZSH/Bash (bash-language-server, shuck for zsh, shfmt with dialect override, shellcheck), YAML (yamlls + schemastore, yamllint, prettier), Ruby (ruby-lsp, rubocop lint+format, rdbg/nvim-dap-ruby), ERB (herb-language-server), CSS/SCSS/Sass (cssls, somesass_ls, stylelint, prettier), JavaScript/TypeScript/Node (ts_ls, eslint-lsp with fix-on-save, prettier, hand-rolled pwa-node DAP).

Explicitly deferred, not forgotten: Ruby's "heavier hitter" ecosystem pass already done (Rails via `ruby-lsp-rails` transitively, Middleman is just Ruby+ERB, Haml/Slim/Sorbet/GraphQL/Deno/vtsls/biome/oxlint all flagged as skip-unless-actually-used). JSX/TSX and framework-specific work (React/Vue/Svelte/Astro) deliberately out of scope until actually needed. `.json5` flagged and explicitly skipped until there's a real reason to use it.
