-- ═══════════════════════════════════════════════
--  Overrides — loaded AFTER config/k4.lua on
--  purpose. Whatever is bound here wins conflicts.
-- ═══════════════════════════════════════════════

local mainMod = "SUPER"

-- SUPER+B = Brave. k4 uses B for its file browser and the Lua API
-- APPENDS binds (it does not replace), so we must unbind every
-- existing SUPER+B first — otherwise one press fires several binds.
-- If Brave is already running, jump to its home workspace instead
-- of spawning a duplicate window.
hl.unbind(mainMod .. " + B")
hl.bind(mainMod .. " + B",
    hl.dsp.exec_cmd("bash -c 'pgrep -x brave-origin >/dev/null && hyprctl dispatch workspace 2 || brave-origin'"))
