if [[ $- == *i* ]] && [[ -t 1 ]] && ! [[ -n "$TMUX" ]]; then
    command -v fastfetch >/dev/null 2>&1 && fastfetch
fi