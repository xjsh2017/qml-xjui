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

qmldemo.files += \
    ./*.qml \
    views/*.qml \
    ../../views/*


OTHER_FILES += $$qmldemo.files
