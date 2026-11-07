// ─────────────────────────────────────────────────────────────
//  Battery — the laptop battery, as liquid.
//
//  · One `cat` of three /sys files every few seconds: capacity,
//    status and uevent (for current, cycles, health…).
//  · In the pill: an indicator with the % and its level glyph.
//  · Click it (or IPC/shortcut): the liquid view in the island.
//  · Events with character: plugging in yanks the island (the
//    cable pulls it!); unplugging gives it a jolt; crossing the
//    low threshold shakes it, tints the bar red and notifies.
//
//  IPC (quickshell ipc … call k4.battery <fn>):
//    state()      everything read, as JSON
//    open()       open the liquid view
//    close()      close it
//    simulate(N)  show a made-up % (runs the real alarm path)
//    restore()    back to the real /sys reading
// ─────────────────────────────────────────────────────────────

import QtQuick
import K4 as K4

K4.Plugin {
    id: self

    name: "battery"
    title: "Battery"
    priority: 62
    active: open
    islandWidth: 540
    islandHeight: 210

    property bool open: false
    function toggle() { open = !open }
    function close() { open = false }

    //  A background tap closes, and does not open the control center on top.
    handlesBackgroundTap: true
    onBackgroundTapped: close()

    // ── settings ─────────────────────────────────────────────
    property int alert: 15           // % of the low-battery threshold
    property bool effects: true      // physical island gestures
    property bool sound: true        // desktop sounds on plug/unplug
    property bool tint: true         // tint the bar on events

    // ── live state ───────────────────────────────────────────
    property bool present: false
    property int capacity: -1
    property string status: ""       // Charging · Discharging · Full · …
    property bool charging: false
    property bool full: false
    property int health: -1          // % of the design charge
    property int cycles: -1
    property real volts: 0
    property real degrees: 0
    property int timeMin: -1         // ≈ minutes to full/empty
    property bool warned: false      // low-battery alarm hysteresis

    //  Simulation mode: ignores /sys and shows a made-up state, to
    //  watch the alarm choreography without draining the battery.
    property bool simulating: false

    property real nivel: 0           // 0..1, where the liquid heads
    Behavior on nivel { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } }

    property color levelColor: Qt.hsla(120 / 360, 0.72, 0.56, 1)
    Behavior on levelColor { ColorAnimation { duration: 900 } }

    //  Hue by level: red → amber → green, piecewise.
    function toneOf(n) {
        let h
        if (n < 15)        h = 0
        else if (n < 35)   h = (n - 15) / 20 * 42
        else if (n < 60)   h = 42 + (n - 35) / 25 * 48
        else               h = 90 + (n - 60) / 40 * 30
        return Qt.hsla(Math.min(120, h) / 360, 0.72, 0.56, 1)
    }

    readonly property bool critical: present && !charging
                                     && capacity >= 0 && capacity <= alert

    //  The indicator glyph, in steps of 10.
    function glyphOf(n) {
        if (charging) return 0x0F0084        // md-battery_charging
        if (critical) return 0x0F0083        // md-battery_alert
        const p = Math.min(100, Math.max(10, Math.floor(n / 10) * 10))
        return p === 100 ? 0x0F0079          // md-battery (full)
                         : 0x0F007A + (p / 10 - 1)   // battery_10…battery_90
    }

    // ── persistence ──────────────────────────────────────────
    K4.Guardado {
        id: saved
        plugin: "battery"
        nombre: "battery"
        onCargado: function (d) { self.restoreSettings(d) }
    }

    function saveSettings() {
        saved.guardar({ alert: self.alert, effects: self.effects,
                        sound: self.sound, tint: self.tint })
    }

    function restoreSettings(d) {
        if (!d) return
        if (typeof d.alert === "number") self.alert = d.alert
        if (typeof d.effects === "boolean") self.effects = d.effects
        if (typeof d.sound === "boolean") self.sound = d.sound
        if (typeof d.tint === "boolean") self.tint = d.tint
    }

    // ── the probe: three files, one cat, nothing that can hang ──
    property string root: "/sys/class/power_supply/BAT0"
    property int tried: 0              // 0..2: BAT0, BAT1, BAT2

    K4.Process {
        id: probe
        onSalida: function (t) { self.parse(t) }
    }

    function read() {
        if (probe.running) return
        probe.command = ["cat", root + "/capacity", root + "/status",
                         root + "/uevent"]
        probe.running = true
    }

    //  Poll faster while the view is open.
    onOpenChanged: {
        watcher.interval = open ? 4000 : 10000
        if (open) read()
    }

    Timer {
        id: watcher
        interval: 10000
        repeat: true
        running: true
        onTriggered: self.read()
    }

    // ── reading and reaction ─────────────────────────────────
    function parse(text) {
        //  While simulating, the real world does not touch the state.
        if (simulating)
            return

        const lines = String(text || "").split("\n")

        //  No output: try the next battery, once each.
        if (lines.length < 2 || lines[0].trim().length === 0) {
            tried++
            if (tried <= 2) {
                root = "/sys/class/power_supply/BAT" + tried
                read()
            }
            return
        }

        if (!present) {
            present = true
            announce()
        }

        const cap = parseInt(lines[0], 10)
        const stat = lines[1].trim()
        const prevCap = capacity
        const prevCharging = charging
        const prevFull = full

        capacity = isNaN(cap) ? capacity : cap
        status = stat
        charging = stat === "Charging"
        full = stat === "Full"

        //  uevent: KEY=VALUE
        let chargeNow = -1, chargeFull = -1, design = -1, current = -1
        let cyclesN = -1, voltsN = 0, tempN = 0
        for (let i = 2; i < lines.length; ++i) {
            const j = lines[i].indexOf("=")
            if (j < 0) continue
            const k = lines[i].slice(0, j), v = lines[i].slice(j + 1)
            if (k === "POWER_SUPPLY_CHARGE_NOW") chargeNow = parseFloat(v)
            else if (k === "POWER_SUPPLY_CHARGE_FULL") chargeFull = parseFloat(v)
            else if (k === "POWER_SUPPLY_CHARGE_FULL_DESIGN") design = parseFloat(v)
            else if (k === "POWER_SUPPLY_CURRENT_NOW") current = Math.abs(parseFloat(v))
            else if (k === "POWER_SUPPLY_CYCLE_COUNT") cyclesN = parseInt(v, 10)
            else if (k === "POWER_SUPPLY_VOLTAGE_NOW") voltsN = parseFloat(v) / 1e6
            else if (k === "POWER_SUPPLY_TEMP") tempN = parseFloat(v) / 10
        }

        if (chargeFull > 0 && design > 0)
            health = Math.round(chargeFull / design * 100)
        if (cyclesN >= 0) cycles = cyclesN
        if (voltsN > 0) volts = voltsN
        if (tempN > 0) degrees = tempN

        timeMin = -1
        if (current > 10000) {
            const remaining = charging ? (chargeFull - chargeNow) : chargeNow
            if (remaining > 0 && chargeNow >= 0 && chargeFull > 0)
                timeMin = Math.round(remaining / current * 60)
        }

        nivel = Math.max(0, Math.min(1, capacity / 100))
        levelColor = toneOf(capacity)

        // ── events ──
        if (prevCap >= 0 && prevCharging !== charging) {
            if (charging) plugged()
            else unplugged()
        }

        if (prevCap >= 0 && charging && !prevFull && full) charged()

        if (capacity >= 0 && prevCap >= 0 && !charging) {
            if (capacity <= alert && prevCap > alert && !warned)
                low()
            if (capacity >= alert + 3)
                warned = false
        }

        announce()
    }

    function plugged() {
        if (sound) {
            chime.fuente = chime.delSistema("power-plug")
            chime.sonar()
        }
        if (effects) K4.Isla.efecto("battery", "tiron", 0.75)
        if (tint) K4.Tema.tintar("battery", "#30d158", 0.3, 4000)
    }

    function unplugged() {
        if (sound) {
            chime.fuente = chime.delSistema("power-unplug")
            chime.sonar()
        }
        if (effects) K4.Isla.efecto("battery", "sacudida", 0.45)
        if (tint) K4.Tema.tintar("battery", "#ffd60a", 0.25, 4000)
    }

    function low() {
        warned = true
        if (sound) {
            chime.fuente = chime.delSistema("dialog-error")
            chime.sonar()
        }
        if (effects) K4.Isla.efecto("battery", "sacudida", 0.85)
        if (tint) K4.Tema.tintar("battery", "#ff453a", 0.35, 8000)
        K4.Sistema.avisar(K4.Idioma.t("Low battery"),
            K4.Idioma.f("%1% left — plug me in when you can", capacity),
            true)
    }

    function charged() {
        if (tint) K4.Tema.tintar("battery", "#30d158", 0.3, 6000)
        K4.Sistema.avisar(K4.Idioma.t("Battery full"),
            K4.Idioma.t("At 100%, ready to go"), false)
    }

    K4.Sonido { id: chime }

    // ── simulation ───────────────────────────────────────────
    //  Applies a fake % and fires whatever the real reading would
    //  fire. Real polls are ignored meanwhile: restore() hands the
    //  bar back to the real world.
    function simulate(pct) {
        if (isNaN(pct)) return
        pct = Math.max(0, Math.min(100, pct))
        const prev = capacity

        simulating = true
        present = true
        status = "Discharging"
        charging = false
        full = false
        capacity = pct
        nivel = pct / 100
        levelColor = toneOf(pct)
        announce()

        if (pct <= alert && (prev < 0 || prev > alert))
            low()
        else if (pct >= alert + 3)
            warned = false

        open = true      // so it can be seen
    }

    function resume() {
        simulating = false
        read()
    }

    // ── the pill and the capsule ─────────────────────────────
    function announce() {
        if (!present) {
            K4.Pildora.quitar("battery.nivel")
            return
        }
        K4.Pildora.registrar("battery.nivel", capacity + "%",
                             glyphOf(capacity), levelColor, 61, true)
    }

    //  Only unfolds in trouble: the pill already shows the %.
    K4.Capsula {
        plugin: "battery"
        extension: self.critical ? ({
            lado: "derecha",
            texto: K4.Idioma.f("Battery %1%", self.capacity),
            glifo: 0x0F0083,
            color: K4.Tema.rojo,
            largoMaximo: 260
        }) : null
    }

    // ── IPC ──────────────────────────────────────────────────
    K4.Ipc {
        target: "k4.battery"
        function state(): string {
            return JSON.stringify({
                present: self.present, capacity: self.capacity,
                status: self.status, charging: self.charging,
                full: self.full, health: self.health,
                cycles: self.cycles, volts: self.volts,
                degrees: self.degrees, timeMin: self.timeMin,
                critical: self.critical
            })
        }
        function open(): void { self.open = true }
        function close(): void { self.open = false }

        //  Show a made-up % (walks the REAL event path, alarm
        //  included) and come back to the real reading.
        function simulate(pct: string): void { self.simulate(parseInt(pct, 10)) }
        function restore(): void { self.resume() }
    }

    // ── global shortcut ──────────────────────────────────────
    //  Bind it in your Hyprland config as «k4:battery».
    K4.Atajo {
        name: "battery"
        onPressed: self.toggle()
    }

    // ── settings ─────────────────────────────────────────────
    K4.Ajustes {
        plugin: "battery"
        grupo: "Battery"
        desc: K4.Idioma.t("The liquid that measures your battery")
        opciones: [
            { id: "alert", tipo: "numero", nombre: K4.Idioma.t("Low battery threshold"),
              desc: K4.Idioma.t("Below this % the alarm sounds and the bar turns red"),
              glifo: 0x0F0083, min: 5, max: 50, paso: 5, unidad: "%" },
            { id: "effects", nombre: K4.Idioma.t("Island gestures"),
              desc: K4.Idioma.t("Tug when plugged in, shake when unplugged"), glifo: 0xF07CB },
            { id: "sound", nombre: K4.Idioma.t("System sounds"),
              desc: K4.Idioma.t("Desktop sounds on plug and unplug"), glifo: 0xF057E },
            { id: "tint", nombre: K4.Idioma.t("Tint the bar"),
              desc: K4.Idioma.t("Green while charging, amber on unplug, red in trouble"), glifo: 0xF03D8 }
        ]
        valores: ({
            alert: self.alert,
            effects: self.effects,
            sound: self.sound,
            tint: self.tint
        })
        onCambiado: function (id, valor) {
            if (id === "alert") self.alert = valor
            else if (id === "effects") self.effects = valor
            else if (id === "sound") self.sound = valor
            else if (id === "tint") self.tint = valor
            self.saveSettings()
        }
    }

    // ── startup ──────────────────────────────────────────────
    Component.onCompleted: function () { read() }

    // ── the view ─────────────────────────────────────────────
    view: Component { BatteryView { plugin: self } }
}
