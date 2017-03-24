#include "waveanaldatamodel.h"

#include <QTime>
#include <iostream>
#include <iomanip>
#include <math.h>
using namespace std;

WaveAnalDataModel::WaveAnalDataModel(QObject *parent)
    : QObject(parent)
    , m_test(QStringLiteral("mac address"))
    , m_notify(true)
//    , m_mac2(QString("00-00-00-00-00-00"))
//    , m_ip2(QString())
//    , m_appid(QString("SMV Ox00"))
{
    reset(0, 0);
}

void WaveAnalDataModel::reset(int chnn_count, int sample_count)
{
    m_x.clear();
    m_y.clear();

    m_x = QVector<qreal>(sample_count, 0);
    m_y = QVector<QVector<qreal> >(chnn_count, QVector<qreal>(sample_count, 0));

    m_relastStatic = QVector<qreal>(31, 0.0f);
}

void WaveAnalDataModel::setChannelCount(int arg)
{
    m_channelCount = arg;
    m_y.clear();
    QVector<QVector<qreal> > x(m_channelCount, QVector<qreal>());
    m_y = x;
}

QVector<qreal> WaveAnalDataModel::x_data()
{
    return m_x;
}

QVector<qreal> WaveAnalDataModel::y_data(int idx)
{
    return m_y.at(idx);
}

void WaveAnalDataModel::xAppend(qreal value, bool needQueen)
{
    if (needQueen)
        m_x.removeFirst();
    m_x.append(value);

    if (m_notify)
    emit xChanged(m_x);
}

void WaveAnalDataModel::xAppend(QVector<qreal> rowValue, bool needQueen)
{
    if (needQueen){
        popFront(m_x, rowValue.size());
    }
    m_x.append(rowValue);

    if (m_notify)
    emit xChanged(m_x);
}

void WaveAnalDataModel::yAppend(int idx, qreal value, bool needQueen)
{
    if (m_channelCount < 1 || m_y.size() < m_channelCount)
        return;

    if (needQueen){
        m_y[idx].removeLast();
    }
    m_y[idx].append(value);

    if (m_notify)
    emit yChanged(m_y);
}

void WaveAnalDataModel::yAppend(int idx, QVector<qreal> rowValue, bool needQueen)
{
    if (m_channelCount < 1 || m_y.size() < m_channelCount)
        return;
    QVector<qreal> tmp = m_y.at(idx);
    if (needQueen){
        popFront(tmp, rowValue.size());
    }
    tmp.append(rowValue);
    m_y.replace(idx, tmp);

    if (m_notify)
    emit yChanged(m_y);
}

void WaveAnalDataModel::yAppend(QVector<QVector<qreal> > matrix, bool needQueen)
{
    if (m_channelCount < 1 || m_y.size() < m_channelCount)
        return;
    if (needQueen){
        for (int i = 0; i < matrix.size(); i++){
            yAppend(i, matrix.at(i), needQueen);
        }
    }else
        m_y.append(matrix);

    if (m_notify)
    emit yChanged(m_y);
}

QVector<qreal> WaveAnalDataModel::RAND(int min, int max, int n)
{
    QVector<qreal> rt;
    for(int i = 0; i < n; ++i)
    {
        int u = (double)rand() / (RAND_MAX + 1) * (max - min) + min;
        rt.append(u);
    }

    return rt;
}

void WaveAnalDataModel::buildSinWaveData(int rows, int cols, int nT
                                         , qreal xMin, qreal xMax, qreal yMin, qreal yMax
                                         , bool bRandStartAngle, QVector<qreal> startAngles)
{
    if (nT < 0)
        return;

    reset(rows, cols);

    qreal xRange = xMax - xMin;
    qreal yRange = yMax - yMin;

    qreal hopX = xRange / (cols - 1);
    qreal offset = yMax - yRange / 2;
    qreal Tx = (xMax - xMin) / nT;

    qreal pi = 3.1415926;

    QVector<qreal> ampFactor;
    ampFactor << 1;
    for(int i=1; i< rows;i++){
        ampFactor.append(qrand()% rows);
    }

    if (bRandStartAngle){
        startAngles.clear();
        startAngles = RAND(0, 360, rows);
    }

    for (int i = 0; i < rows; i++){
        qreal tmp = 0.0;
        for (int j = 0; j < cols; j++){
            if (i == 0)
                m_x[j] = xMin + j * hopX;

            qreal offsetAngle = (startAngles.size() <= i ? 0 : startAngles.at(i)) * pi / 180.0f;
            tmp = yRange / 2 * sin((m_x[j]) / Tx * 2 * pi  + offsetAngle);
            tmp *= ampFactor.at(i) / rows;
            tmp += offset;

            m_y[i][j] = tmp;
        }
    }
}

void WaveAnalDataModel::queenNewSampleData(int yMin, int yMax, int samplePoints)
{
    int nRows = rows();
    int nCols = cols();

//    if (nMaxValue < samplePoints || nRows == 0)
//        return;

    // 先删除数据
//    int nDeleteCount = qMin(nCols, samplePoints);
//    for (int i = 0; i < nRows; ++i)
//    {
//        QVector<qreal> x = m_x.at(i);
//        QVector<qreal> y = m_y.at(i);

//        for (int j = 0; j < nDeleteCount; ++j)
//        {
//            x.removeAt(0);
//            y.removeAt(0);
//        }

//        m_x.replace(i, x);
//        m_y.replace(i, y);
//    }

//    int nMax = nMaxValue;
//    int nCount = samplePoints;

//    for (int i = 0; i < nRows; ++i)
//    {
//        QVector<int> x = random(nMax, nCount);
//        QVector<int> y = random(nMax, nCount);

//        for (int j = 0; j < nCount; ++j)
//        {
//            xAppend(i, x.at(j) - nMax / 2);
//            yAppend(i, y.at(j) - nMax / 2);
//        }
//    }
}

bool WaveAnalDataModel::popFront(QVector<qreal> &list, int nCount)
{
    int nChop = qMin(list.size(), nCount);
    if (nChop < 0){
        list.clear();
        return true;
    }

    for (int i = 0; i < nChop; ++i)
        list.removeFirst();

    return true;
}

bool WaveAnalDataModel::popBack(QVector<qreal> &list, int nCount)
{
    int nChop = qMin(list.size(), nCount);
    if (nChop < 0){
        list.clear();
        return true;
    }

    for (int i = 0; i < nChop; ++i)
        list.removeLast();

    return true;
}

void WaveAnalDataModel::setTestJson()
{
    QString json = "[ \
    {\"name\": \"通道延时\", \"unit\": \"\", \"phase\":\"\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"保护A相电流1\", \"unit\": \"A\", \"phase\":\"A\", \"visible\": true, \"checked\": true, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"保护A相电流2\", \"unit\": \"A\", \"phase\":\"A\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"保护B相电流1\", \"unit\": \"A\", \"phase\":\"B\", \"visible\": true, \"checked\": true, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"保护B相电流2\", \"unit\": \"A\", \"phase\":\"B\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"保护C相电流1\", \"unit\": \"A\", \"phase\":\"C\", \"visible\": true, \"checked\": true, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"保护C相电流2\", \"unit\": \"A\", \"phase\":\"C\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"计量A相电流\", \"unit\": \"A\", \"phase\":\"A\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"计量B相电流\", \"unit\": \"A\", \"phase\":\"B\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"计量C相电流\", \"unit\": \"A\", \"phase\":\"C\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"零序电流I01\", \"unit\": \"A\", \"phase\":\"N\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"零序电流I02\", \"unit\": \"A\", \"phase\":\"N\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"间隙电流Ij1\", \"unit\": \"A\", \"phase\":\"\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"间隙电流Ij2\", \"unit\": \"A\", \"phase\":\"\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"保护A相电压1\", \"unit\": \"V\", \"phase\":\"A\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"保护A相电压2\", \"unit\": \"V\", \"phase\":\"A\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"B相电压采样值1\", \"unit\": \"V\", \"phase\":\"B\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"B相电压采样值2\", \"unit\": \"V\", \"phase\":\"B\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"C相电压采样值1\", \"unit\": \"V\", \"phase\":\"C\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"C相电压采样值2\", \"unit\": \"V\", \"phase\":\"C\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"线路抽取电压1\", \"unit\": \"V\", \"phase\":\"\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"线路抽取电压2\", \"unit\": \"V\", \"phase\":\"\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"零序电压1\", \"unit\": \"V\", \"phase\":\"N\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"零序电压2\", \"unit\": \"V\", \"phase\":\"N\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"计量A相电压\", \"unit\": \"V\", \"phase\":\"A\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"计量B相电压\", \"unit\": \"V\", \"phase\":\"B\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []}, \
    {\"name\": \"计量C相电压\", \"unit\": \"V\", \"phase\":\"C\", \"visible\": true, \"checked\": false, \"amp\":\"\", \"rms\":\"\", \"angle\":\"\", \"harmonic\": []} \
            ]";

            setJson(json);
}










