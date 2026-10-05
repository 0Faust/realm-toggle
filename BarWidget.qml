import QtQuick
import qs.config
import qs.services
import qs.widgets
import qs.modules.bar

// Bar button: one click switches heaven ↔ hell with full swap animation.
Item {
    id: root

    property var plugin
    property string screenName
    property var barWindow

    implicitWidth: btn.implicitWidth + Theme.u * 2
    implicitHeight: Theme.u * 13

    // ---- toggle logic ----
    // Angel.portal() works once portalOpen (returns >= 3 or Owner).
    // Before that we call toHell() / getOut() directly — same animation, same sound.
    function toggle() {
        if (Angel.transition)
            return;                          // already animating, skip
        if (Angel.portalOpen) {
            Angel.portal();
        } else if (Angel.demon) {
            Angel.getOut("stars");           // angel returns: light, choir
        } else {
            Angel.toHell();                  // demon arrives: quake, cracks
        }
    }

    // ---- colors & labels ----
    readonly property color btnColor: Angel.demon
        ? (Theme.hell ? Theme.hellFlame   : Theme.danger)
        : (Theme.hell ? Theme.hellGold    : Theme.accent)

    readonly property string labelText: {
        if (Angel.transition !== "")
            return "…";
        const showText = plugin ? plugin.get("showLabel", true) : true;
        if (!showText)
            return "";
        return Angel.demon
            ? I18n.t("рай ♡",  "Heaven ♡")
            : I18n.t("ад 😈",  "Hell 😈");
    }

    PxButton {
        id: btn
        anchors.centerIn: parent
        compact: true
        hell: Theme.hell
        checked: Angel.demon
        icon: Angel.demon ? "moon" : "sun"
        text: root.labelText
        enabled: !Angel.transition
        onClicked: root.toggle()

        // subtle scale pulse when a swap starts
        property real _scale: 1.0
        scale: _scale
        Connections {
            target: Angel
            function onTransitionChanged() {
                if (Angel.transition !== "")
                    pulseAnim.restart();
            }
        }
        SequentialAnimation {
            id: pulseAnim
            NumberAnimation { target: btn; property: "_scale"; to: 1.18; duration: 120; easing.type: Easing.OutCubic }
            NumberAnimation { target: btn; property: "_scale"; to: 1.0;  duration: 200; easing.type: Easing.InCubic }
        }
    }

    // tooltip on hover — shows current realm and portal status
    ToolTip {
        visible: hoverArea.containsMouse
        delay: 700
        text: Angel.demon
            ? I18n.t("Сейчас: ад · нажми чтобы вернуть ангела", "Now: hell · click to bring the angel back")
            : Angel.portalOpen
                ? I18n.t("Сейчас: рай · нажми чтобы открыть портал в ад", "Now: heaven · click to open the portal to hell")
                : I18n.t("Сейчас: рай · нажми чтобы призвать демонессу", "Now: heaven · click to summon the demoness")
    }
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
