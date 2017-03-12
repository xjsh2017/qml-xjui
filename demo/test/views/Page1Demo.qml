import QtQuick 2.0

import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

//import XjUi 1.0
import Material 0.3

import "../../../src/views"

Item {
    property var sectionTitles: [ "报文分析", "离散度分析", "谐波分析", "向量分析", "序分量分析"]

    Controls.SplitView{
        anchors.fill:parent;
        orientation: Qt.Horizontal;


        handleDelegate: View {
            width: dp(3)
            height: parent.height

            elevation: 2
        }

        Rectangle {
            id: tree

            visible: false

//            Layout.fillWidth: true
//            Layout.minimumWidth: dp(100);
            width: dp(200)
            Layout.maximumWidth: dp(400);

        }

        Rectangle {
            id: table2

            Layout.fillWidth: true

            width: parent.width * 3 / 4
            Layout.minimumWidth: dp(200);

            Controls.SplitView{
                id: content

                width: parent.width
                height: parent.height - navibar.height - dp(1)
                orientation: Qt.Vertical;

                WaveChartAnal {
                    id: wave
                    Layout.fillHeight: true
                    Layout.minimumWidth: 100;
                }

                TabbedPages {
                    id: tabview

                    selectedTabIndex: 3
                    Layout.fillHeight: true;
                    Layout.minimumHeight: dp(200);
                }
            }

            View {
                id: navibar

                anchors.bottom: parent.bottom

                elevation: 2

                backgroundColor: Theme.primaryDarkColor

                height: dp(24)
                width: parent.width

                IconButton {
                    id: action_hide_show_left

                    action: Action {
                        iconName: "editor/border_left"
                        name: tree.visible ? "Hide Siderbar" : "Show Siderbar"
                        onTriggered: {
                            tree.visible = !tree.visible;
                        }
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: dp(30)
                    spacing: dp(1)

                    Repeater {
                        model: sectionTitles

                        Item {
                            width: dp(100)

                            height: parent.height - dp(4)
                            anchors.verticalCenter: parent.verticalCenter

                            View {
                                id: num
                                z: 1

                                height: parent.height
                                width: height - dp(2)

                                backgroundColor: Theme.accentColor

                                Text {
                                    anchors.centerIn: parent

                                    text: index + 1
                                    color: "white"
                                }

                                border.color: Qt.rgba(0, 0, 0, 0.6)

                                radius: dp(2)
                            }

                            Button {
                                id: btnNum
                                text: qsTr(modelData)

                                height: parent.height
                                width: parent.width - num.width

                                anchors.left: num.right
                                anchors.leftMargin: -dp(2)

                                elevation: 1
                                backgroundColor: tabview.selectedTabIndex == index ? num.backgroundColor : "lightgrey"

                                onClicked: {
                                    tabview.selectedTabIndex = index
                                }

                                Rectangle {
                                    anchors.fill: parent

                                    border.color: Qt.rgba(0, 0, 0, 0.6)
                                    radius: dp(2)
                                    color: "transparent"
                                }
                            }
                        }
                    }
                }
            }

        }

    }


}
