# Dotfiles

Personal dotfiles managed with GNU Stow.

## Layout

Each top-level directory is a Stow package. The package contents mirror the paths
that should exist under your home directory.

Current packages:

- `hypr`
- `waybar`

For example, `hypr/.config/hypr/hyprland.conf` is linked to
`~/.config/hypr/hyprland.conf`.

## Install

Create the symlinks:

```sh
make install
```

Preview what Stow would do without changing files:

```sh
make dry-run
```

## Remove

Remove the symlinks:

```sh
make remove
```

## Manual Stow Commands

This repository is in `~/src/dotfiles`, so the Stow target must be your home
directory:

```sh
stow -t ~ hypr waybar
```

Remove links manually:

```sh
stow -D -t ~ hypr waybar
```

