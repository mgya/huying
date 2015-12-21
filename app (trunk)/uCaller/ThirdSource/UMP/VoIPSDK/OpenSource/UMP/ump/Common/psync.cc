//
//  psync.cxx
//  UMPTest
//
//  Created by thehuah on 14-4-12.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "psync.h"
#include "ptthread.h"

////////////////////////////////////////////////////////////////////////////////////////

PSemaphore::PSemaphore(PXClass pxc)
{
    pxClass = pxc;
    
    // these should never be used, as this constructor is
    // only used for PMutex and PSyncPoint and they have their
    // own copy constructors
    
    initialVar = maxCountVar = 0;
    
    if(pxClass == PXSemaphore) {
#if defined(P_HAS_SEMAPHORES)
        /* call sem_init, otherwise sem_destroy fails*/
        PAssertPTHREAD(sem_init, (&semId, 0, 0));
#elif defined(P_HAS_NAMED_SEMAPHORES)
        semId = CreateSem(0);
#else
        currentCount = maximumCount = 0;
        queuedLocks = 0;
        pthread_mutex_init(&mutex, NULL);
        pthread_cond_init(&condVar, NULL);
#endif
    }
}

PSemaphore::PSemaphore(unsigned initial, unsigned maxCount)
{
    pxClass = PXSemaphore;
    
    initialVar  = initial;
    maxCountVar = maxCount;
    
#if defined(P_HAS_SEMAPHORES)
    PAssertPTHREAD(sem_init, (&semId, 0, initial));
#elif defined(P_HAS_NAMED_SEMAPHORES)
    semId = CreateSem(initialVar);
#else
    PAssertPTHREAD(pthread_mutex_init, (&mutex, NULL));
    PAssertPTHREAD(pthread_cond_init, (&condVar, NULL));
    
    PAssert(maxCount > 0, "Invalid semaphore maximum.");
    if (initial > maxCount)
        initial = maxCount;
    
    currentCount = initial;
    maximumCount = maxCount;
    queuedLocks  = 0;
#endif
}

PSemaphore::PSemaphore(const PSemaphore & sem)
{
    pxClass = sem.GetSemClass();
    
    initialVar  = sem.GetInitial();
    maxCountVar = sem.GetMaxCount();
    
    if(pxClass == PXSemaphore) {
#if defined(P_HAS_SEMAPHORES)
        PAssertPTHREAD(sem_init, (&semId, 0, initialVar));
#elif defined(P_HAS_NAMED_SEMAPHORES)
        semId = CreateSem(initialVar);
#else
        PAssertPTHREAD(pthread_mutex_init, (&mutex, NULL));
        PAssertPTHREAD(pthread_cond_init, (&condVar, NULL));
        
        PAssert(maxCountVar > 0, "Invalid semaphore maximum.");
        if (initialVar > maxCountVar)
            initialVar = maxCountVar;
        
        currentCount = initialVar;
        maximumCount = maxCountVar;
        queuedLocks  = 0;
#endif
    }
}

PSemaphore::~PSemaphore()
{
    if(pxClass == PXSemaphore) {
#if defined(P_HAS_SEMAPHORES)
        PAssertPTHREAD(sem_destroy, (&semId));
#elif defined(P_HAS_NAMED_SEMAPHORES)
        PAssertPTHREAD(sem_close, (semId));
#else
        PAssert(queuedLocks == 0, "Semaphore destroyed with queued locks");
        PAssertPTHREAD(pthread_mutex_destroy, (&mutex));
        PAssertPTHREAD(pthread_cond_destroy, (&condVar));
#endif
    }
}

#if defined(P_HAS_NAMED_SEMAPHORES)
sem_t * PSemaphore::CreateSem(unsigned initialValue)
{
    sem_t *sem;
    
    // Since sem_open and sem_unlink are two operations, there is a small
    // window of opportunity that two simultaneous accesses may return
    // the same semaphore. Therefore, the static mutex is used to
    // prevent this, even if the chances are small
    static pthread_mutex_t semCreationMutex = PTHREAD_MUTEX_INITIALIZER;
    PAssertPTHREAD(pthread_mutex_lock, (&semCreationMutex));
    
    sem_unlink("/pwlib_sem");
    sem = sem_open("/pwlib_sem", (O_CREAT | O_EXCL), 700, initialValue);
    
    PAssertPTHREAD(pthread_mutex_unlock, (&semCreationMutex));
    
    PAssert(((int)sem != SEM_FAILED), "Couldn't create named semaphore");
    return sem;
}
#endif

void PSemaphore::Wait()
{
#if defined(P_HAS_SEMAPHORES)
    PAssertPTHREAD(sem_wait, (&semId));
#elif defined(P_HAS_NAMED_SEMAPHORES)
    PAssertPTHREAD(sem_wait, (semId));
#else
    PAssertPTHREAD(pthread_mutex_lock, (&mutex));
    
    queuedLocks++;
    PThread::Current()->PXSetWaitingSemaphore(this);
    
    //modified by brant
    while (currentCount == 0) {
        int err = pthread_cond_wait(&condVar, &mutex);
        PAssert(err == 0 || err == EINTR, psprintf("wait error = %i", err));
        PThread::Yield();
    }
    
    PThread::Current()->PXSetWaitingSemaphore(NULL);
    queuedLocks--;
    
    currentCount--;
    
    PAssertPTHREAD(pthread_mutex_unlock, (&mutex));
#endif
}

PBOOL PSemaphore::Wait(const PTimeInterval & waitTime)
{
    if (waitTime == PMaxTimeInterval) {
        Wait();
        return TRUE;
    }
    
#if defined(P_HAS_SEMAPHORES)
#ifdef P_HAS_SEMAPHORES_XPG6
    // use proper timed spinlocks if supported.
    // http://www.opengroup.org/onlinepubs/007904975/functions/sem_timedwait.html
    
    PTime timeout;
    timeout+=waitTime;
    struct timespec absTime;
    absTime.tv_sec  = timeout.GetTimeInSeconds();
    absTime.tv_nsec = timeout.GetMicrosecond() * 1000;
    
    if (sem_timedwait(&semId, &absTime) == 0) {
        return TRUE;
    }
    else {
        return FALSE;
    }
    
#else
    // create absolute finish time
    PTimeInterval finishTime=PTimer::Tick();
    finishTime += waitTime;
    // loop until timeout, or semaphore becomes available
    // don't use a PTimer, as this causes the housekeeping
    // thread to get very busy
    do {
        if (sem_trywait(&semId) == 0)
            return TRUE;
        
        //modified by brant
        /*
         #if defined(P_LINUX)
         // sched_yield in a tight loop is bad karma
         // for the linux scheduler: http://www.ussg.iu.edu/hypermail/linux/kernel/0312.2/1127.html
         PThread::Sleep(10);
         #else*/
        
        PThread::Yield();
        //#endif
    } while (PTimer::Tick() < finishTime);
    
    return FALSE;
    
#endif
#elif defined(P_HAS_NAMED_SEMAPHORES)
    PTimeInterval finishTime=PTimer::Tick();
    finishTime += waitTime;
    do {
        if(sem_trywait(semId) == 0)
            return TRUE;
        //modified by brant
        PThread::Yield();
    } while (PTimer::Tick() < finishTime);
    
    return FALSE;
#else
    
    PTime timeout;
    timeout+=waitTime;
    struct timespec absTime;
    absTime.tv_sec  = timeout.GetTimeInSeconds();
    absTime.tv_nsec = timeout.GetMicrosecond() * 1000;
    
    PAssertPTHREAD(pthread_mutex_lock, (&mutex));
    
    PThread * thread = PThread::Current();
    thread->PXSetWaitingSemaphore(this);
    queuedLocks++;
    
    PBOOL ok = TRUE;
    //modified by brant
    while (currentCount == 0) {
        int err = pthread_cond_timedwait(&condVar, &mutex, &absTime);
        if (err == ETIMEDOUT) {
            ok = FALSE;
            break;
        }
        else
        {
            PAssert(err == 0 || err == EINTR, psprintf("timed wait error = %i", err));
            PThread::Yield();
        }
    }
    
    thread->PXSetWaitingSemaphore(NULL);
    queuedLocks--;
    
    if (ok)
        currentCount--;
    
    PAssertPTHREAD(pthread_mutex_unlock, ((pthread_mutex_t *)&mutex));
    
    return ok;
#endif
}

void PSemaphore::Signal()
{
#if defined(P_HAS_SEMAPHORES)
    PAssertPTHREAD(sem_post, (&semId));
#elif defined(P_HAS_NAMED_SEMAPHORES)
    PAssertPTHREAD(sem_post, (semId));
#else
    PAssertPTHREAD(pthread_mutex_lock, (&mutex));
    
    if (currentCount < maximumCount)
        currentCount++;
    
    if (queuedLocks > 0)
        PAssertPTHREAD(pthread_cond_signal, (&condVar));
    
    PAssertPTHREAD(pthread_mutex_unlock, (&mutex));
#endif
}

PBOOL PSemaphore::WillBlock() const
{
#if defined(P_HAS_SEMAPHORES)
    if (sem_trywait((sem_t *)&semId) != 0) {
        PAssertOS(errno == EAGAIN || errno == EINTR);
        return TRUE;
    }
    PAssertPTHREAD(sem_post, ((sem_t *)&semId));
    return FALSE;
#elif defined(P_HAS_NAMED_SEMAPHORES)
    if (sem_trywait(semId) != 0) {
        PAssertOS(errno == EAGAIN || errno == EINTR);
        return TRUE;
    }
    PAssertPTHREAD(sem_post, (semId));
    return FALSE;
#else
    return currentCount == 0;
#endif
}

#if defined(P_MACOSX) && (P_HAS_RECURSIVE_MUTEX == 1)
#define PTHREAD_MUTEX_RECURSIVE_NP PTHREAD_MUTEX_RECURSIVE
#endif

#if defined P_HAS_SEMAPHORES

PCriticalSection::PCriticalSection()
{ ::sem_init(&sem, 0, 1); }

PCriticalSection::~PCriticalSection()
{ ::sem_destroy(&sem); }

void PCriticalSection::Wait()
{ ::sem_wait(&sem); }

void PCriticalSection::Signal()
{ ::sem_post(&sem); }

#endif

PTimedMutex::PTimedMutex()
{
#if P_HAS_RECURSIVE_MUTEX
    pthread_mutexattr_t attr;
    PAssertPTHREAD(pthread_mutexattr_init, (&attr));
    PAssertPTHREAD(pthread_mutexattr_settype, (&attr, PTHREAD_MUTEX_RECURSIVE_NP));
    PAssertPTHREAD(pthread_mutex_init, (&mutex, &attr));
    PAssertPTHREAD(pthread_mutexattr_destroy, (&attr));
#else
    PAssertPTHREAD(pthread_mutex_init, (&mutex, NULL));
    ownerThreadId = (pthread_t)-1;
#endif
}

PTimedMutex::PTimedMutex(const PTimedMutex & /*mut*/)
{
#if P_HAS_RECURSIVE_MUTEX
    pthread_mutexattr_t attr;
    PAssertPTHREAD(pthread_mutexattr_init, (&attr));
    PAssertPTHREAD(pthread_mutexattr_settype, (&attr, PTHREAD_MUTEX_RECURSIVE_NP));
    PAssertPTHREAD(pthread_mutex_init, (&mutex, &attr));
    PAssertPTHREAD(pthread_mutexattr_destroy, (&attr));
#else
    pthread_mutex_init(&mutex, NULL);
    ownerThreadId = (pthread_t)-1;
#endif
}

PTimedMutex::~PTimedMutex()
{
    int result = pthread_mutex_destroy(&mutex);
    PINDEX i = 0;
    while ((result == EBUSY) && (i++ < 20)) {
        pthread_mutex_unlock(&mutex);
        result = pthread_mutex_destroy(&mutex);
    }
#ifdef _DEBUG
    PAssert((result == 0), "Error destroying mutex");
#endif
}

void PTimedMutex::Wait()
{
#if P_HAS_RECURSIVE_MUTEX == 0
    pthread_t currentThreadId = pthread_self();
    
    // if the mutex is already acquired by this thread,
    // then just increment the lock count
    if (pthread_equal(ownerThreadId, currentThreadId)) {
        // Note this does not need a lock as it can only be touched by the thread
        // which already has the mutex locked.
        ++lockCount;
        return;
    }
#endif
    
    // acquire the lock for real
    PAssertPTHREAD(pthread_mutex_lock, (&mutex));
    
#if P_HAS_RECURSIVE_MUTEX == 0
    PAssert((ownerThreadId == (pthread_t)-1) && (lockCount.IsZero()),
            "PMutex acquired whilst locked by another thread");
    // Note this is protected by the mutex itself only the thread with
    // the lock can alter it.
    ownerThreadId = currentThreadId;
#endif
}

PBOOL PTimedMutex::Wait(const PTimeInterval & waitTime)
{
    // if waiting indefinitely, then do so
    if (waitTime == PMaxTimeInterval) {
        Wait();
        return TRUE;
    }
    
#if P_HAS_RECURSIVE_MUTEX == 0
    // get the current thread ID
    pthread_t currentThreadId = pthread_self();
    
    // if we already have the mutex, return immediately
    if (pthread_equal(ownerThreadId, currentThreadId)) {
        // Note this does not need a lock as it can only be touched by the thread
        // which already has the mutex locked.
        ++lockCount;
        return TRUE;
    }
#endif
    
    // create absolute finish time
#if P_PTHREADS_XPG6
    PTime timeout;
    timeout+=waitTime;
    struct timespec absTime;
    absTime.tv_sec  = timeout.GetTimeInSeconds();
    absTime.tv_nsec = timeout.GetMicrosecond() * 1000;
    
#if P_HAS_RECURSIVE_MUTEX
    return pthread_mutex_timedlock(&mutex, &absTime) == 0;
#else
    
    if (pthread_mutex_timedlock(&mutex, &absTime) != 0)
        return FALSE;
    
    PAssert((ownerThreadId == (pthread_t)-1) && (lockCount.IsZero()),
            "PMutex acquired whilst locked by another thread");
    
    // Note this is protected by the mutex itself only the thread with
    // the lock can alter it.
    ownerThreadId = currentThreadId;
    return TRUE;
    
#endif
    
#else // P_PTHREADS_XPG6
    PTimeInterval finishTime=PTimer::Tick();
    finishTime += waitTime;
    do {
        if (pthread_mutex_trylock(&mutex) == 0) {
#if P_HAS_RECURSIVE_MUTEX == 0
            PAssert((ownerThreadId == (pthread_t)-1) && (lockCount.IsZero()),
                    "PMutex acquired whilst locked by another thread");
            // Note this is protected by the mutex itself only the thread with
            // the lock can alter it.
            ownerThreadId = currentThreadId;
#endif // P_HAS_RECURSIVE_MUTEX
            
            return TRUE;
        }
        
        //modified by brant
        PThread::Yield(); // sleep for 10ms
    } while (PTimer::Tick() < finishTime);
    
    return FALSE;
    
#endif // P_PTHREADS_XPG6
}

void PTimedMutex::Signal()
{
#if P_HAS_RECURSIVE_MUTEX == 0
    if (!pthread_equal(ownerThreadId, pthread_self())) {
        PAssertAlways("PMutex signal failed - no matching wait or signal by wrong thread");
        return;
    }
    
    // if lock was recursively acquired, then decrement the counter
    // Note this does not need a separate lock as it can only be touched by the thread
    // which already has the mutex locked.
    if (!lockCount.IsZero()) {
        --lockCount;
        return;
    }
    
    // otherwise mark mutex as available
    ownerThreadId = (pthread_t)-1;
#endif
    
    int ret = pthread_mutex_unlock(&mutex);
    if(ret != 0)
        cout << "pthread_mutex_unlock return:"<<ret<<endl;
    //PAssertPTHREAD(pthread_mutex_unlock, (&mutex));
}

PBOOL PTimedMutex::WillBlock() const
{
#if P_HAS_RECURSIVE_MUTEX == 0
    pthread_t currentThreadId = pthread_self();
    if (currentThreadId == ownerThreadId)
        return FALSE;
#endif
    
    pthread_mutex_t * mp = (pthread_mutex_t*)&mutex;
    if (pthread_mutex_trylock(mp) != 0)
        return TRUE;
    
    PAssertPTHREAD(pthread_mutex_unlock, (mp));
    return FALSE;
}

PSyncPoint::PSyncPoint()
: PSemaphore(PXSyncPoint)
{
    PAssertPTHREAD(pthread_mutex_init, (&mutex, NULL));
    PAssertPTHREAD(pthread_cond_init, (&condVar, NULL));
    signalCount = 0;
}

PSyncPoint::PSyncPoint(const PSyncPoint &)
: PSemaphore(PXSyncPoint)
{
    PAssertPTHREAD(pthread_mutex_init, (&mutex, NULL));
    PAssertPTHREAD(pthread_cond_init, (&condVar, NULL));
    signalCount = 0;
}

PSyncPoint::~PSyncPoint()
{
    PAssertPTHREAD(pthread_mutex_destroy, (&mutex));
    PAssertPTHREAD(pthread_cond_destroy, (&condVar));
}

void PSyncPoint::Wait()
{
    PAssertPTHREAD(pthread_mutex_lock, (&mutex));
    while (signalCount == 0)
        pthread_cond_wait(&condVar, &mutex);
    signalCount--;
    PAssertPTHREAD(pthread_mutex_unlock, (&mutex));
}

PBOOL PSyncPoint::Wait(const PTimeInterval & waitTime)
{
    PAssertPTHREAD(pthread_mutex_lock, (&mutex));
    
    PTime finishTime;
    finishTime += waitTime;
    struct timespec absTime;
    absTime.tv_sec  = finishTime.GetTimeInSeconds();
    absTime.tv_nsec = finishTime.GetMicrosecond() * 1000;
    
    int err = 0;
    //modified by brant
    while (signalCount == 0) {
        err = pthread_cond_timedwait(&condVar, &mutex, &absTime);
        if (err == 0 || err == ETIMEDOUT)
            break;
        
        PAssertOS(err == EINTR && errno == EINTR);
        //modified by brant
        PThread::Yield();
        
    }
    
    if (err == 0)
        signalCount--;
    
    PAssertPTHREAD(pthread_mutex_unlock, (&mutex));
    
    return err == 0;
}

void PSyncPoint::Signal()
{
    PAssertPTHREAD(pthread_mutex_lock, (&mutex));
    //modified by brant, obviously, it's a bug
    if(signalCount==0){
        
        signalCount++;
        PAssertPTHREAD(pthread_cond_signal, (&condVar));
    }
    PAssertPTHREAD(pthread_mutex_unlock, (&mutex));
    
}

PBOOL PSyncPoint::WillBlock() const
{
    return signalCount == 0;
}
