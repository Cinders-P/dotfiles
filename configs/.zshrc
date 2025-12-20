# ~/.zshrc: ZSH configuration file

# ─────────────────────────────────────────────────────────────────────────────
# Completions
# ─────────────────────────────────────────────────────────────────────────────
fpath=(~/.local/share/zsh/completions $fpath)
autoload -Uz compinit && compinit

# ─────────────────────────────────────────────────────────────────────────────
# Directory Navigation
# ─────────────────────────────────────────────────────────────────────────────
setopt auto_cd              # cd without typing cd
setopt cdable_vars          # expand variables in cd paths
setopt correct              # autocorrect typos in commands

# ─────────────────────────────────────────────────────────────────────────────
# Globbing
# ─────────────────────────────────────────────────────────────────────────────
setopt no_case_glob         # case-insensitive globbing
setopt extended_glob        # extended glob patterns (#, ~, ^)
setopt glob_dots            # include dotfiles in globbing
# Note: ZSH has ** recursive glob built-in (no extra option needed)
# Note: nomatch (fail on no glob match) is default in ZSH

# ─────────────────────────────────────────────────────────────────────────────
# History
# ─────────────────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=20000

setopt append_history       # append to history file instead of overwriting
setopt inc_append_history   # write to history immediately, not on shell exit
setopt share_history        # share history between all sessions
setopt hist_reduce_blanks   # remove extra blanks from commands
setopt bang_hist            # allow ! to be used in history expansion

# ─────────────────────────────────────────────────────────────────────────────
# Job Control
# ─────────────────────────────────────────────────────────────────────────────
setopt check_jobs           # warn about suspended jobs before exiting

# ─────────────────────────────────────────────────────────────────────────────
# Imports
# ─────────────────────────────────────────────────────────────────────────────
[ -f ~/.exports ] && source ~/.exports
[ -f ~/.aliases ] && source ~/.aliases

# ─────────────────────────────────────────────────────────────────────────────
# Plugins
# ─────────────────────────────────────────────────────────────────────────────
[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# ─────────────────────────────────────────────────────────────────────────────
# Tool Initialization
# ─────────────────────────────────────────────────────────────────────────────
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
