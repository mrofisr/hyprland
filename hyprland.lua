-- ═══════════════════════════════════════════════════════════════
--  CALM MOCHA ISLAND · personal Hyprland setup
--  MacBookPro14,1 · CachyOS · scale 1.5 · Catppuccin Mocha/teal
--
--  Load order (matters!):
--    colors → input → binds → apps  (ours)
--    config.k4                      (k4's, self-managed)
--    overrides                      (ours again, wins conflicts)
-- ═══════════════════════════════════════════════════════════════

require("colors")
require("input")
require("binds")
require("apps")

----------------------------------------------------------------------------
-- Monitor
----------------------------------------------------------------------------
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1.5,
})

----------------------------------------------------------------------------
-- Look & feel
----------------------------------------------------------------------------
hl.config({
    general = {
        gaps_in  = 6,
        gaps_out = 14,

        border_size = 2,

        col = {
            -- teal → blue gradient on the focused window
            active_border   = { colors = { "rgba(94e2d5ff)", "rgba(89b4faff)" }, angle = 45 },
            inactive_border = "rgba(313244aa)",
        },

        resize_on_border = true,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 12,

        active_opacity   = 1.0,
        inactive_opacity = 0.95, -- gentle calm dim on unfocused windows

        shadow = {
            enabled      = true,
            range        = 18,
            render_power = 3,
            color        = 0xee11111b,
        },

        blur = {
            enabled   = true,
            size      = 4,
            passes    = 2,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = -1,    -- k4 draws the wallpaper layer
        disable_hyprland_logo   = true,  -- no anime mascot defaults
    },
})

----------------------------------------------------------------------------
-- Curves & springs — calm, slightly soft
----------------------------------------------------------------------------
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 }    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 }    } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 }       } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 }    } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 }     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy",         style = "popin 85%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 85%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

----------------------------------------------------------------------------
-- k4 (self-managed; written by k4's installer)
----------------------------------------------------------------------------
require("config.k4")

----------------------------------------------------------------------------
-- Our overrides must win over k4
----------------------------------------------------------------------------
require("overrides")

----------------------------------------------------------------------------
-- k4's theme module (config.k4-theme.lua, written by the theme panel).
-- Loads LAST on purpose: the palette it pulls from the wallpaper wins.
----------------------------------------------------------------------------
require("config.k4-theme")
