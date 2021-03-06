import QtQuick 2.0

//import XjUi 1.0
import "WaveChart.js" as WaveCharts
import "../../core"

Canvas {

    id: canvas;

    // ///////////////////////////////////////////////////////////////

    property   var model
    property   int index: -1;

    property   int plotType: WaveCharts.ChartType.LINE;
    property   var plotHandler;
    property   var plotArea: {
        return {
            leftTop: Qt.point(0, 0),
            rightBottom: Qt.point(0, 0),
            width: 0,
            height: 0
        }
    }

    property   var plotData;
    property  real startDataIndex: 0;
    property   int selectDataIndex: 0;

    property   int pressedButton: Qt.LeftButton
    property  real grooveXPlot: 0;
    property color grooveColor: "yellow"

    property  string plotMode: Global.g_plotMode;                   // 绘图模式： 0 - 时间模式、 1 - 采样点模式
    property  real timeRate: Global.g_timeRate;                   // 1ms间隔等同4像素， 取整取浮点都可以。
    property  real timeWidth: (width - 58) / timeRate;          // 单位： ms
    property  real sampleRate: Global.g_sampleRate;               // 采样点间隔等同2个像素，  取整取浮点都可以。
    property  real sampleWidth: Math.floor((width - xPlotOffset - 58) / sampleRate);      // 单位： 个数c
    property  real xPlotOffset: (Math.ceil(startDataIndex) - startDataIndex) * sampleRate

    // ///////////////////////////////////////////////////////////////

    property   var chartOptions;
    property   var chartDatasetOptions;

    property  bool chartAnimated: true;
    property alias chartAnimationEasing: chartAnimator.easing.type;
    property alias chartAnimationDuration: chartAnimator.duration;
    property   int chartAnimationProgress: 0;

    property  real lastX: 0

    // ///////////////////////////////////////////////////////////////

    signal sigChartInfoChanged(var selectDataIndex, var grooveXPlot
                               , var startDataIndex, var plotDataCount)
    signal sigDrawingCompleted(var x)


    // ///////////////////////////////////////////////////////////////

    function init() {
        plotData = {
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

        selectDataIndex = 0;
    }

    function updateCurve() {
        chartAnimationProgress = 100;
        requestPaint();
    }

    function repaint(){
        plotHandler = 0;
        requestPaint();
    }

    function log(says) {
//        console.log("# WaveChart.qml: # " + says);
    }

    function debug(de) {
        if (!de)
            log("-------------debug------------")
        else
            log("-------------" + de + "------------")
    }

    function updatePlotDataBySample(start) {
        if (!plotData){
            init();
        }

        updateSampleWidth();
        log("sampleWidth = " + sampleWidth)

        start = Math.ceil(start);
        plotData.labels = AnalDataModel.getXRow(0, start, start + sampleWidth);
        plotData.datasets[0].data = AnalDataModel.getYRow(index, start, start + sampleWidth);

//        log(index);
//        log(plotData.labels);
//        log(plotData.datasets[0].data);
    }

    function updateSampleWidth() {
        if (sampleRate < 0)
            return;

//        sampleWidth = Math.floor((plotArea.rightBottom.x - plotArea.leftTop.x) / sampleRate);
        sampleWidth = Math.floor((width - xPlotOffset - dp(58)) / sampleRate);

//        log("sampleWidth = " + sampleWidth)
    }

    function updatePlotDataByTime(startTime) {
        if (!plotData){
            init();
        }

        updateTimeWidth();

        var bound = Matlab.findBound(parseFloat(startTime), timeWidth, AnalDataModel.getXRow(0));
        console.assert(bound.end >= bound.start)
//        log("bound = " + bound.start + ", " + bound.end);

//        plotData.labels = model.x.row(0, bound.start, bound.end).data;
//        plotData.datasets[0].data = model.y.row(index, bound.start, bound.end).data;
        plotData.labels = AnalDataModel.getXRow(0, bound.start, bound.end);
        plotData.datasets[0].data = AnalDataModel.getYRow(index, bound.end, bound.end);

//        log(plotData.labels.length)
//        log(plotData.labels)
//        log(plotData.datasets[0].data.length)
//        log(plotData.datasets[0].data)
    }

    function updateTimeWidth() {
        if (canvas.timeRate < 0)
            return;

//        timeWidth = (plotArea.rightBottom.x - plotArea.leftTop.x) / timeRate;
        timeWidth = (width - dp(58)) / timeRate;
    }

    function startRunningTime(start, interval) {
        if (interval > 0)
            runningTimer.interval = interval;
        if (start)
            runningTimer.start();
        else
            runningTimer.stop();
    }

    /* 左右移动波形 */
    function stepChart(steps) {
        var tmp = startDataIndex + steps;

        if (tmp < 0){
            startDataIndex = 0;
            return;
        }

//        console.log("\n\t Sample Width = " + sampleWidth
//                    + "\n \t tmpLast = " + (cols() - sampleWidth))

        if (plotMode == Global.enSampleMode){
            if (sampleWidth + tmp > cols() - 1){
                var tmpLast = cols() - sampleWidth
                if (tmpLast > 0)
                    startDataIndex = tmpLast;
                else// if(tmpLast < 0)
                    startDataIndex = startDataIndex;
//                else
//                    startDataIndex = 0;
            }else{
                startDataIndex = tmp;
            }
        }else{
            var maxTimeEnd = parseFloat(xData(0, cols()-1));
            var maxStartTime = maxTimeEnd - timeWidth;
            var bound;
            if ( tmp > cols() - 1){
                bound = Matlab.findBound(maxStartTime, 0, AnalDataModel.getXRow(0));
                startDataIndex = bound.start;
            }else{
                var newStartTime = parseFloat(xData(0, tmp));
                if (newStartTime > maxStartTime){
                    bound = Matlab.findBound(maxStartTime, 0, AnalDataModel.getXRow(0));
                    startDataIndex = bound.start;
                }else
                    startDataIndex = tmp;
            }
        }

        log(" startDataIndex = " + startDataIndex
                    + "\n\t xPlotOffset = " + xPlotOffset);
    }

    function stepChartToLast(){
        var tmpLast = cols() - sampleWidth
        if (tmpLast > 0)
            startDataIndex = tmpLast;
    }

    function rows() {
        return AnalDataModel.getDataSize().rows;
    }

    function cols() {
        return AnalDataModel.getDataSize().cols;
    }

    function yData(dataIndex) {
        return AnalDataModel.sampleModel.y[index][dataIndex];
    }

    function xData(dataIndex) {
        return AnalDataModel.sampleModel.x[0][dataIndex];
    }

    /* 放大缩小波形 */
    function scaleChart(steps) {
        var tmp;
        if (plotMode == Global.enSampleMode){
            tmp = sampleRate + steps;
            if (tmp < Global.g_DefaultSampleRate){
                sampleRate = Global.g_DefaultSampleRate;
            }else
                sampleRate = tmp;
        }else{
            tmp = timeRate + steps;
            if (tmp < Global.g_DefaultTimeRate){
                timeRate = Global.g_DefaultTimeRate;
            }else{
                timeRate = tmp
            }
        }
    }

    function scaleChartToDefault() {
        var tmp;
        if (plotMode == Global.enSampleMode){
            sampleRate = Global.g_DefaultSampleRate;
        }else{
            timeRate = Global.g_DefaultTimeRate;
        }
    }

    /*! 找到离游标刻度线最近的点， xPlot 为曲线Outline范围内的横坐标 */
    function findSelDataIndex(xPlot) {
        if (!plotArea || !plotArea.width)
            return NaN;

        var tmp;
        if (plotMode == Global.enSampleMode){
            tmp = xPlot * sampleWidth / plotArea.width;

            log("findSelDataIndex = "
                        + "\n\t mouseX = " + lastX
                        + "\n\t xPlot = " + xPlot
                        + "\n\t sampleRate = " + Global.g_sampleRate
                        + "\n\t point index = " + tmp
                        + "\n\t select data index = " + Math.round(tmp + startDataIndex) + " (" + (tmp + startDataIndex).toFixed(4) + ")"
                        )
        }

        tmp += startDataIndex;

        return Math.round(tmp)
    }

    /*! 画布横坐标转曲线区域坐标 */
    function mouseXPos2Plot(mouseX) {
        lastX = mouseX;
        var xPlot = plotArea.rightBottom.x - mouseX;
        if (xPlot < 0)
            return NaN;
        xPlot = mouseX - plotArea.leftTop.x;
        if (xPlot <  0)
            return NaN;

        return xPlot;
    }

    // ///////////////////////////////////////////////////////////////

    Rectangle {
        id: groove
        width: dp(1)
        height: parent.height

        x: 0

        Behavior on x {
            NumberAnimation { duration: 100 }
            enabled: true
        }

        color: grooveColor
    }


    // ///////////////////////////////////////////////////////////////

    onPaint: {
        log("---------------- onPaint Called: " + "plotHandler = " + plotHandler)
        if (plotData == undefined){
            log("plotData = " + plotData);
            init();
        }

        if (plotMode == Global.enSampleMode)
            updatePlotDataBySample(startDataIndex);
        else
            updatePlotDataByTime(xData(startDataIndex));

        if (!Matlab.isArray(plotData.datasets[0].data || !plotData.labels)){
            plotData.datasets[0].data = [];
            plotData.labels = [];
        }

        if(!plotHandler) {
            switch(plotType) {
            case WaveCharts.ChartType.BAR:
                plotHandler = new WaveCharts.Chart(canvas, canvas.getContext("2d")).Bar(plotData, chartOptions);
                break;
            case WaveCharts.ChartType.DOUGHNUT:
                plotHandler = new WaveCharts.Chart(canvas, canvas.getContext("2d")).Doughnut(plotData, chartOptions);
                break;
            case WaveCharts.ChartType.LINE:
                plotHandler = new WaveCharts.Chart(canvas, canvas.getContext("2d")).Line(plotData, chartOptions);
                break;
            case WaveCharts.ChartType.PIE:
                plotHandler = new WaveCharts.Chart(canvas, canvas.getContext("2d")).Pie(plotData, chartOptions);
                break;
            case WaveCharts.ChartType.POLAR:
                plotHandler = new WaveCharts.Chart(canvas, canvas.getContext("2d")).PolarArea(plotData, chartOptions);
                break;
            case WaveCharts.ChartType.RADAR:
                plotHandler = new WaveCharts.Chart(canvas, canvas.getContext("2d")).Radar(plotData, chartOptions);
                break;
            default:
                console.log('Chart type should be specified.');
            }

            plotHandler.init();

            if (chartAnimated)
                chartAnimator.start();
            else
                chartAnimationProgress = 100;
        }

        if (plotHandler && plotHandler.draw){
            plotHandler.draw(chartAnimationProgress/100, chartOptions);

            sigDrawingCompleted(plotArea.leftTop.x)

//            log ("plotArea = "
//                 + "\n\t leftTop: " + plotArea.leftTop
//                 + "\n\t rightBottom: " + plotArea.rightBottom
//                 + "\n\t width = " + plotArea.width
//                 + "\n\t height = " + plotArea.height
//                 + "\n\t startIndex = " + startDataIndex
//                 + "\n\t time with = " + timeWidth
//                 + "\n\t sample with = " + sampleWidth)
        }
    }

    onGrooveXPlotChanged: {
        groove.x = grooveXPlot + plotArea.leftTop.x;

        selectDataIndex = findSelDataIndex(grooveXPlot);
    }

    onSampleRateChanged: {
        updateSampleWidth();

        selectDataIndex = findSelDataIndex(grooveXPlot);

        updateCurve();
    }

    onTimeRateChanged: {
        updateTimeWidth();

        selectDataIndex = findSelDataIndex(grooveXPlot);


        updateCurve();
    }

    onHeightChanged: {
        updateCurve();
    }

    onWidthChanged: {
        updateCurve();
    }

    onChartAnimationProgressChanged: {
//        updateCurve();
    }

    onStartDataIndexChanged: {
        selectDataIndex = findSelDataIndex(grooveXPlot);

//        console.log("selectDataIndex = " + selectDataIndex);

        updateCurve();
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
            if (mouse.button == Qt.LeftButton){
                var tmp = mouseXPos2Plot(mouseX);
                if (tmp)
                    grooveXPlot = tmp    // 改变游标位置
            }
        }

        onPositionChanged: {
            var lenStep = 1;

            if (pressedButton == Qt.RightButton){
                if (mouseX > canvas.lastX)
                    stepChart(-1 * lenStep)
                else if (mouseX < canvas.lastX)
                    stepChart(1 * lenStep)
            } else if (pressedButton == Qt.LeftButton){
                var tmp = mouseXPos2Plot(mouseX);
                if (tmp)
                    grooveXPlot = tmp    // 改变游标位置
            }
        }
    }

    Timer {
        id: runningTimer;
        repeat: true;
        interval: 3000;
        triggeredOnStart: true;
        onTriggered: {
            stepChartToLast();

            updateCurve();
        }
    }

    PropertyAnimation {
        id: chartAnimator;
        target: canvas;
        property: "chartAnimationProgress";
        to: 100;
        duration: 500;
        easing.type: Easing.InOutElastic;
    }

    Component.onCompleted: {
        log("Component.onCompleted")
        init();
    }

    Component.onDestruction: {
        log("Component.onDestruction")
    }
}
