#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QQmlContext>

#include "stores/waveanaldatamodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    WaveAnalDataModel data;
//    data.buildData(10, 800, 20);
    data.buildData(10, 800, 20);

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("waveModel", &data);

#ifdef Q_USE_QML_RC
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
#else
    engine.load(QUrl::fromLocalFile(QGuiApplication::applicationDirPath() +
                                #if defined(Q_OS_WIN)
                                    QStringLiteral("/..")
                                #elif defined(Q_OS_MAC)
                                    QStringLiteral("/../../..")
                                #endif
                                + QStringLiteral("/../../main.qml")));
#endif

    return app.exec();
}
