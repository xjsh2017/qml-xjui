/*
 * QML Material - An application framework implementing Material Design.
 *
 * Copyright (C) 2014-2016 Michael Spencer <sonrisesoftware@gmail.com>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import QtQuick 2.4

pragma Singleton

/*!
   \qmltype Global
   \inqmlmodule XjUi

   \brief Provides access to standard math function.

   See \l {http://www.google.com/design/spec/style/color.html#color-ui-color-application} for
   details about choosing a color scheme for your application.
 */

QtObject {
    id: global

    function mergeFlags(defaults,userDefined) {
        var returnObj = {};
        for (var attrname in defaults) { returnObj[attrname] = defaults[attrname]; }
        for (var attrname1 in userDefined) { returnObj[attrname1] = userDefined[attrname1]; }
        return returnObj;
    }

    function randomColor() {
        return Qt.rgba(Math.random(),
                       Math.random(), Math.random(), 1);
    }

    function randomValue() {
        return Math.round(Math.random() * 100);
    }

    function phaseTypeColor(phaseType) {
        switch (phaseType) {
        case 'A':
            return "#ff9800";
            break;
        case 'B':
            return "#4caf50";

            break;
        case 'C':
            return "#ba68c8";
            break;
        case 'N':
            return "#607d8b";
            break;
        default:
            return "lightgrey"
        }
    }

    function log(says) {
        console.log("## Global.qml ##: \n" + says)
    }

    function dp(number) {
//        return Math.round(number * dp);
        return number;
    }

    Component.onCompleted: {
    }
}
