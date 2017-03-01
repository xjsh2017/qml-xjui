import QtQuick 2.4
import Material 0.2
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

import "."

//import "./QChartJS"
//import "./QChartJS/QChartJsTypes.js"  as ChartTypes

//import "./Charts"

import "./QChart"
import "./QChart/QChart.js"         as Charts

Item {
    id: root

    property  string says: "## WaveAnalDemo.qml ##: "

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
                    id: serh
                    Layout.leftMargin: dp(8)

                    iconName: "action/search"

                    property bool showSearch: false

                    MouseArea {
                        anchors.fill: parent
//                        hoverEnabled: true
                    }
                }

                IconButton {
                    id: alarm
//                    Layout.rightMargin: dp(8)

                    iconName: "action/alarm"
//                    focus: true

                    onClicked: {
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
                        console.log(says + varTmpInfo)
                    }
                }

                IconButton {
                    id: add
//                    Layout.rightMargin: dp(8)

                    iconName: "content/add"
//                    focus: true

                    onClicked: {
                        for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                            flickable_wave.arrayChart[i].stepLegend(-1);
                        }
                    }
                }

                IconButton {
                    id: remove
//                    Layout.rightMargin: dp(8)

                    iconName: "content/remove"
//                    focus: true

                    onClicked: {
                        for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                            flickable_wave.arrayChart[i].stepLegend(1);
                        }
                    }
                }

                IconButton {
                    id: moveLeft
//                    Layout.rightMargin: dp(8)

                    iconName: "hardware/keyboard_arrow_left"
//                    focus: true

                    onClicked: {
                        for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                            flickable_wave.arrayChart[i].stepChart(-1);
                        }
                    }
                }

                IconButton {
                    id: moveRight
//                    Layout.rightMargin: dp(8)

                    iconName: "hardware/keyboard_arrow_right"
//                    focus: true

                    onClicked: {
                        for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                            flickable_wave.arrayChart[i].stepChart(1);
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
                    Layout.rightMargin: dp(8)
                    elevation: 1
                    //                    activeFocusOnPress: true
                    backgroundColor: Theme.accentColor
                    //                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.alignment: Qt.AlignVCenter

                    onClicked: snackbar.open("That button is colored!")
                }
            }
        }

        // 波形标尺
        Rectangle {
            id: axis_wave

            color: "transparent"
            height: dp(64)
            border.color: "black"
            border.width: dp(1)

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

                        value: 280
                        focus: true
                        tickmarksEnabled: true
                        numericValueLabel: true
                        stepSize: 10
                        minimumValue: 0
                        maximumValue: 1000
                        activeFocusOnPress: true
                        darkBackground: false//index == 1

                        onValueChanged: {
                            var newX = gr.width * value / gr.maximumValue + axis_groove.x
                            console.log(says + "Grove Calc X = " + newX)
                            grove_line.x = newX
                        }

//                        MouseArea {
//                            anchors.fill: parent
//                            propagateComposedEvents: true

//                            onClicked: {
//                                console.log(says + "Grove: X =" + mouse.x + ", Y = " + mouse.y)
//                                mouse.accepted = false
//                            }
//                        }
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
                                        text: root.random_scalingFactor() + " ∠"+ root.random_scalingFactor() + "°"
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

//                                QChartJs {
//                                    id: chart_curve

//                                    anchors.fill: parent

//                                    chartType: ChartTypes.QChartJSTypes.LINE
//                                    animation: true
//                                    chartAnimationEasing: Easing.InOutElastic;
//                                    chartAnimationDuration: 1000;

//                                    chartData: {
//                                        "labels": waveModel.x_data(index),
//                                        "datasets": [{
//                                                         "data": waveModel.y_data(index),
//                                                         fillColor : "transparent",
//                                                         strokeColor : drawColor,
//                                                         pointColor : "rgba(220,220,220,1)",
//                                                         pointStrokeColor : "#fff",
//                                                         pointHighlightFill : "#fff",
//                                                         pointHighlightStroke : "rgba(220,220,220,1)",
//                                                         "label": 'Dataset 1'
//                                                     }]
//                                    }

//                                    Rectangle {
//                                        anchors.fill: parent
//                                        border.color: "red"
//                                        color: "transparent"
////                                        visible: false
//                                    }
//                                }

//                                Chart{
//                                    id: chart_curve;
//                                    chartType: ChartType.line

//                                    anchors.fill: parent
//                                    onWidthChanged: {
//                                        console.log(says + width);
//                                    }

//                                    function randomScalingFactor() {
//                                        return Math.round(Math.random() * 100);
//                                    }

//                                    chartData: {
//                                        "labels": waveModel.x_data(index),
//                                        "datasets": [{
//                                                         "data": waveModel.y_data(index),
//                                                         "backgroundColor": [
//                                                             "#F7464A",
//                                                             "#46BFBD",
//                                                             "#FDB45C",
//                                                             "#949FB1",
//                                                             "#4D5360",
//                                                         ],
//                                                         "label": 'Da[aset 1'
//                                                     }]
//                                    }

//                                    Rectangle {
//                                        anchors.fill: parent
//                                        border.color: "red"
//                                        color: "transparent"
////                                        visible: false
//                                    }
//                                }

                                QChart {
                                    id: chart_curve;

                                    anchors.fill: parent

                                    chartAnimated: false;
                                    chartAnimationEasing: Easing.InOutElastic;
                                    chartAnimationDuration: 1000;
                                    chart_index: index

                                    chartWholeData: {
                                        "labels": waveModel.x_data(index),
                                        "datasets": [{
                                                         "fillColor": "transparent",
                                                         "strokeColor": drawColor,
                                                         "pointColor": "rgba(220,220,220,1)",
                                                         "pointStrokeColor": "black",
                                                         "data": waveModel.y_data(index)
                                                     }
                                        ]
                                    }

//                                    chartData: {
//                                        "labels": waveModel.x_data(index),
//                                        "datasets": [{
//                                                         "fillColor": "transparent",
//                                                         "strokeColor": drawColor,
//                                                         "pointColor": "rgba(220,220,220,1)",
//                                                         "pointStrokeColor": "black",
//                                                         "data": waveModel.y_data(index)
//                                                     }
//                                        ]
//                                    }

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
//                                    console.log(says + wave_chart.width)
                                }
                            }

                            Component.onCompleted: {
                                flickable_wave.arrayChart.push(chart_curve)
                            }

                            Connections {
                                target: chart_curve
                                onMousePositionChanged: {
                                    console.log(says + "Chart Mouse: X: " + x + ", Y: " + y)
                                    btnMouse.text = "Mouse: X: " + x + ", Y: " + y
                                    grove_line.x = x + wave_chart.x;
                                    gr.value = x / chart_curve.width * gr.maximumValue

                                    console.log(says + "Grove Value: " + gr.value)
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

            Rectangle {
                id: grove_line
                width: dp(1)
                height: flickable_wave.contentHeight

                x: 0

                Behavior on x {
                    NumberAnimation { duration: 100 }
                    enabled: true
                }

                color: "red"
            }
        }

    }


    Timer {
        id:timer_waveModel;
        repeat: true;
        interval: 2000;
        triggeredOnStart: true;
        onTriggered: {
            console.log(says + "Wave Data Model has changed again...")
//            waveModel.buildData(10, 100, 20);
            waveModel.queenNewData(100, 1); // 插入一个新数据， 并删除原队列中第一个数据
            btn_Show.text = waveModel.test + ": " + waveModel.x_data(0)

            for (var i = 0; i < flickable_wave.arrayChart.length; ++i){
                flickable_wave.arrayChart[i].chartData.labels = waveModel.x_data(i);
                flickable_wave.arrayChart[i].chartData.datasets[0].data = waveModel.y_data(i)
                flickable_wave.arrayChart[i].requestPaint();
            }
        }
    }

    Snackbar {
        id: snackbar
    }

    Component.onCompleted: {
//        timer_waveModel.start();
    }
}
