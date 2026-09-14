-- CachyOS launcher/panel controls plus the workspace and window shortcuts
-- from the Ubuntu profile.  This replaces the starter binds file so every
-- key has one action.
local mod = "SUPER"
local noctalia = "noctalia msg "
local app = "uwsm app -- "
local workspace = "~/.config/hypr/scripts/awesome-workspaces "

local function command(command)
    return hl.dsp.exec_cmd(command)
end

-- Window management
hl.bind(mod .. " + Q", hl.dsp.exit())
hl.bind(mod .. " + CONTROL + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + M", command("hyprctl dispatch fullscreen 1"))
hl.bind(mod .. " + CONTROL + M", command("hyprctl dispatch fullscreenstate 2 0"))
hl.bind(mod .. " + SHIFT + M", command("hyprctl dispatch fullscreenstate 3 0"))
hl.bind(mod .. " + SHIFT + C", hl.dsp.window.close())
hl.bind(mod .. " + J", command("hyprctl dispatch cyclenext"))
hl.bind(mod .. " + K", command("hyprctl dispatch cyclenext prev"))
hl.bind(mod .. " + Tab", command("hyprctl dispatch cyclenext prev"))
hl.bind(mod .. " + SHIFT + J", command("hyprctl dispatch swapnext"))
hl.bind(mod .. " + SHIFT + K", command("hyprctl dispatch swapnext prev"))
hl.bind(mod .. " + Space", command("hyprctl dispatch layoutmsg swapwithmaster"))
hl.bind(mod .. " + T", command("hyprctl dispatch pin"))
hl.bind(mod .. " + O", command("hyprctl dispatch movewindow mon:+1"))
hl.bind(mod .. " + comma", command("hyprctl dispatch layoutmsg 'orientationcycle top left bottom right'"))
hl.bind(mod .. " + period", command("hyprctl dispatch layoutmsg 'orientationcycle top right bottom left'"))
hl.bind(mod .. " + H", command("hyprctl dispatch layoutmsg 'mfact -0.05'"))
hl.bind(mod .. " + L", command("hyprctl dispatch layoutmsg 'mfact +0.05'"))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize())

-- Familiar applications and CachyOS widgets.
hl.bind(mod .. " + Return", command(app .. TERMINAL))
hl.bind(mod .. " + E", command(app .. FILE_MANAGER))
hl.bind(mod .. " + W", command(app .. BROWSER))
hl.bind(mod .. " + C", command(app .. CALCULATOR))
hl.bind("XF86Calculator", command(app .. CALCULATOR))
hl.bind("CONTROL + SHIFT + Escape", command(app .. TERMINAL .. " -e btop"))
hl.bind(mod .. " + R", command("wofi --show run"))
hl.bind(mod .. " + Z", command(noctalia .. "settings-toggle"))
hl.bind(mod .. " + X", command(noctalia .. "panel-toggle control-center"))
hl.bind(mod .. " + SHIFT + W", command(noctalia .. "panel-toggle wallpaper"))
hl.bind(mod .. " + V", command(noctalia .. "panel-toggle clipboard"))
hl.bind(mod .. " + A", command(noctalia .. "panel-toggle control-center notifications"))
hl.bind(mod .. " + ALT + Space", command(noctalia .. "panel-toggle launcher"))
hl.bind(mod .. " + ALT + period", command(noctalia .. "panel-toggle launcher /emo"))
hl.bind(mod .. " + CONTROL + L", command(noctalia .. "session lock"))
hl.bind(mod .. " + ALT + C", command(noctalia .. "panel-toggle session"))

-- Workspace banks: 1-9 on the laptop, 10-18 on the Acer, and 19-27 on the
-- Samsung. The script follows the focused display and remaps after dock/lid
-- changes.
hl.bind(mod .. " + Left", command(workspace .. "prev"))
hl.bind(mod .. " + Right", command(workspace .. "next"))
hl.bind(mod .. " + Up", command(workspace .. "first-empty"))
hl.bind(mod .. " + Down", command(workspace .. "last-empty"))
hl.bind(mod .. " + CONTROL + Left", command(workspace .. "external-prev"))
hl.bind(mod .. " + CONTROL + Right", command(workspace .. "external-next"))
hl.bind(mod .. " + Escape", command("hyprctl dispatch workspace previous"))
hl.bind(mod .. " + SHIFT + Left", command("hyprctl dispatch movetoworkspace r-1"))
hl.bind(mod .. " + SHIFT + Right", command("hyprctl dispatch movetoworkspace r+1"))
hl.bind(mod .. " + SHIFT + Up", command(workspace .. "move-first-empty"))
hl.bind(mod .. " + SHIFT + Down", command(workspace .. "move-last-empty"))
hl.bind(mod .. " + CONTROL + J", command("hyprctl dispatch focusmonitor +1"))
hl.bind(mod .. " + CONTROL + K", command("hyprctl dispatch focusmonitor -1"))
hl.bind(mod .. " + CONTROL + O", command(workspace .. "swap-main"))

for i = 1, 9 do
    hl.bind(mod .. " + " .. i, command(workspace .. "switch " .. i))
    hl.bind(mod .. " + SHIFT + " .. i, command(workspace .. "move " .. i))
    hl.bind(mod .. " + CONTROL + " .. i, command("hyprctl dispatch workspace " .. (i + 9)))
    hl.bind(mod .. " + CONTROL + SHIFT + " .. i, command("hyprctl dispatch movetoworkspace " .. (i + 9)))
end

-- Hardware, screen capture, and local reference sheets.
hl.bind(mod .. " + F5", command("log-brightness down"), { repeating = true })
hl.bind(mod .. " + F6", command("log-brightness up"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", command(noctalia .. "volume-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", command(noctalia .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", command(noctalia .. "volume-mute"), { locked = true })
hl.bind("XF86AudioMicMute", command(noctalia .. "mic-mute"), { locked = true })
hl.bind("XF86AudioPlay", command(noctalia .. "media toggle"), { locked = true })
hl.bind("XF86AudioPause", command(noctalia .. "media toggle"), { locked = true })
hl.bind("XF86AudioNext", command(noctalia .. "media next"), { locked = true })
hl.bind("XF86AudioPrev", command(noctalia .. "media previous"), { locked = true })
hl.bind("XF86MonBrightnessUp", command(noctalia .. "brightness-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", command(noctalia .. "brightness-down"), { locked = true, repeating = true })
hl.bind(mod .. " + P", command("hyprpicker -a -n"))
hl.bind("Print", command(noctalia .. "screenshot-region"))
hl.bind(mod .. " + Print", command(noctalia .. "screenshot-fullscreen"))
hl.bind(mod .. " + SHIFT + H", command("~/.config/hypr/scripts/open-cheatsheet hyprland"))
hl.bind(mod .. " + SHIFT + N", command("~/.config/hypr/scripts/open-cheatsheet nvim"))
hl.bind(mod .. " + SHIFT + P", command("~/.config/hypr/scripts/open-cheatsheet pi"))
hl.bind(mod .. " + CONTROL + R", command("hyprctl reload"))
