import QtQuick 2.4
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1

import Material 0.2

import "../components/Harmoinc"

//import XjUi 1.0

Item {
    id: me

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

        HarmonicTableView {
            id: table

            Layout.fillWidth: true
            Layout.minimumWidth: 100;

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
                harmon.currentIndex = index;
            }
        }
    }
}
