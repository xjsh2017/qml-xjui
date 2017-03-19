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


            RowLayout {
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
                        text: qsTr("分析谐波")

                        font {
                            family: "微软雅黑"
                            weight: Font.Light
                            pixelSize: dp(12)
                        }
                    }
                }

                Controls.ComboBox {
                    id: cmbHarmon

                    width: dp(100)
                    height: parent.height

                    model: ListModel {
                        id: harmonModel
                        ListElement { text: "test"; color: "test" }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    onCurrentIndexChanged: {
                        console.debug(harmonModel.get(currentIndex).text + ", " + harmonModel.get(currentIndex).color);
                        table.selectHarmonTimes = currentIndex;

                        console.log("table.selectHarmonTimes = " + table.selectHarmonTimes)
                    }

                    function updateModel() {
                        harmonModel.clear();

                        var cols = AnalDataModel.analyzer.maxHarmonicTimes;
                        for (var i = 0; i <= cols; i++){
                            var js = {};

                            if (i == 0){
                                js["text"] = "真有效值"
                            }else if (i == 1){
                                js["text"] = "基波"
                            }else{
                                js["text"] = i + " 次谐波";
                            }
                            js["color"] = "random";

                            harmonModel.append(js);
                        }
                    }
                    Component.onCompleted: {
                        updateModel();
                        cmbHarmon.currentIndex = 1;
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
                    id: cmbShowType

                    width: dp(100)
                    height: parent.height

                    model: ListModel {
                        id: modelShowType
                        ListElement { text: "旋转向量"; color: "test" }
                        ListElement { text: "参考向量"; color: "test" }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    onCurrentIndexChanged: {
//                        console.debug(modelShowType.get(currentIndex).text + ", " + modelShowType.get(currentIndex).color);
                    }
                }

                Item {
                    height: parent.height
                    width: dp(80)

                    visible: cmbShowType.currentIndex == 1
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("基准通道")

                        font {
                            family: "微软雅黑"
                            weight: Font.Light
                            pixelSize: dp(12)
                        }
                    }
                }

                Controls.ComboBox {
                    id: cmbBaseChannel

                    visible: cmbShowType.currentIndex == 1

                    width: dp(130)
                    height: parent.height

                    property int  channelIdx: 1

                    model: ListModel {
                        id: baseModel
                        ListElement { text: "test"; color: "test"; channel: 0 }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    onCurrentIndexChanged: {
//                        console.debug(baseModel.get(currentIndex).text + ", " + baseModel.get(currentIndex).color);
                          channelIdx = baseModel.get(currentIndex).channel;
                    }

                    function updateModel() {
                        baseModel.clear();

                        var count = AnalDataModel.getChannelCount();
                        for (var i = 0; i < count; i++){
                            var js = {};

                            if (!AnalDataModel.getPropValue(i, "visible"))
                                continue;

                            js["text"] = (i+1) + " - " + AnalDataModel.getPropValue(i, "name");
                            js["color"] = "random";
                            js["channel"] = i;

                            baseModel.append(js);
                        }
                    }
                    Component.onCompleted: {
                        updateModel();
                    }
                }

                Item {
                    Layout.fillWidth: true;
                    Layout.fillHeight: true;
                }

                IconButton {
                    id: action_hide_table

                    color: Theme.lightDark(navibar.backgroundColor, Theme.light.iconColor,
                                                                      Theme.dark.iconColor)

                    anchors.verticalCenter: parent.verticalCenter

                    action: Action {
                        iconName: "image/slideshow"
                        name: tree.visible ? "Hide Sidebar" : "Show Sidebar"
                        onTriggered: {
                            Global.g_hide = !Global.g_hide
                        }
                    }

                    rotation: 90
                }
            }
        }

        Controls.SplitView{
            height: parent.height - toolbar.height
            width: parent.width
            orientation: Qt.Horizontal;

            VectorTableView {
                id: table

//                selectHarmonTimes: cmbHarmon.currentIndex
                Layout.fillWidth: true
                Layout.minimumWidth: 100;

            }

            VectorChart {
                id: vec

    //            visible: false
                selectHarmonTimes: cmbHarmon.currentIndex
                showType: cmbShowType.currentIndex
                baseChannelIndex: cmbBaseChannel.channelIdx
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
