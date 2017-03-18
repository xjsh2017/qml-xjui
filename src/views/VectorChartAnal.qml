import QtQuick 2.4
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1

import Material 0.2
import Material.ListItems 0.1 as ListItem

//import XjUi 1.0
import "../components/VectorChart"
import "../components/Basic"
import "../core"

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
        spacing: dp(0)

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

                spacing: dp(0)

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
                    width: dp(2)

                    Rectangle {
                        anchors.centerIn: parent
                        width: dp(1)

                        height: parent.height * 3/4

                        color: Theme.backgroundColor
                    }

                }

                Item {
                    height: parent.height
                    width: dp(80)
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("参考谐波")

                        font {
                            family: "微软雅黑"
                            weight: Font.Light
                            pixelSize: dp(12)
                        }
                    }
                }

                Controls.ComboBox {
                    id: cmbBox

                    width: dp(100)
                    height: parent.height

                    model: ListModel {
                        id: model1
                        ListElement { text: "test"; color: "test" }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    onCurrentIndexChanged: {
//                        console.debug(model1.get(currentIndex).text + ", " + model1.get(currentIndex).color);
                        if (table && table.showHarmonTimes)
                            table.showHarmonTimes = currentIndex + 2;
                    }

                    function updateModel() {
                        model1.clear();

                        var cols = AnalDataModel.analyzer.maxHarmonicTimes;
                        for (var i = 1; i <= cols; i++){
                            var js = {};

                            if (i == 1){
                                js["text"] = "基波"
                            }else{
                                js["text"] = i + " 次谐波";
                            }
                            js["data"] = "random";

                            model1.append(js);
                        }
                    }
                    Component.onCompleted: {
                        updateModel();
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

            VectorTableView {
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


//    ActionBox {
//        id: actionSheet
//        parent: me

//        anchors {
//            top: btn.bottom
//        }

//        actions: [
//            Action {
////                iconName: "social/share"
//                name: "Share"
//            },

//            Action {
//                iconName: "file/file_download"
//                name: "Download (Disabled)"
//                enabled: false
//            },

//            Action {
//                iconName: "action/autorenew"
//                name: "THIS SHOULD BE HIDDEN"
//                visible: false
//            },

//            Action {
//                iconName: "action/settings"
//                name: "Details"
//                hasDividerAfter: true
//            },

//            Action {
//                iconName: "content/forward"
//                name: "Move"
//            },

//            Action {
//                iconName: "action/delete"
//                name: "Delete"
//            },

//            Action {
//                iconName: "content/create"
//                name: "Rename"
//            }
//        ]
//    }

}
