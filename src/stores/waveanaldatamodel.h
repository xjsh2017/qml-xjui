﻿#ifndef WAVEANALDATAMODEL_H
#define WAVEANALDATAMODEL_H

#include <QDate>
#include <QObject>
#include <QDebug>

#define QML_PROPERTY(type, name, \
    READ, getter, \
    WRITE, setter, \
    NOTIFY, notifyer\
    )  \
    type m_##name; \
    Q_PROPERTY(type name READ getter WRITE setter NOTIFY notifyer) \
    public: type getter##() const { return m_##name; } \
    public Q_SLOTS: void setter##(type arg) { if (m_##name != arg) {m_##name = arg; emit notifyer##(arg);}} \
    Q_SIGNALS:  \
        void notifyer##(type arg); \
    private:

// //////////////////
/// \brief The WaveAnalDataModel class
///
///  数据接口： 适用于离线波形与MU在线监视波形
///
/// \code
///
///    QString strJson = '[ {"name": "通道延时", "unit": "", "phase":"", "visible": false}, \
///                         {"name": "保护A相电流1", "unit": "A", "phase":"A", "visible": true} \
///                        ]'
///    // 在线监视：
///
///     WaveAnalDataModel model;
///     model.setJson(strJson);
///     model.xAppend(x, true);
///     model.yAppend(y, true); // 可采用不同的重载API填充采样值数据
///     model.sync();
///
///    // 离线分析
///
///     WaveAnalDataModel model;
///     model.setJson(strJson);
///     model.setXData(x);
///     model.setYData(y);
///     model.sync();
///
///  \endcode
///

class WaveAnalDataModel : public QObject
{
    Q_OBJECT

    QString m_test;
    Q_PROPERTY(QString test READ test WRITE setTest NOTIFY testChanged)
public:
    QString test() const { return m_test; }
public Q_SLOTS:
    void setTest(QString arg) { if (m_test != arg) { m_test = arg; emit testChanged(arg); } }
Q_SIGNALS:
    void testChanged(QString arg);
private:

    QString m_channelUpdate;
    Q_PROPERTY(QString channelUpdate READ channelUpdate WRITE setChannelUpdate NOTIFY channelUpdateChanged)
public:
    QString channelUpdate() const { return m_channelUpdate; }
public Q_SLOTS:
    void setChannelUpdate(QString arg) { if (m_channelUpdate != arg) { m_channelUpdate = arg; emit channelUpdateChanged(arg); } }
Q_SIGNALS:
    void channelUpdateChanged(QString arg);
private:

    QString m_sampleUpdate;
    Q_PROPERTY(QString sampleUpdate READ sampleUpdate WRITE setSampleUpdate NOTIFY sampleUpdateChanged)
public:
    QString sampleUpdate() const { return m_sampleUpdate; }
public Q_SLOTS:
    void setSampleUpdate(QString arg) { if (m_sampleUpdate != arg) { m_sampleUpdate = arg; emit sampleUpdateChanged(arg); } }
Q_SIGNALS:
    void sampleUpdateChanged(QString arg);
private:

    QList<qreal> m_relastStatic;
    Q_PROPERTY(QList<qreal> relastStatic READ relastStatic
               WRITE setRelastStatic NOTIFY relastStaticChanged)
public:
    QList<qreal> relastStatic() const { return m_relastStatic; }
public Q_SLOTS:
    void setRelastStatic(QList<qreal> arg) { if (m_relastStatic != arg) { m_relastStatic = arg; emit relastStaticChanged(arg); } }
Q_SIGNALS:
    void relastStaticChanged(QList<qreal> arg);
private:

    /*!
     * \brief m_json    通道属性JSON数据结构
     *
     * \code 按下面格式填入JSON数据
     *  [
     *     {"name": "通道延时", "unit": "", "phase":"", "visible": false},
     *     {"name": "保护A相电流1", "unit": "A", "phase":"A", "visible": true},
     *     .....
     *  ]
     * \endcode
     *
     *   name: 通道名称
     *   unit： 单位
     *   phase: 相别
     *   visible: 用户是否可见
     */
    QString m_json;
    Q_PROPERTY(QString json READ json WRITE setJson NOTIFY jsonChanged)
public:
    QString json() const { return m_json; }
public Q_SLOTS:
    void setJson(QString arg) { if (m_json != arg) { m_json = arg; if (m_notify) emit jsonChanged(arg); } }
Q_SIGNALS:
    void jsonChanged(QString arg);
private:

    int m_channelCount;

//Q_SIGNALS:
//    void modelDataChanged();    // 数据模型变化请求同步信号

//    QML_PROPERTY(QString, test, READ, test, WRITE, setTest, NOTIFY, testChanged)
//    QML_PROPERTY(QString, mac2, READ, mac2, WRITE, setMac2, NOTIFY, mac2Changed)
//    QML_PROPERTY(QString, ip2, READ, ip2, WRITE, setIp2, NOTIFY, ip2Changed)
//    QML_PROPERTY(QString, appid, READ, appid, WRITE, setAppid, NOTIFY, appidChanged)

public:
    explicit WaveAnalDataModel(QObject *parent = 0);

    Q_INVOKABLE void reset(int chnn_count, int sample_count);

    Q_INVOKABLE QList<qreal> x_data();
    Q_INVOKABLE QList<qreal> y_data(int idx);

    Q_INVOKABLE QList<qreal> x() { return m_x; }
    Q_INVOKABLE QList<QList<qreal> > y() { return m_y; }

    Q_INVOKABLE void setXData(const QList<qreal> &rowValue) { m_x = rowValue; }
    Q_INVOKABLE void setXData(int index, qreal value) { m_x[index] = value; }
    Q_INVOKABLE void setYData(const QList<QList<qreal> > &matrix) { m_y = matrix; }
    Q_INVOKABLE void setYData(int chnnIdx, int smpIdx, qreal value) { m_y[chnnIdx][smpIdx] = value; }

    Q_INVOKABLE void xAppend(qreal value, bool needQueen = false);
    Q_INVOKABLE void xAppend(QList<qreal> rowValue, bool needQueen = false);
    Q_INVOKABLE void yAppend(int idx, qreal value, bool needQueen = false);
    Q_INVOKABLE void yAppend(int idx, QList<qreal> rowValue, bool needQueen = false);
    Q_INVOKABLE void yAppend(QList<QList<qreal> > matrix, bool needQueen = false);

    Q_INVOKABLE int rows() { return m_y.size(); }
    Q_INVOKABLE int cols() { return m_x.size(); }

    /*!
      正弦波发生器
     *
     * \c rows: 产生几个正弦波， x轴都是一样的
     *
     * \c cols: 每个正弦波的采样点数
     *
     * \c nT: 每个正弦波的周期数
     *
     * \c xMin, xMax: x轴的最大最小值
     *
     * \c　yMin, yMx: y轴的最大最小值
     *
     * \c bRandStartAngle： 每个正弦波的起始相角是否为随机（0~360）
     *
     * \c startAngles： bRandStartAngle为false时生效，指定每个正弦波的起始相角
     *    注意若size小于正弦波的个数，则少于的正弦波其实相角度为0
     *
     *
     * \code
     *
            QList<qreal> starts;
            starts.push_back(0);
            starts.push_back(120);
            starts.push_back(240);
            buildSinWaveData(5, 171, 1, 0, 360, -5, 5, false, starts);
     *
     * \endcode
     *
     */
    Q_INVOKABLE void buildSinWaveData(int rows, int cols, int nT
                               , qreal xMin, qreal xMax, qreal yMin, qreal yMax
                               , bool bRandStartAngle = false
                               , QList<qreal> startAngles = QList<qreal>());

    Q_INVOKABLE void queenNewSampleData(int yMin, int yMax, int count);
    Q_INVOKABLE QList<qreal> RAND(int min, int max, int n);

    inline bool popFront(QList<qreal> &list, int nCount);
    inline bool popBack(QList<qreal> &list, int nCount);

    /*!
     *  type: 0 - 通道属性同步； 1 - 样本数据同步；  -1 同步所有
     */
    Q_INVOKABLE void sync(int type = -1) {
//        setTestJson();
        qDebug() << "sync = " << type;
        if (type == 0)
            setChannelUpdate(QString("%1").arg(rand()));
        else if (type == 1)
            setSampleUpdate(QString("%1").arg(rand()));
        else{
            setChannelUpdate(QString("%1").arg(rand()));
            setSampleUpdate(QString("%1").arg(rand()));
        }

//        emit modelDataChanged();
    }

    void setNotify(bool arg) { m_notify = arg; }

    void setTestJson();

signals:
    void xChanged(QList<qreal> &arg);
    void yChanged(QList<QList<qreal> > &arg);

private:
    QList<qreal> m_x;               // 帧时间序列
    QList<QList<qreal> >m_y;        // 各通道帧采样点序列

    bool m_notify;                  // 单个数据操作对应的更新通知

};

#endif // WAVEANALDATAMODEL_H
