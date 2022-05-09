/*************************************************************/
/*                                                           */
/* Copyright (C) Microsoft Corporation. All rights reserved. */
/*                                                           */
/*************************************************************/

import Colors 1.0
import QtQuick 2.7
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.4

import "fabricMdl2.js" as FabricMDL

WizardTutorialPageBase {
    id: root
    anchors.fill: parent

    property string fullImageLocation: "file:///" + imageLocation

    header.title.text: _("FirstRunFinishFirstRunTitle")
    header.subtitle.visible: false
    header.subtitle.height: 56
    header.image.source: fullImageLocation + "fre_done.svg"
    header.image.height: 220
    header.image.width: 470

    nextButton.buttonText: _("StatusMenuItemOpenLocalFolder")
    nextButton.onClicked: pageModel.OpenOneDriveFolderClicked();

    additionalContent.anchors.bottom: nextButton.top
    additionalContent.anchors.bottomMargin: 25

    additionalContent.data: Rectangle {
        anchors.fill: additionalContent
        color: "transparent"

        CheckBox {
            id: theCheck
            visible: pageModel.shouldShowOpenAtLoginCheckbox

            Accessible.ignored: !theCheck.visible
            text: theText.text      // this gets picked up Accessible.name

            spacing: 3
            hoverEnabled: true

            topPadding: 1
            bottomPadding: 1
            leftPadding: 5

            anchors.bottom: parent.bottom

            onClicked: { pageModel.openAtLogin = checked; }

            FontLoader {
                id: fabricMDL2;
                source: Qt.platform.os === "osx" ? "FabExMDL2.ttf" : "file:///" + qmlEngineBasePath + "FabExMDL2.ttf"
            }

            background: Rectangle {
                id: theBkgnd
                color: "transparent"
                implicitWidth: theCheck.indicator.width + theCheck.spacing + theCheck.leftPadding + theCheck.rightPadding + theFocusRect.width + theCheck.spacing
            }

            indicator: Rectangle {
                id: theInd
                implicitHeight: 20
                implicitWidth: 20
                color: "transparent"

                anchors.left: theCheck.left
                anchors.verticalCenter: theContent.verticalCenter

                Rectangle {
                    anchors.centerIn: parent
                    width: 16
                    height: 16

                    border.width: 1
                    border.color: theCheck.hovered ?
                                      Colors.treeview_checkbox.border_unchecked_hovered :
                                      Colors.treeview_checkbox.border_unchecked

                    color: (theCheck.pressed ?
                              Colors.treeview_checkbox.fill_color_unchecked_pressed :
                              Colors.treeview_checkbox.fill_color_unchecked)

                    Text {
                        visible: (theCheck.checkState === Qt.Checked)
                        anchors.centerIn: parent
                        font.family: fabricMDL2.name
                        font.pixelSize: 13
                        color: Colors.common.text

                        text: FabricMDL.Icons.CheckMark
                    }
                }
            }

            contentItem: Rectangle {
                id: theContent
                color: "transparent"

                anchors.left: indicator.right

                Rectangle {
                    id : theFocusRect
                    width: childrenRect.width + theCheck.spacing + theText.anchors.leftMargin
                    color: (theCheck.hovered ? Colors.treeview_checkbox.text_hover : "transparent")
                    border.color: theCheck.activeFocus ?
                                      Colors.activity_center.list.background_focus : "transparent"

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    height: 20

                    Text {
                        id: theText
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        text: _("FirstRunFinishFirstRunOpenAtLoginCheckboxText")
                        font.family: "Segoe UI"
                        font.pixelSize: 14
                        color: Colors.common.text
                        font.weight: Font.Normal
                    }
                }
            }
        }
    }

}
