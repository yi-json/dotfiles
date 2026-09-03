#!/usr/bin/env bash
# Symlinks this repo's dotfiles into $HOME.
# Existing files/symlinks at the destination are backed up to ~/.dotfiles_backup/<timestamp>/.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d%H%M%S)"

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
