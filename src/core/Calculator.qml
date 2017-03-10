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
   \qmltype XJElecCalculator
   \inqmlmodule XjUi

   \brief Provides access to standard colors that follow the Material Design specification.

   See \l {http://www.google.com/design/spec/style/color.html#color-ui-color-application} for
   details about choosing a color scheme for your application.
 */
QtObject {
    id: calculator

    /*!
      result for calc
      */
    property var fresult;

    /*!
   Select a color depending on whether the background is light or dark.

   \c input:  输入样本.

   \c out: 计算结果.

   \c sampleCount: 计算所需样本点数（向前取）.

   \c curSamplePos: 计算点.
 */
    function calcRMS(input, curSamplePos, count) {
//        if (typeof input[0] != "number"){
//            log("Error using calcRMS (line 46) \n The 1st argument must be number array type.");
//            return NaN;
//        }
        var fInput = input.map(parseFloat)

        if (arguments.length < 3){
            log("Error using calcRMS (line 46) \nThere should be 3 arguments at least.");
            return NaN;
        }

        if (!input || input.length < 8 || count < 8 || curSamplePos < count)
            return NaN;

        count = arguments[2] != undefined ? arguments[2] : 80;

        var RMS;
        var amplitude;
        var phase;

        var tmp = 0.0;
        var ex = 0.0;
        var dx;
        var samplearr = [];
        for (var i = curSamplePos + 1 - count; i <= curSamplePos; i++){
            samplearr[i - curSamplePos - 1 + count] = fInput[i];
            tmp += (fInput[i] / 1) * (fInput[i] / 1);
            ex += fInput[i] / 1;
        }
        ex = ex / count;

        var dx = Math.sqrt(tmp/count - ex * ex)
        RMS = Math.sqrt(tmp/count);
        amplitude = Math.sqrt(2) * RMS;
        if (dx > 0)
            phase = calcSinAngle(amplitude, fInput[curSamplePos], fInput[curSamplePos] > fInput[curSamplePos - 1]);
        else
            phase = 0.0;

        log ("calcRMS: "
             + "\n\t sample(" + samplearr.length + ") = " + samplearr
             + "\n\t dx = " + dx + ", ex = " + ex
             + "\n\t RMS = " + RMS
             + "\n\t amplitude = " + amplitude
             + "\n\t phase =" + phase
        )

        return {
            RMS: RMS,
            amplitude: amplitude,
            phase: phase
        };
    }

    /*!
   Returns true if the color is dark and should have light content on top
 */
    function calcSinAngle(R, value, updown) {
        var fresult = 0.0;

        if (R > 0.00001){
            if ( R < Math.abs(value) )
                return NaN;
            fresult = Math.asin(value/R)*180/Math.PI;
        }
        else
            return NaN

        if (fresult >= 0){
            if (!updown)
                fresult = 180 - fresult;
        }
        else
        {
            if (!updown)
                fresult = - 180 - fresult;
        }

        return fresult;
    }

    function log(says) {
//        console.log("## Calculator.qml ##: " + says);
    }

    // ///////////////////////////////////////////////////////////////

    Component.onCompleted: {
    }
}
