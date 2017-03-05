#include "mainwindow.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    MainWindow w;
    w.setGeometry(40, 40, 800, 600);
    w.showNormal();

    return a.exec();
}
