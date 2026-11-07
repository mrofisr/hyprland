-- Generado por k4 · módulo HyprTheme.
-- No lo edites a mano: se reescribe cada vez que guardas desde la barra.
-- Para revertirlo: borra este archivo y su línea require de hyprland.lua.

hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 14,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(3d4263ff)", "rgba(1a1c2aff)" }, angle = 45 },
            inactive_border = "rgba(2a2b32ff)",
        },
    },
    decoration = {
        rounding = 12,
        active_opacity = 1.00,
        inactive_opacity = 0.95,
        blur = {
            enabled = true,
            size = 4,
            passes = 2,
        },
        shadow = { enabled = true },
    },
})

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "quick" })
