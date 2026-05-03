/*
 * Blazecoin Core V1.5 About dialog
 * Andrew Mason 2026
 */

#include "aboutdialog.h"
#include "ui_aboutdialog.h"

#include <QDesktopWidget>

#include "clientmodel.h"
#include "dialog_move_handler.h"

// Copyright year (2009-this)
// Todo: update this when changing our copyright comments in the source
const int ABOUTDIALOG_COPYRIGHT_YEAR = 2026;

AboutDialog::AboutDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::AboutDialog)
{
    ui->setupUi(this);
    setWindowFlags(Qt::CustomizeWindowHint | Qt::FramelessWindowHint | Qt::Window);
    ui->wCaption->installEventFilter(new DialogMoveHandler(this));
    // Set current copyright year
    ui->copyrightLabel->setText(
        tr("Copyright") + QString(" &copy; 2013-2014 ") + tr("Blazecoin") +
        QString("<br/>") +
        tr("Copyright") + QString(" &copy; 2026 Andrew Mason"));

    // Center window (deleted)
//    QRect scr = QApplication::desktop()->screenGeometry();
//    move(scr.center() - rect().center());
}

void AboutDialog::setModel(ClientModel *model)
{
    if(model)
    {
        ui->versionLabel->setText(model->formatFullVersion());
    }
}

AboutDialog::~AboutDialog()
{
    delete ui;
}

void AboutDialog::on_buttonBox_accepted()
{
    close();
}
