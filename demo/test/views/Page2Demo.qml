import QtQuick 2.0

import Material 0.3
//import XjQmlUi 1.0
import "../../../src/views"

Item {
    //    TimeDisperAnal {
    //        anchors.fill: parent
    //    }

    View {
        anchors.fill: parent
        elevation: 1

        Rectangle {
            width: parent.width
            height: 12 * Units.dp

            visible: handleScroll.width > 0 && handleScroll.width <= width

            radius: height / 2

            anchors.bottom: parent.bottom

            color: "transparent"

            border.color: "lightgrey"



            IconButton {
                iconName: "navigation/arrow_drop_up"
                rotation: -90
                id: previousMonth
                //            anchors.top: parent.top
                //            anchors.topMargin: control.isLandscape ? 12 * Units.dp : 16 * Units.dp
                anchors.left: parent.left
                anchors.leftMargin: -dp(2)

                anchors.verticalCenter: parent.verticalCenter
                //            anchors.leftMargin: 16 * Units.dp
                //            onClicked: control.showPreviousMonth()
            }

            IconButton {
                iconName: "navigation/arrow_drop_down"
                rotation: -90
                id: nextMonth
                //            anchors.top: parent.top
                //            anchors.topMargin: control.isLandscape ? 12 * Units.dp : 16 * Units.dp
                anchors.right: parent.right

                anchors.verticalCenter: parent.verticalCenter
                //            anchors.rightMargin: 16 * Units.dp
                //            onClicked: control.showNextMonth()
            }

            Rectangle {
                id: handleScroll
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height - dp(2)

                radius: height / 2
                width: dp(60)

                color: Theme.accentColor
                border.color: Qt.lighter(color)

                property real lastX: 0

                Rectangle {
                    width: parent.height * 2 / 4
                    height: width
                    radius: height / 2

                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    drag.target: parent

                    onClicked: {
                        log("gr.minimumValue = " + control.minimumValue + ", gr.maximumValue = " + control.maximumValue)
                        log("gr.scrollbarSteps = " + control.scrollbarSteps + ", gr.width = " + control.width)
                        log("gr.scrollbar.width = " + handleScroll.width + ", gr.scrollbar.x = " + handleScroll.x)
                    }
                }

                onXChanged: {
                    if (x <  dp(1))
                        x =  0;
                    if (x > parent.width - width - dp(0))
                        x = parent.width - width - dp(0)

                    panel.tickMarkLoader.x -= control.scrollbarSteps * (x - lastX)

                    panel.grooveLoader.x -= control.scrollbarSteps * (x - lastX)

                    //                log("X = " + x)
                    scrollbarPosChanged(x - lastX, x)
                    lastX  = x;
                }
            }
        }
    }
}
