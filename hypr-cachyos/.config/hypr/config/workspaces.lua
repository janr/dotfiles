-- Keep nine persistent workspaces on each display. The workspace helper maps
-- Super+1..9 to the bank belonging to the currently focused monitor.
local monitors = { MONITOR1, MONITOR2, MONITOR3 }

for bank, monitor in ipairs(monitors) do
    for key = 1, 9 do
        local workspace = (bank - 1) * 9 + key
        hl.workspace_rule({
            workspace = tostring(workspace),
            monitor = monitor,
            persistent = true,
            default = key == 1,
        })
    end
end
