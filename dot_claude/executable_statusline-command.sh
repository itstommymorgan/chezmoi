#!/bin/bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

branch=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi

DIR_COLOR='\033[2;36m'
BRANCH_COLOR='\033[2;33m'
MODEL_COLOR='\033[1;35m'
CTX_COLOR='\033[2;32m'
RESET='\033[0m'

sep() {
  printf '\033[2;37m|\033[0m'
}

output=$(printf "${DIR_COLOR}%s${RESET}" "$dir")

if [ -n "$branch" ]; then
  output="${output} $(sep) $(printf "${BRANCH_COLOR}%s${RESET}" "$branch")"
fi

output="${output} $(sep) $(printf "${MODEL_COLOR}%s${RESET}" "$model")"

if [ -n "$remaining" ]; then
  remaining_rounded=$(printf '%.0f' "$remaining")
  output="${output} $(sep) $(printf "${CTX_COLOR}%s%% ctx${RESET}" "$remaining_rounded")"
fi

printf '%s\n' "$output"
