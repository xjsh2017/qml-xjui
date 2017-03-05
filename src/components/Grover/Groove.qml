/*
 * QML Material - An application framework implementing Material Design.
 *
 * Copyright (C) 2014 Jordan Neidlinger <JNeidlinger@gmail.com>
 *               2016 Michael Spencer <sonrisesoftware@gmail.com>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import QtQuick 2.4
import Material 0.3

/*!
   \qmltype Slider
   \inqmlmodule Material

   \brief Sliders let users select a value from a continuous or discrete range of
   values by moving the slider thumb.
 */
Item {
    id: control

    /*!
       Set to \c true to enable a floating numeric value label above the slider knob
     */
    property bool numericValueLabel: false

    /*!
       Set to \c true to always show the numeric value label, even when not pressed
     */
    property bool alwaysShowValueLabel: false

    /*!
       Set to \c true if the switch is on a dark background
     */
    property bool darkBackground

    /*!
       The label to display within the value label knob, by default the sliders current value
     */
    property string knobLabel: control.value.toFixed(0)/4 + "\n" + control.value.toFixed(0)

    /*!
       The width of the value label knob
     */
    property int knobWidth: 64 * Units.dp

    /*!
       The height of the value label knob
     */
    property int knobHeight: 44 * Units.dp

    property int moveRate: 5;

    property alias panel: panel

    property real valueRange: maximumValue - minimumValue

    property real scrollbarSteps: Math.ceil(waveModel.cols() / valueRange - 1) + 2;


    property int grooveBasiceHeight: 5 * Units.dp//control.hasOwnProperty("grooveBasiceHeight")
//                            ? control.grooveBasiceHeight : 5 * Units.dp


    property color color: darkBackground ? Theme.dark.accentColor
                                         : Theme.light.accentColor

    property bool tickmarksEnabled: false

    property real value
    property real minimumValue
    property real maximumValue

    property int stepSize: 1

    property bool activeFocusOnPress: true

    implicitHeight: numericValueLabel ? 54 * Units.dp : 32 * Units.dp
    implicitWidth: 200 * Units.dp



    // /////////////////////////////////////////////////////////////////

    function log(says) {
        console.log("## Groove.qml ##: " + says);
    }

    // /////////////////////////////////////////////////////////////////

    signal scrollbarPosChanged(var delta, var pos)
    signal leftMoveClicked();
    signal rightMoveClicked();



    property Component scrollbar: Rectangle {
        width: parent.width
        height: 14 * Units.dp

        visible: handleScroll.width > 0 && handleScroll.width <= width

        radius: height / 2

        anchors.bottom: parent.bottom

        color: "transparent"

        border.color: "lightgrey"

        IconButton {
            id: moveleft
            iconName: "navigation/arrow_drop_up"
            rotation: -90

            anchors.left: parent.left
            anchors.leftMargin: -dp(1)
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                var tmp = handleScroll.x
                tmp -= control.scrollbarSteps * 1
                if (tmp >= 0)
                    handleScroll.x = tmp
            }
        }

        IconButton {
            id: moveRight
            iconName: "navigation/arrow_drop_down"
            rotation: -90

            anchors.right: parent.right
            anchors.rightMargin: -dp(1)
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                var tmp = handleScroll.x
                tmp += control.scrollbarSteps * 1
                if (tmp <= control.valueRange - handleScroll.width)
                    handleScroll.x = tmp;
            }
        }

        Rectangle {
            id: handleScroll
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height - dp(2)

            radius: height / 2
            width: control.valueRange - (waveModel.cols() - control.valueRange) / control.scrollbarSteps

            color: Theme.accentColor
            border.color: Qt.lighter(color)

            property real lastX: 0

            Rectangle {
                width: parent.height * 2 / 4
                height: width
                radius: height / 2

                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                drag.target: parent

                onClicked: {
                    log("gr.minimumValue = " + control.minimumValue + ", gr.maximumValue = " + control.maximumValue)
                    log("gr.scrollbarSteps = " + control.scrollbarSteps + ", gr.width = " + control.width)
                    log("gr.scrollbar.width = " + handleScroll.width + ", gr.scrollbar.x = " + handleScroll.x)
                }
            }

            onXChanged: {
                if (x <  dp(1))
                    x =  0;
                if (x > parent.width - width - dp(0))
                    x = parent.width - width - dp(0)

                panel.tickMarkLoader.x -= control.scrollbarSteps * (x - lastX)

                panel.grooveLoader.x -= control.scrollbarSteps * (x - lastX)

//                log("X = " + x)
                scrollbarPosChanged(x - lastX, x)
                lastX  = x;
            }
        }
    }

    property Component knob : Item {
        visible: control.value > 0
        implicitHeight: control.pressed || control.focus || control.alwaysShowValueLabel
                ? knobHeight : 0
        implicitWidth: control.pressed || control.focus || control.alwaysShowValueLabel
                ? knobWidth : 0

        Label {
            anchors {
                fill: parent
                topMargin: 4 * Units.dp
                bottomMargin: 4 * Units.dp
                leftMargin: 4 * Units.dp
                rightMargin: 4 * Units.dp
            }

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: knobLabel
            fontSizeMode: Text.Fit
            font.pixelSize: knobHeight - 19 * Units.dp
            minimumPixelSize: 6 * Units.dp
            wrapMode: Text.WordWrap
            color: Theme.lightDark(styleColor,
                                    Theme.light.textColor,
                                    Theme.dark.textColor)
            opacity: control.pressed || control.focus || control.alwaysShowValueLabel ? 1 : 0
            z: 1

            property color styleColor: control.hasOwnProperty("color")
                    ? control.color : Theme.light.accentColor

            Behavior on opacity {
                NumberAnimation { duration: 200}
            }
        }

        Rectangle {
            id: roundKnob
            implicitHeight: parent.height
            implicitWidth: parent.width
            radius: implicitWidth / 5
            color: control.color
            opacity: 0.8
            antialiasing: true
//            clip: true

            Rectangle {
                implicitHeight: parent.height / 4
                implicitWidth: parent.height / 4

                color: roundKnob.color
                antialiasing: true
                opacity: 0.8

                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: dp(20)
                anchors.horizontalCenterOffset: dp(4)

                transform: [
                    Rotation {
                        origin { x: parent.width / 2; y: parent.height / 2 }
                        angle: -45;
                    }
                ]
            }
        }

        Behavior on implicitHeight {
            NumberAnimation { duration: 200}
        }

        Behavior on implicitWidth {
            NumberAnimation { duration: 200}
        }
    }

    property Component handle: Item {
        anchors.centerIn: parent
        implicitHeight: 8 * Units.dp
        implicitWidth: 8 * Units.dp

        Loader {
            id: knobLoader
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: - parent.implicitWidth / 2
            anchors.bottom: parent.top
            anchors.bottomMargin: 9 * Units.dp
            sourceComponent: control.numericValueLabel ? knob : null
        }

        Rectangle {
            id: looker
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: - parent.implicitWidth / 2
            implicitHeight: 28 * Units.dp
            implicitWidth: 28 * Units.dp
            color: control.focus ?
                       Theme.alpha(control.color, 0.20) :
                       "transparent"
            radius: implicitHeight / 2
            opacity: 0.8

            Rectangle {
                property var diameter: control.enabled ? 10 * Units.dp : 8 * Units.dp
                anchors.centerIn: parent
                color: control.value === control.minimumValue ?
                           Theme.backgroundColor : control.color

                border.color: control.value === control.minimumValue
                              ? control.darkBackground ? Theme.alpha("#FFFFFF", 0.3)
                                                       : Theme.alpha("#000000", 0.26)
                              : control.color

                border.width: 2 * Units.dp

                implicitHeight: control.pressed && !control.focus && !control.numericValueLabel ?
                                    diameter + 8 * Units.dp :
                                    diameter

                implicitWidth: control.pressed && !control.focus && !control.numericValueLabel ?
                                   diameter + 8 * Units.dp :
                                   diameter

                radius: implicitWidth / 2

                Behavior on implicitHeight {
                    NumberAnimation { duration: 200}
                }

                Behavior on implicitWidth {
                    NumberAnimation { duration: 200}
                }
            }
        }
    }

    property Component groove: Rectangle {
        visible: true
        implicitWidth: 200
        implicitHeight: 2 * Units.dp

        width: control.maximumValue

        anchors.verticalCenter: parent.verticalCenter

        color: control.darkBackground ? Theme.alpha("#FFFFFF", 0.9)
                                    : Theme.alpha("#000000", 0.86)

        Rectangle {
            height: parent.height
            width: styleData.handlePosition
            implicitHeight: 2 * Units.dp
            implicitWidth: 200
            color: control.color
        }
    }

    property Component tickmarks: Repeater {
        id: repeater
        model: control.stepSize > 0 ? 1 + (control.maximumValue/* -  control.minimumValue*/) / control.stepSize : 0

        Rectangle {
            color: style.darkBackground ? "#FFFFFF" : "#000000"
            width: Math.round(1 * Units.dp);
            height: {
                if (index % 10 == 0)
                    return control.grooveBasiceHeight  *  11;
                else if (index % 5 == 0)
                    return control.grooveBasiceHeight  * 3;
                else
                    return control.grooveBasiceHeight * 1;
            }
            y: -height

            x: control.stepSize * index - width / 2//styleData.handleWidth / 2 + index * ((repeater.width - styleData.handleWidth) / (repeater.count-1))

            Text {
                text: index * stepSize / 4

                x: {
                    if (index  == 0)
                        return - contentWidth / 2 + dp(10);
                    else
                        return - contentWidth / 2 - dp(10);
                }
                y: contentWidth / 2 - dp(5)

                rotation: {
                    if (index  == 0)
                        return 0;
                    else
                        return -90;
                }

                visible: !(index % 10)
            }

            Text {
                color: Theme.accentColor
                text: index * stepSize / 1

                x: {
                    if (index  == 0)
                        return - contentWidth / 2 + dp(10);
                    else if ((!(index % 10) && (index != 0)) && repeater.count - 1 - index < 7)
                        return - contentWidth / 2 - dp(9) - contentHeight
                    else
                        return - contentWidth / 2 + dp(8);
                }
                y: contentWidth / 2 - dp(5)

                rotation: {
                    if (index  == 0)
                        return 0;
                    else
                        return -90;
                }

                visible: !(index % 10) && (index != 0)
            }
        }
    }


    Item {
        id: panel

        anchors.fill: parent

        anchors.margins: 0

        property int handleWidth: 0//handleLoader.width
        property int handleHeight: handleLoader.height

        property bool horizontal : true//control.orientation === Qt.Horizontal
        property int horizontalSize: grooveLoader.implicitWidth// + padding.left + padding.right
        property int verticalSize: Math.max(handleLoader.implicitHeight, grooveLoader.implicitHeight)// + padding.top + padding.bottom

        implicitWidth: horizontal ? horizontalSize : verticalSize
        implicitHeight: horizontal ? verticalSize : horizontalSize

        y: horizontal ? 0 : height
        rotation: horizontal ? 0 : -90
        transformOrigin: Item.TopLeft

        property alias grooveLoader: grooveLoader

        property alias tickMarkLoader: tickMarkLoader

        clip: true

        Loader {
            id: grooveLoader
            property QtObject styleData: QtObject {
                readonly property int handlePosition: handleLoader.x
            }
            x: 0
            sourceComponent: groove
            width: dp(900)//(panel.horizontal ? parent.width : parent.height) - (panel.handleWidth)// - padding.left - padding.right - (control.__panel.handleWidth)
            y:  parent.height - scrollbarLoader.height - dp(6)
        }

        Loader {
            id: tickMarkLoader
            x: 0//padding.left - control.minimumValue
            width: (panel.horizontal ? parent.width : parent.height)// (horizontal ? parent.width : parent.height) - padding.left - padding.right + control.minimumValue
            y:  grooveLoader.y
            sourceComponent: control.tickmarksEnabled ? tickmarks : null
            property QtObject styleData: QtObject { readonly property int handleWidth: panel.handleWidth }
        }

        Loader {
            id: handleLoader
            sourceComponent: handle
            anchors.verticalCenter: grooveLoader.verticalCenter
            x: control.value - control.minimumValue

//            Rectangle {
//                anchors.fill: parent
//                color: "transparent"
//                border.color: "red"
//            }

            Behavior on x {
                NumberAnimation { duration: 100 }
                enabled: control.tickmarksEnabled
            }


            onXChanged: {
                log("handle.x = " + x);
                log("handleLoader.x = " + handleLoader.x);
                log("handleLoader.width = " + handleLoader.width);
            }

            Component.onCompleted: {
                console.log(width)
            }
        }
    }

    Rectangle {
        x: 0

        width: 2 * Units.dp

        y: 0
        height: grooveLoader.y
        color: Theme.accentColor
    }

    Loader {
        id: scrollbarLoader
        sourceComponent: scrollbar
        anchors.bottom: panel.bottom
        width: panel.width
        x: 0

        Behavior on x {
            NumberAnimation { duration: 100 }
            enabled: control.tickmarksEnabled
        }
    }

}
