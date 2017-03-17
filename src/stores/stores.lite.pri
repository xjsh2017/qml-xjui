#-------------------------------------------------
#
# Project created by QtCreator 2016-03-31T17:50:25
#
#-------------------------------------------------

INCLUDEPATH += $$SDKInclude $$PWD
#message($$SDKInclude)

INCLUDEPATH += $$SDKInclude \
        $$SDKInclude/cim/core \
        $$SDKInclude/cim/core/core \
        $$SDKInclude/cim/core/domain \
        $$SDKInclude/cim/core/energyscheduling \
        $$SDKInclude/cim/core/financial \
        $$SDKInclude/cim/core/generationdynamics \
        $$SDKInclude/cim/core/loadmodel \
        $$SDKInclude/cim/core/meas \
        $$SDKInclude/cim/core/outage \
        $$SDKInclude/cim/core/production \
        $$SDKInclude/cim/core/protection \
        $$SDKInclude/cim/core/reservation \
        $$SDKInclude/cim/core/scada \
        $$SDKInclude/cim/core/topology \
        $$SDKInclude/cim/core/wires


HEADERS += $$PWD/waveanaldatamodel.h


SOURCES += $$PWD/waveanaldatamodel.cpp
