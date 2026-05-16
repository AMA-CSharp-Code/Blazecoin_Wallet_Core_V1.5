#include "dialog_move_handler.h"
#include <QEvent>
#include <QMouseEvent>
#include <QWidget>
#include <QWindow>

DialogMoveHandler::DialogMoveHandler(QWidget *target)
    : QObject(target)
    , _moving(false)
    , _lastPosition(0, 0)
{
}

bool DialogMoveHandler::eventFilter(QObject *obj, QEvent *event)
{
    QMouseEvent* mouseEvent = static_cast<QMouseEvent*>(event);
    switch (event->type())
    {
    case QEvent::MouseButtonPress:
        if ( mouseEvent->button() == Qt::LeftButton)
        {
            QWidget* target = qobject_cast<QWidget*>(parent());
            if (target)
            {
#if QT_VERSION >= QT_VERSION_CHECK(5, 15, 0)
                // Let the windowing system perform the move. This is the only
                // approach that works under Wayland, which forbids a client
                // from reading or setting its own absolute window position
                // (manual move() below is silently ignored there). It also
                // works correctly on X11 and Windows.
                QWindow* handle = target->window()->windowHandle();
                if (handle && handle->startSystemMove())
                    return true;
#endif
                // Fallback: legacy manual drag, for older Qt or platforms
                // where startSystemMove() is unsupported and reports failure.
                _moving = true;
                _lastPosition = mouseEvent->globalPos();
                return true;
            }
        }
        break;
    case QEvent::MouseMove:
        if (mouseEvent->buttons().testFlag(Qt::LeftButton) && _moving)
        {
            QWidget* target = qobject_cast<QWidget*>(parent());

            if (target)
            {
                target->move(target->pos() + (mouseEvent->globalPos() - _lastPosition));
                _lastPosition = mouseEvent->globalPos();
                return true;
            }
        }
        break;
    case QEvent::MouseButtonRelease:
        if (mouseEvent->button() == Qt::LeftButton)
        {
            _moving = false;
            return true;
        }
        break;
    default:
        break;
    }
    return QObject::eventFilter(obj, event);
}
