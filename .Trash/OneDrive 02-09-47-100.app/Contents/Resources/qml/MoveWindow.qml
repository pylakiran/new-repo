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
import ViewModel 1.0

import "fabricMdl2.js" as FabricMDL

Rectangle {
    id: root
    objectName: "moveWindowRoot"

    color: Colors.common.background
    opacity: (restoreDialog.visible || interruptDialog.visible) ? 0.6 : 1.0

    // On this dialog the info area is the item that will absorb the difference between longer and
    // shorter text items that come up during localization. It will get a scroll bar when needed
    property int availableSpaceForInfoArea: root.height -
                                            headerSection.height -            // the header's padding is built in to it's height
                                            folderSelectionArea.height - 32 - // 32 is the folder selection area anchors
                                            footerSection.height - 32 -       // 32 is the footer section padding
                                            16;                               // 16 is the padding that we want on the bottom of the infoArea
    property string fullImageLocation: "file:///" + imageLocation
    property bool atLeastOneFolderInError: viewModel.documentsFolderItemState === "error" ||
                                           viewModel.picturesFolderItemState === "error" ||
                                           viewModel.desktopFolderItemState === "error"
    property bool nextDisabledByQuota: viewModel.nextDisabledByQuota
    property bool showDonePageInfoText: (areAnyFoldersSkipped || !viewModel.allFoldersMigrated)
    property bool areAnyFoldersSkipped: (viewModel.desktopSkipped ||
                                         viewModel.picturesSkipped ||
                                         viewModel.documentsSkipped)
    property bool isConfirmDialogUp: (restoreDialog.visible || interruptDialog.visible)

    function atLeastOneFolderHasProgressValue() {
        return (viewModel.hasDesktopProgressValue ||
                viewModel.hasDocumentsProgressValue ||
                viewModel.hasPicturesProgressValue);
    }

    LayoutMirroring.enabled: viewModel.isRTL
    LayoutMirroring.childrenInherit: true

    Accessible.role: Accessible.Pane
    Accessible.focusable: true
    Accessible.focused: false
    Accessible.name: "Microsoft OneDrive"
    Accessible.ignored: true

    // Workaround for Qt Bug 78050 - when changing active window
    // from a window with the Qt.Popup flag (Activity Center) to
    // a regular standalone window, initial focus doesn't
    // get assigned to any control in the window
    Window.onActiveChanged: {
        if (Window.active && !Window.activeFocusItem) {
            title.forceActiveFocus();
        }
    }

    width: 591
    height: 528

    state: viewModel.dialogState

    function openMobileUpsellPage() {
        Qt.openUrlExternally("https://aka.ms/Vu1ncw");
    }

    function chooseLinkTextColor(mouseArea) {
        var color = Colors.common.hyperlink;

        if (mouseArea.containsPress) {
            color = Colors.common.hyperlink_pressed;
        }
        else if (mouseArea.containsMouse) {
            color = Colors.common.hyperlink_hovering;
        }

        return color;
    }

    states: [
        State {
            name: "scanning"
            PropertyChanges { target: remainingSpace; visible: false; }
            PropertyChanges { target: infoAreaGraphic; visible: true }
        },
        State {
            name: "userInput"
            PropertyChanges { target: infoAreaText; color: (viewModel.errorSeverity === ViewModel.RedError) ? Colors.move_window.cancelledSecondaryText : Colors.common.text_secondary }
            PropertyChanges { target: infoAreaGraphic; visible: false }
            PropertyChanges { target: infoAreaErrorIcon; visible: (viewModel.infoAreaText.hyperlinkedText !== "") }
            PropertyChanges { target: rotationAnimation; from: 0 }
            PropertyChanges { target: rotationAnimation; running: false }
        },
        State {
            name: "userInputDialog"
            PropertyChanges { target: infoAreaGraphic; visible: false }
            PropertyChanges { target: rotationAnimation; from: 0 }
            PropertyChanges { target: rotationAnimation; running: false }
            StateChangeScript {
                name: "onSwitchToUserInputDialogState"
                script: {
                    interruptDialog.open();
                }
            }
        },
        State {
            name: "migrating"
            PropertyChanges { target: infoAreaGraphic; visible: false; }
        },
        State {
            name: "finished"
            PropertyChanges { target: folderSelectionRow; visible: false; Accessible.ignored: true; }
            PropertyChanges { target: folderSelectionArea; height: finishedImage.height; }
            PropertyChanges { target: finishedImage; visible: true; }
            PropertyChanges { target: infoAreaGraphic; visible: false; }
            PropertyChanges { target: infoAreaText; color: (viewModel.errorSeverity === ViewModel.RedError) ? Colors.move_window.cancelledSecondaryText : Colors.common.text_secondary }
            PropertyChanges { target: viewActivityCenterButton; visible: true; }
            PropertyChanges { target: getAppTextLink; visible: !showDonePageInfoText; }
            PropertyChanges { target: footerSection; visible: false; }
            PropertyChanges { target: scrollView; Accessible.ignored: true; }
            PropertyChanges { target: infoAreaText; Accessible.ignored: true; }
        },
        State {
            name: "blocked"
            PropertyChanges { target: infoAreaText; color: Colors.move_window.cancelledSecondaryText }
            PropertyChanges { target: infoAreaErrorIcon; visible: true }
            PropertyChanges { target: tryAgainButton; visible: false; }
            PropertyChanges { target: infoAreaGraphic; visible: false }
            PropertyChanges { target: rotationAnimation; from: 0 }
            PropertyChanges { target: rotationAnimation; running: false }
        }
    ]

    ConfirmDialog {
        id: interruptDialog
        isRTL: viewModel.isRTL

        // we break Windows paradigm here since we want the default button to be on the right for Wizards
        defaultButtonOnLeft: false

        dialogTitleText: viewModel.interruptDialogTitle
        dialogBodyText: viewModel.interruptDialogBody

        button1Text: viewModel.interruptDialogPrimaryButtonText
        button2Text: viewModel.interruptDialogSecondaryButtonText
        xButtonAltText: viewModel.xButtonAccessibleName

        modal: true

        onButton2Clicked: reject()
        onDismissed: reject()

        onRejected: {
            // Skip
            viewModel.handleInterruptDialogResult(0);
        }

        onButton1Clicked: {
            // Try again
            viewModel.handleInterruptDialogResult(1);
        }

        closePolicy: Popup.CloseOnEscape
    }

    function getImageLabelForFolder(folderType) {
        if (folderType === ViewModel.Desktop) {
            return viewModel.desktopFolderName;
        } else if (folderType === ViewModel.Documents) {
            return viewModel.documentsFolderName;
        } else if (folderType === ViewModel.Pictures) {
            return viewModel.picturesFolderName;
        }
        return "";
    }

    function getImageSourceForFolder(folderType) {
        if (folderType === ViewModel.Desktop) {
            return fullImageLocation + "folder_image_desktop.svg";
        } else if (folderType === ViewModel.Documents) {
            return fullImageLocation + "folder_image_documents.svg";
        } else if (folderType === ViewModel.Pictures) {
            return fullImageLocation + "folder_image_pictures.svg";
        }
        return "";
    }

    function showRestoreResultDialog() {
        restoreDialog.open();
        restoreDialog.forceActiveFocus();
    }

    ImageConfirmDialog {
        id: restoreDialog
        isRTL: viewModel.isRTL

        property int folderType: 0

        // we break Windows paradigm here since we want the default 'Cancel' button to be on the right
        defaultButtonOnLeft: false

        dialogTitleText: viewModel.restoreDialogTitle
        dialogBodyText: viewModel.restoreDialogBody

        accessibleDialogTitleText: viewModel.restoreDialogAccessibleTitle

        button1Text: viewModel.restoreDialogPrimaryButtonText
        button2Text: viewModel.restoreDialogSecondaryButtonText
        xButtonAltText: viewModel.xButtonAccessibleName

        imageSource: getImageSourceForFolder(restoreDialog.folderType)
        imageLabel: getImageLabelForFolder(restoreDialog.folderType)
        imageWidth: 97
        imageHeight: 74

        modal: true

        onButton2Clicked: {
            viewModel.onActionLinkActivated(restoreDialog.folderType);
        }

        onOpened: {
            viewModel.handleRestoreDialogOpenedClosed(restoreDialog.folderType, true /* opened */);
        }

        onClosed: {
            // Restore focus to the folder that
            // started the action
            if (folderType === ViewModel.Desktop) {
                desktopFolder.forceActiveFocus();
            } else if (folderType === ViewModel.Documents) {
                documentsFolder.forceActiveFocus();
            } else if (folderType === ViewModel.Pictures) {
                picturesFolder.forceActiveFocus();
            }

            viewModel.handleRestoreDialogOpenedClosed(restoreDialog.folderType, false /* opened */);
        }
    }

    Rectangle {
        id: headerSection
        color: Colors.common.background

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: childrenRect.height + 24

        Text {
            id: title
            font.family: "Segoe UI"
            wrapMode: Text.WordWrap
            text: viewModel.title
            color: Colors.move_window.title
            font.pixelSize: 28
            font.weight: Font.Light
            horizontalAlignment: Text.AlignHCenter

            Accessible.role: Accessible.StaticText
            Accessible.headingLevel: Accessible.HeadingLevel1
            Accessible.name: viewModel.title
            Accessible.readOnly: true
            Accessible.ignored: isConfirmDialogUp
            Accessible.focusable: true
            focus: true

            anchors {
                top: parent.top
                topMargin: 24
                left: parent.left
                leftMargin: 24
                right: parent.right
                rightMargin: 24
            }

            onTextChanged: {
                viewModel.announceTextChange(title, title.text, Accessible.AnnouncementProcessing_ImportantAll);
            }
        }

        TextWithLink {
            id: instructionText
            embeddedLinkModel: viewModel.informativeText

            font.family: "Segoe UI"
            font.pixelSize: 14
            wrapMode: Text.WordWrap

            color: Colors.common.text_secondary

            Accessible.ignored: isConfirmDialogUp
            Accessible.readOnly: true

            onLinkActivated: Qt.openUrlExternally(link)

            callback: function(text, index) {
                viewModel.onEmbeddedLinkActivated(text, index);
            }

            anchors {
                top: title.bottom
                topMargin: 24

                left: parent.left
                leftMargin: 24

                right: parent.right
                rightMargin: 24
            }
        }
    }

    Rectangle {
        id: folderSelectionArea
        height: folderSelectionRow.height
        color: Colors.common.background

        anchors {
            left: parent.left
            leftMargin: 24

            right: parent.right
            rightMargin: 24

            top: headerSection.bottom
            topMargin: 16
        }

        Image {
            id: finishedImage
            source: fullImageLocation + "done_graphic.svg"
            visible: false
            // we don't need to set the width because the fill mode will scale the width after we set the height
            height: showDonePageInfoText ? 214 : 248
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
        }

        Row {
            id: folderSelectionRow
            Accessible.ignored: true
            spacing: 4
            
            FolderItem {
                id: desktopFolder
                isAccessibleIgnored: !parent.visible || isConfirmDialogUp
                folderType: ViewModel.Desktop
                folderState: viewModel.desktopFolderItemState
                imageSource: fullImageLocation + "folder_image_desktop.svg"
                primaryText: viewModel.desktopFolderName
                secondaryText: viewModel.desktopSecondaryText
                actionLinkEnabled: !viewModel.disableDesktopOptOut
                enableUserInput: viewModel.dialogState === "userInput"
                progressPercentage: viewModel.desktopProgressValue
                isDeterminate: viewModel.hasDesktopProgressValue
                showSizeWhileInProgress: root.atLeastOneFolderHasProgressValue()
            }

            FolderItem {
                id: documentsFolder
                isAccessibleIgnored: !parent.visible || isConfirmDialogUp
                folderType: ViewModel.Documents
                folderState: viewModel.documentsFolderItemState
                imageSource: fullImageLocation + "folder_image_documents.svg"
                primaryText: viewModel.documentsFolderName
                secondaryText: viewModel.documentsSecondaryText
                actionLinkEnabled: !viewModel.disableDocumentsOptOut
                enableUserInput: viewModel.dialogState === "userInput"
                progressPercentage: viewModel.documentsProgressValue
                isDeterminate: viewModel.hasDocumentsProgressValue
                showSizeWhileInProgress: root.atLeastOneFolderHasProgressValue()
            }

            FolderItem {
                id: picturesFolder
                isAccessibleIgnored: !parent.visible || isConfirmDialogUp
                folderType: ViewModel.Pictures
                folderState: viewModel.picturesFolderItemState
                imageSource: fullImageLocation + "folder_image_pictures.svg"
                primaryText: viewModel.picturesFolderName
                secondaryText: viewModel.picturesSecondaryText
                actionLinkEnabled: !viewModel.disablePicturesOptOut
                enableUserInput: viewModel.dialogState === "userInput"
                progressPercentage: viewModel.picturesProgressValue
                isDeterminate: viewModel.hasPicturesProgressValue
                showSizeWhileInProgress: root.atLeastOneFolderHasProgressValue()
            }
        }
    }

    Rectangle {
        id: infoArea
        objectName: "infoArea"
        color: Colors.common.background
        border.color: scrollView.focus && scrollView.isScrollable ? Colors.move_window.scrollViewBorderColor : Colors.common.background
        height: Math.max(infoAreaGraphic.sourceSize.height, Math.min(availableSpaceForInfoArea, infoAreaText.height))

        anchors {
            top: folderSelectionArea.bottom
            topMargin: 16

            right: parent.right
            rightMargin: 24

            left: parent.left
            leftMargin: 24
        }

        // Set the visibility to false if no text to show.
        // Otherwise, if there is no text but visible is "true" this item
        // is included in TAB navigation, which we don't want when there's no text
        visible: (viewModel.infoAreaText.hyperlinkedText !== "")

        ScrollViewWithAcc {
            id: scrollView
            objectName: "infoAreaScrollView"
            property bool isScrollable: (infoAreaText.height > scrollView.height)

            // Do not announce the ScrollView itself (or its scrollbars)
            // in Accessibility. The underlying text will be short enough
            // that it won't need scrolling while narrating.
            Accessible.ignored: true

            anchors {
                left: (infoAreaGraphic.visible || infoAreaErrorIcon.visible) ? infoAreaGraphic.right : infoArea.left
                leftMargin: (infoAreaGraphic.visible || infoAreaErrorIcon.visible) ? 8 : 0
                top: parent.top
                right: parent.right
                bottom: parent.bottom
            }
            clip: true

            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Keys.onLeftPressed: nil
            Keys.onRightPressed: nil

            activeFocusOnTab: (infoAreaText.height > scrollView.height)
            
            TextWithLink {
                id: infoAreaText
                objectName: "infoAreaText"
                embeddedLinkModel: viewModel.infoAreaText

                font.family: "Segoe UI"
                font.pixelSize: 14
                width: scrollView.width - 6 // scroll view width - width of scroll bar
                wrapMode: Text.WordWrap

                color: Colors.move_window.title

                Accessible.ignored: (!visible || isConfirmDialogUp)
                Accessible.readOnly: true
                Accessible.focusable: true

                onLinkActivated: {
                    if (link.search("http") === 0) { // we found the http prefix at the begining of the string
                        Qt.openUrlExternally(link);
                   } else { // otherwise we assume this is a sc:// link that requests the client to do something
                       viewModel.handleClientAction(link);
                   }
                }

                callback: function(text, index) {
                    viewModel.onEmbeddedLinkActivated(text, index);
                }

                onTextChanged: {
                    if (!isConfirmDialogUp)
                    {
                        viewModel.announceTextChange(this, embeddedLinkModel.accessibleText, Accessible.AnnouncementProcessing_MostRecent);
                    }
                }
            }
        }

        Image {
            id: infoAreaErrorIcon
            visible: false
            source: (viewModel.errorSeverity === ViewModel.GreyWarning) ?
                        fullImageLocation + "infoIcon.svg" :
                        fullImageLocation + "errorIcon.svg"
            sourceSize.height: 22
            sourceSize.width: 22
            anchors {
                left: infoArea.left
                top: infoArea.top
            }

            Accessible.ignored: true
        }

        Image {
            id: infoAreaGraphic
            source: fullImageLocation + "loading_spinner.svg"
            sourceSize.height: 22
            sourceSize.width: 22
            anchors {
                left: infoArea.left
                top: infoArea.top
            }

            NumberAnimation on rotation {
                id: rotationAnimation;
                easing.type: Easing.InOutQuad
                from: -45;
                to: 315;
                duration: 1500;
                loops: Animation.Infinite
            }
            Accessible.ignored: true
        }
    }

    FabricButton {
        id: viewActivityCenterButton
        visible: false
        onClicked:viewModel.handleClientAction("sc://OpenActivityCenter")
        buttonText: viewModel.finishedButtonText

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: (showDonePageInfoText) ?
                     infoArea.bottom :
                     folderSelectionArea.bottom;
            topMargin: (showDonePageInfoText) ? 16 : 32
        }

        onVisibleChanged: {
            if (visible) {
                viewActivityCenterButton.forceActiveFocus();
            }
        }

        Accessible.onPressAction: onClicked()
        Keys.onEnterPressed: onClicked()
        Keys.onReturnPressed: onClicked()
        Keys.onSpacePressed: onClicked()
    }

    SimpleButtonLink {
        id: getAppTextLink

        visible: !infoArea.visible

        width: textcontrol.paintedWidth
        height: textcontrol.paintedHeight

        textcontrol.text: _("MoveWindowGetMobileApp")
        textcontrol.font.family: "Segoe UI"
        textcontrol.font.pixelSize: 12
        textcontrol.color: chooseLinkTextColor(mousearea)
        textcontrol.linkColor: chooseLinkTextColor(mousearea)

        anchors {
            horizontalCenter: viewActivityCenterButton.horizontalCenter
        }

        callback: function() {
            openMobileUpsellPage()
        }
    }

    Rectangle {
        id: footerSection
        color: Colors.common.background
        height: Math.max(remainingSpace.height, nextButton.height)

        anchors {
            bottom: parent.bottom
            bottomMargin: 32

            left: parent.left
            leftMargin: 24

            right: parent.right
            rightMargin: 24
        }

        Text {
            id: remainingSpace
            visible: (remainingSpace.text !== "")

            font.family: "Segoe UI"
            font.pixelSize: 14
            wrapMode: Text.WordWrap
            // if the remaining space is negative (i.e. by moving a selected folder the user will
            // go over quota) then we want to display the text in red.
            color: nextDisabledByQuota ? Colors.move_window.cancelledSecondaryText : Colors.common.text_secondary
            text: viewModel.remainingSpaceText

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: tryAgainButton.visible ? tryAgainButton.left : nextButton.left
                rightMargin: 8
            }

            Accessible.role: Accessible.StaticText
            Accessible.name: viewModel.remainingSpaceText
            Accessible.readOnly: true
            // Ignore when not visible or if text is empty
            Accessible.ignored: (!visible || isConfirmDialogUp)
        }

        FabricButton {
            id: tryAgainButton
            onClicked: viewModel.reScan()
            visible: atLeastOneFolderInError && ((viewModel.dialogState === "userInput") || (viewModel.dialogState === "userInputDialog"))
            enabled: visible
            buttonStyle: "secondary"
            buttonText: viewModel.tryAgainButtonText

            Accessible.role: Accessible.Button
            Accessible.name: viewModel.tryAgainButtonText
            Accessible.ignored: !visible || isConfirmDialogUp
            Accessible.onPressAction: viewModel.reScan()
            Keys.onReturnPressed: tryAgainButton.clicked()
            Keys.onEnterPressed:  tryAgainButton.clicked()

            anchors {
                verticalCenter: parent.verticalCenter
                right: nextButton.left
                rightMargin: 8
            }
        }

        FabricButton {
            id: nextButton
            onClicked: viewModel.onNextButtonClicked()
            buttonText: viewModel.nextButtonText
            visible: !viewModel.allFoldersMigrated && (viewModel.dialogState !== "finished")
            enabled: ((viewModel.dialogState === "userInput") && !nextDisabledByQuota &&
                      ((viewModel.desktopFolderItemState === "selected") ||
                       (viewModel.picturesFolderItemState === "selected") ||
                       (viewModel.documentsFolderItemState === "selected")))

            Accessible.role: Accessible.Button
            Accessible.name: viewModel.nextButtonText
            Accessible.ignored: !visible || isConfirmDialogUp
            Accessible.onPressAction: viewModel.onNextButtonClicked()
            Accessible.disabled: !enabled
            
            Keys.onReturnPressed: nextButton.clicked()
            Keys.onEnterPressed:  nextButton.clicked()

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 8
            }
        }
    }
}
