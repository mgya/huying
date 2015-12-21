//
//  socket_core.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__socket_core__
#define __UMPStack__socket_core__

#include "net_type.h"
#include <CFNetwork/CFNetwork.h>

class SocketError
{
private:
	class PSocketHack : public PSocket
	{
	public:
		static PBOOL ConvertOSError(
                                   int error,
                                   PChannel::Errors& lastError,
                                   int& osError);
	};
public:
	SocketError();
	virtual ~SocketError();
    
	PChannel::Errors GetCode(PChannel::ErrorGroup group = PChannel::NumErrorGroups) const;
	int GetNumber(PChannel::ErrorGroup group = PChannel::NumErrorGroups) const;
	PString GetText(PChannel::ErrorGroup group = PChannel::NumErrorGroups) const;
	
	PBOOL Convert(int error, PChannel::ErrorGroup eg);
public:
	static PString GetText(PChannel::Errors lastError,int osError);
    
	static PBOOL Convert(
                        int error,
                        PChannel::Errors& lastError,
                        int& osError);
	static PChannel::Errors GetSockOptError(int handle);
    
private:
	PChannel::Errors _lastErrorCode[PChannel::NumErrorGroups + 1];
	int _lastErrorNumber[PChannel::NumErrorGroups + 1];
};


class SocketCore
{
public:
	SocketCore(SocketError & err);
	virtual ~SocketCore();
	
public:
	PBOOL IsOpen() const{return (_handle!=-1);}
	int GetHandle() const{return _handle;}
public:
	PBOOL Socket(int type, const char * className);
	PBOOL Bind(const struct sockaddr& iface, PBOOL reuse);
	PBOOL SendTo(const void* data, PINDEX& len, int flag,const struct sockaddr& to);
	PBOOL Send(const void* data, PINDEX& len, int flag);
	PBOOL RecvFrom(void* data, PINDEX& len, int flag, struct sockaddr& from);
	PBOOL Recv(void* data, PINDEX& len, int flag);
	PBOOL Accept(int listener, sockaddr& addr, const char * className);
	PBOOL Connect(const struct sockaddr& addr);
	PBOOL Listen(int queue);
	
	PBOOL SetOption(int option, const void* value, int vsize, int level);
	PBOOL GetOption(int option, void* value, int& vsize, int level);
	
	void Close(PBOOL immediately = FALSE);
private:
	int _handle;
	SocketError & _error;
	
};

#endif /* defined(__UMPStack__socket_core__) */
