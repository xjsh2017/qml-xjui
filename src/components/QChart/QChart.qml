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

    property  point chartScaleLeftTop;
    property  point chartScaleRightBottom;

    /* 图形数据在整个数据中开始的位置 */
    property   int chartStartDataIndex: 0;
    property   int chartReachedPointIndex: 0;
    property   int chartDisplayPointCount: 20;
    property  real chartGroovePosX: 0;
    property color chartGrooveColor: "yellow"


    property  real lastX
    property  real lastY

    property   int pressedButton: -1
    property   int preWidth: 0;

    // ///////////////////////////////////////////////////////////////

    signal mousePositionChanged(var x, var y)
    signal sigChartInfoChanged(var chartReachedPointIndex, var chartGroovePosX
                               , var chartStartDataIndex, var chartDisplayPointCount)
    signal sigDrawingCompleted(var x)


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

        return tmp;
    }

    function updateChartData() {
        if (!chartData){
            init();
        }

        chartData.labels = fetchData(waveModel.x_data(chart_index)
                                     , chartStartDataIndex, chartDisplayPointCount)
        chartData.datasets[0].data = fetchData(waveModel.y_data(chart_index)
                                               , chartStartDataIndex, chartDisplayPointCount)

    }

    /* 左右移动波形 */
    function stepChart(steps) {
        var tmp = chartStartDataIndex + steps;

        if (tmp < 0){
            chartStartDataIndex = 0;
            return;
        }

        var len = waveModel.x_data(chart_index).length;
        if (tmp + chartDisplayPointCount > len - 1)
        {
            var tmp2 = len - chartDisplayPointCount;
            if (tmp2 < 0)
                chartStartDataIndex = 0;
            else
                chartStartDataIndex = tmp2;
        }else
            chartStartDataIndex = tmp;
    }

    /* 放大缩小波形 */
    function stepLegend(steps) {
        var tmp = chartDisplayPointCount + steps;

        if (tmp < 2){
            chartDisplayPointCount = 2;
            return;
        }

        chartDisplayPointCount = tmp;
    }

    /* 找到离游标刻度线最近的点 */
    function findGrooveNearPoint(scalePosX, leftTop, rightBottom) {
        log("find start pos x = " + scalePosX)

        var scalewidth = rightBottom.x - leftTop.x
        var tmp = scalePosX * (chartDisplayPointCount - 1) / scalewidth;
        tmp = Math.round(tmp)

        log("found point idx = " + tmp)

        return tmp;
    }

    function init() {
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

        sigDrawingCompleted(chartScaleLeftTop.x)
    }

    Rectangle {
        id: groove
        width: dp(1)
        height: parent.height

        x: 0

        Behavior on x {
            NumberAnimation { duration: 100 }
            enabled: true
        }

        color: chartGrooveColor
    }

    onChartGroovePosXChanged: {
        groove.x = chartGroovePosX + chartScaleLeftTop.x;

        log("groove.posx = " + chartGroovePosX)

        var tmp = findGrooveNearPoint(chartGroovePosX, chartScaleLeftTop, chartScaleRightBottom);
        chartReachedPointIndex = tmp;
        sigChartInfoChanged(chartReachedPointIndex, chartGroovePosX, chartStartDataIndex, chartDisplayPointCount)

//        log("findGrooveNearPoint： " + tmp)
    }

    onChartDisplayPointCountChanged: {
//        log("chartDisplayPointCount = " + chartDisplayPointCount)

        var tmp = findGrooveNearPoint(chartGroovePosX, chartScaleLeftTop, chartScaleRightBottom);
        chartReachedPointIndex = tmp;
        sigChartInfoChanged(chartReachedPointIndex, chartGroovePosX, chartStartDataIndex, chartDisplayPointCount)

        requestPaint();
    }

    onChartStartDataIndexChanged: {
        sigChartInfoChanged(chartReachedPointIndex, chartGroovePosX, chartStartDataIndex, chartDisplayPointCount)

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
//        log("chartGroovePosX = " + chartGroovePosX);
//        log("tmp = " + tmp);
//        log("tmp * chartGroovePosX = " + (tmp * chartGroovePosX));
        chartGroovePosX = tmp * chartGroovePosX

        log("chartDisplayPointCount = " + chartDisplayPointCount);
    }

    onChartAnimationProgressChanged: {
        requestPaint();
    }

    function calcChartGroovePosX(mouseX) {
        var tmpLeft = mouseX - chartScaleLeftTop.x;
        var tmpRight = chartScaleRightBottom.x - mouseX;
        if (tmpLeft > 0 && tmpRight > 0)
            return tmpLeft;
    }

    MouseArea {
        id: area
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        hoverEnabled: false

        onReleased: {
        }

        onPressed: {
            pressedButton = mouse.button

            canvas.lastX = mouseX
            canvas.lastY = mouseY

            if (mouse.button == Qt.LeftButton){
                var tmp = calcChartGroovePosX(mouseX);
                if (tmp)
                    chartGroovePosX = tmp    // 改变游标位置
            }

            log("scaleVertex.leftTop = " + canvas.chartScaleLeftTop)
            log("scaleVertex.rightBottom = " + canvas.chartScaleRightBottom)

//            log("chartDisplayPointCount = " + canvas.chartDisplayPointCount);
//            log("canvas.with = " + canvas.width)
        }

        onPositionChanged: {
            log("Position changed: " + (mouseX - canvas.lastX)
                        + ",  Old X = " + canvas.lastX + ", Current X = " + mouseX)

            var lenStep = 1;

            if (pressedButton == Qt.RightButton){
                if (mouseX > canvas.lastX)
                    stepChart(-1 * lenStep)
                else if (mouseX < canvas.lastX)
                    stepChart(1 * lenStep)
            } else if (pressedButton == Qt.LeftButton){
                var tmp = calcChartGroovePosX(mouseX);
                if (tmp)
                    chartGroovePosX = tmp    // 改变游标位置
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
        init();
    }
}
