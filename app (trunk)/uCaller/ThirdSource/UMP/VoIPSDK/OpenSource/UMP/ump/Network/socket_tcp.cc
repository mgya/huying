//
//  socket_tcp.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "socket_tcp.h"

SocketTCP::WriteBuffers::WriteBuffers()
:_bufferCount(0)
{
}

SocketTCP::WriteBuffers::~WriteBuffers()
{
	Clear();
}

PBYTEArray* SocketTCP::WriteBuffers::Pop()
{
	PBYTEArray* buffer = NULL;
	if (!_bufferList.empty()){
		buffer = _bufferList.front();
		_bufferList.pop_front();
		_bufferCount--;
	}
	
	return buffer;
}

void SocketTCP::WriteBuffers::Unpop(PBYTEArray* buffer)
{
	_bufferList.push_front(buffer);
	_bufferCount++;
}

void SocketTCP::WriteBuffers::Push(PBYTEArray* buffer)
{
	_bufferList.push_back(buffer);
	_bufferCount++;
}

PINDEX SocketTCP::WriteBuffers::GetBufferCount() const
{
	return _bufferCount;
}

void SocketTCP::WriteBuffers::Clear()
{
	DeleteObjectsInContainer(_bufferList);
	_bufferList.clear();
	_bufferCount=0;
}
//////////////////////
SocketTCP::SocketTCP(EventSink & eventSink)
:SocketBase(SOCK_STREAM,eventSink), _connectProgress(e_not_connected)
{
    
}

SocketTCP::~SocketTCP()
{
	Close();
}

PBOOL SocketTCP::Accept(SocketBase & listener)
{
	Close();
	
	struct sockaddr sa;
	if (_core.Accept(listener.GetHandle(), sa, GetClass())) {
		GetEvent()._Register(GetEvent().GetValue(), TRUE);
		
		_connectProgress = e_connected;
		GetEventSink().OnSocketOpen(*this);
		return TRUE;
	} else {
		return FALSE;
	}
}

PBOOL SocketTCP::Connect(
                        const IPPort& remote,
                        DWORD timeout ,
                        PBOOL reuse,
                        const IPPort& local
                        )
{
	Close();
    
	PBOOL ret = FALSE;
    
	do{
		if (!_core.Socket(GetType(), GetClass()))
			break;
		
		if (local.GetIP().IsValid() || local.GetPort() != 0) {
			struct sockaddr sa;
			local.ToSockAddr(sa);
			if (!_core.Bind(sa, reuse))
				break;
		}
		
		GetEventSink().OnSocketOpen(*this);
		
		{
			struct sockaddr sa;
			remote.ToSockAddr(sa);
			if (!_core.Connect(sa))
				break;
		}
		
		_connectTimeout.SetTimeout(timeout);
		_connectProgress = e_connecting;
		
		
		ret = TRUE;
		GetEvent().Register(0, TRUE);
        
	}while(0);
    
	if (!ret)
		Close();
    
	return ret;
}

void SocketTCP::Close(PBOOL immediately)
{
	SocketBase::Close(immediately);
    
	_connectProgress = e_not_connected;
    
	{
		PWaitAndSignal lock(_writeMutex);
		_writeBuffers.Clear();
	}
}

void SocketTCP::Flush()
{
	{
		PWaitAndSignal lock(_writeMutex);
		if (_writeBuffers.GetBufferCount() > 0) {
			PBYTEArray* b = _writeBuffers.Pop();
			PINDEX len = b->GetSize();
			PINDEX wlen = len;
			if (!_core.Send(*b, wlen,
#if defined(VOIPBASE_IOS) || defined(VOIPBASE_MAC)
                            0x4000
#else
                            MSG_NOSIGNAL
#endif
                            )) {
				_writeBuffers.Unpop(b);
				GetEventSink().OnHup(*this);
			}else{
				
				if (wlen != len) {
					PAssert(wlen < len,"wlen>len!");
					BYTE* ptr = b->GetPointer();
					memmove(ptr, ptr + wlen, len - wlen);
					b->SetSize(len - wlen);
					_writeBuffers.Unpop(b);
				} else {
					delete b;
					b = NULL;
				}
			}
		} else {
			GetEvent().Unregister(e_sock_ev_write);
		}
	}
}

PBOOL SocketTCP::Write(const void* buffer, PINDEX len)
{
	PWaitAndSignal lock(_writeMutex);
	if (_writeBuffers.GetBufferCount() > 0) {
		PBYTEArray* b = new PBYTEArray;
		memcpy(b->GetPointer(len), buffer, len);
		_writeBuffers.Push(b);
		GetEvent().Register(e_sock_ev_write,FALSE);
		return TRUE;
	} else {
		PINDEX wlen = len;
		
		if (!_core.Send(buffer, wlen,
#if defined(VOIPBASE_IOS) || defined(VOIPBASE_MAC)
                        0x4000
#else
                        MSG_NOSIGNAL
#endif
                        )) {
			GetEvent()._Register(e_sock_ev_hup,FALSE);
			
			return FALSE;
		}
		if (len != wlen) {
			PAssert(wlen < len,"wlen>len!");
			PBYTEArray* b = new PBYTEArray;
			memcpy(b->GetPointer(len-wlen), ((const char *) buffer) + wlen,
                   len - wlen);
			_writeBuffers.Push(b);
			GetEvent().Register(e_sock_ev_write, TRUE);
		}
		return TRUE;
	}
}

SocketTCP::E_ConnectProgress SocketTCP::GetConnectProgress() const
{
	return _connectProgress;
}

void SocketTCP::SetConnectProgress(E_ConnectProgress progress)
{
	_connectProgress = progress;
}

PINDEX SocketTCP::GetWriteBufferCount() const
{
	return _writeBuffers.GetBufferCount();
}

PBOOL SocketTCP::IsConnectTimeout() const
{
	if (e_connecting == _connectProgress) {
		return _connectTimeout.IsTimeout();
	} else {
		return FALSE;
	}
}

/////////////////////////////
TCPListeners::TCPListeners()
{
	_listeners.AllowDeleteObjects(TRUE);
}

TCPListeners::~TCPListeners()
{
	Clear();
}


PBOOL TCPListeners::Add(
					   const IPPort & bind,
					   DWORD backlog,
					   PBOOL reuse,
					   DWORD userData)
{
	SocketTCP* sock = CreateListener(userData);
	if (!sock->Listen(bind, backlog, reuse)) {
		PTRACE(0,
               "ERR\t" << GetClass() << " failed to listen on " << bind
               << ",reason=" << sock->GetError().GetText());
		delete sock;
		return FALSE;
	}
	
	sock->GetEvent().Register(e_sock_ev_read);
	
	sock->GetEvent().Bind(SocketEventGroup(GetClass()));
	
	
	PTRACE(3, "INFO\t" << GetClass() << " add listener on " << bind);
	_listeners.Append(sock);
	_binds.push_back(bind);
	return TRUE;
    
}
PBOOL TCPListeners::Add(const PString& bind,
					   WORD defPort,
					   DWORD backlog,
					   PBOOL reuse,
					   DWORD userData)
{
	IPPort ipport;
	if (!ipport.FromString(bind, defPort)) {
		PTRACE(0, "ERR\t" << GetClass() << " invalid bind " << bind);
		
		return FALSE;
	}
	
	return Add(ipport, backlog, reuse, userData);
}

void TCPListeners::Clear()
{
	if (_listeners.GetSize() > 0) {
		PTRACE(3,
               "INFO\t" << GetClass() << " " << _listeners.GetSize()
               << " listener(s) available");
	}
	
	for (PINDEX i = 0; i < _listeners.GetSize(); i++) {
		_listeners[i].Close();
		_listeners[i].GetEvent().Unbind();
	}
	_listeners.RemoveAll();
	_binds.clear();
}

const IPPorts & TCPListeners::GetBinds() const
{
	return _binds;
}

DWORD TCPListeners::GetCount() const
{
	return _listeners.GetSize();
}
