//
//  nio_select.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__nio_select__
#define __UMPStack__nio_select__

#include "event_nio.h"

SocketEventNIO::SocketEventNIO()
:_binderCount(0),
_pendingBinderCount(0)
{
}

SocketEventNIO::~SocketEventNIO()
{
	Clear();
}

void SocketEventNIO::Register(SocketEventBinder & /*binder*/)
{
}

int SocketEventNIO::Wait(DWORD timeout)
{
	_readfds.Zero();
	_writefds.Zero();
	_errorfds.Zero();
	
	_readfds.Add(GetUnblockPipe().GetHandle());

	_maxfd = GetUnblockPipe().GetHandle();
	
	PBOOL set = FALSE;
	
	int handle = -1;
	int event = e_sock_ev_none;
	
	EventBinderList::iterator it =_eventBinderList.begin(),eit=_eventBinderList.end();
	while(it!=eit){
		
		set = FALSE;
        
		SocketEventBinder * binder = *(it++);
		
		handle = binder->GetHandle();
		event = binder->GetEvent();
		
		
		if (event & e_sock_ev_connect) {
            
			_writefds.Add(handle);
			_errorfds.Add(handle);
            
			set = TRUE;
		} else {
			if (event & e_sock_ev_read) {
				_readfds.Add(handle);

				set = TRUE;
			}
			
			if (event & e_sock_ev_write) {
				_writefds.Add(handle);

				set = TRUE;
			}
			
		}
		if (set && handle > _maxfd) {
			_maxfd = handle;
		}
	}
	
	
	
	_timeout.tv_sec = timeout / 1000;
	_timeout.tv_usec = (timeout - _timeout.tv_sec * 1000) * 1000;

	return ::select(_maxfd + 1, _readfds, _writefds, _errorfds, &_timeout);
}

void SocketEventNIO::Dispatch(int /*num*/)
{
	EventBinderList::iterator it =_eventBinderList.begin(),eit=_eventBinderList.end();
	while(it!=eit){
		
		SocketEventBinder* binder = *(it++);
		int event = e_sock_ev_none;
		
		if (_readfds.Has(binder->GetHandle())) {
			event |= e_sock_ev_read;
		}
		
		if (_writefds.Has(binder->GetHandle())) {
			event |= (e_sock_ev_write | e_sock_ev_connect);
		}
		
		if (_errorfds.Has(binder->GetHandle())) {
			event |= e_sock_ev_connect;
		}
		if (event) {
			binder->Fire(event, PChannel::NoError);
		}
		
	}
	
	
	if (_readfds.Has(GetUnblockPipe().GetHandle())) {
		GetUnblockPipe().Read();
	}
}

void SocketEventNIO::Cancel(PBOOL /*onExit*/)
{
	GetUnblockPipe().Write();
}

#endif /* defined(__UMPStack__nio_select__) */
