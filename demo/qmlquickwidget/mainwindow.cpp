#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QQuickWidget>
#include <QQuickView>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQmlComponent>

#include <QDebug>

#include "stores/waveanaldatamodel.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    setupUi();

    connect(ui->tabWidget, SIGNAL(currentChanged(int)), this, SLOT(currentChanged(int)));
}

MainWindow::~MainWindow()
{
    delete ui;
}

/*
 * 生成 [ 0 - nMax ]范围内不重复的数据 nCount 个
 * 注意， nMax 不小于 nCount
 *
 */
QList<qreal> random(int nMax, int nCount)
{
    QList<qreal> intList;
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

void MainWindow::setupUi()
{
    QTabWidget *tabw = ui->tabWidget;

    tabw->removeTab(0);

    // 波形图
    m_qwWaveAnal = new QQuickWidget();
    m_qwWaveAnal->setObjectName(QStringLiteral("qwWaveAnal"));
    m_qwWaveAnal->setResizeMode(QQuickWidget::SizeRootObjectToView );
    m_qwWaveAnal->setSource(QUrl("qrc:/quick/WSDataAnal.qml"));
    m_qwWaveData = new WaveAnalDataModel();
    m_qwWaveAnal->rootContext()->setContextProperty("waveModel", m_qwWaveData);

    tabw->addTab(m_qwWaveAnal, QStringLiteral("Wave - Sample1"));

//    m_qwWaveAnal2 = new QQuickWidget();
//    m_qwWaveAnal2->setObjectName(QStringLiteral("qwWaveAnal"));
//    m_qwWaveAnal2->setResizeMode(QQuickWidget::SizeRootObjectToView );
//    m_qwWaveAnal2->setSource(QUrl("qrc:/quick/WSDataAnal.qml"));
//    m_qwWaveData2 = new WaveAnalDataModel();
//    m_qwWaveAnal2->rootContext()->setContextProperty("waveModel", m_qwWaveData2);

//    tabw->addTab(m_qwWaveAnal2, QStringLiteral("Wave - Sample2"));
}

void MainWindow::currentChanged(int index)
{
    qDebug() << index;

//    if (index == 0)
//    {
//        qDebug()<< m_qwWaveAnal->rootContext();
//        if (m_qwWaveData->test() == "1")
//            m_qwWaveData->setTest("0");
//        else
//            m_qwWaveData->setTest("1");
//    }else if (index == 1){
//        qDebug()<< m_qwWaveAnal2->rootContext();
//        if (m_qwWaveData2->test() == "1")
//            m_qwWaveData2->setTest("0");
//        else
//            m_qwWaveData2->setTest("1");
//    }
}
