// QChart.js ---
//
// Author: Julien Wintz
// Created: Thu Feb 13 14:37:26 2014 (+0100)
// Version:
// Last-Updated:
//           By:
//     Update #: 94
//

// Change Log:
//
//

var ChartType = {
         BAR: 1,
    DOUGHNUT: 2,
        LINE: 3,
         PIE: 4,
       POLAR: 5,
       RADAR: 6
};

var Chart = function(canvas, context) {

    function log(says) {
//        console.log("## QChart.js ##: " + says)
    }

    var chart = this;

// /////////////////////////////////////////////////////////////////
// Line helper
// /////////////////////////////////////////////////////////////////

    this.Line = function(data,options) {

        chart.Line.defaults = { // 默认图表参数
            scaleOverlay: false,
            scaleOverride: false,
            scaleSteps: null,
            scaleStepWidth: null,
            scaleStartValue: null,
            scaleLineColor: "rgba(0,0,0,.1)",
            scaleLineWidth: 1,
            scaleShowLabels: true,			// 显示坐标数据
            scaleLabel: "<%=value%>",
            scaleFontFamily: "'Arial'",
            scaleFontSize: 12,
            scaleFontStyle: "normal",
            scaleFontColor: "#666",
            scaleShowGridLines: true,       // 是否显示网格线
            scaleGridLineColor: "grey", //"rgba(0,0,0,.05)",
            scaleGridLineWidth: 1,
            bezierCurve: true,
            pointDot: true,					// 显示点
            pointDotRadius: 2,
            pointDotStrokeWidth: 1,
            datasetStroke: true,
            datasetStrokeWidth: 1,          // 线条粗细
            datasetFill: true,
            animation: true,
            animationSteps: 60,
            animationEasing: "easeOutQuart",
            onAnimationComplete: null,

            scaleShowLabelsX: true,         // 显示横坐标数值 X
            scaleShowLabelsY: true,         // 显示纵坐标数值 Y
            scaleFontColorY: "#ff9800",         // 显示纵坐标 Y
            scaleFontColorX: "#00bcd4",         // 显示纵坐标 Y
            scaleShowAxisX: true,
            scaleShowAxisY: true,
            scaleShowOutline: true,
            scaleYAxisLineColor: "#00bcd4",
            scaleYAxisLineWidth: 1,
            scaleXAxisLineColor: "#00bcd4",
            scaleXAxisLineWidth: 1,
            scaleXAxisLineStyle: 1,     // 0 - 实线， 1 - 虚线
            scaleOutlineColor: "#00bcd4",         // 显示纵坐标 Y
            scaleOutlineWidth: 1,

            fixedLenLabelsY: dp(32),
            scaleAxisLabelGap: dp(8),
            scaleAnchors:  {
                leftMargin: dp(5),
                rightMargin: dp(0),
                topMargin: dp(0),
                bottomMargin: dp(0)
            }
        };

        var config = (options) ? mergeChartConfig(chart.Line.defaults,options) : chart.Line.defaults;

        return new Line(data,config,context);
    }

// /////////////////////////////////////////////////////////////////
// Line implementation
// /////////////////////////////////////////////////////////////////

    var Line = function(data,config,ctx) {

        var widestXLabel;       // 横坐标取值的最大内容长度
        var labelTemplateString;

        var calculatedScale;    // 纵坐标刻度相关取值: 步数，步长，刻度取值
        var labelFontHeight;        // 坐标值的字体高度
        var valueBounds;        // 纵坐标的实际采样取值范围，不是绘图刻度范围
        var valueHopX;          // 横坐标刻度间的像素长度
        var valueHopY;          // 纵坐标刻度间的像素长度 = scaleHop

        var rotateLabels = 0;

        var xLabelMaxheight = 0;
        var xLabelMaxWidth = 0;

        var scaleVertex;

        // /////////////////////////////////////////////////////////////////
        // initialisation
        // /////////////////////////////////////////////////////////////////

        this.init = function () {

            calculateYAxisSize();

            valueBounds = getValueBounds();

            labelTemplateString = (config.scaleShowLabels)? config.scaleLabel : "";

            if (!config.scaleOverride) {
                calculatedScale = calculateScale(valueBounds.maxSteps,valueBounds.minSteps
                                                 ,valueBounds.maxValue,valueBounds.minValue,labelTemplateString);
            } else {
                calculatedScale = {
                    steps: config.scaleSteps,
                    stepValue: config.scaleStepWidth,
                    graphMin: config.scaleStartValue,
                    labels: []
                }
                populateLabels(labelTemplateString, calculatedScale.labels,calculatedScale.steps,config.scaleStartValue,config.scaleStepWidth);
            }

            calculateXAxisSize();
        }

        // /////////////////////////////////////////////////////////////////
        // drawing
        // /////////////////////////////////////////////////////////////////

        this.draw = function (progress, drawOptions) {

            this.init();

            clear(ctx);

            config = (drawOptions) ? mergeChartConfig(config,drawOptions) : config;

            if(config.scaleOverlay) {
                drawLines(progress);
                drawScale();
            } else {
                drawScale();
                drawLines(progress);
            }
        }

        // ///////////////////////////////////////////////////////////////

        function drawLines(animPc) {

            var posx = scaleVertex.leftBottom.x
            var posy = scaleVertex.leftBottom.y
            for (var i=0; i<data.datasets.length; i++) {
                ctx.strokeStyle = data.datasets[i].strokeColor;
                ctx.lineWidth = config.datasetStrokeWidth;
                ctx.beginPath();
                ctx.moveTo(posx, posy - animPc*(calculateOffset(data.datasets[i].data[0],calculatedScale, valueHopY)))

                for (var j=1; j<data.datasets[i].data.length; j++) {
                    if (config.bezierCurve) {
                        ctx.bezierCurveTo(xPos(j-0.5),yPos(i,j-1),xPos(j-0.5),yPos(i,j),xPos(j),yPos(i,j));
                    } else{
                        ctx.lineTo(xPos(j),yPos(i,j));
                    }
                }

                ctx.stroke();

                if (config.datasetFill) {
                    ctx.lineTo(posx + (valueHopX*(data.datasets[i].data.length-1)),posy);
                    ctx.lineTo(posx,posy);
                    ctx.closePath();
                    ctx.fillStyle = data.datasets[i].fillColor;
                    ctx.fill();
                } else {
                    ctx.closePath();
                }


                if (config.pointDot) {
                    ctx.fillStyle = data.datasets[i].pointColor;
                    ctx.strokeStyle = data.datasets[i].pointStrokeColor;
                    ctx.lineWidth = config.pointDotStrokeWidth;
                    for (var k=0; k<data.datasets[i].data.length; k++) {
                        ctx.beginPath();
                        ctx.arc(posx + (valueHopX *k),posy - animPc*(calculateOffset(data.datasets[i].data[k],calculatedScale, valueHopY)),config.pointDotRadius,0,Math.PI*2,true);
                        ctx.fill();
                        ctx.stroke();
                    }
                }
            }

            function yPos(dataSet,iteration) {
                return posy - animPc*(calculateOffset(data.datasets[dataSet].data[iteration],calculatedScale, valueHopY));
            }

            function xPos(iteration) {
                return posx + (valueHopX * iteration);
            }
        }

        function drawScale() {

            var outlen = 0;

            // 绘制图形区域
            if (config.scaleShowOutline) {
                ctx.lineWidth = config.scaleOutlineWidth;
                ctx.strokeStyle = config.scaleOutlineColor;
                ctx.beginPath();
                ctx.moveTo(scaleVertex.leftTop.x, scaleVertex.leftTop.y);
                ctx.lineTo(scaleVertex.leftBottom.x, scaleVertex.leftBottom.y);
                ctx.lineTo(scaleVertex.rightBottom.x, scaleVertex.rightBottom.y);
                ctx.lineTo(scaleVertex.rightTop.x, scaleVertex.rightTop.y);
                ctx.lineTo(scaleVertex.leftTop.x, scaleVertex.leftTop.y);

                ctx.stroke();
            }

            // 绘制横坐标
            if (config.scaleShowAxisX) {
                var idx_xAxis = 0;
                for (var i=0; i < calculatedScale.labels.length; i++){
                    if (calculatedScale.labels[i] == "0"){
                        idx_xAxis = i;
                        break;
                    }
                }

                ctx.lineWidth = config.scaleXAxisLineWidth;
                ctx.strokeStyle = config.scaleXAxisLineColor;

                if (config.scaleXAxisLineStyle == 1){
                    drawDashLine(ctx, scaleVertex.leftBottom.x, scaleVertex.leftBottom.y  - idx_xAxis *valueHopY,
                                 scaleVertex.rightBottom.x, scaleVertex.rightBottom.y - idx_xAxis *valueHopY, dp(2))
                }else{
                    ctx.beginPath();
                    ctx.moveTo(scaleVertex.leftBottom.x, scaleVertex.leftBottom.y  - idx_xAxis *valueHopY);
                    ctx.lineTo(scaleVertex.rightBottom.x, scaleVertex.rightBottom.y - idx_xAxis *valueHopY);
                    ctx.stroke();
                }



            }

            // 绘制纵坐标
            if (config.scaleShowAxisY) {
                ctx.lineWidth = config.scaleYAxisLineWidth;
                ctx.strokeStyle = config.scaleYAxisLineColor;
                ctx.beginPath();
                ctx.moveTo(scaleVertex.leftTop.x, scaleVertex.leftTop.y);
                ctx.lineTo(scaleVertex.leftBottom.x, scaleVertex.leftBottom.y);
                ctx.stroke();
            }

            ctx.lineWidth = config.scaleLineWidth;
            ctx.strokeStyle = config.scaleLineColor;
            ctx.fillStyle = config.scaleFontColor;

            if (rotateLabels > 0) {
                ctx.save();
                ctx.textAlign = "right";
            } else{
                ctx.textAlign = "center";
            }

            var posx = 0;
            var posy = 0;
            for (var i=0; i<data.labels.length; i++) {
                posx = scaleVertex.leftBottom.x + i * valueHopX;

                // 绘制横坐标的刻度数值
                if (config.scaleShowLabels && config.scaleShowLabelsX) {
                    if (config.scaleFontColorX)
                        ctx.fillStyle = config.scaleFontColorX;

                    if (rotateLabels > 0) {
                        ctx.save();
                        ctx.translate(posx, scaleVertex.leftBottom.y + labelFontHeight);
                        ctx.rotate(-(rotateLabels * (Math.PI/180)));
                        ctx.fillText(data.labels[i], 0,0);
                        ctx.restore();
                    } else {
                        ctx.fillText(data.labels[i], posx, scaleVertex.leftBottom.y + labelFontHeight + config.scaleAxisLabelGap / 2);
                    }
                }

                // 绘制纵向网格线
                if (config.scaleShowGridLines) {
                    ctx.beginPath();
                    ctx.moveTo(posx, scaleVertex.leftBottom.y + outlen);
                    ctx.lineWidth = config.scaleGridLineWidth;
                    ctx.strokeStyle = config.scaleGridLineColor;

                    if (i == 0 || i == data.labels.length - 1)
                        continue;

                    ctx.lineTo(posx, scaleVertex.leftTop.y - outlen);
                    ctx.stroke();
                }
            }

            // 横向网格线，不包括横坐标，并绘制纵坐标刻度数值
            ctx.lineWidth = config.scaleLineWidth;
            ctx.strokeStyle = config.scaleLineColor;
            ctx.textAlign = "right";
            ctx.textBaseline = "middle";

            log("calculatedScale.labels = " + calculatedScale.labels)
            for (var j = 0; j < calculatedScale.steps + 1; j++) {
                posy = scaleVertex.leftBottom.y - j*valueHopY;

                if (posy < labelFontHeight / 2)
                    posy += labelFontHeight / 2 + 3
                else if (height - posy < labelFontHeight / 2)
                    posy -= labelFontHeight / 2
                // 绘制纵坐标的刻度数值
                if (config.scaleShowLabels && config.scaleShowLabelsY) {
                    if (config.scaleFontColorY)
                        ctx.fillStyle = config.scaleFontColorY
                    ctx.fillText(calculatedScale.labels[j], scaleVertex.leftBottom.x - config.scaleAxisLabelGap, posy);
                }

                // 绘制横向网格线
                if (config.scaleShowGridLines) {
                    ctx.beginPath();
                    ctx.moveTo(scaleVertex.leftBottom.x - outlen, posy);
                    ctx.lineWidth = config.scaleGridLineWidth;
                    ctx.strokeStyle = config.scaleGridLineColor;

                    if (j == 0 || j == calculatedScale.steps)
                        continue;
                    ctx.lineTo(scaleVertex.rightBottom.x + outlen, posy);

                    ctx.stroke();

                }
            }
        }

        function calculateYAxisSize() { // widestXLabel, xLabelMaxheight, xLabelMaxWidth

            log("Canvas: height = " + height + ", width = " + width)

            ctx.font = config.scaleFontStyle + " " + config.scaleFontSize+"px " + config.scaleFontFamily;
            log("ctx.font = " + ctx.font)

            labelFontHeight = config.scaleFontSize;
            if (config.scaleShowLabels && config.scaleShowLabelsX){
                widestXLabel = 1;   // 横坐标数值中最长的像素
                for (var i=0; i<data.labels.length; i++) {
                    var textLength = ctx.measureText(data.labels[i]).width;
                    widestXLabel = (textLength > widestXLabel)? textLength : widestXLabel;
                }
                log("widestXLabel = " + widestXLabel)

                xLabelMaxheight = labelFontHeight;
                xLabelMaxWidth = widestXLabel;

                if (width/data.labels.length < widestXLabel) {
                    rotateLabels = 45;

                    xLabelMaxWidth = Math.cos(rotateLabels) * widestXLabel;
                    xLabelMaxheight = Math.sin(rotateLabels) * widestXLabel;

                    if (width/data.labels.length < Math.cos(rotateLabels) * widestXLabel) {
                        rotateLabels = 90;
                        xLabelMaxheight = widestXLabel;
                        xLabelMaxWidth = labelFontHeight;
                    }
                }
                log("xLabelMaxheight = " + xLabelMaxheight + ", xLabelMaxWidth = " + xLabelMaxWidth)
            }
        }

        function getValueBounds() { // 获取 data.datasets 最大最小值，即纵坐标的范围

            var upperValue = Number.MIN_VALUE;
            var lowerValue = Number.MAX_VALUE;

            for (var i=0; i<data.datasets.length; i++) {
                for (var j=0; j<data.datasets[i].data.length; j++) {
                    if ( data.datasets[i].data[j] > upperValue) { upperValue = data.datasets[i].data[j] };
                    if ( data.datasets[i].data[j] < lowerValue) { lowerValue = data.datasets[i].data[j] };
                }
            };
            log("upperValue = " + upperValue + ", lowerValue = " + lowerValue)

            var yLen = height - config.scaleAnchors.bottomMargin - config.scaleAnchors.topMargin - xLabelMaxheight;
            var maxSteps = Math.floor((yLen / (labelFontHeight*0.66)));
            var minSteps = Math.floor((yLen / labelFontHeight*0.5));
            log("maxSteps = " + maxSteps + ", minSteps = " + minSteps)

            return {
                maxValue: upperValue,
                minValue: lowerValue,
                maxSteps: maxSteps,
                minSteps: minSteps
            };
        }

        function calculateXAxisSize() {
            ctx.font = config.scaleFontStyle + " " + config.scaleFontSize+"px " + config.scaleFontFamily;

            var longestTextY = 1;    // 纵坐标刻度数值最长的像素
            if (config.scaleShowLabels && config.scaleShowLabelsY) {
                for (var i=0; i<calculatedScale.labels.length; i++) {
                    var measuredText = ctx.measureText(calculatedScale.labels[i]).width;
                    longestTextY = (measuredText > longestTextY)? measuredText : longestTextY;
                }
            }
            log("Calc longestTextY = " + longestTextY)
            if (config.fixedLenLabelsY)
                longestTextY = Math.max(longestTextY, config.fixedLenLabelsY);

            var NY = ((config.scaleShowLabels && config.scaleShowLabelsY) ? 1 : 0);
            var NX = ((config.scaleShowLabels && config.scaleShowLabelsX) ? 1 : 0);
            scaleVertex = {
                leftTop:        { x: config.scaleAnchors.leftMargin + NY* (longestTextY + config.scaleAxisLabelGap)
                                , y: config.scaleAnchors.topMargin},

                rightTop:       { x: width - config.scaleAnchors.rightMargin
                                , y: config.scaleAnchors.topMargin},

                leftBottom:     { x: config.scaleAnchors.leftMargin + NY* (longestTextY + config.scaleAxisLabelGap)
                                , y: height - config.scaleAnchors.bottomMargin - NX* (xLabelMaxheight + config.scaleAxisLabelGap)},

                rightBottom:    { x: width - config.scaleAnchors.rightMargin
                                , y: height - config.scaleAnchors.bottomMargin - NX* (xLabelMaxheight - config.scaleAxisLabelGap)},

                width:          width - config.scaleAnchors.rightMargin - config.scaleAnchors.leftMargin - NY*(longestTextY  + config.scaleAxisLabelGap),
                height:         height - config.scaleAnchors.bottomMargin - config.scaleAnchors.topMargin - NX*(xLabelMaxheight + config.scaleAxisLabelGap)
            }
            log("scaleVertex.height = " + scaleVertex.height)

//            valueHopY = Math.floor(scaleVertex.height / calculatedScale.steps);
            valueHopY = scaleVertex.height / calculatedScale.steps;
            log("valueHopY = " + valueHopY)
//            valueHopX = Math.floor(xAxisLength/(data.labels.length-1));
            valueHopX = scaleVertex.width /(data.labels.length - 1);
            log("valueHopX = " + valueHopX)

            canvas.chartScaleLeftTop = Qt.point(scaleVertex.leftTop.x, scaleVertex.leftTop.y)
            canvas.chartScaleRightBottom = Qt.point(scaleVertex.rightBottom.x, scaleVertex.rightBottom.y)
            canvas.chartDisplayPointCount = scaleVertex.width
        }
    }


// /////////////////////////////////////////////////////////////////
// Helper functions
// /////////////////////////////////////////////////////////////////

    var clear = function(c) {
        c.clearRect(0, 0, width, height);
    };


    function calculateOffset(val,calculatedScale,scaleHop) {

        var outerValue = calculatedScale.steps * calculatedScale.stepValue;
        var adjustedValue = val - calculatedScale.graphMin;
        var scalingFactor = CapValue(adjustedValue/outerValue,1,0);

        return (scaleHop*calculatedScale.steps) * scalingFactor;
    }

    function calculateOrderOfMagnitude(val) {
        return Math.floor(Math.log(val) / Math.LN10);
    }

    /* 计算纵坐标的刻度值 */
    function calculateScale(maxSteps,minSteps,maxValue,minValue,labelTemplateString) {

        var graphMin,graphMax,graphRange,stepValue,numberOfSteps,valueRange,rangeOrderOfMagnitude,decimalNum;

        valueRange = maxValue - minValue;
        rangeOrderOfMagnitude = calculateOrderOfMagnitude(valueRange);

        graphMin = Math.floor(minValue / (1 * Math.pow(10, rangeOrderOfMagnitude))) * Math.pow(10, rangeOrderOfMagnitude);
        graphMax = Math.ceil(maxValue / (1 * Math.pow(10, rangeOrderOfMagnitude))) * Math.pow(10, rangeOrderOfMagnitude);
        log("graphMax = " + graphMax + ", graphMin = " + graphMin)

        graphRange = graphMax - graphMin;
        stepValue = Math.pow(10, rangeOrderOfMagnitude);
        numberOfSteps = Math.round(graphRange / stepValue);
        log("stepValue = " + stepValue + ", numberOfSteps = " + numberOfSteps)

//        while(numberOfSteps < minSteps || numberOfSteps > maxSteps) {
//            if (numberOfSteps < minSteps) {
//                stepValue /= 2;
//                numberOfSteps = Math.round(graphRange/stepValue);
//            } else{
//                stepValue *=2;
//                numberOfSteps = Math.round(graphRange/stepValue);
//            }
//        };
//        log("== stepValue = " + stepValue + ", numberOfSteps = " + numberOfSteps)

        var labels = [];

        populateLabels(labelTemplateString, labels, numberOfSteps, graphMin, stepValue);
        log("labels = " + labels)

        return {
            steps: numberOfSteps,   // 步数
            stepValue: stepValue,   // 步长
            graphMin: graphMin,     // 最小刻度值
            labels: labels          // 每步刻度值，从小到大
        }
    }

    function populateLabels(labelTemplateString, labels, numberOfSteps, graphMin, stepValue) {
        if (labelTemplateString) {
            for (var i = 0; i < numberOfSteps + 1; i++) {
                labels.push(tmpl(labelTemplateString, {value: (graphMin + (stepValue * i)).toFixed(getDecimalPlaces(stepValue))}));
            }
        }
    }

    function Max(array) {
        return Math.max.apply(Math, array);
    };

    function Min(array) {
        return Math.min.apply(Math, array);
    };

    function Default(userDeclared,valueIfFalse) {
        if(!userDeclared) {
            return valueIfFalse;
        } else {
            return userDeclared;
        }
    };

    function isNumber(n) {
        return !isNaN(parseFloat(n)) && isFinite(n);
    }

    function CapValue(valueToCap, maxValue, minValue) {
        if(isNumber(maxValue)) {
            if( valueToCap > maxValue ) {
                return maxValue;
            }
        }
        if(isNumber(minValue)) {
            if ( valueToCap < minValue ) {
                return minValue;
            }
        }
        return valueToCap;
    }

    function getDecimalPlaces (num) {
        var numberOfDecimalPlaces;
        if (num%1!=0) {
            return num.toString().split(".")[1].length
        } else {
            return 0;
        }
    }

    function mergeChartConfig(defaults,userDefined) {
        var returnObj = {};
        for (var attrname in defaults) { returnObj[attrname] = defaults[attrname]; }
        for (var attrname in userDefined) { returnObj[attrname] = userDefined[attrname]; }
        return returnObj;
    }

    var cache = {};

    function tmpl(str, data) {
        var fn = !/\W/.test(str) ?
            cache[str] = cache[str] ||
            tmpl(document.getElementById(str).innerHTML) :

        new Function("obj",
                     "var p=[],print=function() {p.push.apply(p,arguments);};" +
                     "with(obj) {p.push('" +
                     str
                     .replace(/[\r\t\n]/g, " ")
                     .split("<%").join("\t")
                     .replace(/((^|%>)[^\t]*)'/g, "$1\r")
                     .replace(/\t=(.*?)%>/g, "',$1,'")
                     .split("\t").join("');")
                     .split("%>").join("p.push('")
                     .split("\r").join("\\'")
                     + "');}return p.join('');");

        return data ? fn( data ) : fn;
    };

    //求斜边长度
    function getBeveling(x,y)
    {
        return Math.sqrt(Math.pow(x,2)+Math.pow(y,2));
    }

    function drawDashLine(context,x1,y1,x2,y2,dashLen)
    {
        dashLen = dashLen === undefined ? 5 : dashLen;
        //得到斜边的总长度
        var beveling = getBeveling(x2-x1,y2-y1);
        //计算有多少个线段
        var num = Math.floor(beveling/dashLen);

        for(var i = 0 ; i < num; i++)
        {
            context[i%2 == 0 ? 'moveTo' : 'lineTo'](x1+(x2-x1)/num*i,y1+(y2-y1)/num*i);
        }
        context.stroke();
    }
}

// /////////////////////////////////////////////////////////////////
// Credits
// /////////////////////////////////////////////////////////////////

/*!
 * Chart.js
 * http://chartjs.org/
 *
 * Copyright 2013 Nick Downie
 * Released under the MIT license
 * https://github.com/nnnick/Chart.js/blob/master/LICENSE.md
 */

// Copyright (c) 2013 Nick Downie

// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
