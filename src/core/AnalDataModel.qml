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
    id: analModel

    // ///////////////////////////////////////////////////////////////

    property  bool isNeedUpdate: false;

    property var propModel: JSONListModel {
            id: properties
            json: '[ \
                    {"name": "通道延时", "unit": "", "phase":"", "amp":0.0, "rms":0.0, "angle":0.0, "visible": false, "selected": false}, \
                    {"name": "保护A相电流1", "unit": "A", "phase":"A", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": 1}, \
                    {"name": "保护A相电流2", "unit": "A", "phase":"A", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "保护B相电流1", "unit": "A", "phase":"B", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": 1}, \
                    {"name": "保护B相电流2", "unit": "A", "phase":"B", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "保护C相电流1", "unit": "A", "phase":"C", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": 1}, \
                    {"name": "保护C相电流2", "unit": "A", "phase":"C", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "计量A相电流", "unit": "A", "phase":"A", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "计量B相电流", "unit": "A", "phase":"B", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "计量C相电流", "unit": "A", "phase":"C", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "零序电流I01", "unit": "A", "phase":"N", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "零序电流I02", "unit": "A", "phase":"N", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "间隙电流Ij1", "unit": "A", "phase":"", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "间隙电流Ij2", "unit": "A", "phase":"", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "保护A相电压1", "unit": "V", "phase":"A", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "保护A相电压2", "unit": "V", "phase":"A", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "B相电压采样值1", "unit": "V", "phase":"B", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "B相电压采样值2", "unit": "V", "phase":"B", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "C相电压采样值1", "unit": "V", "phase":"C", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "C相电压采样值2", "unit": "V", "phase":"C", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "线路抽取电压1", "unit": "V", "phase":"", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "线路抽取电压2", "unit": "V", "phase":"", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "零序电压1", "unit": "V", "phase":"N", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "零序电压2", "unit": "V", "phase":"N", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "计量A相电压", "unit": "V", "phase":"A", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "计量B相电压", "unit": "V", "phase":"B", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false}, \
                    {"name": "计量C相电压", "unit": "V", "phase":"C", "amp":0.0, "rms":0.0, "angle":0.0, "visible": true, "selected": false} \
                    ]'

    //        query: "$[?(@.label.charAt(0)==='A')]"

            onJsonChanged: {
                AnalDataModel.propValueChanged();
            }

        }

    property alias jsModel: properties.jsmodel;
    property alias json: properties.json;
    property alias listModel: properties.listmodel;

    property var dataModel//:
//                          Matlab.sampleSin(10, 100001, 0, 16000, -20, 20, 1250);
//                          Matlab.sampleSin(27, 16001, 0, 16000, -20, 20, 200);
//                    Matlab.sampleSin(27, 1601, 0, 16000, -20, 20, 20);
//                          Matlab.sampleSin(14, 1001, 0, 500, -20, 20, 10);


    // ///////////////////////////////////////////////////////////////

    signal propValueChanged();
    signal propXYDataChanged();

    function getXData(index, start, end){
        if (index < getCount()){
//            console.log(dataModel.x_row(index, start, end).data.map(parseFloat));
//            return dataModel.x[index].map(parseFloat);
            return dataModel.x_row(index, start, end).data;
        }
    }

    function getYData(index, start, end){
        if (index < getCount()){
//            console.log(dataModel.y[index].map(parseFloat));
//            return dataModel.y[index].map(parseFloat);
            return dataModel.y_row(index, start, end).data;
        }
    }

    function getDataSize(){
        return {
            h: dataModel.y.length,
            w: y ? dataModel.y[0].length : 0
        }
    }

    function getJsonString(){
        return JSON.stringify(jsModel);
    }

    function getCount(){
        if (listModel)
            return listModel.count;

        return 0;
    }

    function getPropName(index, num){
        if (index < getCount()){
            var i = 0;
            for (var key in jsModel[index]){
                if (i == num){
                    return key;
                }
                i++;
            }
        }
    }

    function getPropValue(index, propName) {
        if (listModel)
            return jsModel[index][propName];
    }

    function setPropValue(index, propName, value) {
        if (listModel){
            listModel.setProperty(index, propName, value);

            jsModel[index][propName] = value;

//            properties.json = JSON.stringify(jsModel);

            propValueChanged();
        }
    }

    // ///////////////////////////////////////////////////////////////


    function log(says) {
        console.log("## AnalDataModel.qml ##: " + says);
    }

    // ///////////////////////////////////////////////////////////////

    function initModelData() { log("initModelData")
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

        dataModel.x = x;
        dataModel.y = y;
        dataModel.rows = Rows;
        dataModel.cols = Cols;

        log("Rows: " + Rows + ", Cols: " + Cols)

//        dataModel.data = {
//            // data:
//            x: x,               // matrix: 1 x Cols
//            y: y,               // matrix: rows x Cols
//            rows: Rows,
//            cols: Cols,

//            // Functions
////            print: Matlab.matrix_print,
////            subdata: Matlab.matrix_subdata,

////            x_data: Matlab.x_data,
////            y_data: Matlab.y_data,

////            x_row: Matlab.x_row,
////            y_row: Matlab.y_row

//        }

        propXYDataChanged();

        return 0;
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

    Component.onCompleted: {
        log("hello")
        log(listModel.count)
//        log(json);

//        log(getPropValue(0, "visible"))
        setPropValue(0, "visible", true);
//        log(getPropValue(0, "visible"))

//        dataModel = Matlab.sampleSin(27, 1601, 0, 16000, -20, 20, 20);
//        log(getXData(0));

    }



}
