# macOS /etc/zshrc sets SAVEHIST=1000 and silently truncates once you pass it.
HISTSIZE=50000
SAVEHIST=50000

# Use space at the start of a command to keep it from being logged in the
# history file (good for commands with any sensitive data)
setopt HIST_IGNORE_SPACE

setopt EXTENDED_HISTORY     # timestamp + duration per entry
setopt SHARE_HISTORY        # live sync across open shells
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY          # load !! into the buffer instead of running it
setopt HIST_FCNTL_LOCK      # locking via fcntl, safe for concurrent writes
