export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git" '
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# zsh-fzf-history-search binds ^R in the emacs keymap only, but zsh-vi-mode
# leaves us in viins, so Ctrl+R fell through to the builtin search. ZVM resets
# keymaps at init, so this has to run from its post-init hook to survive.
zvm_after_init_commands+=('bindkey -M viins "^R" fzf_history_search')
