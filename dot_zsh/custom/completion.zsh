# Completion behaviour. compinit itself runs from plugins.zsh, later than this
# file; these are all consulted at completion time rather than at load, so
# setting them first is fine.

zmodload zsh/complist

zstyle ':completion:*' menu select

# Tried in order, each only if the previous found nothing: exact, then
# case-insensitive, then partial-word (f.b -> foo.bar), then substring.
zstyle ':completion:*' matcher-list '' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# Scoped to completion rather than exporting LS_COLORS, which other tools read.
zstyle ':completion:*' list-colors 'di=1;34' 'ln=1;36' 'so=1;35' 'pi=33' \
  'ex=1;32' 'bd=1;33' 'cd=1;33' 'su=1;31' 'sg=1;31' 'tw=1;34' 'ow=1;34'

zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%B%d%b%f'
zstyle ':completion:*:warnings'     format '%F{red}no matches%f'

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# `cd ../<TAB>` shouldn't offer the directory you're already in.
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# hjkl in the completion menu, to match the vi-mode everywhere else.
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
