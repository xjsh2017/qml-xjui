#include "waveanaldatamodel.h"

#include <QTime>

WaveAnalDataModel::WaveAnalDataModel(QObject *parent)
    : QObject(parent), m_test(QStringLiteral("mac address"))
{

}

void WaveAnalDataModel::reset()
{
    m_x.clear();
    m_y.clear();
}

QList<qreal> WaveAnalDataModel::x_data(int idx)
{
    return m_x.at(idx);
}

void WaveAnalDataModel::append_x(int idx, qreal value)
{
    if (idx + 1 > m_x.count())
    {
        for (int i = m_x.count(); i < idx + 1; ++i)
            m_x.push_back(QList<qreal>());
    }
    m_x[idx].append(value);
    emit xChanged(m_x);
}

QList<qreal> WaveAnalDataModel::y_data(int idx)
{
    return m_y.at(idx);
}

void WaveAnalDataModel::append_y(int idx, qreal value)
{
    if (idx + 1 > m_y.count())
    {
        for (int i = m_y.count(); i < idx + 1; ++i)
            m_y.push_back(QList<qreal>());
    }
    m_y[idx].append(value);
    emit yChanged(m_y);
}

QList<int> WaveAnalDataModel::random(int nMax, int nCount)
{
    QList<int> intList;
    int   i=0, m=0;
    QTime time;
    for(i=0;;)
    {
        if (intList.count() > nCount)
            break;

        int     randn;
        time    = QTime::currentTime();
        qsrand(time.msec()*qrand()*qrand()*qrand()*qrand()*qrand()*qrand());
        randn   = qrand()%nMax;
        m=0;

        while(m<i && intList.at(m)!=randn)
            m++;

        if(m==i)            { intList.append(randn); i++;}
        else if(i==nMax)    break;
        else                continue;
    }

    return intList;
}

void WaveAnalDataModel::buildData(int rows, int samplePoints, int nMaxValue)
{
    if (nMaxValue < samplePoints)
        return;

    int nMax = nMaxValue;
    int nCount = samplePoints;

    for (int i = 0; i < rows; ++i)
    {
        QList<int> x = random(nMax, nCount);
        QList<int> y = random(nMax, nCount);

        for (int j = 0; j < nCount; ++j)
        {
            append_x(i, x.at(j) - nMax / 2);
            append_y(i, y.at(j) - nMax / 2);
        }
    }
}
