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

## Hyprland Features

The Hyprland config is a translation of an AwesomeWM setup, keeping the same
Super-key driven workflow where possible.

- Uses `SUPER` as the main modifier.
- Starts Waybar, hyprpaper, the custom workspace watcher, `nm-applet`, and
  Google Chrome on login.
- Uses `x-terminal-emulator` for the terminal, `wofi --show drun` for the
  launcher, and Google Chrome as the browser.
- Sets Yaru cursor themes for both Hyprland and XWayland cursor variables.
- Uses a 2x scale on the laptop panel (`eDP-1`) and places additional monitors
  above it with matching scale.
- Enables focus-follow-mouse behavior.
- Uses the Hyprland `master` layout with an Awesome-like master factor of
  `0.618`.
- Keeps a minimal Awesome-like visual style: no gaps, square corners, simple
  borders, no blur, no shadows, and dimmed inactive windows.
- Adds floating and centered rules for common dialogs, file pickers, portal
  windows, and utilities such as `pinentry`, `blueman-manager`, `Gpick`, and
  Tor Browser.
- Provides Awesome-style workspace controls through
  `~/.config/hypr/scripts/awesome-workspaces`.
- Maps laptop workspaces to `1-9` and external-monitor workspaces to `10-18`,
  while presenting both sets as `1-9` in Waybar.
- Supports direct external workspace access with `SUPER+ALT+1` through
  `SUPER+ALT+9`.
- Includes bindings for window cycling, swapping, moving between workspaces,
  fullscreen modes, pinning, moving windows across monitors, and swapping with
  the master window.
- Supports `SUPER+Left/Right` for workspace navigation and
  `SUPER+SHIFT+Left/Right` for moving the focused window between workspaces.
- Supports `SUPER+CTRL+R` to reload Hyprland and reconcile workspace state.
- Uses `hyprpaper` with the bundled `dark_cubes.jpg` wallpaper on `eDP-1`.

## Waybar Features

The Waybar config is a compact top bar designed for the Hyprland workspace setup.

- Places the bar at the top with a height of 34px.
- Shows Hyprland workspaces on the left, the focused window title in the center,
  and tray, volume, battery, and clock modules on the right.
- Uses the custom Awesome-style workspace script for scroll navigation.
- Shows only the workspaces assigned to the current monitor, which prevents
  stale hotplug assignments from displaying both laptop and external workspace
  sets on one bar.
- Displays workspaces `10-18` as `1-9` so external-monitor workspaces look like
  a normal local tag set.
- Limits window titles to 70 characters and keeps titles separate per output.
- Provides a system tray with 16px icons.
- Shows PulseAudio volume, supports 5% scroll steps, and opens `pavucontrol` on
  click.
- Shows battery charging, plugged, warning, and critical states.
- Shows the clock as weekday, month, day, and 12-hour time, with an ISO date in
  the tooltip.
- Uses JetBrains Mono Nerd Font first, with Noto Sans as fallback.
- Uses transparent bar background with compact rounded module containers and
  Catppuccin-like colors.

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

