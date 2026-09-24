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
- `hypr-cachyos` (CachyOS's Lua-based Hyprland overlay)
- `noctalia` (CachyOS's panel and desktop-shell preferences)

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
- Lets the workspace watcher own lid-close policy so Thunderbolt/MST displays
  can finish attaching after a closed-lid dock wake, waits for multi-monitor
  hotplug to settle before rebuilding Waybar, and still suspends on an undocked
  lid close after a short grace period.
- Enables focus-follow-mouse behavior.
- Keeps Noctalia notification popups on whichever monitor currently has focus.
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
- Sends a PDF open in a viewer or a PDF/arXiv browser tab on the active
  workspace to reMarkable Cloud with `SUPER+SHIFT+R`.
- Supports `SUPER+Left/Right` for occupied-workspace navigation across `1-18`
  with one connected display, or within the focused display's workspace set with
  multiple connected displays.
- Supports `SUPER+CTRL+Left/Right` for all-workspace navigation on the focused
  display, and `SUPER+SHIFT+Left/Right` for moving the focused window between
  workspaces.
- Supports `SUPER+Up/Down` for first/last empty workspace navigation on the
  focused display, and `SUPER+SHIFT+Up/Down` for moving the focused window there.
- Opens a terminal on the first empty workspace of the focused display with
  `SUPER+SHIFT+Enter`, or on the current workspace if none is empty.
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

GNU Stow is required. Install it before running any Make target:

```sh
# Ubuntu
sudo apt install stow

# CachyOS / Arch
sudo pacman -S --needed stow
```

The reMarkable shortcut additionally needs `curl`, `jq`, `wl-clipboard`, and
`libnotify`. `make install`, `make install-ubuntu`, and `make install-cachyos`
automatically download a pinned, checksum-verified
[`rmapi`](https://github.com/ddvk/rmapi) release into the isolated
`~/.local/share/remarkable-push/bin` directory. (`rmapi` is a Go executable,
so a Python virtual environment would not isolate or install it.) To install it
separately or authenticate the account, run:

```sh
make setup-remarkable
make remarkable-auth
```

Running the Hyprland shortcut without saved credentials also opens a Kitty
terminal automatically for the reMarkable one-time device code. After successful
authentication the terminal closes and the original upload continues. Revoked
or expired credentials trigger the same flow and one automatic upload retry. If
Kitty is unavailable, the script falls back to `x-terminal-emulator`.

By default PDFs are uploaded to the cloud root. If a document with the same
name already exists, the shortcut preserves it and its annotations by uploading
the new copy as `name (1).pdf`, `name (2).pdf`, and so on. Configure the
destination for a particular machine in
`~/.config/remarkable-push/config.toml`:

```toml
directory = "Papers"
```

The folder must already exist in reMarkable Cloud. Omit the file or leave
`directory` empty to upload to the cloud root. `REMARKABLE_DIR` remains
available as an environment override, and `REMARKABLE_CONFIG` can select a
different config-file path. For arXiv papers, the shortcut retrieves the
canonical paper title from arXiv metadata and uses it as the uploaded filename,
falling back to the browser title or arXiv identifier if metadata is
unavailable. The browser
integration supports Zen/Firefox and Chromium-family browsers; it briefly
focuses a matching PDF/arXiv window to copy its current URL, then restores the
previous focus and clipboard. Downloads requiring browser cookies are not
supported.

On Ubuntu, install the shared files, the original Hyprland profile, and
Waybar:

```sh
make install-ubuntu
```

On CachyOS, install the Bash login-shell configuration, Kitty, Noctalia, shared
files, custom scripts, and the CachyOS overlay instead. CachyOS's Zsh/Fish
defaults remain unmanaged:

```sh
make install-cachyos
```

`make install`, `make dry-run`, and `make restow` select the CachyOS profile
automatically on CachyOS. Use `make dry-run-cachyos` or
`make dry-run-ubuntu` to preview a specific profile explicitly.

The CachyOS overlay deliberately leaves Noctalia in charge of the panel, while
the `noctalia` package tracks its preferences. On session start it opens Kitty
on laptop workspace 1, Zen on Acer workspace 10, and Slack on Samsung
workspace 19, matching the current window layout. It replaces CachyOS's
`config/{autostart,binds,monitors,variables,workspaces}.lua`; preserve the
distribution versions before the first install:

```sh
mkdir -p ~/.config/hypr/config/cachyos-default
mv ~/.config/hypr/config/{autostart,binds,monitors,variables,workspaces}.lua \
  ~/.config/hypr/config/cachyos-default/
make install-cachyos
```

The CachyOS profile also includes a user timer that keeps Focal Shape monitors
awake on weekdays from 09:00 through 16:55. Every five minutes it sends a
two-second, 20 kHz pulse directly to every connected Focusrite/Scarlett output,
with a 200 ms fade at each end to prevent clicks;
it does nothing when the interface is disconnected. `make install-cachyos`
reloads the systemd user manager and enables and starts the timer automatically;
`make remove-cachyos` disables it before removing the Stow links.

### Microphone footswitch

The CachyOS profile includes `mic-pedal`, a user service for a momentary USB
footswitch. Its normal behavior is push-to-mute: the microphone is live while
the pedal is released and muted while it is held. When an active PipeWire
capture belongs to Claude or ChatGPT, it automatically changes to
push-to-talk: released is muted and held is live. Native clients are identified
from PipeWire/PulseAudio stream metadata. For a browser capture, the active
Hyprland window title must also match an assistant pattern, so a Google Meet
capture continues to use push-to-mute.

Install the runtime dependencies before enabling the profile:

```sh
sudo pacman -S --needed python-evdev libnotify
```

To install the dependencies, udev rule, Stow links, and user service together,
run the dedicated end-to-end target instead:

```sh
make install-mic-pedal
```

The hardware-specific udev rule intentionally is not installed by Stow. It
matches the PCsensor `3553:b001` keyboard endpoint exactly, excluding the
device's mouse and absolute-axis endpoints. It also tells libinput/Hyprland to
ignore that endpoint, so its synthetic `b` never reaches a focused application,
even while the daemon is stopped. Install and activate it once:

```sh
make install-mic-pedal-udev
```

This target prompts through `sudo`, installs the rule under
`/etc/udev/rules.d`, and reloads udev. Unplug and reconnect the pedal afterward
so both its access ACL and libinput exclusion are applied. It installs only the
device rule; use `make install-mic-pedal` for the complete controller setup.

Configure the event key and detection patterns in
`~/.config/mic-pedal/config.toml`. This pedal emits `KEY_B`; the daemon grabs
its keyboard endpoint exclusively, while the udev rule independently excludes
it from libinput and creates `/dev/input/mic-pedal`. The pedal must emit
separate key-down and key-up events; autorepeat is ignored.

Useful checks:

```sh
mic-pedal status
mic-pedal refresh
systemctl --user status mic-pedal.service
journalctl --user -u mic-pedal.service -f
evtest /dev/input/mic-pedal
```

`SUPER+SHIFT+F13` also displays the current status as a notification. The
daemon explicitly applies mute/unmute rather than toggling
state, serializes pedal events, mutes on disconnect and shutdown, and retries
when the device is absent. It controls PipeWire clients only; it cannot mute an
audio interface's direct-monitor path or software that bypasses PipeWire.

The CachyOS profile pins PipeWire to 44.1 kHz. To test different keepalive
signals manually, specify frequency in hertz, linear volume, and duration in
seconds (defaults: `20000`, `0.9`, and `2`):

```sh
focal-keepalive --frequency 18000 --volume 0.5 --duration 5
```

The keepalive samples each Focusrite/Scarlett output for one second and skips
outputs that are emitting audio. This checks the actual signal rather than
PipeWire's stream state, because browsers can leave silent ChatGPT and Claude
streams marked as running. If output activity cannot be sampled, it skips the
tone entirely.

The laptop panel is 1920x1200 and runs at its native 1.5x scale, giving it a
1280x800 logical size. The CachyOS monitor profile places it at `640x1440`:
directly below the 1920x1080 logical Acer display and immediately left of the
portrait Samsung. The workspace watcher preserves that placement after lid
changes.

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
stow -t ~ bash bin hypr kitty nvim share waybar
```

The downloaded reMarkable helper is intentionally preserved by `make remove`.
Remove it explicitly with `make remove-remarkable`.

Remove links manually:

```sh
stow -D -t ~ bash bin hypr kitty nvim share waybar
```
