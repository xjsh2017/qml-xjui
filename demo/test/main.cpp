#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QQmlContext>
#include <QDir>

#include "stores/waveanaldatamodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    WaveAnalDataModel data;
//    data.buildData(10, 800, 20);
    data.buildData(2, 12000, 3800);

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("waveModel", &data);

#ifdef Q_USE_QML_RC
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
#else
    engine.load(QUrl::fromLocalFile(QDir::currentPath() +
                                #if defined(Q_OS_WIN)
                                    QStringLiteral("")
                                #elif defined(Q_OS_MAC)
                                    QStringLiteral("/../../..")
                                #endif
                                + QStringLiteral("/test/main.qml")));
#endif

    return app.exec();
}
