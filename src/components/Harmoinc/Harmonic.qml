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

    property int currentIndex: -1;      // 通道
    property int showHarmonTimes: 7;          // 谐波次数

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

        var title = "谐波分布"
        var name = AnalDataModel.getPropValue(currentIndex, "name");
        if (name)
            title += " - " + name;
        chart.chartData.datasets[0].label = title;
        chart.chartData.datasets[0].data.length = showHarmonTimes + 1
        chart.chartData.labels.length = showHarmonTimes + 1;
        for (var i = 0; i <= showHarmonTimes; i++){
            var harmon_value = AnalDataModel.getHarmonValue(currentIndex, i);
            if (AnalDataModel.isHarmonValueValid(harmon_value))
                chart.chartData.datasets[0].data[i] = (harmon_value.percentage * 100).toFixed(2);
            else
                chart.chartData.datasets[0].data[i] = 0;

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

    onCurrentIndexChanged: {
        if (currentIndex < 0)
            return;
        updateChartData();

        chart.repaint();
    }

    onShowHarmonTimesChanged: {
        log("onShowHarmonTimesChanged")
        if (currentIndex < 0)
            return;
        updateChartData();

        chart.repaint();
    }

    Connections {
        target: AnalDataModel

        onAnalyzerResultUpdated: {
            if (currentIndex < 0)
                return;
            updateChartData();

            chart.repaint();

        }
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

    // ///////////////////////////////////////////////////////////////

    function log(says) {
        console.log("## Harmonic.qml ##: " + says);
    }

    // ///////////////////////////////////////////////////////////////

    Component.onCompleted: {
        try {

        } catch (error) {
            // Ignore the error; it only means that the fonts were not enabled
        }

        log("Component.onCompleted")
    }

    Component.onDestruction: {
        log("Component.onDestruction")
    }

}
