#ifndef MESSAGE_BOX_DIALOG_H
#define MESSAGE_BOX_DIALOG_H

#include <QDialog>

namespace Ui {
class MessageBoxDialog;
}

class MessageBoxDialog : public QDialog
{
    Q_OBJECT

public:
    enum ETYPE
    {
        E_INFORMATION,
        E_RED_ALERT,
        E_YES_NO,
        E_YES_NO_CHECKBOX,
    };

    explicit MessageBoxDialog(QWidget *parent = 0);
    ~MessageBoxDialog();
    int showMessage(const QString &title, const QString &text, ETYPE type);

    bool getCheckboxStatusChecked();

    /* QMessageBox-compatible static helpers (always themed) */
    static int information(QWidget *parent, const QString &title, const QString &text);
    static int warning(QWidget *parent, const QString &title, const QString &text);
    static int critical(QWidget *parent, const QString &title, const QString &text);
    /* Returns QDialog::Accepted for Yes, QDialog::Rejected for No/Cancel */
    static int question(QWidget *parent, const QString &title, const QString &text);

protected:
    void changeEvent(QEvent *e);

private:
    Ui::MessageBoxDialog *ui;
};

#endif // MESSAGE_BOX_DIALOG_H
