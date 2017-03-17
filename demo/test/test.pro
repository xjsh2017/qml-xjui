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

SRC_PATH = ../../src
INCLUDEPATH += $${SRC_PATH}

include($${SRC_PATH}/stores/stores.lite.pri)

qmldemo.files += \
    ./*.qml \
    views/*.qml


OTHER_FILES += $$qmldemo.files
