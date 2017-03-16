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
            update();
        }
    }

    function update() {
        for (var i = 0; i < modelChannel.count; i++){
            var idx = modelChannel.get(i).serial - 1;
            modelChannel.setProperty(i, "rms", AnalDataModel.getPropValue(idx, "rms"))
            modelChannel.setProperty(i, "angle"
                           , AnalDataModel.getPropValue(idx, "angle") ?
                                         "∠ " + AnalDataModel.getPropValue(idx, "angle") + "°": " ")
        }
    }

    ListModel
    {
        id: modelChannel

        function updateModel() {
            clear();
            for (var i = 0; i < AnalDataModel.getChannelCount(); i++){
                if (!AnalDataModel.getPropValue(i, "visible"))
                    continue;
                append({
                                   serial: i + 1,
                                   name: AnalDataModel.getPropValue(i, "name"),
                                   unit: AnalDataModel.getPropValue(i, "unit"),
                                   phase: AnalDataModel.getPropValue(i, "phase"),
                                   rms: AnalDataModel.getPropValue(i, "rms"),
                                   angle: AnalDataModel.getPropValue(i, "angle"),
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
                    var color = AnalDataModel.getChannelColor(styleData.row);
                    if ( !styleData.selected && (styleData.column == 2 || styleData.column == 6))
                        return AnalDataModel.getChannelColor(parseInt(modelChannel.get(styleData.row).serial))

                    return styleData.textColor;
                }

                font {
                    family: "微软雅黑"
                    weight: Font.Light
                    pixelSize: dp(12)
                }
            }

            CheckBox {
                checked: AnalDataModel.getPropValue(modelChannel.get(styleData.row).serial - 1, "selected")
                anchors.verticalCenter: parent.verticalCenter

                visible: styleData.column == 1
                text: textcontent.text//styleData.row + 1

                color: Theme.primaryColor

                onCheckedChanged: {
                    var idx = modelChannel.get(styleData.row).serial - 1;
                    AnalDataModel.setPropValue(idx, "selected", checked)
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
                var width = widths[i];
                temp.push(columnComponent.createObject(table,
                                                       {
                                                           "role": role,
                                                           "title": title,
                                                           "width": width,
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
            modelChannel.updateModel();
        }
    }

    Component.onDestruction: {
        log("Component.onDestruction")
    }
}
