TEMPLATE = lib
TARGET = XjQmlUi

QT += qml quick
CONFIG += qt plugin c++11

TARGET = $$qtLibraryTarget($$TARGET)
uri = XjQmlUi

# Input
SOURCES += \
    xjqmlui_plugin.cpp \
    xjitem.cpp

HEADERS += \
    xjqmlui_plugin.h \
    xjitem.h


target.path = $$[QT_INSTALL_QML]/$$uri

#message($$target.path)

searchlist += \
    *.qml \
    *.js \
    *.png \
    *.jpg \
    *.gif \
    *.svg \
    *qmldir

for (searchvar, searchlist) {
    qrclist += $$files($$searchvar, true)
}

OTHER_FILES += $$qrclist

views.files += views/*
views.path = $$[QT_INSTALL_QML]/$$uri/views

components.files += components/*
components.path = $$[QT_INSTALL_QML]/$$uri/components

icons.files += icons/*
icons.path = $$[QT_INSTALL_QML]/XjQmlUi/icons

qmldir.files = $$PWD/qmldir
qmldir.path = $$[QT_INSTALL_QML]/$$uri
qmldir.CONFIG += no_check_exist

INSTALLS += target views components qmldir# icons

OTHER_FILES += $$qmlui.files
