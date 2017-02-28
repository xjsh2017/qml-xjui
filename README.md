# xjqmlui



+ Add two commands below to project setting in qt creator:

nmake install
qmlplugindump -notrelocatable XjQmlUi 1.0 %{CurrentProject:QT_HOST_BINS}/../qml/XjQmlUi > %{CurrentProject:QT_HOST_BINS}/../qml/XjQmlUi/plugin.qmltypes