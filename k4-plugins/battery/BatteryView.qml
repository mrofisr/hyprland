// ─────────────────────────────────────────────────────────────
//  BatteryView — the liquid.
//
//  A glass tank whose level is the charge, with sloshing waves,
//  bubbles and a floating bolt while charging. Opening pours the
//  liquid in from empty; in trouble the tank throbs red; when full
//  a glint sweeps the glass.
//
//  Everything lives inside the view, so nothing runs while the
//  island is not showing it: it is destroyed whole on close.
// ─────────────────────────────────────────────────────────────

import QtQuick
import K4 as K4

K4.Aparicion {
    id: raiz

    required property var plugin

    width: plugin.islandWidth
    height: plugin.islandHeight

    //  The level pours in on open: it starts at 0 and rises to the real one.
    property bool ready: false
    property real liquid: ready ? plugin.nivel : 0
    Behavior on liquid { NumberAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Timer { id: startup; interval: 140; onTriggered: raiz.ready = true }
    Component.onCompleted: startup.start()

    //  The liquid surface, in tank coordinates.
    readonly property real surfaceY: tank.height * (1 - liquid)

    // ── colors derived from the level ────────────────────────
    function shade(deltaL, deltaS, alpha) {
        const c = plugin.levelColor
        return Qt.hsla(c.hslHue / 360,
            Math.max(0, Math.min(1, c.hslSaturation + deltaS)),
            Math.max(0, Math.min(1, c.hslLightness + deltaL)), alpha)
    }

    readonly property color surfaceColor: shade(0.30, -0.06, 0.9)
    readonly property color lightColor: shade(0.16, -0.05, 1)
    readonly property color midColor: shade(0.05, 0, 1)
    readonly property color darkColor: shade(-0.14, 0.05, 1)

    //  The shared pulse of the halo and the bolt.
    property real pulse: 0
    SequentialAnimation on pulse {
        loops: Animation.Infinite
        running: true
        NumberAnimation { from: 0; to: 1; duration: 480; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1; to: 0; duration: 480; easing.type: Easing.InOutSine }
    }

    // ── the tank ─────────────────────────────────────────────
    Item {
        id: capsule
        x: 28
        y: 24
        width: 118
        height: 162

        //  The halo breathing behind the glass.
        Rectangle {
            id: halo
            anchors.fill: parent
            anchors.margins: -13
            radius: 36
            color: plugin.present ? plugin.levelColor : K4.Tema.apagado
            opacity: 0.05 + (plugin.charging || plugin.critical ? 0.17 : 0.02)
                     * (0.35 + 0.65 * pulse)
        }

        //  The glass.
        Rectangle {
            id: glass
            anchors.fill: parent
            radius: 30
            color: Qt.rgba(1, 1, 1, 0.05)
            border.width: 1.5
            border.color: Qt.rgba(1, 1, 1, 0.16)
            clip: true

            //  When full: a glint sweeping across the glass now and then.
            Rectangle {
                id: glint
                width: 26
                height: 320
                rotation: 18
                visible: plugin.full
                opacity: 0.0
                gradient: Gradient {
                    GradientStop { position: 0; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.45) }
                    GradientStop { position: 1; color: "transparent" }
                }
                SequentialAnimation {
                    loops: Animation.Infinite
                    running: glint.visible
                    PauseAnimation { duration: 1300 }
                    PropertyAction { target: glint; property: "x"; value: -60 }
                    PropertyAction { target: glint; property: "opacity"; value: 0.55 }
                    NumberAnimation { target: glint; property: "x"; to: 200; duration: 1100; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: glint; property: "opacity"; to: 0; duration: 250 }
                }
            }
        }

        //  The inner tank: this is where the liquid lives.
        Item {
            id: tank
            anchors.fill: parent
            anchors.margins: 7
            clip: true

            //  The liquid body and its waves.
            Rectangle {
                id: fill
                width: parent.width
                height: liquid * parent.height + 26
                y: parent.height - height
                clip: true
                visible: liquid > 0.02

                //  The liquid mass under the surface.
                Rectangle {
                    id: body
                    y: 26
                    width: parent.width
                    height: parent.height - 26
                    gradient: Gradient {
                        GradientStop { position: 0; color: lightColor }
                        GradientStop { position: 0.55; color: midColor }
                        GradientStop { position: 1; color: darkColor }
                    }
                }

                //  The meniscus: the thin line tying the waves together.
                Rectangle {
                    y: 23.7
                    width: parent.width
                    height: 2.5
                    radius: 1.25
                    color: surfaceColor
                }

                //  Three waves, back to front: the big one is the slowest.
                Rectangle {
                    id: backWave
                    y: 26 - 25
                    width: 92; height: 92
                    radius: 46
                    color: shade(0.24, -0.10, 1)
                    SequentialAnimation on x {
                        loops: Animation.Infinite
                        running: fill.visible
                        NumberAnimation { from: -36; to: 32; duration: 4300; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 32; to: -36; duration: 4300; easing.type: Easing.InOutSine }
                    }
                }
                Rectangle {
                    id: midWave
                    y: 26 - 18
                    width: 68; height: 68
                    radius: 34
                    color: shade(0.20, -0.08, 1)
                    SequentialAnimation on x {
                        loops: Animation.Infinite
                        running: fill.visible
                        NumberAnimation { from: 4; to: 66; duration: 3400; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 66; to: 4; duration: 3400; easing.type: Easing.InOutSine }
                    }
                }
                Rectangle {
                    id: frontWave
                    y: 26 - 12
                    width: 52; height: 52
                    radius: 26
                    color: lightColor
                    SequentialAnimation on x {
                        loops: Animation.Infinite
                        running: fill.visible
                        NumberAnimation { from: 18; to: 70; duration: 2600; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 70; to: 18; duration: 2600; easing.type: Easing.InOutSine }
                    }
                }

                //  Bubbles while charging, all against one clock.
                property real t: 0
                NumberAnimation on t {
                    from: 0; to: 1
                    duration: 3200
                    loops: Animation.Infinite
                    running: plugin.charging && liquid > 0.05
                }
                Repeater {
                    model: 4
                    Rectangle {
                        required property int index
                        x: 16 + index * 24
                        y: fill.height - 8
                            - ((fill.t + index * 0.25) % 1) * (fill.height - 34)
                        width: 5; height: 5
                        radius: 2.5
                        color: Qt.rgba(1, 1, 1, 0.55)
                        opacity: Math.min(0.5, Math.max(0, y / 30))
                        visible: plugin.charging && liquid > 0.05
                    }
                }
            }

            //  The bolt: floats above the surface and sinks with the charge.
            Item {
                id: bolt
                x: (tank.width - 26) / 2
                y: Math.min(Math.max(surfaceY - 34, 13), 110)
                width: 26; height: 26
                visible: plugin.charging && plugin.present

                K4.Glifo {
                    anchors.centerIn: parent
                    text: String.fromCodePoint(0xF140B)
                    font.pixelSize: 36
                    color: K4.Tema.amarillo
                    opacity: 0.30 + 0.15 * pulse
                }
                K4.Glifo {
                    anchors.centerIn: parent
                    text: String.fromCodePoint(0xF140B)
                    font.pixelSize: 24
                    color: K4.Tema.amarillo
                }
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: bolt.visible
                    NumberAnimation { from: 1; to: 1.13; duration: 430; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.13; to: 1; duration: 430; easing.type: Easing.InOutSine }
                }
            }

            //  In trouble: the alarm pulses over the liquid.
            K4.Glifo {
                id: alarm
                x: (tank.width - 30) / 2
                y: Math.min(Math.max(surfaceY - 40, 13), 110)
                width: 30; height: 30
                text: String.fromCodePoint(0xF0083)
                font.pixelSize: 26
                color: K4.Tema.rojo
                visible: plugin.critical && !plugin.charging && plugin.present
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: alarm.visible
                    NumberAnimation { from: 1; to: 1.24; duration: 380; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.24; to: 1; duration: 380; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // ── the divider ──────────────────────────────────────────
    Rectangle {
        x: 166
        y: 32
        width: 1
        height: 146
        color: K4.Tema.tenue
    }

    // ── the readout ──────────────────────────────────────────
    function dec(x, d) { return x.toFixed(d).replace(".", ",") }

    function timeText(m) {
        const h = Math.floor(m / 60)
        const r = m % 60
        return "≈ " + h + " h " + (r < 10 ? "0" : "") + r + " m"
    }

    function statusText() {
        if (!plugin.present) return K4.Idioma.t("No battery")
        if (plugin.charging) return K4.Idioma.t("Charging")
        if (plugin.full) return K4.Idioma.t("Full")
        if (plugin.status === "Not charging")
            return K4.Idioma.t("Plugged in, not charging")
        if (plugin.status === "Discharging")
            return K4.Idioma.t("Discharging")
        return ""
    }

    Item {
        x: 180
        y: 24
        width: 210
        height: 58
        K4.Etiqueta {
            id: figure
            text: plugin.present ? String(plugin.capacity) : "—"
            font.pixelSize: 48
            font.weight: Font.Light
        }
        K4.Etiqueta {
            anchors.left: figure.right
            anchors.leftMargin: 3
            anchors.bottom: figure.bottom
            anchors.bottomMargin: 9
            text: "%"
            color: K4.Tema.apagado
            font.pixelSize: 20
            font.weight: Font.Light
        }
    }

    K4.Etiqueta {
        x: 180
        y: 92
        text: statusText()
        font.pixelSize: 14
        font.weight: Font.DemiBold
        color: plugin.charging ? plugin.levelColor
             : plugin.critical ? K4.Tema.rojo
             : K4.Tema.apagado
    }

    K4.Etiqueta {
        x: 180
        y: 118
        text: plugin.timeMin >= 0
            ? timeText(plugin.timeMin)
              + (plugin.charging ? K4.Idioma.t(" to full")
                                 : K4.Idioma.t(" left"))
            : ""
        font.pixelSize: 12
        color: K4.Tema.apagado
    }

    K4.Etiqueta {
        x: 180
        y: 142
        text: plugin.health >= 0
            ? K4.Idioma.f("Health %1 %", plugin.health)
              + (plugin.cycles >= 0 ? " · " + plugin.cycles + " " + K4.Idioma.t("cycles") : "")
            : ""
        font.pixelSize: 11
        color: K4.Tema.apagado
    }

    K4.Etiqueta {
        x: 180
        y: 162
        text: (plugin.volts > 0 ? dec(plugin.volts, 1) + " V" : "")
              + (plugin.volts > 0 && plugin.degrees > 0 ? " · " : "")
              + (plugin.degrees > 0 ? dec(plugin.degrees, 1) + " °C" : "")
        font.pixelSize: 11
        color: K4.Tema.apagado
    }

    K4.Etiqueta {
        x: 180
        y: 184
        text: plugin.present ? "" : K4.Idioma.t("No BAT found in /sys")
        font.pixelSize: 11
        color: K4.Tema.tenue
    }

    // ── close ────────────────────────────────────────────────
    K4.Boton {
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.top: parent.top
        anchors.topMargin: 10
        glifo: String.fromCodePoint(0xF0156)
        color: K4.Tema.apagado
        onPulsado: plugin.close()
    }
}
