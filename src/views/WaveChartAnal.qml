import QtQuick 2.4
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

import Material 0.2

//import XjUi 1.0
import "../components/WaveChart"
import "../components/Grover"
import "../core"

Item {
    id: wca

    // ///////////////////////////////////////////////////////////////

    property int selectDataIndex: 0
    property int wavePannelWidth: dp(160)
    property int wavePannelHeight: dp(60)

    property variant curvelist: []
    property variant waveViewlist: []
    property variant wavePanelist: []


    // ///////////////////////////////////////////////////////////////

    function log(says) {
        console.log("## WaveChartAnal.qml ##: " + says);
    }

    function dp(di){
        return di;
    }

    function updatePanelCurves(type){
        for (var i = 0; i < AnalDataModel.getChannelCount(); i++){
            if (type == 0)
                wca.wavePanelist[i].updatePanel();
            else if (type == 1)
                wca.curvelist[i].updateCurve();
            else{
                wca.wavePanelist[i].updatePanel();
                wca.curvelist[i].updateCurve();
            }
        }
    }

    function repaintAllCurves(){
        for (var i = 0; i < wca.wavePanelist.length; ++i){
            wca.curvelist[i].plotHandler = 0;
            wca.curvelist[i].requestPaint();
        }
    }

    // ///////////////////////////////////////////////////////////////

    ColumnLayout {
        id: rootLayout

        anchors {
            fill: parent
            margins: dp(0)
        }
        spacing: dp(3)

        // 波形标尺
        View {
            id: grooveView

            elevation: 1
            height: dp(65)

            Layout.fillWidth: true

            Row {
                width: parent.width
                height: parent.height

                spacing: dp(0)

                View {
                    id: groovePannel
                    width: dp(160)
                    height: parent.height

                    elevation: 3

                    // 面板工具
                    Flow {
                        id: chart_info_title_panel
                        width: parent.width
                        height: parent.height

                        anchors {
                            left: parent.left
                            leftMargin: dp(8)
                            top: parent.top
                            topMargin: dp(5)
                        }
                        spacing: dp(6)

                        IconButton {
                            id: action_inflate

                            action: Action {
                                iconName: "action/inflate"
                                name: "Inflate View"
                                onTriggered: {
                                    if (Global.g_plotMode == Global.enSampleMode)
                                        Global.g_sampleRate +=0.5;
                                }
                            }
                        }

                        IconButton {
                            id: action_inflate_default

                            action: Action {
                                iconName: "action/inflate_default"
                                name: "Default View"
                                onTriggered: {
                                    if (Global.g_plotMode == Global.enSampleMode)
                                        Global.g_sampleRate = Global.g_DefaultSampleRate;
                                }
                            }
                        }

                        IconButton {
                            id: action_deflate

                            action: Action {
                                iconName: "action/deflate"
                                name: "Deflate View"
                                onTriggered: {
                                    if (Global.g_plotMode == Global.enSampleMode && Global.g_sampleRate > 1)
                                        Global.g_sampleRate -= 0.5;
                                }
                            }
                        }

                        IconButton {
                            id: action_left_end

                            action: Action {
                                iconName: "action/scroll_leftend"
                                name: "To Left End"
                                onTriggered: {
                                    if (Global.g_plotMode == Global.enSampleMode)
                                        groove.scroller.move(-999999 * Global.g_sampleRate);
                                }
                            }
                        }

                        IconButton {
                            id: action_left

                            action: Action {
                                iconName: "navigation/chevron_left"
                                name: "Left Move"
                                onTriggered: {
                                    if (Global.g_plotMode == Global.enSampleMode)
                                        groove.scroller.move(-1 * Global.g_sampleRate);
//                                    }
                                }
                            }
                        }

                        IconButton {
                            id: action_right

                            action: Action {
                                iconName: "navigation/chevron_right"
                                name: "Right Move"
                                onTriggered: {
                                    if (Global.g_plotMode == Global.enSampleMode)
                                        groove.scroller.move(1 * Global.g_sampleRate);
//                                    }
                                }
                            }
                        }

                        IconButton {
                            id: action_right_end

                            action: Action {
                                iconName: "action/scroll_rightend"
                                name: "Right End"
                                onTriggered: {
                                    if (Global.g_plotMode == Global.enSampleMode)
                                        groove.scroller.move(999999 * Global.g_sampleRate);
//                                    }
                                }
                            }
                        }

                        Item {
                            width: dp(20)
                        }

                        Button {
                            id: btnValueType

                            property int valueType: 0   // 0 - 瞬时值， 1 - 有效值

                            implicitHeight: dp(22)
                            implicitWidth: dp(22)
                            elevation: 1
                            backgroundColor: Theme.accentColor
                            Layout.alignment: Qt.AlignVCenter

                            Label {
                                id: label_btn_value_type
                                anchors.centerIn: parent
                                text: qsTr("瞬")
                                color: "white"

                                font {
                                    family: "微软雅黑"
                                    weight: Font.Light
                                    pixelSize: dp(13)
                                }
                            }

                            onClicked: {
                                if (valueType == 1){
                                    label_btn_value_type.text = qsTr("瞬");
                                    valueType = 0;
                                    backgroundColor = Theme.accentColor
                                }else{
                                    label_btn_value_type.text = qsTr("有")
                                    valueType = 1;
                                    backgroundColor = "green"
                                }

                                updatePanelCurves(0);
                            }
                        }

                        Button {
                            id: btnGrooveMode

                            implicitHeight: dp(22)
                            implicitWidth: dp(22)
                            elevation: 1
                            backgroundColor: Theme.accentColor
                            Layout.alignment: Qt.AlignVCenter

                            Label {
                                id: label_GrooveMode
                                anchors.centerIn: parent
                                text: qsTr("采")
                                color: "white"

                                font {
                                    family: "微软雅黑"
                                    weight: Font.Light
                                    pixelSize: dp(13)
                                }
                            }

                            onClicked: {
                                if (Global.g_plotMode == Global.enTimeMode){
                                    label_GrooveMode.text = qsTr("采");
                                    Global.g_plotMode = Global.enSampleMode;
                                    backgroundColor = Global.g_sampleModeColor
                                }else{
                                    label_GrooveMode.text = qsTr("时")
                                    Global.g_plotMode = Global.enTimeMode;
                                    backgroundColor = Global.g_timeModeColor
                                }
                            }
                        }

                        IconButton {
                            id: runInRealTime
                            Layout.leftMargin: dp(8)

                            action: Action {
                                iconName: "action/alarm"
                                name: "Go to Running Time Mode"

                                onTriggered: {
                                    var varTmpInfo;
                                    if (timer_wave.running)
                                    {
                                        timer_wave.stop();
                                        varTmpInfo = " Timer for Changing Wave Data Model is stopped  !";
                                    }else
                                    {
                                        timer_wave.start();
                                        varTmpInfo = " Timer for Changing Wave Data Model is running  !";
                                    }
                                    snackbar.open(varTmpInfo)
                                    log(varTmpInfo)

                                    for (var i = 0; i < wca.curvelist.length; ++i){
                                        wca.curvelist[i].startRunningTime(timer_wave.running);
                                    }
                                }
                            }
                        }

                        IconButton {
                            id: chart_setting

                            action: Action {
                                iconName: "action/setting"
                                name: qsTr("Chart Settings (Ctrl + I)")
                                hoverAnimation: true
                                onTriggered: {
                                    chartSettings.show()
                                }
                            }
                        }

                        IconButton {
                            id: chart_refresh

                            action: Action {
                                iconName: "navigation/refresh"
                                name: qsTr("Refresh (Ctrl + R)")
                                hoverAnimation: true
                                onTriggered: {
                                    waveModel.sync();
                                    repaintAllCurves();
                                    snackbar.open("All Charts Refreshed !")
                                }
                            }
                        }
                    }
                }

                // 大标尺
                Groove {
                    id: groove

                    height: parent.height
                    width: parent.width - groovePannel.width

                    value: maximumValue * 0
                    minimumValue: 0
                    maximumValue: parent.width + minimumValue - groove.anchors.leftMargin  // 刻度尺的长度

                    focus: true
                    tickmarksEnabled: true
                    numericValueLabel: true
                    activeFocusOnPress: true
                    darkBackground: false
                    samplecount: AnalDataModel.getDataCols() ? AnalDataModel.getDataCols() : 0;

                    onScrollbarPosChanged : {
                        var deltaStartDataIndex = delta / Global.g_sampleRate;
                        for (var i = 0; i < wca.curvelist.length; ++i){
                            wca.curvelist[i].startDataIndex +=
                                    (delta ? 1 : -1) * deltaStartDataIndex;
                        }
                    }
                }

            }
        }

        // 波形列表
        View {
            id: waveFrameView

            Layout.fillWidth: true
            Layout.fillHeight: true

            backgroundColor: Theme.backgroundColor;

            elevation: 1

            Flickable {
                id: flickable_wave

                anchors.fill: parent
                clip: true

                contentHeight: content.childrenRect.height

                Column {
                    id: content

                    spacing: dp(0)

                    Repeater {
                        model: Math.max(AnalDataModel.getChannelCount(), 40)

                        Row {
                            spacing: dp(2)

                            property color drawColor: AnalDataModel.getChannelColor(index) ?
                                                          AnalDataModel.getChannelColor(index) : Theme.backgroundColor

                            // 波形图面板
                            View {
                                id: wavePanel

                                elevation: 1

                                width: wca.wavePannelWidth
                                height: wca.wavePannelHeight
                                backgroundColor: Qt.lighter(drawColor)

                                visible: AnalDataModel.isChannelVisible(modelData)

                                function updatePanel() {
                                    visible = AnalDataModel.isChannelVisible(index);

////                                    Calculator.analHarmonic(AnalDataModel, index); // 谐波分析

                                    var tmp = AnalDataModel.getYData(index);
                                    if (tmp){
                                        var fresult = Calculator.calcRMS(tmp, curve.selectDataIndex
                                                                         , AnalDataModel.analyzer.periodSampleCount);
                                        tmp = AnalDataModel.sample.y[index][curve.selectDataIndex].toFixed(2);
                                        if (btnValueType.valueType == 1){
                                            tmp = (fresult ? fresult.RMS.toFixed(2) : "#");
                                        }
                                        label_chnn_value.text = tmp + " ∠ " + (fresult ? fresult.angle.toFixed(2) : "#") + "°"

                                        AnalDataModel.setPropValue(index, "rms", (fresult ? fresult.RMS.toFixed(2) : ""));
                                        AnalDataModel.setPropValue(index, "angle", (fresult ? fresult.angle.toFixed(2) : ""))
                                    }
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

                                        Label {
                                            id: labelChn

                                            text: "通道 " + (index + 1) + "： "
                                                  + AnalDataModel.getPropValue(index, "name")
                                            color: Theme.light.textColor
                                            anchors.centerIn: parent

                                            font {
                                                family: "微软雅黑"
                                                weight: Font.Light
                                                pixelSize: dp(12)
                                            }
                                        }

                                    }

                                    MagicDivider {
                                        width: parent.width
                                        dash_len: 4
                                        color: drawColor
                                    }

                                    Rectangle {
                                        height: parent.height / 2
                                        width: parent.width

                                        color: "transparent"

                                        Label {
                                            id: label_chnn_value
                                            text: "# ∠ #°"
                                            color: Theme.light.textColor
                                            anchors.centerIn: parent
                                        }
                                    }
                                }
                            }

                            View {
                                id: waveView

                                height: wavePanel.height
                                width: waveFrameView.width - wavePanel.width - parent.spacing

                                backgroundColor: Global.g_plotBackgroundColor
                                visible: AnalDataModel.isChannelVisible(modelData)

                                WaveChart {
                                    id: curve;

                                    anchors.fill: parent
                                    visible: AnalDataModel.isChannelVisible(modelData)

                                    chartAnimated: false;
                                    chartAnimationEasing: Easing.InOutElastic;
                                    chartAnimationDuration: 1000;

//                                    model: wca.model
                                    index: modelData
                                    grooveColor: Global.g_modeColor

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

                                    Rectangle {
                                        anchors.fill: parent
                                        border.color: Qt.lighter(drawColor)
                                        color: "transparent"
                                    }

                                    onSigDrawingCompleted: {
                                        groovePannel.width = wca.wavePannelWidth + x;
                                    }



                                    onSelectDataIndexChanged: {
                                        AnalDataModel.analyzer.curSamplePos = selectDataIndex;
                                        if (selectDataIndex < 0)
                                            return;

                                        if (visible)
                                            wavePanel.updatePanel();
                                        groove.value = curve.grooveXPlot + groove.minimumValue
                                        if (plotMode == Global.enSampleMode)
                                            groove.knobLabel = selectDataIndex;
                                    }
                                }

                            }

                            Connections {
                                target: curve

                                onGrooveXPlotChanged: {
                                    console.log("wca.curvelist.length = " + wca.curvelist.length)
                                    for (var i = 0; i < AnalDataModel.getChannelCount(); ++i){
                                        if (wca.curvelist[i] == curve)
                                            continue;
                                        if (curve.grooveXPlot == wca.curvelist[i].grooveXPlot)
                                            continue;

                                        console.log("wca.curvelist[" + i + "].grooveXPlot = "
                                                    + wca.curvelist[i].grooveXPlot)

                                        wca.curvelist[i].grooveXPlot = curve.grooveXPlot;
                                    }
                                    console.log(curve);
                                    groove.value = curve.grooveXPlot + groove.minimumValue
                                    if (curve.plotMode == Global.enSampleMode)
                                        groove.knobLabel = curve.selectDataIndex;
                                }
                            }

                            Component.onCompleted: {
                                wca.curvelist[index] = curve;
                                wca.wavePanelist[index] = wavePanel;
                                wca.waveViewlist[index] = waveView
                            }
                        }
                    }
                }
            }

            Scrollbar {
                flickableItem: flickable_wave
                orientation: Qt.Vertical
            }
        }

    }


    Timer {
        id:timer_wave;
        repeat: true;
        interval: 3000;
        triggeredOnStart: true;
        onTriggered: {
            log("Detected: Anal Run-time Sample Data changed again...")
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
                text: "Show Points: " + wca.curvelist.length
                darkBackground: false

                onCheckedChanged: {
                    for (var i = 0; i < wca.curvelist.length; ++i){
                        wca.curvelist[i].chartOptions.pointDot = checked;
                        wca.curvelist[i].requestPaint();
                    }
                }
            }

            Item { width: 1; height: 1 }

            CheckBox {
                checked: false
                text: "Show X Labels: " + wca.curvelist.length
                darkBackground: false
                onCheckedChanged: {
                    for (var i = 0; i < wca.curvelist.length; ++i){
                        wca.curvelist[i].chartOptions.scaleShowLabelsX = checked;
                        wca.curvelist[i].requestPaint();
                    }
                }
            }

            CheckBox {
                checked: false
                text: "Show Y Labels: " + wca.curvelist.length
                darkBackground: false
                onCheckedChanged: {
                    for (var i = 0; i < wca.curvelist.length; ++i){
                        wca.curvelist[i].chartOptions.scaleShowLabelsY = checked;
                        wca.curvelist[i].requestPaint();
                    }
                }
            }

            CheckBox {
                checked: true
                text: "Show Y Labels: " + wca.curvelist.length
                darkBackground: false
                onCheckedChanged: {
                    for (var i = 0; i < wca.curvelist.length; ++i){
                        wca.curvelist[i].chartOptions.scaleShowAxisX = checked;
                        wca.curvelist[i].chartOptions.scaleShowAxisY = checked;
                        wca.curvelist[i].requestPaint();
                    }
                }
            }

            CheckBox {
                checked: false
                text: "Show Y Labels: " + wca.curvelist.length
                darkBackground: false
                onCheckedChanged: {
                    for (var i = 0; i < wca.curvelist.length; ++i){
                        wca.curvelist[i].chartOptions.scaleShowGridLines = checked;
                        wca.curvelist[i].requestPaint();
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



    // ///////////////////////////////////////////////////////////////

    Connections {
        target: AnalDataModel

        onChannelsChanged:{
            log("AnalDataModel --> onChannelsChanged")
        }

        onSampleChanged: {
            log("AnalDataModel --> onSampleChanged: "
                + "\n\t rows = " + AnalDataModel.sample.rows()
                + "\n\t cols = " + AnalDataModel.sample.cols());
        }

        onAnalyzerChanged: {
            log("AnalDataModel --> onAnalyzerChanged")

        }
    }

    Connections {
        target: waveModel

        onModelDataChanged: {
            console.log("Detect waveModel data changed outside!")

//            AnalDataModel.updateModelFromInternalDataAPI(waveModel)
        }
    }

    // ///////////////////////////////////////////////////////////////

    Component.onCompleted: {
        Calculator.model = AnalDataModel

        AnalDataModel.sample = Matlab.sampleSin(27, 1601, 0, 16000, -20, 20, 20);
        var sample = AnalDataModel.sample;

        Theme.primaryColor = "#00bcd4";
        Theme.accentColor = "#ff9800";
        Theme.tabHighlightColor = "white";

        var harmon = AnalDataModel.getPropValue(1, "harmonic");
        log(Matlab.isArray(harmon))

        var test = {
            n: 1,
            real: 20.5,
            img: -31.8,
            amp: 28.99,
            angle: 35.6,
            percentage: 0.125
        }
        log("AnalDataModel.isHarmonValueValid(test) = " + AnalDataModel.isHarmonValueValid(test));

        log("wca.curvelist = " + wca.curvelist);
    }

    Component.onDestruction: {
        log("Component.onDestruction")
    }
}
