//
//  ptlibthrd.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "ptthread.h"

#include <sched.h>  // for sched_yield
#include <pthread.h>
#include <sys/resource.h>

#include "psocket.h"
#include "pprocess.h"
#include "psync.h"

#define SUSPEND_SIG SIGVTALRM

int PX_NewHandle(const char *, int);

PBOOL PAssertThreadOp(int retval,
                            unsigned & retry,
                            const char * funcname,
                            const char * file,
                            unsigned line)
{
    if (retval == 0) {
        PTRACE_IF(2, retry > 0, "PWLib\t" << funcname << " required " << retry << " retries!");
        return FALSE;
    }
    
    if (errno == EINTR || errno == EAGAIN) {
        if (++retry < 1000) {
            usleep(10000); // Basically just swap out thread to try and clear blockage
            return TRUE;   // Return value to try again
        }
        // Give up and assert
    }
    
    PAssertFunc(file, line, NULL, psprintf("Function %s failed", funcname));
    return FALSE;
}


static pthread_mutex_t MutexInitialiser = PTHREAD_MUTEX_INITIALIZER;


#define new PNEW


void PHouseKeepingThread::Main()
{
    PProcess & process = PProcess::Current();
    
    //modified by brant
    P_fd_set read_fds;
    while (!closing) {
        PTimeInterval delay = process.timers.Process();
        
        int fd = process.timerChangePipe[0];
        
        read_fds = fd;
        P_timeval tval = delay;
        int retval=::select(fd+1, read_fds, NULL, NULL, tval);
        if(retval == 1) {
            BYTE ch;
            ::read(fd, &ch, 1);
        }
        //else if(retval<0) {
		PThread::Yield();
        //}
        
        process.PXCheckSignals();
    }
}


TPWorker::TPWorker()
:PThread(5000,AutoDeleteThread),
_job(NULL)
{
	_id = ++(tpk->id);
	{
		PWaitAndSignal lock(tpk->mapMutex);
		tpk->allMap[_id] = this;
		tpk->totalCount ++;
        
		PTRACE(5, "INFO\t"<<GetClass()<<" ID #"<<GetThreadId()<<" Create,"
               <<tpk->idleCount<<" idle,"
               <<tpk->totalCount<<" total");
	}
	Resume();
}

TPWorker::~TPWorker()
{
	delete _job;
	_job = NULL;
	{
		PWaitAndSignal lock(tpk->mapMutex);
		tpk->allMap.erase(_id);
		tpk->totalCount --;
		
		PTRACE(5, "INFO\t"<<GetClass()<<" ID #"<<GetThreadId()<<" Destroy,"
               <<tpk->idleCount<<" idle,"
               <<tpk->totalCount<<" total");
	}
}

void TPWorker::Execute(JobBase * job)
{
	_job = job;
	_jobSync.Signal();
    
}


void TPWorker::Main()
{
	PTRACE(5, "INFO\t"<<GetClass()<<" ID #"<<GetThreadId()<<" Started,"
           <<tpk->idleCount<<" idle,"
           <<tpk->totalCount<<" total");
	do{
		PBOOL timeout = !_jobSync.Wait(PThreadPool::GetThreadTimeout());
		if(_job){
			
			PString jobName = _job->GetName();
			PTRACE(5, "INFO\t"<<GetClass()<<" ID #"<<GetThreadId()<<" Run job "<< jobName
                   <<","<<tpk->idleCount<<" idle,"
                   <<tpk->totalCount<<" total");
			{
				PThreadPool::PrioritySet ps(_job->GetPriority());
				_job->Run();
			}
			
			delete _job;
			_job = NULL;
			
			
			SetIdle(TRUE);
			PTRACE(5, "INFO\t"<<GetClass()<<" ID #"<<GetThreadId()<<" Done job "<<jobName
                   <<","<<tpk->idleCount<<" idle,"
                   <<tpk->totalCount<<" total");
			
			
		} else {
			if(timeout){
				
				PTRACE(5, "INFO\t"<<GetClass()<<" ID #"<<GetThreadId()<<" Timeout");
				
				PWaitAndSignal lock(tpk->mapMutex);
				
				if(NULL == _job){
					SetIdle(FALSE);
					break;
				}
				
			}
		}
		
	}while(!tpk->shutdown);
    
	SetIdle(FALSE);
	
	PTRACE(5, "INFO\t"<<GetClass()<<" ID #"<<GetThreadId()<<" Ended,"
           <<tpk->idleCount<<" idle,"
           <<tpk->totalCount<<" total");
    
}

void TPWorker::SetIdle(PBOOL idle)
{
	PWaitAndSignal lock(tpk->mapMutex);
	if(idle){
		tpk->idleMap[_id] = this;
		tpk->idleCount++;
	}else{
		if(tpk->idleMap.find(_id) != tpk->idleMap.end()){
			tpk->idleMap.erase(_id);
			tpk->idleCount--;
		}
	}
}

//////////////////
PThreadPool::PrioritySet::PrioritySet(PThread::Priority prio)
{
	_prio = PThread::Current()->GetPriority();
	PThread::Current()->SetPriority(prio);
}

PThreadPool::PrioritySet::~PrioritySet()
{
	PThread::Current()->SetPriority(_prio);
}
///////////////////////////////////
/** default 10 min timeout
 */
static DWORD _threadTimeout = 1000*10*60;

////////////////////////
PPooledThread::PPooledThread()
:joined(TRUE),
running(FALSE)
{
    
}

PPooledThread::~PPooledThread()
{
	Join();
}

void PPooledThread::Start(PThread::Priority prio)
{
	Join();
	sync.Wait(0);
	joined = FALSE;
	running = TRUE;
    
	PThreadPool::Run(this,&PPooledThread::Run,GetClass(),prio);
}

void PPooledThread::Join()
{
	if(!joined){
		sync.Wait();
		joined = TRUE;
		sync.Signal();
	}
}

void PPooledThread::Run()
{
	Main();
	running = FALSE;
	sync.Signal();
}

PBOOL PPooledThread::IsRunning() const
{
	return running;
}

////////////
DWORD PThreadPool::GetThreadTimeout()
{
	return _threadTimeout;
}

void PThreadPool::SetThreadTimeout(DWORD timeout)
{
	_threadTimeout=timeout;
}

void PThreadPool::Execute(JobBase * job)
{
	PWaitAndSignal glock(tpk->mutex);
	
	if(tpk->shutdown){
		PTRACE(1,"WARN\tPThreadPool Execute job "<<job->GetName()<<" while threadPool alread shutdown!!");
		return;
	}
	TPWorker * worker = NULL;
	PWaitAndSignal lock(tpk->mapMutex);
	if(!tpk->idleMap.empty()){
		TPWorkerMap::iterator it = tpk->idleMap.begin();
		worker = it->second;
		worker->SetIdle(FALSE);
	}else
		worker = new TPWorker;
	
	worker->Execute(job);
	
}

//////////////////////////////////////////////////////////////////////////////

PINLINE PThreadIdentifier PThread::GetThreadId() const
{ return PX_threadId; }

PINLINE PThreadIdentifier PThread::GetCurrentThreadId()
{ return ::pthread_self(); }

///////////////////////////////////////////////////////////////////////////////

PThread::PThread()
{
    // see InitialiseProcessThread()
}


void PThread::InitialiseProcessThread()
{
    autoDelete          = FALSE;
    
    PX_origStackSize    = 0;
    PX_threadId         = pthread_self();
    PX_priority         = NormalPriority;
    PX_suspendCount     = 0;
    
#ifndef P_HAS_SEMAPHORES
    PX_waitingSemaphore = NULL;
    PX_WaitSemMutex = MutexInitialiser;
#endif
    
    PX_suspendMutex = MutexInitialiser;
    
    PAssertOS(::pipe(unblockPipe) == 0);
    
    ((PProcess *)this)->activeThreads.DisallowDeleteObjects();
    ((PProcess *)this)->activeThreads.SetAt((PINDEX)PX_threadId, this);
    
    PX_firstTimeStart = FALSE;
    
    traceBlockIndentLevel = 0;
}


PThread::PThread(PINDEX stackSize,
                 AutoDeleteFlag deletion,
                 Priority priorityLevel,
                 const PString & name)
: threadName(name)
{
    autoDelete = (deletion == AutoDeleteThread);
    
    PAssert(stackSize > 0, PInvalidParameter);
    PX_origStackSize = stackSize;
    PX_threadId = 0;
    PX_priority = priorityLevel;
    PX_suspendCount = 1;
    
#ifndef P_HAS_SEMAPHORES
    PX_waitingSemaphore = NULL;
    PX_WaitSemMutex = MutexInitialiser;
#endif
    
    PX_suspendMutex = MutexInitialiser;
    
    PAssertOS(::pipe(unblockPipe) == 0);

    PX_NewHandle("Thread unblock pipe", PMAX(unblockPipe[0], unblockPipe[1]));
    
    // new thread is actually started the first time Resume() is called.
    PX_firstTimeStart = TRUE;
    
    traceBlockIndentLevel = 0;
    
    PTRACE(5, "PWLib\tCreated thread " << this << ' ' << threadName);
}


PThread::~PThread()
{
	if(&PProcess::Current() == this)
		return;
    WaitForTermination();
    //   if (PX_threadId != 0 && PX_threadId != pthread_self())
    //     Terminate();
    
    PAssertPTHREAD(::close, (unblockPipe[0]));
    PAssertPTHREAD(::close, (unblockPipe[1]));
    
#ifndef P_HAS_SEMAPHORES
    pthread_mutex_destroy(&PX_WaitSemMutex);
#endif
    
    // If the mutex was not locked, the unlock will fail */
    pthread_mutex_trylock(&PX_suspendMutex);
    pthread_mutex_unlock(&PX_suspendMutex);
    pthread_mutex_destroy(&PX_suspendMutex);
    
    // if (this != &PProcess::Current())
    PTRACE(5, "PWLib\tDestroyed thread " << this << ' ' << threadName);
}


void PThread::Restart()
{
    if (!IsTerminated())
        return;
    
    pthread_attr_t threadAttr;
    pthread_attr_init(&threadAttr);
    pthread_attr_setdetachstate(&threadAttr, PTHREAD_CREATE_DETACHED);
    
#if defined(P_LINUX)
    
    // Set a decent (256K) stack size that won't eat all virtual memory
    pthread_attr_setstacksize(&threadAttr, 16*PTHREAD_STACK_MIN);
    
    /*
     Set realtime scheduling if our effective user id is root (only then is this
     allowed) AND our priority is Highest.
     As far as I can see, we could use either SCHED_FIFO or SCHED_RR here, it
     doesn't matter.
     I don't know if other UNIX OSs have SCHED_FIFO and SCHED_RR as well.
     
     WARNING: a misbehaving thread (one that never blocks) started with Highest
     priority can hang the entire machine. That is why root permission is
     neccessary.
     */
    if ((geteuid() == 0) && (PX_priority == HighestPriority))
        PAssertPTHREAD(pthread_attr_setschedpolicy, (&threadAttr, SCHED_FIFO));
#endif
    
    PProcess & process = PProcess::Current();
    PINDEX newHighWaterMark = 0;
    static PINDEX highWaterMark = 0;
    
    // lock the thread list
    process.threadMutex.Wait();
    
    // create the thread
    PAssertPTHREAD(pthread_create, (&PX_threadId, &threadAttr, PX_ThreadStart, this));
    
    // put the thread into the thread list
    process.activeThreads.SetAt((PINDEX)PX_threadId, this);
    if (process.activeThreads.GetSize() > highWaterMark)
        newHighWaterMark = highWaterMark = process.activeThreads.GetSize();
    
    // unlock the thread list
    process.threadMutex.Signal();
    
    PTRACE_IF(4, newHighWaterMark > 0, "PWLib\tThread high water mark set: " << newHighWaterMark);
    
#ifdef P_MACOSX
    if (PX_priority == HighestPriority) {
        PTRACE(1, "set thread to have the highest priority (MACOSX)");
        SetPriority(HighestPriority);
    }
#endif
}


void PX_SuspendSignalHandler(int)
{
    PThread * thread = PThread::Current();
    if (thread == NULL)
        return;
    
    //PBOOL notResumed = TRUE;
    
    //modified by brant
    //while (notResumed)
    for(;;){
        BYTE ch;
        int retval= ::read(thread->unblockPipe[0], &ch, 1);
        if(retval< 0 && errno == EINTR)
            PThread::Yield();
        else
            break;
#if defined(P_NO_CANCEL)
        pthread_testcancel();
#endif
    }
}


void PThread::Suspend(PBOOL susp)
{
    PAssertPTHREAD(pthread_mutex_lock, (&PX_suspendMutex));
    
    // Check for start up condition, first time Resume() is called
    if (PX_firstTimeStart) {
        if (susp)
            PX_suspendCount++;
        else {
            if (PX_suspendCount > 0)
                PX_suspendCount--;
            if (PX_suspendCount == 0) {
                PX_firstTimeStart = FALSE;
                Restart();
            }
        }
        
        PAssertPTHREAD(pthread_mutex_unlock, (&PX_suspendMutex));
        return;
    }
    
#if defined(P_MACOSX) && (P_MACOSX <= 55)
    // Suspend - warn the user with an Assertion
    PAssertAlways("Cannot suspend threads on Mac OS X due to lack of pthread_kill()");
#else
    if (PPThreadKill(PX_threadId, 0)) {
        
        // if suspending, then see if already suspended
        if (susp) {
            PX_suspendCount++;
            if (PX_suspendCount == 1) {
                if (PX_threadId != pthread_self()) {
                    signal(SUSPEND_SIG, PX_SuspendSignalHandler);
                    PPThreadKill(PX_threadId, SUSPEND_SIG);
                }
                else {
                    PAssertPTHREAD(pthread_mutex_unlock, (&PX_suspendMutex));
                    PX_SuspendSignalHandler(SUSPEND_SIG);
                    return;  // Mutex already unlocked
                }
            }
        }
        
        // if resuming, then see if to really resume
        else if (PX_suspendCount > 0) {
            PX_suspendCount--;
            if (PX_suspendCount == 0)
                PXAbortBlock();
        }
    }
    
    PAssertPTHREAD(pthread_mutex_unlock, (&PX_suspendMutex));
#endif // P_MACOSX
}


void PThread::Resume()
{
    Suspend(FALSE);
}


PBOOL PThread::IsSuspended() const
{
    if (PX_firstTimeStart)
        return TRUE;
    
    if (IsTerminated())
        return FALSE;
    
    PAssertPTHREAD(pthread_mutex_lock, ((pthread_mutex_t *)&PX_suspendMutex));
    PBOOL suspended = PX_suspendCount != 0;
    PAssertPTHREAD(pthread_mutex_unlock, ((pthread_mutex_t *)&PX_suspendMutex));
    return suspended;
}


void PThread::SetAutoDelete(AutoDeleteFlag deletion)
{
    PAssert(deletion != AutoDeleteThread || this != &PProcess::Current(), PLogicError);
    autoDelete = deletion == AutoDeleteThread;
}

#ifdef P_MACOSX
// obtain thread priority of the main thread
static unsigned long
GetThreadBasePriority ()
{
    thread_basic_info_data_t threadInfo;
    policy_info_data_t       thePolicyInfo;
    unsigned int             count;
    
    if (baseThread == 0) {
        return 0;
    }
    
    // get basic info
    count = THREAD_BASIC_INFO_COUNT;
    thread_info (pthread_mach_thread_np (baseThread), THREAD_BASIC_INFO,
                 (integer_t*)&threadInfo, &count);
    
    switch (threadInfo.policy) {
        case POLICY_TIMESHARE:
            count = POLICY_TIMESHARE_INFO_COUNT;
            thread_info(pthread_mach_thread_np (baseThread),
                        THREAD_SCHED_TIMESHARE_INFO,
                        (integer_t*)&(thePolicyInfo.ts), &count);
            return thePolicyInfo.ts.base_priority;
            
        case POLICY_FIFO:
            count = POLICY_FIFO_INFO_COUNT;
            thread_info(pthread_mach_thread_np (baseThread),
                        THREAD_SCHED_FIFO_INFO,
                        (integer_t*)&(thePolicyInfo.fifo), &count);
            if (thePolicyInfo.fifo.depressed)
                return thePolicyInfo.fifo.depress_priority;
            return thePolicyInfo.fifo.base_priority;
            
        case POLICY_RR:
            count = POLICY_RR_INFO_COUNT;
            thread_info(pthread_mach_thread_np (baseThread),
                        THREAD_SCHED_RR_INFO,
                        (integer_t*)&(thePolicyInfo.rr), &count);
            if (thePolicyInfo.rr.depressed)
                return thePolicyInfo.rr.depress_priority;
            return thePolicyInfo.rr.base_priority;
    }
    
    return 0;
}
#endif

void PThread::SetPriority(Priority priorityLevel)
{
    PX_priority = priorityLevel;
    
#if defined(P_LINUX)
    if (IsTerminated())
        return;
    
    struct sched_param sched_param;
    
    if ((priorityLevel == HighestPriority) && (geteuid() == 0) ) {
        sched_param.sched_priority = sched_get_priority_min( SCHED_FIFO );
        
        PAssertPTHREAD(pthread_setschedparam, (PX_threadId, SCHED_FIFO, &sched_param));
    }
    else if (priorityLevel != HighestPriority) {
        /* priority 0 is the only permitted value for the SCHED_OTHER scheduler */
        sched_param.sched_priority = 0;
        
        PAssertPTHREAD(pthread_setschedparam, (PX_threadId, SCHED_OTHER, &sched_param));
    }
#endif
    
#if defined(P_MACOSX)
    if (IsTerminated())
        return;
    
    if (priorityLevel == HighestPriority) {
        /* get fixed priority */
        {
            int result;
            
            thread_extended_policy_data_t   theFixedPolicy;
            thread_precedence_policy_data_t thePrecedencePolicy;
            long                            relativePriority;
            
            theFixedPolicy.timeshare = false; // set to true for a non-fixed thread
            result = thread_policy_set (pthread_mach_thread_np(PX_threadId),
                                        THREAD_EXTENDED_POLICY,
                                        (thread_policy_t)&theFixedPolicy,
                                        THREAD_EXTENDED_POLICY_COUNT);
            if (result != KERN_SUCCESS) {
                PTRACE(1, "thread_policy - Couldn't set thread as fixed priority.");
            }
            
            // set priority
            
            // precedency policy's "importance" value is relative to
            // spawning thread's priority
            
            relativePriority = 62 - GetThreadBasePriority();
            PTRACE(1,  "relativePriority is " << relativePriority << " base priority is " << GetThreadBasePriority());
            
            thePrecedencePolicy.importance = relativePriority;
            result = thread_policy_set (pthread_mach_thread_np(PX_threadId),
                                        THREAD_PRECEDENCE_POLICY,
                                        (thread_policy_t)&thePrecedencePolicy,
                                        THREAD_PRECEDENCE_POLICY_COUNT);
            if (result != KERN_SUCCESS) {
                PTRACE(1, "thread_policy - Couldn't set thread priority.");
            }
        }
    }
#endif
}


PThread::Priority PThread::GetPriority() const
{
#if defined(LINUX)
    int schedulingPolicy;
    struct sched_param schedParams;
    
    PAssertPTHREAD(pthread_getschedparam, (PX_threadId, &schedulingPolicy, &schedParams));
    
    switch( schedulingPolicy )
    {
        case SCHED_OTHER:
            break;
            
        case SCHED_FIFO:
        case SCHED_RR:
            return HighestPriority;
            
        default:
            /* Unknown scheduler. We don't know what priority this thread has. */
            PTRACE(1, "PWLib\tPThread::GetPriority: unknown scheduling policy #" << schedulingPolicy);
    }
#endif
    
    return NormalPriority; /* as good a guess as any */
}


#ifndef P_HAS_SEMAPHORES
void PThread::PXSetWaitingSemaphore(PSemaphore * sem)
{
    PAssertPTHREAD(pthread_mutex_lock, (&PX_WaitSemMutex));
    PX_waitingSemaphore = sem;
    PAssertPTHREAD(pthread_mutex_unlock, (&PX_WaitSemMutex));
}
#endif


#ifdef P_GNU_PTH
// GNU PTH threads version (used by NetBSD)
// Taken from NetBSD pkg patches
void PThread::Sleep(const PTimeInterval & timeout)
{
	sched_yield();
    
	P_timeval tval= timeout;
	select(0, NULL, NULL, NULL, tval);
	//pthread_testcancel();
    /*
     sched_yield();
     
     PTimeInterval lastTime = PTimer::Tick();
     PTimeInterval targetTime = lastTime + timeout;
     
     //  lastTime = PTime();
     
     //modified by brant
     while (lastTime < targetTime) {
     P_timeval tval = targetTime - lastTime;
     int retval= select(0, NULL, NULL, NULL, tval);
     if(retval< 0)
     {
     if(errno == EINTR)
     sched_yield();
     else
     break;
     }
     
     pthread_testcancel();
     
     lastTime = PTimer::Tick();
     }*/
}

#else
// Normal Posix threads version
void PThread::Sleep(const PTimeInterval & timeout)
{
	//changed by brant
	sched_yield();
	P_timeval tval= timeout;
	select(0, NULL, NULL, NULL, tval);
    
#if !( defined(P_NETBSD) && defined(P_NO_CANCEL) )
	//pthread_testcancel();
#endif
    /*
     PTimeInterval lastTime=PTimer::Tick();
     PTimeInterval targetTime = lastTime + timeout;
     do {
     P_timeval tval = targetTime - lastTime;
     int retval= select(0, NULL, NULL, NULL, tval);
     if(retval< 0)
     {
     if(errno == EINTR)
     sched_yield();
     else
     break;
     }
     
     #if !( defined(P_NETBSD) && defined(P_NO_CANCEL) )
     pthread_testcancel();
     #endif
     
     lastTime = PTimer::Tick();
     } while (lastTime < targetTime);*/
    
}
#endif

void PThread::Yield()
{
#ifdef P_LINUX
	PThread::Sleep(5);
#else
    sched_yield();
#endif
}


PThread * PThread::Current()
{
    PProcess & process = PProcess::Current();
    process.threadMutex.Wait();
    PThread * thread = process.activeThreads.GetAt((PINDEX)pthread_self());
    process.threadMutex.Signal();
    return thread;
}


void PThread::Terminate()
{
    if (PX_origStackSize <= 0)
        return;
    
    // don't use PThread::Current, as the thread may already not be in the
    // active threads list
    if (PX_threadId == pthread_self()) {
        pthread_exit(0);
        return;
    }
    
    if (IsTerminated())
        return;
    
    PTRACE(2, "PWLib\tForcing termination of thread " << (void *)this);
    
    PXAbortBlock();
    WaitForTermination(20);
    
#if !defined(P_HAS_SEMAPHORES) && !defined(P_HAS_NAMED_SEMAPHORES)
    PAssertPTHREAD(pthread_mutex_lock, (&PX_WaitSemMutex));
    if (PX_waitingSemaphore != NULL) {
        PAssertPTHREAD(pthread_mutex_lock, (&PX_waitingSemaphore->mutex));
        PX_waitingSemaphore->queuedLocks--;
        PAssertPTHREAD(pthread_mutex_unlock, (&PX_waitingSemaphore->mutex));
        PX_waitingSemaphore = NULL;
    }
    PAssertPTHREAD(pthread_mutex_unlock, (&PX_WaitSemMutex));
#endif
    
#ifndef VOIPBASE_ANDROID
    if (PX_threadId) {
        pthread_cancel(PX_threadId);
    }
#endif
}


PBOOL PThread::IsTerminated() const
{
    pthread_t id = PX_threadId;
    return (id == 0) || !PPThreadKill(id, 0);
}


void PThread::WaitForTermination() const
{
    if (this == Current()) {
        PTRACE(2, "WaitForTermination short circuited");
        return;
    }
    
    PXAbortBlock();   // this assist in clean shutdowns on some systems
    
    while (!IsTerminated()) {
        Sleep(10); // sleep for 10ms. This slows down the busy loop removing 100%
        // CPU usage and also yeilds so other threads can run.
    }
}


PBOOL PThread::WaitForTermination(const PTimeInterval & maxWait) const
{
    if (this == Current()) {
        PTRACE(2, "WaitForTermination(t) short circuited");
        return TRUE;
    }
    
    PTRACE(6, "PWLib\tWaitForTermination(" << maxWait << ')');
    
    PXAbortBlock();   // this assist in clean shutdowns on some systems
    PTimer timeout = maxWait;
    while (!IsTerminated()) {
        if (timeout == 0)
            return FALSE;
        Sleep(10); // sleep for 10ms. This slows down the busy loop removing 100%
        // CPU usage and also yeilds so other threads can run.
    }
    return TRUE;
}


void * PThread::PX_ThreadStart(void * arg)
{
    PThread * thread = (PThread *)arg;
    //don't need to detach the the thread, it was created in the PTHREAD_CREATE_DETACHED state
    // Added this to guarantee that the thread creation (PThread::Restart)
    // has completed before we start the thread. Then the PX_threadId has
    // been set.
    pthread_mutex_lock(&thread->PX_suspendMutex);
    thread->SetThreadName(thread->GetThreadName());
    pthread_mutex_unlock(&thread->PX_suspendMutex);
    
    // make sure the cleanup routine is called when the thread exits
    pthread_cleanup_push(PThread::PX_ThreadEnd, arg);
    
    PTRACE(5, "PWLib\tStarted thread " << thread << ' ' << thread->threadName);
    
    
    //bug(?) for linux 2.4.x kernel
    //fixed by brant 2006-7-31
    //PProcess::Current().SetMaxHandles(PProcess::Current().GetMaxHandles());
    // now call the the thread main routine
    thread->Main();
    
    // execute the cleanup routine
    pthread_cleanup_pop(1);
    
    return NULL;
}


void PThread::PX_ThreadEnd(void * arg)
{
    PProcess & process = PProcess::Current();
    process.threadMutex.Wait();
    
    PThread * thread = (PThread *)arg;
    pthread_t id = thread->GetThreadId();
    if (id == 0) {
        // Don't know why, but pthreads under Linux at least can call this function
        // multiple times! Probably a bug, but we have to allow for it.
        process.threadMutex.Signal();
        PTRACE(2, "PWLib\tAttempted to multiply end thread " << thread << " ThreadID=" << (void *)id);
        return;
    }
    
    // remove this thread from the active thread list
    process.activeThreads.SetAt((PINDEX)id, NULL);
    
    // delete the thread if required, note this is done this way to avoid
    // a race condition, the thread ID cannot be zeroed before the if!
    if (thread->autoDelete) {
        thread->PX_threadId = 0;  // Prevent terminating terminated thread
        process.threadMutex.Signal();
        PTRACE(5, "PWLib\tEnded thread " << thread << ' ' << thread->threadName);
        
        /* It is now safe to delete this thread. Note that this thread
         is deleted after the process.threadMutex.Signal(), which means
         PWaitAndSignal(process.threadMutex) could not be used */
        delete thread;
    }
    else {
        thread->PX_threadId = 0;
        process.threadMutex.Signal();
        PTRACE(5, "PWLib\tEnded thread " << thread << ' ' << thread->threadName);
    }
}

int PThread::PXBlockOnIO(int handle, int type, const PTimeInterval & timeout)
{
    PTRACE(7, "PWLib\tPThread::PXBlockOnIO(" << handle << ',' << type << ')');
    
    if ((handle < 0) || (handle >= PProcess::Current().GetMaxHandles())) {
        PTRACE(2, "PWLib\tAttempt to use illegal handle in PThread::PXBlockOnIO, handle=" << handle);
        errno = EBADF;
        return -1;
    }
    
    // make sure we flush the buffer before doing a write
    P_fd_set read_fds;
    P_fd_set write_fds;
    P_fd_set exception_fds;
    
    int retval;
    //modified by brant
    for(;;) {
        switch (type) {
            case PChannel::PXReadBlock:
            case PChannel::PXAcceptBlock:
                read_fds = handle;
                write_fds.Zero();
                exception_fds.Zero();
                break;
            case PChannel::PXWriteBlock:
                read_fds.Zero();
                write_fds = handle;
                exception_fds.Zero();
                break;
            case PChannel::PXConnectBlock:
                read_fds.Zero();
                write_fds = handle;
                exception_fds = handle;
                break;
            default:
                PAssertAlways(PLogicError);
                return 0;
        }
        
        // include the termination pipe into all blocking I/O functions
        read_fds += unblockPipe[0];
        
        P_timeval tval = timeout;
        retval = ::select(PMAX(handle, unblockPipe[0])+1,
                          read_fds, write_fds, exception_fds, tval);
        
        if(retval < 0 && errno == EINTR)
            PThread::Yield();
        else
            break;
    }
    
    if ((retval == 1) && read_fds.IsPresent(unblockPipe[0])) {
        BYTE ch;
        ::read(unblockPipe[0], &ch, 1);
        errno = EINTR;
        retval =  -1;
        PTRACE(6, "PWLib\tUnblocked I/O fd=" << unblockPipe[0]);
    }
    
    return retval;
}

void PThread::PXAbortBlock() const
{
    static BYTE ch = 0;
    ::write(unblockPipe[1], &ch, 1);
    PTRACE(6, "PWLib\tUnblocking I/O fd=" << unblockPipe[0] << " thread=" << GetThreadName());
}



void PThread::PrintOn(ostream & strm) const
{
    strm << GetThreadName();
}


PString PThread::GetThreadName() const
{
    return threadName;
}

void PThread::SetThreadName(const PString & name)
{
    if (name.IsEmpty())
        threadName = psprintf("%s:%08x", GetClass(), (INT)this);
    else
        threadName = psprintf(name, (INT)this);
    
#if defined(_DEBUG) && defined(_MSC_VER)
    if (threadId) {       // make thread name known to debugger
        THREADNAME_INFO Info = { 0x1000, (const char *) threadName, threadId, 0 } ;
        SetWinDebugThreadName (&Info) ;
    }
#endif // defined(_DEBUG) && defined(_MSC_VER)
}

PThread * PThread::Create(const PNotifier & notifier,
                          INT parameter,
                          AutoDeleteFlag deletion,
                          Priority priorityLevel,
                          const PString & threadName,
                          PINDEX stackSize)
{
    PThread * thread = new PSimpleThread(notifier,
                                         parameter,
                                         deletion,
                                         priorityLevel,
                                         threadName,
                                         stackSize);
    if (deletion != AutoDeleteThread)
        return thread;
    
    // Do not return a pointer to the thread if it is auto-delete as this
    // pointer is extremely dangerous to use, it could be deleted at any moment
    // from now on so using the pointer could crash the program.
    return NULL;
}

///////////////////////////////////////////////////////////////////////////////

PSimpleThread::PSimpleThread(const PNotifier & notifier,
                             INT param,
                             AutoDeleteFlag deletion,
                             Priority priorityLevel,
                             const PString & threadName,
                             PINDEX stackSize)
: PThread(stackSize, deletion, priorityLevel, threadName),
callback(notifier),
parameter(param)
{
    Resume();
}


void PSimpleThread::Main()
{
    callback(*this, parameter);
}


