# USB Microphone Footswitch Plan

## Goal

Add a USB footswitch controller for the PipeWire microphone input on CachyOS.
It supports two momentary behaviors selected automatically:

| Mode | Pedal released | Pedal held |
| --- | --- | --- |
| Active assistant capture / push-to-talk (PTT) | Muted | Live |
| Default / push-to-mute (PTM) | Live | Muted |

The initial use cases are:

- Push-to-mute by default, including while participating in Google Meet calls.
- Automatically use push-to-talk while using voice features in Claude or
  ChatGPT.

Applications should remain unmuted in their own UI. The controller gates the
PipeWire microphone source underneath them. It does not activate an
application's record, dictation, or voice-session button.

## Hardware Requirements

A single-pedal USB HID footswitch is sufficient:

- The pedal controls the microphone momentarily.
- A press must generate a key-down event and release must generate a key-up
  event.
- The device should be configurable to emit otherwise-unused keys, preferably
  `F13` and `F14`.
- The attached PCsensor pedal currently emits `B`, so the daemon must grab its
  keyboard endpoint exclusively and the udev rule must mark it ignored by
  libinput to prevent stray `b` input in applications.
- The device must continue reporting the held state rather than emitting only a
  complete key tap or a prerecorded macro.

## Safety and State Rules

The implementation must use explicit mute and unmute commands. It must never
use a blind mute toggle.

- Start muted until the pedal is connected and assistant detection succeeds.
- Default to PTM whenever no active assistant capture is detected.
- Switching automatically to PTT immediately applies the PTT state.
- In PTT mode, pressing unmutes and releasing mutes.
- In PTM mode, pressing mutes and releasing unmutes.
- Mute if the control pedal disconnects while held.
- Mute when the daemon shuts down or exits unexpectedly where possible.
- Ignore key-repeat events and safely handle duplicate press or release events.
- Handle rapid presses without commands racing or arriving out of order.
- On reconnect or resume, remain muted until assistant detection completes,
  then apply the inferred behavior.
- Manual microphone changes made elsewhere must not cause the next pedal event
  to invert unexpectedly. Every transition reapplies the required absolute
  state.

## Proposed Architecture

Implement a small Python daemon rather than relying on compositor key bindings.
The daemon will read Linux input events directly, maintain the selected mode,
and call PipeWire's `wpctl` with an absolute state.

The basic commands are:

```sh
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0  # live
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1  # muted
```

The input state machine and PipeWire command execution should be separated so
the state transitions can be tested without access to the physical pedal.

The executable exposes a small control interface:

```sh
mic-pedal status
mic-pedal refresh
```

The daemon and command-line invocations can communicate through a Unix socket
in `$XDG_RUNTIME_DIR`. Only the daemon should issue microphone commands during
normal operation, keeping event ordering deterministic.

## Planned Repository Changes

### Controller

Create `bin/.local/bin/mic-pedal`:

- Read the configured evdev input device.
- Recognize the main-pedal key code.
- Detect active assistant capture clients and maintain PTT/PTM behavior plus
  pressed/released state.
- Apply explicit mute states through `wpctl`.
- Provide status and detection-refresh commands.
- Reopen the device after disconnect/reconnect.
- Handle termination signals and attempt to mute before exiting.
- Log concise diagnostics suitable for `journalctl --user`.
- Send mode and error notifications through `notify-send`/Noctalia.

Use the packaged Python evdev bindings if practical on CachyOS. Do not add the
user to the general `input` group merely to access the pedal.

### Configuration

Create `hypr-cachyos/.config/mic-pedal/config.toml` containing:

- Stable pedal device path, expected to be `/dev/input/mic-pedal`.
- Main-pedal key code.
- Assistant and browser matching patterns.
- PipeWire target, initially `@DEFAULT_AUDIO_SOURCE@`.
- Notification settings.

The attached pedal identifies as `PCsensor FootSwitch` (`3553:b001`), with the
keyboard event endpoint named `PCsensor FootSwitch Keyboard`. It emits `KEY_B`.

### User Service

Create `hypr-cachyos/.config/systemd/user/mic-pedal.service`:

- Start as part of the graphical user session.
- Restart after unexpected failures.
- Use the repository-managed executable and configuration.
- Ensure service stop invokes or gives the daemon time to apply its safe mute
  state.
- Avoid a restart loop while the USB device is absent; the daemon should wait
  for the device or retry with backoff.

### Hyprland Binding

Update `hypr-cachyos/.config/hypr/config/binds.lua` with a shortcut to display
the current inferred mode and status. There is no manual meeting-mode state.

### Device Permissions

Add a repository-managed udev rule populated with the pedal's exact USB vendor
ID, product ID, and keyboard event endpoint name.

The rule should:

- Match only the footswitch rather than all input devices.
- Give the active local user access with `uaccess` or an equivalently narrow
  mechanism.
- Create the stable symlink `/dev/input/mic-pedal`.

Because udev rules are system files, provide and document the separate,
explicit `make install-mic-pedal-udev` target for installing into
`/etc/udev/rules.d`. Do not make a normal GNU Stow operation write to `/etc`.

### Installation and Documentation

Update the `Makefile` and `README.md` to:

- Install and enable the user service for the CachyOS profile.
- Disable the service before removing the CachyOS package.
- Document the Python/evdev dependency.
- Document the one-time privileged udev-rule installation.
- Document mode-control and troubleshooting commands.
- Explain that the controller affects PipeWire clients but cannot mute an
  interface's direct-monitor path or an application bypassing PipeWire.

## Hardware Bring-Up

Once the footswitch is available:

1. Record its USB vendor and product IDs with `lsusb`.
2. Locate its event interfaces under `/dev/input/by-id` and inspect their
   properties.
3. Use `evtest` or an equivalent event viewer to confirm distinct press and
   release events.
4. Record the key code produced by the pedal.
5. Confirm that holding a pedal keeps the key logically down and that any
   autorepeat events can be ignored.
6. Configure unused key codes if the hardware supports onboard programming.
7. Install the populated, narrowly scoped udev rule.
8. Verify access to `/dev/input/mic-pedal` without root and without membership
   in the general `input` group.
9. Confirm the intended microphone is selected by
   `@DEFAULT_AUDIO_SOURCE@`. Add a more specific target strategy if the default
   source changes unexpectedly between the audio interface and other devices.

## Tests

### Automated State-Machine Tests

- Default PTM press changes live to muted.
- Default PTM release changes muted to live.
- Detected-assistant PTT press changes muted to live.
- PTT release changes live to muted.
- Detecting an assistant applies PTT immediately.
- An assistant capture ending applies PTM immediately.
- Duplicate press and release events are idempotent.
- Autorepeat events have no effect.
- Rapid press/release sequences remain ordered.
- Changing mode while the pedal is held produces a defined, safe state.
- Disconnect and shutdown select muted.
- Invalid configuration fails closed and reports the problem.

### Manual Integration Tests

- Verify `wpctl` state changes against the expected PipeWire source.
- Test normal, rapid, and long pedal presses.
- Disconnect USB while the pedal is held.
- Disconnect and reconnect the audio interface.
- Suspend and resume the computer.
- Restart PipeWire/WirePlumber while the daemon remains active.
- Test after a manual `XF86AudioMicMute` action.
- Verify notifications appear on the focused monitor through Noctalia.
- Confirm Google Meet uses the default PTM behavior.
- Test PTT gating with Claude and ChatGPT voice input.
- Confirm direct monitoring on the audio interface is unaffected and document
  that limitation.

## User Feedback

Automatically inferred behavior changes should produce an immediately
recognizable notification:

```text
MIC: PTT - released is muted
MIC: PTM - released is live
```

Use a replacement notification ID so repeated state changes update one popup
instead of creating a stack. An optional short sound may accompany a mode
change, but ordinary press/release actions should remain silent by default.

Browser assistant detection requires both an active browser capture stream and
an assistant match in the active Hyprland window. A background assistant tab by
itself cannot change microphone behavior.

## Completion Criteria

The feature is complete when:

- Both automatically selected momentary behaviors work with the physical pedal.
- Assistant detection is visible and cannot silently invert behavior.
- The microphone fails closed on startup, shutdown, disconnect, and errors.
- The service starts automatically in the CachyOS graphical session.
- Pedal access is limited by an exact udev rule.
- Automated state-machine tests pass.
- Google Meet remains PTM while Claude and ChatGPT voice capture selects PTT.
- Installation, removal, configuration, and troubleshooting are documented in
  the dotfiles repository.
