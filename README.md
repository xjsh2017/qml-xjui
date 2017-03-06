# qml-xjui


### 编译及配置

1、 在qml-xjui.pro的Build Settings 中，添加如下2条命令到 Build Steps:


nmake install
qmlplugindump -notrelocatable XjUi 1.0 %{CurrentProject:QT_HOST_BINS}/../qml/XjUi > %{CurrentProject:QT_HOST_BINS}/../qml/XjUi/plugin.qmltypes


2、在qml-xjui.pro的 Run Settings 中，将 Working directory 设置为 demo/test目录下


---


### 参考

https://github.com/bebu/QmlChart.git

https://github.com/jwintz/qchart.js.git
