import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.color

    Image {
        id: bg
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.35
    }

    Image {
        id: logo
        source: "logo.png"
        width: 140
        height: 140
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 90
    }

    Text {
        anchors.top: logo.bottom
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        text: config.HeaderText
        color: "white"
        font.pointSize: 22
        font.bold: true
    }

    Rectangle {
        id: loginBox
        width: 360
        height: 220
        radius: 14
        color: "#1a1a1acc"
        anchors.centerIn: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 14

            ComboBox {
                id: user
                Layout.fillWidth: true
                model: userModel
                currentIndex: userModel.lastIndex
            }

            TextField {
                id: password
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "Contraseña"
                onAccepted: sddm.login(user.currentText, password.text, session.currentIndex)
            }

            ComboBox {
                id: session
                Layout.fillWidth: true
                model: sessionModel
                currentIndex: sessionModel.lastIndex
            }

            Button {
                Layout.fillWidth: true
                text: "Entrar"
                onClicked: sddm.login(user.currentText, password.text, session.currentIndex)
            }
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20
        spacing: 12

        Button { text: "Reiniciar"; visible: sddm.canReboot; onClicked: sddm.reboot() }
        Button { text: "Apagar"; visible: sddm.canPowerOff; onClicked: sddm.powerOff() }
    }
}
