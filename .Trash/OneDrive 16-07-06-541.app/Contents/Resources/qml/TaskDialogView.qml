/*************************************************************/
/*                                                           */
/* Copyright (C) Microsoft Corporation. All rights reserved. */
/*                                                           */
/*************************************************************/
import Colors 1.0
import QtQml 2.2
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2
import TaskDialogViewModel 1.0

Rectangle {
    id: root

    property string fullImageLocation: "file:///" + imageLocation
    property int bottomMargin: 24
    property int topMargin: 15
    
    // Task Dialog will have a fixed width but dynamic height
    width: 576
    height: childrenRect.height + topMargin + bottomMargin
    color: Colors.common.background

    LayoutMirroring.enabled: viewModel.isRTL
    LayoutMirroring.childrenInherit: true

    Row {
        id: header
        
        width: parent.width
        height: headerText.height
        spacing: 8
        
        anchors.top: parent.top
        anchors.topMargin: topMargin
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        
        Image {
            id: headerIcon
            source: fullImageLocation + viewModel.iconImage
            width: viewModel.iconSize
            height: viewModel.iconSize
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.Pad
            anchors.verticalCenter: headerText.verticalCenter
            
            Accessible.ignored: true
        }

        Text {
            id: headerText
            
            width: parent.width - headerIcon.width - header.spacing
            text: viewModel.header
            color: Colors.common.text
            font.family: "Segoe UI Semibold"
            font.pixelSize: 23
            wrapMode: Text.WordWrap
            
            Accessible.role: Accessible.StaticText
            Accessible.name: text
            Accessible.readOnly: true
        }
    }
    
    Column {
        id: body
        spacing: 18

        width: parent.width
        height: childrenRect.height
                
        anchors.top: header.bottom
        anchors.topMargin: 11
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 24
        anchors.rightMargin: 24

        // TextWithLink does not require a link (link is optional)
        // This is treated as a regular text body if there are no links
        TextWithLink {
            id: bodyText

            embeddedLinkModel: viewModel.body
            font.family: "Segoe UI"
            font.pixelSize: 14
            color: Colors.common.text

            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WordWrap
            anchors.left: parent.left
            anchors.right: parent.right

            onLinkActivated: {
                // Called on Mouse Click
                Qt.openUrlExternally(viewModel.bodyLink);
            }
            callback: function() {
                // Called on Keyboard Enter Key
                Qt.openUrlExternally(viewModel.bodyLink);
            }
        }

        // Additional Text is optional. Callers must set the text to enable this component
        Text {
            id: additionalBodyText

            text: viewModel.additionalBody
            visible:(additionalBodyText.text !== "")
            
            anchors.left: parent.left
            anchors.right: parent.right
            
            color: Colors.common.text
            font.family: "Segoe UI Semibold"
            font.pixelSize: 14
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignLeft
            
            Accessible.role: Accessible.StaticText
            Accessible.name: text
            Accessible.ignored: !visible
            Accessible.readOnly: true
        }
        
       
       // Checkbox is optional. Callers must set the text to enable this component
       CheckBox {
            id: checkBox

            visible: (checkBox.text !== "")
            spacing: 5
            topPadding: -1
            bottomPadding: 0
            
            anchors.left: parent.left
            anchors.right: parent.right
            
            contentItem: Text {
                id: checkboxTextLabel
                width: checkBox.width
                anchors.left: indicatorBox.right
                leftPadding: checkBox.spacing
                rightPadding: checkBox.spacing
                text: viewModel.checkBox
                color: Colors.common.text

                font.pixelSize: 14
                font.family: "Segoe UI"
            }
            
            checked: viewModel.checkBoxValue
            onClicked: { viewModel.checkBoxValue = checked; }
            indicator: Rectangle {
                id: indicatorBox
                implicitWidth: 20
                implicitHeight: 20
                    
                border.width: parent.visualFocus ? 2 : 1
                border.color: parent.visualFocus ? Colors.activity_center.common.focused_border :  Colors.activity_center.common.focused_border
                
                anchors.left: parent.left
                Image {
                    sourceSize.width:  20
                    sourceSize.height: 20
                    anchors.fill: parent
                    source: fullImageLocation + "checkboxComposite.svg"
                    visible: checkBox.checked
                }
            }

            // Workaround for accessibility, Controls2.0 read accessible text from text,
            // instead of setting Accessible.name. Displayed text is based off contentItem (checkboxTextLabel)
            text: checkboxTextLabel.text
            Accessible.ignored: !visible
            Accessible.role: Accessible.CheckBox
            Accessible.focusable: true
        }
    }

    Row {
        id: buttonPane
        spacing: 8
        width: parent.width
        height: childrenRect.height

        anchors.top: body.bottom
        anchors.topMargin: 34
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        
        // Mac shows the primary button on the Right
        // Windows shows the primary button on the Left
        layoutDirection: (Qt.platform.os === "osx") ? Qt.RightToLeft : Qt.LeftToRight
        
        FabricButton {
            id: primaryButton
            
            // Cover the whole width of the dialog if the second button is not visible
            width: (secondaryButton.visible) ? 260 : parent.width
            height: contentItem.paintedHeight + 12
            focus: true

            buttonText: viewModel.getButtonText(TaskDialogViewModel.PrimaryButton)

            Accessible.role: Accessible.Button
            Accessible.name: primaryButton.buttonText
            Accessible.ignored: !primaryButton.visible
            Accessible.onPressAction: primaryButton.clicked()
            Keys.onReturnPressed: primaryButton.clicked()
            Keys.onEnterPressed:  primaryButton.clicked()

            onClicked: function() {
                viewModel.onButtonClicked(TaskDialogViewModel.PrimaryButton)
            }
        }

        // Secondary Button is optional. Caller must set text to enable this component
        FabricButton {
            id: secondaryButton
            width: 260
            height: contentItem.paintedHeight + 12

            buttonText: viewModel.getButtonText(TaskDialogViewModel.SecondaryButton)
            visible: (secondaryButton.text !== "")
            buttonStyle: "secondary"

            Accessible.role: Accessible.Button
            Accessible.name: secondaryButton.buttonText
            Accessible.ignored: !secondaryButton.visible
            Accessible.onPressAction: secondaryButton.clicked()
            Keys.onReturnPressed: secondaryButton.clicked()
            Keys.onEnterPressed:  secondaryButton.clicked()

            onClicked: function() {
                viewModel.onButtonClicked(TaskDialogViewModel.SecondaryButton)
            }
        }        
    }
}