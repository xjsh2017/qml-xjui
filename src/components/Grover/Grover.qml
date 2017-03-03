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
import QtQuick.Controls 1.3 as Controls

/*!
   \qmltype Slider
   \inqmlmodule Material

   \brief Sliders let users select a value from a continuous or discrete range of
   values by moving the slider thumb.
 */
Controls.Slider {
    id: slider

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
    property string knobLabel: slider.value.toFixed(0)

    /*!
       The width of the value label knob
     */
    property int knobWidth: 64 * Units.dp

    /*!
       The height of the value label knob
     */
    property int knobHeight: 32 * Units.dp

    property color color: darkBackground ? Theme.dark.accentColor
                                         : Theme.light.accentColor

    tickmarksEnabled: false

    implicitHeight: numericValueLabel ? 54 * Units.dp : 32 * Units.dp
    implicitWidth: 200 * Units.dp

    // /////////////////////////////////////////////////////////////////

    function log(says) {
        console.log("## Grover.qml ##: " + says);
    }

    // /////////////////////////////////////////////////////////////////

    signal scrollbarPosChanged(var pos)

    Rectangle {
//        z: -1
        width: parent.width
        height: 10 * Units.dp

        radius: height / 2

        anchors.bottom: parent.bottom

        color: "transparent"

        border.color: "lightgrey"

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height - dp(2)

            radius: height / 2
            width: dp(52)

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
            }

            onXChanged: {
                if (x <  dp(1))
                    x =  dp(1);
                if (x > parent.width - width - dp(1))
                    x = parent.width - width - dp(1)

//                log("X = " + x)
                scrollbarPosChanged(x - lastX)
                lastX  = x;
            }
        }
    }

    style: GroverStyle {}
}
