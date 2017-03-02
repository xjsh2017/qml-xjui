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
                                     randomScalingFactor()
                                 ],
                                 "backgroundColor": [randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor(),
                                     randomColor()
                                 ],
                                 "label": '0x4001 谐波分布'
                             }],
                "labels": ["基波","直流","2次谐波","3次谐波","4次谐波","5次谐波","6次谐波","7次谐波"]
            }

        }

    }

}
