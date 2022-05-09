/************************************************************ */
/*                                                            */
/* Copyright (C) Microsoft Corporation. All rights reserved.  */
/*                                                            */
/**************************************************************/

import Colors 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0

// FabricRadioButton
//
//      A QML implementation of the Office UI fabric radio button
//
//      See some examples on the public web: https://developer.microsoft.com/en-us/fabric#/controls/web/choicegroup
//
//      People who want to use this button need to provide:
//      1. text
//      2. onToggled callback
//
//      Optionally you may customize the min size of the button and the padding.
//
//      For accessibility, the expected behavior for a group of radio buttons is for tab
//      to enter the group of buttons, and then arrow keys should be used to navigate within
//      the group. This is so keyboard users do not need to navigate through the full list of
//      items just to navigate to the bottom of the menu. Additionally, while not in scan-mode,
//      navigating to the next radio button should automatically select that radio button.
//
//      Radio buttons are auto-exclusive by default. Only one button can be checked
//      at any time amongst radio buttons that belong to the same parent item.
//      https://doc.qt.io/qt-5/qml-qtquick-controls2-radiobutton.html

RadioButton {
    id: button

    activeFocusOnTab: false
    Accessible.role: Accessible.RadioButton
    Accessible.name: text
    Accessible.onToggleAction: toggled();
    Accessible.onPressAction: toggled();
    onClicked: toggled()

    // See accessibility note for RadioButtons above. This auto-selects the radio button
    // when it gains focus.
    onActiveFocusChanged: {
        if (activeFocus && !checked) {
            checked = true;
            toggled();
        }
    }

    contentItem: Text {
        leftPadding: 11
        rightPadding: 11
        anchors {
            left: indicator.right
            right: parent.right
        }
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.family: "Segoe UI"
        font.pixelSize: 14
        text: parent.text
        color: Colors.common.text
        wrapMode: Text.WordWrap
    }

    indicator: Rectangle {
        property int radioButtonSize: 18
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        width: radioButtonSize
        height: radioButtonSize
        radius: radioButtonSize / 2
        border.color: checked ? Colors.fabric_button.primary.radio_button_selected : Colors.common.text

        // This is the inner circle that appears when the RadioButton is selected
        Rectangle {
            property int indicatorPadding: 8
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.radioButtonSize - indicatorPadding
            height: parent.radioButtonSize - indicatorPadding
            radius: (parent.radioButtonSize - indicatorPadding) / 2

            color: Colors.fabric_button.primary.radio_button_selected
            visible: checked
        }
    }
}
