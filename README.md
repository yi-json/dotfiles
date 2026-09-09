# dotfiles

Personal dotfiles, symlinked into `$HOME` via `install.sh`.

## Install

```sh
git clone git@github.com:yi-json/dotfiles.git ~/github/dotfiles
cd ~/github/dotfiles
./install.sh
```

This installs prerequisites, symlinks each file below into `$HOME` (backing up any
existing file to `~/.dotfiles_backup/<timestamp>/` first), then sets up oh-my-zsh.

Prerequisites (skipped if already installed):

- Rust/cargo (via `rustup`), then `jj-cli` installed with `cargo install`

Then oh-my-zsh setup:

- clones `powerlevel10k` into `$ZSH_CUSTOM/themes/`
- clones `zsh-autosuggestions` and `zsh-syntax-highlighting` into `$ZSH_CUSTOM/plugins/`
- downloads the `coolnight` iTerm2 color scheme to `~/Downloads/`
- rewrites the `plugins=(...)` line in `~/.zshrc` to `plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)`
- rewrites the `ZSH_THEME=` line in `~/.zshrc` to `ZSH_THEME="powerlevel10k/powerlevel10k"`
- merges any remaining blocks from the repo's `zshrc` into `~/.zshrc` (instant-prompt
  block, autosuggestion tab-accept widget, p10k source line), skipping any block
  already present so nothing is duplicated on re-runs
