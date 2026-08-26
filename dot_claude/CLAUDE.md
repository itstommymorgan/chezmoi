# Global instructions

User-scope preferences that apply to every project. Project-specific rules belong in that
project's own `CLAUDE.md`, not here.

## Environment

- macOS (Apple Silicon), zsh, Homebrew, `mise` for language runtimes.
- Neovim is the primary editor; dotfiles are chezmoi-managed in `~/.local/share/chezmoi`.
- Terminal: Ghostty.

## Working style

- **Verify, don't assert.** Check the actual source, docs, or filesystem before claiming a
  tool, flag, path, or API exists — especially for anything that changed recently. If
  something is unverified, say so plainly instead of stating it confidently.
- **Prefer empirical checks over reasoning about behavior.** Run the command, open the file,
  test the edge case. A reversible probe beats a confident guess.
- Correct earlier mistakes plainly and move on. No preamble, no self-flagellation.
- Edit existing files rather than creating new ones unless a new file is genuinely warranted.

## Comments and prose

- Keep comments terse. Comment the non-obvious *why*, never restate what the code does.
- Don't write comments explaining that something replaced something else, or narrating the
  history of an edit — that belongs in the commit message.
- Match the surrounding file's existing comment density and idiom.

## Git

- Don't commit unless asked. Don't push without asking first.
- Branch before committing when on the default branch.
- Stage explicitly by filename; avoid `git add -A` / `git add .`.
- Review what's staged before committing, and check for secrets in anything bound for a
  public remote.
