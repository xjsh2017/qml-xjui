#include "xjui_plugin.h"
#include "xjitem.h"

#include <qqml.h>

void XjUiPlugin::registerTypes(const char *uri)
{
    // @uri XjUi
    qmlRegisterType<XjItem>(uri, 1, 0, "XjItem");
}

