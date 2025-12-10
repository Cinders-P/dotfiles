if [[ $- == *i* ]] && [[ -t 1 ]] && ! [[ -n "$TMUX" ]]; then
    fastfetch
fi