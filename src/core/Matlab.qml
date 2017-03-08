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

        var length = 1 + Math.round((Max - Min)/Step);

        var data = new Array(length)
        for (var i = 0; i < length; i++){
            data[i] = Min + i * Step;

            if (flags.fixed)
                data[i] = data[i].toFixed(flags.fixed);
        }

        var print = function _print() {
            if (!data)
                return;
            var says = "[ type: " + typeof data + " (Array: " + length + ") ] = \n";
            log(says + data);
        }

        var value = function _value(a, b) {
            return data[a][b];
        }

        if (flags.print){
            print();
        }

        return {
            data: data,
            length: data.length,
            print: print,
            value: value
        }
    }

    /*!
       产生指定行数列数的随机矩阵.

       \c Row: 行数.

       \c Col: 列数.

       \c Min: 最小.

       \c Max: 最大.

       \c userflags: 用户定义参数. 见 defaultFlags
     */
    function random(Rows, Cols, Min, Max, userflags){
        if (arguments.length < 4){
            log("Error using random (line 46) \nThere should be 4 arguments at least.");
            return NaN;
        }

        var defaultFlags = {
                    type: type_INT,     // 数值类型
                   fixed: 2,            // 浮点型的小数点位数
                   print: false         // 是否输出到控制台
        };
        var flags = (userflags) ? mergeFlags(defaultFlags, userflags) : defaultFlags;

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
            var says = "[ type: " + typeof this + " (Matrix: " + Rows + " x " + Cols + ") ] = \n";
            for (var k = 0; k < Rows; k++){
                says += data[k] + "\n"
            }
            log(says);
        }

        var value = function _value(a, b) {
            return data[a][b];
        }

        if (flags.print){
            print();
        }

        return {
            data: data,
            rows: Rows,
            cols: Cols,
            print: print,
            value: value
        }
    }

    function mergeFlags(defaults,userDefined) {
        var returnObj = {};
        for (var attrname in defaults) { returnObj[attrname] = defaults[attrname]; }
        for (var attrname1 in userDefined) { returnObj[attrname1] = userDefined[attrname1]; }
        return returnObj;
    }

    function log(says) {
        console.log("## Matlab ##: \n" + says)
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
