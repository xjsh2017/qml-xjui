#ifndef QXJQUICKWIDGET_H
#define QXJQUICKWIDGET_H

#include <QQuickWidget>

class QXJQuickWidget : public QQuickWidget
{
    Q_OBJECT

public:
    QXJQuickWidget(QWidget *parent = Q_NULLPTR);

    void hideEvent(QHideEvent *) {}
};

#endif // QXJQUICKWIDGET_H
