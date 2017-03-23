#include "mainwindow.h"
#include "ui_mainwindow.h"

#include "qxjquickwidget.h"
#include <QQuickView>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QTimer>

#include <QDebug>

#include "stores/waveanaldatamodel.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    setupUi();

    connect(ui->tabWidget, SIGNAL(currentChanged(int)), this, SLOT(currentChanged(int)));

    //新建一个QTimer对象
    m_timer = new QTimer();
    //设置定时器每个多少毫秒发送一个timeout()信号
    m_timer->setInterval(11000);
    //启动定时器
    m_timer->start();

    connect(m_timer, SIGNAL(timeout()), this, SLOT(onTimerOut()));
}

MainWindow::~MainWindow()
{
    delete ui;
    delete m_qwWaveData;
    delete m_qwWaveView;
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
    m_qwWaveView = new QXJQuickWidget(this);
    m_qwWaveView->resize(300,300);
    m_qwWaveView->setObjectName(QStringLiteral("qwWaveAnal"));
    m_qwWaveView->setResizeMode(QQuickWidget::SizeRootObjectToView );
    m_qwWaveView->setSource(QUrl("qrc:/quick/WSDataAnal.qml"));
//    QQmlComponent *component = new QQmlComponent(m_qwWaveView->engine());
//    component->setData("import QtQuick 2.4\n import XjUi 1.0 \n WSDataAnal{}", QUrl());
//    m_qwWaveView->setContent(QUrl(), component, component->create());
    m_qwWaveData = new WaveAnalDataModel();
//    QList<qreal> starts;
//    starts.push_back(0);
//    starts.push_back(0);
//    starts.push_back(120);
//    starts.push_back(240);
    m_qwWaveData->buildSinWaveData(27, 1601, 20, 0, 900, -20, 20, true/*, starts*/);
    m_qwWaveView->rootContext()->setContextProperty("waveModel", m_qwWaveData);

    tabw->addTab(m_qwWaveView, QStringLiteral("Wave - Sample1"));

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

}

void MainWindow::onTimerOut()
{
    //获取系统当前时间
    QTime time = QTime::currentTime();

    qDebug() << time.toString("hh:mm:ss") << "onTimerOut triggered!";

    m_qwWaveData->sync();
}
