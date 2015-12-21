//
//  event_nio.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "event_nio.h"

#include "net_type.h"
#include "socket_base.h"
#include "socket_tcp.h"


#ifdef HAS_EPOLL
#warning "############## epoll enabled"
#endif

SocketEventBinder::SocketEventBinder(SocketEventNIO & nio, PBYTEArray& sharedBuffer)
:_eventNIO(nio),
_sharedBuffer(sharedBuffer),
_socket(NULL),
_event(e_sock_ev_none),
_handle(-1)
{
}

SocketEventBinder::~SocketEventBinder()
{
    
	PWaitAndSignal lock(_mutex);
	if(NULL == _socket)
		return;
    
	Register(e_sock_ev_none,_socket->GetHandle(),FALSE);
	_socket->GetEvent().SetBinder(NULL);
	PTRACE(1, "WARN\t"<<GetClass()<<" Delete bound socket");
	delete _socket;
	_socket = NULL;
}

void SocketEventBinder::Bind(SocketBase * socket)
{
	PWaitAndSignal lock(_mutex);
	
	_socket = socket;
	_socket->GetEvent().SetBinder(this);
	Register(_socket->GetEvent().GetValue(),_socket->GetHandle(),TRUE);
}

void SocketEventBinder::Unbind()
{
	PWaitAndSignal lock(_mutex);
	
	if(NULL == _socket)
		return;
	
	Register(e_sock_ev_none,_socket->GetHandle(),FALSE);
	_socket->GetEvent().SetBinder(NULL);
	_socket = NULL;
}

void SocketEventBinder::Register(int event,int handle,PBOOL urgent)
{
	_event = event;
	if (!(_event & e_sock_ev_io))
		urgent = FALSE;
    
	_handle = handle;
	_eventNIO.Register(*this);
	
	if (urgent)
		_eventNIO.Cancel(FALSE);
}

void SocketEventBinder::TickNow()
{
	if(_event&e_sock_ev_tick)
		_eventNIO.TickNow(*this);
}

void SocketEventBinder::Fire(int event, PChannel::Errors result)
{
	PWaitAndSignal lock(_mutex);
	if (NULL == _socket)
		return;
	
	if (_event & event & e_sock_ev_destroy) {
        /** let the destructor of socket to disconnect from me
         */
		delete _socket;
		return;
	}
	
    
	
	/** async tcp connect callback
     */
	if (_event & event & e_sock_ev_connect){

		_socket->GetEvent().Unregister(e_sock_ev_connect);
		
		if(_socket->GetType()==SOCK_STREAM &&
           ((SocketTCP*)_socket)->GetConnectProgress() == SocketTCP::e_connecting) {
            
			PChannel::Errors error = (result == PChannel::NoError) ?
            SocketError::GetSockOptError(GetHandle()):result;
			_socket->GetError().Convert(-1,PChannel::LastGeneralError);
			
			if(PChannel::NoError!=error){
				_socket->Close();
				((SocketTCP*)_socket)->SetConnectProgress(SocketTCP::e_not_connected);
			}
			else
				((SocketTCP*)_socket)->SetConnectProgress(SocketTCP::e_connected);
			
			_socket->GetEventSink().OnConnect(*_socket,error);
			return;
			
		}
		
	}
	
	if ((event & e_sock_ev_hup)||(_event & e_sock_ev_hup)){
		
		_event&=(~e_sock_ev_hup);
		_socket->GetEvent().SetValue(_socket->GetEvent().GetValue()&(~e_sock_ev_hup));
		if(_socket->GetType() == SOCK_STREAM){
			_socket->GetEventSink().OnHup(*_socket);
		}
		return;
	}
	
	if (_event & event & e_sock_ev_read) {
		_socket->GetEventSink().OnReadable(*_socket,_sharedBuffer);
	}
    
	if(NULL == _socket)
		return;
    
	if (_event & event & e_sock_ev_write) {
        
		if(_socket->GetType()==SOCK_STREAM)
			((SocketTCP*)_socket)->Flush();
		else
			_socket->GetEvent().Unregister(e_sock_ev_write);
		_socket->GetEventSink().OnWritable(*_socket,_sharedBuffer);
	}
	
	
	/** tick callback, about every 1 second
     */
	if(NULL == _socket)
		return;
    
	if (_event & event & e_sock_ev_tick) {
		_socket->GetEventSink().OnTick(*_socket);
	}
}
//////////////////////

#ifdef HAS_EPOLL
#include "nio_epoll.h"
#else
#include "nio_select.h"
#endif


SocketEventNIO::UnblockPipe::UnblockPipe()
{
	_handle = -1;
	_thread = NULL;
	_length = 0;
}

SocketEventNIO::UnblockPipe::~UnblockPipe()
{
	Close();
}

void SocketEventNIO::UnblockPipe::Open(PThread * thread)
{
	Close();
    
	/** on linux/unix we use a pipe of PThread as unblock-pipe
     */
	class DummyThread : public PThread {
	public:
		int GetUnblockPipe()
		{
			return unblockPipe[0];
		}
	};
	_handle = ((DummyThread *) thread)->GetUnblockPipe();

	_thread = thread;
}

void SocketEventNIO::UnblockPipe::Close()
{
	_handle = -1;
	_thread = NULL;
    
}

void SocketEventNIO::UnblockPipe::Write()
{
	if(PThread::Current() == _thread)
		return;
	
	
	if (_length>0)
		return;
	if(_handle<0)
		return;
	
	PTRACE(7, "INFO\t" << GetClass() << " cancelBlock");
	
	PThread* thread = _thread;
	if (thread) {
		thread->PXAbortBlock();
	}

	++_length;
    
}

void SocketEventNIO::UnblockPipe::Read()
{
	static char c;
	
	PTRACE(7, "INFO\t" << GetClass() << " unblocked");
	
	::read(_handle, &c, 1);

	--_length;
}

///////////////////////
void SocketEventNIO::Append(const std::vector<SocketEventBinder *> & binders)
{
	PWaitAndSignal lock(_pendingBinderListMutex);
	
	for(unsigned i=0;i<binders.size();i++){
		_pendingBinderList.push_back(binders[i]);
	}
	_pendingBinderCount += binders.size();
}

DWORD SocketEventNIO::GetMediatorCount() const
{
	return _binderCount+_pendingBinderCount;
}


void SocketEventNIO::Prepare()
{
	/** append pending event mediators
     */
	if(!_pendingBinderList.empty()){
		
		PWaitAndSignal lock(_pendingBinderListMutex);
		while (!_pendingBinderList.empty()) {
			_eventBinderList.push_back(_pendingBinderList.front());
			_pendingBinderList.pop_front();
		}
		_binderCount+=_pendingBinderCount;
		_pendingBinderCount = 0;
	}
    
	{
		if(!_tickNowBinderList.empty()){
			for(;;){
				SocketEventBinder * binder = NULL;
				{
					PWaitAndSignal lock(_tickNowBinderListMutex);
					if(!_tickNowBinderList.empty()){
						binder = _tickNowBinderList.front();
						_tickNowBinderList.pop_front();
					}
				}
				if(binder){
					binder->Fire(e_sock_ev_tick,PChannel::NoError);
				}else
					break;
			}
			
		}
	}
}

void SocketEventNIO::Clear()
{
	Prepare();
	int bound=0;
	
	while (!_eventBinderList.empty()){
		SocketEventBinder * binder = _eventBinderList.front();
		_eventBinderList.pop_front();
		if (!binder->IsDeletable()) {
			bound++;
		}
		delete binder;
	}
    
	if (bound > 0 ) {
		PTRACE(1,
               "WARN\t" << GetClass() << " " << bound << " mediator(s) still bound");
	}
	_binderCount=0;
    
}

void SocketEventNIO::TickNow(SocketEventBinder & binder)
{
	{
		PWaitAndSignal lock(_tickNowBinderListMutex);
		_tickNowBinderList.push_back(&binder);
	}
	GetUnblockPipe().Write();
}

PBOOL SocketEventNIO::Tick()
{
	PBOOL empty = _eventBinderList.empty();
	if(!empty){
        
		EventBinderList::iterator it = _eventBinderList.begin(),
        eit = _eventBinderList.end();
		while(it!=eit){
			
			SocketEventBinder * binder = *it;
			if (!binder->IsDeletable()) {
				
				if (binder->GetEvent() & e_sock_ev_destroy)
					binder->Fire(e_sock_ev_destroy, PChannel::NoError);
                
				else {
					
					int event = e_sock_ev_none;
					PChannel::Errors result = PChannel::NoError;
					SocketBase * socket = binder->GetSocket();
					if(socket->GetType() == SOCK_STREAM){
						if(((SocketTCP*)socket)->IsConnectTimeout()){
							PTRACE(5,
                                   "INFO\t" << GetClass() << " connect timeout,h="
                                   << binder->GetHandle());
							
							event |= e_sock_ev_connect;
							result = PChannel::Timeout;
							errno = ETIMEDOUT;
						}
						
					}
					
					if (binder->GetEvent() & e_sock_ev_tick)
						event |= e_sock_ev_tick;
					
					if (event)
						binder->Fire(event, result);
                    
				}
				it++;
			} else {
				it = _eventBinderList.erase(it);
				delete binder;
				
				--_binderCount;
				
			}
		}
	}
	{
		PWaitAndSignal lock(_tickNowBinderListMutex);
		_tickNowBinderList.clear();
	}
    
	return (!empty);
	
}
