//
//  nio_epoll.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__nio_epoll__
#define __UMPStack__nio_epoll__

#ifdef HAS_EPOLL

#include <sys/epoll.h>
#include "event_nio.h"

int PX_NewHandle(const char*, int);

SocketEventNIO::SocketEventNIO()
:_binderCount(0),
_pendingBinderCount(0)
{
	
	_unblockPipeRegistered = FALSE;
    
	_buffer.resize(SocketEventGroup().GetMaxSockCount() + 1/*a unblock pipe*/);
	_events = &(_buffer[0]);
    
    
	_epoll = PX_NewHandle(
                          "SocketEventNIO",
                          ::epoll_create(_buffer.size()));
	if (_epoll < 0) {
		PTRACE(0,
               "ERR\t" << GetClass() << " SERIOUS ERROR--epool_create failed for "
               << strerror(errno) << "(" + PString(errno) + ")");
	}
	
    
}

SocketEventNIO::~SocketEventNIO()
{
	Clear();
	::close(_epoll);
	_epoll=-1;
}

void SocketEventNIO::Register(SocketEventBinder & binder)
{
	
	const int handle = binder.GetHandle();
	
	if (handle < 0)
		return;
	
	const int event = binder.GetEvent();
	epoll_event ev;
	ev.events = 0;
	ev.data.ptr = &binder;
	
	
	if (event & e_sock_ev_read) {
		ev.events |= EPOLLIN;
	}
	if (event & e_sock_ev_write) {
		ev.events |= EPOLLOUT;
	}
	
	if (event & e_sock_ev_connect) {
		ev.events |= EPOLLOUT;
		
	}
	//PStringStream traceInfo;
	if (ev.events == 0) {
		if (::epoll_ctl(_epoll, EPOLL_CTL_DEL, handle, &ev) != 0) {
            /*
             traceInfo
             << " failed to del event for h=" << handle
             << ",err=" << strerror(errno)
             << "(" + PString(errno) + ")";*/
			
		}
		else
			return;
	} else {
		
		if (::epoll_ctl(_epoll, EPOLL_CTL_MOD, handle, &ev) != 0) {
            /*
             traceInfo
             << " failed to mod event for h=" << handle
             << " v=" << ev.events
             << ",err=" << strerror(errno)
             << "(" + PString(errno) + ")";*/
			
			if (::epoll_ctl(_epoll, EPOLL_CTL_ADD, handle, &ev) !=
				0) {
				/*
                 traceInfo
                 << " failed to add event for h=" << handle
                 << ",err=" << strerror(errno)
                 << "(" + PString(errno) + ")";*/
				
			}
			else
				return;
		}
		else
			return;
	}
	
}

int SocketEventNIO::Wait(DWORD timeout)
{
	if(!_unblockPipeRegistered){
		epoll_event ev;
		ev.events = EPOLLIN;
		ev.data.ptr = NULL;
		if (::epoll_ctl(_epoll, EPOLL_CTL_ADD, GetUnblockPipe().GetHandle(), &ev) == 0) {
			_unblockPipeRegistered = TRUE;
		}
		else{
			PTRACE(0,
                   "ERR\t" << GetClass() << " failed to add event for unblockPipe="
                   << GetUnblockPipe().GetHandle() << ",err=" << strerror(errno)
                   << "(" + PString(errno) + ")");
		}
		
	}
	return ::epoll_wait(_epoll, _events, _binderCount + 1, (int) timeout);
}

void SocketEventNIO::Dispatch(int num)
{
	SocketEventBinder * binder = NULL;
	for (int i = 0; i < num; i++) {
		binder = (SocketEventBinder *) _events[i].data.ptr;
		if (binder) {
			int event = e_sock_ev_none;
			
			if (_events[i].events & EPOLLIN) {
				event |= e_sock_ev_read;
			}
			
			if(_events[i].events & EPOLLHUP){
				if((binder->GetEvent()&e_sock_ev_read)==0)
					event |= e_sock_ev_hup;
			}
			
			if (_events[i].events & EPOLLOUT) {
				event |= (e_sock_ev_write | e_sock_ev_connect);
				
			}
			
			if (_events[i].events & EPOLLERR) {
				event |= e_sock_ev_connect;
			}
			
			
			
			
			if (event) {
				binder->Fire(event, PChannel::NoError);
			}
		} else {
			
			//PTRACE(1,"WARN\t"<<GetClass()<<" event with null pointer");
			
			if (_events[i].events & EPOLLIN) {
				PTRACE(5, "INFO\t" << GetClass() << " block Canceled");
				GetUnblockPipe().Read();
			}
			
		}
	}
}

void SocketEventNIO::Cancel(PBOOL onExit)
{
	if(onExit)
		GetUnblockPipe().Write();
}

#endif

#endif /* defined(__UMPStack__nio_epoll__) */
