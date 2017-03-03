/* QChart.qml ---
 *
 * Author: Julien Wintz
 * Created: Thu Feb 13 20:59:40 2014 (+0100)
 * Version:
 * Last-Updated: jeu. mars  6 12:55:14 2014 (+0100)
 *           By: Julien Wintz
 *     Update #: 69
 */

/* Change Log:
 *
 */

import QtQuick 2.0
import "QChart.js" as Charts

Canvas {

    id: canvas;

    // ///////////////////////////////////////////////////////////////

    property   var chart;
    property   var chartData;
    property   var chartOptions;
    property   var chartDatasetOptions;
    property   int chartType: 0;
    property  bool chartAnimated: true;
    property alias chartAnimationEasing: chartAnimator.easing.type;
    property alias chartAnimationDuration: chartAnimator.duration;
    property   int chartAnimationProgress: 0;
    property   int chart_index: -1;

    property   int preWidth: 0;

    /* 图形数据在整个数据中开始的位置 */
    property   int startChartDataIndex: 0;
    property   int reachedChartDataIndex: 0;
    /* 需显示的数据点个数 */
    property   int displayChartDataCount: 20;

    property  real lastGroverlineX: 0;

    property  real lastX
    property  real lastY

    property   int pressedButton: -1
    property color grovelineColor: "yellow"


    // ///////////////////////////////////////////////////////////////

    signal mousePositionChanged(var x, var y)
    signal groverlineReachedPointChanged(var reachedPointIndex, var groverlineX)
    signal sigChartInfoChanged(var reachedChartDataIndex, var groverlineX
                               , var startChartDataIndex, var displayChartDataCount)


    // ///////////////////////////////////////////////////////////////

    function log(says) {
        console.log("## QChart.qml ##: " + says);
    }

    function fetchData(arrData, idx_start, varCount) {
        var tmp = new Array;
        var len = arrData.length;

        if (idx_start < 0 || idx_start > len - 1)
            return tmp;

        for (var i = idx_start; i < varCount + idx_start; i++)
        {
            if (i >= len)
                break;

            tmp[i - idx_start] = arrData[i];
        }

//        console.log("start idx = " + idx_start + ", chop count = " + realCount)

        return tmp;
    }

    function updateChartData() {
        chartData.labels = fetchData(waveModel.x_data(chart_index)
                                     , startChartDataIndex, displayChartDataCount)
        chartData.datasets[0].data = fetchData(waveModel.y_data(chart_index)
                                               , startChartDataIndex, displayChartDataCount)

    }

    /* 左右移动波形 */
    function stepChart(steps) {
        var tmp = startChartDataIndex + steps;

        if (tmp < 0){
            startChartDataIndex = 0;
            return;
        }

        var len = waveModel.x_data(chart_index).length;
        if (tmp + displayChartDataCount > len - 1)
        {
            var tmp2 = len - displayChartDataCount;
            if (tmp2 < 0)
                startChartDataIndex = 0;
            else
                startChartDataIndex = tmp2;
        }else
            startChartDataIndex = tmp;
    }

    /* 放大缩小波形 */
    function stepLegend(steps) {
        var tmp = displayChartDataCount + steps;

        if (tmp < 2){
            displayChartDataCount = 2;
            return;
        }

        displayChartDataCount = tmp;
    }

    /* */
    function fnCalcGroverNearPoint(mouseX) {
        var delta = dp(47);
        var tmp = (mouseX - delta) / (canvas.width - delta) * (displayChartDataCount - 1);
        tmp = Math.round(tmp)

        return tmp;
    }

    // /////////////////////////////////////////////////////////////////
    // Callbacks
    // /////////////////////////////////////////////////////////////////

    onPaint: {
        log("onPaint Called: " + "chart = " + chart)
        if (chartData == undefined){
            log("chartData = " + chartData);
        }
        updateChartData()

        if(!chart) {

            switch(chartType) {
            case Charts.ChartType.BAR:
                chart = new Charts.Chart(canvas, canvas.getContext("2d")).Bar(chartData, chartOptions);
                break;
            case Charts.ChartType.DOUGHNUT:
                chart = new Charts.Chart(canvas, canvas.getContext("2d")).Doughnut(chartData, chartOptions);
                break;
            case Charts.ChartType.LINE:
                chart = new Charts.Chart(canvas, canvas.getContext("2d")).Line(chartData, chartOptions);
                break;
            case Charts.ChartType.PIE:
                chart = new Charts.Chart(canvas, canvas.getContext("2d")).Pie(chartData, chartOptions);
                break;
            case Charts.ChartType.POLAR:
                chart = new Charts.Chart(canvas, canvas.getContext("2d")).PolarArea(chartData, chartOptions);
                break;
            case Charts.ChartType.RADAR:
                chart = new Charts.Chart(canvas, canvas.getContext("2d")).Radar(chartData, chartOptions);
                break;
            default:
                console.log('Chart type should be specified.');
            }

            chart.init();

            if (chartAnimated)
                chartAnimator.start();
            else
                chartAnimationProgress = 100;
        }

        chart.draw(chartAnimationProgress/100, chartOptions);
    }

    Rectangle {
        id: groverLine
        width: dp(1)
        height: parent.height

        x: 0

        Behavior on x {
            NumberAnimation { duration: 100 }
            enabled: true
        }

        color: grovelineColor
    }

    onLastGroverlineXChanged: {
        groverLine.x = lastGroverlineX;

        var tmp = fnCalcGroverNearPoint(lastGroverlineX);
        reachedChartDataIndex = tmp;
        sigChartInfoChanged(reachedChartDataIndex, lastGroverlineX, startChartDataIndex, displayChartDataCount)

//        log("fnCalcGroverNearPoint： " + tmp)
    }

    onDisplayChartDataCountChanged: {
//        log("displayChartDataCount = " + displayChartDataCount)

        var tmp = fnCalcGroverNearPoint(lastGroverlineX);
        reachedChartDataIndex = tmp;
        sigChartInfoChanged(reachedChartDataIndex, lastGroverlineX, startChartDataIndex, displayChartDataCount)

        requestPaint();
    }

    onHeightChanged: {
        requestPaint();
    }

    onWidthChanged: {
        if (Math.abs(canvas.width - preWidth) < 4)
            return;

        if (preWidth == 0)
            preWidth = width;
        if (width == 0)
            return;
        var tmp = canvas.width / preWidth;
        preWidth = canvas.width
//        log("lastGroverlineX = " + lastGroverlineX);
//        log("tmp = " + tmp);
//        log("tmp * lastGroverlineX = " + (tmp * lastGroverlineX));
        lastGroverlineX = tmp * lastGroverlineX

        log("displayChartDataCount = " + displayChartDataCount);
    }

    onChartAnimationProgressChanged: {
        requestPaint();
    }

    onStartChartDataIndexChanged: {
        sigChartInfoChanged(reachedChartDataIndex, lastGroverlineX, startChartDataIndex, displayChartDataCount)

        requestPaint();
    }

    MouseArea {
        id: area
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        hoverEnabled: false

        onPressed: {
            pressedButton = mouse.button

            canvas.lastX = mouseX
            canvas.lastY = mouseY

            if (mouse.button == Qt.LeftButton){
                lastGroverlineX = mouseX    // 改变游标位置
            }

//            if (mouse.button == Qt.RightButton){
////                stepChart(1);
//                stepLegend(1);
//            }else if (mouse.button == Qt.LeftButton){
////                stepChart(-1);
//                stepLegend(-1);
//            }

            log("displayChartDataCount = " + canvas.displayChartDataCount);
        }

        onPositionChanged: {
            log("Position changed: " + (mouseX - canvas.lastX)
                        + ",  Old X = " + canvas.lastX + ", Current X = " + mouseX)

            var lenStep = 1;

            if (pressedButton == Qt.RightButton){
                if (mouseX > canvas.lastX)
                    stepChart(1 * lenStep)
                else if (mouseX < canvas.lastX)
                    stepChart(-1 * lenStep)
            } else if (pressedButton == Qt.LeftButton){
                lastGroverlineX = mouseX
                mousePositionChanged(mouseX, mouseY);
            }
        }


        onPressAndHold: {
            log("onPressAndHold accuring....")
        }


    }

    //  Timer {
    //        id: timer1;
    //        repeat: true;
    //        interval: 2000;
    //        triggeredOnStart: true;
    //        onTriggered: {
    //            // ... add code here
    //            console.log("chartOptions.pointDot = " + chartOptions.pointDot);
    //            chartOptions.pointDot = !chartOptions.pointDot;

    //            requestPaint()
    //        }
    //    }

    //    Component.onCompleted: {
    //        timer1.start();
    //    }

    // /////////////////////////////////////////////////////////////////
    // Functions
    // /////////////////////////////////////////////////////////////////

    function repaint() {
        chartAnimationProgress = 100;
        chartAnimator.start();
    }

    // /////////////////////////////////////////////////////////////////
    // Internals
    // /////////////////////////////////////////////////////////////////

    PropertyAnimation {
        id: chartAnimator;
        target: canvas;
        property: "chartAnimationProgress";
        to: 100;
        duration: 500;
        easing.type: Easing.InOutElastic;
    }

    Component.onCompleted: {
        chartData = {
            "labels": [],
            "datasets": [{
                             "fillColor": chartDatasetOptions.fillColor,
                             "strokeColor": chartDatasetOptions.strokeColor,
                             "pointColor": chartDatasetOptions.pointColor,
                             "pointStrokeColor": chartDatasetOptions.pointStrokeColor,
                             "data": []
                         }
            ]
        }

        preWidth = width;
    }
}
