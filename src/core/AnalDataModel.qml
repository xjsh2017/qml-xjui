pragma Singleton

import QtQuick 2.4

/*!
   \qmltype AnalDataModel
   \inqmlmodule XjUi

   \brief Provides access to standard colors that follow the Material Design specification.

   See \l {http://www.google.com/design/spec/style/color.html#color-ui-color-application} for
   details about choosing a color scheme for your application.
 */

QtObject {
    id: analDataModel

    // ///////////////////////////////////////////////////////////////

    property  bool isNeedUpdate: false;

    property var propModel: JSONListModel {
            id: properties
            json: '[ \
                    {"name": "通道延时", "unit": "", "phase":"", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护A相电流1", "unit": "A", "phase":"A", "visible": true, "selected": true, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护A相电流2", "unit": "A", "phase":"A", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护B相电流1", "unit": "A", "phase":"B", "visible": true, "selected": true, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护B相电流2", "unit": "A", "phase":"B", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护C相电流1", "unit": "A", "phase":"C", "visible": true, "selected": true, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护C相电流2", "unit": "A", "phase":"C", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "计量A相电流", "unit": "A", "phase":"A", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "计量B相电流", "unit": "A", "phase":"B", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "计量C相电流", "unit": "A", "phase":"C", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "零序电流I01", "unit": "A", "phase":"N", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "零序电流I02", "unit": "A", "phase":"N", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "间隙电流Ij1", "unit": "A", "phase":"", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "间隙电流Ij2", "unit": "A", "phase":"", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护A相电压1", "unit": "V", "phase":"A", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护A相电压2", "unit": "V", "phase":"A", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "B相电压采样值1", "unit": "V", "phase":"B", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "B相电压采样值2", "unit": "V", "phase":"B", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "C相电压采样值1", "unit": "V", "phase":"C", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "C相电压采样值2", "unit": "V", "phase":"C", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "线路抽取电压1", "unit": "V", "phase":"", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "线路抽取电压2", "unit": "V", "phase":"", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "零序电压1", "unit": "V", "phase":"N", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "零序电压2", "unit": "V", "phase":"N", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "计量A相电压", "unit": "V", "phase":"A", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "计量B相电压", "unit": "V", "phase":"B", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "计量C相电压", "unit": "V", "phase":"C", "visible": true, "selected": false, "amp":"", "rms":"", "angle":"", "harmonic": []} \
                    ]'

    //        query: "$[?(@.label.charAt(0)==='A')]"

            onJsonChanged: {
                AnalDataModel.propValueChanged();
            }

        }
    property alias jsModel: properties.jsmodel;
    property alias json: properties.json;
    property alias listModel: properties.listmodel;

    property var sample;
//                          Matlab.sampleSin(10, 100001, 0, 16000, -20, 20, 1250);
//                          Matlab.sampleSin(27, 16001, 0, 16000, -20, 20, 200);
//                          Matlab.sampleSin(27, 1601, 0, 16000, -20, 20, 20);
//                          Matlab.sampleSin(14, 1001, 0, 500, -20, 20, 10);

    property var analModel: {
        "ncapp_id": 0,    // 链路appid

        // 数据分析
        curSamplePos: 0,        // 当前分析采样点索引位置
        maxHarmonicTimes: 19,   // 谐波分析的最大谐波次数： 直流、一次谐波（基本分量）、二次谐波....nMax次谐波
        periodSampleCount: 80,  // 一个周波点数
        analSampleCount: 80,    // 谐波分析需要的采样点数，从当前采样点索引位置向前数，一般一个周波点数

//        harmonic: [[]],         // 每个通道当前索引位置采样点的maxHarmonicTimes次谐波分析的结果， 通道数 X maxHarmonicTimes

        // 离散度分析相关
        timeRelastStatic: {},       // 本链路时间均匀度统计
        ftime_relative_first: 0,    // 本链路第一帧报文与采样与采样文件中第一帧的时间差，见CAPCONNECTINFO，单位：秒
        ftime_relative_last:0,      // 最后一帧报文与采样文件中第一帧的时间差
        lTotalCapLenth: 0           // 本链路字节数
    }

    // ///////////////////////////////////////////////////////////////

    signal propValueChanged();
    signal propXYDataChanged();
    signal propAnalDataChanged();

    function getChannelCount(){
        if (listModel)
            return listModel.count;

        return 0;
    }

    function getChannelColor(index) {
        return phaseColorByTypeName(listModel.get(index).phase)
    }

    function isChannelVisible(index) {
        return index < getChannelCount() ?
                    getPropValue(index, "visible") : false
    }

    function getJsonString(){
        return JSON.stringify(jsModel);
    }

    function getPropName(channelIdx, propIdx){
        if (index < getChannelCount() && isArray(jsModel)){
            var i = 0;
            for (var key in jsModel[channelIdx]){
                if (i == propIdx){
                    return key;
                }
                i++;
            }
        }
    }

    function getPropValue(channelIdx, propName) {
        if (hasProperty(channelIdx, propName))
            return jsModel[channelIdx][propName];
    }

    function setPropValue(channelIdx, propName, value) {
        if (hasProperty(channelIdx, propName)){
            listModel.setProperty(channelIdx, propName, value);
            jsModel[channelIdx][propName] = value;
//            properties.json = JSON.stringify(jsModel);

            propValueChanged();
        }
    }

    /*! 判断索引编号为channelIdx的通道是否存在属性名propName  */
    function hasProperty(channelIdx, propName){
        return isArray(jsModel) && channelIdx < jsModel.length && (propName in jsModel[channelIdx])
    }

    function getDataCols() {
        if (sample && is2dArray(sample.y))
            return sample.y[0].length
    }

    function getDataRows() {
        if (sample && isArray(sample.y))
            return sample.y.length
    }

    function getDataSize(){
        return {
            rows: getDataRows(),
            cols: getDataCols()
        }
    }

    function getXData(index, start, end){
        if (index < getChannelCount() && sample && sample.x_row){
            return sample.x_row(index, start, end).data;
        }
    }

    function getYData(index, start, end){
        if (index < getChannelCount() && sample && sample.y_row){
            return sample.y_row(index, start, end).data;
        }
    }

    function phaseColorByTypeName(type) {
        switch (type) {
        case 'A':
            return "#ff9800";
            break;
        case 'B':
            return "#4caf50";

            break;
        case 'C':
            return "#ba68c8";
            break;
        case 'N':
            return "#607d8b";
            break;
        default:
            return "lightgrey"
        }
    }

    // ///////////////////////////////////////////////////////////////


    function log(says) {
//        console.log("## AnalDataModel.qml ##: " + says);
    }

    // ///////////////////////////////////////////////////////////////

    function initModelData() {
        var channel_count = getChannelCount();

        for (var i = 0; i < channel_count; i++){
            listModel.get(i).harmonic = new Array(19);
            for (var j = 0; j < 19; j++){
                listModel.get(i).harmonic[j] = {
                    n: j,
                    real: 0.0,
                    img: 0.0,
                    amp: 0.0,
                    angle: 0.0,
                    percentage: 0.0
                }
            }
        }

        analModel.timeRelastStatic = {
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
        console.log("here: " + modeldata)

        var Rows = modeldata.rows();
        var Cols = modeldata.cols();
        var x = modeldata.x_data();
        var y = new Array(Rows);
        for (var i = 0; i < Rows; i ++){
            y[i] = modeldata.y_data(i);
        }

        sample.x = x;
        sample.y = y;
        sample.rows = Rows;
        sample.cols = Cols;

        log("Rows: " + Rows + ", Cols: " + Cols)

        propXYDataChanged();
    }

    /*!
      检查数据模型是否有效
      */
    function isModelValid(model) {
        if (!model || !model.data || !model.data.y)
            return false;

        if (model.data.rows < 1 || model.data.cols < 1)
            return false;

        return true;
    }

    // ///////////////////////////////////////////////////////////////

    function isArray(o){
        return Object.prototype.toString.call(o)=='[object Array]';
    }

    function is2dArray(arg){
        return arg && isArray(arg) && isArray(arg[0])
    }

    // ///////////////////////////////////////////////////////////////

    Component.onCompleted: {
//        initModelData();
    }



}
