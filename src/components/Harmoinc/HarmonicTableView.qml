import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

//import MoeFileModel 1.0

import Material 0.3

//import XjUi 1.0
import "../../core"

Item {
    id: root

    visible: true
    width: 800
    height:600

    property int showHarmonTimes: 7

    // ///////////////////////////////////////////////////////////////

    signal selRowChanged(var channelIdx, var showHarmonTimes)

    // ///////////////////////////////////////////////////////////////

    Connections {
        target: AnalDataModel

        onAnalyzerResultUpdated: {
            log("Detected AnalDataModel Anal Result Updated !")
            log("Doing: update harmonic table model data !")
            modelChannel.updateModel();
            log("Done!: update harmonic table model data !")
        }

        onChannelPropUpdated: {
            log("Detected AnalDataModel channel info updated !")
            log("Doing: rebuild harmonic table model data !")
            modelChannel.rebuildModel();
            log("Done!: rebuild harmonic table model data !")
        }
    }

    onShowHarmonTimesChanged: {
        log("onShowHarmonTimesChanged")
        table.update();

        selRowChanged(table.currentRow, showHarmonTimes)
    }

    ListModel
    {
        id: modelChannel

        function rebuildModel() {
            clear();

            for (var i = 0; i < AnalDataModel.getChannelCount(); i++){
                if (!AnalDataModel.getPropValue(i, "visible"))
                    continue;

                var js = {};
                js["serial"] = i + 1;   // 通道编号
                js["name"] = AnalDataModel.getPropValue(i, "name");

                for (var j = 0; j <= AnalDataModel.analyzer.maxHarmonicTimes; j ++){
                    var harmon_value = AnalDataModel.getHarmonValue(i, j);
                    if (harmon_value && AnalDataModel.isHarmonValueValid(harmon_value)){
                        js[j] = harmon_value.rms.toFixed(3) + ", "
                                + (harmon_value.percentage * 100).toFixed(2) + " %";
                    }else{
                        js[j] = "";
                    }
                }

                append(js);
            }
        }

        function getRowIdxByChannelIdx(channelIdx) {
            for (var i = 0; i < modelChannel.count; i++){
                if (parseInt(modelChannel.get(i).serial) == (channelIdx + 1))
                    return i;
            }

            return -1;
        }

        function updateModel() {
            for (var i = 0; i < modelChannel.count; i++){
                var idx = modelChannel.get(i).serial - 1;
                if (idx < 0)
                    continue;

                for (var j = 0; j <= AnalDataModel.analyzer.maxHarmonicTimes; j ++){
                    var harmon_value = AnalDataModel.getHarmonValue(idx, j);
                    if (AnalDataModel.isHarmonValueValid(harmon_value)){
                        modelChannel.setProperty(i, j.toString(), harmon_value.rms.toFixed(3) + ", "
                                                 + (harmon_value.percentage * 100).toFixed(2) + " %");
                    }
                }
            }
        }
    }

    TableView
    {
        id: table
        anchors.fill: parent

        model: modelChannel

        function createResources() {
            resources = [];
            var roleList = roleNames
            var titleList = titleNames
            var widthList = widths
            var cols = AnalDataModel.analyzer.maxHarmonicTimes + 1;//Math.min(showHarmonTimes, AnalDataModel.analyzer.maxHarmonicTimes) + 1;
            for (var i = 2; i < cols; i++){
                roleList.push(i.toString());
                titleList.push(i + "次谐波");
                widthList.push(100)
            }

            var temp = []
            for(i=0; i<roleList.length; i++)
            {
                var role  = roleList[i];
                var title  = titleList[i];
                var width = widthList[i];
                temp.push(columnComponent.createObject(table,
                                                       {
                                                           "role": role,
                                                           "title": title,
                                                           "width": width,
                                                           "horizontalAlignment": Text.AlignHCenter
                                                       }))
                if (i - 4 >= showHarmonTimes)
                    temp[i].visible = false;
            }

            resources = temp;

            return temp;
        }

        function update() {
            log("resources.length = " + resources.length)
            for (var i = 5; i < resources.length; i++){
                if (i >= showHarmonTimes + 4)
                    resources[i].visible = false;
                else
                    resources[i].visible = true;
            }
        }

        property var roleNames: [" ", "serial", "name","0", "1"]
        property var titleNames: [" ", "通道编号", "通道名称","直流分量", "基波"]
        property var widths: [1, 60, 150, 100, 100]

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
                    table.currentRow = modelChannel.get(styleData.row).serial - 1;  // 将通道的index传过去，而不是行号
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
//                color: textColor
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
                anchors.verticalCenter: parent.verticalCenter
                anchors.centerIn: parent
                elide: styleData.elideMode
                text: styleData.value

                color: {
                    var rowModel = modelChannel.get(styleData.row);
                    if (rowModel && rowModel.serial){
                        var idx = parseInt(rowModel.serial) - 1;
                        var color = AnalDataModel.getChannelColor(idx);
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
        }

        resources: createResources()

        onCurrentRowChanged: {
            selRowChanged(currentRow, showHarmonTimes)
        }
    }

    Component
    {
        id: columnComponent
        TableViewColumn{ width: 100 }
    }

    // ///////////////////////////////////////////////////////////////

    function log(says) {
        console.log("## HarmonicTableView.qml ##: " + says);
    }

    function dp(di){
        return di;
    }

    // ///////////////////////////////////////////////////////////////

    Component.onCompleted: {
        try {
            if (AnalDataModel.isModelValid())
                modelChannel.rebuildModel();

        } catch (error) {
            // Ignore the error
        }

        log("Component.onCompleted")
    }

    Component.onDestruction: {
        log("Component.onDestruction")
    }
}
