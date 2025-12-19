#!/bin/bash
set -eu -o pipefail -o errtrace # fail fast

# completions stored in:
# ~/.local/share/bash-completion/completions/
# ~/.local/share/zsh/completions/ (not /usr/local/share/zsh/site-functions/)

# Simple install for a fresh box
export DEBIAN_FRONTEND=noninteractive
sudo -E apt update
sudo -E apt install -y curl git ca-certificates wget build-essential perl vim shellcheck

git config --global http.postBuffer 1048576000
git config --global http.maxRequestBuffer 100M
git config --global core.compression 0

# Extend sudo timeout from default 15 minutes to 60 minutes
if [[ ! -f /etc/sudoers.d/timeout ]]; then
    echo "Defaults timestamp_timeout=60" | sudo tee /etc/sudoers.d/timeout > /dev/null
    sudo chmod 440 /etc/sudoers.d/timeout
    sudo visudo -c -q
fi


### VIM SECTION ###

echo "Setting up vim..."
mkdir -p ~/.vim/pack/plugins/start

# commentary.vim - adds motions for commenting lines
if [[ ! -d ~/.vim/pack/plugins/start/commentary ]]; then
    git clone https://tpope.io/vim/commentary.git ~/.vim/pack/plugins/start/commentary
    vim -u NONE -c "helptags ~/.vim/pack/plugins/start/commentary/doc" -c q
fi

# vim-signature - shows marks in the gutter
if [[ ! -d ~/.vim/pack/plugins/start/vim-signature ]]; then
    git clone https://github.com/kshenoy/vim-signature.git ~/.vim/pack/plugins/start/vim-signature
    vim -u NONE -c "helptags ~/.vim/pack/plugins/start/vim-signature/doc" -c q
fi

# fzf.vim - open files with fuzzy finder
if [[ ! -d ~/.fzf ]] && ! command -v fzf &> /dev/null; then
    git clone https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi

if [[ ! -d ~/.vim/pack/plugins/start/fzf.vim ]]; then
    git clone https://github.com/junegunn/fzf.vim.git ~/.vim/pack/plugins/start/fzf.vim
    vim -u NONE -c "helptags ~/.vim/pack/plugins/start/fzf.vim/doc" -c q
fi

# Create a symlink to the main fzf installation
ln -sf ~/.fzf ~/.vim/pack/plugins/start/fzf

### SHELL SECTION ###

echo "Setting up shell..."

# bash-completion
sudo apt install -y bash-completion zsh libpcre3-dev
sudo apt install -y keychain 2>/dev/null || echo "  ⚠ Skipping keychain (not available in this repository)"
mkdir -p ~/.local/share/bash-completion/completions
mkdir -p ~/.local/share/zsh/completions
mkdir -p ~/.local/bin

# Starship
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir ~/.local/bin
fi

# zsh-autosuggestions
if [[ ! -d ~/.zsh/zsh-autosuggestions ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [[ ! -d ~/.zsh/zsh-syntax-highlighting ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
fi


### OTHER TOOLS ###

# mise-en-place
if ! command -v mise &> /dev/null; then
    curl https://mise.run | sh -s -- -y
fi

# Add ~/.local/bin to PATH for current session to call mise
export PATH="$HOME/.local/bin:$PATH"
mise use -g python pipx uv

# general build tools for 'make'
sudo apt install -y autoconf automake pkg-config yacc build-essential libevent-dev libncurses-dev libpcre3-dev zlib1g-dev liblzma-dev file
curl -fSsL "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux" > ~/.local/share/bash-completion/completions/tmux

# zoxide - autojump to directories
mise use -g zoxide

# usage is needed to generate the completions
mise use -g usage
mise completion bash --include-bash-completion-lib > ~/.local/share/bash-completion/completions/mise
mise completion zsh > ~/.local/share/zsh/completions/_mise # underscore important for zsh

mise use -g fastfetch

mise use -g tmux ripgrep fd ag jq tmux bat 
# if bat is installed as 'batcat', create symlink to alias
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/batcat ~/.local/bin/bat
fi
# fd has a naming conflict on Ubuntu, override
#echo "alias fd='fdfind'" | tee -a ~/.bashrc ~/.zshrc

mise use -g node
eval "$(mise activate bash)" # register new binaries to use npm
npm completion > ~/.local/share/bash-completion/completions/npm
npm completion > ~/.local/share/zsh/completions/_npm
pip completion --bash > ~/.local/share/bash-completion/completions/pip
pip completion --zsh > ~/.local/share/zsh/completions/_pip

pipx install tldr # similarly, curl cheat.sh/ip
pipx install argcomplete
register-python-argcomplete pipx | tee ~/.local/share/bash-completion/completions/pipx ~/.local/share/zsh/completions/_pipx > /dev/null

uv generate-shell-completion bash > ~/.local/share/bash-completion/completions/uv
uv generate-shell-completion zsh > ~/.local/share/zsh/completions/_uv

### CONFIGS SECTION ###

echo "Linking dotfiles..."
( # change shopt in subshell to avoid affecting current session
    shopt -s dotglob
    for file in configs/*; do
        [[ -f "$file" ]] || continue # skip dirs
        [[ "$(basename "$file")" == ".ssh" ]] && continue # skip .ssh

        ln -sf "$(pwd)/$file" ~/"$(basename "$file")"
        echo "  ✓ $(basename "$file")"
    done
)
# fastfetch config
mkdir -p ~/.config/fastfetch
ln -sf "$(pwd)/fastfetch.jsonc" ~/.config/fastfetch/config.jsonc

# Starship config
ln -sf "$(pwd)/starship.toml" ~/.config/

sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

### GIT CONFIGURATION ###

echo "Configuring Git..."

git config --global core.editor "vim"
git config --global init.defaultBranch main
git config --global push.default simple # only push current branch to upstream
git config --global diff.colorMoved zebra # show colored diffs
git config --global color.ui true # show colors in git

git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

echo "Git configured! Set your name and email with:"
echo "  git config --global user.name 'Your Name'"
echo "  git config --global user.email 'your.email@example.com'"

### SSH SETUP ###
echo "Setting up SSH..."
mkdir -p ~/.ssh/sockets
chmod 700 ~/.ssh
ln -sf "$(pwd)/configs/.ssh" ~/.ssh/config
chmod 600 ~/.ssh/config
echo "SSH directory and config created."

# Examples

# ssh-keygen -t ed25519 -C "your.email@example.com"
# Press Enter to accept default location (~/.ssh/id_ed25519)
# Enter a passphrase when prompted

# cat ~/.ssh/id_ed25519.pub
# Copy the output and paste it into GitHub:
# Settings → SSH and GPG keys → New SSH key

# ssh -T git@github.com
# Should see: "Hi username! You've successfully authenticated..."

# On a server, add it to authorized_keys
# ssh-copy-id username@remote_host
# ssh-copy-id -i path/to/certificate username@remote_host

# or manually without ssh-copy-id...
# cat ~/.ssh/id_ed25519.pub
# echo "ssh-ed25519 AAAAC3... your.email@example.com" >> ~/.ssh/authorized_keys
# chmod 600 ~/.ssh/authorized_keys

# Forwarding local keys, -A flag
# ssh -A user@host-ip

# Proxy jump to access private servers, -J flag
# ssh -J user@jumpbox user@target

echo "Done!"
echo "Restart your session with 'exec $(basename $SHELL)' to apply changes."
echo "You will need to install Docker and its completions manually."
echo "See https://docs.docker.com/engine/install/ubuntu and https://docs.docker.com/engine/cli/completion/ for instructions."