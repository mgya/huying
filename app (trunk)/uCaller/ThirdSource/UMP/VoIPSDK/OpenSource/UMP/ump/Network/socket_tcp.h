//
//  socket_tcp.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__socket_tcp__
#define __UMPStack__socket_tcp__

#include "socket_base.h"

class SocketTCP : public SocketBase
{
	PCLASSINFO(SocketTCP, SocketBase);
public:
	friend class SocketEventBinder;
    
    
	class WriteBuffers
	{
	public:
		WriteBuffers();
		virtual ~WriteBuffers();
		
		PBYTEArray* Pop();
		void Unpop(PBYTEArray* buffer);
		void Push(PBYTEArray* buffer);
		
		PINDEX GetBufferCount() const;
		
		void Clear();
		
	protected:
		
		
	protected:
		typedef std::list<PBYTEArray * > BufferList;
        
		BufferList _bufferList;
        
		PINDEX _bufferCount;
	};
    
	enum E_ConnectProgress {
		e_not_connected		= 0,
		e_connecting,
		e_connected,
	};
public:
    
	SocketTCP(EventSink & eventSink);
	virtual ~SocketTCP();
    
	virtual PBOOL Accept(SocketBase & listener);
	
	virtual PBOOL Connect(
                         const IPPort & remote,
                         DWORD timeout = 10 * 1000, /* 10 sec */
                         PBOOL reuse = FALSE,
                         const IPPort & local = IPPort()
                         );
	virtual void Close(PBOOL immediately = FALSE);
	virtual PBOOL Write(const void* buffer, PINDEX len);
	
	PBOOL IsConnectTimeout() const;
	E_ConnectProgress GetConnectProgress() const;
    
	PINDEX GetWriteBufferCount() const;
    
	
private:
	void Flush();
	void SetConnectProgress(E_ConnectProgress progress);
	Timeout _connectTimeout;
    
	E_ConnectProgress _connectProgress;
    
	WriteBuffers _writeBuffers;
	PMutex _writeMutex;
};




/**
 */
class TCPListeners : public PObject
{
	PCLASSINFO(TCPListeners, PObject)
public:
	TCPListeners();
	virtual ~TCPListeners();
	
	PBOOL Add(
             const PString& bind,
             WORD defPort,
             DWORD backlog = 5,
             PBOOL reuse = FALSE,
             DWORD userData = 0);
    
	PBOOL Add(
             const IPPort & bind,
             DWORD backlog = 5,
             PBOOL reuse = FALSE,
             DWORD userData = 0);
	
	void Clear();
	
	const IPPorts & GetBinds() const;
	
	DWORD GetCount() const;
protected:
	virtual SocketTCP * CreateListener(DWORD userData) = 0;
    
protected:
	PARRAY(Listeners, SocketTCP);
    
	
	
	Listeners _listeners;
	IPPorts _binds;
private:
	NonCopyable ______nocopy;
};

#endif /* defined(__UMPStack__socket_tcp__) */
