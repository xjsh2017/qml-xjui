TEMPLATE = lib
TARGET = XjUi

QT += qml quick
CONFIG += qt plugin c++11

#TARGET = $$qtLibraryTarget($$TARGET)
uri = XjUi

include(corelib.pri)

target.path = $$[QT_INSTALL_QML]/$$uri

#----------------------------------------------------------------
# INSTALLS

views.files += views/*
views.path = $$[QT_INSTALL_QML]/$$uri/views

core.files += core/*
core.path = $$[QT_INSTALL_QML]/$$uri/core

components.files += components/*
                components/QChart/*
                components/Grover/*
components.path = $$[QT_INSTALL_QML]/$$uri/components

icons.files += icons/*
icons.path = $$[QT_INSTALL_QML]/XjUi/icons

qmlfiles.files += qml/*
qmlfiles.path = $$[QT_INSTALL_QML]/XjUi/qml

qmldir.files = $$PWD/qmldir
qmldir.path = $$[QT_INSTALL_QML]/$$uri
qmldir.CONFIG += no_check_exist

INSTALLS += target qmldir views components core qmlfiles# icons

#---------------------------INSTALLS FILES end -------------------------------------
# generate QML folder

searchlist += \
    *.qml \
    *.js \
    *qmldir \

for (searchvar, searchlist) {
    qrclist += $$files($$searchvar, true)
}

OTHER_FILES += $$qrclist # QML folder

#---------------------generate QML folder end-------------------------------------------
# generate qml.qrc

RESOURCE_CONTENT = \
    "<RCC>" \
    "    <qresource prefix=\"/\"> "
for (qrcvar, qrclist) {
        resourcefileabsolutepath = $$absolute_path($$qrcvar)
        relativepath_in = $$relative_path($$resourcefileabsolutepath, $$PWD)
#        relativepath_out = $$relative_path($$resourcefileabsolutepath, $$OUT_PWD)
        RESOURCE_CONTENT += "<file alias=\"$$relativepath_in\">$$relativepath_in</file>"
}
RESOURCE_CONTENT += \
    '    </qresource>' \
    </RCC>
GENERATED_RESOURCE_FILE = $$PWD/qml.qrc
#write_file($$GENERATED_RESOURCE_FILE, RESOURCE_CONTENT)
#RESOURCES += $$GENERATED_RESOURCE_FILE
#QMAKE_PRE_LINK += $(DEL_FILE) $$GENERATED_RESOURCE_FILE
QMAKE_CLEAN += $$GENERATED_RESOURCE_FILE


CONFIG += qtquickcompiler
#--------------------generate qml.qrc end--------------------------------------------
