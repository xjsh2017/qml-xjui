#-------------------------------------------------
#
# Project created by QtCreator 2016-03-31T17:50:25
#
#-------------------------------------------------

INCLUDEPATH += $$SDKInclude $$PWD
#message($$SDKInclude)

include(stores/stores.pri)

searchlist += $$PWD/*.h
for(searchvar, searchlist) {
    hlist += $$files($$searchvar, true)
}

HEADERS += $$hlist

searchlist = $$PWD/*.cpp
for(searchvar, searchlist) {
    srclist += $$files($$searchvar, true)
}

SOURCES += $$srclist
