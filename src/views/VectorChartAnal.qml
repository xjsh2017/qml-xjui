import QtQuick 2.4
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1

import Material 0.2

import "../components/VectorChart"

Item {
    id: me

    property alias model: table.model;
    property alias selectDataIndex: table.selectDataIndex;

    function dp(di){
        return di;
    }

    function randomScalingFactor() {
        return Math.round(Math.random() * 100);
    }

    // 工具栏
    Controls.SplitView{
        anchors.fill:parent;
        orientation: Qt.Horizontal;

        XJTableView {
            id: table

            Layout.fillWidth: true
            Layout.minimumWidth: 100;

        }

        VectorChart {

            visible: false
            Layout.fillWidth: true
            width: parent.width * 2 / 5
        }
    }
}
