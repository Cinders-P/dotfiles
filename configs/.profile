# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n 2> /dev/null || true

# Check runner is an interactive shell that isn't piped or redirected,
# and also supports colors.This prevents programs that start shell 
# processes from triggering fastfetch.
if [[ $- == *i* ]] && [[ -t 1 ]] && ! [[ -n "$TMUX" ]]; then
    fastfetch
fi
