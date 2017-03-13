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

import "../../core"

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
    property string knobLabel;

    /*!
       The width of the value label knob
     */
    property int knobWidth: 64 * Units.dp

    /*!
       The height of the value label knob
     */
    property int knobHeight: 32 * Units.dp

    property int grooveBottomGap: dp(7)

    property int moveRate: 5;

    property alias panel: panel

    property real valueRange: maximumValue - minimumValue

    property real scrollbarSteps: 4;


    property int grooveBasiceHeight: 5 * Units.dp//control.hasOwnProperty("grooveBasiceHeight")
//                            ? control.grooveBasiceHeight : 5 * Units.dp


    property color color: darkBackground ? Theme.dark.accentColor
                                         : Theme.light.accentColor

    property bool tickmarksEnabled: false

    property real value
    property real minimumValue
    property real maximumValue

    property      int samplecount: 1;
    property   string plotMode: Global.g_plotMode;                      // 绘图模式： 0 - 时间模式、 1 - 采样点模式
    property     real timeRate: Global.g_timeRate;                      // 1ms间隔等同4像素， 取整取浮点都可以。
    property     real timeWidth: (width - 58) / timeRate;               // 单位： ms
    property     real sampleRate: Global.g_sampleRate;                  // 采样点间隔等同2个像素，  取整取浮点都可以。
    property     real sampleWidth: (width - 58) / sampleRate;           // 单位： 个数c

    property real ratedWith:  (samplecount - 1) * sampleRate;

    property int stepSize: 10 * sampleRate

    property bool activeFocusOnPress: true

    implicitHeight: numericValueLabel ? 54 * Units.dp : 32 * Units.dp
    implicitWidth: 200 * Units.dp

    // /////////////////////////////////////////////////////////////////

    function log(says) {
//        console.log("## Groove.qml ##: " + says);
    }

    // /////////////////////////////////////////////////////////////////

    signal scrollbarPosChanged(var xLastPos, var xPos
                               , var deltaX, var delta, var velocity)
    signal leftMoveClicked();
    signal rightMoveClicked();



    property Component scrollbar: Rectangle {
        width: parent.width
        height: 14 * Units.dp

        visible: handleScroll.width > 0 && handleScroll.width < width

        radius: height / 2

        anchors.bottom: parent.bottom

        color: "transparent"

        border.color: "lightgrey"

        // delta 为移动的像素长度
        function move(delta) {
            var tmp = delta / handleScroll.velocity
            tmp = handleScroll.x + tmp
            if (tmp >= 0)
                handleScroll.x = tmp
            else
                handleScroll.x = 0;
        }

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
                if (tmp >= 0){
                    handleScroll.lastX = handleScroll.x;
                    handleScroll.x = tmp
                }
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
//            width: control.valueRange - (waveModel.cols() - control.valueRange) / control.scrollbarSteps
            width: Math.max(parent.width * parent.width / (control.ratedWith * control.sampleRate), implicitWidth)
            implicitWidth: dp(50)

            property real velocity: (control.ratedWith - parent.width) / (parent.width - width)

            color: "#9e9e9e"//Theme.accentColor
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
                if (x <  dp(0))
                    x =  0;
                if (x > parent.width - width - dp(0))
                    x = parent.width - width - dp(0)

                console.log("onXChanged: x = " + x + ", lastX = " + lastX)

                var deltaX = x - lastX;

                var delta = velocity * deltaX;
                panel.tickMarkLoader.x -= delta;
                panel.grooveLoader.x -= delta;

                scrollbarPosChanged(lastX, x, deltaX, delta, velocity);
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
                centerIn: parent
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
            color: Global.g_modeColor//control.color
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
                anchors.bottomMargin: -height / 2
                rotation: 45;
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

        Rectangle {
            visible: false
            anchors.fill: parent
            color: "transparent"
            border.color: "red"
        }

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
                       Theme.alpha(Global.g_modeColor, 0.20) :
                       "transparent"
            radius: implicitHeight / 2
            opacity: 0.8

            Rectangle {
                property var diameter: control.enabled ? 10 * Units.dp : 8 * Units.dp
                anchors.centerIn: parent
                color: control.value === control.minimumValue ?
                           Theme.backgroundColor : Global.g_modeColor

                border.color: control.value === control.minimumValue
                              ? control.darkBackground ? Theme.alpha("#FFFFFF", 0.3)
                                                       : Theme.alpha("#000000", 0.26)
                              : Global.g_modeColor

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

        width: control.ratedWith

        anchors.verticalCenter: parent.verticalCenter

        color: control.darkBackground ? Theme.alpha("#FFFFFF", 0.9)
                                    : Theme.alpha("#000000", 0.86)

        Rectangle {
            height: parent.height
            width: styleData.handlePosition
            implicitHeight: 2 * Units.dp
            implicitWidth: 200
            color: Global.g_modeColor
        }
    }

    property Component tickmarks: Repeater {
        id: repeater

//        model: control.stepSize > 0 ? 1 + (control.maximumValue/* -  control.minimumValue*/) / control.stepSize : 0
        model: control.ratedWith / control.stepSize;

        Rectangle {
            color: control.darkBackground ? "#FFFFFF" : "#000000"
            width: Math.round(1 * Units.dp);
            height: {
                if (index % 10 == 0)
                    return control.grooveBasiceHeight  *  8;
                else if (index % 5 == 0)
                    return control.grooveBasiceHeight  * 3;
                else
                    return control.grooveBasiceHeight * 1;
            }
            y: -height

            x: control.stepSize * index - width / 2//styleData.handleWidth / 2 + index * ((repeater.width - styleData.handleWidth) / (repeater.count-1))

            Text { // 毫秒
                text: index * stepSize / 4 + " ms"

                color: Global.g_timeModeColor

                x: {
                    return 0 + dp(6);
//                    if (index  == 0)
//                        return - contentWidth / 2 + dp(10);
//                    else
//                        return - contentWidth / 2 - dp(10);
                }
                y: 0//contentWidth / 2 - dp(5)

//                rotation: {
//                    if (index  == 0)
//                        return 0;
//                    else
//                        return -90;
//                }

                visible: !(index % 10) && control.plotMode == Global.enTimeMode
            }

            Text {
                color: Global.g_sampleModeColor
                text: (index * stepSize) / sampleRate

                x: {
                    if (index  == 0)
                        return - contentWidth / 2 + dp(10);
                    else if ((!(index % 10) && (index != 0)) && repeater.count - 1 - index < 7)
                        return - contentWidth / 2 - dp(9) - contentHeight
                    else
                        return - contentWidth / 2 - dp(8);

//                    if (index  == 0)
//                        return - contentWidth / 2 + dp(10);
//                    else if ((!(index % 10) && (index != 0)) && repeater.count - 1 - index < 7)
//                        return - contentWidth / 2 - dp(9) - contentHeight
//                    else
//                        return - contentWidth / 2 + dp(8);
                }
                y: contentWidth / 2 - dp(5)

                rotation: {
                    if (index  == 0)
                        return 0;
                    else
                        return -90;
                }

                visible: !(index % 10)/* && (index != 0)*/ && control.plotMode == Global.enSampleMode
            }
        }
    }


    property alias scroller: scrollbarLoader.item

    Item {
        id: panel

        anchors.fill: parent

        anchors.margins: 0
        anchors.leftMargin: dp(2)

        property int handleWidth: dp(0)
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
            sourceComponent: groove
            y:  parent.height - grooveBottomGap// - (scrollbarLoader.item.visible ? scrollbarLoader.item.height : 0)
        }

        Loader {
            id: tickMarkLoader
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

            Behavior on x {
                NumberAnimation { duration: 100 }
                enabled: control.tickmarksEnabled
            }
        }
    }

    Rectangle {
        width: 2 * Units.dp

        y: scrollbarLoader.height
        z: -1
        height: parent.height
        color: Global.g_modeColor
    }

    Loader {
        id: scrollbarLoader
        sourceComponent: scrollbar
        anchors.top: panel.top
        width: panel.width
        z: -1

        Behavior on x {
            NumberAnimation { duration: 100 }
            enabled: control.tickmarksEnabled
        }
    }

}
