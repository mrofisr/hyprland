-- ═══════════════════════════════════════════════
--  Environment, autostart, window rules
-- ═══════════════════════════════════════════════

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("TERMINAL", "alacritty")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

----------------------------------------------------------------------------
-- Autostart
----------------------------------------------------------------------------
hl.on("hyprland.start", function()
    -- idle: dim → lock → suspend
    hl.exec_cmd("hypridle")

    -- night light, always on (Super+Shift+N toggles)
    hl.exec_cmd("hyprsunset -t 5000")

    -- macOS-style volume/brightness popup
    hl.exec_cmd("swayosd-server")

    -- speaker EQ
    hl.exec_cmd("easyeffects --gapplication-service")

    -- KDE Connect: keep phone integration alive (you already use it)
    hl.exec_cmd("kdeconnectd")

    -- First-login welcome, once
    hl.exec_cmd("bash -c 'if [ ! -f ~/.cache/hypr-welcomed ]; then touch ~/.cache/hypr-welcomed; sleep 2; hyprctl notify -1 8000 \"rgb(94e2d5)\" \"Welcome to your Hyprland 🏝️  Super+K shows every shortcut\"; fi'")
end)

----------------------------------------------------------------------------
-- Window rules
----------------------------------------------------------------------------

-- Ignore maximize requests from apps (the tiling way)
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Small dialogs float, centered
hl.window_rule({
    name  = "float-zenity",
    match = { class = "Zenity" },
    float = true,
    center = true,
})

----------------------------------------------------------------------------
-- Placement system: primaries have home workspaces
----------------------------------------------------------------------------
hl.window_rule({
    name      = "brave-home",
    match     = { class = "brave-origin" },
    workspace = "2",
})

hl.window_rule({
    name      = "zcode-home",
    match     = { class = "ZCode" },
    workspace = "3",
})

hl.window_rule({
    name      = "steam-home",
    match     = { class = "steam" },
    workspace = "4",
})

----------------------------------------------------------------------------
-- Workspace names, persistent (k4 island + overview show them)
----------------------------------------------------------------------------
hl.workspace_rule({ workspace = "1", persistent = true, default_name = "main" })
hl.workspace_rule({ workspace = "2", persistent = true, default_name = "browser" })
hl.workspace_rule({ workspace = "3", persistent = true, default_name = "code" })
hl.workspace_rule({ workspace = "4", persistent = true, default_name = "game" })

----------------------------------------------------------------------------
-- Single-window calm: a workspace with exactly one tiled window
-- renders edge-to-edge (no gaps, no border) — the modern
-- no_gaps_when_only.
----------------------------------------------------------------------------
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })

hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})
