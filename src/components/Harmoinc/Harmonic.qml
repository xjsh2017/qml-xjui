import QtQuick 2.4
import Material 0.2
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

//import XjUi 1.0
import "../Charts"
import "../../core"

Item {
    id: me

    // ///////////////////////////////////////////////////////////////

    property var model: Calculator.model
    property int currentIndex: -1;      // 通道


    // ///////////////////////////////////////////////////////////////

    function dp(di){
        return di;
    }

    function randomScalingFactor() {
        return Math.round(Math.random() * 100);
    }

    function updateChartData() {
        if (currentIndex < 0)
            return;

//        {
//                        "datasets": [{
//                                         "data": [randomScalingFactor(),
//                                             randomScalingFactor(),
//                                             randomScalingFactor(),
//                                             randomScalingFactor(),
//                                             randomScalingFactor(),
//                                             randomScalingFactor(),
//                                             randomScalingFactor(),
//                                             randomScalingFactor()
//                                         ],
//                                         "backgroundColor": [randomColor(),
//                                             randomColor(),
//                                             randomColor(),
//                                             randomColor(),
//                                             randomColor(),
//                                             randomColor(),
//                                             randomColor(),
//                                             randomColor()
//                                         ],
//                                         "label": '0x4001 谐波分布'
//                                     }],
//                        "labels": ["直流","基波","2次谐波","3次谐波","4次谐波","5次谐波","6次谐波","7次谐波"]
//                    }

//        var js = {}

        for (var i = 0; i <= 7; i++){
            chart.chartData.datasets[0].data[i] = (model.harmonic[currentIndex][i].percentage * 100).toFixed(2)
//            if (i == 0)
//                chart.chartData.datasets[0].label[i] = "直流分量： " + model.harmonic[currentIndex][i].amp.toFixed(2)
//                        + ", " + (model.harmonic[currentIndex][i].percentage * 100).toFixed(2) + " %";
//            else if (i == 1)
//                chart.chartData.datasets[0].label[i] = "基波分量： " + model.harmonic[currentIndex][i].amp.toFixed(2)
//                        + ", " + (model.harmonic[currentIndex][i].percentage * 100).toFixed(0) + " %";
//            else
//                chart.chartData.datasets[0].label[i] = i + " 次谐波分量： " + model.harmonic[currentIndex][i].amp.toFixed(2)
//                        + ", " + (model.harmonic[currentIndex][i].percentage * 100).toFixed(2) + " %";
            if (i == 0){
                chart.chartData.labels[i] = "直流";
            }else if (i == 1){
                chart.chartData.labels[i] = "基波";
            }else{
                chart.chartData.labels[i] = i + " 次谐波";
            }
            chart.chartData.datasets[0].backgroundColor[i] = Global.randomColor();
        }
    }

//    onIsModelUpdateChanged: {
//        updateChartData();

//        chart.repaint();
//    }

    onCurrentIndexChanged: {
        updateChartData();

        chart.repaint();
    }

    // ///////////////////////////////////////////////////////////////

    // 工具栏

    // 离散度分析
    View{
        anchors {
            fill: parent
            margins: dp(6)
        }

        elevation: 1


        Chart{
            id: chart


            anchors.fill: parent
            chartType: ChartType.bar;

            onWidthChanged: {
//                console.log(width);
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
                                 "data": [0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0
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
                                 "label": '谐波分布'
                             }],
                "labels": ["直流","基波","2次谐波","3次谐波","4次谐波","5次谐波","6次谐波","7次谐波"]
            }

        }

    }

}
