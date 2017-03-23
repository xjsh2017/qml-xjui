import QtQuick 2.4
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

import Material 0.2

//import XjUi 1.0
import "../components/VectorChart"
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
                    id: action_selchannel

                    color: Theme.lightDark(navibar.backgroundColor, Theme.light.iconColor,
                                                                      Theme.dark.iconColor)

                    anchors.verticalCenter: parent.verticalCenter

                    action: Action {
                        iconName: "device/storage"
                        name: qsTr("选择通道")
                        onTriggered: {
                            channelSettings.show();
                        }
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

            SeqTableView {
                id: table

                Layout.fillWidth: true
                Layout.minimumWidth: 100;

            }

            SeqVectorChart {
                id: vec

                model: table.model

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

    Dialog {
        id: channelSettings
        title: qsTr("")

        property var selAnalChannels: [-1, -1, -1, -1, -1, -1]

        positiveButtonText: qsTr("确定")
        negativeButtonText: qsTr("取消")

        function updateModel() {
            var tmp = [];

            var cols = AnalDataModel.getChannelCount();
            tmp[0] = "---"
            for (var i = 0; i < cols; i++){
                tmp.push("通道 " + (i + 1) + " : " + AnalDataModel.getPropValue(i, "name"));
            }
            return tmp
        }

        Item {

            width: dp(300)
            height: dp(380)

            ColumnLayout {
                id: column

                property var sections: ["UA", "UB", "UC", "IA", "IB", "IC"]

                anchors {
                    fill: parent
                    topMargin: dp(16)
                    bottomMargin: dp(16)
                }

                Label {
                    id: titleLabel

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: dp(16)
                    }

                    style: "title"
                    text: qsTr("序分量分析-通道选择")
                }

                Item {
                    Layout.fillWidth: true
                    height: dp(9)
                }

                MagicDivider {
                    styleDivider:  1
                    dash_len: 3
                    color: Theme.accentColor
                }

//                Item {
//                    Layout.fillWidth: true
//                    height: dp(9)
//                }

                Repeater{
                    model: column.sections.length

                    delegate: ListItem.Standard {
                        content: RowLayout {
                            anchors.centerIn: parent
                            width: parent.width

                            Item {
                                Layout.alignment: Qt.AlignHCenter
//                                Layout.preferredWidth: 0.2 * parent.width
                                width: 0.2*parent.width

                                Label {
                                    anchors.centerIn: parent
                                    text: column.sections[modelData]
                                }
                            }

                            MenuField {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.fillWidth: true

                                model: []
                                Component.onCompleted: {
                                    model = channelSettings.updateModel();
                                }

                                onItemSelected: {
                                    console.log("modelData = " + modelData + ", index = " + index);
                                    if (index > 0){
                                        channelSettings.selAnalChannels[modelData] = (index - 1);
                                    }else{
                                        channelSettings.selAnalChannels[modelData] = -1;
                                    }
                                }
                            }
                        }
                    }

                }


                Item {
                    Layout.fillHeight: true;
                    Layout.fillWidth: true;
                }
            }

        }

        onAccepted: {
            console.log("channelSettings.selAnalChannels = " + channelSettings.selAnalChannels);
            table.selAnalChannels = channelSettings.selAnalChannels;
            table.selAnalChannelsChanged();
        }

        onRejected: {
            // TODO set default colors again but we currently don't know what that is
        }
    }
}
