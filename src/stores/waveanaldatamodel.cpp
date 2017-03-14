#include "waveanaldatamodel.h"

#include <QTime>
#include <iostream>
#include<iomanip>
using namespace std;

WaveAnalDataModel::WaveAnalDataModel(QObject *parent)
    : QObject(parent)
    , m_test(QStringLiteral("mac address"))
    , m_notify(true)
//    , m_mac2(QString("00-00-00-00-00-00"))
//    , m_ip2(QString())
//    , m_appid(QString("SMV Ox00"))
{
    reset();
}

void WaveAnalDataModel::reset()
{
    m_x.clear();
    m_y.clear();
}

QList<qreal> WaveAnalDataModel::x_data()
{
    return m_x;
}

QList<qreal> WaveAnalDataModel::y_data(int idx)
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

void WaveAnalDataModel::xAppend(QList<qreal> rowValue, bool needQueen)
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
    QList<qreal> tmp = m_y.at(idx);
    if (needQueen){
        tmp.removeLast();
    }
    tmp.append(value);
    m_y.replace(idx, tmp);

    if (m_notify)
    emit yChanged(m_y);
}

void WaveAnalDataModel::yAppend(int idx, QList<qreal> rowValue, bool needQueen)
{
    QList<qreal> tmp = m_y.at(idx);
    if (needQueen){
        popFront(tmp, rowValue.size());
    }
    tmp.append(rowValue);
    m_y.replace(idx, tmp);

    if (m_notify)
    emit yChanged(m_y);
}

void WaveAnalDataModel::yAppend(QList<QList<qreal> > matrix, bool needQueen)
{
    if (needQueen){
        for (int i = 0; i < matrix.size(); i++){
            yAppend(i, matrix.at(i), needQueen);
        }
    }else
        m_y.append(matrix);

    if (m_notify)
    emit yChanged(m_y);
}

QList<qreal> WaveAnalDataModel::RAND(int min, int max, int n)
{
    QList<qreal> rt;
    for(int i = 0; i < n; ++i)
    {
        int u = (double)rand() / (RAND_MAX + 1) * (max - min) + min;
        rt.append(u);
    }

    return rt;
}

void WaveAnalDataModel::buildSinWaveData(int rows, int cols, int nT
                                         , qreal xMin, qreal xMax, qreal yMin, qreal yMax
                                         , bool bRandStartAngle, QList<qreal> startAngles)
{
    if (nT < 0)
        return;

    reset();

    qreal xRange = xMax - xMin;
    qreal yRange = yMax - yMin;

    qreal hopX = xRange / (cols - 1);
    qreal offset = yMax - yRange / 2;
    qreal Tx = (xMax - xMin) / nT;

    m_y.reserve(rows);
    m_x.reserve(cols);

    qreal pi = 3.1415926;

    QList<qreal> ampFactor;
    ampFactor << 1;
    for(int i=1; i< rows;i++){
        ampFactor.append(qrand()% rows);
    }

    if (bRandStartAngle){
        startAngles.clear();
        startAngles = RAND(0, 360, rows);
    }

//    cout << setiosflags(ios::fixed);
//    cout << "y = [\n";
    for (int i = 0; i < rows; i++){
        qreal tmp = 0.0;
        QList<qreal> rowValue;
        rowValue.reserve(cols);
        for (int j = 0; j < cols; j++){
            if (i == 0)
                m_x.append(xMin + j * hopX);

            qreal offsetAngle = (startAngles.size() <= i ? 0 : startAngles.at(i)) * pi / 180.0f;
            tmp = yRange / 2 * sin((m_x[j]) / Tx * 2 * pi  + offsetAngle);
            tmp *= ampFactor.at(i) / rows;
            tmp += offset;

            rowValue.push_back(tmp);
//            cout << setprecision(2) << tmp;
//            if (j != cols -1)
//                cout << ", ";
        }
        m_y.push_back(rowValue);

//        cout << endl;
    }

//    cout << "]" << endl;

//    cout << "x = [\n";
//    for (int i = 0; i < m_x.size(); i++){
//        cout << m_x.at(i);
//        if (i != m_x.size() -1)
//            cout << ", ";
//    }

//    cout << "]" << endl;
}

void WaveAnalDataModel::queenNewSampleData(int yMin, int yMax, int samplePoints)
{
    int nRows = rows();
    int nCols = cols();

//    if (nMaxValue < samplePoints || nRows == 0)
//        return;

    // ÏÈÉ¾³ýÊý¾Ý
//    int nDeleteCount = qMin(nCols, samplePoints);
//    for (int i = 0; i < nRows; ++i)
//    {
//        QList<qreal> x = m_x.at(i);
//        QList<qreal> y = m_y.at(i);

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
//        QList<int> x = random(nMax, nCount);
//        QList<int> y = random(nMax, nCount);

//        for (int j = 0; j < nCount; ++j)
//        {
//            xAppend(i, x.at(j) - nMax / 2);
//            yAppend(i, y.at(j) - nMax / 2);
//        }
//    }
}

bool WaveAnalDataModel::popFront(QList<qreal> &list, int nCount)
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

bool WaveAnalDataModel::popBack(QList<qreal> &list, int nCount)
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











