# Ensure zsh-vi-mode doesn't break other things
export ZVM_INIT_MODE=sourcing

# Manage zplug with zplug
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# completion and some niceties for AWS CLI
zplug "eastokes/aws-plugin-zsh"

# Complete all the things
zplug "zsh-users/zsh-completions"

# Docker completions
zplug "greymd/docker-zsh-completion"

# Blaaaaaah
zplug "dracula/zsh", use:"dracula.zsh-theme"

# Use FZF for history search (Ctrl+R)
zplug "joshskidmore/zsh-fzf-history-search"

# Git helpers stolen from omz
zplug "plugins/git", from:oh-my-zsh

# Enable `git open` command
zplug "paulirish/git-open"

# Completions for 1password commandline
zplug "sirhc/op.plugin.zsh"

# Enable faster parsing for `rake` commands
zplug "unixorn/rake-completion.zshplugin"

# Wrapper for terraform
zplug "jsporna/terraform-zsh-plugin"

# Remind me if I forgot my aliases
zplug "MichaelAquilina/zsh-you-should-use"

# vi mode, of course
zplug "jeffreytse/zsh-vi-mode"

# Auto-suggest completions for commands
zplug "zsh-users/zsh-autosuggestions"

# Auto-match paired punctuation (e.g. ' " and ())
zplug "hlissner/zsh-autopair", defer:3

# Syntax highlighting!
zplug "zsh-users/zsh-syntax-highlighting", defer:3

zplug load
