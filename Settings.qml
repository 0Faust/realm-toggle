import QtQuick
import qs.config
import qs.services
import qs.widgets

// Settings → Plugins → Смена измерения
Column {
    property var plugin
    width: parent ? parent.width : 400
    spacing: Theme.u * 5

    // live status block at top
    PxGroup {
        title: I18n.t("Текущий режим", "Current realm")
        icon: "starSparkle"
        width: parent.width

        SettingRow {
            label: I18n.t("Измерение", "Realm")
            PxText {
                text: Angel.demon
                    ? I18n.t("😈 Ад (демонесса)", "😈 Hell (demoness)")
                    : I18n.t("♡ Небеса (ангел)",  "♡ Heaven (angel)")
                font.bold: true
                color: Angel.demon ? Theme.danger : Theme.accent
            }
        }
        SettingRow {
            label: I18n.t("Портал", "Portal")
            hint: I18n.t("открывается после 3 возвратов из ада", "opens after 3 returns from hell")
            PxText {
                text: Angel.portalOpen
                    ? I18n.t("открыт ✓", "open ✓")
                    : Angel.returns + "/" + Angel.returnsNeeded
                color: Angel.portalOpen ? Theme.ok : Theme.textDim
            }
        }
        SettingRow {
            label: I18n.t("Анимация", "Animation")
            PxText {
                text: Angel.transition !== ""
                    ? (Angel.transition === "toHell"
                        ? I18n.t("падение…", "falling…")
                        : I18n.t("подъём…",  "ascending…"))
                    : I18n.t("готова", "ready")
                dim: Angel.transition === ""
            }
        }
    }

    PxGroup {
        title: I18n.t("Кнопка на панели", "Bar button")
        icon: "starSparkle"
        width: parent.width

        SettingRow {
            label: I18n.t("Показывать текст", "Show label")
            hint: I18n.t("«рай ♡» / «ад 😈» рядом с иконкой", "'Heaven ♡' / 'Hell 😈' next to the icon")
            PxToggle {
                checked: plugin ? plugin.get("showLabel", true) : true
                onToggled: c => plugin.set("showLabel", c)
            }
        }
    }
}
