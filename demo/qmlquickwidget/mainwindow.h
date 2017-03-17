#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

namespace Ui {
class MainWindow;
}

class QQuickWidget;
class WaveAnalDataModel;
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private:
    void setupUi();

private slots:
    void currentChanged(int index);

private:
    Ui::MainWindow *ui;

    QQuickWidget *m_qwWaveView; // Qml波形分析图
    QQuickWidget *m_qwWaveAnal2; // Qml波形分析图2
    WaveAnalDataModel *m_qwWaveData; // Qml波形分析数据
    WaveAnalDataModel *m_qwWaveData2; // Qml波形分析数据2
};

#endif // MAINWINDOW_H
