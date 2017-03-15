#ifndef WAVEANALDATAMODEL_H
#define WAVEANALDATAMODEL_H

#include <QDate>
#include <QObject>

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
///  ���ݽӿڣ� ���������߲�����MU���߼��Ӳ���
///
/// \code
///
///    QString strJson = '[ {"name": "ͨ����ʱ", "unit": "", "phase":"", "visible": false}, \
///                         {"name": "����A�����1", "unit": "A", "phase":"A", "visible": true} \
///                        ]'
///    // ���߼��ӣ�
///
///     WaveAnalDataModel model;
///     model.setJson(strJson);
///     model.xAppend(x, true);
///     model.yAppend(y, true); // �ɲ��ò�ͬ������API������ֵ����
///     model.sync();
///
///    // ���߷���
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

    /*!
     * \brief m_json    ͨ������JSON���ݽṹ
     *
     * \code �������ʽ����JSON����
     *  [
     *     {"name": "ͨ����ʱ", "unit": "", "phase":"", "visible": false},
     *     {"name": "����A�����1", "unit": "A", "phase":"A", "visible": true},
     *     .....
     *  ]
     * \endcode
     *
     *   name: ͨ������
     *   unit�� ��λ
     *   phase: ���
     *   visible: �û��Ƿ�ɼ�
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

signals:
    void modelDataChanged();    // ����ģ�ͱ仯����ͬ���ź�

//    QML_PROPERTY(QString, test, READ, test, WRITE, setTest, NOTIFY, testChanged)
//    QML_PROPERTY(QString, mac2, READ, mac2, WRITE, setMac2, NOTIFY, mac2Changed)
//    QML_PROPERTY(QString, ip2, READ, ip2, WRITE, setIp2, NOTIFY, ip2Changed)
//    QML_PROPERTY(QString, appid, READ, appid, WRITE, setAppid, NOTIFY, appidChanged)

public:
    explicit WaveAnalDataModel(QObject *parent = 0);

    Q_INVOKABLE void reset();
    Q_INVOKABLE void setChannelCount(int arg);

    Q_INVOKABLE QList<qreal> x_data();
    Q_INVOKABLE QList<qreal> y_data(int idx);

    Q_INVOKABLE void setXData(const QList<qreal> &rowValue) { m_x = rowValue; }
    Q_INVOKABLE void setYData(const QList<QList<qreal> > &matrix) { m_y = matrix; }

    Q_INVOKABLE void xAppend(qreal value, bool needQueen = false);
    Q_INVOKABLE void xAppend(QList<qreal> rowValue, bool needQueen = false);
    Q_INVOKABLE void yAppend(int idx, qreal value, bool needQueen = false);
    Q_INVOKABLE void yAppend(int idx, QList<qreal> rowValue, bool needQueen = false);
    Q_INVOKABLE void yAppend(QList<QList<qreal> > matrix, bool needQueen = false);

    Q_INVOKABLE int rows() { return m_y.size(); }
    Q_INVOKABLE int cols() { if (m_y.size() > 0) return m_y.at(0).size(); else return 0; }

    /*!
      ���Ҳ�������
     *
     * \c rows: �����������Ҳ��� x�ᶼ��һ����
     *
     * \c cols: ÿ�����Ҳ��Ĳ�������
     *
     * \c nT: ÿ�����Ҳ���������
     *
     * \c xMin, xMax: x��������Сֵ
     *
     * \c��yMin, yMx: y��������Сֵ
     *
     * \c bRandStartAngle�� ÿ�����Ҳ�����ʼ����Ƿ�Ϊ�����0~360��
     *
     * \c startAngles�� bRandStartAngleΪfalseʱ��Ч��ָ��ÿ�����Ҳ�����ʼ���
     *    ע����sizeС�����Ҳ��ĸ����������ڵ����Ҳ���ʵ��Ƕ�Ϊ0
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

    Q_INVOKABLE void sync() { emit modelDataChanged(); }
    void setNotify(bool arg) { m_notify = arg; }

signals:
    void xChanged(QList<qreal> &arg);
    void yChanged(QList<QList<qreal> > &arg);

private:
    QList<qreal> m_x;               // ֡ʱ������
    QList<QList<qreal> >m_y;        // ��ͨ��֡����������

    bool m_notify;                  // �������ݲ�����Ӧ�ĸ���֪ͨ

};

#endif // WAVEANALDATAMODEL_H
