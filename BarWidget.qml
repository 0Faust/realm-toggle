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

    // The plugin keeps its own hell-cycle state and never uses AngelOS'
    // return counter as the unlock condition.
    property bool _pluginReturnPending: false
    property int _pluginReturnSnapshot: -1

    implicitWidth: btn.implicitWidth + Theme.u * 2
    implicitHeight: Theme.u * 13

    // Restore the AngelOS return counter only after Angel has actually
    // completed the plugin-triggered ascent.
    Timer {
        id: restoreReturnsTimer
        interval: 50
        repeat: true
        onTriggered: {
            if (!root._pluginReturnPending) {
                stop();
                return;
            }

            if (!Angel.demon && Angel.transition === "" && root._pluginReturnSnapshot >= 0) {
                Story.player.returns = root._pluginReturnSnapshot;
                root._pluginReturnPending = false;
                root._pluginReturnSnapshot = -1;
                if (root.plugin) {
                    root.plugin.set("realmToggleReturnPending", false);
                    root.plugin.set("realmToggleHellEntered", false);
                    root.plugin.set("realmToggleHellPassed", true);
                }
                stop();
            }
        }
    }

    function returnToHeaven() {
        if (root._pluginReturnPending || Angel.transition)
            return;

        // Snapshot the real AngelOS counter. The plugin-triggered return
        // must leave it exactly as it was before this transition.
        root._pluginReturnSnapshot = Story.player.returns || 0;
        root._pluginReturnPending = true;
        if (root.plugin)
            root.plugin.set("realmToggleReturnPending", true);

        Angel.getOut("stars");
        restoreReturnsTimer.restart();
    }

    // ---- toggle logic ----
    // The first complete hell trip is controlled by this plugin itself.
    // AngelOS' 3-return portal rule is not used as the plugin's unlock.
    function toggle() {
        if (Angel.transition || root._pluginReturnPending)
            return;

        if (Angel.demon) {
            // A return is allowed only after this plugin has registered an
            // actual trip into hell.
            if (!(root.plugin && root.plugin.get("realmToggleHellEntered", false)))
                return;
            returnToHeaven();
        } else {
            if (root.plugin)
                root.plugin.set("realmToggleHellEntered", true);
            Angel.toHell();
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
        enabled: !Angel.transition && !root._pluginReturnPending
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
