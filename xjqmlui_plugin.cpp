#include "xjqmlui_plugin.h"
#include "xjitem.h"

#include <qqml.h>

void XjQmlUiPlugin::registerTypes(const char *uri)
{
    // @uri XjQmlUi
    qmlRegisterType<XjItem>(uri, 1, 0, "XjItem");
}

