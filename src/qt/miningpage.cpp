#include "miningpage.h"
#include "ui_miningpage.h"
#include "guiutil.h"
#include "util.h"
#include "main.h"
#include "init.h"
#include "blazecoingui.h"

#include <QTime>
#include <QTimer>
#include <QThread>
#include <QTextEdit>
#include <QKeyEvent>
#include <QUrl>
#include <QScrollBar>

#ifdef WIN32
// For GetActiveProcessorCount across all processor groups (Windows 7+).
// boost::thread::hardware_concurrency() only sees the current group (64-cpu cap),
// which is insufficient on >64-core systems (e.g. dual 96-core CPUs).
#include <windows.h>
#endif

// Hard cap on the slider so future hardware doesn't immediately need a recompile.
static const int kMiningThreadMax = 512;

MiningPage::MiningPage(QWidget *parent, BlazecoinGUI *mainForm) :
    QWidget(parent),
    ui(new Ui::MiningPage)
{
    _mainFrom = mainForm;
    ui->setupUi(this);
    clear();
    ui->procSlider->setMinimum(1);
    int nProcessors = 0;
#ifdef WIN32
    // Look up GetActiveProcessorCount dynamically (the codebase sets
    // _WIN32_WINNT to 0x0501 which hides the Win7+ symbol at compile time).
    typedef DWORD (WINAPI *GAPCFn)(WORD);
    HMODULE hKernel = GetModuleHandleA("kernel32.dll");
    if (hKernel) {
        GAPCFn pGetActiveProcessorCount =
            (GAPCFn)GetProcAddress(hKernel, "GetActiveProcessorCount");
        if (pGetActiveProcessorCount)
            nProcessors = (int)pGetActiveProcessorCount(0xFFFF /*ALL_PROCESSOR_GROUPS*/);
    }
#endif
    if (nProcessors <= 0)
        nProcessors = (int)boost::thread::hardware_concurrency();
    if (nProcessors < 1)
        nProcessors = 1;
    if (nProcessors > kMiningThreadMax)
        nProcessors = kMiningThreadMax;
    // Reserve one core for the OS/GUI on multi-core systems so the wallet
    // stays responsive at max slider — single-core boxes still get to use it.
    int nMaxThreads = (nProcessors > 1) ? (nProcessors - 1) : 1;
    ui->procSlider->setMaximum(nMaxThreads);
    ui->procSlider->setValue((nMaxThreads + 1) / 2);
    connect(ui->procSlider, SIGNAL(valueChanged(int)), this, SLOT(slotThreadsChanged(int)));
    slotThreadsChanged(ui->procSlider->value());
    QTimer* ptimer = new QTimer(this);
    connect(ptimer, SIGNAL(timeout()), SLOT(slotUpdateSpeed()));
    ptimer->start(1000);
    slotUpdateSpeed();
}

void MiningPage::slotThreadsChanged(int n)
{
    ui->lThreadCount->setText(QString::number(n));
    // Visual warning when the user pushes past 75% of usable cores —
    // sustained near-max mining can thermal-throttle or overload the PSU.
    const int nMax = ui->procSlider->maximum();
    const bool bHot = (nMax > 1) && (n * 4 > nMax * 3);
    ui->lThreadCount->setStyleSheet(
        bHot ? "QLabel { color: #FF6B6B; font-size: 14px; font-weight: bold; }"
             : "QLabel { color: #FFFFFF; font-size: 14px; }");
}

void MiningPage::slotUpdateSpeed()
{
        boost::int64_t speed = 0;
        if (GetTimeMillis() - nHPSTimerStart > 8000)
            speed = (boost::int64_t)0;
        else
            speed = (boost::int64_t)dHashesPerSec;
        if (ui->bStopMining->isEnabled())
        ui->lSpeed->setText(QString("%1 Kh/s").arg(speed / 1000));
}

MiningPage::~MiningPage()
{
    delete ui;
}

void MiningPage::scrollToEnd()
{
    QScrollBar *scrollbar = ui->miningLog->verticalScrollBar();
    scrollbar->setValue(scrollbar->maximum());
}

void MiningPage::SetMiningStatus(bool isMining)
{
    ui->bStartMining->setEnabled(!isMining);
    ui->bStopMining->setEnabled(isMining);
    ui->procSlider->setEnabled(!isMining);
    if (!isMining)
        ui->lSpeed->setText("");
    _mainFrom->SetMiningStatus(isMining);
    if (isMining)
    {
        message(CMD_REQUEST, tr("Mining coins started!"));
        int64 pc = GetArg("-genproclimit", -1);
        message(CMD_REQUEST, QString(tr("Used threads %1")).arg(pc));
    }
    else
        message(CMD_REQUEST, tr("Mining coins stopped!"));
}

void MiningPage::clear()
{
    ui->miningLog->clear();

    ui->miningLog->document()->setDefaultStyleSheet(
                "table { }"
                "td.time { color: #b0b0b0; padding-top: 3px; } "
                "td.message { font-family: Monospace; font-size: 12px; color: #FFFFFF; } "
                "td.cmd-request { color: #FFFFFF; } "
                "td.cmd-error { color: #FF6B6B; } "
                "b { color: #FFFFFF; } "
                );
}

static QString categoryClass(int category)
{
    switch(category)
    {
    case MiningPage::CMD_REQUEST:  return "cmd-request"; break;
    case MiningPage::CMD_REPLY:    return "cmd-reply"; break;
    case MiningPage::CMD_ERROR:    return "cmd-error"; break;
    default:                       return "misc";
    }
}

void MiningPage::message(int category, const QString &message, bool html)
{
    QTime time = QTime::currentTime();
    QString timeString = time.toString();
    QString out;
    out += "<table><tr><td class=\"time\" width=\"65\">" + timeString + "</td>";
    out += "<td class=\"icon\" width=\"32\"><img src=\"" + categoryClass(category) + "\"></td>";
    out += "<td class=\"message " + categoryClass(category) + "\" valign=\"middle\">";
    if(html)
        out += message;
    else
        out += GUIUtil::HtmlEscape(message, true);
    out += "</td></tr></table>";
    ui->miningLog->append(out);
}

void MiningPage::on_bStartMining_clicked()
{
    message(CMD_REPLY, tr("Running mining coins..."));
    try
    {
        bool res = SetGenerate(true, ui->procSlider->value());
        if (res == true)
            SetMiningStatus(res);
        else
            message(CMD_ERROR, tr("Start error!"));
    }
    catch (std::exception& e)
    {
        message(CMD_ERROR, QString("Error: ") + QString::fromStdString(e.what()));
    }
    scrollToEnd();
}

void MiningPage::on_bStopMining_clicked()
{
    message(CMD_REPLY, tr("Stop mining coins..."));
    try
    {
        bool res = SetGenerate(false, -1);
        if (res == false)
            SetMiningStatus(res);
        else
            message(CMD_ERROR, tr("Stop error!"));
    }
    catch (std::exception& e)
    {
        message(CMD_ERROR, QString("Error: ") + QString::fromStdString(e.what()));
    }
    scrollToEnd();
}

bool MiningPage::SetGenerate(bool start, int proc)
{
    bool fGenerate = start;
    int nGenProcLimit = proc;
    mapArgs["-genproclimit"] = itostr(nGenProcLimit);
    if (nGenProcLimit == 0)
        fGenerate = false;
    mapArgs["-gen"] = (fGenerate ? "1" : "0");
    GenerateBlazecoins(fGenerate, pwalletMain);
    return GetBoolArg("-gen", false);
}
