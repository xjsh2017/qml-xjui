#ifndef XJITEM_H
#define XJITEM_H

#include <QQuickItem>

class XjItem : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(XjItem)

public:
    XjItem(QQuickItem *parent = 0);
    ~XjItem();
};

#endif // XJITEM_H
