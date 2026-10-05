# Realm Toggle (realm-toggle)

Плагин для AngelOS: кнопка на панели, которая одним кликом переключает рай и ад с полной анимацией перехода. В настройках можно скрыть текст рядом с иконкой и посмотреть текущий режим и состояние портала.

AngelOS plugin: a bar button that toggles heaven and hell with one click and the full swap animation. Settings let you hide the label and show the current realm and portal status.

## Установка / Install
Через Community Store или вручную:

    cp -a realm-toggle ~/.config/angelos/plugins/realm-toggle

Затем перезагрузите AngelOS и включите плагин в Settings → Plugins.

## Требования / Requirements
Нужна версия AngelOS с режимами «рай» и «ад» (сервис `Angel`). Проверено на AngelOS 3116fd7 (2026-10-04). Плагин не работает на оболочках без этого сервиса.

## Как работает / How it works
- Кнопка вызывает методы сервиса `Angel` самого AngelOS.
- Пункт контекстного меню запускает `qs -c angelos -n ipc call helper portal`.
- Сеть, внешние программы и чтение файлов не используются.

## Лицензия / License
MIT, см. LICENSE.
