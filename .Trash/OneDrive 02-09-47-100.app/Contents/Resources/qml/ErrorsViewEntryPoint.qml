/*************************************************************/
/*                                                           */
/* Copyright (C) Microsoft Corporation. All rights reserved. */
/*                                                           */
/*************************************************************/

import Colors 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
import QtQuick.Controls.Styles 1.4
import QtQml 2.2

import com.microsoft.OneDrive 1.0

import "fabricMdl2.js" as FabricMDL

import "HelperFunctions.js" as HelperFunctions

Rectangle
{
    readonly property int verticalPadding: 12
    readonly property int textPadding: 2
    readonly property int horizontalPadding: 12

    property var messageColors: (errorsModel.isWarningsOnly) ? Colors.errors_list.warning : Colors.errors_list.error

    height: ((errorsModel.hasSingleFrontPageEntry) ? singleErrorDisplay.height : entryPoint.height)
    width: parent.width

    color: (errorListHeaderMouseArea.containsMouse || errorListHeaderMouseArea.activeFocus) ?
        messageColors.background_hover :
        messageColors.background

    border.color: errorListHeaderMouseArea.activeFocus ? Colors.activity_center.error.border_alert_focus : "transparent"
    border.width: 1

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    // Used if we have a single error and it supports display on the main page.
    // Uses the same qml as the ListView delegate, so we have to hook up the data
    // in a way which mocks being in the list.
    ErrorsListItem
    {
        // Only visible if there is one item in the errors list
        visible: errorsModel.hasSingleFrontPageEntry

        property int index: 0

        // Forward declare properties exposed by ListView data model
        property var primaryText         : ""
        property var secondaryText       : ""
        property var primaryButtonText   : ""
        property var buttonOneVisible    : ""
        property var secondaryButtonText : ""
        property var buttonTwoVisible    : ""
        property var imageUrl            : ""
        property var fileImage           : ""
        property var checkboxText        : ""
        property var hasCheckbox         : ""
        property var hasLearnMoreLink    : ""
        property var learnMoreText       : ""
        property var learnMoreLink       : ""
        property var customControlsFile  : ""
        property var hasCustomControl    : ""
        property var itemIndexAccessibleText: ""

        // Attach to the hasSingleFrontPageEntry property so when the error changes,
        // strings will all be refreshed
        property var hasSingleFrontPageEntry: errorsModel.hasSingleFrontPageEntry

        // Handles updating text when the error changes
        onHasSingleFrontPageEntryChanged: {

            if (errorsModel.hasSingleFrontPageEntry)
            {
                primaryText             = errorsModel.GetPrimaryErrorData("primaryText")
                secondaryText           = errorsModel.GetPrimaryErrorData("secondaryText")
                primaryButtonText       = errorsModel.GetPrimaryErrorData("primaryButtonText")
                buttonOneVisible        = errorsModel.GetPrimaryErrorData("buttonOneVisible")
                secondaryButtonText     = errorsModel.GetPrimaryErrorData("secondaryButtonText")
                buttonTwoVisible        = errorsModel.GetPrimaryErrorData("buttonTwoVisible")
                imageUrl                = errorsModel.GetPrimaryErrorData("imageUrl")
                fileImage               = errorsModel.GetPrimaryErrorData("fileImage")
                checkboxText            = errorsModel.GetPrimaryErrorData("checkboxText")
                hasCheckbox             = errorsModel.GetPrimaryErrorData("hasCheckbox")
                hasLearnMoreLink        = errorsModel.GetPrimaryErrorData("hasLearnMoreLink")
                learnMoreText           = errorsModel.GetPrimaryErrorData("learnMoreText")
                learnMoreLink           = errorsModel.GetPrimaryErrorData("learnMoreLink")
                customControlsFile      = errorsModel.GetPrimaryErrorData("customControlsFile")
                hasCustomControl        = errorsModel.GetPrimaryErrorData("hasCustomControl")
                itemIndexAccessibleText = errorsModel.GetPrimaryErrorData("itemIndexAccessibleText")
            }
        }
    }

    // If there are multiple errors or errors that can only be displayed in the list,
    // this will show the entry point to the errors list
    Rectangle {
        id: entryPoint
        
        // Only visible if there are more than one items in the errors list
        visible: !errorsModel.hasSingleFrontPageEntry

        height: visible ? (errorTextGroupV2.height + (2 * parent.verticalPadding)) : 0
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: "transparent"
        
        Image {
            id: errorIconV2
            width: 48
            height: 48
            sourceSize.width:  48
            sourceSize.height: 48
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: horizontalPadding
            source: errorsModel.isWarningsOnly ?
                        "file:///" + imageLocation + "infoIcon.svg" :
                        "file:///" + imageLocation + "errorIcon.svg";
            fillMode: Image.PreserveAspectFit
        }

        Column {
            id: errorTextGroupV2
            anchors.left: errorIconV2.right
            anchors.leftMargin: horizontalPadding
            anchors.right : rightArrowButton.left
            anchors.topMargin: verticalPadding
            anchors.top: parent.top
            height: (errorPrimaryV2.height + errorSecondaryV2.height + textPadding)
            spacing: textPadding

            Text {
                id: errorPrimaryV2
                color: errorListHeaderMouseArea.containsMouse ?
                    messageColors.text_hover :
                    messageColors.text
                text: errorsModel.errorEntryHeaderText

                font.family: "Segoe UI Semibold"
                font.pixelSize: 14
                anchors.left: errorTextGroupV2.left
                anchors.right: errorTextGroupV2.right
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
            }

            Text {
                id: errorSecondaryV2
                color: errorListHeaderMouseArea.containsMouse ?
                    messageColors.text_hover :
                    messageColors.text
                text: errorsModel.errorEntrySecondaryText
                font.pixelSize: 12
                anchors.left: errorTextGroupV2.left
                anchors.right: errorTextGroupV2.right
                font.family: "Segoe UI"
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                visible: (contentWidth > 0)
            }
        }

        Image {
            id: rightArrowButton
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            height: 32
            width: 32
            sourceSize.width:  32
            sourceSize.height: 32
            source: headerModel.isRTL ?
                "file:///" + imageLocation + "backArrow.svg" : // RTL should use the back arrow
                "file:///" + imageLocation + "forwardArrow.svg"  // LTR should use forward arrow
        }

        MouseArea
        {
            id: errorListHeaderMouseArea
            anchors.fill: parent
            hoverEnabled: true

            activeFocusOnTab: true
            Accessible.focusable: true
            Accessible.onPressAction: {
                errorsModel.SetErrorViewOpened(true);
            }
            Accessible.name: errorsModel.errorEntryBannerAccessibleText
            Accessible.ignored: !visible
            Accessible.role: Accessible.Button

            Keys.onReturnPressed: switchToErrorsView(true);
            Keys.onSpacePressed: switchToErrorsView(true);
            onClicked: switchToErrorsView(false);
        }
    }
}