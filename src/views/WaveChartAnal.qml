import QtQuick 2.4
import Material 0.2
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

import "."
import "../core"
import "../components/Grover"
import "../components/WaveChart"

Item {
    id: root

    // ///////////////////////////////////////////////////////////////

    property var model: {
//                          "data": Matlab.sampleSin(10, 100001, 0, 16000, -20, 20, 1250),
                          "data": Matlab.sampleSin(1, 16001, 0, 16000, -20, 20, 200),
//                          "data": Matlab.sampleSin(1, 1001, 0, 500, -20, 20, 10),

                          "name": ["通道延时"
                                   , "保护A相电流1", "保护A相电流2"
                                   , "保护B相电流1", "保护B相电流2"
                                   , "保护C相电流1", "保护C相电流2"
                                   , "计量A相电流", "计量B相电流", "计量C相电流"
                                   , "零序电流I01", "零序电流I02"
                                   , "间隙电流Ij1", "间隙电流Ij2"
                                   , "保护A相电压1", "保护A相电压2"
                                   , "B相电压采样值1", "B相电压采样值2"
                                   , "C相电压采样值1", "C相电压采样值2"
                                   , "线路抽取电压1", "线路抽取电压2"
                                   , "零序电压1", "零序电压2"
                                   , "计量A相电压", "计量B相电压", "计量C相电压"],
                          "unit": [""
                                   , "A", "A"
                                   , "A", "A"
                                   , "A", "A"
                                   , "A", "A", "A"
                                   , "A", "A"
                                   , "A", "A"
                                   , "V", "V"
                                   , "V", "V"
                                   , "V", "V"
                                   , "V", "V"
                                   , "V", "V"
                                   , "V", "V", "V"],
                          "phase": [""
                                    , "A", "A"
                                    , "B", "B"
                                    , "C", "C"
                                    , "A", "B", "C"
                                    , "N", "N"
                                    , "", ""
                                    , "A", "A"
                                    , "B", "B"
                                    , "C", "C"
                                    , "", ""
                                    , "N", "N"
                                    , "A", "B", "C"],
                          rms: [""],
                          angle: [""]
    }

    property int selectDataIndex: 0
    property int wavePannelWidth: dp(160)
    property int wavePannelHeight: dp(80)

    property variant curvelist: []
    property variant wavePanelist: []

    onModelChanged: {
        log("WaveChartAnal Model Changed!")
    }

    // ///////////////////////////////////////////////////////////////

    function log(says) {
        console.log("## WaveChartAnal.qml ##: " + says);
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
//                            topMargin: height / 2 - action_inflate.height / 2//dp(10)
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
//                                    for (var i = 0; i < root.curvelist.length; ++i){
//                                        root.curvelist[i].stepChart(-19999);
//                                        log(root.curvelist[i].startDataIndex)
//                                    }
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
//                                    for (var i = 0; i < root.curvelist.length; ++i){
//                                        root.curvelist[i].stepChart(-1);
//                                        log(root.curvelist[i].startDataIndex)
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
//                                    groove.scrollbarLoader.item.x_move_delta = 1 * Global.g_sampleRate
//                                    console.log("groove.scrollbarLoader.item.x_move_delta = " + groove.scrollbarLoader.item.x_move_delta)
//                                    for (var i = 0; i < root.curvelist.length; ++i){
//                                        root.curvelist[i].stepChart(1);
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
//                                    for (var i = 0; i < root.curvelist.length; ++i){
//                                        root.curvelist[i].stepChart(19999);
//                                        log(root.curvelist[i].startDataIndex)
//                                    }
                                }
                            }
                        }

                        Item {
                            width: dp(20)
                        }

                        Button {
                            id: btnValueType
                            text: qsTr("瞬")

                            property int valueType: 0   // 0 - 瞬时值， 1 - 有效值

                            implicitHeight: dp(22)
                            implicitWidth: dp(22)
                            elevation: 1
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

                                for (var i in root.wavePanelist){
                                    root.wavePanelist[i].updateWavePanel();
                                }

                            }
                        }

                        Button {
                            id: btnGrooveMode
                            text: qsTr("采")

                            implicitHeight: dp(22)
                            implicitWidth: dp(22)
                            elevation: 1
                            backgroundColor: Theme.accentColor
                            Layout.alignment: Qt.AlignVCenter

                            onClicked: {
                                if (Global.g_plotMode == Global.enTimeMode){
                                    text = qsTr("采");
                                    Global.g_plotMode = Global.enSampleMode;
                                    backgroundColor = Global.g_sampleModeColor
                                }else{
                                    text = qsTr("时")
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

                                    for (var i = 0; i < root.curvelist.length; ++i){
                                        root.curvelist[i].startRunningTime(timer_waveModel.running);
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
                                    for (var i = 0; i < root.wavePanelist.length; ++i){
                                        root.curvelist[i].plotHandler = null;
                                        root.curvelist[i].requestPaint();
                                    }
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
//                    stepSize: dp(10)    // 10个像素绘制一个小刻度， 50个像素绘制一个中刻度， 100个像素绘制一个大刻度

                    focus: true
                    tickmarksEnabled: true
                    numericValueLabel: true
                    activeFocusOnPress: true
                    darkBackground: false
                    samplecount: root.model.data.cols;

                    onValueChanged: {
                        root.log("groove.width = " + groove.width)
                    }

                    onScrollbarPosChanged : {
//                        root.log(" Scroll bar : "
//                                 + "\n\t pos: x = " + xLastPos
//                                 + "\n\t pos: x = " + xPos
//                                 + "\n\t deltaX = " + deltaX
//                                 + "\n\t move delta = " + delta
//                                 + "\n\t move velocity = " + velocity
//                                 + "\n\t move data count = " + (delta / Global.g_sampleRate).toFixed(3)
//                                 + "\n\t all move data count = " + (velocity * xPos / Global.g_sampleRate)
//                                 + "\n\t groove.width = " + groove.width
//                                 + "\n\t sample count = " + root.model.data.cols
//                                 + "\n");

                        var deltaStartDataIndex = delta / Global.g_sampleRate;

                        for (var i = 0; i < root.curvelist.length; ++i){
                            root.curvelist[i].startDataIndex +=
                                    (delta ? 1 : -1) * deltaStartDataIndex;
                        }
                    }
                }

            }
        }

        // 波形列表
        View {
            id: waveView

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
                        model: root.model.data.rows

                        Row {
                            spacing: dp(2)

                            property color drawColor: Global.phaseTypeColor(root.model.phase[index]);

                            // 波形图面板
                            View {
                                id: wavePanel

                                elevation: 1

                                width: root.wavePannelWidth
                                height: root.wavePannelHeight
                                backgroundColor: Qt.lighter(drawColor)

                                function updateWavePanel() {
                                    var tmp = root.model.data.y_row(index).data;

                                    var fresult = Calculator.calcRMS(tmp, curve.selectDataIndex, 80);
                                    tmp = root.model.data.y_row(index).data[curve.selectDataIndex];
                                    if (btnValueType.valueType == 1){
                                        tmp = (fresult ? fresult.RMS.toFixed(2) : "#");
                                    }

                                    label_chnn_value.text = tmp + " ∠ " + (fresult ? fresult.phase.toFixed(2) : "#") + "°"

                                    root.model.rms[index] = (fresult ? fresult.RMS.toFixed(2) : "#");
                                    root.model.angle[index] = (fresult ? fresult.phase.toFixed(2) : "#");

                                    root.modelChanged()
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
                                            text: "通道 " + (index + 1) + "： " + root.model.name[index]
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
                                id: waveChartView

                                height: wavePanel.height
                                width: waveView.width - wavePanel.width - parent.spacing

                                backgroundColor: "#263238"

                                WaveChart {
                                    id: curve;

                                    anchors.fill: parent

                                    chartAnimated: false;
                                    chartAnimationEasing: Easing.InOutElastic;
                                    chartAnimationDuration: 1000;

                                    model: root.model
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
                                        groovePannel.width = root.wavePannelWidth + x;
                                    }

                                    onGrooveXPlotChanged: {
                                        for (var i = 0; i < root.curvelist.length; ++i){
                                            if (root.curvelist[i] == curve)
                                                continue;
                                            if (curve.grooveXPlot == root.curvelist[i].grooveXPlot)
                                                continue;

                                            root.curvelist[i].grooveXPlot = curve.grooveXPlot; // grooveXPlot在内部已经更改自己的selectDataIndex

//                                            console.log(root.curvelist[i]);
                                        }
                                        console.log(curve);
                                        groove.value = curve.grooveXPlot + groove.minimumValue
                                        if (plotMode == Global.enSampleMode)
                                            groove.knobLabel = selectDataIndex;
                                    }

                                    onSelectDataIndexChanged: {
                                        root.log("Event: onSelectDataIndexChanged --> index = " + index + ", select data index = " + selectDataIndex
                                                 + ", curve.grooveXPlot = " + curve.grooveXPlot)
                                        wavePanel.updateWavePanel();
                                        groove.value = curve.grooveXPlot + groove.minimumValue
                                        if (plotMode == Global.enSampleMode)
                                            groove.knobLabel = selectDataIndex;
                                    }
                                }

                            }

                            Component.onCompleted: {
                                root.curvelist.push(curve)
                                root.wavePanelist.push(wavePanel)
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
                text: "Show Points: " + root.curvelist.length
                darkBackground: false

                onCheckedChanged: {
                    for (var i = 0; i < root.curvelist.length; ++i){
                        root.curvelist[i].chartOptions.pointDot = checked;
                        root.curvelist[i].requestPaint();
                    }
                }
            }

            Item { width: 1; height: 1 }

            CheckBox {
                checked: false
                text: "Show X Labels: " + root.curvelist.length
                darkBackground: false
                onCheckedChanged: {
                    for (var i = 0; i < root.curvelist.length; ++i){
                        root.curvelist[i].chartOptions.scaleShowLabelsX = checked;
                        root.curvelist[i].requestPaint();
                    }
                }
            }

            CheckBox {
                checked: false
                text: "Show Y Labels: " + root.curvelist.length
                darkBackground: false
                onCheckedChanged: {
                    for (var i = 0; i < root.curvelist.length; ++i){
                        root.curvelist[i].chartOptions.scaleShowLabelsY = checked;
                        root.curvelist[i].requestPaint();
                    }
                }
            }

            CheckBox {
                checked: true
                text: "Show Y Labels: " + root.curvelist.length
                darkBackground: false
                onCheckedChanged: {
                    for (var i = 0; i < root.curvelist.length; ++i){
                        root.curvelist[i].chartOptions.scaleShowAxisX = checked;
                        root.curvelist[i].chartOptions.scaleShowAxisY = checked;
                        root.curvelist[i].requestPaint();
                    }
                }
            }

            CheckBox {
                checked: false
                text: "Show Y Labels: " + root.curvelist.length
                darkBackground: false
                onCheckedChanged: {
                    for (var i = 0; i < root.curvelist.length; ++i){
                        root.curvelist[i].chartOptions.scaleShowGridLines = checked;
                        root.curvelist[i].requestPaint();
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


    function updateModel() {
        waveModel.cols();
        var Rows = waveModel.rows();
        var Cols = waveModel.cols();
        model.y = Matlab.matrix(Rows, Cols);
        for (var i = 0; i < Rows; i ++){
            model.y.data[i] = waveModel.y_data(i);
        }

        return 0;
    }

    Component.onCompleted: {
//        updateModel();
//        model.x.print();
//        model.y.print();

//        var tmp = Matlab.matrix(2, 5, 1);
//        tmp.print();
//        tmp.y_row(1).print();
    }
}
