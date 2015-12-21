//
//  pprocess.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "pprocess.h"

#include <sys/resource.h>

#define new PNEW

int PX_NewHandle(const char * clsName, int fd)
{
    if (fd < 0)
        return fd;
    
    static int lowWaterMark = INT_MAX;
    static int highWaterMark = 0;
    if (fd > highWaterMark) {
        highWaterMark = fd;
        lowWaterMark = fd;
        
        int maxHandles = PProcess::Current().GetMaxHandles();
        if (fd < (maxHandles-maxHandles/20))
            PTRACE(4, "PWLib\tFile handle high water mark set: " << fd << ' ' << clsName);
        else
            PTRACE(1, "PWLib\tFile handle high water mark within 5% of maximum: " << fd << ' ' << clsName);
    }
    
    if (fd < lowWaterMark) {
        lowWaterMark = fd;
        PTRACE(4, "PWLib\tFile handle low water mark set: " << fd << ' ' << clsName);
    }
    
    return fd;
}

static PMutex * PTraceMutex = NULL;

#ifndef __NUCLEUS_PLUS__
static ostream * PErrorStream = &cerr;
#else
static ostream * PErrorStream = NULL;
#endif

ostream & PGetErrorStream()
{
    return *PErrorStream;
}


void PSetErrorStream(ostream * s)
{
#ifndef __NUCLEUS_PLUS__
    PErrorStream = s != NULL ? s : &cerr;
#else
    PErrorStream = s;
#endif
}

#if !defined(__NUCLEUS_PLUS__)
static ostream * PTraceStream = &cerr;
#else

#ifdef __NUCLEUS_PLUS__
static ostream * PTraceStream = 0L;
#endif

#endif

static unsigned PTraceOptions = PTrace::FileAndLine;
static unsigned PTraceLevelThreshold = 0;
static PTimeInterval ApplicationStartTick = PTimer::Tick();
unsigned PTraceCurrentLevel;
static const char * PTrace_Filename = NULL;
static int PTrace_lastDayOfYear = 0;

void PTrace::SetStream(ostream * s)
{
#ifndef __NUCLEUS_PLUS__
    if (s == NULL)
        s = &cerr;
#endif
    
    if (PTraceMutex == NULL)
        PTraceStream = s;
    else {
        PWaitAndSignal m(*PTraceMutex);
        PTraceStream = s;
    }
}

static void OpenTraceFile()
{
#if 0
    PFilePath fn(PTrace_Filename);
    
    if ((PTraceOptions & PTrace::RotateDaily) != 0)
        fn = PFilePath(fn.GetDirectory() + (fn.GetTitle() + PTime(/*(PTraceOptions&PTrace::GMTTime) ? PTime::GMT : PTime::Local*/).AsString("yyyy_MM_dd") + fn.GetType()));
    
    PTextFile * traceOutput;
    if (PTraceOptions & PTrace::AppendToFile) {
        traceOutput = new PTextFile(fn, PFile::ReadWrite);
        traceOutput->SetPosition(0, PFile::End);
    } else
        traceOutput = new PTextFile(fn, PFile::WriteOnly);
    
    if (traceOutput->IsOpen())
        PTrace::SetStream(traceOutput);
    else {
        PTRACE(0, PProcess::Current().GetName() << "Could not open trace output file \"" << fn << '"');
        delete traceOutput;
    }
#endif
}

void PTrace::Initialise(unsigned level, const char * filename, unsigned options)
{
    // If we have a tracing version, then open trace file and set modes
#if PTRACING
    PProcess & process = PProcess::Current();
#endif
    
#if PMEMORY_CHECK
    int ignoreAllocations = -1;
#endif
    
    PTrace_Filename = filename;
    PTraceOptions = options;
    
    if (options & RotateDaily)
        PTrace_lastDayOfYear = PTime(/*(PTraceOptions&GMTTime) ? PTime::GMT : PTime::Local*/).GetDayOfYear();
    else
        PTrace_lastDayOfYear = 0;
    
    if (filename != NULL) {
#if PMEMORY_CHECK
        ignoreAllocations = PMemoryHeap::SetIgnoreAllocations(TRUE) ? 1 : 0;
#endif
        OpenTraceFile();
    }
    
    PTraceLevelThreshold = level;
    
    PTRACE(1, process.GetName()
           << "\tVersion " << process.GetVersion(TRUE)
           << " by " << process.GetManufacturer()
           << " on " << process.GetOSClass() << ' ' << process.GetOSName()
           << " (" << process.GetOSVersion() << '-' << process.GetOSHardware()
           << ") at " << PTime().AsString("yyyy/M/d h:mm:ss.uuu"));
    
#if PMEMORY_CHECK
    if (ignoreAllocations >= 0)
        PMemoryHeap::SetIgnoreAllocations(ignoreAllocations != 0);
#endif
}


void PTrace::SetOptions(unsigned options)
{
    PTraceOptions |= options;
}


void PTrace::ClearOptions(unsigned options)
{
    PTraceOptions &= ~options;
}


unsigned PTrace::GetOptions()
{
    return PTraceOptions;
}


void PTrace::SetLevel(unsigned level)
{
    PTraceLevelThreshold = level;
}


unsigned PTrace::GetLevel()
{
    return PTraceLevelThreshold;
}


PBOOL PTrace::CanTrace(unsigned level)
{
    return level <= PTraceLevelThreshold;
}


ostream & PTrace::Begin(unsigned level, const char * fileName, int lineNum)
{
    if (PTraceMutex == NULL) {
        PAssertAlways("Cannot use PTRACE before PProcess constructed.");
        return *PTraceStream;
    }
    
    if (level == UINT_MAX)
        return *PTraceStream;
    
    PTraceMutex->Wait();
    
    // Save log level for this message so End() function can use. This is
    // protected by the PTraceMutex
    PTraceCurrentLevel = level;
    
    if ((PTrace_Filename != NULL) && (PTraceOptions&RotateDaily) != 0) {
        int day = PTime(/*(PTraceOptions&GMTTime) ? PTime::GMT : PTime::Local*/).GetDayOfYear();
        if (day != PTrace_lastDayOfYear) {
            //bug fixed by brant
            PTrace_lastDayOfYear=day;
            
            if(PTraceStream!=&cerr)
                delete PTraceStream;
            PTraceStream = NULL;
            OpenTraceFile();
            /*
             if (PTraceStream == NULL) {
             PTraceMutex->Signal();
             return *PTraceStream;
             }*/
            
        }
    }
    if(PTraceStream==NULL)
		PTraceStream=&cerr;
    
    if ((PTraceOptions&SystemLogStream) == 0) {
        if ((PTraceOptions&DateAndTime) != 0) {
            PTime now;
            *PTraceStream << now.AsString("yyyy/MM/dd hh:mm:ss.uuu\t", (PTraceOptions&GMTTime) ? PTime::GMT : PTime::Local);
        }
        
        if ((PTraceOptions&Timestamp) != 0)
            *PTraceStream << setprecision(3) << setw(10) << (PTimer::Tick()-ApplicationStartTick) << '\t';
        
        if ((PTraceOptions&Thread) != 0) {
            PThread * thread = PThread::Current();
            if (thread == NULL)
                *PTraceStream << "ThreadID=0x"
                << setfill('0') << hex << setw(8)
                << PThread::GetCurrentThreadId()
                << setfill(' ') << dec;
            else {
                PString name = thread->GetThreadName();
                if (name.GetLength() <= 23)
                    *PTraceStream << setw(23) << name;
                else
                    *PTraceStream << name.Left(10) << "..." << name.Right(10);
            }
            *PTraceStream << '\t';
        }
        
        if ((PTraceOptions&ThreadAddress) != 0)
            *PTraceStream << hex << setfill('0')
            << setw(7) << (void *)PThread::Current()
            << dec << setfill(' ') << '\t';
    }
    
    if ((PTraceOptions&TraceLevel) != 0)
        *PTraceStream << level << '\t';
    
    if ((PTraceOptions&FileAndLine) != 0 && fileName != NULL) {
        const char * file = strrchr(fileName, '/');
        if (file != NULL)
            file++;
        else {
            file = strrchr(fileName, '\\');
            if (file != NULL)
                file++;
            else
                file = fileName;
        }
        
        *PTraceStream << setw(16) << file << '(' << lineNum << ")\t";
    }
    
    return *PTraceStream;
}


ostream & PTrace::End(ostream & s)
{
    /* Only output if there is something to output, this prevents some blank trace
     entries from appearing under some patholgical conditions. Unfortunately if
     stderr is used the unitbuf flag causes the out_waiting() not to work so we
     must suffer with blank lines in that case.
     */
#if 0
#ifndef P_LINUX
    ::streambuf & rb = *s.rdbuf();
    if (((s.flags()&ios::unitbuf) != 0) ||
#ifdef __USE_STL__
        rb.pubseekoff(0, ios::cur, ios::out) > 0
#else
        rb.out_waiting() > 0
#endif
        )
#endif
#endif
    {
        if ((PTraceOptions&SystemLogStream) != 0) {
            // Get the trace level for this message and set the stream width to that
            // level so that the PSystemLog can extract the log level back out of the
            // ios structure. There could be portability issues with this though it
            // should work pretty universally.
            s.width(PTraceCurrentLevel+1);
            s.flush();
        }
        else
            s << endl;
    }
    
    PTraceMutex->Signal();
    
    return s;
}


PTrace::Block::Block(const char * fileName, int lineNum, const char * traceName)
{
    file = fileName;
    line = lineNum;
    name = traceName;
    
    if ((PTraceOptions&Blocks) != 0) {
        PThread * thread = PThread::Current();
        thread->traceBlockIndentLevel += 2;
        
        ostream & s = PTrace::Begin(1, file, line);
        s << "B-Entry\t";
        for (unsigned i = 0; i < thread->traceBlockIndentLevel; i++)
            s << '=';
        s << "> " << name << PTrace::End;
    }
}


PTrace::Block::~Block()
{
    if ((PTraceOptions&Blocks) != 0) {
        PThread * thread = PThread::Current();
        
        ostream & s = PTrace::Begin(1, file, line);
        s << "B-Exit\t<";
        for (unsigned i = 0; i < thread->traceBlockIndentLevel; i++)
            s << '=';
        s << ' ' << name << PTrace::End;
        
        thread->traceBlockIndentLevel -= 2;
    }
}




///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// PTimerList

PTimerList::PTimerList()
{
    DisallowDeleteObjects();
    currentTimer = NULL;
}


PTimeInterval PTimerList::Process()
{
    PINDEX i;
    PTimeInterval minTimeLeft = PMaxTimeInterval;
    
    listMutex.Wait();
    
    PTimeInterval now = PTimer::Tick();
    PTimeInterval sampleTime;
    if (lastSample == 0)
        sampleTime = 0;
    else {
        sampleTime = now - lastSample;
        if (now < lastSample)
            sampleTime += PMaxTimeInterval;
    }
    lastSample = now;
    
    for (i = 0; i < GetSize(); i++) {
        currentTimer = (PTimer *)GetAt(i);
        inTimeoutMutex.Wait();
        listMutex.Signal();
        currentTimer->Process(sampleTime, minTimeLeft);
        listMutex.Wait();
        inTimeoutMutex.Signal();
    }
    currentTimer = NULL;
    
    listMutex.Signal();
    
    return minTimeLeft;
}

PINLINE const PString & PProcess::GetManufacturer() const
{ return manufacturer; }

PINLINE const PString & PProcess::GetName() const
{ return productName; }

PINLINE int PProcess::GetMaxHandles() const
{ return maxHandles; }

PINLINE PTimerList * PProcess::GetTimerList()
{ return &timers; }

PINLINE void PProcess::SetTerminationValue(int value)
{ terminationValue = value; }

PINLINE int PProcess::GetTerminationValue() const
{ return terminationValue; }

PString PProcess::GetOSClass()
{
    return PString("Unix");
}

PString PProcess::GetOSName()
{
#if defined(HAS_UNAME)
    struct utsname info;
    uname(&info);
    return PString(info.sysname);
#else
#warning No GetOSName specified
    return PString("Unknown");
#endif
}

PString PProcess::GetOSHardware()
{
#if defined(HAS_UNAME)
    struct utsname info;
    uname(&info);
    return PString(info.machine);
#else
#warning No GetOSHardware specified
    return PString("unknown");
#endif
}

PString PProcess::GetOSVersion()
{
#if defined(HAS_UNAME)
    struct utsname info;
    uname(&info);
    return PString(info.release);
#else
#warning No GetOSVersion specified
    return PString("?.?");
#endif
}

///////////////////////////////////////////////////////////////////////////////
//
// PProcess
//
// Return the effective user name of the process, eg "root" etc.

PString PProcess::GetUserName_() const

{
    return PString("root");
}


PBOOL PProcess::SetUserName(const PString & username, PBOOL permanent)
{
    return TRUE;
}


///////////////////////////////////////////////////////////////////////////////
//
// PProcess
//
// Return the effective group name of the process, eg "wheel" etc.

PString PProcess::GetGroupName() const
{
    return PString("group");
}


PBOOL PProcess::SetGroupName(const PString & groupname, PBOOL permanent)
{
    return TRUE;
}


void PProcess::PXShowSystemWarning(PINDEX num)
{
    PXShowSystemWarning(num, "");
}

void PProcess::PXShowSystemWarning(PINDEX num, const PString & str)
{
    PProcess::Current()._PXShowSystemWarning(num, str);
}

void PProcess::_PXShowSystemWarning(PINDEX code, const PString & str)
{
    PError << "PWLib " << GetOSClass() << " error #" << code << '-' << str << endl;
}

void PXSignalHandler(int sig)
{
#ifdef SIGNALS_DEBUG
    fprintf(stderr,"\nSIGNAL<%u>\n",sig);
#endif
    
    PProcess & process = PProcess::Current();
    process.pxSignals |= 1 << sig;
    process.PXOnAsyncSignal(sig);
#if defined(P_MAC_MPTHREADS)
    process.SignalTimerChange();
#elif defined(P_PTHREADS)
    // Inform house keeping thread we have a signal to be processed
    BYTE ch;
    write(process.timerChangePipe[1], &ch, 1);
#endif
    signal(sig, PXSignalHandler);
}

void PProcess::PXCheckSignals()
{
    if (pxSignals == 0)
        return;
    
#ifdef SIGNALS_DEBUG
    fprintf(stderr,"\nCHKSIG<%x>\n",pxSignals);
#endif
    
    for (int sig = 0; sig < 32; sig++) {
        int bit = 1 << sig;
        if ((pxSignals&bit) != 0) {
            pxSignals &= ~bit;
            PXOnSignal(sig);
        }
    }
}


void SetSignals(void (*handler)(int))
{
#ifdef SIGNALS_DEBUG
    fprintf(stderr,"\nSETSIG<%x>\n",(INT)handler);
#endif
    
    if (handler == NULL)
        handler = SIG_DFL;
    
#ifdef SIGHUP
    signal(SIGHUP, handler);
#endif
#ifdef SIGINT
    signal(SIGINT, handler);
#endif
#ifdef SIGUSR1
    signal(SIGUSR1, handler);
#endif
#ifdef SIGUSR2
    signal(SIGUSR2, handler);
#endif
#ifdef SIGPIPE
    signal(SIGPIPE, handler);
#endif
#ifdef SIGTERM
    signal(SIGTERM, handler);
#endif
#ifdef SIGWINCH
    signal(SIGWINCH, handler);
#endif
#ifdef SIGPROF
    signal(SIGPROF, handler);
#endif
}


void PProcess::PXOnAsyncSignal(int sig)
{
}

void PProcess::PXOnSignal(int sig)
{
#ifdef SIGNALS_DEBUG
    fprintf(stderr,"\nSYNCSIG<%u>\n",sig);
#endif
}

void PProcess::CommonConstruct()
{
    // Setup signal handlers
    pxSignals = 0;
    
    SetSignals(&PXSignalHandler);
    
    // initialise the timezone information
    tzset();
    
#ifdef P_CONFIG_FILE
    CreateConfigFilesDictionary();
#endif
}

void PProcess::CommonDestruct()
{
#ifdef P_CONFIG_FILE
    delete configFiles;
#endif
    configFiles = NULL;
    SetSignals(NULL);
}

static PProcess * PProcessInstance = NULL;
int PProcess::p_argc = 0;
char ** PProcess::p_argv = NULL;
char ** PProcess::p_envp = NULL;

typedef std::map<PString, PProcessStartup *> PProcessStartupList;

int PProcess::_main(void *)
{
    Main();
    return terminationValue;
}

void PProcess::PreInitialise(int c, char ** v, char ** e)
{
#if PMEMORY_CHECK
    PMemoryHeap::SetIgnoreAllocations(FALSE);
#endif
    
    p_argc = c;
    p_argv = v;
    p_envp = e;
}


static PProcessStartupList & GetPProcessStartupList()
{
    static PProcessStartupList list;
    return list;
}


PProcess::PProcess(const char * manuf, const char * name,
                   WORD major, WORD minor, CodeStatus stat, WORD build)
: manufacturer(manuf), productName(name)
{
    if(NULL == p_argv){
        
        PreInitialise(0,NULL,NULL);
    }
    PProcessInstance = this;
    terminationValue = 0;
    
    majorVersion = major;
    minorVersion = minor;
    status = stat;
    buildNumber = build;
    
    // This flag must never be destroyed before it is finished with. As we
    // cannot assure destruction at the right time we simply allocate it and
    // NEVER destroy it! This is OK as the only reason for its destruction is
    // the program is exiting and then who cares?
#if PMEMORY_CHECK
    PBOOL ignoreAllocations = PMemoryHeap::SetIgnoreAllocations(TRUE);
#endif
    PTraceMutex = new PMutex;
#if PMEMORY_CHECK
    PMemoryHeap::SetIgnoreAllocations(ignoreAllocations);
#endif
        
    InitialiseProcessThread();
    
    Construct();
    
#ifdef __MACOSX__
    
#ifdef HAS_VIDEO
    PWLibStupidOSXHacks::loadFakeVideoStuff = 1;
#ifdef USE_SHM_VIDEO_DEVICES
    PWLibStupidOSXHacks::loadShmVideoStuff = 1;
#endif // USE_SHM_VIDEO_DEVICES
#endif // HAS_VIDEO
    
#ifdef HAS_AUDIO
    PWLibStupidOSXHacks::loadCoreAudioStuff = 1;
#endif // HAS_AUDIO
    
#endif // __MACOSX__
    
    // create one instance of each class registered in the
    // PProcessStartup abstract factory
    PProcessStartupList & startups = GetPProcessStartupList();
    {
        PProcessStartup * levelSet = PFactory<PProcessStartup>::CreateInstance("SetTraceLevel");
        if (levelSet != NULL)
            levelSet->OnStartup();
        else {
            char * env =
            ::getenv("PWLIB_TRACE_STARTUP");

            if (env != NULL)
                PTrace::Initialise(
                                   atoi(env)
                                   , NULL, PTrace::Blocks | PTrace::Timestamp | PTrace::Thread | PTrace::FileAndLine);
        }
        
        PProcessStartupFactory::KeyList_T list = PProcessStartupFactory::GetKeyList();
        PProcessStartupFactory::KeyList_T::const_iterator r;
        for (r = list.begin(); r != list.end(); ++r) {
            if (*r != "SetTraceLevel") {
                PProcessStartup * instance = PProcessStartupFactory::CreateInstance(*r);
                instance->OnStartup();
                startups.insert(std::pair<PString, PProcessStartup *>(*r, instance));
            }
        }
    }
}


void PProcess::PreShutdown()
{
    PProcessStartupList & startups = GetPProcessStartupList();
    
    // call OnShutfdown for the PProcessInstances previously created
    // make sure we handle singletons correctly
    {
        while (startups.size() > 0) {
            PProcessStartupList::iterator r = startups.begin();
            PProcessStartup * instance = r->second;
            instance->OnShutdown();
            if (!PProcessStartupFactory::IsSingleton(r->first))
                delete instance;
            startups.erase(r);
        }
    }
    delete tpk;
    tpk = NULL;
    
}

static PMutex s_pmutex;
PProcess & PProcess::Current()
{
    PWaitAndSignal lock(s_pmutex);
    if (PProcessInstance == NULL) {
        PreInitialise(0,NULL,NULL);
        static class P: public PProcess
        {
        public:
            void Main(){}
        } init;
    }
    return *PProcessInstance;
}


PBOOL PProcess::IsInitialised()
{
    return PProcessInstance != NULL;
}


PObject::Comparison PProcess::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, PProcess), PInvalidCast);
    return productName.Compare(((const PProcess &)obj).productName);
}


void PProcess::Terminate()
{
#ifdef _WINDLL
    FatalExit(terminationValue);
#else
    exit(terminationValue);
#endif
}


PString PProcess::GetThreadName() const
{
    return GetName();
}


void PProcess::SetThreadName(const PString & /*name*/)
{
}

PTime PProcess::GetStartTime() const
{
    return programStartTime;
}

PString PProcess::GetVersion(PBOOL full) const
{
    const char * const statusLetter[NumCodeStatuses] =
    { "alpha", "beta", "." };
    return psprintf(full ? "%u.%u%s%u" : "%u.%u",
                    majorVersion, minorVersion, statusLetter[status], buildNumber);
}


void PProcess::SetConfigurationPath(const PString & path)
{
    configurationPaths = path.Tokenise(";:", FALSE);
}

void PProcess::SignalTimerChange()
{
    if (housekeepingThread == NULL) {
#if PMEMORY_CHECK
        PBOOL oldIgnoreAllocations = PMemoryHeap::SetIgnoreAllocations(TRUE);
#endif
        housekeepingThread = new PHouseKeepingThread;
#if PMEMORY_CHECK
        PMemoryHeap::SetIgnoreAllocations(oldIgnoreAllocations);
#endif
    }
    
    static BYTE ch = 0;
    write(timerChangePipe[1], &ch, 1);
}


void PProcess::Construct()
{
    // get the file descriptor limit
    struct rlimit rl;
    PAssertOS(getrlimit(RLIMIT_NOFILE, &rl) == 0);
    maxHandles = rl.rlim_cur;
    PTRACE(4, "PWLib\tMaximum per-process file handles is " << maxHandles);
    
    ::pipe(timerChangePipe);
    
    // initialise the housekeeping thread
    housekeepingThread = NULL;
    
#ifdef P_MACOSX
    // records the main thread for priority adjusting
    baseThread = pthread_self();
#endif
    
    CommonConstruct();
}

PBOOL PProcess::SetMaxHandles(int newMax)
{
    // get the current process limit
    struct rlimit rl;
    PAssertOS(getrlimit(RLIMIT_NOFILE, &rl) == 0);
    
    // set the new current limit
    rl.rlim_cur = newMax;
    //added by brant
    //linux 2.6 kernel need this
    rl.rlim_max = newMax;
    //
    if (setrlimit(RLIMIT_NOFILE, &rl) == 0) {
        PAssertOS(getrlimit(RLIMIT_NOFILE, &rl) == 0);
        maxHandles = rl.rlim_cur;
        if (maxHandles == newMax) {
            PTRACE(2, "PWLib\tNew maximum per-process file handles set to " << maxHandles);
            return TRUE;
        }
    }
    
    PTRACE(1, "PWLib\tCannot set per-process file handle limit to "
           << newMax << " (is " << maxHandles << ") - check permissions");
    return FALSE;
}


PProcess::~PProcess()
{
    PreShutdown();
    
    // Don't wait for housekeeper to stop if Terminate() is called from it.
    if (housekeepingThread != NULL && PThread::Current() != housekeepingThread) {
        housekeepingThread->SetClosing();
        SignalTimerChange();
        housekeepingThread->WaitForTermination();
        delete housekeepingThread;
    }
    CommonDestruct();
    
    PTRACE(5, "PWLib\tDestroyed process " << this);
}

PBOOL PProcess::PThreadKill(pthread_t id, unsigned sig)
{
    PWaitAndSignal m(threadMutex);
    
    if (!activeThreads.Contains((PINDEX)id))
        return FALSE;
    
    return pthread_kill(id, sig) == 0;
}
