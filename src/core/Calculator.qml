pragma Singleton

import "."
import QtQuick 2.4

/*!
   \qmltype XJElecCalculator
   \inqmlmodule XjUi

   \brief Provides access to standard colors that follow the Material Design specification.

   See \l {http://www.google.com/design/spec/style/color.html#color-ui-color-application} for
   details about choosing a color scheme for your application.
 */
QtObject {
    id: calculator

    // ///////////////////////////////////////////////////////////////

    property var model: {
                // 采样数据
//                          "data": Matlab.sampleSin(10, 100001, 0, 16000, -20, 20, 1250),
//                          "data": Matlab.sampleSin(27, 16001, 0, 16000, -20, 20, 200),
                "data": Matlab.sampleSin(2, 1601, 0, 16000, -20, 20, 20),
                //                          "data": Matlab.sampleSin(14, 1001, 0, 500, -20, 20, 10),

                // 通道数据
                "name": ["通道延时"
                         , "保护A相电流1", "保护A相电流2"
                         , "保护B相电流1", "保护B相电流2"
                         , "保护C相电流1", "保护C相电流2"
                         , "计量A相电流", "计量B相电流", "计量C相电流"
                         , "零序电流I01", "零序电流I02"
                         , "间隙电流Ij1", "间隙电流Ij2"
                         , "保护A相电压1", "保护A相电压2"
                         , "B相电压采样值1", "B相电压采样值2"
                         , "C相电压采样值1", "C相电压采样值2"
                         , "线路抽取电压1", "线路抽取电压2"
                         , "零序电压1", "零序电压2"
                         , "计量A相电压", "计量B相电压", "计量C相电压"],
                "unit": [""
                         , "A", "A"
                         , "A", "A"
                         , "A", "A"
                         , "A", "A", "A"
                         , "A", "A"
                         , "A", "A"
                         , "V", "V"
                         , "V", "V"
                         , "V", "V"
                         , "V", "V"
                         , "V", "V"
                         , "V", "V", "V"],
                "phase": [""
                          , "A", "A"
                          , "B", "B"
                          , "C", "C"
                          , "A", "B", "C"
                          , "N", "N"
                          , "", ""
                          , "A", "A"
                          , "B", "B"
                          , "C", "C"
                          , "", ""
                          , "N", "N"
                          , "A", "B", "C"],

                ncapp_id: 0,    // 链路appid

                // 数据分析
                curSamplePos: 0, // 当前分析采样点索引位置
                maxHarmonicTimes: 19, // 谐波分析的最大谐波次数： 直流、一次谐波（基本分量）、二次谐波....nMax次谐波
                check: [false],   // 当前通道的分析数据是否可见
                isAnal: [true],   // 当前通道的分析数据是否分析
                periodSampleCount: 80, // 一个周波点数
                analSampleCount: 80, // 谐波分析需要的采样点数，从当前采样点索引位置向前数，一般一个周波点数

                amp: [""],        // 每个通道当前索引位置采样点的幅值
                rms: [""],        // 每个通道当前索引位置采样点的有效值
                angle: [""],      // 每个通道当前索引位置采样点的相角
                harmonic: [[]],    // 每个通道当前索引位置采样点的maxHarmonicTimes次谐波分析的结果， 通道数 X maxHarmonicTimes

                // 离散度分析相关
                timeRelastStatic: {},    // 本链路时间均匀度统计
                ftime_relative_first: 0,    // 本链路第一帧报文与采样与采样文件中第一帧的时间差，见CAPCONNECTINFO，单位：秒
                ftime_relative_last:0,   // 最后一帧报文与采样文件中第一帧的时间差
                lTotalCapLenth: 0       // 本链路字节数
    }

    property  bool isNeedUpdate: false;

    property var internalDataModel: waveModel
//    property string test: internalDataModel ? internalDataModel.test : ""

//    onTestChanged: {
//        log("detect changed!")
//    }

    onModelChanged: {
        log("Model Changed !")
    }

    // ///////////////////////////////////////////////////////////////


    function log(says) {
        console.log("## Calculator.qml ##: " + says);
    }

    // ///////////////////////////////////////////////////////////////

    function initModelData() { log("initModelData")
        var channel_count = model.name.length;

        model.check = new Array(channel_count);
        model.isAnal = new Array(channel_count);
        model.amp = new Array(channel_count);
        model.rms = new Array(channel_count);
        model.angle = new Array(channel_count);
        model.harmonic = new Array(channel_count);
        for (var i = 0; i < channel_count; i++){
            model.check[i] = false;
            model.isAnal[i] = true;
            model.amp[i] = 0.0;
            model.rms[i] = 0.0;
            model.angle[i] = 0.0;

            model.harmonic[i] = new Array(19);
            for (var j = 0; j < 19; j++){
                model.harmonic[i][j] = {
                    n: j,
                    real: 0.0,
                    img: 0.0,
                    amp: 0.0,
                    angle: 0.0,
                    percentage: 0.0
                }
            }
        }

        model.timeRelastStatic = {
            n0us: 0, n1us: 0, n2us: 0, n3us: 0, n4us: 0, n5us: 0, n6us: 0, n7us:0, n8us:0, n9us: 0, n10us:0, nup11us:0,
            neg_n1us: 0, neg_n2us: 0, neg_n3us: 0, neg_n4us: 0, neg_n5us: 0, neg_n6us: 0, neg_n7us:0,
            neg_n8us:0, neg_n9us: 0, neg_n10us:0, neg_nup11us:0,

            n4to10us:0, n11to25us:0, n25tous:0
        }
    }

    /*
        从内部数据接口更新模型数据
      */
    function updateModelFromInternalDataAPI(modeldata) {
        if(!modeldata)
            return;

        var Rows = modeldata.rows();
        var Cols = modeldata.cols();
        var x = new Array(Rows);
        var y = new Array(Rows);
        for (var i = 0; i < Rows; i ++){
            y[i] = modeldata.y_data(i);
            x[i] = modeldata.x_data(i);
        }
        model.data = {
            // data:
            x: x,               // matrix: 1 x Cols
            y: y,               // matrix: rows x Cols
            rows: Rows,
            cols: Cols,

            // Functions
            print: Matlab.matrix_print,
            subdata: Matlab.matrix_subdata,

            x_data: Matlab.x_data,
            y_data: Matlab.y_data,

            x_row: Matlab.x_row,
            y_row: Matlab.y_row

        }

        return 0;
    }

    /*!
   Select a color depending on whether the background is light or dark.

   \c input:  输入样本.

   \c out: 计算结果.

   \c sampleCount: 计算所需样本点数（向前取）.

   \c curSamplePos: 计算点.
 */
    function calcRMS(input, curSamplePos, count) {
//        if (typeof input[0] != "number"){
//            log("Error using calcRMS (line 46) \n The 1st argument must be number array type.");
//            return NaN;
//        }
        if (!Matlab.isArray(input)){
            log("calcRMS : input is not array!");
            return;
        }

        var fInput = input.map(parseFloat)

        if (arguments.length < 3){
            log("Error using calcRMS (line 46) \nThere should be 3 arguments at least.");
            return NaN;
        }

        if (!input || input.length < 8 || count < 8 || curSamplePos < count)
            return NaN;

        count = arguments[2] != undefined ? arguments[2] : 80;

        var RMS;
        var amplitude;
        var angle;

        var tmp = 0.0;
        var ex = 0.0;
        var dx;
        var samplearr = [];
        for (var i = curSamplePos + 1 - count; i <= curSamplePos; i++){
            samplearr[i - curSamplePos - 1 + count] = fInput[i];
            tmp += (fInput[i] / 1) * (fInput[i] / 1);
            ex += fInput[i] / 1;
        }
        ex = ex / count;

        var dx = Math.sqrt(tmp/count - ex * ex)
        RMS = Math.sqrt(tmp/count);
        amplitude = Math.sqrt(2) * RMS;
        if (dx > 0)
            angle = calcSinAngle(amplitude, fInput[curSamplePos], fInput[curSamplePos] > fInput[curSamplePos - 1]);
        else
            angle = 0.0;

//        log ("calcRMS: "
//             + "\n\t sample(" + samplearr.length + ") = " + samplearr
//             + "\n\t dx = " + dx + ", ex = " + ex
//             + "\n\t RMS = " + RMS
//             + "\n\t amplitude = " + amplitude
//             + "\n\t angle =" + angle
//        )

        return {
            RMS: RMS,
            amplitude: amplitude,
            angle: angle
        };
    }

    /*!
   Returns true if the color is dark and should have light content on top
 */
    function calcSinAngle(R, value, updown) {
        var fresult = 0.0;

        if (R > 0.00001){
            if ( R < Math.abs(value) )
                return NaN;
            fresult = Math.asin(value/R)*180/Math.PI;
        }
        else
            return NaN

        if (fresult >= 0){
            if (!updown)
                fresult = 180 - fresult;
        }
        else
        {
            if (!updown)
                fresult = - 180 - fresult;
        }

        return fresult;
    }

    /*!
      n次谐波计算 - 傅氏全波差分计算方法

      \c model: 分析数据模型，其数据结构如下

        property var model: {
                          // 采样数据
                          "data": Matlab.sampleSin(15, 1601, 0, 16000, -20, 20, 20),

                          // 通道数据
                          "name": ["计量A相电流", "计量B相电流", "计量C相电流"...],
                          "unit": [ "V", "A", "V"...],
                          "phase": ["A", "B", "C"...],

                          // 数据分析
                          curSamplePos: 0, // 当前分析采样点索引位置
                          maxHarmonicTimes: 7, // 谐波分析的最大谐波次数： 直流、一次谐波（基本分量）、二次谐波....nMax次谐波
                          check: [false],   // 当前通道的分析数据是否可见
                          periodSampleCount: 80, // 一个周波点数
                          analSampleCount: 80, // 谐波分析需要的采样点数，从当前采样点索引位置向前数，一般一个周波点数

                          rms: [""],        // 每个通道当前索引位置采样点的有效值
                          angle: [""],      // 每个通道当前索引位置采样点的相角
                          harmonic: [[]]    // 每个通道当前索引位置采样点的maxHarmonicTimes次谐波分析的结果， 通道数 X maxHarmonicTimes
        }

        采样数据 data 的数据结构如下： { -- 见Matlab定义
            // 数据部分:
            x: x,               // matrix: 1 x Cols
            y: y,               // matrix: rows x Cols
            rows: Rows,
            cols: Cols,

            // Functions
            y_row: ...
        }

        \c index, 通道索引， 为空时，表示计算所有通道

      */
    function analHarmonic(model, index) {
        if (arguments.length < 1){
            log("Error using analHarmonic (line 46) \nThere should be 1 arguments at least.");
            return NaN;
        }
        index = (arguments[1] || arguments[1] == 0) ? arguments[1] : -1;

        var channelModel = model.listModel;
        var sampleModel = model.sampleModel;
        var analModel = model.analModel
        var size = model.getDataSize();

        if (!isModelValid(model)
                || size.cols < analModel.periodSampleCount
                || model.curSamplePos < analModel.periodSampleCount)
            return NaN;
        log("analHarmonic: rows = " + size.rows + ", cols = " + size.cols)
        log("analHarmonic: curSamplePos = " + analModel.curSamplePos)

        var period = analModel.periodSampleCount;
        var pos = analModel.curSamplePos;
        var nMax = analModel.maxHarmonicTimes;

        // 逐个通道分析
        for (var i = 0; i < size.rows; i++){
            if (index != -1 && i != index)
                continue;

            log("harmonic: " + i + ", anal started ...");

            var input = sampleModel.y_row(i, pos - period, pos).data;

            channelModel.get(i).harmonic[0] = analDC(input);
            for (var j = 1; j <= nMax; j++){
                channelModel.get(i).harmonic[j] = analPeriodHarmonic(input, j);
                if (j == 1) // 基波幅值作为通道在该索引点的幅值
                    channelModel.get(i).amp = channelModel.get(i).harmonic[j].amp;
            }

            // 谐波百分比计算， 各谐波的amp与基波的amp的比值百分数， 所以基波永远是100%
            for (j = 0; j <= nMax; j++){
                if (channelModel.get(i).amp > 1.0)
                    channelModel.get(i).harmonic[j].percentage = channelModel.get(i).harmonic[j].amp / channelModel.get(i).amp;
                else
                    channelModel.get(i).harmonic[j].percentage = 0.0;
            }
        }

    }

    function print_harmonic_result() {
        var says;

        var channel_count = model.name.length;
        for (var i = 0; i < channel_count; i++){
            says += "\n\t " + model.name[i] + ": ";
            for (var j = 0; j < 7; j++){
                 says += j +" = " + model.harmonic[i][j].amp.toFixed(3) + " " + (model.harmonic[i][j].percentage * 100).toFixed(3) + "%, "
            }
        }

        if (says)
            log(says)
    }

    /*!
      检查数据模型是否有效
      */
    function isModelValid(model) {
        if (!model)
            return false;

        var size = model.getDataSize();

        if (size.rows < 1 || size.cols < 1)
            return false;

        return true;
    }

    /*!
      n次谐波计算 - 傅氏全波差分计算方法

      \c input: 输入采样序列，一般是一个周波采样点序列

      \c n: 本次谐波分析的次数

      */
    function analPeriodHarmonic(input, n) {
        if (!input || input.length < 8 || n < 1)
            return NaN;

        var fInput = input.map(parseFloat)

        var Xr = 0.0, Xi = 0.0; // 实部，虚部
        var N = fInput.length - 1;
        var yinzi = 2*Math.PI /N;  // 差分因子
        var fTemp, fV, fA;

        for (var i = 1; i < N + 1; i++){
            fTemp = fInput[i] - fInput[i-1];   // 计算差分
            Xr += fTemp * Math.sin(n*(i + 1) * yinzi);
            Xi += fTemp * Math.cos(n*(i + 1) * yinzi);
        }

        fV = 2.0 * Math.sin(Math.PI * n/N);      // 差分修正系数
        fA = (0.5 - n/N) * Math.PI;

        var a, b, c, d, divbase;
        a = 2 *Xr/N;
        b = 2 *Xi/N;
        c = fV * Math.cos(fA);
        d = fV * Math.sin(fA);
        divbase = c*c + d*d;

        var real, img, amp, angle;
        if (divbase > 0.00001){
            real = (a*c + b*d)/divbase; // 实部
            img = (b*c - a*d)/divbase; // 虚部
        }else{
            real = 0.0;
            img = 0.0;
        }

        amp = Math.sqrt((real*real + img*img) / 2);
        angle = calcComplexAngle(real, img) * 180 / Math.PI

        return {
            n: n,
            real: real,
            img: img,
            amp: amp,
            angle: angle,
            percentage: 0.0
        }
    }

    /*!
      直流分量分析

      */
    function analDC(input){
        if (!input)
            return NaN;

        var count = input.length;
        if (count < 8)
            return NaN;

        var fInput = input.map(parseFloat)

        var fTemp = 0.0;
        for (var i = 0; i < count; i++){
            fTemp += input[i] * 1.0;
        }

        fTemp /= count;

        return {
            n: 0,
            real: fTemp,
            img: 0.0,
            amp: fTemp,
            angle: 0.0,
            percentage: 0.0
        }
    }

    function calcComplexAngle(real, img){
        var fresult = 0.0;
        if (Math.abs(real) > 0.0001){
            fresult = Math.atan(img/real);
            if (fresult > 0.0){ // 1, 3象限
                if (real < 0.0 && img < 0.0){ // 3
                    fresult = fresult - Math.PI
                }
            }else if(fresult < 0.0){ // 2, 4
                if (real < 0.0 && img > 0.0){ // 2
                    fresult = fresult + Math.PI
                }
            }else{ // 0° 或者 180°
                if (real > 0.0)
                    fresult = 0.0;
                else
                    fresult = Math.PI;
            }
        }else{ // 实部为 0
            if (img > 0.0)
                fresult = Math.PI / 2;
            else if (img < 0.0)
                fresult = - Math.PI / 2;
            else
                fresult = 0.0;
        }

        return fresult;
    }


    /*
      离散度分析
      */

    function analTimeDisper() {
        var fhege = 0.0;
        var nhege = 0;
        var nTotal = model.data.cols;
        if (nTotal == 0)
            nTotal += 1;

        nhege = model.timeRelastStatic.n0us + model.timeRelastStatic.n1us +
                model.timeRelastStatic.n2us + model.timeRelastStatic.n3us +
                model.timeRelastStatic.n4us + model.timeRelastStatic.n5us +
                model.timeRelastStatic.n6us +model.timeRelastStatic.n7us +
                model.timeRelastStatic.n8us + model.timeRelastStatic.n9us +
                model.timeRelastStatic.n10us + model.timeRelastStatic.neg_n1us +
                model.timeRelastStatic.neg_n2us +model.timeRelastStatic.neg_n3us +
                model.timeRelastStatic.neg_n4us + model.timeRelastStatic.neg_n5us +
                model.timeRelastStatic.neg_n6us + model.timeRelastStatic.neg_n7us +
                model.timeRelastStatic.neg_n8us + model.timeRelastStatic.neg_n9us +
                model.timeRelastStatic.neg_n10us;

        fhege = nhege / nTotal;
        var fkeep = model.ftime_relative_last - model.ftime_relative_first;
        var nZhenSu = Math.round(nTotal / fkeep);
        var fLiuLiang = model.lTotalCapLenth * 8/(fkeep*1024*1024);
        var title = "0x" + model.ncapp_id + " 总帧数： " + nTotal
                + "  合格： " + nhege + " 帧, " + (fhege * 100).toFixed(2) + " %(帧间差-250us≤10us)"
                + "  帧速： " + nZhenSu + " 帧/秒  流量： " + fLiuLiang.toFixed(3) + " Mb/s"
                + "  持续时间： " + fkeep.toFixed(3);

        return {
            title: title,
            static: model.timeRelastStatic
        }


    }

    // ///////////////////////////////////////////////////////////////

    Component.onCompleted: {
        initModelData();
    }
}
