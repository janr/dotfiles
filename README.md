# Dotfiles

Personal dotfiles managed with GNU Stow.

## Layout

Each top-level directory is a Stow package. The package contents mirror the paths
that should exist under your home directory.

Current packages:

- `bin`
- `hypr`
- `kitty`
- `nvim`
- `share`
- `waybar`

For example, `hypr/.config/hypr/hyprland.conf` is linked to
`~/.config/hypr/hyprland.conf`.

## Hyprland Features

The Hyprland config is a translation of an AwesomeWM setup, keeping the same
Super-key driven workflow where possible.

- Uses `SUPER` as the main modifier.
- Starts Waybar, hyprpaper, the custom workspace watcher, `nm-applet`, and
  Zen on login.
- Uses `kitty` for the terminal, `wofi --show run` for the launcher, and
  Zen as the browser.
- Sets Yaru cursor themes for both Hyprland and XWayland cursor variables.
- Uses a 2x scale on the laptop panel (`eDP-1`) and places additional monitors
  above it with matching scale.
- Lets the workspace watcher own lid-close policy so Thunderbolt displays can
  finish attaching after a closed-lid dock wake; an undocked lid close still
  suspends after a short hotplug grace period.
- Enables focus-follow-mouse behavior.
- Uses the Hyprland `master` layout with an Awesome-like master factor.
- Defaults the portrait Samsung display to a top-master orientation so windows
  stack vertically on the rotated monitor.
- Supports rotating the master layout orientation counter-clockwise with
  `SUPER+,` and clockwise with `SUPER+.`.
- Keeps a compact Awesome-like visual style: no gaps, simple borders, modest
  rounding, blur, glow accents, no shadows, and dimmed inactive windows.
- Adds floating and centered rules for common dialogs, file pickers, portal
  windows, and utilities such as `pinentry`, `blueman-manager`, `Gpick`, and
  Tor Browser.
- Provides Awesome-style workspace controls through
  `~/.config/hypr/scripts/awesome-workspaces`.
- Maps laptop workspaces to `1-9` and external-monitor workspaces to `10-18`,
  while presenting both sets as `1-9` in Waybar.
- Supports direct external workspace access with `SUPER+CTRL+1` through
  `SUPER+CTRL+9`, and moving windows there with `SUPER+CTRL+SHIFT+1` through
  `SUPER+CTRL+SHIFT+9`.
- Includes bindings for window cycling, swapping, moving between workspaces,
  fullscreen modes, pinning, moving windows across monitors, and swapping with
  the master window.
- Includes local cheatsheets for Hyprland (`SUPER+SHIFT+H`), Neovim
  (`SUPER+SHIFT+N`), and Pi (`SUPER+SHIFT+P`).
- Supports `SUPER+Left/Right` for occupied-workspace navigation across `1-18`
  with one connected display, or within the focused display's workspace set with
  multiple connected displays.
- Supports `SUPER+CTRL+Left/Right` for all-workspace navigation on the focused
  display, and `SUPER+SHIFT+Left/Right` for moving the focused window between
  workspaces.
- Supports `SUPER+Up/Down` for first/last empty workspace navigation on the
  focused display, and `SUPER+SHIFT+Up/Down` for moving the focused window there.
- Supports `SUPER+CTRL+R` to reload Hyprland, restart Waybar, restart
  hyprpaper, and restart the custom workspace watcher.
- Uses `hyprpaper` with the bundled `dark_cubes.jpg` wallpaper as the fallback for all displays.

## Waybar Features

The Waybar config is a compact top bar designed for the Hyprland workspace setup.

- Places the bar at the top with a height of 34px.
- Shows the output's Hyprland workspaces on the left, the focused window title
  in the center, and tray, volume, battery, and clock modules on the right.
- Uses the custom Awesome-style workspace script for scroll navigation.
- Uses separate output-scoped bars: `eDP-1` shows workspaces `1-9`, while
  non-`eDP-1` outputs show external workspaces `10-18`.
- When the external display is disconnected, occupied `10-18` workspaces are
  shown on the `eDP-1` bar until they are empty.
- Displays external workspaces `10-18` as `1-9` with a subtly different pill
  color.
- Limits window titles to 70 characters and keeps titles separate per output.
- Provides a system tray with 16px icons.
- Shows PulseAudio volume, supports 5% scroll steps, and opens `pavucontrol` on
  click.
- Shows current weather from `wttr.in`, using `WAYBAR_WEATHER_LOCATION` when it
  is set and network-inferred location otherwise, with day/night icons based on
  sunrise and sunset.
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
stow -t ~ bin hypr kitty nvim share waybar
```

Remove links manually:

```sh
stow -D -t ~ bin hypr kitty nvim share waybar
```
