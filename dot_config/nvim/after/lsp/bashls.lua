-- zsh handled by shuck instead (see after/lsp/shuck.lua) - bashls's
-- shellcheck integration produces false positives on zsh-only syntax
return {
  filetypes = { "sh", "bash" },
}
