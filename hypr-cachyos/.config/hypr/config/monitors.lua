-- Logical layout at 2x scale:
-- Acer: 1920x1080 at 0x360; Samsung (rotated): 1080x1920 at 1920x0.
-- The 1920x1200 laptop panel is 1280x800 logically at its native 1.5x scale,
-- tucked below the Acer and
-- left of the Samsung.
hl.monitor({
    output = "desc:Acer Technologies Acer RT280K 0x71803C91",
    mode = "preferred",
    position = "0x360",
    scale = "2",
})

hl.monitor({
    output = "desc:Samsung Electric Company LU28R55 HCJW907260",
    mode = "preferred",
    position = "1920x0",
    scale = "2",
    transform = 1,
})

hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "640x1440",
    scale = "1.5",
})

-- Safe fallback when travelling without either external display.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "2" })
