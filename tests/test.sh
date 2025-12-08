#!/bin/bash
# Test script to run setup.sh in a fresh Ubuntu container

DOTFILES_ROOT="$(realpath "$(dirname "$0")/..")"

echo "🐳 Starting fresh Ubuntu container..."

docker run -it --rm \
  -v "$DOTFILES_ROOT:/home/ubuntu/dotfiles" \
  -w /home/ubuntu/dotfiles \
  ubuntu:latest bash tests/test-input.sh

# script is related to the working directory -w
# -c '<cmd1><cmd2>' to run direct commands