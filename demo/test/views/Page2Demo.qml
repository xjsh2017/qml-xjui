import QtQuick 2.0

import Material 0.3
import XjUi 1.0

import QtQuick.Layouts 1.1

Item {
    //    TimeDisperAnal {
    //        anchors.fill: parent
    //    }

    View {
        anchors.fill: parent
        elevation: 1

        // 波形标尺
        View {
            id: axis_wave

            //            color: "transparent"
            elevation: 2
            height: dp(76)
            //            border.color: "black"
            //            border.width: dp(1)

            //            Layout.fillWidth: true
            width: parent.width

            anchors {
                top: parent.top
                topMargin: dp(24)
            }

            RowLayout {
                anchors.fill: parent

                Column {
                    id: chart_info_title_panel
                    width: dp(160)
                    //                    Layout.fillHeight: true

                    height: parent.height

                    anchors {
                        //                        topMargin: dp(18)
                        verticalCenter: parent.verticalCenter
                    }

                    spacing: dp(6)

                    Item {
                        width: dp(160)//parent.width - dp(1)
                        height: labelTitle.height

                        Rectangle {
                            height: parent.height
                            width: dp(5)
                            color: "green"

                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            id: labelTitle
                            text: "0x4001"
                            color: Theme.light.textColor

                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: dp(20)
                            }

                            MagicDivider {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.bottom
                                }

                                styleDivider:  2
                                dash_len: 3
                                color: "green"
                            }
                        }
                    }

                    Item {
                        width: dp(160)//parent.width - dp(1)
                        height: labelMac.height

                        Rectangle {
                            height: parent.height
                            width: dp(5)
                            color: Theme.accentColor

                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            id: labelMac
                            text: "0c-03-2b-c3-7e"
                            color: Theme.light.textColor

                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: dp(20)
                            }

                            MagicDivider {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.bottom
                                }

                                styleDivider:  2
                                dash_len: 3
                                color: Theme.accentColor
                            }
                        }
                    }
                }

                // 坐标轴
                Rectangle {
                    id: axis_groove

                    color: "transparent"

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        height: parent.height
                        width: parent.width

                        border.color: "red"
                    }
                }
            }
        }




        Rectangle {
            width: parent.width
            height: 14 * Units.dp

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

                color: "grey"//Theme.accentColor
                border.color: Qt.lighter(color)

                property real lastX: 0

                Rectangle {
                    width: parent.height * 2 / 4
                    height: width
                    radius: height / 2

                    //                    color: Theme.accentColor

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
