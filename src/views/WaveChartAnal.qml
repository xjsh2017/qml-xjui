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

    property int wavePannelWidth: dp(160)
    property int wavePannelHeight: dp(60)

    property  real grooveXPlot: 0;
    property   int selectDataIndex: 0

    property int maxCount: 50;

    property var curvelist: new Array(maxCount)
    property var waveViewlist: new Array(maxCount)
    property var wavePanelist: new Array(maxCount)
    property var rowPaneCurvelist: new Array(maxCount)

//    onCurvelistChanged: {
//        log("onCurvelistChanged: curvelist = " + curvelist)
//    }

    // 更新大标尺groove的位置和读数，更新其它波形的刻度线位置
    onGrooveXPlotChanged: {
        log("wca onGrooveXPlotChanged: new grooveXPlot = " + grooveXPlot);

        groove.value = grooveXPlot + groove.minimumValue
        log("setting groove x = " + groove.value);

        // 更新其它波形的grooveXPlot
        log("doing: setting other wave groove line x = " + grooveXPlot);
        for (var i = 0; i < AnalDataModel.getChannelCount(); ++i){
            var curve = wca.curvelist[i];
            if (!curve || curve.grooveXPlot == grooveXPlot || !curve.visible)
                continue;

            curve.grooveXPlot = grooveXPlot;
        }
        log("done!: setting other wave groove line x = " + grooveXPlot);
    }

    // 计算分析新的索引位置
    onSelectDataIndexChanged: {
        log("wca onSelectDataIndexChanged: new selectDataIndex = " + selectDataIndex);

        AnalDataModel.analyzer.curSamplePos = selectDataIndex;
        AnalDataModel.selectDataIndex = selectDataIndex;
        log("AnalDataModel.analyzer.curSamplePos = " + selectDataIndex);

        if (Global.g_plotMode == Global.enSampleMode)
            groove.knobLabel = selectDataIndex;
        log("setting groove label = " + selectDataIndex);

        AnalDataModel.blockAnalSignal();
        log("doing : Calculator.analHarmonic(AnalDataModel)");
        Calculator.analHarmonic(AnalDataModel); // 谐波分析
        log("done! : Calculator.analHarmonic(AnalDataModel)");

        log("doing : Calculator.analRMS(AnalDataModel)");
        Calculator.analRMS(AnalDataModel);  // RMS 计算
        log("done! : Calculator.analRMS(AnalDataModel)");
        log("doing : wca.updatePanels()");
        updatePanels()
        log("done! : wca.updatePanels()");

        AnalDataModel.unblockAnalSignal(true);
    }

    function updatePanels() {
        for (var i = 0; i < AnalDataModel.getChannelCount(); ++i){
            var panel = wca.wavePanelist[i];
//            if (!panel || !panel.visible)
//                continue;

            panel.updatePanel();
        }
    }

    function updatePanelCurveByPropChanged(){
        for (var i = 0; i < AnalDataModel.getChannelCount(); ++i){
            var panel = wca.wavePanelist[i];
            var wave = wca.waveViewlist[i];
            var rowPaneCurve = wca.rowPaneCurvelist[i];

            // visible
            var show = AnalDataModel.getPropValue(i, "visible")
            panel.visible = show;
            wave.visible = show;

            panel.channelInfoText = "通道 " + (i + 1) + "： "
                    + AnalDataModel.getPropValue(i, "name");

            rowPaneCurve.drawColor = (AnalDataModel.getChannelColor(i) ?
                        AnalDataModel.getChannelColor(i) : Theme.backgroundColor);
        }
    }

    function repaintCurves(){
        for (var i = 0; i < AnalDataModel.getChannelCount(); ++i){
            var curve = wca.curvelist[i];
            if (!curve || !curve.visible)
                continue;

            curve.repaint();
        }
    }

    // ////////////////  ///////////////////////////////////////////////

    function log(says) {        console.log("## WaveChartAnal.qml ##: " + says);
    }

    function dp(di){
        return di;
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

                                updatePanels();
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
//                            Layout.leftMargin: dp(8)

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

//                                    for (var i = 0; i < wca.curvelist.length; ++i){
//                                        wca.curvelist[i].startRunningTime(timer_wave.running);
//                                    }
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
                                    var show = AnalDataModel.getPropValue(0, "visible");
                                    AnalDataModel.setPropValue(0, "visible", !show);
                                }
                            }
                        }

                        IconButton {
                            id: chart_refresh

                            action: Action {
                                iconName: "action/autorenew"
                                name: qsTr("Refresh (Ctrl + R)")
                                hoverAnimation: true
                                onTriggered: {
                                    AnalDataModel.syncSample();
                                    repaintCurves();
                                    snackbar.open("All Curves Refreshed !")
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
                        for (var i = 0; i < AnalDataModel.getChannelCount(); ++i){
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
                        model: Math.max(AnalDataModel.getChannelCount(), maxCount)

                        Row {
                            id: rowPanelCurve
                            spacing: dp(2)

                            property color drawColor: AnalDataModel.getChannelColor(modelData) ?
                                                          AnalDataModel.getChannelColor(modelData) : Theme.backgroundColor

                            // 波形图面板
                            View {
                                id: wavePanel

                                elevation: 1

                                width: wca.wavePannelWidth
                                height: wca.wavePannelHeight
                                backgroundColor: Qt.lighter(drawColor)

                                visible: AnalDataModel.isChannelVisible(modelData) === "undefined" ? true
                                                                                                   : AnalDataModel.isChannelVisible(modelData)
                                property alias channelInfoText: labelChn.text

                                function updatePanel(){
                                    var value_rms = AnalDataModel.getPropValue(index, "rms");
                                    var value_angle = AnalDataModel.getPropValue(index, "angle");
                                    var value_instant = AnalDataModel.getYData(index, selectDataIndex).toFixed(2);

                                    if (btnValueType.valueType == 1){
                                        label_chnn_value.text = value_rms + " ∠ " + value_angle + "°"
                                    }else{
                                        label_chnn_value.text = value_instant + " ∠ " + value_angle + "°"
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
                                visible: AnalDataModel.isChannelVisible(modelData) === "undefined" ? true
                                                                                                   : AnalDataModel.isChannelVisible(modelData)

                                WaveChart {
                                    id: curve;

                                    anchors.fill: parent

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



                                    onGrooveXPlotChanged: {
                                        var says = " curve: = " + curve
                                                + ", index = " + index
                                                + ", Event: = onGrooveXPlotChanged";

                                        wca.grooveXPlot = curve.grooveXPlot; // 通知其它波形更新

//                                        console.log(says)
                                    }



                                    onSelectDataIndexChanged: {
                                        if (selectDataIndex < 0 || index >= AnalDataModel.getChannelCount())
                                            return;

                                        var says = " curve: = " + curve
                                                + ", index: = " + index
                                                + ", Event: = onSelectDataIndexChanged";
                                        says += "\n\t new selectDataIndex = " + curve.selectDataIndex;

                                        wca.selectDataIndex = curve.selectDataIndex;
//                                        says += "\n\t set wca.selectDataIndex = " + curve.selectDataIndex;

//                                        console.log(says);
                                    }
                                }

                            }

                            Component.onCompleted: {
//                                console.log("Component.onCompleted: index = " + modelData);
                                wca.curvelist[modelData] = curve;
                                wca.wavePanelist[modelData] = wavePanel;
                                wca.waveViewlist[modelData] = waveView;
                                wca.rowPaneCurvelist[modelData] = rowPanelCurve;
                            }

                            onDrawColorChanged: {
                                curve.repaint();
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
//            wca.repaintCurves();
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

        onAnalyzerChanged: {
            log("Detected AnalDataModel analyzer settings updated !")

        }

        onChannelPropUpdated: {
            log("Detected AnalDataModel channel info updated !")
            wca.updatePanelCurveByPropChanged();
        }

        onSampleChanged: {
            log("Detected AnalDataModel Sample Updtated: "
                + " rows = " + AnalDataModel.getDataRows()
                + ", cols = " + AnalDataModel.getDataCols());
            var sample = AnalDataModel.sample;
            wca.selectDataIndexChanged();
            wca.repaintCurves();
        }
    }

    // ///////////////////////////////////////////////////////////////

    Component.onCompleted: {
        try {
            Theme.primaryColor = "#009688";
            Theme.accentColor = "#ff9800";
            Theme.tabHighlightColor = "white";

            AnalDataModel.sample = Matlab.sampleSin(27, 1601, 0, 16000, -20, 20, 20);
            var sample = AnalDataModel.sample;
//            log("wca.curvelist = " + curvelist);

            selectDataIndexChanged();

            log("Component.onCompleted")
        } catch (error) {
            // Ignore the error; it only means that the fonts were not enabled
        }
    }

    Component.onDestruction: {
        log("Component.onDestruction")
    }
}
