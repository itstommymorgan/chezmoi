#!/bin/bash

input=$(cat)

# One jq pass for every field: the status line re-renders constantly, and a process
# per field is the difference between instant and visibly laggy. The separator must be
# non-whitespace -- bash collapses runs of IFS *whitespace* into one delimiter, which
# silently shifts every field left as soon as an optional one (rate_limits) is absent.
IFS=$'\x1f' read -r cwd model remaining limit5 reset5 limit7 reset7 <<<"$(
  printf '%s' "$input" | jq -r '
    [ .workspace.current_dir,
      .model.display_name,
      (.context_window.remaining_percentage // ""),
      (.rate_limits.five_hour.used_percentage  // ""),
      (.rate_limits.five_hour.resets_at        // ""),
      (.rate_limits.seven_day.used_percentage  // ""),
      (.rate_limits.seven_day.resets_at        // "")
    ] | map(tostring) | join("\u001f")'
)"

dir=$(basename "$cwd")

branch=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi

DIR_COLOR='\033[2;36m'
BRANCH_COLOR='\033[2;33m'
MODEL_COLOR='\033[1;35m'
CTX_COLOR='\033[2;32m'
LIMIT_OK='\033[2;32m'
LIMIT_WARN='\033[1;33m'
LIMIT_HIGH='\033[1;31m'
RESET='\033[0m'

sep() {
  printf '\033[2;37m|\033[0m'
}

# Renders one rate-limit window, e.g. "5h 23%". Unlike ctx, which counts down, these
# count *up* toward the cap, so the color escalates as the number grows. The reset
# clock only appears past 80%, where knowing when the window clears starts to matter.
limit_segment() {
  local label=$1 pct=$2 resets_at=$3
  local rounded color countdown="" secs_left hours mins

  [ -n "$pct" ] || return 0
  rounded=$(printf '%.0f' "$pct")

  if [ "$rounded" -ge 80 ]; then
    color=$LIMIT_HIGH
  elif [ "$rounded" -ge 50 ]; then
    color=$LIMIT_WARN
  else
    color=$LIMIT_OK
  fi

  if [ "$rounded" -ge 80 ] && [ -n "$resets_at" ]; then
    secs_left=$((resets_at - $(date +%s)))
    if [ "$secs_left" -gt 0 ]; then
      hours=$((secs_left / 3600))
      mins=$(((secs_left % 3600) / 60))
      if [ "$hours" -gt 0 ]; then
        countdown=$(printf ' ↻%dh%02dm' "$hours" "$mins")
      else
        countdown=$(printf ' ↻%dm' "$mins")
      fi
    fi
  fi

  printf "${color}%s %s%%%s${RESET}" "$label" "$rounded" "$countdown"
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

# Absent for API-key users, and for subscribers until the session's first API response.
for window in "5h:$limit5:$reset5" "7d:$limit7:$reset7"; do
  IFS=: read -r label pct resets_at <<<"$window"
  segment=$(limit_segment "$label" "$pct" "$resets_at")
  [ -n "$segment" ] && output="${output} $(sep) ${segment}"
done

printf '%s\n' "$output"
