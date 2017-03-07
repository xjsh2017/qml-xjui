import QtQuick 2.4
import Material 0.2
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

import "."
import "../components"
import "../components/Grover"
import "../components/QChart"
import "../components/QChart/QChart.js"         as Charts

Item {
    id: root


    // ///////////////////////////////////////////////////////////////


    // ///////////////////////////////////////////////////////////////

    function log(says) {
        console.log("## WaveAnalDemo.qml ##: " + says);
    }

    function dp(di){
        return di;
    }

    function random_scalingFactor() {
        return Math.round(Math.random() * 100);
    }

    function random_color() {
        return Qt.rgba(Math.random(),
                       Math.random(), Math.random(), 1);
    }

    function random_colos(clrCount) {
        var arrClr = new Array;
        for (var i = 0; i < clrCount; i++)
            arrClr.push(random_color());

        log(arrClr);

        return arrClr;
    }

    // ///////////////////////////////////////////////////////////////

    ColumnLayout {
        id: rootLayout

        anchors {
            fill: parent
            margins: dp(0)
        }
        spacing: dp(6)

        // 工具栏
        View {
            id: toolbar

            visible: false

            height: dp(36)
            elevation: dp(2)
            clip:false
//            backgroundColor: Theme.backgroundColor

            Layout.fillWidth: true

            Rectangle { // 渐变色
                anchors.fill: parent
                gradient: Gradient {
                        GradientStop { position: 0.0; color: "white" }
                        GradientStop { position: 0.73; color: "lightgrey" }
                        GradientStop { position: 1.0; color: "lightgrey" }
                    }
            }

            // 按钮
            RowLayout {
                width: parent.width
                height: parent.height

                anchors {
                    margins: dp(11)
                    bottomMargin: dp(8)
                    leftMargin: dp(8)
                }
                spacing: dp(12)

                IconButton {
                    id: action_timer
                    Layout.leftMargin: dp(8)

                    action: Action {
                        iconName: "action/alarm"
                        name: "Chart : timer for data runtime.."
                        hoverAnimation: false
                        onTriggered: {
                            var varTmpInfo;
                            if (timer_waveModel.running)
                            {
                                timer_waveModel.stop();
                                varTmpInfo = " Timer for Changing Wave Data Model is stopped  !";
                            }else
                            {
                                timer_waveModel.start();
                                varTmpInfo = " Timer for Changing Wave Data Model is running  !";
                            }
                            snackbar.open(varTmpInfo)
                            log(varTmpInfo)

                            for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                                flickable_wave.arrayChart[i].startRunningTime(timer_waveModel.running);
                            }
                        }
                    }
                }

                Button {
                    id: btnDebug1

                    visible: false

                    text: "Mouse: X: " + 0 + ", Y: " + 0
                    implicitHeight: dp(30)
                    elevation: 1
                    activeFocusOnPress: true
                    backgroundColor: Theme.accentColor
                    Layout.alignment: Qt.AlignVCenter

                    onClicked: {
//                        actionSheet.visible = !actionSheet.visible
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    id: btnDebug
                    text: ""/*waveModel.test*/

                    visible: text.length > 0

                    implicitHeight: dp(28)
                    elevation: 1
                    //                    activeFocusOnPress: true
                    backgroundColor: Theme.accentColor
                    //                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.alignment: Qt.AlignVCenter

                    onClicked: snackbar.open("That button is colored!")
                }

                IconButton {
                    id: chart_setting
                    Layout.rightMargin: dp(8)

                    action: Action {
                        iconName: "action/settings"
                        name: "Settings"
                        hoverAnimation: true
                        onTriggered: {
                            chartSettings.show()
                        }
                    }
                }
            }
        }

        // 波形标尺
        View {
            id: axis_wave

            elevation: 1
            height: dp(65)

            Layout.fillWidth: true

            Row {
                width: parent.width
                height: parent.height

                View {
                    id: panel_groove
                    width: dp(160)
                    height: parent.height

                    elevation: 3

//                    border.color: Theme.accentColor

                    Flow {
                        id: chart_info_title_panel
                        width: parent.width
                        height: parent.height

                        anchors {
                            left: parent.left
                            leftMargin: dp(10)
                            top: parent.top
                            topMargin: height / 2 - action_inflate.height / 2//dp(10)
//                            centerIn: parent
                        }
                        spacing: dp(6)

                        IconButton {
                            id: action_inflate

                            action: Action {
                                iconName: "action/inflate"
                                name: "Chart : Inflate look"
                                onTriggered: {
                                    for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                                        flickable_wave.arrayChart[i].stepLegend(-2);
                                    }
                                }
                            }
                        }

                        IconButton {
                            id: action_inflate_default

                            action: Action {
                                iconName: "action/inflate_default"
                                name: "Chart : default look"
                                onTriggered: {
                                    for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                                        flickable_wave.arrayChart[i].stepLegend(0);
                                    }
                                }
                            }
                        }

                        IconButton {
                            id: action_deflate

                            action: Action {
                                iconName: "action/deflate"
                                name: "Chart : Deflate look"
                                onTriggered: {
                                    for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                                        flickable_wave.arrayChart[i].stepLegend(2);
                                    }
                                }
                            }
                        }

                        IconButton {
                            id: chart_refresh

                            action: Action {
                                iconName: "navigation/refresh"
                                name: "Chart: Refresh (Ctrl + R)"
                                hoverAnimation: true
                                onTriggered: {
                                    for (var i = 0; i < flickable_wave.arrayChartInfo.length; ++i){
                                        flickable_wave.arrayChart[i].chart = null;
                                        flickable_wave.arrayChart[i].requestPaint();
                                    }
                                    snackbar.open("All Charts Refreshed !")
                                }
                            }
                        }

                        IconButton {
                            id: chart_setting2

                            action: Action {
                                iconName: "action/setting"
                                name: "Chart Settings (Ctrl + I)"
                                hoverAnimation: true
                                onTriggered: {
                                    chartSettings.show()
                                }
                            }
                        }

                        Button {
                            id: btnValueType
                            text: qsTr("瞬")

                            property int valueType: 0   // 0 - 瞬时值， 1 - 有效值

                            implicitHeight: dp(22)
                            implicitWidth: dp(22)
                            elevation: 0
                            backgroundColor: Theme.accentColor
                            Layout.alignment: Qt.AlignVCenter

                            onClicked: {
                                if (valueType == 1){
                                    text = qsTr("瞬");
                                    valueType = 0;
                                    backgroundColor = Theme.accentColor
                                }else{
                                    text = qsTr("有")
                                    valueType = 1;
                                    backgroundColor = "green"
                                }
                                for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                                    var samplePos = flickable_wave.arrayChart[i].chartReachedPointIndex;
                                    var fresult = flickable_wave.arrayChart[i].calcLatitudeAndPhase(
                                                flickable_wave.arrayChart[i].chartData.datasets[0].data, 80, samplePos);
                                    var datapos = flickable_wave.arrayChartInfo[i].selDataPointIndex;

                                    log("samplePos = " + samplePos + ", datapos = " + datapos)

                                    var tmp1 = waveModel.y_data(flickable_wave.arrayChart[i].chart_index)[datapos];

                                    log("By Btn:  Instant = " + tmp1 + ", real = " + fresult[0].toFixed(2));
                                    if (valueType == 1)
                                        tmp1 = fresult[0].toFixed(2);

                                    flickable_wave.arrayChartValue[i].text = tmp1 + " ∠ " + fresult[2].toFixed(2) + "°"
                                }
                            }
                        }

                        IconButton {
                            id: runInRealTime
                            Layout.leftMargin: dp(8)

                            action: Action {
                                iconName: "action/alarm"
                                name: "Chart : timer for data runtime.."
                                onTriggered: {
                                    var varTmpInfo;
                                    if (timer_waveModel.running)
                                    {
                                        timer_waveModel.stop();
                                        varTmpInfo = " Timer for Changing Wave Data Model is stopped  !";
                                    }else
                                    {
                                        timer_waveModel.start();
                                        varTmpInfo = " Timer for Changing Wave Data Model is running  !";
                                    }
                                    snackbar.open(varTmpInfo)
                                    log(varTmpInfo)

                                    for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                                        flickable_wave.arrayChart[i].startRunningTime(timer_waveModel.running);
                                    }
                                }
                            }
                        }
                    }
                }

                // 大标尺
                Groove {
                    id: gr

                    height: parent.height
                    width: parent.width - panel_groove.width

                    value: maximumValue * 0
                    focus: true
                    tickmarksEnabled: true
                    numericValueLabel: true
                    stepSize: dp(10)    // 10个像素绘制一个小刻度， 50个像素绘制一个中刻度， 100个像素绘制一个大刻度
                    minimumValue: 0
                    maximumValue: parent.width + minimumValue - gr.anchors.leftMargin  // 刻度尺的长度
                    activeFocusOnPress: true
                    darkBackground: false//index == 1

                    property real valueChangedDelta: 0

                    property bool lockValueChange: false

                    onValueChanged: {
                    }

                    onLeftMoveClicked: {

                    }

                    onRightMoveClicked: {
                        gr.scrollbar_posx += gr.scrollbarSteps * 1
                    }
                }

                Connections {
                    target: gr

                    onScrollbarPosChanged : {
                        log("scrollbar status: " + delta + ", " + pos)
                        gr.minimumValue = gr.scrollbarSteps * pos;
                        log("gr.min_max = (" + gr.minimumValue + ", " + gr.maximumValue + ")")

                        for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                            flickable_wave.arrayChart[i].chartStartDataIndex = (delta ? 1 : -1) * gr.scrollbarSteps * pos;
                            if (flickable_wave.arrayChart[i].chartStartDataIndex < 0)
                                flickable_wave.arrayChart[i].chartStartDataIndex = 0;
                            else if (flickable_wave.arrayChart[i].chartStartDataIndex
                                     > waveModel.cols() - flickable_wave.arrayChart[i].chartDisplayPointCount)
                                flickable_wave.arrayChart[i].chartStartDataIndex
                                     = waveModel.cols() - flickable_wave.arrayChart[i].chartDisplayPointCount;
                            break;
                        }
                    }
                }

            }
        }

        // 波形列表
        View {
            id: wave

            Layout.fillWidth: true
            Layout.fillHeight: true

            elevation: 1
            backgroundColor: Qt.lighter(Theme.backgroundColor);

            Flickable {
                id: flickable_wave

                clip: true
                visible: true
                anchors.fill: parent

                contentHeight: content.childrenRect.height
//                contentWidth: content.childrenRect.width

                property variant arrayChart: []
                property variant arrayChartInfo: []
                property variant arrayColor: []
                property variant arrayChartValue: []

                Column {
                    id: content
                    spacing: dp(0)

                    Repeater {
                        model: waveModel.chn_count()

                        Row {
                            id: rowChart
                            spacing: dp(3)

                            property color drawColor: root.random_color();

                            View {
                                id: wave_info

                                width: dp(160)
                                height: dp(70)

                                elevation: 2

                                property   int selDataPointIndex: 0

                                backgroundColor: Qt.lighter(drawColor)

                                function updateChartInfo() {
                                    var tmp1 = waveModel.y_data(index)[wave_info.selDataPointIndex];
                                    var fresult = chart_curve.calcLatitudeAndPhase(chart_curve.chartData.datasets[0].data, 80, chart_curve.chartReachedPointIndex);

                                    log("By Click:  Instant = " + tmp1 + ", real = " + fresult[0].toFixed(2));

                                    if (btnValueType.valueType == 1)
                                        tmp1 = fresult[0].toFixed(2);
                                    label_chnn_value.text = tmp1 + " ∠ " + fresult[2].toFixed(2) + "°"
                                }

                                Rectangle {
                                    anchors.fill: parent

                                    border.color: drawColor
                                    color: "transparent"
                                }

                                Column {
                                    anchors.fill: parent

                                    Rectangle {
                                        height: parent.height / 2
                                        width: parent.width

                                        color: "transparent"

                                        View {
                                            visible: false
                                            elevation: 1
                                            height: labelChn.height
                                            width: dp(5)

                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Label {
                                            id: labelChn
                                            text: "通道： " + (index + 1)
                                            color: Theme.light.textColor
                                            anchors.centerIn: parent
                                        }

                                    }

                                    MagicDivider {
                                        width: parent.width

//                                        styleDivider: 2
                                        dash_len: 4
                                        color: drawColor
                                    }

                                    Rectangle {
                                        height: parent.height / 2
                                        width: parent.width

                                        color: "transparent"

                                        Label {
                                            id: label_chnn_value
                                            text: waveModel.y_data(index)[wave_info.selDataPointIndex]
                                                  + " ∠ "
                                                  + waveModel.x_data(index)[wave_info.selDataPointIndex]
                                                  + "0°"
                                            color: Theme.light.textColor
                                            anchors.centerIn: parent
                                        }
                                    }
                                }

                                onSelDataPointIndexChanged: {
                                    updateChartInfo();
                                }
                            }

                            View {
                                id: wave_chart

                                height: wave_info.height
                                width: wave.width - wave_info.width - rowChart.spacing

                                backgroundColor: "#263238"

                                QChart {
                                    id: chart_curve;

                                    anchors.fill: parent

                                    chartAnimated: false;
                                    chartAnimationEasing: Easing.InOutElastic;
                                    chartAnimationDuration: 1000;
                                    chart_index: index
                                    chartDisplayPointCount: gr.maximumValue - gr.minimumValue
                                    chartGrooveColor: gr.color

                                    onChartGroovePosXChanged: {
                                        var tmp1 = waveModel.y_data(index)[wave_info.selDataPointIndex];
                                        var fresult = chart_curve.calcLatitudeAndPhase(chartData.datasets[0].data, 80, chartReachedPointIndex);

                                        log("By Click:  Instant = " + tmp1 + ", real = " + fresult[0].toFixed(2));

                                        if (btnValueType.valueType == 1)
                                            tmp1 = fresult[0].toFixed(2);
                                        label_chnn_value.text = tmp1 + " ∠ " + fresult[2].toFixed(2) + "°"
                                    }

                                    chartDatasetOptions: {
                                        "fillColor": "transparent",
                                        "strokeColor": drawColor,
                                        "pointColor": "rgba(220,220,220,1)",
                                        "pointStrokeColor": "black"
                                    }

                                    chartOptions: {
                                        "pointDot" : false,
                                        "scaleShowLabelsX" : false,
                                        "scaleShowLabelsY" : true,
                                        "scaleShowGridLines" : false,
                                        "fixedLenLabelsY": dp(40)
                                    }

                                    chartType: Charts.ChartType.LINE;

                                    Rectangle {
                                        anchors.fill: parent
                                        border.color: Qt.lighter(drawColor)
                                        color: "transparent"
                                    }
                                }

                                Component.onCompleted: {
//                                    log(wave_chart.width)
                                }
                            }

                            Component.onCompleted: {
                                flickable_wave.arrayChart.push(chart_curve)
                                flickable_wave.arrayChartInfo.push(wave_info)
                                flickable_wave.arrayChartValue.push(label_chnn_value)
                            }

                            Connections {
                                target: chart_curve

                                onSigDrawingCompleted: {
                                    panel_groove.width = dp(160) + x + dp(3);
                                }

                                onSigChartInfoChanged: {
//                                    log("chartGroovePosX = " + chartGroovePosX)
                                    for (var i = 0; i < flickable_wave.arrayChartInfo.length; ++i){
                                        flickable_wave.arrayChartInfo[i].selDataPointIndex =
                                                chartReachedPointIndex + chartStartDataIndex;
                                        flickable_wave.arrayChart[i].chartGroovePosX = chartGroovePosX;
                                        flickable_wave.arrayChart[i].chartStartDataIndex = chartStartDataIndex;
                                        flickable_wave.arrayChartInfo[i].updateChartInfo();
                                    }
                                    if (!gr.lockValueChange)
                                        gr.value = chartGroovePosX + gr.minimumValue


//                                    btnDebug.text = "Count: "
//                                            + chart_curve.chartDisplayPointCount + "/" + waveModel.cols()
//                                            + ", Start = " + flickable_wave.arrayChart[0].chartStartDataIndex
//                                            + ", End = " + (flickable_wave.arrayChart[0].chartStartDataIndex
//                                            + flickable_wave.arrayChart[0].chartDisplayPointCount)
//                                            + ", Select = " + flickable_wave.arrayChartInfo[0].selDataPointIndex


                                }
                            }
                        }
                    }
                }
            }

            Scrollbar {
                flickableItem: flickable_wave
                orientation: Qt.Vertical
            }

            Scrollbar {
                flickableItem: flickable_wave
                orientation: Qt.Horizontal
            }
        }

    }


    Timer {
        id:timer_waveModel;
        repeat: true;
        interval: 3000;
        triggeredOnStart: true;
        onTriggered: {
            log("Wave Data Model has changed again...")
//            waveModel.buildData(10, 100, 20);
            waveModel.queenNewData(5000, 50); // 插入一个新数据， 并删除原队列中第一个数据
            btnDebug.text = waveModel.test + ": " + waveModel.x_data(0)
        }
    }

    Snackbar {
        id: snackbar
    }

    Dialog {
        id: chartSettings
        title: qsTr("Chart Settings")

        positiveButtonText: "Done"

        MagicDivider {


            styleDivider:  1
            dash_len: 3
            color: Theme.accentColor
        }

        Grid {
            columns: 2
            spacing: dp(8)

            CheckBox {
                checked: false
                text: "Show Points: " + flickable_wave.arrayChart.length
                darkBackground: false

                onCheckedChanged: {
                    for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                        flickable_wave.arrayChart[i].chartOptions.pointDot = checked;
                        flickable_wave.arrayChart[i].requestPaint();
                    }
                }
            }

            Item { width: 1; height: 1 }

            CheckBox {
                checked: false
                text: "Show X Labels: " + flickable_wave.arrayChart.length
                darkBackground: false
                onCheckedChanged: {
                    for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                        flickable_wave.arrayChart[i].chartOptions.scaleShowLabelsX = checked;
                        flickable_wave.arrayChart[i].requestPaint();
                    }
                }
            }

            CheckBox {
                checked: false
                text: "Show Y Labels: " + flickable_wave.arrayChart.length
                darkBackground: false
                onCheckedChanged: {
                    for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                        flickable_wave.arrayChart[i].chartOptions.scaleShowLabelsY = checked;
                        flickable_wave.arrayChart[i].requestPaint();
                    }
                }
            }

            CheckBox {
                checked: true
                text: "Show Y Labels: " + flickable_wave.arrayChart.length
                darkBackground: false
                onCheckedChanged: {
                    for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                        flickable_wave.arrayChart[i].chartOptions.scaleShowAxisX = checked;
                        flickable_wave.arrayChart[i].chartOptions.scaleShowAxisY = checked;
                        flickable_wave.arrayChart[i].requestPaint();
                    }
                }
            }

            CheckBox {
                checked: false
                text: "Show Y Labels: " + flickable_wave.arrayChart.length
                darkBackground: false
                onCheckedChanged: {
                    for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                        flickable_wave.arrayChart[i].chartOptions.scaleShowGridLines = checked;
                        flickable_wave.arrayChart[i].requestPaint();
                    }
                }
            }
        }

        MagicDivider {


            styleDivider:  2
            dash_len: 3
            color: Theme.accentColor
        }

        MenuField {
            id: selection
            model: ["Curve Line color", "Point stroke color", "Point fill color", "Grid Line color"]
            width: dp(160)
        }

        Grid {
            columns: 10
            spacing: dp(8)

            Repeater {
                model: [
                    "red", "pink", "purple", "deepPurple", "indigo",
                    "blue", "lightBlue", "cyan", "teal", "green",
                    "lightGreen", "lime", "yellow", "amber", "orange",
                    "deepOrange", "grey", "blueGrey", "brown", "black",
                    "white"
                ]

                Rectangle {
                    width: dp(30)
                    height: dp(30)
                    radius: dp(2)
                    color: Palette.colors[modelData]["500"]
                    border.width: modelData === "white" ? dp(2) : 0
                    border.color: Theme.alpha("#000", 0.26)

                    Ink {
                        anchors.fill: parent

                        onPressed: {
                            switch(selection.selectedIndex) {
                                case 0:
                                    theme.primaryColor = parent.color
                                    break;
                                case 1:
                                    theme.accentColor = parent.color
                                    break;
                                case 2:
                                    theme.backgroundColor = parent.color
                                    break;
                            }
                        }
                    }
                }
            }
        }

        onRejected: {
            // TODO set default colors again but we currently don't know what that is
        }
    }


    Component.onCompleted: {
        log("gr.lockValueChange = " + gr.lockValueChange)
    }    
}
