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
    property int selectHarmonTimes: 1

    // ///////////////////////////////////////////////////////////////

    signal modelCheckedChanged();

    // ///////////////////////////////////////////////////////////////

    function log(says) {
        console.log("## VectorTableView.qml ##: " + says);
    }

    function dp(di){
        return di;
    }

    // ///////////////////////////////////////////////////////////////

    Connections {
        target: AnalDataModel

        onAnalyzerResultUpdated: {
            modelCheckedChanged();  // 发送给VectorChart
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

    onSelectHarmonTimesChanged: {
//        modelCheckedChanged();  // 发送给VectorChart
        modelChannel.updateModel();
    }

    ListModel
    {
        id: modelChannel

        function rebuildModel() {
            clear();
            log("rebuildModel: selectHarmonTimes = " + selectHarmonTimes)
            for (var i = 0; i < AnalDataModel.getChannelCount(); i++){
                if (!AnalDataModel.getPropValue(i, "visible"))
                    continue;

                if (selectHarmonTimes == 0){
                    append({
                                       serial: i + 1,
                                       name: AnalDataModel.getPropValue(i, "name"),
                                       unit: AnalDataModel.getPropValue(i, "unit"),
                                       phase: AnalDataModel.getPropValue(i, "phase"),
                                       rms: AnalDataModel.getPropValue(i, "rms"),
                                       angle: AnalDataModel.getPropValue(i, "angle"),
                                   }
                            )
                }else{
                    var harmon_value = AnalDataModel.getHarmonValue(i, selectHarmonTimes);
                    if (!AnalDataModel.isHarmonValueValid(harmon_value))
                        continue;
                    append({
                                       serial: i + 1,
                                       name: AnalDataModel.getPropValue(i, "name"),
                                       unit: AnalDataModel.getPropValue(i, "unit"),
                                       phase: AnalDataModel.getPropValue(i, "phase"),
                                       rms: harmon_value.rms.toFixed(2) + "",
                                       angle: harmon_value.angle.toFixed(2) + "",
                                   }
                            )
                }


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
            log("updateModel: selectHarmonTimes = " + selectHarmonTimes)
            for (var i = 0; i < modelChannel.count; i++){
                var idx = modelChannel.get(i).serial - 1;

                if (selectHarmonTimes == 0){
                    modelChannel.setProperty(i, "rms", AnalDataModel.getPropValue(idx, "rms"))
                    modelChannel.setProperty(i, "angle"
                                   , AnalDataModel.getPropValue(idx, "angle") ?
                                                 "∠ " + AnalDataModel.getPropValue(idx, "angle") + "°": " ")
                }else{
                    var harmon_value = AnalDataModel.getHarmonValue(idx, selectHarmonTimes);
                    if (!AnalDataModel.isHarmonValueValid(harmon_value))
                        continue;

                    modelChannel.setProperty(i, "rms", harmon_value.rms.toFixed(2) + "")
                    modelChannel.setProperty(i, "angle", "∠ " + harmon_value.angle.toFixed(2) + "°")
                }
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

            CheckBox {
                checked: false//AnalDataModel.getPropValue(modelChannel.get(styleData.row).serial - 1, "checked")
                anchors.verticalCenter: parent.verticalCenter

                visible: styleData.column == 1
                text: textcontent.text//styleData.row + 1

                color: Theme.primaryColor

                onCheckedChanged: {
                    var idx = modelChannel.get(styleData.row).serial - 1;
                    AnalDataModel.setPropValue(idx, "checked", checked)
                    root.modelCheckedChanged()
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
