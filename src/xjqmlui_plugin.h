#ifndef XJQMLUI_PLUGIN_H
#define XJQMLUI_PLUGIN_H

#include <QQmlExtensionPlugin>

class XjQmlUiPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
};

#endif // XJQMLUI_PLUGIN_H
