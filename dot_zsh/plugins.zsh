# Plugin loading, via antidote in static mode: the .txt files are the source of
# truth and the .zsh files beside them are generated, regenerated whenever a list
# is newer. antidote itself is autoloaded, so it costs nothing unless a list
# changed.

export ZVM_INIT_MODE=sourcing

fpath+=("$BREW_ROOT/opt/antidote/share/antidote/functions")
autoload -Uz antidote

() {
  local txt
  for txt in "$ZSH"/zsh_plugins{_fpath,}.txt; do
    [[ -e "${txt%.txt}.zsh" && ! "$txt" -nt "${txt%.txt}.zsh" ]] && continue
    antidote bundle <"$txt" >| "${txt%.txt}.zsh"
  done
}

source "$ZSH/zsh_plugins_fpath.zsh"

# compinit's security audit is the expensive part of it, so run the full check
# once a day and skip it the rest of the time.
autoload -Uz compinit
() {
  setopt localoptions extendedglob
  local dump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
  [[ -d "${dump:h}" ]] || mkdir -p "${dump:h}"
  if [[ -n "$dump"(#qN.mh-24) ]]; then
    compinit -C -d "$dump"
  else
    compinit -d "$dump"
  fi
}

source "$ZSH/zsh_plugins.zsh"
