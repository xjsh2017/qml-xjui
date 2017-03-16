import QtQuick 2.4
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1

import Material 0.2

import "../components/VectorChart"
//import XjUi 1.0

Item {
    id: me

    property alias selectDataIndex: table.selectDataIndex;
    property  string titleName;

    function dp(di){
        return di;
    }

    function randomScalingFactor() {
        return Math.round(Math.random() * 100);
    }

    Column {
        id: verticallayout

        anchors.fill: parent
        spacing: dp(2)

        // 工具栏
        View {
            id: toolbar

            width: parent.width;
            height: dp(24)

            elevation: 3

            clip: false

            backgroundColor: Theme.primaryColor

            Rectangle { // 渐变色
                anchors.fill: parent
                gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.lighter(Theme.primaryColor) }
                        GradientStop { position: 0.73; color: Theme.primaryColor }
                        GradientStop { position: 1.0; color: Theme.primaryColor }
                    }
            }


            Row {
                width: parent.width
                height: parent.height

                spacing: dp(4)

                Item {
                    height: parent.height
                    width: dp(80)
                    Label {
                        anchors.centerIn: parent
                        text: qsTr(titleName)

                        font {
                            family: "微软雅黑"
                            weight: Font.Light
                            pixelSize: dp(12)
                        }
                    }
                }

                Item {
                    height: parent.height
                    width: dp(80)
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("显示方式")

                        font {
                            family: "微软雅黑"
                            weight: Font.Light
                            pixelSize: dp(12)
                        }
                    }
                }

                Controls.ComboBox {
                    id: cmbBox2

                    width: dp(100)
                    height: parent.height

                    model: ListModel {
                        id: model2
                        ListElement { text: "参考向量"; color: "test" }
                        ListElement { text: "旋转向量"; color: "test" }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    onCurrentIndexChanged: {
                        console.debug(model2.get(currentIndex).text + ", " + model2.get(currentIndex).color);
                    }
                }

                Button {
                    id: btnGrooveMode

                    height: parent.height
                    width: dp(80)

                    elevation: 1
                    backgroundColor: Theme.accentColor

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("通道选择")
                        color: "white"

                        font {
                            family: "微软雅黑"
                            weight: Font.Light
                            pixelSize: dp(13)
                        }
                    }

                    onClicked: {

                    }
                }


                IconButton {
                    id: action_left_end
                    visible: false

                    action: Action {
                        iconName: "action/scroll_leftend"
                        name: "To Left End"
                        onTriggered: {
                            if (Global.g_plotMode == Global.enSampleMode)
                                groove.scroller.move(-999999 * Global.g_sampleRate);
                        }
                    }
                }
            }
        }

        Controls.SplitView{
            height: parent.height - toolbar.height
            width: parent.width
            orientation: Qt.Horizontal;

            SeqTableView {
                id: table

                Layout.fillWidth: true
                Layout.minimumWidth: 100;

            }

            VectorChart {
                id: vec

    //            visible: false
                Layout.fillWidth: true
                Layout.minimumWidth: 300;
                width: parent.width * 1 / 5
            }

            Connections {
                target: table

                onModelCheckedChanged: {
                    vec.repaint();
                }
            }
        }

    }
}
