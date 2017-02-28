TEMPLATE = app

QT += qml quick
CONFIG += c++11

SOURCES += main.cpp

RESOURCES += \#qml.qrc \
    $$[QT_INSTALL_QML]/icons/icons_all.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)
include(stores/stores.pri)
#include(../../src/src.pri)

qmldemo.files += \
    ./*.qml \
    views/*.qml


OTHER_FILES += $$qmldemo.files
