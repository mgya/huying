//
//  ptthread.h
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__ptthread__
#define __UMPStack__ptthread__

#include <map>

#include "pcommon.h"
#include "pstring.h"
#include "ptimer.h"
#include "pnotifier.h"
#include "psync.h"

#ifdef Priority
#undef Priority
#endif

#ifdef P_MACOSX
#include <mach/mach.h>
#include <mach/thread_policy.h>
#include <sys/param.h>
#include <sys/sysctl.h>
// going to need the main thread for adjusting relative priority
static pthread_t baseThread;
#endif

class PSemaphore;

#define PThreadIdentifer PThreadIdentifier

typedef P_THREADIDENTIFIER PThreadIdentifier;

#define PPThreadKill(id, sig)  PProcess::Current().PThreadKill(id, sig)

#define PAssertPTHREAD(func, args) \
{ \
unsigned threadOpRetry = 0; \
while (PAssertThreadOp(func args, threadOpRetry, #func, __FILE__, __LINE__)); \
}

PBOOL PAssertThreadOp(int retval,
                             unsigned & retry,
                             const char * funcname,
                             const char * file,
                      unsigned line);

///////////////////////////////////////////////////////////////////////////////
// PThread

/** This class defines a thread of execution in the system. A {\it thread} is
 an independent flow of processor instructions. This differs from a
 {\it process} which also embodies a program address space and resource
 allocation. So threads can share memory and resources as they run in the
 context of a given process. A process always contains at least one thread.
 This is reflected in this library by the #PProcess# class being
 descended from the PThread class.
 
 The implementation of a thread is platform dependent, but it is
 assumed that the platform has some support for native threads.
 Previous versions of PWLib has some support for co-operative
 threads, but this has been removed
 */
class PThread : public PObject
{
    PCLASSINFO(PThread, PObject);
    
public:
    /**@name Construction */
    //@{
    /// Codes for thread priorities.
    enum Priority {
        /// Will only run if all other threads are blocked.
        LowestPriority,
        
        /// Runs approximately half as often as normal.
        LowPriority,
        
        /// Normal priority for a thread.
        NormalPriority,
        
        /// Runs approximately twice as often as normal.
        HighPriority,
        
        /// Is only thread that will run, unless blocked.
        HighestPriority,
        
        NumPriorities
    };
    
    /// Codes for thread autodelete flag
    enum AutoDeleteFlag {
        /// Automatically delete thread object on termination.
        AutoDeleteThread,
        
        /// Don't delete thread as it may not be on heap.
        NoAutoDeleteThread
    };
    
    /** Create a new thread instance. Unless the #startSuspended#
     parameter is TRUE, the threads #Main()# function is called to
     execute the code for the thread.
     
     Note that the exact timing of the execution of code in threads can
     never be predicted. Thus you you can get a race condition on
     intialising a descendent class. To avoid this problem a thread is
     always started suspended. You must call the Resume() function after
     your descendent class construction is complete.
     
     If synchronisation is required between threads then the use of
     semaphores is essential.
     
     If the #deletion# is set to #AutoDeleteThread#
     then the PThread is assumed to be allocated with the new operator and
     may be freed using the delete operator as soon as the thread is
     terminated or executes to completion (usually the latter).
     
     The stack size argument retained only for source code compatibility for
     previous implementations. It is not used in the current code and
     may be removed in subsequent versions.
     */
    PThread(
            PINDEX ,                 ///< Not used - previously stack size
            AutoDeleteFlag deletion = AutoDeleteThread,
            ///< Automatically delete PThread instance on termination of thread.
            Priority priorityLevel = NormalPriority,  ///< Initial priority of thread.
            const PString & threadName = PString::Empty() ///< The name of the thread (for Debug/Trace)
    );
    
    /** Destroy the thread, this simply calls the #Terminate()# function
     with all its restrictions and penalties. See that function for more
     information.
     
     Note that the correct way for a thread to terminate is to return from
     the #Main()# function.
     */
    ~PThread();
    //@}
    
    /**@name Overrides from PObject */
    //@{
    /**Standard stream print function.
     The PObject class has a << operator defined that calls this function
     polymorphically.
     */
    void PrintOn(
                 ostream & strm    ///< Stream to output text representation
    ) const;
    //@}
    
    /**@name Control functions */
    //@{
    /** Restart a terminated thread using the same stack priority etc that
     was current when the thread terminated.
     
     If the thread is still running then this function is ignored.
     */
    virtual void Restart();
    
    /** Terminate the thread. It is highly recommended that this is not used
     except in abnormal abort situations as not all clean up of resources
     allocated to the thread will be executed. This is especially true in
     C++ as the destructors of objects that are automatic variables are not
     called causing at the very least the possiblity of memory leaks.
     
     Note that the correct way for a thread to terminate is to return from
     the #Main()# function or self terminate by calling
     #Terminate()# within the context of the thread which can then
     assure that all resources are cleaned up.
     */
    virtual void Terminate();
    
    /** Determine if the thread has been terminated or ran to completion.
     
     @return
     TRUE if the thread has been terminated.
     */
    virtual PBOOL IsTerminated() const;
    
    /** Block and wait for the thread to terminate.
     
     @return
     FALSE if the thread has not terminated and the timeout has expired.
     */
    void WaitForTermination() const;
    PBOOL WaitForTermination(
                            const PTimeInterval & maxWait  ///< Maximum time to wait for termination.
    ) const;
    
    /** Suspend or resume the thread.
     
     If #susp# is TRUE this increments an internal count of
     suspensions that must be matched by an equal number of calls to
     #Resume()# or #Suspend(FALSE)# before the
     thread actually executes again.
     
     If #susp# is FALSE then this decrements the internal count of
     suspensions. If the count is <= 0 then the thread will run. Note that
     the thread will not be suspended until an equal number of
     #Suspend(TRUE)# calls are made.
     */
    virtual void Suspend(
                         PBOOL susp = TRUE    ///< Flag to suspend or resume a thread.
    );
    
    /** Resume thread execution, this is identical to
     #Suspend(FALSE)#.
     
     The Resume() method may be called from within the constructor of a
     PThread descendant.  However, the Resume() should be in the
     constructor of the most descendant class. So, if you have a
     class B (which is descended of PThread), and a class C (which is
     descended of B), placing the call to Resume in the constructor of B is
     unwise.
     
     If you do place a call to Resume in the constructor, it
     should be at the end of the constructor, after all the other
     initialisation in the constructor.
     
     The reason the call to Resume() should be at the end of the
     construction process is simple - you want the thread to start
     when all the variables in the class have been correctly
     initialised.
     */
    virtual void Resume();
    
    /** Determine if the thread is currently suspended. This checks the
     suspension count and if greater than zero returns TRUE for a suspended
     thread.
     
     @return
     TRUE if thread is suspended.
     */
    virtual PBOOL IsSuspended() const;
    
    /// Suspend the current thread for the specified amount of time.
    static void Sleep(
                      const PTimeInterval & delay   ///< Time interval to sleep for.
    );
    
    /** Set the priority of the thread relative to other threads in the current
     process.
     */
    virtual void SetPriority(
                             Priority priorityLevel    ///< New priority for thread.
    );
    
    /** Get the current priority of the thread in the current process.
     
     @return
     current thread priority.
     */
    virtual Priority GetPriority() const;
    
    /** Set the flag indicating thread object is to be automatically deleted
     when the thread ends.
     */
    virtual void SetAutoDelete(
                               AutoDeleteFlag deletion = AutoDeleteThread  ///< New auto delete setting.
    );
    
    /** Reet the flag indicating thread object is to be automatically deleted
     when the thread ends.
     */
    void SetNoAutoDelete() { SetAutoDelete(NoAutoDeleteThread); }
    
    /** Get the name of the thread. Thread names are a optional debugging aid.
     
     @return
     current thread name.
     */
    virtual PString GetThreadName() const;
    
    /** Change the name of the thread. Thread names are a optional debugging aid.
     
     @return
     current thread name.
     */
    virtual void SetThreadName(
                               const PString & name        ///< New name for the thread.
    );
    //@}
    
    /**@name Miscellaneous */
    //@{
    /** Get operating system specific thread identifier for this thread.
     * Note that the return value from these functions is only valid
     * if called by the owning thread. Calling this function for another
     * thread that may be terminating is a very bad idea.
     */
    virtual PThreadIdentifier GetThreadId() const;
    static PThreadIdentifier GetCurrentThreadId();
    
    /** User override function for the main execution routine of the thread. A
     descendent class must provide the code that will be executed in the
     thread within this function.
     
     Note that the correct way for a thread to terminate is to return from
     this function.
     */
    virtual void Main() = 0;
    
    /** Get the currently running thread object instance. It is possible, even
     likely, that the smae code may be executed in the context of differenct
     threads. Under some circumstances it may be necessary to know what the
     current codes thread is and this static function provides that
     information.
     
     @return
     pointer to current thread.
     */
    static PThread * Current();
    
    /** Yield to another thread without blocking.
     This duplicates the implicit thread yield that may occur on some
     I/O operations or system calls.
     
     This may not be implemented on all platforms.
     */
    static void Yield();
    
    /**Create a simple thread executing the specified notifier.
     This creates a simple PThread class that automatically executes the
     function defined by the PNotifier in the context of a new thread.
     */
    static PThread * Create(
                            const PNotifier & notifier,     ///< Function to execute in thread.
                            INT parameter = 0,              ///< Parameter value to pass to notifier.
                            AutoDeleteFlag deletion = AutoDeleteThread,
                            ///< Automatically delete PThread instance on termination of thread.
                            Priority priorityLevel = NormalPriority,  ///< Initial priority of thread.
                            const PString & threadName = PString::Empty(), ///< The name of the thread (for Debug/Trace)
                            PINDEX stackSize = 10000         ///< Stack size on some platforms
    );
    //@}
    
protected:
    void InitialiseProcessThread();
    /* Initialialise the primordial thread, the one in the PProcess. This is
     required due to the bootstrap logic of processes and threads.
     */
    
private:
    PThread();
    // Create a new thread instance as part of a PProcess class.
    
    friend class PProcess;
    // So a PProcess can get at PThread() constructor but nothing else.
    
    PThread(const PThread &) { }
    // Empty constructor to prevent copying of thread instances.
    
    PThread & operator=(const PThread &) { return *this; }
    // Empty assignment operator to prevent copying of thread instances.
    
    PBOOL autoDelete;
    // Automatically delete the thread on completion.
    
    // Give the thread a name for debugging purposes.
    PString threadName;
    
private:
    unsigned traceBlockIndentLevel;
    friend class PTrace::Block;
    
    
    // Include platform dependent part of class
public:
    int PXBlockOnChildTerminate(int pid, const PTimeInterval & timeout);
    
    int PXBlockOnIO(int handle,
                    int type,
                    const PTimeInterval & timeout);
    
    void PXAbortBlock() const;
    
#ifdef P_PTHREADS
    
public:
#ifndef P_HAS_SEMAPHORES
    void PXSetWaitingSemaphore(PSemaphore * sem);
#endif
    
protected:
    static void * PX_ThreadStart(void *);
    static void PX_ThreadEnd(void *);
    
    PINDEX          PX_origStackSize;
    Priority        PX_priority;
    pthread_t       PX_threadId;
    pthread_mutex_t PX_suspendMutex;
    int             PX_suspendCount;
    PBOOL            PX_firstTimeStart;
    
#ifndef P_HAS_SEMAPHORES
    PSemaphore    * PX_waitingSemaphore;
    pthread_mutex_t PX_WaitSemMutex;
#endif
    
    int unblockPipe[2];
    friend class PSocket;
    friend void PX_SuspendSignalHandler(int);
    
#elif defined(P_MAC_MPTHREADS)
public:
    void PXSetWaitingSemaphore(PSemaphore * sem);
    //void InitialiseProcessThread();
    static long PX_ThreadStart(void *);
    static void PX_ThreadEnd(void *);
    MPTaskID    PX_GetThreadId() const;
    
protected:
    void PX_NewThread(PBOOL startSuspended);
    
    PINDEX     PX_origStackSize;
    int        PX_suspendCount;
    PSemaphore *suspend_semaphore;
    long       PX_signature;
    enum { kMPThreadSig = 'THRD', kMPDeadSig = 'DEAD'};
    
    MPTaskID   PX_threadId;
    MPSemaphoreID PX_suspendMutex;
    
    int unblockPipe[2];
    friend class PSocket;
#endif
};


/**
 Thread pool
 */

class JobBase
{
public:
	
	JobBase(const PString & name, PThread::Priority prio)
    :_name(name),_prio(prio)
	{
	}
	virtual ~JobBase()
	{}
	
	const PString & GetName() const
	{
		return _name;
	}
	PThread::Priority GetPriority() const
	{
		return _prio;
	}
	
	virtual void Run()=0;
	
protected:
	PString _name;
	PThread::Priority _prio;
};

#pragma pack(push,4)
template< class T>
class Job: public JobBase
{
public:
	
	Job(T* obj, void (T:: * func) () ,const PString & name, PThread::Priority prio = PThread::NormalPriority)
    :JobBase(name,prio), _obj(obj), _func(func)
	{
	}
	
	
	virtual void Run()
	{
		(_obj->*_func) ();
	}
	
	
protected:
	
	T* _obj;
	void (T::*_func)();
	
};
#pragma pack(pop)

template< class T, class A>
class JobA : public Job<T>
{
public:
	typedef void (T::*FuncA)(A);
	
	JobA(T* obj, FuncA func ,A arg ,const PString & name, PThread::Priority prio = PThread::NormalPriority)
    :Job<T>(obj,NULL,name,prio),_funcA(func),_arg(arg)
	{
	}
	
	
	virtual void Run()
	{
		(JobA<T,A>::_obj->*_funcA) (_arg);
	}
private:
	
	FuncA _funcA;
	A _arg;
	
	
};

#ifndef _NAMESPACE
#ifdef NEVER_DEFINED
#define _NAMESPACE struct
#else
#define _NAMESPACE namespace
#endif
#endif
_NAMESPACE  PThreadPool
{
	class PrioritySet {
	public:
		PrioritySet(PThread::Priority prio);
		
		~PrioritySet();
		
	protected:
		PThread::Priority _prio;
		
	private:
	};
    
    DWORD GetThreadTimeout();
	void SetThreadTimeout(DWORD timeout);
	void Execute(JobBase * job);
	
	template< class T>
	void Run(
             T* obj,
             void (T:: * func) (),
             const PString & name,
             PThread::Priority prio = PThread::NormalPriority)
	{
		Execute(new Job< T>(obj,func,name,prio));
	}
    
	template< class T, class A>
	void RunA(
              T* obj,
              void (T:: * funcA) (A),
              A arg,
              const PString & name,
              PThread::Priority prio = PThread::NormalPriority)
	{
		Execute(new JobA<T, A>(obj,funcA,arg,name,prio));
	}

};

#include "psync.h"

class PPooledThread : public PObject
{
	PCLASSINFO(PPooledThread, PObject);
public:
	PPooledThread();
	virtual ~PPooledThread();
    
	void Start(PThread::Priority prio = PThread::NormalPriority);
	void Join();
    
	PBOOL IsRunning() const;
protected:
	virtual void Main() = 0;
private:
	void Run();
private:
	PBOOL joined;
	PBOOL running;
	PSyncPoint sync;
};


class PSimpleThread : public PThread
{
    PCLASSINFO(PSimpleThread, PThread);
public:
    PSimpleThread(
                  const PNotifier & notifier,
                  INT parameter,
                  AutoDeleteFlag deletion,
                  Priority priorityLevel,
                  const PString & threadName,
                  PINDEX stackSize
                  );
    void Main();
protected:
    PNotifier callback;
    INT parameter;
};

PDECLARE_CLASS(PHouseKeepingThread, PThread)
public:
PHouseKeepingThread()
: PThread(1000, NoAutoDeleteThread, NormalPriority, "Housekeeper")
{ closing = FALSE; Resume(); }

void Main();
void SetClosing() { closing = TRUE; }

protected:
PBOOL closing;
};


class TPWorker : public PThread
{
	PCLASSINFO(TPWorker,PThread);
public:
	TPWorker();
	virtual ~TPWorker();
    
	void Execute(JobBase * job);
    
	PSyncPoint & GetJobSync() {return _jobSync;}
    
	void SetIdle(PBOOL idle);
private:
	void Main();
public:
	PSyncPoint _jobSync;
public:
	JobBase * _job;
    
	int _id;
    
};

typedef std::map<int, TPWorker * > TPWorkerMap;

class ThreadPoolKeeper
{
public:
	ThreadPoolKeeper()
    :idleCount(0),
    totalCount(0),
    shutdown(FALSE),
    id(0)
	{
	}
    
	virtual ~ThreadPoolKeeper()
	{
		
		PWaitAndSignal glock(mutex);
		
		shutdown = TRUE;
		{
			PWaitAndSignal lock(mapMutex);
			TPWorkerMap::iterator it = allMap.begin(),
            eit = allMap.end();
			while(it!=eit){
				it->second->_jobSync.Signal();
				it++;
			}
			
		}
		
		
#ifdef _DEBUG
		DWORD start = PTimer::Tick().GetInterval();
#endif
		while(totalCount){
			PThread::Sleep(10);
#ifdef _DEBUG
			if(PTimer::Tick().GetInterval()-start>10*1000)//wait for 10seconds
				break;
#endif
		}
		
		{
			PWaitAndSignal lock(mapMutex);
			if(!allMap.empty()){
				PTRACE(1,"WARN\tPThreadPool "<<totalCount<<" Workers still running!!");
				
				TPWorkerMap::iterator it = allMap.begin(),
                eit = allMap.end();
				while(it!=eit){
					if(it->second->_job)
						PTRACE(1, "INFO\tPThreadPool Worker ID #"<<it->second->GetThreadId()<<" running. job="<<it->second->_job->GetName());
					else
						PTRACE(1, "INFO\tPThreadPool Worker ID #"<<it->second->GetThreadId()<<" running.");
					it++;
				}
			}
		}
        
	}
    
public:
	
	
	
	TPWorkerMap idleMap;
	TPWorkerMap allMap;
	PMutex mapMutex;
	
	int idleCount;
	int totalCount;
	
	PBOOL shutdown;
	
	PMutex mutex;
	PAtomicInteger id;
    
};

static ThreadPoolKeeper * tpk = new ThreadPoolKeeper;

#endif /* defined(__UMPStack__ptthread__) */
