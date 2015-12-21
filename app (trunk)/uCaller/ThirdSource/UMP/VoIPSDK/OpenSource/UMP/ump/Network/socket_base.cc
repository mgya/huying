//
//  socket_base.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "socket_base.h"
#include "event_pump.h"
#include "event_nio.h"

#if P_HAS_IPV6
#error IPV6 not supported
#endif

///////////////////////
/////////////////////////
SocketBase::Event::Event(SocketBase & socket)
:_value(e_sock_ev_none),
_socket(socket),
_binder(NULL)
{
}

SocketBase::Event::~Event()
{
	Unbind();
}


void SocketBase::Event::Bind(std::vector<SocketBase * > & sockets, const SocketEventGroup & group)
{
	
	SocketEventPumpManager::Instance().Bind(sockets, group);
}

void SocketBase::Event::Bind(const SocketEventGroup & group)
{
	Unbind();
	std::vector<SocketBase * > sockets;
	sockets.push_back(&_socket);
	Bind(sockets,group);
	
}


void SocketBase::Event::Unbind()
{
	if(_binder){
		((SocketEventBinder *) _binder)->Unbind();
	}
	
}

int SocketBase::Event::Register(int event,PBOOL urgent)
{
	return (_value = _Register(event,urgent));
}

int SocketBase::Event::Unregister(int event)
{
	return (_value = _Unregister(event));
}

void SocketBase::Event::TickNow()
{
	if (_binder) {
		_binder->TickNow();
	}
}

void SocketBase::Event::SetBinder(SocketEventBinder * binder)
{
	_binder = binder;
}

int SocketBase::Event::_Register(int event,PBOOL urgent )
{
	int value=_value|event;
	
	if (value & e_sock_ev_destroy) {
		value = e_sock_ev_destroy;
	}
	
	if (_binder) {
		_binder->Register(value, _socket.GetHandle(), urgent);
	}
	return value;
}

int SocketBase::Event::_Unregister(int event)
{
	int value=_value&(~(event&(~e_sock_ev_destroy)));
	if (value & e_sock_ev_destroy) {
		value = e_sock_ev_destroy;
	}
	
	if (_binder)
		_binder->Register(value, _socket.GetHandle(),FALSE);
	
	return value;
}

///////////////////////////////
SocketBase::SocketBase(int type,EventSink & eventSink)
:
_type(type),
_core(_error),
_event(*this),
_eventSink(eventSink)
{
}

SocketBase::~SocketBase()
{
}

IPPort SocketBase::GetLocalAddress()
{
	IPPort ret;
    
	struct sockaddr address;
	socklen_t size = sizeof(address);
	if (_error.Convert(::getsockname(GetHandle(), &address, &size),
                       PChannel::LastGeneralError)) {
		ret.FromSockAddr(address);
	}
    
	return ret;
}

IPPort SocketBase::GetPeerAddress()
{
	IPPort ret;
    
	struct sockaddr address;
	socklen_t size = sizeof(address);
	if (_error.Convert(::getpeername(GetHandle(), &address, &size),
                       PChannel::LastGeneralError)) {
		ret.FromSockAddr(address);
	}
    
	return ret;
}


PBOOL SocketBase::SetUrgent(PBOOL urgent)
{
	int v = urgent ? 1 : 0;
	if (!_core.SetOption(TCP_NODELAY, &v, sizeof(v), IPPROTO_TCP)) {
		PTRACE(0,
               "ERR\t" << GetClass() << " setOption(TCP_NODELAY="
               << (urgent ? "TRUE" : "FALSE") << ") failed: "
               << _error.GetText());
		return FALSE;
	}
    return TRUE;
}

PBOOL SocketBase::SetLinger(PBOOL l, unsigned short timeout)
{
	const linger ling = {
		(unsigned short) (l ? 1 : 0), timeout
	};
	if (!_core.SetOption(SO_LINGER, &ling, sizeof(ling), SOL_SOCKET)) {
		PTRACE(0,
               "ERR\t" <<GetClass() << " setOption(SO_LINGER) failed: "
               << _error.GetText());
		return FALSE;
	}
    
    return TRUE;
}

PBOOL SocketBase::SetKeepAlive(PBOOL ka)
{
	int v = ka ? 1 : 0;
	if (!_core.SetOption(SO_KEEPALIVE, &v, sizeof(v), SOL_SOCKET)) {
		PTRACE(0,
               "ERR\t" << GetClass() << " setOption(SO_KEEPALIVE) failed: "
               << _error.GetText());
		return FALSE;
	}
	return TRUE;
}

PBOOL SocketBase::SetOption(int option, const void* value, int vsize,
                           int level)
{
	return _core.SetOption(option, value, vsize, level);
}

PBOOL SocketBase::GetOption(int option, void* value, int& vsize, int level)
{
	return _core.GetOption(option, value, vsize, level);
}

PBOOL SocketBase::Listen(const IPPort & local, DWORD queue /*= 5*/,
                        PBOOL reuse /*= FALSE*/)
{
	Close();
    
	//linuxœ¬±ÿ–ÎŒ™TRUE
	reuse = TRUE;

	PBOOL ret = FALSE;
	
	do{
		if (!_core.Socket(_type, GetClass()))
			break;
		
		struct sockaddr sa;
		local.ToSockAddr(sa);
		if (!_core.Bind(sa, reuse))
			break;
		
		if (GetType() == SOCK_STREAM) {
			if (!_core.Listen(queue))
				break;
		}
		
		ret = TRUE;
        
		_event.Register(0,TRUE);
		_eventSink.OnSocketOpen(*this);
        
	}while(0);
	
	if (!ret)
		Close();
    
	return ret;
}

PBOOL SocketBase::Read(void* buffer, PINDEX& len)
{
	return _core.Recv(buffer, len, 0);
}

PBOOL SocketBase::ReadFrom(void* buffer, PINDEX & len, IPPort & from)
{
	struct sockaddr sa;
	if (!_core.RecvFrom(buffer, len, 0, sa))
		return FALSE;
    
	from.FromSockAddr(sa);
	return TRUE;
}

PBOOL SocketBase::Write(const void* buffer, PINDEX len)
{
	return _core.Send(buffer, len, 0);
}

PBOOL SocketBase::WriteTo(
						 const void* buffer,
						 PINDEX len,
						 const IPPort& to)
{
	struct sockaddr sa;
	to.ToSockAddr(sa);
	return _core.SendTo(buffer, len, 0, sa);
}

void SocketBase::Close(PBOOL immediately)
{
	_event._Unregister(e_sock_ev_io);
    
	_core.Close(immediately);
}

PBOOL SocketBase::IsReadable()
{
	if(!IsOpen())
		return FALSE;
    
	DWORD available = 0;
    
	if (!_error.Convert(::ioctl(GetHandle(), FIONREAD, &available),
                        PChannel::LastGeneralError))
		return FALSE;
    
	return 	available > 0;
}

PBOOL SocketBase::IsWritable()
{
	if(!IsOpen())
		return FALSE;

	DWORD n = 0;
    
	if (!_error.Convert(::ioctl(GetHandle(), TIOCOUTQ, &n),
                        PChannel::LastGeneralError))
		return FALSE;
    
	int sz = 0;
	int l = sizeof(sz);
	if (!_core.GetOption(SO_SNDBUF, &sz, l, SOL_SOCKET))
		return FALSE;
    
	return (sz > ((int) n));
}

void SocketBase::Shutdown()
{
	SocketEventPumpManager::DestroyInstance();
}
