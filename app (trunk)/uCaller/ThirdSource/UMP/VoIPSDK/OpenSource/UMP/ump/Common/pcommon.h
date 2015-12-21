//
//  pcommon.h
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__pobject__
#define __UMPStack__pobject__

//#ifndef VOIPBASE_ANDROID
//#define VOIPBASE_ANDROID
//#endif

//#ifndef VOIPBASE_IOS
//#define VOIPBASE_IOS
//#endif

//#ifndef VOIPBASE_MAC
//#define VOIPBASE_MAC
//#endif

//#define UMP_IOS 1

#ifdef VOIPBASE_ANDROID
#define P_LINUX
#define P_PTHREADS
#define P_HAS_SEMAPHORES

#elif defined VOIPBASE_IOS
#define P_PTHREADS
#define P_HAS_SEMAPHORES
#define P_BSD

#elif defined VOIPBASE_MAC
#define P_MACOSX 1000
#define P_PTHREADS
#define P_HAS_SEMAPHORES
#endif

#ifdef P_USE_PRAGMA
#pragma interface
#endif

#include "ulog.h"
///////////////////////////////////////////////////////////////////////////////

#if defined(P_LINUX) || defined(P_BSD)

#include <paths.h>
#include <errno.h>
#include <signal.h>
#include <sys/ioctl.h>
//#include <sys/fcntl.h>
#include <fcntl.h>
//#include <sys/termios.h>
#include <termios.h>
#include <unistd.h>
#include <net/if.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <dlfcn.h>
#include <signal.h>

#define HAS_IFREQ
#define PSETPGRP()  setpgrp()

#if __GNU_LIBRARY__ < 6
#define P_LINUX_LIB_OLD
#endif

#ifdef PPC
typedef size_t socklen_t;
#endif

///////////////////////////////////////////////////////////////////////////////
#elif defined (P_MACOSX) || defined(P_MACOS)

#if defined(P_PTHREADS)
#   define _THREAD_SAFE
#   define P_THREAD_SAFE_CLIB
#   include <pthread.h>
#endif
#if defined(P_MAC_MPTHREADS)
#include <CoreServices/CoreServices.h>
// Blasted Mac <CoreServices.h> comes with 17 years of crufty history
// crapping up the namespace, thankyouverymuch.  (What I really want is
// just Multiprocessing.h, but that drags in nearly as much crap and isn't
// readily available on Mac OS X.)
// So:  undefine the troublespots as they occur.
#undef pnil // you morons.

// Open Transport and UNIX networking headers don't get along.  Why did
// Apple have to do this?  And what's worse, they are functionally equivalent
// #defines, Apple could have easily made the headers compatible.  But no.
#undef TCP_NODELAY
#undef TCP_MAXSEG
#endif // MPThreads

#include <paths.h>
#include <errno.h>
#include <termios.h>
#include <sys/fcntl.h>
#include <sys/filio.h>
#include <sys/socket.h>
#include <sys/sockio.h>
#include <sys/signal.h>
#include <net/if.h>
#include <netinet/tcp.h>
#include <sys/ioctl.h>
#include <signal.h>
//#include <fcntl.h>
//#include <unistd.h>
//#include <sys/types.h>
//#include <arm/types.h>

#if defined (P_MACOSX) && (P_MACOSX < 800)
typedef int socklen_t;
#endif

#define HAS_IFREQ

#define PSETPGRP()  setpgrp(0, 0)

///////////////////////////////////////////////////////////////////////////////
#elif defined(P_CYGWIN)
#include <sys/termios.h>
#include <sys/ioctl.h>
#include <sys/fcntl.h>

///////////////////////////////////////////////////////////////////////////////

// Other operating systems here

#else
#endif

///////////////////////////////////////////////////////////////////////////////

// includes common to all Unix variants

#include <netdb.h>
#include <dirent.h>
#include <limits.h>

#include <netinet/in.h>
#include <errno.h>
#include <sys/socket.h>
#include <sys/time.h>

#include <arpa/inet.h>
#include <netinet/in.h>

typedef int SOCKET;

#ifdef P_PTHREADS

#include <pthread.h>
#define P_THREADIDENTIFIER pthread_t

#if defined(P_HAS_SEMAPHORES) || defined(P_HAS_NAMED_SEMAPHORES)
#include <semaphore.h>
#endif  // P_HAS_SEMPAHORES

#endif  // P_PTHREADS

// End of file _PMACHDEP_H


#include <unistd.h>
#include <ctype.h>
#include <limits.h>


///////////////////////////////////////////
//
//  define TRUE and FALSE for environments that don't have them
//

#ifndef TRUE
#define TRUE    1
#endif

#ifndef FALSE
#define FALSE    0
#endif

///////////////////////////////////////////
//
//  define a macro for declaring classes so we can bolt
//  extra things to class declarations
//

#define PEXPORT
#define PSTATIC


///////////////////////////////////////////
//
// define some basic types and their limits
//
typedef int                PBOOL;
typedef unsigned char      BYTE;    // 1 byte
typedef signed short       PInt16;  // 16 bit
typedef unsigned short     WORD;

typedef signed int         PInt32;  // 32 bit
typedef unsigned int       DWORD;

#ifndef P_NEEDS_INT64
typedef   signed long long int PInt64;
typedef unsigned long long int PUInt64; // 64 bit
#endif

#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
#define P_64BIT
#endif
// Integer type that is same size as a pointer type.
#ifdef P_64BIT
typedef long          INT;
typedef unsigned long UINT;
typedef long PINDEX;
#else
typedef int           INT;
typedef unsigned int  UINT;
typedef int PINDEX;
#endif

//typedef int PINDEX;
#define P_MAX_INDEX INT_MAX

inline PINDEX PABSINDEX(PINDEX idx) { return (idx < 0 ? -idx : idx)&P_MAX_INDEX; }
#define PASSERTINDEX(idx) PAssert((idx) >= 0, PInvalidArrayIndex)

///////////////////////////////////////////
//
// needed for STL
//
#define P_HAS_STL_STREAMS 1

#if P_HAS_STL_STREAMS
#define __USE_STL__     1
#endif

#define P_HAS_TYPEINFO  1

using namespace std;

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>

#include <string.h>

#ifdef __USE_STL__
#include <string>
#include <iomanip>
#include <iostream>
#if (__GNUC__ >= 3)
#include <sstream>
typedef std::ostringstream ostrstream;
#else
#include <strstream>
#endif
//using namespace std;
#else
#if (__GNUC__ >= 3)
#include <iostream>
#ifndef __MWERKS__
#include <iomanip>
#endif
#else
#include <iostream.h>
#ifdef __GNUC__
#include <strstream.h>
#else
#include <strstrea.h>
#endif
#ifndef __MWERKS__
#include <iomanip.h>
#endif
#endif
#endif

#if (__GNUC__ < 3)
typedef long _Ios_Fmtflags;
#endif

#if _MSC_VER<1300
#define _BADOFF -1
#endif

///////////////////////////////////////////////////////////////////////////////
// Disable inlines when debugging for faster compiles (the compiler doesn't
// actually inline the function with debug on any way).
#ifdef DEBUG
#ifndef _DEBUG
#define _DEBUG 1
#endif
#endif
#ifndef P_USE_INLINES
#ifdef _DEBUG
#define P_USE_INLINES 0
#else
#define P_USE_INLINES 0
#endif
#endif

#if P_USE_INLINES
#define PINLINE inline
#else
#define PINLINE
#endif


///////////////////////////////////////////////////////////////////////////////
// Declare the debugging support
#ifndef P_USE_ASSERTS
#define P_USE_ASSERTS 1
#endif

#if !P_USE_ASSERTS

#define PAssert(b, m) (b)
#define PAssert2(b, c, m) (b)
#define PAssertOS(b) (b)
#define PAssertNULL(p) (p)
#define PAssertAlways(m)
#define PAssertAlways2(c, m)


#else // P_USE_ASSERTS

/// Standard assert messages for the PAssert macro.
enum PStandardAssertMessage {
    PLogicError,              // A logic error occurred.
    POutOfMemory,             // A new or malloc failed.
    PNullPointerReference,    // A reference was made through a NULL pointer.
    PInvalidCast,             // An invalid cast to descendant is required.
    PInvalidArrayIndex,       // An index into an array was negative.
    PInvalidArrayElement,     // A NULL array element object was accessed.
    PStackEmpty,              // A Pop() was made of a stack with no elements.
    PUnimplementedFunction,   // Funtion is not implemented.
    PInvalidParameter,        // Invalid parameter was passed to a function.
    POperatingSystemError,    // Error was returned by Operating System.
    PChannelNotOpen,          // Operation attempted when channel not open.
    PUnsupportedFeature,      // Feature is not supported.
    PInvalidWindow,           // Access through invalid window.
    PMaxStandardAssertMessage
};

#define __CLASS__ NULL

void PAssertFunc(const char * file, int line, const char * className, PStandardAssertMessage msg);
void PAssertFunc(const char * file, int line, const char * className, const char * msg);
void PAssertFunc(const char * full_msg);

inline bool PAssertFuncInline(bool b, const char * file, int line, const char * className, PStandardAssertMessage msg)
{
    if (!b)
        PAssertFunc(file, line, className, msg);
    return b;
}
inline bool PAssertFuncInline(bool b, const char * file, int line, const char * className, const char * msg)
{
    if (!b)
        PAssertFunc(file, line, className, msg);
    return b;
}

/** This macro is used to assert that a condition must be TRUE.
 If the condition is FALSE then an assert function is called with the source
 file and line number the macro was instantiated on, plus the message described
 by the #msg# parameter. This parameter may be either a standard value
 from the #PStandardAssertMessage# enum or a literal string.
 */
#define PAssert(b, m) PAssertFuncInline((b), __FILE__,__LINE__,__CLASS__,(m))

/** This macro is used to assert that a condition must be TRUE.
 If the condition is FALSE then an assert function is called with the source
 file and line number the macro was instantiated on, plus the message described
 by the #msg# parameter. This parameter may be either a standard value
 from the #PStandardAssertMessage# enum or a literal string.
 The #c# parameter specifies the class name that the error occurred in
 */
#define PAssert2(b, c, m) PAssertFuncInline((b), __FILE__,__LINE__,(c),(m))

/** This macro is used to assert that an operating system call succeeds.
 If the condition is FALSE then an assert function is called with the source
 file and line number the macro was instantiated on, plus the message
 described by the #POperatingSystemError# value in the #PStandardAssertMessage#
 enum.
 */
#define PAssertOS(b) PAssertFuncInline((b), __FILE__,__LINE__,__CLASS__,POperatingSystemError)

/** This macro is used to assert that a pointer must be non-null.
 If the pointer is NULL then an assert function is called with the source file
 and line number the macro was instantiated on, plus the message described by
 the PNullPointerReference value in the #PStandardAssertMessage# enum.
 
 Note that this evaluates the expression defined by #ptr# twice. To
 prevent incorrect behaviour with this, the macro will assume that the
 #ptr# parameter is an L-Value.
 */
#define PAssertNULL(p) ((&(p)&&(p)!=NULL)?(p): \
(PAssertFunc(__FILE__,__LINE__, __CLASS__, PNullPointerReference),(p)))

/** This macro is used to assert immediately.
 The assert function is called with the source file and line number the macro
 was instantiated on, plus the message described by the #msg# parameter. This
 parameter may be either a standard value from the #PStandardAssertMessage#
 enum or a literal string.
 */
#define PAssertAlways(m) PAssertFunc(__FILE__,__LINE__,__CLASS__,(m))

/** This macro is used to assert immediately.
 The assert function is called with the source file and line number the macro
 was instantiated on, plus the message described by the #msg# parameter. This
 parameter may be either a standard value from the #PStandardAssertMessage#
 enum or a literal string.
 */
#define PAssertAlways2(c, m) PAssertFunc(__FILE__,__LINE__,(c),(m))

#endif // P_USE_ASSERTS


/** Get the stream being used for error output.
 This stream is used for all trace output using the various trace functions
 and macros.
 */
ostream & PGetErrorStream();

/** Set the stream to be used for error output.
 This stream is used for all error output using the #PError# macro.
 */
void PSetErrorStream(ostream * strm /** New stream for error output */ );

/** This macro is used to access the platform specific error output stream.
 This is to be used in preference to assuming #cerr# is always available. On
 Unix platforms this {\bfis} #cerr# but for MS-Windows this is another stream
 that uses the OutputDebugString() Windows API function. Note that a MS-DOS or
 Windows NT console application would still use #cerr#.
 
 The #PError# stream would normally only be used for debugging information as
 a suitable display is not always available in windowed environments.
 
 The macro is a wrapper for a global variable #PErrorStream# which is a pointer
 to an #ostream#. The variable is initialised to #cerr# for all but MS-Windows
 and NT GUI applications. An application could change this pointer to a
 #ofstream# variable of #PError# output is wished to be redirected to a file.
 */
#define PError (PGetErrorStream())



///////////////////////////////////////////////////////////////////////////////
// Debug and tracing

#ifndef PTRACING
#ifndef _DEBUG
#define PTRACING 0
#else
#define PTRACING 1
#endif
#endif

/**Class to encapsulate tracing functions.
 This class does not require any instances and is only being used as a
 method of grouping functions together in a name space.
 */
class PTrace
{
public:
    /// Options for trace output.
    enum Options {
        /**Include PTrace::Block constructs in output
         If this is bit is clear, all PTrace::Block output is inhibited
         regardless of the trace level. If set, the PTrace::Block may occur
         provided the trace level is greater than zero.
         */
        Blocks = 1,
        /// Include date and time in all output
        DateAndTime = 2,
        /// Include (millisecond) timestamp in all output
        Timestamp = 4,
        /// Include identifier for thread trace is made from in all output
        Thread = 8,
        /// Include trace level in all output
        TraceLevel = 16,
        /// Include the file and line for the trace call in all output
        FileAndLine = 32,
        /// Include thread object pointer address in all trace output
        ThreadAddress = 64,
        /// Append to log file rather than resetting every time
        AppendToFile = 128,
        /** Output timestamps in GMT time rather than local time
         */
        GMTTime = 256,
        /** If set, log file will be rotated daily
         */
        RotateDaily = 512,
        /** SystemLog flag for tracing within a PServiceProcess application. Must
         be set in conjection with SetStream(new PSystemLog).
         */
        SystemLogStream = 32768
    };
    
    /**Set the most common trace options.
     If filename is not NULL then a PTextFile is created and attached the
     trace output stream. This object is never closed or deleted until the
     termination of the program.
     
     A trace output of the program name version and OS is written as well.
     */
    static void Initialise(
                           unsigned level,
                           const char * filename = NULL,
                           unsigned options = Timestamp | Thread | Blocks
                           );
    
    /** Set the trace options.
     The PTRACE(), PTRACE_BLOCK() and PTRACE_LINE() macros output trace text that
     may contain assorted values. These are defined by the Options enum.
     
     Note this function OR's the bits included in the options parameter.
     */
    static void SetOptions(unsigned options /** New level for trace */ );
    
    /** Clear the trace options.
     The PTRACE(), PTRACE_BLOCK() and PTRACE_LINE() macros output trace text that
     may contain assorted values. These are defined by the Options enum.
     
     Note this function AND's the complement of the bits included in the options
     parameter.
     */
    static void ClearOptions(unsigned options /** New level for trace */ );
    
    /** Get the current trace options.
     The PTRACE(), PTRACE_BLOCK() and PTRACE_LINE() macros output trace text that
     may contain assorted values. These are defined by the Options enum.
     */
    static unsigned GetOptions();
    
    /** Set the trace level.
     The PTRACE() macro checks to see if its level is equal to or lower then the
     level set by this function. If so then the trace text is output to the trace
     stream.
     */
    static void SetLevel(unsigned level /** New level for trace */ );
    
    /** Get the trace level.
     The PTRACE() macro checks to see if its level is equal to or lower then the
     level set by this function. If so then the trace text is output to the trace
     stream.
     */
    static unsigned GetLevel();
    
    /** Determine if the level may cause trace output.
     This checks against the current global trace level set by #PSetTraceLevel#
     for if the trace output may be emitted. This is used by the PTRACE macro.
     */
    static PBOOL CanTrace(unsigned level /** Trace level to check */);
    
    /** Set the stream to be used for trace output.
     This stream is used for all trace output using the various trace functions
     and macros.
     */
    static void SetStream(ostream * out /** New output stream from trace. */ );
    
    /** Begin a trace output.
     If the trace stream output is used outside of the provided macros, it
     should be noted that a mutex is obtained on the call to #PBeginTrace# which
     will prevent any other threads from using the trace stream until the
     #PEndTrace# function is called.
     
     So a typical usage would be:
     \begin{verbatim}
     ostream & s = PTrace::Begin(3, __FILE__, __LINE__);
     s << "hello";
     if (want_there)
     s << " there";
     s << '!' << PTrace::End();
     \end{verbatim}
     */
    static ostream & Begin(
                           unsigned level,         ///< Log level for output
                           const char * fileName,  ///< Filename of source file being traced
                           int lineNum             ///< Line number of source file being traced.
    );
    
    /** End a trace output.
     If the trace stream output is used outside of the provided macros, the
     #PEndTrace# function must be used at the end of the section of trace
     output. A mutex is obtained on the call to #PBeginTrace# which will prevent
     any other threads from using the trace stream until the PEndTrace. The
     #PEndTrace# is used in a similar manner to #::endl# or #::flush#.
     
     So a typical usage would be:
     \begin{verbatim}
     ostream & s = PTrace::Begin();
     s << "hello";
     if (want_there)
     s << " there";
     s << '!' << PTrace::End();
     \end{verbatim}
     */
    static ostream & End(ostream & strm /** Trace output stream being completed */);
    
    
    /** Class to trace Execution blocks.
     This class is used for tracing the entry and exit of program blocks. Upon
     construction it outputs an entry trace message and on destruction outputs an
     exit trace message. This is normally only used from in the PTRACE_BLOCK macro.
     */
    class Block {
    public:
        /** Output entry trace message. */
        Block(
              const char * fileName, ///< Filename of source file being traced
              int lineNum,           ///< Line number of source file being traced.
              const char * traceName
        ///< String to be output with trace, typically it is the function name.
        );
        /// Output exit trace message.
        ~Block();
    private:
        const char * file;
        int          line;
        const char * name;
    };
};

#if !PTRACING

#define PTRACE_PARAM(param)
#define PTRACE_BLOCK(n)
#define PTRACE_LINE()
#define PTRACE(level, arg)
#define PTRACE_IF(level, cond, args)

#else

/* Macro to conditionally declare a parameter to a function to avoid compiler
 warning due that parameter only being used in a PTRACE */
#define PTRACE_PARAM(param) param

/** Trace an execution block.
 This macro creates a trace variable for tracking the entry and exit of program
 blocks. It creates an instance of the PTraceBlock class that will output a
 trace message at the line PTRACE_BLOCK is called and then on exit from the
 scope it is defined in.
 */
#define PTRACE_BLOCK(name) PTrace::Block __trace_block_instance(__FILE__, __LINE__, name)

/** Trace the execution of a line.
 This macro outputs a trace of a source file line execution.
 */
#define PTRACE_LINE() \
if (!PTrace::CanTrace(1)) ; else \
PTrace::Begin(1, __FILE__, __LINE__) << __FILE__ << '(' << __LINE__ << ')' << PTrace::End

/** Output trace.
 This macro outputs a trace of any information needed, using standard stream
 output operators. The output is only made if the trace level set by the
 #PSetTraceLevel# function is greater than or equal to the #level# argument.
 */
#define PTRACE(level, args) \
if (!PTrace::CanTrace(level)) ; else \
PTrace::Begin(level, __FILE__, __LINE__) << args << PTrace::End

/** Output trace on condition.
 This macro outputs a trace of any information needed, using standard stream
 output operators. The output is only made if the trace level set by the
 #PSetTraceLevel# function is greater than or equal to the #level# argument
 and the conditional is TRUE. Note the conditional is only evaluated if the
 trace level is sufficient.
 */
#define PTRACE_IF(level, cond, args) \
if (!(PTrace::CanTrace(level)  && (cond))) ; else \
PTrace::Begin(level, __FILE__, __LINE__) << args << PTrace::End

#endif

#if PMEMORY_CHECK

/** Memory heap checking class.
 This class implements the memory heap checking and validation functions. It
 maintains lists of allocated block so that memory leaks can be detected. It
 also initialises memory on allocation and deallocation to help catch errors
 involving the use of dangling pointers.
 */
class PMemoryHeap {
protected:
    /// Initialise the memory checking subsystem.
    PMemoryHeap();
    
public:
    // Clear up the memory checking subsystem, dumping memory leaks.
    ~PMemoryHeap();
    
    /** Allocate a memory block.
     This allocates a new memory block and keeps track of it. The memory
     block is filled with the value in the #allocFillChar# member variable
     to help detect uninitialised structures.
     @return pointer to newly allocated memory block.
     */
    static void * Allocate(
                           size_t nSize,           ///< Number of bytes to allocate.
                           const char * file,      ///< Source file name for allocating function.
                           int line,               ///< Source file line for allocating function.
                           const char * className  ///< Class name for allocating function.
                           );
    /** Allocate a memory block.
     This allocates a new memory block and keeps track of it. The memory
     block is filled with the value in the #allocFillChar# member variable
     to help detect uninitialised structures.
     @return pointer to newly allocated memory block.
     */
    static void * Allocate(
                           size_t count,       ///< Number of items to allocate.
                           size_t iSize,       ///< Size in bytes of each item.
                           const char * file,  ///< Source file name for allocating function.
                           int line            ///< Source file line for allocating function.
                           );
    
    /** Change the size of an allocated memory block.
     This allocates a new memory block and keeps track of it. The memory
     block is filled with the value in the #allocFillChar# member variable
     to help detect uninitialised structures.
     @return pointer to reallocated memory block. Note this may
     {\em not} be the same as the pointer passed into the function.
     */
    static void * Reallocate(
                             void * ptr,         ///< Pointer to memory block to reallocate.
                             size_t nSize,       ///< New number of bytes to allocate.
                             const char * file,  ///< Source file name for allocating function.
                             int line            ///< Source file line for allocating function.
                             );
    
    /** Free a memory block.
     The memory is deallocated, a warning is displayed if it was never
     allocated. The block of memory is filled with the value in the
     #freeFillChar# member variable.
     */
    static void Deallocate(
                           void * ptr,             ///< Pointer to memory block to deallocate.
                           const char * className  ///< Class name for deallocating function.
                           );
    
    /** Validation result.
     */
    enum Validation {
        Ok, Bad, Trashed
    };
    /** Validate the memory pointer.
     The #ptr# parameter is validated as a currently allocated heap
     variable.
     @return Ok for pointer is in heap, Bad for pointer is not in the heap
     or Trashed if the pointer is in the heap but has overwritten the guard
     bytes before or after the actual data part of the memory block.
     */
    static Validation Validate(
                               void * ptr,             ///< Pointer to memory block to check
                               const char * className, ///< Class name it should be.
                               ostream * error         ///< Stream to receive error message (may be NULL)
                               );
    
    /** Validate all objects in memory.
     This effectively calls Validate() on every object in the heap.
     @return TRUE if every object in heap is Ok.
     */
    static PBOOL ValidateHeap(
                             ostream * error = NULL  ///< Stream to output, use default if NULL
                             );
    
    /** Ignore/Monitor allocations.
     Set internal flag so that allocations are not included in the memory
     leak check on program termination.
     Returns the previous state.
     */
    static PBOOL SetIgnoreAllocations(
                                     PBOOL ignore  ///< New flag for allocation ignoring.
                                     );
    
    /** Get memory check system statistics.
     Dump statistics output to the default stream.
     */
    static void DumpStatistics();
    /** Get memory check system statistics.
     Dump statistics output to the specified stream.
     */
    static void DumpStatistics(ostream & strm /** Stream to output to */);
    
    /* Get number of allocation.
     Each allocation is counted and if desired the next allocation request
     number may be obtained via this function.
     @return Allocation request number.
     */
    static DWORD GetAllocationRequest();
    
    /** Dump allocated objects.
     Dump ojects allocated and not deallocated since the specified object
     number. This would be a value returned by the #GetAllocationRequest()#
     function.
     
     Output is to the default stream.
     */
    static void DumpObjectsSince(
                                 DWORD objectNumber    ///< Memory object to begin dump from.
                                 );
    
    /** Dump allocated objects.
     Dump ojects allocated and not deallocated since the specified object
     number. This would be a value returned by the #GetAllocationRequest()#
     function.
     */
    static void DumpObjectsSince(
                                 DWORD objectNumber,   ///< Memory object to begin dump from.
                                 ostream & strm        ///< Stream to output dump
                                 );
    
    /** Set break point allocation number.
     Set the allocation request number to cause an assert. This allows a
     developer to cause a halt in a debugger on a certain allocation allowing
     them to determine memory leaks allocation point.
     */
    static void SetAllocationBreakpoint(
                                        DWORD point   ///< Allocation number to stop at.
                                        );
    
protected:
    void * InternalAllocate(
                            size_t nSize,           // Number of bytes to allocate.
                            const char * file,      // Source file name for allocating function.
                            int line,               // Source file line for allocating function.
                            const char * className  // Class name for allocating function.
                            );
    Validation InternalValidate(
                                void * ptr,             // Pointer to memory block to check
                                const char * className, // Class name it should be.
                                ostream * error         // Stream to receive error message (may be NULL)
                                );
    void InternalDumpStatistics(ostream & strm);
    void InternalDumpObjectsSince(DWORD objectNumber, ostream & strm);
    
    class Wrapper {
    public:
        Wrapper();
        ~Wrapper();
        PMemoryHeap * operator->() const { return instance; }
    private:
        PMemoryHeap * instance;
    };
    friend class Wrapper;
    
    enum Flags {
        NoLeakPrint = 1
    };
    
#pragma pack(1)
    struct Header {
        enum {
            // Assure that the Header struct is aligned to 8 byte boundary
            NumGuardBytes = 16 - (sizeof(Header *) +
                                  sizeof(Header *) +
                                  sizeof(const char *) +
                                  sizeof(const char *) +
                                  sizeof(size_t) +
                                  sizeof(DWORD) +
                                  sizeof(WORD) +
                                  sizeof(BYTE))%8
        };
        
        Header     * prev;
        Header     * next;
        const char * className;
        const char * fileName;
        size_t       size;
        DWORD        request;
        WORD         line;
        BYTE         flags;
        char         guard[NumGuardBytes];
        
        static char GuardBytes[NumGuardBytes];
    };
#pragma pack()
    
    PBOOL isDestroyed;
    
    Header * listHead;
    Header * listTail;
    
    static DWORD allocationBreakpoint;
    DWORD allocationRequest;
    DWORD firstRealObject;
    BYTE  flags;
    
    char  allocFillChar;
    char  freeFillChar;
    
    DWORD currentMemoryUsage;
    DWORD peakMemoryUsage;
    DWORD currentObjects;
    DWORD peakObjects;
    DWORD totalObjects;
    
    ostream * leakDumpStream;
    
#if defined(P_PTHREADS)
    pthread_mutex_t mutex;
#endif
};


/** Allocate memory for the run time library.
 This version of free is used for data that is not to be allocated using the
 memory check system, ie will be free'ed inside the C run time library.
 */
inline void * runtime_malloc(size_t bytes /** Size of block to allocate */ ) { return malloc(bytes); }

/** Free memory allocated by run time library.
 This version of free is used for data that is not allocated using the
 memory check system, ie was malloc'ed inside the C run time library.
 */
inline void runtime_free(void * ptr /** Memory block to free */ ) { free(ptr); }


/** Override of system call for memory check system.
 This macro is used to allocate memory via the memory check system selected
 with the #PMEMORY_CHECK# compile time option. It will include the source file
 and line into the memory allocation to allow the PMemoryHeap class to keep
 track of the memory block.
 */
#define malloc(s) PMemoryHeap::Allocate(s, __FILE__, __LINE__, NULL)

/** Override of system call for memory check system.
 This macro is used to allocate memory via the memory check system selected
 with the #PMEMORY_CHECK# compile time option. It will include the source file
 and line into the memory allocation to allow the PMemoryHeap class to keep
 track of the memory block.
 */
#define calloc(n,s) PMemoryHeap::Allocate(n, s, __FILE__, __LINE__)

/** Override of system call for memory check system.
 This macro is used to allocate memory via the memory check system selected
 with the #PMEMORY_CHECK# compile time option. It will include the source file
 and line into the memory allocation to allow the PMemoryHeap class to keep
 track of the memory block.
 */
#define realloc(p,s) PMemoryHeap::Reallocate(p, s, __FILE__, __LINE__)


/** Override of system call for memory check system.
 This macro is used to deallocate memory via the memory check system selected
 with the #PMEMORY_CHECK# compile time option. It will include the source file
 and line into the memory allocation to allow the PMemoryHeap class to keep
 track of the memory block.
 */
#define free(p) PMemoryHeap::Deallocate(p, NULL)


/** Override of system call for memory check system.
 This macro is used to deallocate memory via the memory check system selected
 with the #PMEMORY_CHECK# compile time option. It will include the source file
 and line into the memory allocation to allow the PMemoryHeap class to keep
 track of the memory block.
 */
#define cfree(p) PMemoryHeap::Deallocate(p, NULL)


/** Macro for overriding system default #new# operator.
 This macro is used to allocate memory via the memory check system selected
 with the PMEMORY_CHECK compile time option. It will include the source file
 and line into the memory allocation to allow the PMemoryHeap class to keep
 track of the memory block.
 
 This macro could be used instead of the system #new# operator. Or you can place
 the line
 \begin{verbatim}
 #define new PNEW
 \end{verbatim}
 at the begining of the source file, after all declarations that use the
 PCLASSINFO macro.
 */
#define PNEW  new (__FILE__, __LINE__)

#if !defined(_MSC_VER) || _MSC_VER<1200
#define PSPECIAL_DELETE_FUNCTION
#else
#define PSPECIAL_DELETE_FUNCTION \
void operator delete(void * ptr, const char *, int) \
{ PMemoryHeap::Deallocate(ptr, Class()); } \
void operator delete[](void * ptr, const char *, int) \
{ PMemoryHeap::Deallocate(ptr, Class()); }
#endif

#define PNEW_AND_DELETE_FUNCTIONS \
void * operator new(size_t nSize, const char * file, int line) \
{ return PMemoryHeap::Allocate(nSize, file, line, Class()); } \
void * operator new(size_t nSize) \
{ return PMemoryHeap::Allocate(nSize, NULL, 0, Class()); } \
void operator delete(void * ptr) \
{ PMemoryHeap::Deallocate(ptr, Class()); } \
void * operator new[](size_t nSize, const char * file, int line) \
{ return PMemoryHeap::Allocate(nSize, file, line, Class()); } \
void * operator new[](size_t nSize) \
{ return PMemoryHeap::Allocate(nSize, NULL, 0, Class()); } \
void operator delete[](void * ptr) \
{ PMemoryHeap::Deallocate(ptr, Class()); } \
PSPECIAL_DELETE_FUNCTION


inline void * operator new(size_t nSize, const char * file, int line)
{ return PMemoryHeap::Allocate(nSize, file, line, NULL); }

inline void * operator new[](size_t nSize, const char * file, int line)
{ return PMemoryHeap::Allocate(nSize, file, line, NULL); }

#ifndef __GNUC__
void * operator new(size_t nSize);
void * operator new[](size_t nSize);

void operator delete(void * ptr);
void operator delete[](void * ptr);

#if defined(_MSC_VER) && _MSC_VER>=1200
inline void operator delete(void * ptr, const char *, int)
{ PMemoryHeap::Deallocate(ptr, NULL); }

inline void operator delete[](void * ptr, const char *, int)
{ PMemoryHeap::Deallocate(ptr, NULL); }
#endif
#endif


#else // PMEMORY_CHECK
#define PNEW new
#if 0
#if defined(__GNUC__)

#define PNEW_AND_DELETE_FUNCTIONS

#else

#define PNEW_AND_DELETE_FUNCTIONS \
void * operator new(size_t nSize) \
{ return malloc(nSize); } \
void operator delete(void * ptr) \
{ free(ptr); } \
void * operator new[](size_t nSize) \
{ return malloc(nSize); } \
void operator delete[](void * ptr) \
{ free(ptr); }

void * operator new(size_t nSize);
void * operator new[](size_t nSize);

void operator delete(void * ptr);
void operator delete[](void * ptr);

#endif


#define runtime_malloc(s) malloc(s)
#define runtime_free(p) free(p)
#endif
#endif // PMEMORY_CHECK



#if P_HAS_TYPEINFO

#define PIsDescendant(ptr, cls)    (dynamic_cast<const cls *>(ptr) != NULL)
#define PIsDescendantStr(ptr, str) ((ptr)->InternalIsDescendant(str))

#define PRemoveConst(cls, ptr)  (const_cast<cls*>(ptr))

#if P_USE_ASSERTS
template<class BaseClass> inline BaseClass * PAssertCast(BaseClass * obj, const char * file, int line)
{ if (obj == NULL) PAssertFunc(file, line, BaseClass::Class(), PInvalidCast); return obj; }
#define PDownCast(cls, ptr) PAssertCast<cls>(dynamic_cast<cls*>(ptr),__FILE__,__LINE__)
#else
#define PDownCast(cls, ptr) (dynamic_cast<cls*>(ptr))
#endif

#include <typeinfo>

#define   PCLASSNAME(cls) (#cls)

#define PBASECLASSINFO(cls, par) \
public: \
static inline const char * Class() \
{ return PCLASSNAME(cls); } \
virtual PBOOL InternalIsDescendant(const char * clsName) const \
{ return strcmp(clsName, PCLASSNAME(cls)) == 0 || par::InternalIsDescendant(clsName); } \

#else // P_HAS_TYPEINFO

#define PIsDescendant(ptr, cls)    ((ptr)->InternalIsDescendant(cls::Class()))
#define PIsDescendantStr(ptr, str) ((ptr)->InternalIsDescendant(str))

#define PRemoveConst(cls, ptr)  ((cls*)(ptr))

#if P_USE_ASSERTS
template<class BaseClass> inline BaseClass * PAssertCast(PObject * obj, const char * file, int line)
{ if (obj->InternalIsDescendant(BaseClass::Class()) return (BaseClass *)obj; PAssertFunc(file, line, BaseClass::Class(), PInvalidCast); return NULL; }
#define PDownCast(cls, ptr) PAssertCast<cls>((ptr),__FILE__,__LINE__)
#else
#define PDownCast(cls, ptr) ((cls*)(ptr))
#endif
      
#define PBASECLASSINFO(cls, par) \
      public: \
      static const char * Class() \
      { return #cls; } \
      virtual PBOOL InternalIsDescendant(const char * clsName) const \
      { return strcmp(clsName, cls::Class()) == 0 || par::InternalIsDescendant(clsName); } \
      
#endif // P_HAS_TYPEINFO
      
      
#define PCLASSINFO(cls, par) \
      PBASECLASSINFO(cls, par) \
      virtual const char * GetClass(unsigned ancestor = 0) const \
      { return ancestor > 0 ? par::GetClass(ancestor-1) : cls::Class(); } \
      virtual Comparison CompareObjectMemoryDirect(const PObject & obj) const \
      { return (Comparison)memcmp(this, &obj, sizeof(cls)); } \
      
/** Declare a class with PWLib class information.
 This macro is used to declare a new class with a single public ancestor. It
 starts the class declaration and then uses the #PCLASSINFO# macro to
 get all the run-time type functions.
 
 The use of this macro is no longer recommended for reasons of compatibility
 with documentation systems.
 */
#define PDECLARE_CLASS(cls, par) class cls : public par { PCLASSINFO(cls, par)
      
      ///////////////////////////////////////////////////////////////////////////////
      // The root of all evil ... umm classes
      
/** Ultimate parent class for all objects in the class library.
 This provides functionality provided to all classes, eg run-time types,
 default comparison operations, simple stream I/O and serialisation support.
 */
      class PObject {
          
      protected:
          /** Constructor for PObject, make protected so cannot ever create one on
           its own.
           */
          PObject() { }
          
      public:
          /* Destructor required to get the "virtual". A PObject really has nothing
           to destroy.
           */
          virtual ~PObject() { }
          
          /**@name Run Time Type functions */
          //@{
          /** Get the name of the class as a C string. This is a static function which
           returns the type of a specific class.
           
           When comparing class names, always use the #strcmp()#
           function rather than comparing pointers. The pointers are not
           necessarily the same over compilation units depending on the compiler,
           platform etc.
           
           @return pointer to C string literal.
           */
          static inline const char * Class()    { return PCLASSNAME(PObject); }
          
          /** Get the current dynamic type of the object instance.
           
           When comparing class names, always use the #strcmp()#
           function rather than comparing pointers. The pointers are not
           necessarily the same over compilation units depending on the compiler,
           platform etc.
           
           The #PCLASSINFO# macro declares an override of this function for
           the particular class. The user need not implement it.
           
           @return pointer to C string literal.
           */
          virtual const char * GetClass(unsigned /*ancestor*/ = 0) const { return Class(); }
          
          PBOOL IsClass(const char * cls) const
          { return strcmp(cls, GetClass()) == 0; }
          
          /** Determine if the dynamic type of the current instance is a descendent of
           the specified class. The class name is usually provided by the
           #Class()# static function of the desired class.
           
           The #PCLASSINFO# macro declares an override of this function for
           the particular class. The user need not implement it.
           
           @return TRUE if object is descended from the class.
           */
          virtual PBOOL InternalIsDescendant(
                                            const char * clsName    // Ancestor class name to compare against.
                                            ) const
          { return IsClass(clsName); }
          
          //@}
          
          /**@name Comparison functions */
          //@{
          /** Result of the comparison operation performed by the #Compare()#
           function.
           */
          enum Comparison {
              LessThan = -1,
              EqualTo = 0,
              GreaterThan = 1
          };
          
          /** Compare the two objects and return their relative rank. This function is
           usually overridden by descendent classes to yield the ranking according
           to the semantics of the object.
           
           The default function is to use the #CompareObjectMemoryDirect()#
           function to do a byte wise memory comparison of the two objects.
           
           @return
           #LessThan#, #EqualTo# or #GreaterThan#
           according to the relative rank of the objects.
           */
          virtual Comparison Compare(
                                     const PObject & obj   // Object to compare against.
                                     ) const;
          
          /** Determine the byte wise comparison of two objects. This is the default
           comparison operation for objects that do not explicitly override the
           #Compare()# function.
           
           The #PCLASSINFO# macro declares an override of this function for
           the particular class. The user need not implement it.
           
           @return
           #LessThan#, #EqualTo# or #GreaterThan#
           according to the result #memcpy()# function.
           */
          virtual Comparison CompareObjectMemoryDirect(
                                                       const PObject & obj   // Object to compare against.
                                                       ) const;
          
          /** Compare the two objects.
           
           @return
           TRUE if objects are equal.
           */
          bool operator==(
                          const PObject & obj   // Object to compare against.
                          ) const { return Compare(obj) == EqualTo; }
          
          /** Compare the two objects.
           
           @return
           TRUE if objects are not equal.
           */
          bool operator!=(
                          const PObject & obj   // Object to compare against.
                          ) const { return Compare(obj) != EqualTo; }
          
          /** Compare the two objects.
           
           @return
           TRUE if objects are less than.
           */
          bool operator<(
                         const PObject & obj   // Object to compare against.
                         ) const { return Compare(obj) == LessThan; }
          
          /** Compare the two objects.
           
           @return
           TRUE if objects are greater than.
           */
          bool operator>(
                         const PObject & obj   // Object to compare against.
                         ) const { return Compare(obj) == GreaterThan; }
          
          /** Compare the two objects.
           
           @return
           TRUE if objects are less than or equal.
           */
          bool operator<=(
                          const PObject & obj   // Object to compare against.
                          ) const { return Compare(obj) != GreaterThan; }
          
          /** Compare the two objects.
           
           @return
           TRUE if objects are greater than or equal.
           */
          bool operator>=(
                          const PObject & obj   // Object to compare against.
                          ) const { return Compare(obj) != LessThan; }
          //@}
          
          /**@name I/O functions */
          //@{
          /** Output the contents of the object to the stream. The exact output is
           dependent on the exact semantics of the descendent class. This is
           primarily used by the standard #operator<<# function.
           
           The default behaviour is to print the class name.
           */
          virtual void PrintOn(
                               ostream &strm   // Stream to print the object into.
                               ) const;
          
          /** Input the contents of the object from the stream. The exact input is
           dependent on the exact semantics of the descendent class. This is
           primarily used by the standard #operator>># function.
           
           The default behaviour is to do nothing.
           */
          virtual void ReadFrom(
                                istream &strm   // Stream to read the objects contents from.
                                );
          
          
          /** Global function for using the standard << operator on objects descended
           from PObject. This simply calls the objects #PrintOn()# function.
           
           @return the #strm# parameter.
           */
          inline friend ostream & operator<<(
                                             ostream &strm,       // Stream to print the object into.
                                             const PObject & obj  // Object to print to the stream.
                                             ) { obj.PrintOn(strm); return strm; }
          
          /** Global function for using the standard >> operator on objects descended
           from PObject. This simply calls the objects #ReadFrom()# function.
           
           @return the #strm# parameter.
           */
          inline friend istream & operator>>(
                                             istream &strm,   // Stream to read the objects contents from.
                                             PObject & obj    // Object to read inormation into.
                                             ) { obj.ReadFrom(strm); return strm; }
          
          
          /**@name Miscellaneous functions */
          //@{
          /** Create a copy of the class on the heap. The exact semantics of the
           descendent class determine what is required to make a duplicate of the
           instance. Not all classes can even {\bf do} a clone operation.
           
           The main user of the clone function is the #PDictionary# class as
           it requires copies of the dictionary keys.
           
           The default behaviour is for this function to assert.
           
           @return
           pointer to new copy of the class instance.
           */
          virtual PObject * Clone() const;
          
          /** This function yields a hash value required by the #PDictionary#
           class. A descendent class that is required to be the key of a dictionary
           should override this function. The precise values returned is dependent
           on the semantics of the class. For example, the #PString# class
           overrides it to provide a hash function for distinguishing text strings.
           
           The default behaviour is to return the value zero.
           
           @return
           hash function value for class instance.
           */
          virtual PINDEX HashFunction() const;
          //@}
      };
      
      ///////////////////////////////////////////////////////////////////////////////
      // Platform independent types
      
      // All these classes encapsulate primitive types such that they may be
      // transfered in a platform independent manner. In particular it is used to
      // do byte swapping for little endien and big endien processor architectures
      // as well as accommodating structure packing rules for memory structures.
      
#define PANSI_CHAR 1
#define PLITTLE_ENDIAN 2
#define PBIG_ENDIAN 3
      
#define PI_SAME(name, type) \
      struct name { \
          name() { } \
          name(type value) { data = value; } \
          name(const name & value) { data = value.data; } \
          name & operator =(type value) { data = value; return *this; } \
          name & operator =(const name & value) { data = value.data; return *this; } \
          operator type() const { return data; } \
          friend ostream & operator<<(ostream & s, const name & v) { return s << v.data; } \
          friend istream & operator>>(istream & s, name & v) { return s >> v.data; } \
      private: type data; \
      }
      
#define PI_LOOP(src, dst) \
      BYTE *s = ((BYTE *)&src)+sizeof(src); BYTE *d = (BYTE *)&dst; \
      while (s != (BYTE *)&src) *d++ = *--s;
      
#define PI_DIFF(name, type) \
      struct name { \
          name() { } \
          name(type value) { operator=(value); } \
          name(const name & value) { data = value.data; } \
          name & operator =(type value) { PI_LOOP(value, data); return *this; } \
          name & operator =(const name & value) { data = value.data; return *this; } \
          operator type() const { type value; PI_LOOP(data, value); return value; } \
          friend ostream & operator<<(ostream & s, const name & value) { return s << (type)value; } \
          friend istream & operator>>(istream & s, name & v) { type val; s >> val; v = val; return s; } \
      private: type data; \
      }
      
#ifndef PCHAR8
#define PCHAR8 PANSI_CHAR
#endif
      
#if PCHAR8==PANSI_CHAR
      PI_SAME(PChar8, char);
#endif
      
      PI_SAME(PInt8, signed char);
      
      PI_SAME(PUInt8, unsigned char);

#define PBYTE_ORDER PLITTLE_ENDIAN
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_SAME(PInt16l, PInt16);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_DIFF(PInt16l, PInt16);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_DIFF(PInt16b, PInt16);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_SAME(PInt16b, PInt16);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_SAME(PUInt16l, WORD);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_DIFF(PUInt16l, WORD);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_DIFF(PUInt16b, WORD);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_SAME(PUInt16b, WORD);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_SAME(PInt32l, PInt32);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_DIFF(PInt32l, PInt32);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_DIFF(PInt32b, PInt32);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_SAME(PInt32b, PInt32);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_SAME(PUInt32l, DWORD);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_DIFF(PUInt32l, DWORD);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_DIFF(PUInt32b, DWORD);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_SAME(PUInt32b, DWORD);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_SAME(PInt64l, PInt64);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_DIFF(PInt64l, PInt64);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_DIFF(PInt64b, PInt64);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_SAME(PInt64b, PInt64);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_SAME(PUInt64l, PUInt64);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_DIFF(PUInt64l, PUInt64);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_DIFF(PUInt64b, PUInt64);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_SAME(PUInt64b, PUInt64);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_SAME(PFloat32l, float);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_DIFF(PFloat32l, float);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_DIFF(PFloat32b, float);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_SAME(PFloat32b, float);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_SAME(PFloat64l, double);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_DIFF(PFloat64l, double);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_DIFF(PFloat64b, double);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_SAME(PFloat64b, double);
#endif
      
#ifndef NO_LONG_DOUBLE // stupid OSX compiler
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_SAME(PFloat80l, long double);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_DIFF(PFloat80l, long double);
#endif
      
#if PBYTE_ORDER==PLITTLE_ENDIAN
      PI_DIFF(PFloat80b, long double);
#elif PBYTE_ORDER==PBIG_ENDIAN
      PI_SAME(PFloat80b, long double);
#endif
#endif
    
#undef PI_LOOP
#undef PI_SAME
#undef PI_DIFF
    
    
    ///////////////////////////////////////////////////////////////////////////////
    // Miscellaneous
    
    /*$MACRO PARRAYSIZE(array)
     This macro is used to calculate the number of array elements in a static
     array.
     */
#define PARRAYSIZE(array) ((PINDEX)(sizeof(array)/sizeof(array[0])))
    
    /*$MACRO PMIN(v1, v2)
     This macro is used to calculate the minimum of two values. As this is a
     macro the expression in #v1# or #v2# is executed
     twice so extreme care should be made in its use.
     */
#define PMIN(v1, v2) ((v1) < (v2) ? (v1) : (v2))
    
    /*$MACRO PMAX(v1, v2)
     This macro is used to calculate the maximum of two values. As this is a
     macro the expression in #v1# or #v2# is executed
     twice so extreme care should be made in its use.
     */
#define PMAX(v1, v2) ((v1) > (v2) ? (v1) : (v2))
    
    /*$MACRO PABS(val)
     This macro is used to calculate an absolute value. As this is a macro the
     expression in #val# is executed twice so extreme care should be
     made in its use.
     */
#define PABS(v) ((v) < 0 ? -(v) : (v))
    
    
#endif /* defined(__UMPStack__pobject__) */