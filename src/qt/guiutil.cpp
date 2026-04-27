#include <QApplication>

#include "guiutil.h"
#include "dialog_move_handler.h"

#include "blazecoinaddressvalidator.h"
#include "walletmodel.h"
#include "blazecoinunits.h"

#include "util.h"
#include "init.h"

#include <QDateTime>
#include <QDoubleValidator>
#include <QFont>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QPushButton>
#include <QTextEdit>
#include <QVBoxLayout>
#if QT_VERSION >= 0x050000
#include <QUrlQuery>
#else
#include <QUrl>
#endif
#include <QTextDocument> // for Qt::mightBeRichText
#include <QAbstractItemView>
#include <QClipboard>
#include <QFileDialog>
#include <QDesktopServices>
#include <QThread>

#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>

#ifdef WIN32
#ifdef _WIN32_WINNT
#undef _WIN32_WINNT
#endif
#define _WIN32_WINNT 0x0501
#ifdef _WIN32_IE
#undef _WIN32_IE
#endif
#define _WIN32_IE 0x0501
#define WIN32_LEAN_AND_MEAN 1
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include "shlwapi.h"
#include "shlobj.h"
#include "shellapi.h"
#endif

namespace GUIUtil {

QString dateTimeStr(const QDateTime &date)
{
    return date.toString("hh:mm") + QString(", ") + date.date().toString(Qt::SystemLocaleShortDate);
}

QString dateTimeStr(qint64 nTime)
{
    return dateTimeStr(QDateTime::fromTime_t((qint32)nTime));
}

QFont blazecoinAddressFont()
{
    QFont font("Monospace");
    font.setStyleHint(QFont::TypeWriter);
    return font;
}

void setupAddressWidget(QLineEdit *widget, QWidget *parent)
{
    widget->setMaxLength(BlazecoinAddressValidator::MaxAddressLength);
    widget->setValidator(new BlazecoinAddressValidator(parent));
    widget->setFont(blazecoinAddressFont());
}

void setupAmountWidget(QLineEdit *widget, QWidget *parent)
{
    QDoubleValidator *amountValidator = new QDoubleValidator(parent);
    amountValidator->setDecimals(8);
    amountValidator->setBottom(0.0);
    widget->setValidator(amountValidator);
    widget->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
}

bool parseBlazecoinURI(const QUrl &uri, SendCoinsRecipient *out)
{
    // return if URI is not valid or is no blazecoin URI
    if(!uri.isValid() || uri.scheme() != QString("blazecoin"))
        return false;

    SendCoinsRecipient rv;
    rv.address = uri.path();
    rv.amount = 0;

#if QT_VERSION < 0x050000
    QList<QPair<QString, QString> > items = uri.queryItems();
#else
    QUrlQuery uriQuery(uri);
    QList<QPair<QString, QString> > items = uriQuery.queryItems();
#endif
    for (QList<QPair<QString, QString> >::iterator i = items.begin(); i != items.end(); i++)
    {
        bool fShouldReturnFalse = false;
        if (i->first.startsWith("req-"))
        {
            i->first.remove(0, 4);
            fShouldReturnFalse = true;
        }

        if (i->first == "label")
        {
            rv.label = i->second;
            fShouldReturnFalse = false;
        }
        else if (i->first == "amount")
        {
            if(!i->second.isEmpty())
            {
                if(!BlazecoinUnits::parse(BlazecoinUnits::BLZ, i->second, &rv.amount))
                {
                    return false;
                }
            }
            fShouldReturnFalse = false;
        }

        if (fShouldReturnFalse)
            return false;
    }
    if(out)
    {
        *out = rv;
    }
    return true;
}

bool parseBlazecoinURI(QString uri, SendCoinsRecipient *out)
{
    // Convert blazecoin:// to blazecoin:
    //
    //    Cannot handle this later, because blazecoin:// will cause Qt to see the part after // as host,
    //    which will lower-case it (and thus invalidate the address).
    if(uri.startsWith("blazecoin://"))
    {
        uri.replace(0, 10, "blazecoin:");
    }
    QUrl uriInstance(uri);
    return parseBlazecoinURI(uriInstance, out);
}

QString HtmlEscape(const QString& str, bool fMultiLine)
{
#if QT_VERSION < 0x050000
    QString escaped = Qt::escape(str);
#else
    QString escaped = str.toHtmlEscaped();
#endif
    if(fMultiLine)
    {
        escaped = escaped.replace("\n", "<br>\n");
    }
    return escaped;
}

QString HtmlEscape(const std::string& str, bool fMultiLine)
{
    return HtmlEscape(QString::fromStdString(str), fMultiLine);
}

void copyEntryData(QAbstractItemView *view, int column, int role)
{
    if(!view || !view->selectionModel())
        return;
    QModelIndexList selection = view->selectionModel()->selectedRows(column);

    if(!selection.isEmpty())
    {
        // Copy first item (global clipboard)
        QApplication::clipboard()->setText(selection.at(0).data(role).toString(), QClipboard::Clipboard);
        // Copy first item (global mouse selection for e.g. X11 - NOP on Windows)
        QApplication::clipboard()->setText(selection.at(0).data(role).toString(), QClipboard::Selection);
    }
}

QString getSaveFileName(QWidget *parent, const QString &caption,
                                 const QString &dir,
                                 const QString &filter,
                                 QString *selectedSuffixOut)
{
    QString selectedFilter;
    QString myDir;
    if(dir.isEmpty()) // Default to user documents location
    {
#if QT_VERSION < 0x050000
        myDir = QDesktopServices::storageLocation(QDesktopServices::DocumentsLocation);
#else
        myDir = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
#endif
    }
    else
    {
        myDir = dir;
    }
    QString result = QFileDialog::getSaveFileName(parent, caption, myDir, filter, &selectedFilter);

    /* Extract first suffix from filter pattern "Description (*.foo)" or "Description (*.foo *.bar ...) */
    QRegExp filter_re(".* \\(\\*\\.(.*)[ \\)]");
    QString selectedSuffix;
    if(filter_re.exactMatch(selectedFilter))
    {
        selectedSuffix = filter_re.cap(1);
    }

    /* Add suffix if needed */
    QFileInfo info(result);
    if(!result.isEmpty())
    {
        if(info.suffix().isEmpty() && !selectedSuffix.isEmpty())
        {
            /* No suffix specified, add selected suffix */
            if(!result.endsWith("."))
                result.append(".");
            result.append(selectedSuffix);
        }
    }

    /* Return selected suffix if asked to */
    if(selectedSuffixOut)
    {
        *selectedSuffixOut = selectedSuffix;
    }
    return result;
}

Qt::ConnectionType blockingGUIThreadConnection()
{
    if(QThread::currentThread() != qApp->thread())
    {
        return Qt::BlockingQueuedConnection;
    }
    else
    {
        return Qt::DirectConnection;
    }
}

bool checkPoint(const QPoint &p, const QWidget *w)
{
    QWidget *atW = QApplication::widgetAt(w->mapToGlobal(p));
    if (!atW) return false;
    return atW->topLevelWidget() == w;
}

bool isObscured(QWidget *w)
{
    return !(checkPoint(QPoint(0, 0), w)
        && checkPoint(QPoint(w->width() - 1, 0), w)
        && checkPoint(QPoint(0, w->height() - 1), w)
        && checkPoint(QPoint(w->width() - 1, w->height() - 1), w)
        && checkPoint(QPoint(w->width() / 2, w->height() / 2), w));
}

void openDebugLogfile()
{
    boost::filesystem::path pathDebug = GetDataDir() / "debug.log";

    /* Open debug.log with the associated application */
    if (boost::filesystem::exists(pathDebug))
        QDesktopServices::openUrl(QUrl::fromLocalFile(QString::fromStdString(pathDebug.string())));
}

ToolTipToRichTextFilter::ToolTipToRichTextFilter(int size_threshold, QObject *parent) :
    QObject(parent), size_threshold(size_threshold)
{

}

bool ToolTipToRichTextFilter::eventFilter(QObject *obj, QEvent *evt)
{
    if(evt->type() == QEvent::ToolTipChange)
    {
        QWidget *widget = static_cast<QWidget*>(obj);
        QString tooltip = widget->toolTip();
        if(tooltip.size() > size_threshold && !tooltip.startsWith("<qt/>") && !Qt::mightBeRichText(tooltip))
        {
            // Prefix <qt/> to make sure Qt detects this as rich text
            // Escape the current message as HTML and replace \n by <br>
            tooltip = "<qt/>" + HtmlEscape(tooltip, true);
            widget->setToolTip(tooltip);
            return true;
        }
    }
    return QObject::eventFilter(obj, evt);
}

#ifdef WIN32
boost::filesystem::path static StartupShortcutPath()
{
    return GetSpecialFolderPath(CSIDL_STARTUP) / "Blazecoin.lnk";
}

bool GetStartOnSystemStartup()
{
    // check for Blazecoin.lnk
    return boost::filesystem::exists(StartupShortcutPath());
}

bool SetStartOnSystemStartup(bool fAutoStart)
{
    // If the shortcut exists already, remove it for updating
    boost::filesystem::remove(StartupShortcutPath());

    if (fAutoStart)
    {
        CoInitialize(NULL);

        // Get a pointer to the IShellLink interface.
        IShellLink* psl = NULL;
        HRESULT hres = CoCreateInstance(CLSID_ShellLink, NULL,
                                CLSCTX_INPROC_SERVER, IID_IShellLink,
                                reinterpret_cast<void**>(&psl));

        if (SUCCEEDED(hres))
        {
            // Get the current executable path
            TCHAR pszExePath[MAX_PATH];
            GetModuleFileName(NULL, pszExePath, sizeof(pszExePath));

            TCHAR pszArgs[5] = TEXT("-min");

            // Set the path to the shortcut target
            psl->SetPath(pszExePath);
            PathRemoveFileSpec(pszExePath);
            psl->SetWorkingDirectory(pszExePath);
            psl->SetShowCmd(SW_SHOWMINNOACTIVE);
            psl->SetArguments(pszArgs);

            // Query IShellLink for the IPersistFile interface for
            // saving the shortcut in persistent storage.
            IPersistFile* ppf = NULL;
            hres = psl->QueryInterface(IID_IPersistFile,
                                       reinterpret_cast<void**>(&ppf));
            if (SUCCEEDED(hres))
            {
                WCHAR pwsz[MAX_PATH];
                // Ensure that the string is ANSI.
                MultiByteToWideChar(CP_ACP, 0, StartupShortcutPath().string().c_str(), -1, pwsz, MAX_PATH);
                // Save the link by calling IPersistFile::Save.
                hres = ppf->Save(pwsz, TRUE);
                ppf->Release();
                psl->Release();
                CoUninitialize();
                return true;
            }
            psl->Release();
        }
        CoUninitialize();
        return false;
    }
    return true;
}

#elif defined(LINUX)

// Follow the Desktop Application Autostart Spec:
//  http://standards.freedesktop.org/autostart-spec/autostart-spec-latest.html

boost::filesystem::path static GetAutostartDir()
{
    namespace fs = boost::filesystem;

    char* pszConfigHome = getenv("XDG_CONFIG_HOME");
    if (pszConfigHome) return fs::path(pszConfigHome) / "autostart";
    char* pszHome = getenv("HOME");
    if (pszHome) return fs::path(pszHome) / ".config" / "autostart";
    return fs::path();
}

boost::filesystem::path static GetAutostartFilePath()
{
    return GetAutostartDir() / "blazecoin.desktop";
}

bool GetStartOnSystemStartup()
{
    boost::filesystem::ifstream optionFile(GetAutostartFilePath());
    if (!optionFile.good())
        return false;
    // Scan through file for "Hidden=true":
    std::string line;
    while (!optionFile.eof())
    {
        getline(optionFile, line);
        if (line.find("Hidden") != std::string::npos &&
            line.find("true") != std::string::npos)
            return false;
    }
    optionFile.close();

    return true;
}

bool SetStartOnSystemStartup(bool fAutoStart)
{
    if (!fAutoStart)
        boost::filesystem::remove(GetAutostartFilePath());
    else
    {
        char pszExePath[MAX_PATH+1];
        memset(pszExePath, 0, sizeof(pszExePath));
        if (readlink("/proc/self/exe", pszExePath, sizeof(pszExePath)-1) == -1)
            return false;

        boost::filesystem::create_directories(GetAutostartDir());

        boost::filesystem::ofstream optionFile(GetAutostartFilePath(), std::ios_base::out|std::ios_base::trunc);
        if (!optionFile.good())
            return false;
        // Write a blazecoin.desktop file to the autostart directory:
        optionFile << "[Desktop Entry]\n";
        optionFile << "Type=Application\n";
        optionFile << "Name=Blazecoin\n";
        optionFile << "Exec=" << pszExePath << " -min\n";
        optionFile << "Terminal=false\n";
        optionFile << "Hidden=false\n";
        optionFile.close();
    }
    return true;
}
#else

// TODO: OSX startup stuff; see:
// https://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Articles/CustomLogin.html

bool GetStartOnSystemStartup() { return false; }
bool SetStartOnSystemStartup(bool fAutoStart) { return false; }

#endif

HelpMessageBox::HelpMessageBox(QWidget *parent) :
    QDialog(parent)
{
    header = tr("Blazecoin-Qt") + " " + tr("version") + " " +
        QString::fromStdString(FormatFullVersion()) + "\n\n" +
        tr("Usage:") + "\n" +
        "  blazecoin-qt [" + tr("command-line options") + "]                     " + "\n";

    coreOptions = QString::fromStdString(HelpMessage());

    uiOptions = tr("UI options") + ":\n" +
        "  -lang=<lang>           " + tr("Set language, for example \"de_DE\" (default: system locale)") + "\n" +
        "  -min                   " + tr("Start minimized") + "\n" +
        "  -splash                " + tr("Show splash screen on startup (default: 1)") + "\n";

    setWindowTitle(tr("Blazecoin-Qt"));
    setWindowFlags(Qt::CustomizeWindowHint | Qt::FramelessWindowHint | Qt::Window);
    setObjectName("HelpMessageBox");
    setAttribute(Qt::WA_StyledBackground, true);
    resize(700, 500);

    // --- Custom dark title bar (wCaption) ---
    QWidget *wCaption = new QWidget(this);
    wCaption->setObjectName("wCaption");
    wCaption->setFixedHeight(32);
    wCaption->setStyleSheet("#wCaption { background-color: rgb(0, 0, 0); border: 1px solid #d80317; }");

    QLabel *lbCaptionTitle = new QLabel(tr("Command-line Options"), wCaption);
    QFont captionFont("Arial", 11);
    captionFont.setStyleStrategy(QFont::PreferAntialias);
    lbCaptionTitle->setFont(captionFont);
    lbCaptionTitle->setStyleSheet("QLabel { color: #FFFFFF; background-color: transparent; }");

    QPushButton *bClose = new QPushButton(wCaption);
    bClose->setFixedSize(30, 30);
    bClose->setFlat(true);
    bClose->setStyleSheet(
        "QPushButton {"
        "  background-color: transparent;"
        "  background-image: url(:/res/close_normal.png);"
        "  background-repeat: no-repeat;"
        "  background-position: center;"
        "  border: 0px solid gray;"
        "}"
        "QPushButton:hover {"
        "  background-color: #d80317;"
        "  background-image: url(:/res/close_normal.png);"
        "  background-repeat: no-repeat;"
        "  background-position: center;"
        "}"
        "QPushButton:pressed:flat {"
        "  background-color: #FF1A2E;"
        "  background-image: url(:/res/close_normal.png);"
        "  background-repeat: no-repeat;"
        "  background-position: center;"
        "}"
    );
    connect(bClose, SIGNAL(clicked()), this, SLOT(close()));

    QHBoxLayout *captionLay = new QHBoxLayout(wCaption);
    captionLay->setContentsMargins(13, 0, 0, 0);
    captionLay->setSpacing(0);
    captionLay->addWidget(lbCaptionTitle);
    captionLay->addStretch();
    captionLay->addWidget(bClose);

    wCaption->installEventFilter(new DialogMoveHandler(this));

    // --- Body: header label + scrollable help text + OK button ---
    QLabel *lbHeader = new QLabel(header, this);
    lbHeader->setWordWrap(true);

    QTextEdit *txtBody = new QTextEdit(this);
    txtBody->setReadOnly(true);
    txtBody->setPlainText(coreOptions + "\n" + uiOptions);
    txtBody->setLineWrapMode(QTextEdit::NoWrap);

    QPushButton *bOk = new QPushButton(tr("OK"), this);
    connect(bOk, SIGNAL(clicked()), this, SLOT(accept()));

    QHBoxLayout *btnRow = new QHBoxLayout();
    btnRow->addStretch();
    btnRow->addWidget(bOk);
    btnRow->addStretch();

    QVBoxLayout *body = new QVBoxLayout();
    body->setContentsMargins(14, 12, 14, 14);
    body->setSpacing(10);
    body->addWidget(lbHeader);
    body->addWidget(txtBody);
    body->addLayout(btnRow);

    QVBoxLayout *root = new QVBoxLayout(this);
    root->setContentsMargins(0, 0, 0, 0);
    root->setSpacing(0);
    root->addWidget(wCaption);
    root->addLayout(body);

    // Dark theme to match the rest of the wallet.
    setStyleSheet(
        "#HelpMessageBox { background-color: rgb(0, 0, 0); border: 1px solid #d80317; }"
        "QLabel { color: #FFFFFF; }"
        "QTextEdit, QPlainTextEdit {"
        "  background-color: rgba(0, 0, 0, 200);"
        "  color: #FFFFFF;"
        "  border: 1px solid #d80317;"
        "  selection-background-color: rgba(216, 3, 23, 120);"
        "  selection-color: #FFFFFF;"
        "}"
        "QPushButton {"
        "  background-color: rgba(0, 0, 0, 200);"
        "  color: #FFFFFF;"
        "  border: 1px solid #d80317;"
        "  padding: 4px 14px;"
        "  min-height: 22px;"
        "  min-width: 70px;"
        "}"
        "QPushButton:hover { background-color: #d80317; }"
        "QPushButton:pressed { background-color: #FF1A2E; }"
        "QScrollBar:vertical { border: 0px; background: rgba(0,0,0,60); width: 9px; }"
        "QScrollBar::handle:vertical { background: rgba(255,255,255,90); min-height: 20px; }"
        "QScrollBar::sub-line:vertical, QScrollBar::add-line:vertical { height: 0px; }"
    );
}

void HelpMessageBox::printToConsole()
{
    // On other operating systems, the expected action is to print the message to the console.
    QString strUsage = header + "\n" + coreOptions + "\n" + uiOptions;
    fprintf(stdout, "%s", strUsage.toStdString().c_str());
}

void HelpMessageBox::showOrPrint()
{
#if defined(WIN32)
        // On Windows, show a message box, as there is no stderr/stdout in windowed applications
        exec();
#else
        // On other operating systems, print help text to console
        printToConsole();
#endif
}

} // namespace GUIUtil
