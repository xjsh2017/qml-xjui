/* QChart.qml ---
 *
 * Author: Julien Wintz
 * Created: Thu Feb 13 20:59:40 2014 (+0100)
 * Version:
 * Last-Updated: jeu. mars  6 12:55:14 2014 (+0100)
 *           By: Julien Wintz
 *     Update #: 69
 */

/* Change Log:
 *
 */

import QtQuick 2.0
import "QChart.js" as Charts

Canvas {

  id: canvas;

// ///////////////////////////////////////////////////////////////

  property   var chart;
  property   var chartData;
  property   var chartOptions;
  property   int chartType: 0;
  property  bool chartAnimated: true;
  property alias chartAnimationEasing: chartAnimator.easing.type;
  property alias chartAnimationDuration: chartAnimator.duration;
  property   int chartAnimationProgress: 0;
  property   int chart_index: -1;

  property  real lastX
  property  real lastY

// /////////////////////////////////////////////////////////////////
// Callbacks
// /////////////////////////////////////////////////////////////////

  onPaint: {
      if(!chart) {

          switch(chartType) {
          case Charts.ChartType.BAR:
              chart = new Charts.Chart(canvas, canvas.getContext("2d")).Bar(chartData);
              break;
          case Charts.ChartType.DOUGHNUT:
              chart = new Charts.Chart(canvas, canvas.getContext("2d")).Doughnut(chartData);
              break;
          case Charts.ChartType.LINE:
              chart = new Charts.Chart(canvas, canvas.getContext("2d")).Line(chartData, chartOptions);
              break;
          case Charts.ChartType.PIE:
              chart = new Charts.Chart(canvas, canvas.getContext("2d")).Pie(chartData);
              break;
          case Charts.ChartType.POLAR:
              chart = new Charts.Chart(canvas, canvas.getContext("2d")).PolarArea(chartData);
              break;
          case Charts.ChartType.RADAR:
              chart = new Charts.Chart(canvas, canvas.getContext("2d")).Radar(chartData);
              break;
          default:
              console.log('Chart type should be specified.');
          }

          chart.init();

          if (chartAnimated)
              chartAnimator.start();
          else
              chartAnimationProgress = 100;
      }

      chart.draw(chartAnimationProgress/100);
  }

  onHeightChanged: {
    requestPaint();
  }

  onWidthChanged: {
    requestPaint();
      console.log(width)
  }

  onChartAnimationProgressChanged: {
      requestPaint();
  }

  MouseArea {
      id: area
      anchors.fill: parent
      onPressed: {
          canvas.lastX = mouseX
          canvas.lastY = mouseY

//          canvas.chartData.labels = waveModel.x_data(index);
//          canvas.chartData.datasets[0].data = waveModel.y_data(index)
//          console.log(" chartData X:  " + canvas.chartData.labels)

          console.log(" X:  " + mouseX + ", Y: " + mouseY)

          requestPaint()
      }

      onPositionChanged: {
          canvas.requestPaint()
      }
  }

//  Timer {
//        id: timer1;
//        repeat: true;
//        interval: 2000;
//        triggeredOnStart: true;
//        onTriggered: {
//            // ... add code here
//            console.log("chartOptions.pointDot = " + chartOptions.pointDot);
//            chartOptions.pointDot = !chartOptions.pointDot;

//            requestPaint()
//        }
//    }

//    Component.onCompleted: {
//        timer1.start();
//    }

// /////////////////////////////////////////////////////////////////
// Functions
// /////////////////////////////////////////////////////////////////

  function repaint() {
      chartAnimationProgress = 100;
      chartAnimator.start();
  }

// /////////////////////////////////////////////////////////////////
// Internals
// /////////////////////////////////////////////////////////////////

  PropertyAnimation {
             id: chartAnimator;
         target: canvas;
       property: "chartAnimationProgress";
             to: 100;
       duration: 500;
    easing.type: Easing.InOutElastic;
  }
}
