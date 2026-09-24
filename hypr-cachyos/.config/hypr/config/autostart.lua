-- Keep CachyOS's Noctalia panel and all of its widgets.
-- The workspace watcher inherits these values on starts, reloads, and binds.
hl.env("HYPR_WORKSPACE_BAR", "none")
hl.env("HYPR_LAPTOP_SCALE", "1.5")
hl.env("HYPR_LAPTOP_POSITION", "640x1440")
hl.env("HYPR_WORKSPACE_API", "lua")

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("xhost +SI:localuser:root")

    -- The watcher assigns the familiar nine-workspace banks to each monitor.
    -- Noctalia owns the panel, so this profile must not launch Waybar.
    hl.exec_cmd("~/.config/hypr/scripts/awesome-workspaces watch")

    -- Match the current desk: Kitty on the laptop, Zen on the Acer,
    -- and Slack on the portrait Samsung. Scope only these launches so
    -- later windows can still be opened on whichever workspace is active.
    hl.exec_cmd("kitty", { workspace = "1" })
    hl.exec_cmd("zen", { workspace = "10" })
    hl.exec_cmd("slack", { workspace = "19" })
end)
