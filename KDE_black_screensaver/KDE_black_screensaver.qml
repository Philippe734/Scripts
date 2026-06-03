import QtQuick
import QtQuick.Window

Window {
    visible: true
    visibility: Window.FullScreen
    color: "black"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    Item {
        anchors.fill: parent
        focus: true
        Component.onCompleted: forceActiveFocus()

        Keys.onPressed: Qt.quit()

        MouseArea {
            anchors.fill: parent

            cursorShape: Qt.BlankCursor   // ← ici ça fonctionne

            onPressed: Qt.quit()
            onWheel: Qt.quit()
            onClicked: Qt.quit()
        }
    }
}
