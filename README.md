# dotfiles

Personal dotfiles, symlinked into `$HOME` via `install.sh`.

## Install

```sh
git clone git@github.com:yi-json/dotfiles.git ~/github/dotfiles
cd ~/github/dotfiles
./install.sh
```

This symlinks each file below into `$HOME` (backing up any existing file to
`~/.dotfiles_backup/<timestamp>/` first).
