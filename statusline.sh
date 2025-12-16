#!/bin/bash
set -euo pipefail

# Enhanced statusline for Claude Code with accurate context tracking and real cost display
#  Sonnet 4.5  · Ctx: │            │   9% · ⇣ 10.2K ⇡ 2.3K ($0.092) · Thursday, Dec 11
# 
# Requirement: Nerd Font in your terminal
# Directly add a statusLine command to your .claude/settings.json:
# {
#   "statusLine": {
#     "type": "command",
#     "command": "~/.claude/statusline.sh",
#     "padding": 0 // Optional: set to 0 to let status line go to edge
#   }
# }
#
# FEATURES:
# - Context percentage: Current window usage (not cumulative), solving the /clear issue
# - Cost: Actual billed amount from Claude Code (not estimated)
# - Session tokens: Cumulative totals for reference
# - Date: Current day and time context
#
# TECHNICAL:
# - Context percentage: Uses current_usage field from Claude Code (v2.0.70+) for accurate context tracking
#   Falls back to total_tokens if current_usage is null (new sessions)
# - Cost: Uses real cost from Claude Code's cost.total_cost_usd field (actual billing data)
#   Shows $0.000 if cost data not yet available (new sessions)
# - current_usage provides: input_tokens + cache_creation_input_tokens + cache_read_input_tokens
# - Context percentage accurately reflects when to clear/compact, cost shows actual billing

input=$(cat)

# Extract data once
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens')
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size')
MODEL=$(echo "$input" | jq -r '.model.display_name')
REAL_COST=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
CURRENT_USAGE=$(echo "$input" | jq -c '.context_window.current_usage // null')

# Color definitions
readonly COLOR_RESET='\033[0m'
readonly COLOR_MODEL='\033[38;5;147m'
readonly COLOR_GREY='\033[38;5;245m'
readonly COLOR_BAR_TEXT='\033[38;5;250m'
readonly COLOR_BAR_BG='\033[48;5;237m'
readonly -a COLOR_BAR_FILL=(
    $'\033[48;5;255m'  # 0-69%: white
    $'\033[48;5;208m'  # 70-89%: yellow-orange
    $'\033[48;5;196m'  # 90%+: red
)

# Constants
readonly BAR_WIDTH=12

# Format number with K/M suffixes
format_number() {
    local num=$1
    if (( num >= 1000000 )); then
        printf "%.1fM" $((num / 100000)).$((num % 100000 / 10000))
    elif (( num >= 1000 )); then
        printf "%.1fK" $((num / 1000)).$((num % 1000 / 100))
    else
        printf "%d" "$num"
    fi
}

# Get current context tokens from current_usage field
get_current_context_tokens() {
    local current_usage=$1
    local total_tokens=$2

    # If current_usage is null or empty, fall back to total tokens (session just started)
    if [[ "$current_usage" == "null" || -z "$current_usage" ]]; then
        echo "$total_tokens"
        return
    fi

    # Calculate current context: input_tokens + cache tokens
    local context_tokens
    context_tokens=$(echo "$current_usage" | jq '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)')

    # Validate result is numeric
    [[ "$context_tokens" =~ ^[0-9]+$ ]] && echo "$context_tokens" || echo "$total_tokens"
}

# Get bar color based on percentage
get_bar_color() {
    local percent=$1
    if (( percent < 70 )); then
        echo "${COLOR_BAR_FILL[0]}"
    elif (( percent < 90 )); then
        echo "${COLOR_BAR_FILL[1]}"
    else
        echo "${COLOR_BAR_FILL[2]}"
    fi
}

# Build progress bar
build_progress_bar() {
    local percent=$1
    local fill_width=$((percent * BAR_WIDTH / 100))
    local bar_color=$(get_bar_color "$percent")
    local bar=""

    for ((i = 0; i < BAR_WIDTH; i++)); do
        if (( i < fill_width )); then
            bar+="${bar_color} ${COLOR_RESET}"
        else
            bar+="${COLOR_BAR_BG} ${COLOR_RESET}"
        fi
    done
    echo "$bar"
}

# Format cost with 3 decimal places
format_cost() {
    local cost=$1
    printf "%.3f" "$cost" | sed 's/^\./0./'
}

# Main calculations
TOTAL_TOKENS=$((INPUT_TOKENS + OUTPUT_TOKENS))
CURRENT_CONTEXT_TOKENS=$(get_current_context_tokens "$CURRENT_USAGE" "$TOTAL_TOKENS")
PERCENT_USED=$((CURRENT_CONTEXT_TOKENS * 100 / CONTEXT_SIZE))

# Use real cost from Claude Code, default to 0 if not available
if [[ "$REAL_COST" != "null" && "$REAL_COST" != "" ]]; then
    COST=$REAL_COST
else
    COST=0
fi

# Format all components
PROGRESS_BAR=$(build_progress_bar "$PERCENT_USED")
INPUT_FMT=$(format_number "$INPUT_TOKENS")
OUTPUT_FMT=$(format_number "$OUTPUT_TOKENS")
COST_FMT=$(format_cost "$COST")
DATE_FMT=$(date "+%A, %b %-d")

# Output final status line
printf "${COLOR_GREY}${COLOR_RESET} ${COLOR_MODEL}%-11s${COLOR_RESET} ${COLOR_GREY}·${COLOR_RESET} ${COLOR_GREY}Ctx:${COLOR_RESET} ${COLOR_BAR_TEXT}│${PROGRESS_BAR}│${COLOR_RESET} ${COLOR_GREY}%3d%%${COLOR_RESET} ${COLOR_GREY}·${COLOR_RESET} ${COLOR_GREY}⇣${COLOR_RESET} ${COLOR_MODEL}%s${COLOR_RESET} ${COLOR_GREY}⇡${COLOR_RESET} ${COLOR_MODEL}%s${COLOR_RESET} ${COLOR_GREY}(${COLOR_MODEL}\$${COLOR_MODEL}%s${COLOR_GREY}) ${COLOR_GREY}·${COLOR_RESET} ${COLOR_GREY}%s${COLOR_RESET}\n" \
    "$MODEL" \
    "$PERCENT_USED" \
    "$INPUT_FMT" \
    "$OUTPUT_FMT" \
    "$COST_FMT" \
    "$DATE_FMT"
