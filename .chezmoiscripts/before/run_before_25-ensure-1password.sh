#!/usr/bin/env zsh
# `op` only works while the 1Password desktop app is running, and dot_ssh/id_ed25519.pub.tmpl
# calls onepasswordRead. Targets apply alphabetically, so a failure under .ssh/ aborts every
# after_ script behind it -- that's how AltTab silently never made it into login items.
# A before_ script is the only hook early enough to prevent it. Runs after 20-use-1password-
# for-ssh so first-time setup happens first.
#
# Failsafe only: with 1Password in login items it should already be running and this exits
# immediately. Never fails the run -- on a fresh machine 1Password legitimately isn't set up
# yet, and blocking bootstrap would be worse than the SSH template erroring on its own.
set -euo pipefail

app_process="1Password.app/Contents/MacOS/1Password"

# Checking the process (rather than invoking `op`) keeps the common path free and avoids
# triggering a biometric prompt on every apply.
if pgrep -f "$app_process" >/dev/null 2>&1; then
  exit 0
fi

if [ ! -d "/Applications/1Password.app" ]; then
  exit 0 # not installed yet; Homebrew (10) may not have run on a fresh machine
fi

echo "1Password isn't running; launching it in the background so \`op\` can resolve secrets..."
open -g -j -a "1Password" 2>/dev/null || true

for _ in {1..15}; do
  sleep 1
  if pgrep -f "$app_process" >/dev/null 2>&1; then
    exit 0
  fi
done

echo "warning: 1Password still isn't running. If this apply fails reading a secret," >&2
echo "         unlock 1Password and re-run \`chezmoi apply\`." >&2
exit 0
