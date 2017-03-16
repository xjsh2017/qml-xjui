import QtQuick 2.4
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

import Material 0.2

import "../components/Harmoinc"
import "../core"

//import XjUi 1.0

Item {
    id: me

    function dp(di){
        return di;
    }

    function randomScalingFactor() {
        return Math.round(Math.random() * 100);
    }

    property  string titleName;

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
                    width: dp(100)
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("最大谐波次数")

                        font {
                            family: "微软雅黑"
                            weight: Font.Light
                            pixelSize: dp(12)
                        }
                    }
                }

                Controls.ComboBox {
                    id: cmbBox

                    width: dp(50)
                    height: parent.height
                    visible: false

                    currentIndex: 2
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
                        for (var i = 2; i <= cols; i++){
                            var js = {};
                            js["text"] = i + " "/* + " 次谐波分析"*/;
                            js["data"] = "random";

                            model1.append(js);
                        }
                    }
                    Component.onCompleted: {
                        updateModel();
                    }
                }

                Item {
                    width: dp(80)
                    height: parent.height

                    property alias selectIdx: cmbMenu.selectedIndex

                    ListItem.Standard {
                        anchors.fill: parent

                        content: RowLayout {
                            anchors.centerIn: parent
                            width: parent.width

                            MenuField {
                                id: cmbMenu
                                anchors.fill: parent

                                model: []
                                Component.onCompleted: {
                                    var tmp = [];
                                    var cols = AnalDataModel.analyzer.maxHarmonicTimes;
                                    for (var i = 2; i <= cols; i++){
                                        tmp.push(i)
                                    }
                                    model = tmp;

                                    selectedIndex = 7 - 2;
                                }

                                onItemSelected: {
                                    if (table && table.showHarmonTimes)
                                        table.showHarmonTimes = index + 2;
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: false
                        height: parent.height + dp(4)
                        width: parent.width
                        y: -dp(2)
                        color:"transparent"
                        border.color: "grey";
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

            HarmonicTableView {
                id: table

                Layout.fillWidth: true
                Layout.minimumWidth: 100;

                Component.onCompleted: {
                    cmbBox.currentIndex = table.showHarmonTimes - 2;
                }
            }

            Harmonic {
                id: harmon

                Layout.fillWidth: true
                Layout.minimumWidth: 300;
                width: parent.width * 1 / 5
            }

            Connections {
                target: table

                onSelectRowChanged: {
                    console.log("onSelectRowChanged : " + index)
                    harmon.currentIndex = index;
                }
            }
        }

    }

}
