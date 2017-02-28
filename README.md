# xjqmlui



### 编译及配置

1、 在xjqmlui.pro的Build Settings 中，添加如下2条命令到 Build Steps:


nmake install
qmlplugindump -notrelocatable XjQmlUi 1.0 %{CurrentProject:QT_HOST_BINS}/../qml/XjQmlUi > %{CurrentProject:QT_HOST_BINS}/../qml/XjQmlUi/plugin.qmltypes


2、在xjqmlui.pro的 Run Settings 中，将 Working directory 设置为 demo/test目录下