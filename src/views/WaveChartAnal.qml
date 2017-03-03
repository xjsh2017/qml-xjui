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

    function log(says) {
        console.log("## WaveAnalDemo.qml ##: " + says);
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
                    id: action_search
                    Layout.leftMargin: dp(8)

                    action: Action {
                        iconName: "action/search"
                        name: "Chart : searching"
                        onTriggered: {

                        }
                    }
                }

                IconButton {
                    id: action_timer

                    action: Action {
                        iconName: "action/alarm"
                        name: "Chart : timer for data runtime.."
                        hoverAnimation: true
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
                        }
                    }
                }

                IconButton {
                    id: action_inflate
                    Layout.rightMargin: dp(8)

                    action: Action {
                        iconName: "content/add"
                        name: "Chart : Inflate"
                        onTriggered: {
                            for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                                flickable_wave.arrayChart[i].stepLegend(-1);
                            }
                        }
                    }
                }

                IconButton {
                    id: action_deflate

                    action: Action {
                        iconName: "content/remove"
                        name: "Chart : Deflate"
                        onTriggered: {
                            for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                                flickable_wave.arrayChart[i].stepLegend(1);
                            }
                        }
                    }
                }

                IconButton {
                    id: moveLeft

                    action: Action {
                        iconName: "hardware/keyboard_arrow_left"
                        name: "Chart : Move Left"
                        onTriggered: {
                            for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                                flickable_wave.arrayChart[i].stepChart(-1);
                            }
                        }
                    }
                }

                IconButton {
                    id: moveRight

                    action: Action {
                        iconName: "hardware/keyboard_arrow_right"
                        name: "Chart : Move Right"
                        onTriggered: {
                            for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                                flickable_wave.arrayChart[i].stepChart(1);
                            }
                        }
                    }
                }

                Button {
                    id: btnMouse

                    text: "Mouse: X: " + 0 + ", Y: " + 0
                    implicitHeight: dp(30)
                    elevation: 1
                    activeFocusOnPress: true
                    backgroundColor: Theme.accentColor
                    Layout.alignment: Qt.AlignVCenter

                    onClicked: {
                        actionSheet.visible = !actionSheet.visible
                        //                        actionSheet.open()
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    id: btn_Show
                    text: waveModel.test

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

//            color: "transparent"
            elevation: 1
            height: dp(64)
//            border.color: "black"
//            border.width: dp(1)

            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent

                Rectangle {
                    id: axis_desc

                    border.color: Theme.light.textColor

                    Layout.fillWidth: true
                    Layout.minimumWidth: dp(80)
                    Layout.maximumWidth: dp(160)


                    Label {
                        text: "时间 （ 毫秒 ） / 帧"
                        color: Theme.light.textColor

                        anchors.centerIn: parent
                    }
                }

                // 坐标轴
                Rectangle {
                    id: axis_groove

                    color: "transparent"

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Grover {
                        id: gr
                        anchors.fill: parent

                        value: maximumValue * 0.2
                        focus: true
                        tickmarksEnabled: true
                        numericValueLabel: true
                        stepSize: 10
                        minimumValue: 0
                        maximumValue: 1000
                        activeFocusOnPress: true
                        darkBackground: false//index == 1

                        property bool lockValueChange: false

                        onValueChanged: {
                            var newX = gr.width * value / gr.maximumValue
//                            log(newX)

                            lockValueChange = true;
                            for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                                flickable_wave.arrayChart[i].lastGroverlineX = Math.round(newX);
                                break;
                            }
                            lockValueChange = false;
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

                Column {
                    id: content
                    spacing: dp(3)

                    Repeater {
                        model: waveModel.chn_count()

                        Row {
                            spacing: dp(3)

                            property color drawColor: root.random_color();

                            View {
                                id: wave_info

                                width: dp(160)
                                height: dp(100)

                                property   int selDataPointIndex: 0

                                backgroundColor: Qt.lighter(drawColor)

                                Rectangle {
                                    height: parent.height / 2
                                    width: parent.width
                                    border.color: drawColor

                                    color: "transparent"

                                    Label {
                                        text: "通道： " + (index + 1)
                                        color: Theme.light.textColor
                                        anchors.centerIn: parent
                                    }
                                    clip: true

                                    Rectangle { // 角标
                                        x: parent.width - dp(8)
                                        y: -dp(8)
                                        height: dp(16)
                                        width: height
                                        rotation: 45

                                        color: drawColor

                                    }
                                }

                                Rectangle {
                                    y: parent.height / 2 - dp(1)
                                    height: parent.height / 2
                                    width: parent.width
                                    border.color: drawColor

                                    color: "transparent"

                                    Label {
                                        text: waveModel.x_data(index)[wave_info.selDataPointIndex]
                                              + " ∠ "
                                              + waveModel.y_data(index)[wave_info.selDataPointIndex] + "°"
                                        color: Theme.light.textColor
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            View {
                                id: wave_chart

                                height: wave_info.height
                                width: wave.width - wave_info.width - dp(12)

                                backgroundColor: "#263238"

                                QChart {
                                    id: chart_curve;

                                    anchors.fill: parent

                                    chartAnimated: false;
                                    chartAnimationEasing: Easing.InOutElastic;
                                    chartAnimationDuration: 1000;
                                    chart_index: index
                                    grovelineColor: gr.color

                                    chartDatasetOptions: {
                                        "fillColor": "transparent",
                                        "strokeColor": drawColor,
                                        "pointColor": "rgba(220,220,220,1)",
                                        "pointStrokeColor": "black"
                                    }

                                    chartOptions: {
                                        "pointDot" : true,
                                        "scaleXShowLabels" : true
                                    }

                                    chartType: Charts.ChartType.LINE;

                                    Rectangle {
                                        anchors.fill: parent
                                        border.color: "red"
                                        color: "transparent"
//                                        visible: false
                                    }
                                }

                                Component.onCompleted: {
//                                    log(wave_chart.width)
                                }
                            }

                            Component.onCompleted: {
                                flickable_wave.arrayChart.push(chart_curve)
                                flickable_wave.arrayChartInfo.push(wave_info)
                            }

                            Connections {
                                target: chart_curve

                                onSigChartInfoChanged: {
                                    for (var i = 0; i < flickable_wave.arrayChartInfo.length; ++i){
                                        flickable_wave.arrayChartInfo[i].selDataPointIndex =
                                                reachedChartDataIndex + startChartDataIndex;
                                        flickable_wave.arrayChart[i].lastGroverlineX = groverlineX;
                                        flickable_wave.arrayChart[i].startChartDataIndex = startChartDataIndex;
                                    }

                                    if (!gr.lockValueChange)
                                        gr.value = groverlineX / chart_curve.width * gr.maximumValue
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
        interval: 2000;
        triggeredOnStart: true;
        onTriggered: {
            log("Wave Data Model has changed again...")
//            waveModel.buildData(10, 100, 20);
            waveModel.queenNewData(100, 1); // 插入一个新数据， 并删除原队列中第一个数据
            btn_Show.text = waveModel.test + ": " + waveModel.x_data(0)

            for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                flickable_wave.arrayChart[i].requestPaint();
            }
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
                checked: true
                text: "Show Points"
                darkBackground: index == 1

                onCheckedChanged: {
                    for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                        flickable_wave.arrayChart[i].chartOptions.pointDot = checked;
                        flickable_wave.arrayChart[i].requestPaint();
                    }
                }
            }

            Item { width: 1; height: 1 }

            CheckBox {
                checked: true
                text: "Show X Labels"
                darkBackground: index == 1
            }

            CheckBox {
                checked: true
                text: "Show Y Labels"
                darkBackground: index == 1
            }

            CheckBox {
                checked: true
                text: "Show Axis"
                darkBackground: index == 1
            }

            CheckBox {
                checked: true
                text: "Show Grid Lines"
                darkBackground: index == 1
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
        log("gr.lockValueChange" + gr.lockValueChange)
    }
}
