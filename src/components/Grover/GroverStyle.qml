/*
 * QML Material - An application framework implementing Material Design.
 *
 * Copyright (C) 2015-2016 Michael Spencer <sonrisesoftware@gmail.com>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import QtQuick 2.4
import QtQuick.Controls.Styles 1.3
import Material 0.3

SliderStyle {
    id: style

    property color color: control.hasOwnProperty("color")
            ? control.color : Theme.light.accentColor

    property bool darkBackground: control.hasOwnProperty("darkBackground")
            ? control.darkBackground : false

    property bool numericValueLabel: control.hasOwnProperty("numericValueLabel")
            ? control.numericValueLabel : false

    property bool alwaysShowValueLabel: control.hasOwnProperty("alwaysShowValueLabel")
            ? control.alwaysShowValueLabel : false

    property string knobLabel: control.hasOwnProperty("knobLabel")
            ? control.knobLabel : control.value

    property int knobWidth: control.hasOwnProperty("knobWidth")
                            ? control.knobWidth : 64 * Units.dp

    property int knobHeight: control.hasOwnProperty("knobHeight")
                            ? control.knobHeight : 32 * Units.dp

    property int grooveBasiceHeight: control.hasOwnProperty("grooveBasiceHeight")
                            ? control.grooveBasiceHeight : 5 * Units.dp

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
                bottomMargin: 2 * Units.dp
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
            radius: implicitWidth / 2
            color: style.color
            antialiasing: true
//            clip: true

            Rectangle {
                implicitHeight: parent.height / 2
                implicitWidth: parent.height / 2
                color: style.color
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: dp(12)
                anchors.horizontalCenterOffset: dp(-1)
                antialiasing: true

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

    groove: Rectangle {
        implicitWidth: 200
        implicitHeight: 2 * Units.dp

        anchors.verticalCenter: parent.verticalCenter

        color: style.darkBackground ? Theme.alpha("#FFFFFF", 0.9)
                                    : Theme.alpha("#000000", 0.86)

        Rectangle {
            height: parent.height
            width: styleData.handlePosition
            implicitHeight: 2 * Units.dp
            implicitWidth: 200
            color: style.color
        }
    }

    handle: Item {
        anchors.centerIn: parent
        implicitHeight: 8 * Units.dp
        implicitWidth: 8 * Units.dp

        Loader {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: 16 * Units.dp
            sourceComponent: style.numericValueLabel ? knob : null
        }

        Rectangle {
            anchors.centerIn: parent
            implicitHeight: 32 * Units.dp
            implicitWidth: 32 * Units.dp
            color: control.focus ?
                       Theme.alpha(style.color, 0.20) :
                       "transparent"
            radius: implicitHeight / 2
            Rectangle {
                property var diameter: control.enabled ? 16 * Units.dp : 12 * Units.dp
                anchors.centerIn: parent
                color: control.value === control.minimumValue ?
                           Theme.backgroundColor : style.color

                border.color: control.value === control.minimumValue
                              ? style.darkBackground ? Theme.alpha("#FFFFFF", 0.3)
                                                       : Theme.alpha("#000000", 0.26)
                              : style.color

                border.width: 2 * Units.dp

                implicitHeight: control.pressed && !control.focus && !style.numericValueLabel ?
                                    diameter + 8 * Units.dp :
                                    diameter

                implicitWidth: control.pressed && !control.focus && !style.numericValueLabel ?
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

    tickmarks: Repeater {
        id: repeater
        model: control.stepSize > 0 ? 1 + (control.maximumValue/* -  control.minimumValue*/) / control.stepSize : 0

        Rectangle {
            color: style.darkBackground ? "#FFFFFF" : "#000000"
            width: Math.round(1 * Units.dp);
            height: {
                if (index % 10 == 0)
                    return grooveBasiceHeight  *  8;
                else if (index % 5 == 0)
                    return grooveBasiceHeight  * 3;
                else
                    return grooveBasiceHeight * 1;
            }
            y: -height

            x: styleData.handleWidth / 2 + index * ((repeater.width - styleData.handleWidth) / (repeater.count-1))

            Text {
                text: index * stepSize / 4
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: {
                                                    if (index  == 0)
                                                        return dp(10);
                                                    else
                                                        return -dp(10);
                                                }

                anchors.top: parent.top
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
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: {
                                                    if (index  == 0)
                                                        return dp(10);
                                                    else
                                                        return dp(10);
                                                }

                anchors.top: parent.top
                rotation: {
                    if (index  == 0)
                        return 0;
                    else
                        return -90;
                }

                visible: !(index % 10)
            }
        }
    }

    panel: Item {
        id: root
        property int handleWidth: handleLoader.width
        property int handleHeight: handleLoader.height

        property bool horizontal : control.orientation === Qt.Horizontal
        property int horizontalSize: grooveLoader.implicitWidth + padding.left + padding.right
        property int verticalSize: Math.max(handleLoader.implicitHeight, grooveLoader.implicitHeight) + padding.top + padding.bottom

        implicitWidth: horizontal ? horizontalSize : verticalSize
        implicitHeight: horizontal ? verticalSize : horizontalSize

        y: horizontal ? 0 : height
        rotation: horizontal ? 0 : -90
        transformOrigin: Item.TopLeft

        Item {
            anchors.fill: parent
            clip: true

            Loader {
                id: grooveLoader
                property QtObject styleData: QtObject {
                    readonly property int handlePosition: handleLoader.x + handleLoader.width/2
                }
                x: padding.left + control.__panel.handleWidth / 2
                sourceComponent: groove
                width: (horizontal ? parent.width : parent.height) - padding.left - padding.right - (control.__panel.handleWidth)
                y:  Math.round(padding.top + (Math.round(horizontal ? parent.height : parent.width - padding.top - padding.bottom) - grooveLoader.item.height - control.__panel.handleHeight) / (style.numericValueLabel ? 1 : 2))
                        - dp (10)
            }

            Loader {
                id: tickMarkLoader
                x: padding.left - control.minimumValue
                width: (horizontal ? parent.width : parent.height) - padding.left - padding.right + control.minimumValue
                y:  grooveLoader.y
                sourceComponent: control.tickmarksEnabled ? tickmarks : null
                property QtObject styleData: QtObject { readonly property int handleWidth: control.__panel.handleWidth }
            }

            Loader {
                id: handleLoader
                sourceComponent: handle
                anchors.verticalCenter: grooveLoader.verticalCenter
                x: Math.round((control.__handlePos - control.minimumValue) / (control.maximumValue - control.minimumValue) * ((horizontal ? root.width : root.height) - item.width))

                Behavior on x {
                    NumberAnimation { duration: 100 }
                    enabled: control.tickmarksEnabled
                }
            }
        }
    }
}
