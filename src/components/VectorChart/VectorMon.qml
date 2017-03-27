import QtQuick 2.0

import Material 0.3
//import XjUi 1.0

import "../../core"

Canvas {

    id: canvas;

    // ///////////////////////////////////////////////////////////////

    property    var model: AnalDataModel.listModel
    property    int selectHarmonTimes: 0
    property    int baseChannelIndex: 0
    property    int showType: 0

    property    var ctx;
    property    var plotArea;        // 绘图区域
    property    var plotMargins: {
                    "leftMargin": dp(10),
                    "rightMargin": dp(10),
                    "topMargin": dp(10),
                    "bottomMargin": dp(10)
    };

    property    real fontSize: 12;
    property    real maxRMS: 0;
    property    real refAngle: 0;

    // ///////////////////////////////////////////////////////////////

    Connections {
        target: AnalDataModel

        onChannelPropUpdated:{
            log("json = " + AnalDataModel.json);

            repaint();
        }
    }

    // ///////////////////////////////////////////////////////////////

    function dp(di){
        return di;
    }

    function init() {
    }

    function repaint() {
        requestPaint();
    }

    function log(says) {
        console.log("# VectorMon.qml: # " + says);
    }

    function debug(de) {
        if (!de)
            log("-------------debug------------")
        else
            log("-------------" + de + "------------")
    }

    function getRBound() {
        if (!canvas.model)
            return;

        if (canvas.model.count < 0)
            return;

        var len = canvas.model.count;

        var tmp = 0;
        for (var i = 0; i < len; i++){
            if (!model.get(i).checked || !model.get(i).visible)
                continue;

            if (selectHarmonTimes == 0){
                if (parseFloat(model.get(i).rms) > tmp){
                    tmp = parseFloat(model.get(i).rms);
                    log("checked channel index = " + i + ", model.rms = " + parseFloat(model.get(i).rms));
                }
            }else{
                var harmon_value = AnalDataModel.getHarmonValue(i, selectHarmonTimes);
                if (!AnalDataModel.isHarmonValueValid(harmon_value))
                    continue;

                if (harmon_value.rms > tmp){
                    tmp = harmon_value.rms;
                    log("checked channel index = " + i + ", harmon: " + selectHarmonTimes
                        + ", harmon.rms = " + harmon_value.rms);
                }
            }
        }

        maxRMS = tmp;

        log("max rms = " + maxRMS);

        if (maxRMS < 0.001)
            maxRMS = 1;

        return tmp;
    }

    function updateRefAnagle() {
        if (showType == 0)
            refAngle = 0.0;
        else if (baseChannelIndex >= 0){
            if (selectHarmonTimes == 0){
                refAngle = parseInt(AnalDataModel.getPropValue(baseChannelIndex, "angle"));
            }else{
                var harmon_value = AnalDataModel.getHarmonValue(baseChannelIndex, selectHarmonTimes);
                if (!AnalDataModel.isHarmonValueValid(harmon_value))
                    refAngle = 0.0;
                else
                    refAngle = harmon_value.angle;
            }

        }
    }

    // ///////////////////////////////////////////////////////////////


    onPaint: {
        initSize();

        drawScale();

        drawVectors();
    }

    onRefAngleChanged: {
        log("onRefAngleChanged: refAngle = " + refAngle)
        repaint();
    }

    onSelectHarmonTimesChanged: {
        updateRefAnagle();

        log("detected~ showType = " + showType + ", refAngle = " + refAngle)
        repaint();
    }

    onShowTypeChanged: {
        updateRefAnagle();

        repaint();
    }

    onBaseChannelIndexChanged: {
        updateRefAnagle();

        repaint();
    }

    // ///////////////////////////////////////////////////////////////

    function initSize() {
        var leftTop, rightBottom, center, plotWidth, plotHeight;

        var actWidth = width - plotMargins.leftMargin - plotMargins.rightMargin;
        var actHeight = height - plotMargins.topMargin - plotMargins.bottomMargin;
        if (actHeight < actWidth){
            leftTop = Qt.point((actWidth - actHeight) / 2, plotMargins.topMargin);
            rightBottom = Qt.point((actWidth + actHeight) / 2, height - plotMargins.bottomMargin);
        }else{
            leftTop = Qt.point(plotMargins.leftMargin, (actHeight - actWidth) / 2 + plotMargins.topMargin);
            rightBottom = Qt.point(width - plotMargins.rightMargin,  (actHeight + actWidth)/2 - plotMargins.bottomMargin);
        }
        plotWidth = rightBottom.x - leftTop.x;
        plotHeight = rightBottom.y - leftTop.y;
        center = Qt.point(leftTop.x + plotWidth / 2, leftTop.y + plotHeight / 2);

        plotArea = {
            leftTop: leftTop,
            rightBottom: rightBottom,
            center: center,
            width: plotWidth,
            height: plotHeight,
            r: plotWidth / 2 - fontSize - dp(3)
        }

//        var says = "init size: "
//                + "\n\t Canvas: width = " + width.toFixed(3) + ", height = " + height.toFixed(3)
//                + "\n\t Margins: (" + plotMargins.leftMargin + ", " + plotMargins.rightMargin + ", "
//                    + plotMargins.topMargin + ", " + plotMargins.bottomMargin + ")"
//                + "\n\t Plot Area: width = " + plotArea.width.toFixed(3) + ", height = " + plotArea.height.toFixed(3)
//                + "\n\t\t leftTop = (" + plotArea.leftTop.x.toFixed(3) + ", " + plotArea.leftTop.y.toFixed(3) + ")"
//                + "\n\t\t rightBottom = (" + plotArea.rightBottom.x.toFixed(3) + ", " + plotArea.rightBottom.y.toFixed(3) + ")"
//                + "\n\t\t center = (" + plotArea.center.x.toFixed(3) + ", " + plotArea.center.y.toFixed(3) + ")"

//        log(says)
    }

    function drawScale() {
        var posx1, posx2, posy1, posy2, outlen, polarR;
        var ctx = getContext("2d")

        outlen = dp(5);

        polarR = plotArea.r + outlen;

        var widthfont = ctx.measureText("90").width / 2;

        ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        // 设置画笔
        ctx.lineWidth = 1
        ctx.strokeStyle = "grey"
        ctx.fillStyle = Global.g_plotBackgroundColor
        ctx.fillRect(dp(3), dp(3), width - dp(6), height-dp(6));

        getRBound();

        ctx.beginPath();
        ctx.arc(plotArea.center.x, plotArea.center.y, plotArea.r, 2 * Math.PI, false);
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(plotArea.center.x, plotArea.center.y, plotArea.r * 2/3, 2 * Math.PI, false);
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(plotArea.center.x, plotArea.center.y, plotArea.r * 1/3, 2 * Math.PI, false);
        ctx.stroke();

        ctx.fillStyle = "white"
        ctx.font = fontSize + "px 微软雅黑"
        if (maxRMS > 0){
            ctx.save();
            ctx.font = fontSize * 5/6 + "px 微软雅黑"
            ctx.fillStyle = Theme.accentColor

            ctx.fillText("0", plotArea.center.x + dp(4), plotArea.center.y + fontSize * 2);
            ctx.fillText(maxRMS.toFixed(2), plotArea.center.x + dp(2), plotArea.leftTop.y + fontSize * 2);
            ctx.fillText((maxRMS * 2/3).toFixed(2), plotArea.center.x + dp(2), plotArea.leftTop.y + plotArea.r / 3 + fontSize * 2);
            ctx.fillText((maxRMS * 1/3).toFixed(2), plotArea.center.x + dp(2), plotArea.leftTop.y + plotArea.r * 2 / 3 + fontSize * 2);

            ctx.restore();
        }


        ctx.beginPath();
        ctx.moveTo(plotArea.leftTop.x, plotArea.center.y);
        ctx.lineTo(plotArea.rightBottom.x, plotArea.center.y);
        ctx.stroke();

        ctx.fillText("180°", plotArea.leftTop.x - widthfont * 2, plotArea.center.y + fontSize / 3);
        ctx.fillText("0°", plotArea.rightBottom.x - widthfont, plotArea.center.y + fontSize / 3);

        ctx.beginPath();
        ctx.moveTo(plotArea.center.x, plotArea.leftTop.y);
        ctx.lineTo(plotArea.center.x, plotArea.rightBottom.y);
        ctx.stroke();
        ctx.fillText("90°", plotArea.center.x - widthfont, plotArea.leftTop.y + fontSize / 2);
        ctx.fillText("-90°", plotArea.center.x - widthfont * 2, plotArea.rightBottom.y + fontSize / 2);

        posx1 = plotArea.center.x + polarR * Math.sin(Math.PI / 3);
        posy1 = plotArea.center.y - polarR * Math.cos(Math.PI / 3);
        posx2 = plotArea.center.x + polarR * Math.sin(-Math.PI * 2 / 3);
        posy2 = plotArea.center.y - polarR * Math.cos(-Math.PI * 2 / 3);

        ctx.beginPath();
        ctx.moveTo(posx1, posy1);
        ctx.lineTo(posx2, posy2);
        ctx.stroke();

        ctx.fillText("30°", posx1 + widthfont / 2, posy1 + fontSize / 4);
        ctx.fillText("-150°", posx2 - widthfont * 4, posy2 + fontSize);


        posx1 = plotArea.center.x + polarR * Math.sin(Math.PI / 6);
        posy1 = plotArea.center.y - polarR * Math.cos(Math.PI / 6);
        posx2 = plotArea.center.x + polarR * Math.sin(-Math.PI * 5 / 6);
        posy2 = plotArea.center.y - polarR * Math.cos(-Math.PI * 5 / 6);

        ctx.beginPath();
        ctx.moveTo(posx1, posy1);
        ctx.lineTo(posx2, posy2);
        ctx.stroke();

        ctx.fillText("60°", posx1, posy1);
        ctx.fillText("-120°", posx2 - widthfont * 3, posy2 + fontSize);


        posx1 = plotArea.center.x + polarR * Math.sin(-Math.PI / 3);
        posy1 = plotArea.center.y - polarR * Math.cos(-Math.PI / 3);
        posx2 = plotArea.center.x + polarR * Math.sin(Math.PI * 2 / 3);
        posy2 = plotArea.center.y - polarR * Math.cos(Math.PI * 2 / 3);
        ctx.beginPath();
        ctx.moveTo(posx1, posy1);
        ctx.lineTo(posx2, posy2);
        ctx.stroke();

        ctx.fillText("-30°", posx2, posy2 + fontSize / 2);
        ctx.fillText("150°", posx1 - widthfont * 3, posy1 - fontSize / 2);

        posx1 = plotArea.center.x + polarR * Math.sin(-Math.PI / 6);
        posy1 = plotArea.center.y - polarR * Math.cos(-Math.PI / 6);
        posx2 = plotArea.center.x + polarR * Math.sin(Math.PI * 5 / 6);
        posy2 = plotArea.center.y - polarR * Math.cos(Math.PI * 5 / 6);
        ctx.beginPath();
        ctx.moveTo(posx1, posy1);
        ctx.lineTo(posx2, posy2);
        ctx.stroke();

        ctx.fillText("-60°", posx2 , posy2 + fontSize);
        ctx.fillText("120°", posx1 - widthfont * 2, posy1 - fontSize / 2);

    }

    function drawVectors() {
        if (!canvas.model)
            return;

        if (canvas.model.count < 0)
            return;

        var len = canvas.model.count;

        for (var i = 0; i < len; i++){
            if (!model.get(i).checked || !model.get(i).visible)
                continue;

            var color = Global.phaseTypeColor(model.get(i).phase);
            if (selectHarmonTimes == 0)
                drawVector(getContext("2d"), parseFloat(model.get(i).rms), parseFloat(model.get(i).angle), color)
            else{
                var harmon_value = AnalDataModel.getHarmonValue(i, selectHarmonTimes);
                if (!AnalDataModel.isHarmonValueValid(harmon_value))
                    continue;

                drawVector(getContext("2d"), (harmon_value.rms  < 0.001 ? 1 : harmon_value.rms)
                           , harmon_value.angle, color)
            }
        }
    }

    function calcArrowPoints(x0, y0, x, y, r, angle){
        angle = angle * Math.PI / 180;

        var c = Math.cos(angle) * r * Math.sqrt((x-x0)*(x-x0) + (y - y0)*(y - y0));

        var d = Math.sqrt(-c*c + r*r*x*x - 2*r*r*x*x0 + r*r*x0*x0 + r*r*y*y - 2*r*r*y*y0 + r*r *y0*y0);
        var e = (x*x - 2*x*x0 + x0*x0 + y*y - 2*y*y0 + y0*y0);

        var v1 = (x*x*x - 2*x0*x*x + (x0*x0 + y*y-2*y*y0+y0*y0-c) *x + y0*d - y*d + c*x0) / e;
        var v2 = (x*x*x - 2*x0*x*x + (x0*x0 + y*y-2*y*y0+y0*y0-c) *x + y*d - y0*d + c*x0) / e;

        var x1 = { 1: v1, 2: v2, 3: v1, 4: v2 }
        var x2 = { 1: v1, 2: v1, 3: v2, 4: v2 }

        var m1 = (y*x*x + (d - 2*x0*y) *x + c*y0 - c*y - x0*d + x0*x0*y + y*y0*y0 - 2*y*y*y0 + y*y*y) / e ;
        var m2 = (y*x*x + (-d - 2*x0*y) *x + x0*d - c*y + c*y0 + x0*x0*y + y*y0*y0 - 2*y*y*y0 + y*y*y) / e ;

        var y1 = { 1: m1, 2: m2, 3: m1, 4: m2 }
        var y2 = { 1: m1, 2: m1, 3: m2, 4: m2 }

//        log("p0: " + Qt.point(x0, y0) + ", p: " + Qt.point(x,y)
//                    + "\n\t r = " + r + ", angle = " + (angle * 180 / Math.PI).toFixed(3)
//                    + "\n\t c = " + c
//                    + "\n\t d = " + d
//                    + "\n\t e = " + e
//                    + "\n\t v1 = " + v1
//                    + "\n\t v2 = " + v2
//                    + "\n\t m1 = " + m1
//                    + "\n\t m2 = " + m2
//                    + "\n\t p1 = " + Qt.point(x1[2], y1[2])
//                    + "\n\t p1 = " + Qt.point(x2[2], y2[2])
//                    )

        return {
            p1: Qt.point(x1[2], y1[2]),
            p2: Qt.point(x2[2], y2[2])
        }
    }

    function drawVector(ctx, r, angle, color) {
//        console.log("r = " + r + ", angle = " + angle)
//        console.log(typeof r + ", " + typeof angle)

        log("drawVector： refAngle = " + refAngle)
        r = parseFloat(r);
        angle = parseFloat(angle) - refAngle;
        var posx0, posy0, posx, posy

        r = maxRMS > 0 ? plotArea.r * r / maxRMS : 2;

//        console.log(r);

        angle = angle * Math.PI / 180;

        ctx.lineWidth = 2
        ctx.strokeStyle = color
        ctx.fillStyle = color

        ctx.beginPath();
        posx0 = plotArea.center.x;
        posy0 = plotArea.center.y;
        posx = plotArea.center.x + r * Math.cos(angle);
        posy = plotArea.center.y - r * Math.sin(angle);
        ctx.moveTo(posx0, posy0);
        ctx.lineTo(posx, posy);

        ctx.stroke();

        var p = calcArrowPoints(posx0, posy0, posx, posy, dp(10), 20);

        ctx.beginPath();
        ctx.moveTo(posx, posy);
        ctx.lineTo(p.p1.x, p.p1.y);
        ctx.lineTo(p.p2.x, p.p2.y);
        ctx.closePath();
        ctx.fill();
    }

    // ///////////////////////////////////////////////////////////////

    Rectangle {
        width: plotArea ? plotArea.width : 0
        height: plotArea ? plotArea.height : 0
        x: plotArea && plotArea.leftTop ? plotArea.leftTop.x : 0
        y: plotArea && plotArea.leftTop ? plotArea.leftTop.y : 0

        border.color: Theme.accentColor
        color: "transparent"

        visible: false
    }

    Timer {
        id: runningTimer;
        repeat: true;
        interval: 3000;
        triggeredOnStart: true;
        onTriggered: {
        }
    }

    PropertyAnimation {
        id: chartAnimator;
        target: canvas;
        property: "chartAnimationProgress";
        to: 100;
        duration: 500;
        easing.type: Easing.InOutElastic;
    }

    ActionButton {
        visible: false
        width: dp(36)
        height: dp(36)

        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: dp(16)
        }

        iconName: "action/view_list"

        onClicked: {

        }
    }


    Component.onCompleted: {
        init();
    }
}
