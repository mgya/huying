//
//  psync.h
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__psync__
#define __UMPStack__psync__

#ifdef P_USE_PRAGMA
#pragma interface
#endif

#include <limits.h>

#include "pcommon.h"


#if P_HAS_ATOMIC_INT
#if P_NEEDS_GNU_CXX_NAMESPACE
#define EXCHANGE_AND_ADD(v,i)   __gnu_cxx::__exchange_and_add(v,i)
#else
#define EXCHANGE_AND_ADD(v,i)   __exchange_and_add(v,i)
#endif
#endif

class PThread;
class PTimeInterval;

class PSync : public PObject
{
public:
    /**@name Operations */
    //@{
    /**Block until the synchronisation object is available
     */
    virtual void Wait() = 0;
    
    /**Signal that the synchronisation object is available
     */
    virtual void Signal() = 0;
    //@}
    
};

/**This class waits for the semaphore on construction and automatically
 signals the semaphore on destruction. Any descendent of PSemaphore
 may be used.
 
 This is very usefull for constructs such as:
 \begin{verbatim}
 void func()
 {
 PWaitAndSignal mutexWait(myMutex);
 if (condition)
 return;
 do_something();
 if (other_condition)
 return;
 do_something_else();
 }
 \end{verbatim}
 */

class PWaitAndSignal {
public:
    /**Create the semaphore wait instance.
     This will wait on the specified semaphore using the #Wait()# function
     before returning.
     */
    inline PWaitAndSignal(
                          const PSync & sem,   ///< Semaphore descendent to wait/signal.
                          PBOOL wait = TRUE    ///< Wait for semaphore before returning.
    ) : sync((PSync &)sem)
    { if (wait) sync.Wait(); }
    
    /** Signal the semaphore.
     This will execute the Signal() function on the semaphore that was used
     in the construction of this instance.
     */
    ~PWaitAndSignal()
    { sync.Signal(); }
    
protected:
    PSync & sync;
};

typedef PWaitAndSignal PEnterAndLeave;

class PSemaphore : public PSync
{
    PCLASSINFO(PSemaphore, PSync);
    
public:
    /**@name Construction */
    //@{
    /**Create a new semaphore with maximum count and initial value specified.
     If the initial value is larger than the maximum value then is is set to
     the maximum value.
     */
    PSemaphore(
               unsigned initial, ///< Initial value for semaphore count.
               unsigned maximum  ///< Maximum value for semaphore count.
    );
    
    /** Create a new Semaphore with the same initial and maximum values as the original
     */
    PSemaphore(const PSemaphore &);
    
    /**Destroy the semaphore. This will assert if there are still waiting
     threads on the semaphore.
     */
    ~PSemaphore();
    //@}
    
    /**@name Operations */
    //@{
    /**If the semaphore count is > 0, decrement the semaphore and return. If
     if is = 0 then wait (block).
     */
    virtual void Wait();
    
    /**If the semaphore count is > 0, decrement the semaphore and return. If
     if is = 0 then wait (block) for the specified amount of time.
     
     @return
     TRUE if semaphore was signalled, FALSE if timed out.
     */
    virtual PBOOL Wait(
                       const PTimeInterval & timeout // Amount of time to wait for semaphore.
    );
    
    /**If there are waiting (blocked) threads then unblock the first one that
     was blocked. If no waiting threads and the count is less than the
     maximum then increment the semaphore.
     */
    virtual void Signal();
    
    /**Determine if the semaphore would block if the #Wait()# function
     were called.
     
     @return
     TRUE if semaphore will block when Wait() is called.
     */
    virtual PBOOL WillBlock() const;
    //@}
    
private:
    PSemaphore & operator=(const PSemaphore &) { return *this; }
    
    
    // Include platform dependent part of class
public:
    unsigned GetInitial() const { return initialVar; }
    unsigned GetMaxCount() const     { return maxCountVar; }
    
protected:
    unsigned initialVar;
    unsigned maxCountVar;
    
#if defined(P_MAC_MPTHREADS)
protected:
    mutable MPSemaphoreID semId;
#elif defined(P_PTHREADS)
    
    enum PXClass { PXSemaphore, PXMutex, PXSyncPoint } pxClass;
    PXClass GetSemClass() const { return pxClass; }
    
    //protected:
public:
    PSemaphore(PXClass);
    mutable pthread_mutex_t mutex;
    mutable pthread_cond_t  condVar;
    
#if defined(P_HAS_SEMAPHORES)
    mutable sem_t semId;
#elif defined(P_HAS_NAMED_SEMAPHORES)
    mutable sem_t *semId;
    sem_t *CreateSem(unsigned initialValue);
#else
    mutable unsigned currentCount;
    mutable unsigned maximumCount;
    mutable unsigned queuedLocks;
#endif
    
#else
    
protected:
    PQUEUE(ThreadQueue, PThread);
    ThreadQueue waitQueue;
    
#endif
};


class PSyncPoint : public PSemaphore
{
    PCLASSINFO(PSyncPoint, PSemaphore);
    
public:
    /** Create a new sync point.
     */
    PSyncPoint();
    PSyncPoint(const PSyncPoint &);
    
    
    // Include platform dependent part of class
#if defined(P_PTHREADS)
public:
    virtual ~PSyncPoint();
#endif
    
#if defined(P_PTHREADS) || defined(P_MAC_MPTHREADS)
public:
    virtual void Wait();
    virtual PBOOL Wait(const PTimeInterval & timeout);
    virtual void Signal();
    virtual PBOOL WillBlock() const;
private:
    unsigned signalCount;
#endif
};

class PCriticalSection : public PSync
{
    PCLASSINFO(PCriticalSection, PSync);
    
public:
    /**@name Construction */
    //@{
    /**Create a new critical section object .
     */
    //@}
    PCriticalSection();
    PCriticalSection(const PCriticalSection &);
    
    /**Destroy the critical section object
     */
    ~PCriticalSection();
    
    void Wait();
    inline void Enter()
    { Wait(); }
    
    /** Leave the critical section by unlocking the mutex
     */
    void Signal();
    inline void Leave()
    { Signal(); }
    
private:
    PCriticalSection & operator=(const PCriticalSection &) { return *this; }
    
    // Include platform dependent part of class
    // Unix specific critical section implementation
#if defined P_HAS_SEMAPHORES
    mutable sem_t sem;
#endif
    
};


/** This class implements an integer that can be atomically
 * incremented and decremented in a thread-safe manner.
 * On Windows, the integer is of type long and this class is implemented using InterlockedIncrement
 * and InterlockedDecrement integer is of type long.
 * On Unix systems with GNU std++ support for EXCHANGE_AND_ADD, the integer is of type _Atomic_word (normally int)
 * On all other systems, this class is implemented using PCriticalSection and the integer is of type int.
 */

class PAtomicInteger
{
#if defined(P_HAS_ATOMIC_INT)
public:
    inline PAtomicInteger(int v = 0)
    : value(v) { }
    PBOOL IsZero() const                { return value == 0; }
    inline int operator++()            { return EXCHANGE_AND_ADD(&value, 1) + 1; }
    inline int unsigned operator--()   { return EXCHANGE_AND_ADD(&value, -1) - 1; }
    inline operator int () const       { return value; }
    inline void SetValue(int v)        { value = v; }
protected:
    _Atomic_word value;
#else
protected:
    PCriticalSection critSec;
public:
    inline PAtomicInteger(int v = 0)
    : value(v) { }
    PBOOL IsZero() const                { return value == 0; }
    inline int operator++()            { PWaitAndSignal m(critSec); value++; return value;}
    inline int operator--()            { PWaitAndSignal m(critSec); value--; return value;}
    inline operator int () const       { return value; }
    inline void SetValue(int v)        { value = v; }
    //private:
    PAtomicInteger & operator=(const PAtomicInteger & ref) { value = (int)ref; return *this; }
protected:
    int value;
#endif
};

class PTimedMutex : public PSync
{
    PCLASSINFO(PTimedMutex, PSync)
    
public:
    /* Create a new mutex.
     Initially the mutex will not be "set", so the first call to Wait() will
     never wait.
     */
    PTimedMutex();
    PTimedMutex(const PTimedMutex & mutex);
    
    // Include platform dependent part of class
#if defined(P_PTHREADS)
    virtual ~PTimedMutex();
    mutable pthread_mutex_t mutex;
#endif
    
#if defined(P_PTHREADS) || defined(P_MAC_MPTHREADS)
    virtual void Wait();
    virtual PBOOL Wait(const PTimeInterval & timeout);
    virtual void Signal();
    virtual PBOOL WillBlock() const;
    
protected:
    
#if defined(P_PTHREADS)
#if P_HAS_RECURSIVE_MUTEX == 0
    mutable pthread_t ownerThreadId;
    mutable PAtomicInteger lockCount;
#endif
#endif
    
#endif
    
};

typedef PTimedMutex PMutex;

#endif /* defined(__UMPStack__psync__) */
