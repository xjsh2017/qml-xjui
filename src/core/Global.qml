pragma Singleton

import QtQuick 2.4

import Material 0.3

/*!
   \qmltype Global
   \inqmlmodule XjUi

   \brief Provides access to standard math function.

   See \l {http://www.google.com/design/spec/style/color.html#color-ui-color-application} for
   details about choosing a color scheme for your application.
 */

QtObject {
    id: global

    // ///////////////////////////////////////////////////////////////

    property   string enTimeMode: "time mode"           // 时间模式
    property   string enSampleMode: "sample mode"       // 采样点模式
    property     real g_DefaultSampleRate: 1
    property     real g_DefaultTimeRate: 4

    property   string g_plotMode: enSampleMode;         // 绘图模式： 0 - 时间模式、 1 - 采样点模式
    property     real g_timeRate: g_DefaultTimeRate;         // 单位时间间隔（1ms）等同4像素， 取整取浮点都可以。
    property     real g_sampleRate: g_DefaultSampleRate;       // 采样点间隔等同1个像素，  取整取浮点都可以。
    property    color g_sampleModeColor: Theme.accentColor
    property    color g_timeModeColor: "green"
    property    color g_modeColor: g_plotMode == enTimeMode ? g_timeModeColor : g_sampleModeColor

    property    color g_plotBackgroundColor: "#263238"

    // ///////////////////////////////////////////////////////////////

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
        Theme.primaryColor = "#00bcd4";
        Theme.accentColor = "#ff9800";
        Theme.tabHighlightColor = "white";
    }
}
