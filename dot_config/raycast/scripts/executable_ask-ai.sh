#!/usr/bin/env zsh

# @raycast.schemaVersion 1
# @raycast.title Ask AI
# @raycast.mode fullOutput
# @raycast.packageName AI
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "question" }
# @raycast.description One-shot question, answered tersely. Leaves no chat behind.

# Absolute path: Raycast runs script commands with the GUI environment's PATH,
# which has no Homebrew. Point at the bin symlink, not the Caskroom target --
# the latter carries a version number and breaks on every cask bump.
CLAUDE=/opt/homebrew/bin/claude

# $HOME rather than the script's own directory: `claude -p` reads the CLAUDE.md
# of whatever project it starts in, which would colour answers to unrelated
# questions and cost tokens loading it.
cd "$HOME" || exit 1

# --strict-mcp-config with an empty set skips loading every configured MCP
# server. They're useless to a one-shot question and cost ~1.5s of startup.
#
# </dev/null is load-bearing: without it `claude -p` waits 3s for piped stdin
# that never arrives, then prints a warning into the output Raycast renders.
#
# --system-prompt REPLACES Claude Code's own coding-agent prompt. The similarly
# named --append-system-prompt appends to it instead, loses the argument, and
# returns bulleted essays -- verified, not assumed.
#
# Haiku, not Sonnet, and the reason is counterintuitive: replacing Claude Code's
# default system prompt with a short one measurably degrades Sonnet's factual
# recall (it answered "1975" for zsh's release year in 5/5 runs, where the same
# prompt on Haiku and the stock prompt on Sonnet both give the correct 1990).
# Re-test before switching models here.
exec "$CLAUDE" -p \
  --model haiku \
  --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
  --system-prompt 'You answer one-off questions from a launcher. At most 3 sentences of plain prose. No preamble, no headers, no bullet lists, no restating the question, no caveats, no offers to elaborate. If the answer is a single fact, give only that fact.' \
  "$1" </dev/null
