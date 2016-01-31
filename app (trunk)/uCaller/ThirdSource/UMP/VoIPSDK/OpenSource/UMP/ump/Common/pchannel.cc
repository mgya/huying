//
//  pchannel.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "pchannel.h"

#include "ptimer.h"


///////////////////////////////////////////////////////////////////////////////
// PChannel

PChannelStreamBuffer::PChannelStreamBuffer(PChannel * chan)
: channel(PAssertNULL(chan))
{
}


PBOOL PChannelStreamBuffer::SetBufferSize(PINDEX newSize)
{
    return input.SetSize(newSize) && output.SetSize(newSize);
}


int PChannelStreamBuffer::overflow(int c)
{
    if (pbase() == NULL) {
        char * p = output.GetPointer(1024);
        setp(p, p+output.GetSize());
    }
    
    int bufSize = pptr() - pbase();
    if (bufSize > 0) {
        setp(pbase(), epptr());
        if (!channel->Write(pbase(), bufSize))
            return EOF;
    }
    
    if (c != EOF) {
        *pptr() = (char)c;
        pbump(1);
    }
    
    return 0;
}


int PChannelStreamBuffer::underflow()
{
    if (eback() == NULL) {
        char * p = input.GetPointer(1024);
        char * e = p+input.GetSize();
        setg(p, e, e);
    }
    
    if (gptr() != egptr())
        return (BYTE)*gptr();
    
    if (!channel->Read(eback(), egptr() - eback()) ||
        channel->GetErrorCode() != PChannel::NoError)
        return EOF;
    
    PINDEX count = channel->GetLastReadCount();
    char * p = egptr() - count;
    memmove(p, eback(), count);
    setg(eback(), p, egptr());
    return (BYTE)*p;
}


int PChannelStreamBuffer::sync()
{
    return 0;
}


#ifdef __USE_STL__
streampos PChannelStreamBuffer::seekoff(off_type off, ios_base::seekdir dir, ios_base::openmode)
#else
streampos PChannelStreamBuffer::seekoff(streamoff off, ios::seek_dir dir, int)
#endif
{
    return egptr() - gptr();
}
//#endif

#ifdef __USE_STL__
streampos PChannelStreamBuffer::seekpos(pos_type pos, ios_base::openmode mode)
{
    return seekoff(pos, ios_base::beg, mode);
}
#endif

PChannelStreamBuffer::PChannelStreamBuffer(const PChannelStreamBuffer & sbuf)
: channel(sbuf.channel) { }

PChannelStreamBuffer &
PChannelStreamBuffer::operator=(const PChannelStreamBuffer & sbuf)
{ channel = sbuf.channel; return *this; }

PChannel::PChannel(const PChannel &) : iostream(cout.rdbuf())
{ PAssertAlways("Cannot copy channels"); }

PChannel & PChannel::operator=(const PChannel &)
{ PAssertAlways("Cannot assign channels"); return *this; }

void PChannel::SetReadTimeout(const PTimeInterval & time)
{ readTimeout = time; }

PTimeInterval PChannel::GetReadTimeout() const
{ return readTimeout; }

void PChannel::SetWriteTimeout(const PTimeInterval & time)
{ writeTimeout = time; }

PTimeInterval PChannel::GetWriteTimeout() const
{ return writeTimeout; }

int PChannel::GetHandle() const
{ return os_handle; }

PChannel::Errors PChannel::GetErrorCode(ErrorGroup group) const
{ return lastErrorCode[group]; }

int PChannel::GetErrorNumber(ErrorGroup group) const
{ return lastErrorNumber[group]; }

void PChannel::AbortCommandString()
{ abortCommandString = TRUE; }

PString PChannel::GetName() const
{ return channelName; }

#ifdef _MSC_VER
#pragma warning(disable:4355)
#endif

PChannel::PChannel()
: iostream(new PChannelStreamBuffer(this)),
readTimeout(PMaxTimeInterval), writeTimeout(PMaxTimeInterval)
{
    os_handle = -1;
    memset(lastErrorCode, 0, sizeof(lastErrorCode));
    memset(lastErrorNumber, 0, sizeof(lastErrorNumber));
    lastReadCount = lastWriteCount = 0;
    Construct();
}

#ifdef _MSC_VER
#pragma warning(default:4355)
#endif


PChannel::~PChannel()
{
    flush();
    Close();
    delete (PChannelStreamBuffer *)rdbuf();

    init(NULL);
}

PObject::Comparison PChannel::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, PChannel), PInvalidCast);
    int h1 = GetHandle();
    int h2 = ((const PChannel&)obj).GetHandle();
    if (h1 < h2)
        return LessThan;
    if (h1 > h2)
        return GreaterThan;
    return EqualTo;
}


PINDEX PChannel::HashFunction() const
{
    return GetHandle()%97;
}


PBOOL PChannel::IsOpen() const
{
	//modified by brant
	return os_handle != -1;
    //return os_handle >= 0;
}

PINDEX PChannel::GetLastReadCount() const
{
    return lastReadCount;
}

PINDEX PChannel::GetLastWriteCount() const
{
    return lastWriteCount;
}

int PChannel::ReadChar()
{
    BYTE c;
    PBOOL retVal = Read(&c, 1);
    return (retVal && lastReadCount == 1) ? c : -1;
}


int PChannel::ReadCharWithTimeout(PTimeInterval & timeout)
{
    SetReadTimeout(timeout);
    PTimeInterval startTick = PTimer::Tick();
    int c;
    if ((c = ReadChar()) < 0) // Timeout or aborted
        return -1;
    timeout -= PTimer::Tick() - startTick;
    return c;
}


PBOOL PChannel::ReadBlock(void * buf, PINDEX len)
{
    char * ptr = (char *)buf;
    PINDEX numRead = 0;
    
    while (numRead < len && Read(ptr+numRead, len - numRead))
        numRead += lastReadCount;
    
    lastReadCount = numRead;
    
    return lastReadCount == len;
}


PString PChannel::ReadString(PINDEX len)
{
    PString str;
    
    if (len == P_MAX_INDEX) {
        PINDEX l = 0;
        for (;;) {
            char * p = l + str.GetPointer(l+1000+1);
            if (!Read(p, 1000))
                break;
            l += lastReadCount;
        }
        str.SetSize(l+1);
        
        /*Need to put in a null at the end to allow for MSDOS/Win32 text files
         which returns fewer bytes than actually read as it shrinks the data into
         the removed carriage returns, so it actually changes the buffer beyond
         what it indicated. */
        str[l] = '\0';
    }
    else {
        if (!ReadBlock(str.GetPointer(len+1), len))
            return PString::Empty();
    }
    
    return str;
}


PBOOL PChannel::WriteString(const PString & str)
{
    PINDEX len = str.GetLength();
    PINDEX written = 0;
    while (written < len) {
        if (!Write((const char *)str + written, len - written)) {
            lastWriteCount += written;
            return FALSE;
        }
        written += lastWriteCount;
    }
    lastWriteCount = written;
    return TRUE;
}


PBOOL PChannel::ReadAsync(void * buf, PINDEX len)
{
    PBOOL retVal = Read(buf, len);
    OnReadComplete(buf, lastReadCount);
    return retVal;
}


void PChannel::OnReadComplete(void *, PINDEX)
{
}


PBOOL PChannel::WriteChar(int c)
{
    PAssert(c >= 0 && c < 256, PInvalidParameter);
    char buf = (char)c;
    return Write(&buf, 1);
}


PBOOL PChannel::WriteAsync(const void * buf, PINDEX len)
{
    PBOOL retVal = Write(buf, len);
    OnWriteComplete(buf, lastWriteCount);
    return retVal;
}


void PChannel::OnWriteComplete(const void *, PINDEX)
{
}


PBOOL PChannel::SetBufferSize(PINDEX newSize)
{
    return ((PChannelStreamBuffer *)rdbuf())->SetBufferSize(newSize);
}


enum {
    NextCharEndOfString = -1,
    NextCharDelay = -2,
    NextCharSend = -3,
    NextCharWait = -4
};


static int HexDigit(char c)
{
    if (!isxdigit(c))
        return 0;
    
    int hex = c - '0';
    if (hex < 10)
        return hex;
    
    hex -= 'A' - '9' - 1;
    if (hex < 16)
        return hex;
    
    return hex - ('a' - 'A');
}


static int GetNextChar(const PString & command,
                       PINDEX & pos, PTimeInterval * time = NULL)
{
    int temp;
    
    if (command[pos] == '\0')
        return NextCharEndOfString;
    
    if (command[pos] != '\\')
        return command[pos++];
    
    switch (command[++pos]) {
        case '\0' :
            return NextCharEndOfString;
            
        case 'a' : // alert (ascii value 7)
            pos++;
            return 7;
            
        case 'b' : // backspace (ascii value 8)
            pos++;
            return 8;
            
        case 'f' : // formfeed (ascii value 12)
            pos++;
            return 12;
            
        case 'n' : // newline (ascii value 10)
            pos++;
            return 10;
            
        case 'r' : // return (ascii value 13)
            pos++;
            return 13;
            
        case 't' : // horizontal tab (ascii value 9)
            pos++;
            return 9;
            
        case 'v' : // vertical tab (ascii value 11)
            pos++;
            return 11;
            
        case 'x' : // followed by hh  where nn is hex number (ascii value 0xhh)
            if (isxdigit(command[++pos])) {
                temp = HexDigit(command[pos++]);
                if (isxdigit(command[pos]))
                    temp += HexDigit(command[pos++]);
                return temp;
            }
            return command[pos];
            
        case 's' :
            pos++;
            return NextCharSend;
            
        case 'd' : // ns  delay for n seconds/milliseconds
        case 'w' :
            temp = command[pos] == 'd' ? NextCharDelay : NextCharWait;
            long milliseconds = 0;
            while (isdigit(command[++pos]))
                milliseconds = milliseconds*10 + command[pos] - '0';
            if (milliseconds <= 0)
                milliseconds = 1;
            if (command[pos] == 'm')
                pos++;
            else {
                milliseconds *= 1000;
                if (command[pos] == 's')
                    pos++;
            }
            if (time != NULL)
                *time = milliseconds;
            return temp;
    }
    
    if (command[pos] < '0' || command[pos] > '7')
        return command[pos++];
    
    // octal number
    temp = command[pos++] - '0';
    if (command[pos] < '0' || command[pos] > '7')
        return temp;
    
    temp += command[pos++] - '0';
    if (command[pos] < '0' || command[pos] > '7')
        return temp;
    
    temp += command[pos++] - '0';
    return temp;
}


PBOOL PChannel::ReceiveCommandString(int nextChar,
                                    const PString & reply, PINDEX & pos, PINDEX start)
{
    if (nextChar != GetNextChar(reply, pos)) {
        pos = start;
        return FALSE;
    }
    
    PINDEX dummyPos = pos;
    return GetNextChar(reply, dummyPos) < 0;
}


PBOOL PChannel::SendCommandString(const PString & command)
{
    abortCommandString = FALSE;
    
    int nextChar;
    PINDEX sendPosition = 0;
    PTimeInterval timeout;
    SetWriteTimeout(10000);
    
    while (!abortCommandString) { // not aborted
        nextChar = GetNextChar(command, sendPosition, &timeout);
        switch (nextChar) {
            default :
                if (!WriteChar(nextChar))
                    return FALSE;
                break;
                
            case NextCharEndOfString :
                return TRUE;  // Success!!
                
            case NextCharSend :
                break;
                
            case NextCharDelay : // Delay in send
                PThread::Current()->Sleep(timeout);
                break;
                
            case NextCharWait : // Wait for reply
                PINDEX receivePosition = sendPosition;
                if (GetNextChar(command, receivePosition) < 0) {
                    SetReadTimeout(timeout);
                    while (ReadChar() >= 0)
                        if (abortCommandString) // aborted
                            return FALSE;
                }
                else {
                    receivePosition = sendPosition;
                    do {
                        if (abortCommandString) // aborted
                            return FALSE;
                        if ((nextChar = ReadCharWithTimeout(timeout)) < 0)
                            return FALSE;
                    } while (!ReceiveCommandString(nextChar,
                                                   command, receivePosition, sendPosition));
                    //          nextChar = GetNextChar(command, receivePosition);
                    sendPosition = receivePosition;
                }
        }
    }
    
    return FALSE;
}


PBOOL PChannel::Shutdown(ShutdownValue)
{
    return FALSE;
}


PChannel * PChannel::GetBaseReadChannel() const
{
    return (PChannel *)this;
}


PChannel * PChannel::GetBaseWriteChannel() const
{
    return (PChannel *)this;
}


PString PChannel::GetErrorText(ErrorGroup group) const
{
    return GetErrorText(lastErrorCode[group], lastErrorNumber[group]);
}


PBOOL PChannel::ConvertOSError(int status, ErrorGroup group)
{
    Errors lastError;
    int osError;
    PBOOL ok = ConvertOSError(status, lastError, osError);
    SetErrorValues(lastError, osError, group);
    return ok;
}


PBOOL PChannel::SetErrorValues(Errors errorCode, int errorNum, ErrorGroup group)
{
    lastErrorCode[NumErrorGroups] = lastErrorCode[group] = errorCode;
    lastErrorNumber[NumErrorGroups] = lastErrorNumber[group] = errorNum;
    return errorCode == NoError;
}

#ifndef P_HAS_RECVMSG

PBOOL PChannel::Read(const VectorOfSlice & slices)
{
    PINDEX length = 0;
    
    VectorOfSlice::const_iterator r;
    for (r = slices.begin(); r != slices.end(); ++r) {
        PBOOL stat = Read(r->iov_base, r->iov_len);
        length        += lastReadCount;
        lastReadCount = length;
        if (!stat)
            return FALSE;
    }
    
    return TRUE;
}

PBOOL PChannel::Write(const VectorOfSlice & slices)
{
    PINDEX length = 0;
    
    VectorOfSlice::const_iterator r;
    for (r = slices.begin(); r != slices.end(); ++r) {
        PBOOL stat = Write(r->iov_base, r->iov_len);
        length        += lastWriteCount;
        lastWriteCount = length;
        if (!stat)
            return FALSE;
    }
    
    return TRUE;
}

#endif // P_HAS_RECVMSG

#ifdef P_NEED_IOSTREAM_MUTEX
static PMutex iostreamMutex;
#define IOSTREAM_MUTEX_WAIT()   iostreamMutex.Wait();
#define IOSTREAM_MUTEX_SIGNAL() iostreamMutex.Signal();
#else
#define IOSTREAM_MUTEX_WAIT()
#define IOSTREAM_MUTEX_SIGNAL()
#endif


void PChannel::Construct()
{
    os_handle = -1;
    px_lastBlockType = PXReadBlock;
    px_readThread = NULL;
    px_writeThread = NULL;
    px_selectThread = NULL;
}


///////////////////////////////////////////////////////////////////////////////
//
// PChannel::PXSetIOBlock
//   This function is used to perform IO blocks.
//   If the return value is FALSE, then the select call either
//   returned an error or a timeout occurred. The member variable lastError
//   can be used to determine which error occurred
//

PBOOL PChannel::PXSetIOBlock(PXBlockType type, const PTimeInterval & timeout)
{
    ErrorGroup group;
    switch (type) {
        case PXReadBlock :
            group = LastReadError;
            break;
        case PXWriteBlock :
            group = LastWriteError;
            break;
        default :
            group = LastGeneralError;
    }
    
    if (os_handle < 0)
        return SetErrorValues(NotOpen, EBADF, group);
    
    PThread * blockedThread = PThread::Current();
    
    {
        PWaitAndSignal mutex(px_threadMutex);
        switch (type) {
            case PXWriteBlock :
                if (px_readThread != NULL && px_lastBlockType != PXReadBlock)
                    return SetErrorValues(DeviceInUse, EBUSY, LastReadError);
                
                PTRACE(4, "PWLib\tBlocking on write.");
                px_writeMutex.Wait();
                px_writeThread = blockedThread;
                break;
                
            case PXReadBlock :
                PAssert(px_readThread == NULL || px_lastBlockType != PXReadBlock,
                        "Attempt to do simultaneous reads from multiple threads.");
                // Fall into default case
                
            default :
                if (px_readThread != NULL)
                    return SetErrorValues(DeviceInUse, EBUSY, LastReadError);
                px_readThread = blockedThread;
                px_lastBlockType = type;
        }
    }
    
    int stat = blockedThread->PXBlockOnIO(os_handle, type, timeout);
    
    px_threadMutex.Wait();
    if (type != PXWriteBlock) {
        px_lastBlockType = PXReadBlock;
        px_readThread = NULL;
    }
    else {
        px_writeThread = NULL;
        px_writeMutex.Signal();
    }
    px_threadMutex.Signal();
    
    // if select returned < 0, then convert errno into lastError and return FALSE
    if (stat < 0)
        return ConvertOSError(stat, group);
    
    // if the select succeeded, then return TRUE
    if (stat > 0)
        return TRUE;
    
    // otherwise, a timeout occurred so return FALSE
    return SetErrorValues(Timeout, ETIMEDOUT, group);
}


PBOOL PChannel::Read(void * buf, PINDEX len)
{
    lastReadCount = 0;
    
    if (os_handle < 0)
        return SetErrorValues(NotOpen, EBADF, LastReadError);
    
    if (!PXSetIOBlock(PXReadBlock, readTimeout))
        return FALSE;
    
    if (ConvertOSError(lastReadCount = ::read(os_handle, buf, len), LastReadError))
        return lastReadCount > 0;
    
    lastReadCount = 0;
    return FALSE;
}


PBOOL PChannel::Write(const void * buf, PINDEX len)
{
    // if the os_handle isn't open, no can do
    if (os_handle < 0)
        return SetErrorValues(NotOpen, EBADF, LastWriteError);
    
    // flush the buffer before doing a write
    IOSTREAM_MUTEX_WAIT();
    flush();
    IOSTREAM_MUTEX_SIGNAL();
    
    lastWriteCount = 0;
    
    while (len > 0) {
        
        int result;
        while ((result = ::write(os_handle, ((char *)buf)+lastWriteCount, len)) < 0) {
            if (errno != EWOULDBLOCK)
                return ConvertOSError(-1, LastWriteError);
            
            if (!PXSetIOBlock(PXWriteBlock, writeTimeout))
                return FALSE;
        }
        
        lastWriteCount += result;
        len -= result;
    }
    
#if !defined(P_PTHREADS) && !defined(P_MAC_MPTHREADS)
    PThread::Yield(); // Starvation prevention
#endif
    
    // Reset all the errors.
    return ConvertOSError(0, LastWriteError);
}

#ifdef P_HAS_RECVMSG

PBOOL PChannel::Read(const VectorOfSlice & slices)
{
    lastReadCount = 0;
    
    if (os_handle < 0)
        return SetErrorValues(NotOpen, EBADF, LastReadError);
    
    if (!PXSetIOBlock(PXReadBlock, readTimeout))
        return FALSE;
    
    if (ConvertOSError(lastReadCount = ::readv(os_handle, &slices[0], slices.size()), LastReadError))
        return lastReadCount > 0;
    
    lastReadCount = 0;
    return FALSE;
}

PBOOL PChannel::Write(const VectorOfSlice & slices)
{
    // if the os_handle isn't open, no can do
    if (os_handle < 0)
        return SetErrorValues(NotOpen, EBADF, LastWriteError);
    
    // flush the buffer before doing a write
    IOSTREAM_MUTEX_WAIT();
    flush();
    IOSTREAM_MUTEX_SIGNAL();
    
    int result;
    while ((result = ::writev(os_handle, &slices[0], slices.size())) < 0) {
        if (errno != EWOULDBLOCK)
            return ConvertOSError(-1, LastWriteError);
        
        if (!PXSetIOBlock(PXWriteBlock, writeTimeout))
            return FALSE;
    }
    
#if !defined(P_PTHREADS) && !defined(P_MAC_MPTHREADS)
    PThread::Yield(); // Starvation prevention
#endif
    
    // Reset all the errors.
    return ConvertOSError(0, LastWriteError);
}

#endif

PBOOL PChannel::Close()
{
    if (os_handle < 0)
        return SetErrorValues(NotOpen, EBADF);
    
    return ConvertOSError(PXClose());
}


static void AbortIO(PThread * & thread, PMutex & mutex)
{
    mutex.Wait();
    if (thread != NULL)
        thread->PXAbortBlock();
    mutex.Signal();
    
    while (thread != NULL)
        PThread::Yield();
}

int PChannel::PXClose()
{
    if (os_handle < 0)
        return -1;
    
    PTRACE(6, "PWLib\tClosing channel, fd=" << os_handle);
    
    // make sure we don't have any problems
    IOSTREAM_MUTEX_WAIT();
    flush();
    int handle = os_handle;
    os_handle = -1;
    IOSTREAM_MUTEX_SIGNAL();

    AbortIO(px_readThread, px_threadMutex);
    AbortIO(px_writeThread, px_threadMutex);
    AbortIO(px_selectThread, px_threadMutex);
    
    int stat;
    //modified by brant
    for(;;) {
        stat = ::close(handle);
        if(stat == -1 && errno == EINTR)
            PThread::Yield();
        else
            break;
    }
    
    return stat;
}

PString PChannel::GetErrorText(Errors normalisedError, int osError /* =0 */)
{
    if (osError == 0) {
        if (normalisedError == NoError)
            return PString();
        
        static int const errors[NumNormalisedErrors] = {
            0, ENOENT, EEXIST, ENOSPC, EACCES, EBUSY, EINVAL, ENOMEM, EBADF, EAGAIN, EINTR,
            EMSGSIZE, EIO, 0x1000000
        };
        osError = errors[normalisedError];
    }
    
    if (osError == 0x1000000)
        return "High level protocol failure";
    
    const char * err = strerror(osError);
    if (err != NULL)
        return err;
    
    return psprintf("Unknown error %d", osError);
}


PBOOL PChannel::ConvertOSError(int err, Errors & lastError, int & osError)

{
    osError = (err >= 0) ? 0 : errno;
    
    if(osError != 0){
        U_WARN_("osError is " << osError << " ");
    }
    
    switch (osError) {
        case 0 :
            lastError = NoError;
            return TRUE;
            
        case EMSGSIZE:
            lastError = BufferTooSmall;
            break;
            
        case EBADF:  // will get EBADF if a read/write occurs after closing. This must return Interrupted
        case EINTR:
            lastError = Interrupted;
            break;
            
        case EEXIST:
            lastError = FileExists;
            break;
            
        case EISDIR:
        case EROFS:
        case EACCES:
        case EPERM:
            lastError = AccessDenied;
            break;
            
        case ETXTBSY:
            lastError = DeviceInUse;
            break;
            
        case EFAULT:
        case ELOOP:
        case EINVAL:
            lastError = BadParameter;
            break;
            
        case ENOENT :
        case ENAMETOOLONG:
        case ENOTDIR:
            lastError = NotFound;
            break;
            
        case EMFILE:
        case ENFILE:
        case ENOMEM :
            lastError = NoMemory;
            break;
            
        case ENOSPC:
            lastError = DiskFull;
            break;
            
        default :
            lastError = Miscellaneous;
            break;
    }
    return FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// End Of File ///////////////////////////////////////////////////////////////

