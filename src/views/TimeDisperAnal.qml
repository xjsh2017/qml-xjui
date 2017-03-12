import QtQuick 2.4
import Material 0.2
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

import "."
import "../components/Charts"

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


        Chart{
            anchors.fill: parent
            chartType: ChartType.bar;

            onWidthChanged: {
                console.log(width);
            }

            function randomScalingFactor() {
                return Math.round(Math.random() * 100);
            }

            function randomColor() {
                return Qt.rgba(Math.random(),
                               Math.random(), Math.random(), 1);
            }

            chartData: {
                "datasets": [{
                                 "data": [randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor(),
                                     randomScalingFactor()
                                 ],
                                 "backgroundColor": [randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor()
                                 ],
                                 "label": '0x4001 总帧数： 99685  合格帧数： 99685  合格率： 100.0% （帧间差 -250us ≤ 10us）  帧速： 4000帧/s  流量： 9.125 Mb/s  持续时间： 24.921 s'
                             }],
                "labels": ["<-10","-10","-9","-8","-7","-6","-5","-4","-3","-2","-1","0"
                           ,"1","2","3","4","5","6","7","8","9","10",">10"]
            }

        }

    }

}
