//
//  event_nio.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__event_nio__
#define __UMPStack__event_nio__


#include "net_type.h"
#include "../Common/uutil.h"

#ifdef WITH_EPOLL
#define HAS_EPOLL
#endif

class SocketEventNIO;
class SocketBase;

class SocketEventBinder : public PObject
{
	PCLASSINFO(SocketEventBinder,PObject);
public:
	
	SocketEventBinder(SocketEventNIO & nio, PBYTEArray& sharedBuffer);
	virtual ~SocketEventBinder();
	
	void Bind(SocketBase * socket);
	void Unbind();
	void Register(int event,int handle,PBOOL urgent);
    
	void TickNow();
	
	SocketBase * GetSocket(){return _socket;}
    
public:
	PBOOL IsDeletable() const{return (NULL==_socket);}
	int GetEvent() const{return _event;}
	int GetHandle() const{return _handle;}
	
	
	void Fire(int event, PChannel::Errors result);
protected:
	SocketEventNIO & _eventNIO;
	PBYTEArray & _sharedBuffer;
	
	SocketBase *			_socket;
	
	int						_event;
	int						_handle;
	
	PMutex _mutex;
    
private:
	NonCopyable ______nocopy;
	
};

struct epoll_event;

class SocketEventNIO : public PObject
{
	PCLASSINFO(SocketEventNIO, PObject);
public:
	typedef std::list<SocketEventBinder*> EventBinderList;
	
	/**Unblock pipe for NIO model
	 */
	class UnblockPipe: PObject
	{
		PCLASSINFO(UnblockPipe,PObject);
	public:
		UnblockPipe();
		virtual ~UnblockPipe();
        
		void Open(PThread * thread);
		void Close();
        
		/**Write a piece of data to pipe to cause blocking canceled
		 */
		void Write();
        
		/**
		 */
		void Read();
        
		int GetHandle() const{return _handle;}
        
	private:
		int _handle;
		PThread * _thread;
		PAtomicInteger _length;
        
	private:
		NonCopyable ______nocopy;
		
	};
public:
	SocketEventNIO();
	virtual ~SocketEventNIO();
    
	DWORD GetMediatorCount() const;
    
    
	PBOOL Tick();
public:
	void TickNow(SocketEventBinder & binder);
	void Register(SocketEventBinder & binder);
    
	void Append(const std::vector<SocketEventBinder *> & binders);
    
	void Prepare();
	int Wait(DWORD timeout);
	void Dispatch(int num);
	void Cancel(PBOOL onExit);
    
public:
	UnblockPipe & GetUnblockPipe(){	return _unblockPipe;}
	PBYTEArray & GetSharedBuffer(){return _sharedBuffer;}
	void Clear();
private:
	UnblockPipe _unblockPipe;
    
	/** to reduce lock on EventMediatorList, we seperate
     the EventMediatorList into two parts
     */
	EventBinderList _eventBinderList;
	EventBinderList _pendingBinderList;
	PMutex _pendingBinderListMutex;
    
	EventBinderList _tickNowBinderList;
	PMutex _tickNowBinderListMutex;
    
	PBYTEArray _sharedBuffer;
#ifdef HAS_EPOLL
	int _epoll;
	epoll_event* _events;
	std::vector<epoll_event> _buffer;
	
	PBOOL _unblockPipeRegistered;
#else
	SocketFDSET _readfds;
	SocketFDSET _writefds;
	SocketFDSET _errorfds;
	
  	int _maxfd;
	struct timeval _timeout;
#endif
	DWORD _binderCount;
	DWORD _pendingBinderCount;
    
private:
	NonCopyable ______nocopy;
    
};


#endif /* defined(__UMPStack__event_nio__) */
