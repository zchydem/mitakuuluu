import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: page
    objectName: "account"
    allowedOrientations: Orientation.Portrait

    property string pushname: ""
    property string presence: ""
    property int creation: 0
    property int expiration: 0
    property bool active: true
    property bool isFree: true
    property string avatar: "/home/nemo/.whatsapp/avatar/" + roster.myJid

    canAccept: (roster.connectionStatus == 4) && (pushnameArea.text.length > 0) && (presenceArea.text.length > 0)

    Connections {
        target: whatsapp

        onPictureUpdated: {
            if (pjid == roster.myJid) {
                page.avatar = ""
                page.avatar = path
            }
        }
    }

    onStatusChanged: {
        if (status == DialogStatus.Opened) {
            pushname = settings.value("pushname", "WhatsApp user")
            pushnameArea.text = pushname
            presence = settings.value("status", "I'm using Mitakuuluu!")
            presenceArea.text = presence
            creation = settings.value("creation", 0)
            expiration = settings.value("expiration", 0)
            isFree = settings.value("kind", "free") == "free"
            active = settings.value("accountstatus", "active") == "active"
        }
    }

    onAccepted: {
        page.pushname = pushnameArea.text
        settings.setValue("pushname", pushnameArea.text)
        whatsapp.setMyPushname(pushnameArea.text)
        pushnameArea.focus = false
        page.forceActiveFocus()

        page.presence = presenceArea.text
        settings.setValue("presence", presenceArea.text)
        whatsapp.setMyPresence(presenceArea.text)
        presenceArea.focus = false
        page.forceActiveFocus()
    }

    function timestampToFullDate(stamp) {
        var d = new Date(stamp*1000)
        return Qt.formatDateTime(d, "dd MMM yyyy")
    }

    SilicaFlickable {
        anchors.fill: page
        clip: true

        PullDownMenu {
            MenuItem {
                text: "Delete everything"
                enabled: roster.connectionStatus == 4
                onClicked: {
                    deleteDialog.open()
                }
            }
            MenuItem {
                text: "Remove account"
                enabled: roster.connectionStatus == 4
                onClicked: {
                    remorseAccount.execute("Remove current account",
                                           function() {
                                                whatsapp.disconnect()
                                                whatsapp.removeAccount()
                                                pageStack.pop(roster, PageStackAction.Immediate)
                                                pageStack.replace(register)
                                           },
                                           5000)
                }
            }
        }

        DialogHeader {
            id: header
            title: "Account"
            acceptText: "Save"
        }

        Label {
            id: pushnameLabel
            text: "Nickname:"
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            anchors.top: pushnameArea.top
            anchors.topMargin: Theme.paddingSmall
        }

        TextField {
            id: pushnameArea
            anchors.top: header.bottom
            anchors.left: pushnameLabel.right
            anchors.right: parent.right
            text: page.pushname
            EnterKey.enabled: false//text.trim().length > 0
            EnterKey.highlighted: EnterKey.enabled
            //EnterKey.iconSource: "image://theme/icon-m-enter-next"
            //EnterKey.text: "save"
            /*EnterKey.onClicked: {
                page.pushname = text
                settings.setValue("pushname", text)
                whatsapp.setMyPushname(text)
                pushnameArea.focus = false
                page.forceActiveFocus()
            }*/
            onActiveFocusChanged: {
                if (activeFocus)
                    selectAll()
            }
        }

        Label {
            id: presenceLabel
            text: "Status:"
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            anchors.top: presenceArea.top
            anchors.topMargin: Theme.paddingSmall
        }

        TextField {
            id: presenceArea
            anchors.top: pushnameArea.bottom
            anchors.left: presenceLabel.right
            anchors.right: parent.right
            text: page.presence
            EnterKey.enabled: false//text.trim().length > 0
            EnterKey.highlighted: EnterKey.enabled
            //EnterKey.iconSource: "image://theme/icon-m-enter-next"
            //EnterKey.text: "save"
            /*EnterKey.onClicked: {
                page.presence = text
                settings.setValue("presence", text)
                whatsapp.setMyPresence(text)
                presenceArea.focus = false
                page.forceActiveFocus()
            }*/
            onActiveFocusChanged: {
                if (activeFocus)
                    selectAll()
            }
        }

        Label {
            id: labelCreated
            text: "Created: " + timestampToFullDate(page.creation)
            anchors.top: presenceArea.bottom
            anchors.topMargin: Theme.paddingLarge
            anchors.left: ava.right
            anchors.leftMargin: Theme.paddingSmall
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            wrapMode: Text.NoWrap
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeSmall
        }

        Label {
            id: labelExpired
            text: "Expiration: " + timestampToFullDate(page.expiration)
            anchors.top: labelCreated.bottom
            anchors.topMargin: Theme.paddingSmall
            anchors.left: ava.right
            anchors.leftMargin: Theme.paddingSmall
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            wrapMode: Text.NoWrap
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeSmall
        }

        Label {
            id: labelActive
            text: "Account status: " + (page.active ? "active" : "blocked")
            anchors.top: labelExpired.bottom
            anchors.topMargin: Theme.paddingSmall
            anchors.left: ava.right
            anchors.leftMargin: Theme.paddingSmall
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            wrapMode: Text.NoWrap
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeSmall
        }

        Label {
            id: labelType
            text: "Account type: " + (page.isFree ? "free" : "paid")
            anchors.top: labelActive.bottom
            anchors.topMargin: Theme.paddingSmall
            anchors.left: ava.right
            anchors.leftMargin: Theme.paddingSmall
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            wrapMode: Text.NoWrap
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeSmall
        }

        AvatarHolder {
            id: ava
            anchors.top: presenceArea.bottom
            anchors.topMargin: Theme.paddingLarge
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            width: 128
            height: 128
            source: page.avatar

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    avatarView.show(page.avatar)
                }
            }
        }
    }

    RemorsePopup {
        id: remorseAccount
    }

    Dialog {
        id: deleteDialog
        SilicaFlickable {
            anchors.fill: parent
            Column {
                width: parent.width - (Theme.paddingLarge * 2)
                anchors.centerIn: parent
                spacing: Theme.paddingLarge
                DialogHeader {
                    id: dheader
                    title: "Delete everything"
                    acceptText: "Delete!"
                }
                Label {
                    width: parent.width
                    text: "This action will delete your account from WhatsApp server, login information, conversations and contacts. Downloaded media files will remain."
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        onAccepted: {
            pageStack.pop(roster, PageStackAction.Immediate)
            pageStack.replace(removePage)
            whatsapp.removeAccountFromServer()
            roster.deleteEverything()
        }
    }

    Rectangle {
        id: avatarView
        anchors.fill: parent
        color: "#40FFFFFF"
        opacity: 0.0
        visible: opacity > 0.0
        onVisibleChanged: {
            console.log("avatarView " + (visible ? "visible" : "invisible"))
        }
        Behavior on opacity {
            FadeAnimation {}
        }
        function show(path) {
            avaView.source = path
            avatarView.opacity = 1.0
            page.backNavigation = false
        }
        function hide() {
            avaView.source = ""
            avatarView.opacity = 0.0
            page.backNavigation = true
        }
        function resizeAvatar(path) {
            selectPicture.selected.disconnect(avatarView.resizeAvatar)
            resizePicture.picture = path
            resizePicture.jid = roster.myJid
            resizePicture.selected.connect(avatarView.setNewAvatar)
            resizePicture.open(true)
        }
        function setNewAvatar(path) {
            resizePicture.selected.disconnect(avatarView.setNewAvatar)
            avaView.source = ""
            avaView.source = path
            whatsapp.setPicture(roster.myJid, avaView.source)
        }
        Image {
            id: avaView
            anchors.centerIn: parent
            asynchronous: true
            cache: false
        }
        MouseArea {
            enabled: avatarView.visible
            anchors.fill: parent
            onClicked: {
                console.log("avatarview clicked")
                avatarView.hide()
            }
        }
        Button {
            anchors.top: avaView.bottom
            anchors.horizontalCenter: avaView.horizontalCenter
            text: "Select"
            onClicked: {
                selectPicture.selected.connect(avatarView.resizeAvatar)
                selectPicture.setProcessImages()
                selectPicture.open()
            }
        }
    }
}