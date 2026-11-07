-- ═══════════════════════════════════════════════
--  Our keybinds · mnemonic SUPER+letter
--  k4's own binds live in config/k4.lua (loaded after).
--  Anything we need to win over k4 goes in overrides.lua.
-- ═══════════════════════════════════════════════

local mainMod = "SUPER"

local terminal    = "alacritty"
local fileManager = "dolphin"

----------------------------------------------------------------------------
-- Launch apps by mnemonic
----------------------------------------------------------------------------
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
-- SUPER+B lives in overrides.lua: it must unbind k4's files bind first
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("discord"))

----------------------------------------------------------------------------
-- Window control
----------------------------------------------------------------------------
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Resize the active window with the keyboard (tiling mode)
hl.bind(mainMod .. " + CONTROL + left",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive -40 0"))
hl.bind(mainMod .. " + CONTROL + right", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 40 0"))
hl.bind(mainMod .. " + CONTROL + up",    hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -40"))
hl.bind(mainMod .. " + CONTROL + down",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 40"))

-- Power menu (hyprshutdown if present, else plain exit)
hl.bind(mainMod .. " + SHIFT + Q",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))

----------------------------------------------------------------------------
-- Focus & move
----------------------------------------------------------------------------
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

----------------------------------------------------------------------------
-- Workspaces: SUPER+1..9 to switch, +SHIFT to move window
----------------------------------------------------------------------------
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

----------------------------------------------------------------------------
-- Scratchpad (special workspace)
----------------------------------------------------------------------------
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

----------------------------------------------------------------------------
-- Scroll workspaces / drag & resize with mouse
----------------------------------------------------------------------------
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

----------------------------------------------------------------------------
-- Hardware keys (media Play/Next/Prev stay with k4's island player)
-- Volume/brightness go through swayosd for the macOS-style OSD popup
----------------------------------------------------------------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"),       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("swayosd-client --brightness raise"),          { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("swayosd-client --brightness lower"),          { locked = true, repeating = true })

----------------------------------------------------------------------------
-- Extras
----------------------------------------------------------------------------
-- hyprspace: Mission Control-style overview
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("hyprctl dispatch overview:toggle"))
-- Color picker → clipboard
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"))
-- Night light toggle (starts on at 5000K)
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("bash -c 'pkill -x hyprsunset || hyprsunset -t 5000'"))
