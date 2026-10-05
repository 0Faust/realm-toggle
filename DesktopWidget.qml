import QtQuick
import qs.config
import qs.services
import qs.widgets

// Desktop widget: big realm toggle button with live state display.
Item {
    id: root

    property var plugin
    property string screenName
    property var widget

    // hide when the game is off (no angel/demon shown)
    readonly property bool wantVisible: Angel.shown || Angel.demon

    implicitWidth:  Theme.u * 110
    implicitHeight: col.implicitHeight

    function toggle() {
        if (Angel.transition) return;
        if (Angel.portalOpen) {
            Angel.portal();
        } else if (Angel.demon) {
            Angel.getOut("stars");
        } else {
            Angel.toHell();
        }
    }

    // ---- animated realm label ----
    readonly property string realmWord: Angel.demon
        ? (Theme.hell ? I18n.t("ТЬМА",   "DARKNESS") : I18n.t("Ад",      "Hell"))
        : (Theme.hell ? I18n.t("СВЕТ",   "LIGHT")    : I18n.t("Небеса",  "Heaven"))

    readonly property color realmColor: Angel.demon
        ? (Theme.hell ? Theme.hellFlame : Theme.danger)
        : (Theme.hell ? Theme.hellGold  : Theme.accent)

    Column {
        id: col
        width: parent.width
        spacing: Theme.u * 4

        // ---- realm name + glow ----
        Item {
            width: parent.width
            height: title.implicitHeight + Theme.u * 4

            // glow behind the text
            Rectangle {
                anchors.centerIn: title
                width:  title.implicitWidth  + Theme.u * 8
                height: title.implicitHeight + Theme.u * 4
                radius: height / 2
                color:  root.realmColor
                opacity: Angel.transition !== "" ? 0.35 : Angel.demon ? 0.18 : 0.10
                Behavior on opacity { NumberAnimation { duration: 400 } }
                Behavior on color   { ColorAnimation   { duration: 600 } }
            }

            PxText {
                id: title
                anchors.centerIn: parent
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: root.realmWord
                kind: "title"
                font.family: Theme.hell && Theme.latin(text) ? Theme.fontHell : Theme.fontTitle
                font.pixelSize: Theme.hell && Theme.latin(text) ? Theme.hellPx(Theme.fs) : Theme.sizeTitle
                color: root.realmColor

                Behavior on color { ColorAnimation { duration: 500 } }
            }
        }

        // ---- status line ----
        PxText {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: {
                if (Angel.transition === "toHell")  return I18n.t("она падает…",   "falling…");
                if (Angel.transition === "ascend")   return I18n.t("она поднялась ♡", "ascending ♡");
                if (Angel.demon)                     return I18n.t("демонесса правит", "the demoness reigns");
                return I18n.t("ангелочек здесь ♡",  "little angel is here ♡");
            }
            dim: !Angel.demon
            color: Angel.demon
                ? (Theme.hell ? Theme.hellTextDim : Theme.textDim)
                : Theme.textDim
            kind: "tiny"
        }

        // ---- portal status (shows returns progress) ----
        PxText {
            visible: !Angel.portalOpen && !Angel.demon
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: I18n.t("портал: ", "portal: ") + Angel.returns + "/" + Angel.returnsNeeded
            kind: "tiny"
            dim: true
        }

        // ---- big toggle button ----
        PxButton {
            id: bigBtn
            anchors.horizontalCenter: parent.horizontalCenter
            hell: Theme.hell
            checked: Angel.demon
            icon: Angel.demon ? "moon" : "sun"
            text: {
                if (Angel.transition !== "") return I18n.t("…переход…", "…switching…");
                return Angel.demon
                    ? I18n.t("Вернуть ангела ♡", "Bring the angel back ♡")
                    : I18n.t("Призвать демонессу 😈", "Summon the demoness 😈");
            }
            enabled: !Angel.transition && Angel.shown
            onClicked: root.toggle()

            // pulse on transition start
            property real _s: 1.0
            scale: _s
            Connections {
                target: Angel
                function onTransitionChanged() {
                    if (Angel.transition !== "") btnPulse.restart();
                }
            }
            SequentialAnimation {
                id: btnPulse
                NumberAnimation { target: bigBtn; property: "_s"; to: 1.12; duration: 100; easing.type: Easing.OutQuad }
                NumberAnimation { target: bigBtn; property: "_s"; to: 1.0;  duration: 220; easing.type: Easing.InQuad }
            }
        }
    }
}
