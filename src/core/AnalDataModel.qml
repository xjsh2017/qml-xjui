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
    id: root

    // ///////////////////////////////////////////////////////////////

    property  string typename: "AnalDataModel"

    property variant syncModel: waveModel
    property string test: waveModel.test

    property var channels: JSONListModel {
            id: js_list_properties
        property var locals: ["name", "unit", "phase", "visible"]
            json: '[ \
                    {"name": "通道延时", "unit": "", "phase":"", "visible": false, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护A相电流1", "unit": "A", "phase":"A", "visible": true, "checked": true, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护A相电流2", "unit": "A", "phase":"A", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护B相电流1", "unit": "A", "phase":"B", "visible": true, "checked": true, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护B相电流2", "unit": "A", "phase":"B", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护C相电流1", "unit": "A", "phase":"C", "visible": true, "checked": true, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护C相电流2", "unit": "A", "phase":"C", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "计量A相电流", "unit": "A", "phase":"A", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "计量B相电流", "unit": "A", "phase":"B", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "计量C相电流", "unit": "A", "phase":"C", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "零序电流I01", "unit": "A", "phase":"N", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "零序电流I02", "unit": "A", "phase":"N", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "间隙电流Ij1", "unit": "A", "phase":"", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "间隙电流Ij2", "unit": "A", "phase":"", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护A相电压1", "unit": "V", "phase":"A", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "保护A相电压2", "unit": "V", "phase":"A", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "B相电压采样值1", "unit": "V", "phase":"B", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "B相电压采样值2", "unit": "V", "phase":"B", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "C相电压采样值1", "unit": "V", "phase":"C", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "C相电压采样值2", "unit": "V", "phase":"C", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "线路抽取电压1", "unit": "V", "phase":"", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "线路抽取电压2", "unit": "V", "phase":"", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "零序电压1", "unit": "V", "phase":"N", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "零序电压2", "unit": "V", "phase":"N", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "计量A相电压", "unit": "V", "phase":"A", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "计量B相电压", "unit": "V", "phase":"B", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []}, \
                    {"name": "计量C相电压", "unit": "V", "phase":"C", "visible": true, "checked": false, "amp":"", "rms":"", "angle":"", "harmonic": []} \
                    ]'

    //        query: "$[?(@.label.charAt(0)==='A')]"
        property alias sample: root.sample
        property alias analyzer: root.analyzer

            onJsonChanged: {
                root.channelsChanged();
            }

        }
    property alias jsModel: js_list_properties.jsmodel;
    property alias json: js_list_properties.json;
    property alias listModel: js_list_properties.listmodel;
    property alias localProps: js_list_properties.locals
    property int selectDataIndex: 0

    /*!
        var tmp = Matlab.sampleSin(27, 1601, 0, 16000, -20, 20, 20);
        var sample = AnalDataModel.sample;

        sample.x = tmp.x;
        sample.y = tmp.y;
        sample.print = Matlab.matrix_print;
        sample.rows = Matlab.matrix_rows;
        sample.cols = Matlab.matrix_cols;
        sample.x_row = Matlab.x_row;
        sample.y_row = Matlab.y_row;
        sample.x_data = Matlab.x_data;
        sample.y_data = Matlab.y_data;
        sample.cpto = Matlab.cpto;

        or: tmp.cpto(sample);

        AnalDataModel.sample = Matlab.sampleSin(27, 1601, 0, 16000, -20, 20, 20);
//                          Matlab.sampleSin(10, 100001, 0, 16000, -20, 20, 1250);
//                          Matlab.sampleSin(27, 16001, 0, 16000, -20, 20, 200);
//                          Matlab.sampleSin(27, 1601, 0, 16000, -20, 20, 20);
//                          Matlab.sampleSin(14, 1001, 0, 500, -20, 20, 10);
      */
    property var sample: {
        return {
            x: [[]],
            y: [[]],

            // Functions
            print: undefined,
            subdata: undefined,

            x_data: undefined,
            y_data: undefined,

            x_row: undefined,
            y_row: undefined
        }
    }
    property var analyzer: {
        "ncapp_id": 0,    // 链路appid

        // 数据分析
        curSamplePos: 0,        // 当前分析采样点索引位置
        maxHarmonicTimes: 19,   // 谐波分析的最大谐波次数： 直流、一次谐波（基本分量）、二次谐波....nMax次谐波
        periodSampleCount: 80,  // 一个周波点数
        analSampleCount: 80,    // 谐波分析需要的采样点数，从当前采样点索引位置向前数，一般一个周波点数

        // 离散度分析相关
        timeRelastStatic: {},       // 本链路时间均匀度统计
        ftime_relative_first: 0,    // 本链路第一帧报文与采样与采样文件中第一帧的时间差，见CAPCONNECTINFO，单位：秒
        ftime_relative_last:0,      // 最后一帧报文与采样文件中第一帧的时间差
        lTotalCapLenth: 0           // 本链路字节数
    }

    property bool blockChannelPropUpdatedSignal: false
    property bool blockAnalRstUpdatedSignal: false

    // ///////////////////////////////////////////////////////////////

    signal analyzerResultUpdated()  // 分析数据变更
    signal channelPropUpdated()     // 通道属性变更

    // ///////////////////////////////////////////////////////////////

    function getChannelCount(){
        if (listModel)
            return listModel.count;

        return 0;
    }

    function getChannelColor(index) {
        if(hasProperty(index, "phase"))
            return phaseColorByTypeName(listModel.get(index).phase)

        return undefined;
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
//            js_list_properties.json = JSON.stringify(jsModel);

            if (propName == "checked")
                return;

            if (localProps.indexOf(propName) > -1){
                if (!blockChannelPropUpdatedSignal)
                    channelPropUpdated();
            }else{
                if (!blockAnalRstUpdatedSignal)
                    analyzerResultUpdated();
            }
        }
    }

    function getHarmonValue(channelIdx, times){
        if (hasProperty(channelIdx, "harmonic")){
            var harmon = getPropValue(channelIdx, "harmonic");
            if (isArray(harmon) && times < harmon.length){
                return harmon[times];
            }
        }
    }

    function isHarmonValueValid(arg){
        if (arg && arg.n != undefined
                && arg.real != undefined
                && arg.img != undefined
                && arg.rms != undefined
                && arg.angle != undefined
                && arg.percentage != undefined)
            return true;

        return false;
    }

    function blockAnalSignal(){
        blockAnalRstUpdatedSignal = true;
    }
    function unblockAnalSignal(emit){
        blockAnalRstUpdatedSignal = false;

        if (emit)
            analyzerResultUpdated();
    }

    function blockPropSignal() {
        blockChannelPropUpdatedSignal = true;
    }

    function unblockPropSignal(emit){
        blockChannelPropUpdatedSignal = false;

        if (emit)
            channelPropUpdated();
    }

    /*! 判断索引编号为channelIdx的通道是否存在属性名propName  */
    function hasProperty(channelIdx, propName){
        return isArray(jsModel) && channelIdx < jsModel.length && (propName in jsModel[channelIdx])
    }

    function getDataCols() {
//        log("sample = " + sample);
//        log("isArray(arg) = " + isArray(sample.y))
//        log("isArray(arg[0])" + isArray(sample.y[0]))
//        log("isArray(arg[0])" + Array.isArray(sample.y[0]))
//        log("typeof sample.y[0] = " + typeof sample.y[0])
//        log("is2dArray(sample.y) = " + is2dArray(sample.y));
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

    function getXRow(index, start, end){
        start = arguments[1] ? arguments[1] : 0;
        end = arguments[2] ? arguments[2] : getDataCols();
        end = Math.min(end, getDataCols());

        if (index >= 0 && index < 1 /*getDataRows()*/ && sample && sample.x/* && sample.x_row*/){
//            return sample.x_row(index, start, end).data;
            return sample.x[index].slice(start, end + 1);
        }
    }

    function getYRow(index, start, end){ // [start, end]
        start = arguments[1] ? arguments[1] : 0;
        end = arguments[2] ? arguments[2] : getDataCols();
        end = Math.min(end, getDataCols());

        if (index >= 0 && index < getDataRows() && sample && sample.y/* &&  sample.y_row*/){
//            return sample.y_row(index, start, end).data;
            return sample.y[index].slice(start, end + 1);
        }
    }

    function getXData(rowIdx, colIdx){
        if (rowIdx >= 0 && rowIdx < getDataRows()
            && colIdx >= 0 && colIdx < getDataCols() && sample/* && sample.x_data*/){
//            return sample.x_data(rowIdx, colIdx);
           return sample.x[rowIdx][colIdx];
        }
    }

    function getYData(rowIdx, colIdx){
        if (rowIdx >= 0 && rowIdx < getDataRows()
            && colIdx >= 0 && colIdx < getDataCols() && sample/* && sample.x_data*/){
//            return sample.x_data(rowIdx, colIdx);
           return sample.y[rowIdx][colIdx];
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

    function rebuildHarmonData(){
        var channel_count = getChannelCount();
        for (var i = 0; i < channel_count; i++){
            if (!hasProperty(i, "harmonic"))
                continue;

            var harmon = new Array(analyzer.maxHarmonicTimes);
            for (var j = 0; j <= analyzer.maxHarmonicTimes; j++){
                harmon[j] = {
                    n: j,
                    real: 0.0,
                    img: 0.0,
                    rms: 0.0,
                    angle: 0.0,
                    percentage: 0.0
                }
            }

            setPropValue(i, "harmonic", harmon);
        }
    }

    function resetHarmonData() {
        var channel_count = getChannelCount();
        for (var i = 0; i < channel_count; i++){
            var harmon = getPropValue(i, "harmonic");
            if (!isArray(harmon))
                continue;

            for (var j = 0; j < harmon.length; j++){
                harmon[j].n = j;
                harmon[j].real = 0.0;
                harmon[j].img = 0.0;
                harmon[j].rms = 0.0;
                harmon[j].angle = 0.0;
                harmon[j].percentage = 0.0;
            }
        }
    }

    // ///////////////////////////////////////////////////////////////

    function init() {
        rebuildHarmonData();

        analyzer.timeRelastStatic = {
            n0us: 0, n1us: 0, n2us: 0, n3us: 0, n4us: 0, n5us: 0, n6us: 0, n7us:0, n8us:0, n9us: 0, n10us:0, nup11us:0,
            neg_n1us: 0, neg_n2us: 0, neg_n3us: 0, neg_n4us: 0, neg_n5us: 0, neg_n6us: 0, neg_n7us:0,
            neg_n8us:0, neg_n9us: 0, neg_n10us:0, neg_nup11us:0,

            n4to10us:0, n11to25us:0, n25tous:0
        }
    }

    /*
        从内部数据接口更新模型数据
      */
    function sync() {
        if(!syncModel)
            return;

        log("syncModel: " + syncModel)
        var Rows = syncModel.rows();
        var Cols = syncModel.cols();
        sample.x = new Array(1);
        sample.y = new Array(Rows);
        for (var k = 0; k < Cols; k++){
            sample.x[k] = syncModel.x_data(k);
        }
        for (var i = 0; i < Rows; i ++){
            sample.y[i] = new Array(Cols);
            for (var j = 0; j < Cols; j++)
                sample.y[i][j] = syncModel.y_data(i)[j];
        }

        log("Rows: " + Rows + ", Cols: " + Cols)


        sampleChanged();
    }

    function isModelReady() {

    }

    /*!
      检查数据模型是否有效
      */
    function isModelValid() {
        if (!channels || !isArray(jsModel))
            return false;

        return true;
    }

    // ///////////////////////////////////////////////////////////////

    function isArray(o){
//        return o && Array.isArray(o);
        return o && Object.prototype.toString.call(o)=='[object Array]';
    }

    function is2dArray(arg){
        return arg && isArray(arg) && isArray(arg[0])
    }

    function log(says) {
        console.log("## AnalDataModel.qml ##: " + says);
    }

    onTestChanged: {
        log("detect sync request from test string")

        sync();
    }

    // ///////////////////////////////////////////////////////////////

    Component.onCompleted: {
        try {
            init();

        } catch (error) {
            // Ignore the error; it only means that the fonts were not enabled
        }

        log("Component.onCompleted")
    }

    Component.onDestruction: {
        log("Component.onDestruction")
    }



}
