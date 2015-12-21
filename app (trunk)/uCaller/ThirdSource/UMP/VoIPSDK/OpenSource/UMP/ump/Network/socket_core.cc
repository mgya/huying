//
//  socket_core.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "socket_core.h"
//#include <CoreFoundation/CFStream.h>

#include "event_pump.h"


PBOOL SocketError::PSocketHack::ConvertOSError(
											  int error,
											  PChannel::Errors& lastError,
											  int& osError)
{
	return PSocket::ConvertOSError(error, lastError, osError);
}
/////////////
SocketError::SocketError()
{
	memset(_lastErrorCode, 0, sizeof(_lastErrorCode));
	memset(_lastErrorNumber, 0, sizeof(_lastErrorNumber));
}

SocketError::~SocketError()
{
    
}
PChannel::Errors SocketError::GetSockOptError(int handle)
{
	PChannel::Errors result = PChannel::NoError;
	
	int oserror = 0;
	int err = -1;
	socklen_t errlen = sizeof(err);
	
	::getsockopt(handle, SOL_SOCKET, SO_ERROR, (char *) &err, &errlen);
	errno = err;

	Convert(err == 0 ? 0 : -1, result, oserror);
	
	return result;
}



PChannel::Errors SocketError::GetCode(PChannel::ErrorGroup group) const
{
	return _lastErrorCode[group];
}

int SocketError::GetNumber(PChannel::ErrorGroup group) const
{
	return _lastErrorNumber[group];
}

PString SocketError::GetText(PChannel::ErrorGroup group) const
{
	return PSocket::GetErrorText(_lastErrorCode[group],
                                 _lastErrorNumber[group]);
}


PBOOL SocketError::Convert(int error, PChannel::ErrorGroup eg)
{
	PBOOL ret = PSocketHack::ConvertOSError(error,
                                           _lastErrorCode[PChannel::NumErrorGroups],
                                           _lastErrorNumber[PChannel::NumErrorGroups]);
	_lastErrorCode[eg] = _lastErrorCode[PChannel::NumErrorGroups];
	_lastErrorNumber[eg] = _lastErrorNumber[PChannel::NumErrorGroups];
	return ret;
}

PString SocketError::GetText(PChannel::Errors lastError,int osError)
{
	return PSocket::GetErrorText(lastError, osError);
}

PBOOL SocketError::Convert(
						  int error,
						  PChannel::Errors& lastError,
						  int& osError)
{
	return PSocketHack::ConvertOSError(error, lastError, osError);
}
//////////////////////
SocketCore::SocketCore(SocketError & err)
:_handle(-1),
_error(err)
{
	
}

SocketCore::~SocketCore()
{
	Close();
}


int PX_NewHandle(const char*, int);

PBOOL SocketCore::Socket(int type, const char * className)
{
	Close();
	int retval = ::socket(AF_INET, type, 0);
	
	if (!_error.Convert(
                        PX_NewHandle(className, retval),
                        PChannel::LastGeneralError))
		return FALSE;
    
	_handle = retval;
    
	//set nonblocking
	int cmd = 1;
	if (!_error.Convert(::ioctl(_handle, FIONBIO, &cmd), PChannel::LastGeneralError) ||
		!_error.Convert(::fcntl(_handle, F_SETFD, 1),	PChannel::LastGeneralError)){
        
		Close();
		return FALSE;
	}
	
	return TRUE;
    
}

PBOOL SocketCore::Bind(const struct sockaddr& iface, PBOOL reuse)
{
	int r = reuse ? 1 : 0;
	
	if (!SetOption(SO_REUSEADDR, &r, sizeof(r), SOL_SOCKET)) {
		return FALSE;
	}
	
	return _error.Convert(::bind(_handle, &iface, sizeof(iface)),
                          PChannel::LastGeneralError);
}

PBOOL SocketCore::SendTo(
						const void* data,
						PINDEX& len,
						int flag,
						const struct sockaddr& to)
{
//	in_addr addr = ((sockaddr_in *)&to)->sin_addr;
//	int port = ((sockaddr_in *)&to)->sin_port;
	int retval = ::sendto(
                          _handle,
                          (const char*) data,
                          len,
                          flag,
                          &to,
                          sizeof(to));
    
	if (retval < 0) {
		len = 0;
		switch(errno){
            case EAGAIN:
            case EINTR:
            case ENOSPC:
                retval = 0;
                break;
            default:
                break;
		}
	} else
		len = retval;
    
    
	return _error.Convert(retval, PChannel::LastWriteError);
}

PBOOL SocketCore::Send(const void* data, PINDEX& len, int flag)
{
	int retval = ::send(_handle, (const char*) data, len, flag);
	
	if (retval < 0) {
		len = 0;
		switch(errno){
            case EAGAIN:
            case EINTR:
            case ENOSPC:
                retval = 0;
                break;
            default:
                break;
		}
	} else
		len = retval;
    
	return _error.Convert(retval, PChannel::LastWriteError);
}

PBOOL SocketCore::RecvFrom(
						  void* data,
						  PINDEX& len,
						  int flag,
						  struct sockaddr& from)
{
	socklen_t fromlen = sizeof(sockaddr);
	int retval = ::recvfrom(
                            _handle,
                            (char*) data,
                            len,
                            flag,
                            &from,
                            &fromlen);
	
	if (retval < 0) {
		len = 0;
		switch(errno){
            case EAGAIN:
            case EINTR:
                retval = 0;
                break;
            default:
                break;
		}
	} else {
		len = retval;
		
		//means remote side has shut down the connection gracefully
		if (retval == 0) {
			retval = -1;
		}
	}
	
	_error.Convert(retval, PChannel::LastReadError);
	
	return (retval >= 0);
}

PBOOL SocketCore::Recv(void* data, PINDEX& len, int flag)
{
	int retval = ::recv(_handle, (char*) data, len, flag);
	
	if (retval < 0) {
		len = 0;
		switch(errno){
            case EAGAIN:
            case EINTR:
                retval = 0;
                break;
            default:
                break;
		}
	} else {
		len = retval;
		
		//means remote side has shut down the connection gracefully
		if (0 == retval) {
			retval = -1;
		}
	}
	
	_error.Convert(retval, PChannel::LastReadError);
	
	return (retval >= 0);
}

PBOOL SocketCore::Accept(int listener, sockaddr& addr, const char * className)
{
	Close();
	socklen_t addrlen = sizeof(addr);
	int retval = PX_NewHandle(className,
                              ::accept(listener, &addr, &addrlen));
	if (!_error.Convert(retval, PChannel::LastGeneralError))
		return FALSE;
	
	_handle = retval;
	
	//set nonblocking
	int cmd = 1;
	
	if (!_error.Convert(::ioctl(_handle, FIONBIO, &cmd),PChannel::LastGeneralError) ||
		!_error.Convert(::fcntl(_handle, F_SETFD, 1),PChannel::LastGeneralError)){
        
		Close();
		return FALSE;
	}
    
	return TRUE;
}

PBOOL SocketCore::Connect(const struct sockaddr& addr)
{
	int retval = ::connect(_handle, &addr, sizeof(addr));
	if(retval<0){
		
		if(EINPROGRESS==errno)
			return TRUE;
		else
			return _error.Convert(-1, PChannel::LastGeneralError);		
	}else
		return TRUE;
	
}

PBOOL SocketCore::Listen(int queue)
{
	return _error.Convert(::listen(_handle, queue),
                          PChannel::LastGeneralError);
}

PBOOL SocketCore::SetOption(int option, const void* value, int vsize,
                           int level)
{
	return _error.Convert(::setsockopt(_handle, level, option,
                                       (const char *) value, vsize),
                          PChannel::LastGeneralError);
}

PBOOL SocketCore::GetOption(int option, void* value, int& vsize, int level)
{
	return _error.Convert(::getsockopt(_handle, level, option,
                                       (char *) value, (socklen_t *) &vsize),
                          PChannel::LastGeneralError);
}

void SocketCore::Close(PBOOL immediately)
{
	int handle = _handle;
	_handle = -1;
	
	if(handle == -1)
		return;
    
	if(immediately){
        
		::shutdown(handle,2);
        
#define _closesocket	close
        
		if(::_closesocket(handle) == 0){
			//successful
			return;
		} 
	}
    
	SocketEventPumpManager::Instance().GetSocketCloser().CloseSocket(handle);
}



