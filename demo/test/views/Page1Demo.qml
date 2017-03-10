import QtQuick 2.0

import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1

//import XjUi 1.0
import "../../../src/views"

Item {
    Controls.SplitView{
        anchors.fill:parent;
        orientation: Qt.Vertical;

        WaveChartAnal {
            id: wave
            Layout.fillHeight: true
            Layout.minimumWidth: 100;
        }

        VectorChartAnal {
            id: vec
            model: wave.model
            selectDataIndex: wave.selectDataIndex
            Layout.fillHeight: true
            height: parent.height * 2 / 5
            Layout.minimumHeight: dp(200)
        }
    }
}
