--!nonstrict
-- The dictation process atomically writes "pid recording|transcribing" and removes
-- the file on exit. Check the PID too, so a crash cannot leave a stuck icon.
local runtime = noctalia.getenv("XDG_RUNTIME_DIR")
local path = runtime and (runtime .. "/dictate.status") or nil

function update()
  noctalia.setUpdateInterval(250)
  local contents = path and noctalia.readFile(path) or nil
  local pid, state
  if contents then
    pid, state = string.match(contents, "^(%d+) (%a+)")
  end
  local alive = pid and noctalia.fileExists("/proc/" .. pid)
  if alive and state == "recording" then
    barWidget.setGlyph("circle-filled")
    barWidget.setGlyphColor("#FF4444")
    barWidget.setTooltip("Dictation: recording")
    barWidget.setVisible(true)
  elseif alive and state == "transcribing" then
    barWidget.setGlyph("pencil")
    barWidget.setGlyphColor("primary")
    barWidget.setTooltip("Dictation: transcribing")
    barWidget.setVisible(true)
  else
    barWidget.setVisible(false)
  end
end
