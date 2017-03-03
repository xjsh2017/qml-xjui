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
        console.log("## QChart.js ##: " + says)
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
            scaleShowLabels: true,			// 显示纵坐标 Y
            scaleXShowLabels: true,         // 显示横坐标 X
            scaleLabel: "<%=value%>",
            scaleFontFamily: "'Arial'",
            scaleFontSize: 12,
            scaleFontStyle: "normal",
            scaleFontColor: "#666",
            scaleShowGridLines: true,       // 是否显示网格线
            scaleGridLineColor: "rgba(0,0,0,.05)",
            scaleGridLineWidth: 1,
            bezierCurve: true,
            pointDot: true,					// 显示点
            pointDotRadius: 4,
            pointDotStrokeWidth: 2,
            datasetStroke: true,
            datasetStrokeWidth: 1,          // 线条粗细
            datasetFill: true,
            animation: true,
            animationSteps: 60,
            animationEasing: "easeOutQuart",
            onAnimationComplete: null
        };

        var config = (options) ? mergeChartConfig(chart.Line.defaults,options) : chart.Line.defaults;

        return new Line(data,config,context);
    }

// /////////////////////////////////////////////////////////////////
// Line implementation
// /////////////////////////////////////////////////////////////////

    var Line = function(data,config,ctx) {

        var maxSize;
        var scaleHop;   // 纵坐标刻度间的像素长度
        var calculatedScale;    // 纵坐标刻度相关取值: 步数，步长，刻度取值
        var labelHeight;    // 坐标值的字体高度
        var scaleHeight;    // 纵坐标的像素高度
        var valueBounds;    // 纵坐标的实际采样取值范围，不是绘图刻度范围
        var labelTemplateString;
        var valueHop;       // 横坐标刻度间的像素长度
        var widestXLabel;   // 横坐标取值的最大内容长度
        var xAxisLength;    // 横坐标的像素长度
        var yAxisPosX;      // 纵左标刻度线离绘图框左边的像素距离
        var xAxisPosY;      // 横坐标刻度线离绘图框顶部的像素距离
        var rotateLabels = 0;

        // /////////////////////////////////////////////////////////////////
        // initialisation
        // /////////////////////////////////////////////////////////////////

        this.init = function () {

            calculateDrawingSizes();

            valueBounds = getValueBounds();
            labelTemplateString = (config.scaleShowLabels)? config.scaleLabel : "";

            if (!config.scaleOverride) {
                log("here")
                calculatedScale = calculateScale(scaleHeight,valueBounds.maxSteps,valueBounds.minSteps,valueBounds.maxValue,valueBounds.minValue,labelTemplateString);
            } else {
                calculatedScale = {
                    steps: config.scaleSteps,
                    stepValue: config.scaleStepWidth,
                    graphMin: config.scaleStartValue,
                    labels: []
                }
                populateLabels(labelTemplateString, calculatedScale.labels,calculatedScale.steps,config.scaleStartValue,config.scaleStepWidth);
            }

            scaleHop = Math.floor(scaleHeight/calculatedScale.steps);
            log("scaleHop = " + scaleHop)
            calculateXAxisSize();
        }

        // /////////////////////////////////////////////////////////////////
        // drawing
        // /////////////////////////////////////////////////////////////////

        this.draw = function (progress, ops) {

            this.init();

            clear(ctx);

            config = (ops) ? mergeChartConfig(config,ops) : config;

            if(config.scaleOverlay) {
                log("hahaha")
                drawLines(progress);
                drawScale();
            } else {
                log("hohoho")
                drawScale();
                drawLines(progress);
            }
        }

        // ///////////////////////////////////////////////////////////////

        function drawLines(animPc) {

            for (var i=0; i<data.datasets.length; i++) {
                ctx.strokeStyle = data.datasets[i].strokeColor;
                ctx.lineWidth = config.datasetStrokeWidth;
                ctx.beginPath();
                ctx.moveTo(yAxisPosX, xAxisPosY - animPc*(calculateOffset(data.datasets[i].data[0],calculatedScale,scaleHop)))

                for (var j=1; j<data.datasets[i].data.length; j++) {
                    if (config.bezierCurve) {
                        ctx.bezierCurveTo(xPos(j-0.5),yPos(i,j-1),xPos(j-0.5),yPos(i,j),xPos(j),yPos(i,j));
                    } else{
                        ctx.lineTo(xPos(j),yPos(i,j));
                    }
                }

                ctx.stroke();

                if (config.datasetFill) {
                    ctx.lineTo(yAxisPosX + (valueHop*(data.datasets[i].data.length-1)),xAxisPosY);
                    ctx.lineTo(yAxisPosX,xAxisPosY);
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
                        ctx.arc(yAxisPosX + (valueHop *k),xAxisPosY - animPc*(calculateOffset(data.datasets[i].data[k],calculatedScale,scaleHop)),config.pointDotRadius,0,Math.PI*2,true);
                        ctx.fill();
                        ctx.stroke();
                    }
                }
            }

            function yPos(dataSet,iteration) {
                return xAxisPosY - animPc*(calculateOffset(data.datasets[dataSet].data[iteration],calculatedScale,scaleHop));
            }

            function xPos(iteration) {
                return yAxisPosX + (valueHop * iteration);
            }
        }

        function drawScale() {

            ctx.lineWidth = config.scaleLineWidth;
            ctx.strokeStyle = config.scaleLineColor;
            ctx.beginPath();
//            ctx.moveTo(width-widestXLabel/2 + 5,xAxisPosY);
            ctx.moveTo(width-widestXLabel/2,xAxisPosY);
//            ctx.lineTo(width-(widestXLabel/2)-xAxisLength-5,xAxisPosY);
            ctx.lineTo(yAxisPosX - 5, xAxisPosY)
            ctx.stroke();

            if (rotateLabels > 0) {
                ctx.save();
                ctx.textAlign = "right";
            } else{
                ctx.textAlign = "center";
            }
            ctx.fillStyle = config.scaleFontColor;

            // 绘制纵向网格线，不包括纵坐标刻度线，并绘制横坐标的刻度数值
            for (var i=0; i<data.labels.length; i++) {

                ctx.save();

                if (config.scaleXShowLabels)
                if (rotateLabels > 0) {
                    ctx.translate(yAxisPosX + i*valueHop,xAxisPosY + config.scaleFontSize);
                    ctx.rotate(-(rotateLabels * (Math.PI/180)));
                    ctx.fillText(data.labels[i], 0,0);
                    ctx.restore();
                } else {
                    ctx.fillText(data.labels[i], yAxisPosX + i*valueHop,xAxisPosY + config.scaleFontSize+3);
                }

                ctx.beginPath();
                ctx.moveTo(yAxisPosX + i * valueHop, xAxisPosY+3);

                if(config.scaleShowGridLines && i>0) {
                    ctx.lineWidth = config.scaleGridLineWidth;
                    ctx.strokeStyle = config.scaleGridLineColor;
                    ctx.lineTo(yAxisPosX + i * valueHop, 5);
                } else{
                    ctx.lineTo(yAxisPosX + i * valueHop, xAxisPosY+3);
                }
                ctx.stroke();
            }

            // 绘制横纵坐标、横向网格线，不包括横坐标，并绘制纵坐标刻度数值
            ctx.lineWidth = config.scaleLineWidth;
            ctx.strokeStyle = config.scaleLineColor;
            ctx.beginPath();
            ctx.moveTo(yAxisPosX,xAxisPosY+5);
            ctx.lineTo(yAxisPosX,5);
            ctx.stroke();
            ctx.textAlign = "right";
            ctx.textBaseline = "middle";

            log("calculatedScale.labels = " + calculatedScale.labels)
            for (var j=0; j<calculatedScale.steps; j++) {
                ctx.beginPath();
                ctx.moveTo(yAxisPosX-3,xAxisPosY - ((j+1) * scaleHop));
                if (config.scaleShowGridLines) {
                    ctx.lineWidth = config.scaleGridLineWidth;
                    ctx.strokeStyle = config.scaleGridLineColor;
                    ctx.lineTo(yAxisPosX + xAxisLength + 5,xAxisPosY - ((j+1) * scaleHop));
                } else {
                    ctx.lineTo(yAxisPosX-0.5,xAxisPosY - ((j+1) * scaleHop));
                }
                ctx.stroke();
                if (config.scaleShowLabels) {
                    log(j)
                    ctx.fillText(calculatedScale.labels[j],yAxisPosX-8,xAxisPosY - ((j+0) * scaleHop));
                }
            }
            if (config.scaleShowLabels) { // 绘制纵坐标最上面一个刻度数值
                ctx.moveTo(yAxisPosX-3, xAxisPosY - ((calculatedScale.steps) * scaleHop));
                ctx.fillText(calculatedScale.labels[calculatedScale.steps], yAxisPosX-8, xAxisPosY - ((calculatedScale.steps) * scaleHop));
            }
        }

        function calculateXAxisSize() {

            var longestText = 1;    // 纵坐标最长的刻度数值的右边缘离整个绘图框左边的像素长度

            if (config.scaleShowLabels) {
                ctx.font = config.scaleFontStyle + " " + config.scaleFontSize+"px " + config.scaleFontFamily;
                for (var i=0; i<calculatedScale.labels.length; i++) {
                    var measuredText = ctx.measureText(calculatedScale.labels[i]).width;
                    longestText = (measuredText > longestText)? measuredText : longestText;
                }
                longestText +=10;
            }
            log("longestText = " + longestText)

            xAxisLength = width - longestText - widestXLabel;
//            valueHop = Math.floor(xAxisLength/(data.labels.length-1));
            valueHop = xAxisLength/(data.labels.length-1);
            log("xAxisLength = " + xAxisLength + ", valueHop = " + valueHop)

            yAxisPosX = width-widestXLabel/2-xAxisLength;
            xAxisPosY = scaleHeight + config.scaleFontSize/2;
            log("yAxisPosX = " + yAxisPosX + ", xAxisPosY = " + xAxisPosY)
        }

        function calculateDrawingSizes() { // 计算纵坐标可用的高度

            log("height = " + height + ", width = " + width)

            maxSize = height;

            ctx.font = config.scaleFontStyle + " " + config.scaleFontSize+"px " + config.scaleFontFamily;

            widestXLabel = 1;
            log("ctx.font = " + ctx.font)
            if (config.scaleXShowLabels){
                for (var i=0; i<data.labels.length; i++) {

                    var textLength = ctx.measureText(data.labels[i]).width;
                    widestXLabel = (textLength > widestXLabel)? textLength : widestXLabel;
    //                log("data.labels[" + i + "].width = " + textLength)
                }
                log("widestXLabel = " + widestXLabel)

                if (width/data.labels.length < widestXLabel) {
                    log("less")

                    rotateLabels = 45;

                    if (width/data.labels.length < Math.cos(rotateLabels) * widestXLabel) {
                        rotateLabels = 90;
                        maxSize -= widestXLabel;
                    } else{
                        maxSize -= Math.sin(rotateLabels) * widestXLabel;
                    }
                } else{
                    maxSize -= config.scaleFontSize;
                }
            }

            log("maxSize = " + maxSize)

            maxSize -= 5;

            labelHeight = config.scaleFontSize;
            maxSize -= labelHeight;

            scaleHeight = maxSize;

            log("maxSize = " + maxSize)
        }

        function getValueBounds() { // 获取 data.datasets 最大最小值，即纵坐标的范围

            var upperValue = Number.MIN_VALUE;
            var lowerValue = Number.MAX_VALUE;

            log("upperValue = " + upperValue + ", lowerValue = " + lowerValue)

            for (var i=0; i<data.datasets.length; i++) {
                for (var j=0; j<data.datasets[i].data.length; j++) {
                    if ( data.datasets[i].data[j] > upperValue) { upperValue = data.datasets[i].data[j] };
                    if ( data.datasets[i].data[j] < lowerValue) { lowerValue = data.datasets[i].data[j] };
                }
            };

            log("upperValue = " + upperValue + ", lowerValue = " + lowerValue)

            var maxSteps = Math.floor((scaleHeight / (labelHeight*0.66)));
            var minSteps = Math.floor((scaleHeight / labelHeight*0.5));

            log("maxSteps = " + maxSteps + ", minSteps = " + minSteps)

            return {
                maxValue: upperValue,
                minValue: lowerValue,
                maxSteps: maxSteps,
                minSteps: minSteps
            };
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

    /* 计算纵坐标的刻度值 */
    function calculateScale(drawingHeight,maxSteps,minSteps,maxValue,minValue,labelTemplateString) {

        var graphMin,graphMax,graphRange,stepValue,numberOfSteps,valueRange,rangeOrderOfMagnitude,decimalNum;

        valueRange = maxValue - minValue;
        rangeOrderOfMagnitude = calculateOrderOfMagnitude(valueRange);
        log("rangeOrderOfMagnitude = " + rangeOrderOfMagnitude)
        graphMin = Math.floor(minValue / (1 * Math.pow(10, rangeOrderOfMagnitude))) * Math.pow(10, rangeOrderOfMagnitude);
        graphMax = Math.ceil(maxValue / (1 * Math.pow(10, rangeOrderOfMagnitude))) * Math.pow(10, rangeOrderOfMagnitude);

        log("graphMax = " + graphMax + ", graphMin = " + graphMin)

        graphRange = graphMax - graphMin;
        stepValue = Math.pow(10, rangeOrderOfMagnitude);
        numberOfSteps = Math.round(graphRange / stepValue);

        log("stepValue = " + stepValue + ", numberOfSteps = " + numberOfSteps)

        while(numberOfSteps < minSteps || numberOfSteps > maxSteps) {
            if (numberOfSteps < minSteps) {
                stepValue /= 2;
                numberOfSteps = Math.round(graphRange/stepValue);
            } else{
                stepValue *=2;
                numberOfSteps = Math.round(graphRange/stepValue);
            }
        };

        var labels = [];

        populateLabels(labelTemplateString, labels, numberOfSteps, graphMin, stepValue);
        log("labels = " + labels)

        return {
            steps: numberOfSteps,   // 步数
            stepValue: stepValue,   // 步长
            graphMin: graphMin,     // 最小刻度值
            labels: labels          // 每步刻度值，从小到大
        }

        function calculateOrderOfMagnitude(val) {
            return Math.floor(Math.log(val) / Math.LN10);
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
