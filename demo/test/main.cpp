#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QQmlContext>
#include <QDir>
#include <QDebug>

#include "stores/waveanaldatamodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    WaveAnalDataModel data;

    QList<qreal> starts;
    starts.push_back(0);
    starts.push_back(120);
    starts.push_back(240);
    data.buildSinWaveData(27, 1601, 20, 0, 900, -20, 20, false, starts);

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
                                + ("/test/main.qml")));
#endif

    return app.exec();
}
