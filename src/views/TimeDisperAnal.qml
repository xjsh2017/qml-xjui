import QtQuick 2.4
import Material 0.2
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

//import "."
import "../components/Charts"
import "../core"
//import XjUi 1.0

Item {
    id: me


    // ///////////////////////////////////////////////////////////////

    property var model: Calculator.model
    property bool isModelUpdate: Calculator.isNeedUpdate


    // ///////////////////////////////////////////////////////////////


    function log(says) {
        console.log("## TimeDisperAnal.qml ##: " + says);
    }

    // ///////////////////////////////////////////////////////////////

    function updateChartData() {
        var result = Calculator.analTimeDisper();

        chart.chartData.labels = ["<-10","-10","-9","-8","-7","-6","-5","-4","-3","-2","-1","0"
                                   ,"1","2","3","4","5","6","7","8","9","10",">10"];

        chart.chartData.datasets[0].data = [
                    result.static.neg_nup11us,
                    result.static.neg_n10us,
                    result.static.neg_n9us,
                    result.static.neg_n8us,
                    result.static.neg_n7us,
                    result.static.neg_n6us,
                    result.static.neg_n5us,
                    result.static.neg_n4us,
                    result.static.neg_n3us,
                    result.static.neg_n2us,
                    result.static.neg_n1us,
                    result.static.n0us,
                    result.static.n1us,
                    result.static.n2us,
                    result.static.n3us,
                    result.static.n4us,
                    result.static.n5us,
                    result.static.n6us,
                    result.static.n7us,
                    result.static.n8us,
                    result.static.n9us,
                    result.static.n10us,
                    result.static.nup11us
                ]
        for　(var i = 0; i < chart.chartData.labels.length; i++){
            chart.chartData.datasets[0].backgroundColor[i] = Global.randomColor();
        }

        chart.chartData.datasets[0].label = result.title;

        log("Title = " + result.title)
    }

    function update() {
        updateChartData()

        chart.repaint();
    }


    // ///////////////////////////////////////////////////////////////

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

            chartData: {
                "datasets": [{
                                 "data": [0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0,
                                     0
                                 ],
                                 "backgroundColor": [Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor(),
                                     Global.randomColor()
                                 ],
                                 "label": ' -- '
                             }],
                "labels": ["<-10","-10","-9","-8","-7","-6","-5","-4","-3","-2","-1","0"
                           ,"1","2","3","4","5","6","7","8","9","10",">10"]
            }

        }

    }

    Component.onCompleted: {
        update();
    }

}
