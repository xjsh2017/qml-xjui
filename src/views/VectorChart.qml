import QtQuick 2.4
import Material 0.2
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

import "."
import "./Charts"

Item {
    id: me

    function dp(di){
        return di;
    }

    function randomScalingFactor() {
        return Math.round(Math.random() * 100);
    }

    // 工具栏


    // 离散度分析
    View{
        anchors {
            fill: parent
            margins: dp(6)
        }

        elevation: 1


        Rectangle {
            id: outerCircle
            anchors {
                centerIn: parent
                margins: dp(16)
            }

            height: parent.height - dp(48)
            width: height

            radius: width / 2

            border.color: "lightgray"
            color: "transparent"

            Rectangle {
                id: axisX
                anchors.centerIn: parent
                height: dp(1)
                width: parent.width + dp (8)

                border.color: "lightgray"
                color: "lightgray"
            }

            Label {
                text: "180°"
                color: Theme.light.textColor
                x: axisX.x - dp(28)
                anchors.verticalCenter: axisX.verticalCenter
            }

            Label {
                text: "0°"
                color: Theme.light.textColor
                x: axisX.x + axisX.width
                anchors.verticalCenter: axisX.verticalCenter
            }

            Rectangle {
                anchors.centerIn: parent
                height: dp(1)
                width: parent.width + dp (8)

                border.color: "lightgray"
                color: "lightgray"

                Label {
                    text: "135°"
                    color: Theme.light.textColor
                    x: parent.x - dp(20)
                    anchors.verticalCenter: parent.verticalCenter

                    rotation: -90
                }

                Label {
                    text: "-45°"
                    color: Theme.light.textColor
                    x: parent.x + parent.width + dp(3)
                    anchors.verticalCenter: parent.verticalCenter

                    rotation: -90
                }

                rotation: 45
            }

            Rectangle {
                id: axisY
                anchors.centerIn: parent
                width: dp(1)
                height: parent.height + dp (8)

                border.color: "lightgray"
                color: "lightgray"

                Label {
                    text: "90°"
                    color: Theme.light.textColor
                    y: axisY.y - dp(12)
                    anchors.horizontalCenter: axisY.horizontalCenter
                }

                Label {
                    text: "-90°"
                    color: Theme.light.textColor
                    y: axisY.y + axisY.height + dp(3)
                    anchors.horizontalCenter: axisY.horizontalCenter
                }

                Label {
                    text: "0"
                    color: Theme.light.textColor
                    y: axisY.y + axisY.height / 8 * 4 + dp(2)
                    anchors.horizontalCenter: axisY.horizontalCenter
                    anchors.horizontalCenterOffset: dp(6)
                }

                Label {
                    text: "0.25"
                    color: Theme.light.textColor
                    y: axisY.y + axisY.height / 8 * 3
                    anchors.horizontalCenter: axisY.horizontalCenter
                }

                Label {
                    text: "0.50"
                    color: Theme.light.textColor
                    y: axisY.y + axisY.height / 8 * 2
                    anchors.horizontalCenter: axisY.horizontalCenter
                }

                Label {
                    text: "0.75"
                    color: Theme.light.textColor
                    y: axisY.y + axisY.height / 8 * 1
                    anchors.horizontalCenter: axisY.horizontalCenter
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: dp(1)
                height: parent.height + dp (8)

                border.color: "lightgray"
                color: "lightgray"

                Label {
                    text: "45°"
                    color: Theme.light.textColor
                    y: parent.y - dp(12)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    text: "-135°"
                    color: Theme.light.textColor
                    y: parent.y + parent.height + dp(3)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                rotation: 45
            }

            // 示例

            Rectangle {
                height: dp(8)
                width: height

                radius: height / 2

                border.color: "lightgray"
                color: "red"

                x: dp(72)
                y: dp(72)
            }

            Rectangle {
                height: dp(8)
                width: height

                radius: height / 2

                border.color: "lightgray"
                color: "blue"

                x: axisX.x + axisX.width *0.25
                y: axisX.y - axisY.height / 2 * 0.3
            }

            Rectangle {
                height: dp(8)
                width: height

                radius: height / 2

                border.color: "lightgray"
                color: "yellow"

                x: axisY.x
                y: axisX.y + axisY.height / 2 * 0.7
            }

            Canvas {
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext('2d')
                    ctx.lineWidth = dp(2)
                    ctx.strokeStyle = "red"
                    ctx.beginPath()
                    ctx.moveTo(outerCircle.width/2, outerCircle.width/2)
                    ctx.lineTo(dp(80), dp(80))

                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(dp(80), dp(80))
                    ctx.lineTo(dp(83), dp(87))
                    ctx.lineTo(dp(87), dp(83))
                    ctx.closePath();
                    ctx.stroke()
                }
            }
        }

        Rectangle {
            anchors {
                centerIn: parent
                margins: dp(16)
            }

            height: outerCircle.height * 3 / 4
            width: height

            radius: width / 2

            border.color: "lightgray"
            color: "transparent"
        }

        Rectangle {
            anchors {
                centerIn: parent
                margins: dp(16)
            }

            height: outerCircle.height * 2 / 4
            width: height

            radius: width / 2

            border.color: "lightgray"
            color: "transparent"


        }

        Rectangle {
            anchors {
                centerIn: parent
                margins: dp(16)
            }

            height: outerCircle.height * 1 / 4
            width: height

            radius: width / 2

            border.color: "lightgray"
            color: "transparent"
        }




    }

}
