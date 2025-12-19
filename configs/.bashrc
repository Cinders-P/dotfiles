# ~/.bashrc: executed by bash(1) for non-login shells.

[ -z "$PS1" ] && return

# allow less to view more file types
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

shopt -s checkwinsize # resize display to match window after command

# directories
shopt -s autocd # cd without writing cd
shopt -s cdspell # autocorrect typos for cd

# globbing *
shopt -s nocaseglob
shopt -s dotglob
shopt -s extglob # extended glob
shopt -s globstar # allow ** recursive glob
shopt -s failglob # can change to nullglob

# history
shopt -s cmdhist # save multiline commands as one (default=on)
shopt -s lithist # save embedded newlines instead of using ;
#shopt -s histverify # do not run ! expansions automatically

# check suspended jobs before exit
shopt -s checkjobs

# expand backslash-escapes in echo
# or use echo -e
#shopt -s xpg_echo

# This shares history betwen shells, but only syncs when the a new prompt is calculated
shopt -s histappend
export HISTCONTROL=""
export HISTSIZE=20000                          
export HISTFILESIZE=20000
PROMPT_COMMAND="history -a; history -n;$PROMPT_COMMAND"

if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

[ -f ~/.exports ] && source ~/.exports # path, keys
[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
command -v mise >/dev/null 2>&1 && eval "$(mise activate bash)"
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

