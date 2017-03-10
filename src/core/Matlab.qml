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

import "."
pragma Singleton

/*!
   \qmltype Matlab
   \inqmlmodule XjUi

   \brief Provides access to standard math function.

   See \l {http://www.google.com/design/spec/style/color.html#color-ui-color-application} for
   details about choosing a color scheme for your application.
 */

QtObject {
    id: matlab

    property string type_INT: "int"
    property string type_DOUBLE: "double"

    /*!
        产生指定步长的等距数列.

        \c Min: 最小.

        \c Step: 步长.

        \c Max: 最大.

        \c userflags: 用户定义参数. 见 defaultFlags

        \code
            var tmp = Matlab.serialize(0, 0.1, 1);
            tmp.print();
        \endcode
     */
    function serialize(Min, Step, Max, userflags) {
        if (arguments.length < 3){
            log("Error using random (line 46) \nThere should be 3 arguments at least.");
            return NaN;
        }

        var defaultFlags = {
                    type: type_INT,     // 数值类型
                   fixed: 2,            // 浮点型的小数点位数
                   print: false         // 是否输出到控制台
        };
        var flags = (userflags) ? mergeFlags(defaultFlags, userflags) : defaultFlags;

        Min = arguments[0] != undefined ? arguments[0] : 0;
        Step = arguments[1] != undefined ? arguments[1] : 0.1;
        Max = arguments[2] != undefined ? arguments[2] : 1;

        if (Max < Min){
            log("Error using serialize (line 61) \nThe argument Max must be not less than Min.")
            return NaN;
        }

        if (Step <= 0){
            log("Error using serialize (line 61) \nThe argument Step must be greater than 0.")
            return NaN;
        }
        if (Step > Max - Min){
            log("Error using serialize (line 61) \nThe argument Step must not be greater than Max - Min.")
            return NaN;
        }

        var Rows = 1;
        var Cols = 1 + Math.round((Max - Min)/Step);

        var data = new Array(Rows);
        for (var i = 0; i < Rows; i++){
            data[i] = new Array(Cols)
            for (var j = 0; j < Cols; j++){
                data[i][j] = Min + j * Step;

                if (flags.fixed)
                    data[i][j] = data[i][j].toFixed(flags.fixed);
            }
        }

        var print = function _print() {
            if (!data)
                return;
            var says = "\ntype: " + typeof this + " (Matrix: " + Rows + " x " + Cols + ")\ndata =\n";
            for (var k = 0; k < Rows; k++){
                says += "\t[" + k + "]: " + data[k] + "\n";
            }
            log(says);
        }

        var value = function _value(a, b) {
            return data[a][b];
        }

        if (flags.print){
            print();
        }

        var rows = Rows;
        var cols = Cols;

        var row = function _row(a, start, from) {
            if (!data || a > rows - 1 || a < 0)
                return NaN;

            start = arguments[1] ? arguments[1] : 0;
            from = arguments[2] ? arguments[2] : cols - 1;

            if (start < 0 || from < 0 || from < start || start > cols - 1)
                return NaN;

            from = Math.min(from, cols - 1)
            var tmp = new Array(from - start + 1);
            for (var i = start; i <= from; i++)
                tmp[i - start] = data[a][i];

            return tmp;
        }

        return {
            data: data,
            rows: Rows,
            cols: Cols,

            print: print,
            value: value,
            row: row
        }
    }

    /*!
        产生指定行数列数的随机矩阵.

        \c Row: 行数.

        \c Col: 列数.

        \c Min: 最小.

        \c Max: 最大.

        \c userflags: 用户定义参数. 见 defaultFlags

        \code
            var tmp = Matlab.random(2, 15, -100, 100, {type: Matlab.type_DOUBLE});
            tmp.print();
        \endcode
     */
    function random(Rows, Cols, Min, Max, userflags){
        if (arguments.length < 4){
            log("Error using random (line 46) \nThere should be 4 arguments at least.");
            return NaN;
        }

        var defaultFlags = {
                    type: type_DOUBLE,     // 数值类型
                   fixed: 2,            // 浮点型的小数点位数
                   print: false         // 是否输出到控制台
        };
        var flags = (userflags) ? Global.mergeFlags(defaultFlags, userflags) : defaultFlags;

        Min = arguments[2] != undefined ? arguments[2] : 0;
        Max = arguments[3] != undefined ? arguments[3] : 1;

        if (Max < Min){
            log("Error using random (line 61) \nThe Max argument must be not less than Min.")
            return NaN
        }

        var Range = Max - Min;

        var data = new Array(Rows)
        for (var i = 0; i < Rows; i++){
            data[i] = new Array(Cols);
            for (var j = 0; j < Cols; j++){
                if (Range > 0) {
                    var Rand = Math.random();
                    if (flags.type == type_INT)
                        data[i][j] = Min + Math.round(Rand * Range);
                    else
                        data[i][j] = Min + Rand * Range;
                }else{
                    data[i][j] = Min;
                }

                if (flags.fixed && flags.type != type_INT)
                    data[i][j] = data[i][j].toFixed(flags.fixed);
            }
        }

        var print = function _print() {
            if (!data)
                return;
            var says = "\ntype: " + typeof this + " (Matrix: " + Rows + " x " + Cols + ")\ndata =\n";
            for (var k = 0; k < Rows; k++){
                says += "\t[" + k + "]: " + data[k] + "\n";
            }
            log(says);
        }

        var value = function _value(a, b) {
            return data[a][b];
        }

        if (flags.print){
            print();
        }

        var rows = Rows;
        var cols = Cols;

        var row = function _row(a, start, from) {
            if (!data || a > rows - 1 || a < 0)
                return NaN;

            start = arguments[1] ? arguments[1] : 0;
            from = arguments[2] ? arguments[2] : cols - 1;

            if (start < 0 || from < 0 || from < start || start > cols - 1)
                return NaN;

            from = Math.min(from, cols - 1)
            var tmp = new Array(from - start + 1);
            for (var i = start; i <= from; i++)
                tmp[i - start] = data[a][i];

            return tmp;
        }

        return {
            data: data,
            rows: Rows,
            cols: Cols,

            print: print,
            value: value,
            row: row
        }
    }

    /*!
        产生指定行数列数的随机矩阵.

        \c Row: 行数.

        \c Col: 列数.

        \c Min: 最小.

        \c Max: 最大.

        \c userflags: 用户定义参数. 见 defaultFlags

        \code
            var tmp = Matlab.random(2, 15, -100, 100, {type: Matlab.type_DOUBLE});
            tmp.print();
        \endcode
     */
    function matrix(Rows, Cols, InitValue, userflags){
        if (arguments.length < 2){
            log("Error using matrix (line 46) \nThere should be 2 arguments at least.");
            return NaN;
        }

        var defaultFlags = {
                    type: type_DOUBLE,     // 数值类型
                   fixed: 2,            // 浮点型的小数点位数
                   print: false         // 是否输出到控制台
        };
        var flags = (userflags) ? Global.mergeFlags(defaultFlags, userflags) : defaultFlags;

        InitValue = arguments[2] ? arguments[2] : 0;

        var data = new Array(Rows)
        for (var i = 0; i < Rows; i++){
            data[i] = new Array(Cols);
            for (var j = 0; j < Cols; j++){
                data[i][j] = InitValue;

                if (flags.fixed && flags.type != type_INT)
                    data[i][j] = data[i][j].toFixed(flags.fixed);
            }
        }

        var print = function _print() {
            if (!data)
                return;
            var says = "\ntype: " + typeof this + " (Matrix: " + Rows + " x " + Cols + ")\ndata =\n";
            for (var k = 0; k < Rows; k++){
                says += "\t[" + k + "]: " + data[k] + "\n";
            }
            log(says);
        }

        var value = function _value(a, b) {
            return data[a][b];
        }

        if (flags.print){
            print();
        }

        var rows = Rows;
        var cols = Cols;

        var row = function _row(a, start, from) {
            if (!data || a > rows - 1 || a < 0)
                return NaN;

            start = arguments[1] ? arguments[1] : 0;
            from = arguments[2] ? arguments[2] : cols - 1;

            if (start < 0 || from < 0 || from < start || start > cols - 1)
                return NaN;

            from = Math.min(from, cols - 1)
            var tmp = new Array(from - start + 1);
            for (var i = start; i <= from; i++)
                tmp[i - start] = data[a][i];

            return tmp;
        }

        return {
            data: data,
            rows: Rows,
            cols: Cols,

            print: print,
            value: value,
            row: row
        }
    }


    /*! 产生正弦波形数据 */
    function sampleSin(Rows, Cols, xMin, xMax, yMin, yMax, nT, userflags){
        if (arguments.length < 2){
            log("Error using sampleSin (line 46) \nThere should be 4 arguments at least.");
            return NaN;
        }

        xMin = arguments[2] != undefined ? arguments[2] : 0;
        xMax = arguments[3] != undefined ? arguments[3] : Math.PI * 2;
        yMin = arguments[4] != undefined ? arguments[4] : -1;
        yMax = arguments[5] != undefined ? arguments[5] : 1;
        nT = arguments[6] != undefined ? arguments[6] : 1;

        if (xMax < xMin){
            log("Error using sampleSin (line 61) \nThe Max argument must be not less than Min.")
            return NaN
        }

        if (yMax < yMin){
            log("Error using sampleSin (line 61) \nThe Max argument must be not less than Min.")
            return NaN
        }

        var defaultFlags = {
                    type: type_DOUBLE,     // 数值类型
                   fixed: 2,            // 浮点型的小数点位数
                   print: false         // 是否输出到控制台
        };
        var flags = (userflags) ? Global.mergeFlags(defaultFlags, userflags) : defaultFlags;

        var xRange = xMax - xMin;
        var yRange = yMax - yMin;

        log("xRange type: " + (typeof xRange))

        var hopX = xRange / (Cols - 1);
        var offset = yMax - yRange / 2;
        var Tx = (xMax - xMin) / nT;

        log("hopX = " + hopX + ", offset = " + offset + ", Tx = " + Tx)

        var x = new Array(Cols);
        var data = new Array(Rows);
        var tmp = 0.0;
        for (var i = 0; i < Rows; i++){
            data[i] = new Array(Cols);
            var randFactor = Math.random(1);
            if (i == 0)
                randFactor = 1;
            for (var j = 0; j < Cols; j++){
                if (i == 0)
                    x[j] = parseFloat(xMin + (j) * hopX);
                tmp = yRange / 2 * Math.sin(x[j] / Tx * 2*Math.PI);
                tmp = tmp * randFactor;
                tmp += offset

                if (flags.fixed && flags.type != type_INT)
                    tmp = tmp.toFixed(flags.fixed);

                data[i][j] = parseFloat(tmp);
            }
        }

        log("data type: " + (typeof data))

        log("data[0][0] type: " + (typeof data[0][0]))

        var print = function _print() {
            var says = "\ntype: " + typeof this + " (Matrix: " + Rows + " x " + Cols + ")\n";
            if (x){
                says += "x =\n";
                for (var i = 0; i < 1; i++){
                    says += "\t[" + i + "]: " + x + "\n";
                }
            }

            if (data) {
                says += "data =\n";
                for (var k = 0; k < Rows; k++){
                    says += "\t[" + k + "]: " + data[k] + "\n";
                }
            }
            log(says);
        }

        var value = function _value(a, b) {
            return data[a][b];
        }

        if (flags.print){
            print();
        }

        var rows = Rows;
        var cols = Cols;

        var row = function _row(a, start, from) {
            if (!data || a > rows - 1 || a < 0)
                return NaN;

            start = arguments[1] ? arguments[1] : 0;
            from = arguments[2] ? arguments[2] : cols - 1;

            if (start < 0 || from < 0 || from < start || start > cols - 1)
                return NaN;

            from = Math.min(from, cols - 1)
            var tmp = new Array(from - start + 1);
            for (var i = start; i <= from; i++)
                tmp[i - start] = data[a][i];

            return tmp;
        }

        return {
            x: x,
            data: data,
            rows: Rows,
            cols: Cols,

            print: print,
            value: value,
            row: row
        }
    }


    function findBound(startTime, timeWidth, matrix) {
        var start = 0;
        for (var i = 0; i < matrix.cols; i++){
            if (startTime <= matrix.value(0, i)){
                start = i;
                break;
            }
        }
        console.assert(timeWidth > 0)

        var nexMaxEndTime = startTime + timeWidth;
        var end = -1;
        for (var j = start + 1; j < matrix.cols; j++){
            if (matrix.value(0, j) >= nexMaxEndTime){
                end = j - 1;
                break;
            }
        }
        if (-1 == end)
            end = matrix.cols - 1;

        return {
            start: start,
            end: end
        }
    }

    function log(says) {
        console.log("## Matlab.qml ##: \n" + says)
    }

    Component.onCompleted: {
    }
}
