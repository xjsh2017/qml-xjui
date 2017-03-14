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

    property var model: AnalDataModel.listModel
    property var propModel: AnalDataModel.propModel
    property bool isNeedUpdate: Calculator.isNeedUpdate
    property int selectDataIndex: 0

    // ///////////////////////////////////////////////////////////////

    signal modelCheckedChanged();

    // ///////////////////////////////////////////////////////////////

    function log(says) {
        console.log("## XJTableView.qml ##: " + says);
    }

    function dp(di){
        return di;
    }

    // ///////////////////////////////////////////////////////////////

//    onIsNeedUpdateChanged: {
//        log("Model Changed detected!")
//        modelCheckedChanged();
//        update();
//    }

    Connections {
        target: AnalDataModel

        onPropValueChanged: {
            root.update();
        }
    }

    function update() {
        log(root.model.rms)
        log(root.model.angle)

        for (var i = 0; i < modelChannel.count; i++){
            modelChannel.setProperty(i, "rms", root.model.get(i).rms)
            modelChannel.setProperty(i, "angle"
                           , root.model.get(i).angle ? "∠ " + root.model.get(i).angle + "°": "NaN")
        }
    }

    ListModel
    {
        id: modelChannel

        function updateModel() {
            clear();
            for (var i = 0; i < model.count; i++){
                console.log(root.model.get(i).name)
                append({
                                   name: root.model.get(i).name,
                                   unit: root.model.get(i).unit,
                                   phase: root.model.get(i).phase,
                                   rms: root.model.get(i).rms,
                                   angle: root.model.get(i).angle + " "
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
        property var titleNames: [" ", "序号", "通道名称","有效值", "相角", "单位", "相别", "精度系数"]

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

            backgroundColor: Theme.primaryColor

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

//        resources:{
//            var roleList = roleNames
//            var titleList = titleNames
//            var temp = []
//            for(var i=0; i<roleList.length; i++)
//            {
//                var role  = roleList[i];
//                var title  = titleList[i]
//                if (i == 0){
//                    temp.push(columnComponent.createObject(table, { "role": role, "title": title, width: 1}))
//                    continue;
//                }
//                temp.push(columnComponent.createObject(table, { "role": role, "title": title}))
//            }
//            return temp
//        }

        // columns go here...
        TableViewColumn {
            id: icon
            width: 1
            delegate: Item{
                anchors.fill: parent
                clip: !styleData.selected
                Rectangle {
                    clip:false
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    //height: 60
                    width: table.width
//                    color: "#4db6ac"
                    color: Theme.accentColor
                }
            }
        }

        TableViewColumn {
            id: colNumber
            role: "serialNum"
            title: "序号"
            width: 80
            delegate: Item {
                id: itemFirst
                clip:true
                anchors.fill: parent

                CheckBox {
                    checked: root.model.get(styleData.row).selected
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.primaryColor
                    text: styleData.row + 1

                    onCheckedChanged: {
                        console.log(styleData.row + ", Checked: " + checked);
                        root.model.get(styleData.row).selected = checked;
                        root.modelCheckedChanged()
                    }
                }
            }
        }

        TableViewColumn {
            id: colName
            role: "name"
            title: "通道名称"
            width: 200
            delegate: Item {
                clip:true
                anchors.fill: parent

                Text {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: dp(3)
                    }

                    text: styleData.value

                    color: {
                        if ( modelChannel && modelChannel.get(styleData.row) && modelChannel.get(styleData.row).phase)
                            return Global.phaseTypeColor(modelChannel.get(styleData.row).phase)

                        return Qt.rgba(0,0,0,1)//ThemePalette.textColor;
                    }

                    elide: Text.ElideRight



                    font {
                        family: "微软雅黑"
                        weight: Font.Light
                        pixelSize: dp(12)
                    }
                }
            }
        }

        TableViewColumn {
            id: youxiao
            role: "rms"
            title: "有效值"
            width: 100
            delegate: Item {
                anchors.fill: parent
                clip: true
                Text{
                    anchors.verticalCenter: parent.verticalCenter
                    text: styleData.value
                    elide: Text.ElideRight
                }
            }
        }

        TableViewColumn {
            id: angle
            role: "angle"
            title: "相角"
            width: 100
            delegate: Item {
                anchors.fill: parent
                clip: true
                Text{
                    anchors.verticalCenter: parent.verticalCenter
                    text: styleData.value
                    elide: Text.ElideRight
                }
            }
        }

        TableViewColumn {
            id: phase
            role: "phase"
            title: "相别"
            width: 60
            horizontalAlignment: Text.AlignHCenter
            delegate: Item {
                id: cc
                anchors.fill: parent
                clip: true
                property alias text: content.text

                Text{
                    id: content
                    anchors.centerIn: parent;
                    text: styleData.value
                    elide: Text.ElideRight

                    color: Global.phaseTypeColor(text)
                }

//                Rectangle {
//                    visible: content.text

//                    anchors {
//                        fill: parent
//                        leftMargin: (parent.width - content.width) / 3
//                        rightMargin: (parent.width - content.width) / 3
//                        topMargin: (parent.height - content.height) / 3
//                        bottomMargin: (parent.height - content.height) / 3
//                    }
//                    color: "transparent"
//                    border.color: content.color
//                }
            }
        }

        TableViewColumn {
            id: unit
            role: "unit"
            title: "单位"
            width: 60
            horizontalAlignment: Text.AlignHCenter
            delegate: Item {
                anchors.fill: parent
                clip: true
                Text{
                    id:txt2
                    anchors.centerIn: parent;
                    text: styleData.value
                    elide: Text.ElideRight
                }
            }
        }

        TableViewColumn {
            id: precision
            role: "precision"
            title: "精度系数"
            width: 100
            delegate: Item {
                anchors.fill: parent
                clip: true
                Text{
                    anchors.centerIn: parent;
                    text: styleData.value
                    elide: Text.ElideRight
                }
            }
        }


    }

    Component
    {
        id: columnComponent
        TableViewColumn{ width: 100 }
    }

    Component.onCompleted: {
        if (root.model){
            modelChannel.updateModel();
            log("on vector table view ")
        }
    }
}
