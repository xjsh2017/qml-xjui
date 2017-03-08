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
    property var calc_result

    /*!
   Select a color depending on whether the background is light or dark.

   \c input:  输入样本.

   \c out: 计算结果.

   \c sampleCount: 计算所需样本点数（向前取）.

   \c curSamplePos: 计算点.
 */
    function calcLatitudeAndPhase(input, sampleCount, curSamplePos) {
        var out = [NaN, NaN, NaN];
        if (!input || input.length < 8 || sampleCount < 8 || curSamplePos < sampleCount)
            return out

        //        console.log("Click value = " + input[curSamplePos])
        var tmp = 0.0;
        var ex = 0.0;
        var samplearr = [];
        for (var i = curSamplePos + 1 - sampleCount; i <= curSamplePos; i++){
            samplearr[i - curSamplePos - 1 + sampleCount] = input[i];
            tmp += (input[i] / 10000) * (input[i] / 10000);
            ex += input[i] / 10000;
        }
        //        console.log("sample(" + samplearr.length + "):" + samplearr);
        var dx = tmp/sampleCount * 10000 * 10000 - (ex / sampleCount * 10000) * (ex / sampleCount * 10000)
        //        console.log("dx = " + dx + ", ex = " + ex)
        out[0] = Math.sqrt(tmp/sampleCount) * 10000;
        out[1] = Math.sqrt(2) * out[0];
        if (dx > 0)
            out[2] = calcSinAngle(out[1], input[curSamplePos], input[curSamplePos] > input[curSamplePos - 1]);
        else
            out[2] = 0.0;

        //        console.log("fresult = " + out)

        return out;
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

    Component.onCompleted: {
//        try {
//            var code = 'import Material.Fonts 0.1; MaterialFontLoader {}'
//            Qt.createQmlObject(code, theme, "MaterialFontLoader")
//        } catch (error) {
//            // Ignore the error; it only means that the fonts were not enabled
//        }
    }
}
