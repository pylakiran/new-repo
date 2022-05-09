/*************************************************************/
/*                                                           */
/* Copyright (C) Microsoft Corporation. All rights reserved. */
/*                                                           */
/*************************************************************/

import Colors 1.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import QtQuick.Controls.Styles 1.4

import "fabricMdl2.js" as FabricMDL

Rectangle {
    id: root
    objectName: "wizardWindowRoot"

    property bool isConfirmDialogUp: ((state === "confirmDialogUp") || (state === "imageConfirmDialogUp"))
    opacity: isConfirmDialogUp ? 0.6 : 1.0

    property string fullImageLocation: "file:///" + imageLocation

    width: wizardWindow.defaultWidth
    height: wizardWindow.defaultHeight

    color: Colors.common.background

    LayoutMirroring.enabled: wizardWindow.isRTL
    LayoutMirroring.childrenInherit: true

    function _(key) {
        return wizardWindow.getLocalizedMessage(key);
    }

    state: wizardWindow.dialogState
    states: [
        State {
            name: "dialogHidden"
        },
        State {
            name: "confirmDialogUp"
            StateChangeScript {
                name: "onSwitchToConfirmDialogUpState"
                script: {
                    confirmDialog.open();
                    confirmDialog.forceActiveFocus();
                }
            }
        },
        State {
            name: "imageConfirmDialogUp"
            StateChangeScript {
                name: "onSwitchToImageDialogUpState"
                script: {
                    imageConfirmDialog.open();
                    imageConfirmDialog.forceActiveFocus();
                }
            }
        }
    ]

    Loader {
        id: myLoader
        objectName: "wizardWindowLoader"

        source: wizardWindow.loaderSource
        anchors.fill: parent
        asynchronous: true
        visible: (status === Loader.Ready)
        focus: true

        onStatusChanged: {
            console.log("Loader src: " + source + " status: " + status);

            if (status === Loader.Null)
            {
                spinningText.forceActiveFocus();
            }

            if (status === Loader.Ready)
            {
                wizardWindow.onLoaderReady();
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        height: childrenRect.height

        width: parent.width
        visible: ((myLoader.status !== Loader.Ready) && !wizardWindow.isBrowserLoaded)
        color: "transparent"

        Image {
            id: spinningGraphic
            source: "file:///" + imageLocation + "loading_spinner.svg"
            sourceSize.height: 28
            sourceSize.width: 28

            Accessible.ignored: true

            anchors.horizontalCenter: parent.horizontalCenter

            NumberAnimation on rotation {
                id: rotationAnimation
                easing.type: Easing.InOutQuad
                from: -45
                to: 315
                duration: 1500
                loops: Animation.Infinite
                running: spinningGraphic.visible
            }
        }

        Text {
            id: spinningText
            text: wizardWindow.spinningText

            width: root.width - 40
            wrapMode: Text.WordWrap

            font.family: "Segoe UI"
            font.pixelSize: 14
            color: Colors.common.hyperlink

            horizontalAlignment: Text.Center
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: spinningGraphic.bottom
                topMargin: 4
            }

            Accessible.ignored: !spinningText.visible
            Accessible.role: Accessible.StaticText
            Accessible.name: spinningText.text
            Accessible.readOnly: true
            Accessible.focusable: true
        }

        Text {
            id: spinningSubText
            text: wizardWindow.spinningSubText

            visible: parent.visible
            width: root.width - 40
            wrapMode: Text.WordWrap

            font.family: "Segoe UI"
            font.pixelSize: 12
            color: Colors.common.hyperlink

            horizontalAlignment: Text.Center
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: spinningText.bottom
                topMargin: 2
            }

            Accessible.ignored: !spinningSubText.visible
            Accessible.role: Accessible.StaticText
            Accessible.name: spinningSubText.text
            Accessible.readOnly: true
            Accessible.focusable: true
        }
    }

    ConfirmDialog {
        id: confirmDialog
        isRTL: wizardWindow.isRTL

        // we break Windows paradigm here since we want the default button to be on the right for Wizards
        defaultButtonOnLeft: false

        dialogTitleText: wizardWindow.confirmDialogPrimaryText
        dialogBodyText: wizardWindow.confirmDialogSecondaryText

        accessibleDialogTitleText: wizardWindow.confirmDialogAccessiblePrimaryText

        button1Text: wizardWindow.confirmDialogButtonOneText
        button2Text: wizardWindow.confirmDialogButtonTwoText
        xButtonAltText: _("SignInCloseButtonText")

        headerBottomPadding: 10

        modal: true

        onButton1Clicked: {
            wizardWindow.onDialogClosed(1);
        }

        onButton2Clicked: {
            wizardWindow.onDialogClosed(2);
        }

        onDismissed: reject()
        onRejected: {
            wizardWindow.onDialogClosed(0);
        }
    }

    ImageConfirmDialog {
        id: imageConfirmDialog
        isRTL: wizardWindow.isRTL

        property int folderType: 0

        // we break Windows paradigm here since we want the default 'Cancel' button to be on the right
        defaultButtonOnLeft: false

        dialogTitleText: wizardWindow.confirmDialogPrimaryText
        dialogBodyText: wizardWindow.confirmDialogSecondaryText

        accessibleDialogTitleText: wizardWindow.confirmDialogAccessiblePrimaryText

        linkButtonText: wizardWindow.confirmDialogLinkButtonText
        button1Text: wizardWindow.confirmDialogButtonOneText
        button2Text: wizardWindow.confirmDialogButtonTwoText
        xButtonAltText: _("SignInCloseButtonText")

        imageSource: fullImageLocation + wizardWindow.confirmDialogImageSource
        imageLabel: wizardWindow.confirmDialogImageLabel
        imageWidth: 97
        imageHeight: 74

        modal: true

        onButton1Clicked: {
            wizardWindow.onDialogClosed(1);
        }

        onButton2Clicked: {
            wizardWindow.onDialogClosed(2);
        }

        onLinkButtonClicked: {
            wizardWindow.onDialogClosed(3);
        }

        onDismissed: reject()
        onRejected: {
            wizardWindow.onDialogClosed(0);
        }
    }
}
