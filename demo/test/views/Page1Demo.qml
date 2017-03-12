import QtQuick 2.0

import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

//import XjUi 1.0
import "../../../src/views"
import Material 0.3

Item {
    property var sectionTitles: [ "报文分析", "离散度分析", "谐波分析", "向量分析", "序分量分析"]

    Controls.SplitView{
        id: content

//        anchors.fill:parent;
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

            model: wave.model

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

        RowLayout {
            anchors.fill: parent

            spacing: dp(1)

            Repeater {
                model: sectionTitles

                Item {
                    Layout.fillHeight: true
                    width: btnNum.width + num.width
                    Layout.margins: 2

                    Button {
                        id: btnNum
                        text: qsTr(modelData)

                        implicitHeight: dp(16)
                        implicitWidth: dp(80)

                        height: num.height

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

                    View {
                        id: num

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
                }
            }



            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}
