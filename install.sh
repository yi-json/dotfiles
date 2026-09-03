#!/usr/bin/env bash
# Symlinks this repo's dotfiles into $HOME.
# Existing files/symlinks at the destination are backed up to ~/.dotfiles_backup/<timestamp>/.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d%H%M%S)"

echo "Checking prerequisites..."

if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
    if ! grep -qF 'eval "$(/opt/homebrew/bin/brew shellenv)"' "$HOME/.zprofile" 2>/dev/null; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! command -v cargo >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck disable=SC1091
    . "$HOME/.cargo/env"
fi

if ! command -v jj >/dev/null 2>&1; then
    cargo install --locked jj-cli
fi

# map: repo file -> destination path in $HOME
declare -a LINKS=(
    "tmux.conf:.tmux.conf"
    "jj_config.toml:.config/jj/config.toml"
)

for entry in "${LINKS[@]}"; do
    src="${entry%%:*}"
    dest_rel="${entry##*:}"
    src_path="$REPO_DIR/$src"
    dest_path="$HOME/$dest_rel"

    mkdir -p "$(dirname "$dest_path")"

    if [ -e "$dest_path" ] || [ -L "$dest_path" ]; then
        if [ -L "$dest_path" ] && [ "$(readlink "$dest_path")" = "$src_path" ]; then
            echo "skip   $dest_rel (already linked)"
            continue
        fi
        mkdir -p "$BACKUP_DIR"
        mv "$dest_path" "$BACKUP_DIR/$(basename "$dest_rel")"
        echo "backed up existing $dest_rel -> $BACKUP_DIR/"
    fi

    ln -s "$src_path" "$dest_path"
    echo "linked $dest_rel -> $src_path"
done

if [ -d "$BACKUP_DIR" ]; then
    echo
    echo "Backups saved to $BACKUP_DIR"
fi

echo
echo "Setting up oh-my-zsh plugins/theme..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_if_missing() {
    local repo_url="$1"
    local dest="$2"
    if [ -d "$dest" ]; then
        echo "skip   $dest (already cloned)"
    else
        git clone --depth 1 "$repo_url" "$dest"
    fi
}

clone_if_missing "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k"
clone_if_missing "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

mkdir -p "$HOME/Downloads"
curl -fsSL "https://raw.githubusercontent.com/josean-dev/dev-environment-files/main/coolnight.itermcolors" \
    --output "$HOME/Downloads/coolnight.itermcolors"

if [ -f "$HOME/.zshrc" ]; then
    if grep -qE '^plugins=\(' "$HOME/.zshrc"; then
        sed -i.bak -E 's/^plugins=\(.*\)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)/' "$HOME/.zshrc"
        rm -f "$HOME/.zshrc.bak"
        echo "updated plugins= line in ~/.zshrc"
    else
        echo "warning: no plugins= line found in ~/.zshrc, skipping"
    fi

    if grep -qE '^ZSH_THEME=' "$HOME/.zshrc"; then
        sed -i.bak -E 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
        rm -f "$HOME/.zshrc.bak"
        echo "updated ZSH_THEME= line in ~/.zshrc"
    else
        echo "warning: no ZSH_THEME= line found in ~/.zshrc, skipping"
    fi
else
    echo "warning: ~/.zshrc not found, skipping plugins/theme update"
fi
