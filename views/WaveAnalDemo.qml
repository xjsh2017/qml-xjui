import QtQuick 2.4
import Material 0.2
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

import "./QChart"
import "./QChart/QChart.js"         as Charts
//import "./QChart/QChartGallery.js"  as ChartsData

Item {
    id: me

    function dp(di){
        return di;
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
            height: dp(36)

            elevation: dp(2)
            Layout.fillWidth: true
//            backgroundColor: Theme.backgroundColor

            clip:false

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                        GradientStop { position: 0.0; color: "white" }
                        GradientStop { position: 0.73; color: "lightgrey" }
                        GradientStop { position: 1.0; color: "lightgrey" }
                    }
            }

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

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }

                IconButton {
                    id: add
//                    Layout.rightMargin: dp(8)

                    iconName: "content/add"
//                    focus: true

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }

                IconButton {
                    id: remove
//                    Layout.rightMargin: dp(8)

                    iconName: "content/remove"
//                    focus: true

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }

                Button {
                    id: addCimDev

                    visible: false
                    text: "+ Button1"
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
                    text: waveModel.test// + ": " + waveModel.chn_count()

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

        // 坐标轴
        Rectangle {
            id: axis

            color: "transparent"
            height: dp(64)
            border.color: "black"
            border.width: dp(1)

            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent

                Rectangle {
                    id: axisLabel
                    Layout.fillWidth: true
                    Layout.minimumWidth: dp(80)
                    Layout.maximumWidth: dp(160)
                    border.color: Theme.light.textColor


                    Label {
                        text: "时间 （ 毫秒 ） / 帧"
                        color: Theme.light.textColor
                        anchors.centerIn: parent
                    }
                }

                // 坐标轴
                Rectangle {
                    id: axisGroove
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    color: "transparent"

                    Grover {
                        id: gr
                        anchors.fill: parent

                        value: 280
                        focus: true
                        tickmarksEnabled: true
                        numericValueLabel: true
                        stepSize: 20
                        minimumValue: 0
                        maximumValue: 1000
                        activeFocusOnPress: true
                        darkBackground: false//index == 1

                        onValueChanged: {
                            //console.log(value * gr.width / gr.maximumValue)
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
            //        backgroundColor: Qt.rgba(0,0, 0, 0.8);

            function randomScalingFactor() {
                return Math.round(Math.random() * 100);
            }

            Flickable {
                id: flickable
                anchors.fill: parent
                contentHeight: content.childrenRect.height
                contentWidth: content.childrenRect.width
                clip: true
                visible: true

                Column {
                    id: content
//                    width: parent.width
                    width: 1988
                    spacing: dp(3)

                    Repeater {
                        model: waveModel.chn_count()

                        Row {
                            spacing: dp(3)
                            height: dp(100)
                            width: parent.width

                            property color drawColor: Qt.rgba(Math.random(),
                                                              Math.random(), Math.random(), 1);


                            Column {
                                height: parent.height
                                width: dp(169)

                                Rectangle {
                                    height: parent.height / 2
                                    width: parent.width
                                    border.color: drawColor

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
                                    height: parent.height / 2
                                    width: parent.width
                                    border.color: drawColor

                                    Label {
                                        text: wave.randomScalingFactor() + " ∠"+ wave.randomScalingFactor() + "°"
                                        color: Theme.light.textColor
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            QChart {
                                id: chart_line;
                                width: parent.width
                                height: parent.height

                                chartAnimated: true;
                                chartAnimationEasing: Easing.InOutElastic;
                                chartAnimationDuration: 1000;

//                                chartData: {
//                                    "labels": ["1","2","3","4","5","6","7"],
//                                    "datasets": [{
//                                                     "fillColor": "transparent",
//                                                     "strokeColor": drawColor,
//                                                     "pointColor": "rgba(220,220,220,1)",
//                                                     "pointStrokeColor": "black",
//                                                     "data": [wave.randomScalingFactor(),
//                                                         wave.randomScalingFactor(),
//                                                         wave.randomScalingFactor(),
//                                                         wave.randomScalingFactor(),
//                                                         wave.randomScalingFactor(),
//                                                         wave.randomScalingFactor(),
//                                                         wave.randomScalingFactor()]
//                                                 }
//                                    ]
//                                }

                                chartData: {
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

                                chartType: Charts.ChartType.LINE;

                                Component.onCompleted: {
                                }
                            }
                        }
                    }
                }

            }

            Scrollbar {
                flickableItem: flickable
                orientation: Qt.Vertical
            }

            Scrollbar {
                flickableItem: flickable
                orientation: Qt.Horizontal
            }

            Rectangle {
                width: dp(2)
                height: flickable.height

                x: gr.value * gr.width / gr.maximumValue + axisLabel.width + dp(7)

                Behavior on x {
                    NumberAnimation { duration: 100 }
                    enabled: true
                }

                color: "red"
            }
        }

    }

    Component.onCompleted: {

    }
}
