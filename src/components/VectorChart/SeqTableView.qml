import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

import Material 0.3

import "../../core"

Item {
    id: root

    visible: true
    width: 800
    height:600

    property int selectDataIndex: 0
//    property var selAnalChannels: [-1, -1, -1, -1, -1, -1]
    property var selAnalChannels: [14,16,18,1,3,5]

    property alias model: modelChannel

    // ///////////////////////////////////////////////////////////////

    signal modelCheckedChanged();
//    signal selAnalChannelsChanged();

    // ///////////////////////////////////////////////////////////////

    function log(says) {
        console.log("## SeqTableView.qml ##: " + says);
    }

    function dp(di){
        return di;
    }

    function validateSelAnalChannels(){
        if (!selAnalChannels || !Array.isArray(selAnalChannels) || selAnalChannels.length != 6)
            return false;

        log("here")

        for (var i = 0; i < selAnalChannels.length; i++){
            if (selAnalChannels[i] < 0)
                return false;
        }

        return true;
    }

    // ///////////////////////////////////////////////////////////////

    Connections {
        target: AnalDataModel

        onAnalyzerResultUpdated: {
            modelCheckedChanged();  // 发送给VectorChart
            modelChannel.rebuildModel();
        }
    }

    onSelAnalChannelsChanged: {
        log("selAnalChannels = " + selAnalChannels)
        modelChannel.rebuildModel();
    }

    function formatAngle(arg){
        return "∠ " + arg.toFixed(2) + "°";
    }

    ListModel
    {
        id: modelChannel

        function rebuildModel() {
            clear();

            if (!root.validateSelAnalChannels())
                return;

            var names = ["", "", "", "U1", "U2", "3U0", "", "", "", "I1", "I2", "3I0"];
            var phase = ["", "", "", "", "", "", "", "", "", "", "", ""];
            var unit = ["", "", "", "", "", "", "", "", "", "", "", ""];
            var rms = ["", "", "", "", "", "", "", "", "", "", "", ""];
            var angle = ["", "", "", "", "", "", "", "", "", "", "", ""];
            var checked = [false, false, false, false, false, false, false, false, false, false, false, false];
            var input_U = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
            var input_I = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

            names[0] = AnalDataModel.getPropValue(selAnalChannels[0], "name");
            names[1] = AnalDataModel.getPropValue(selAnalChannels[1], "name");
            names[2] = AnalDataModel.getPropValue(selAnalChannels[2], "name");
            names[6] = AnalDataModel.getPropValue(selAnalChannels[3], "name");
            names[7] = AnalDataModel.getPropValue(selAnalChannels[4], "name");
            names[8] = AnalDataModel.getPropValue(selAnalChannels[5], "name");

            phase[0] = AnalDataModel.getPropValue(selAnalChannels[0], "phase");
            phase[1] = AnalDataModel.getPropValue(selAnalChannels[1], "phase");
            phase[2] = AnalDataModel.getPropValue(selAnalChannels[2], "phase");
            phase[6] = AnalDataModel.getPropValue(selAnalChannels[3], "phase");
            phase[7] = AnalDataModel.getPropValue(selAnalChannels[4], "phase");
            phase[8] = AnalDataModel.getPropValue(selAnalChannels[5], "phase");

            unit[0] = AnalDataModel.getPropValue(selAnalChannels[0], "unit");
            unit[1] = AnalDataModel.getPropValue(selAnalChannels[1], "unit");
            unit[2] = AnalDataModel.getPropValue(selAnalChannels[2], "unit");
            unit[3] = AnalDataModel.getPropValue(selAnalChannels[2], "unit");
            unit[4] = AnalDataModel.getPropValue(selAnalChannels[2], "unit");
            unit[5] = AnalDataModel.getPropValue(selAnalChannels[2], "unit");
            unit[6] = AnalDataModel.getPropValue(selAnalChannels[3], "unit");
            unit[7] = AnalDataModel.getPropValue(selAnalChannels[4], "unit");
            unit[8] = AnalDataModel.getPropValue(selAnalChannels[5], "unit");
            unit[9] = AnalDataModel.getPropValue(selAnalChannels[5], "unit");
            unit[10] = AnalDataModel.getPropValue(selAnalChannels[5], "unit");
            unit[11] = AnalDataModel.getPropValue(selAnalChannels[5], "unit");

            var harmon_value = AnalDataModel.getHarmonValue(selAnalChannels[0], 1)
            if (AnalDataModel.isHarmonValueValid(harmon_value)){
                rms[0] = harmon_value.rms.toFixed(2) + "";
                angle[0] = formatAngle(harmon_value.angle)
                input_U[0] = harmon_value.real;
                input_U[1] = harmon_value.img;
            }
            harmon_value = AnalDataModel.getHarmonValue(selAnalChannels[1], 1)
            if (AnalDataModel.isHarmonValueValid(harmon_value)){
                rms[1] = harmon_value.rms.toFixed(2) + "";
                angle[1] = formatAngle(harmon_value.angle)
                input_U[2] = harmon_value.real;
                input_U[3] = harmon_value.img;
            }
            harmon_value = AnalDataModel.getHarmonValue(selAnalChannels[2], 1)
            if (AnalDataModel.isHarmonValueValid(harmon_value)){
                rms[2] = harmon_value.rms.toFixed(2) + "";
                angle[2] = formatAngle(harmon_value.angle)
                input_U[4] = harmon_value.real;
                input_U[5] = harmon_value.img;
            }

            harmon_value = AnalDataModel.getHarmonValue(selAnalChannels[3], 1)
            if (AnalDataModel.isHarmonValueValid(harmon_value)){
                rms[6] = harmon_value.rms.toFixed(2) + "";
                angle[6] = formatAngle(harmon_value.angle)
                input_I[0] = harmon_value.real;
                input_I[1] = harmon_value.img;
            }
            harmon_value = AnalDataModel.getHarmonValue(selAnalChannels[4], 1)
            if (AnalDataModel.isHarmonValueValid(harmon_value)){
                rms[7] = harmon_value.rms.toFixed(2) + "";
                angle[7] = formatAngle(harmon_value.angle)
                input_I[2] = harmon_value.real;
                input_I[3] = harmon_value.img;
            }
            harmon_value = AnalDataModel.getHarmonValue(selAnalChannels[5], 1)
            if (AnalDataModel.isHarmonValueValid(harmon_value)){
                rms[8] = harmon_value.rms.toFixed(2) + "";
                angle[8] = formatAngle(harmon_value.angle)
                input_I[4] = harmon_value.real;
                input_I[5] = harmon_value.img;
            }

            var u = Calculator.calcE1(input_U);
            if (u){
                rms[3] = u.rms.toFixed(2) + "";
                angle[3] = formatAngle(u.angle)
            }

            u = Calculator.calcE2(input_U);
            if (u){
                rms[4] = u.rms.toFixed(2) + "";
                angle[4] = formatAngle(u.angle);
            }

            u = Calculator.calc3E0(input_U);
            if (u){
                rms[5] = u.rms.toFixed(2) + "";
                angle[5] = formatAngle(u.angle);
            }

            var ii = Calculator.calcE1(input_I);
            if (ii){
                rms[9] = ii.rms.toFixed(2) + "";
                angle[9] = formatAngle(ii.angle);
            }

            ii = Calculator.calcE2(input_I);
            if (ii) {
                rms[10] = ii.rms.toFixed(2) + "";
                angle[10] = formatAngle(ii.angle);
            }
            ii = Calculator.calc3E0(input_I);
            if (ii){
                rms[11] = ii.rms.toFixed(2) + "";
                angle[11] = formatAngle(ii.angle);
            }

            for (var i = 0; i < names.length; i++){
                append({
                                   checked: checked[i],
                                   serial: i + 1,
                                   name: names[i],
                                   unit: unit[i],
                                   phase: phase[i],
                                   rms: rms[i],
                                   angle: angle[i]
                               }
                        )
            }
        }
    }

    TableView
    {
        id: table
        anchors.fill: parent

        model: modelChannel

        property var roleNames: [" ", "serial", "name","rms", "angle", "unit", "phase", "precision"]
        property var titleNames: [" ", "通道编号", "通道名称","有效值", "相角", "单位", "相别", "精度系数"]
        property var widths: [1, 70, 200, 100, 100, 60, 60, 100]

        rowDelegate: View {
            id: rowDelegate

            property int sizeOpen: 30
            property int sizeClosed: 26

            elevation: rowDelegate.sizeOpen == rowDelegate.height ? 1 : 0
            backgroundColor: (styleData.selected) ? Theme.accentColor : (styleData.alternate ? "#fafafa" : "white")
            height: getSize() // styleData.selected? sizeOpen : sizeClosed

            function getSize(){
                if(!table.selection.contains(styleData.row))
                {
                    doClose.start();
                    return sizeClosed;
                }

                return sizeOpen;
            }

            MouseArea {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: sizeClosed
                propagateComposedEvents: true
                preventStealing: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: {
                    table.currentRow = modelChannel.get(styleData.row).serial - 1;
                    if(rowDelegate.sizeOpen == rowDelegate.height)
                    {
                        table.selection.deselect(styleData.row);
                        doClose.start()
                    }
                    else
                    {
                        table.selection.clear();
                        table.selection.select(styleData.row);
                        doOpen.start();
                    }
                }
            }

            ParallelAnimation {
                id: doOpen
                running: false
                NumberAnimation { target: rowDelegate; easing.type: Easing.OutSine; property: "height"; to: sizeOpen; duration: 100 }
            }
            ParallelAnimation {
                id: doClose
                running: false
                NumberAnimation { target: rowDelegate; easing.type: Easing.OutSine; property: "height"; to: sizeClosed; duration: 100; }
            }
        }

        headerDelegate: View {
            elevation: 1
            height: dp(24)

            backgroundColor: Theme.backgroundColor

            Text {
                id: textItem
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: styleData.textAlignment
                anchors.leftMargin: 12
                text: styleData.value
                elide: Text.ElideRight
                renderType: Text.NativeRendering

                font {
                    family: "微软雅黑"
                    weight: Font.Light
                    pixelSize: dp(12)
                }
            }

        }

        itemDelegate: Item {
            Text {
                id: textcontent
                anchors.verticalCenter: parent.verticalCenter
                anchors.centerIn: parent
                elide: styleData.elideMode
                text: styleData.value

                visible: styleData.column != 1

                color: {
                    var rowModel = modelChannel.get(styleData.row);
                    if (rowModel && rowModel.phase){
                        var color = AnalDataModel.phaseColorByTypeName(rowModel.phase)
                        if ( color && !styleData.selected && (styleData.column != 1 && styleData.column != 0)/* && color != "lightgrey"*/)
                            return color
                    }

                    return styleData.textColor;
                }

                font {
                    family: "微软雅黑"
                    weight: Font.Light
                    pixelSize: dp(12)
                }
            }

            CheckBox {
                checked: false
                anchors.verticalCenter: parent.verticalCenter

                visible: styleData.column == 1
                text: textcontent.text//styleData.row + 1

                color: Theme.primaryColor

                onCheckedChanged: {
                    var idx = modelChannel.get(styleData.row).serial - 1;
                    modelChannel.get(styleData.row).checked = checked;
                    modelCheckedChanged();
                }
            }
        }

        resources:{
            var roleList = roleNames
            var titleList = titleNames
            var temp = []
            for(var i=0; i<roleList.length; i++)
            {
                var role  = roleList[i];
                var title  = titleList[i];
                var width0 = widths[i];
                temp.push(columnComponent.createObject(table,
                                                       {
                                                           "role": role,
                                                           "title": title,
                                                           "width": width0,
                                                           "horizontalAlignment": Text.AlignHCenter
                                                       }))
            }
            return temp
        }
    }

    Component
    {
        id: columnComponent
        TableViewColumn{ width: 100 }
    }

    Component.onCompleted: {
        log("Component.onCompleted")

        if (AnalDataModel.isModelValid()){
            modelChannel.rebuildModel();
        }
    }

    Component.onDestruction: {
        log("Component.onDestruction")
    }
}
