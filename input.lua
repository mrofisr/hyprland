-- ═══════════════════════════════════════════════
--  Keyboard & touchpad (MacBook feel)
-- ═══════════════════════════════════════════════

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "caps:escape", -- CapsLock is Escape now
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity  = 0, -- -1.0 - 1.0, 0 = untouched
        accel_profile = "adaptive",

        touchpad = {
            natural_scroll        = true,  -- Mac muscle memory
            tap_to_click          = true,  -- tap = click
            tap_and_drag          = true,  -- tap, then drag without holding
            clickfinger_behavior  = true,  -- 2-finger tap = right-click (macOS style)
            tap_button_map        = "lrm", -- 3-finger tap = middle-click
            disable_while_typing  = true,
            drag_lock             = false,
        },
    },
})

-- 3-finger horizontal swipe = switch workspace (Mac gesture)
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- 4-finger swipe = drag the focused window (macOS 3-finger-drag feel)
hl.gesture({
    fingers   = 4,
    direction = "horizontal",
    action    = "move",
})
