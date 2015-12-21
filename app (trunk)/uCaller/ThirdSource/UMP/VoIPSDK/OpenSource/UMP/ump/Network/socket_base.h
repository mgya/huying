//
//  socket_base.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__socket_base__
#define __UMPStack__socket_base__


#include "net_type.h"
#include "socket_core.h"
#include "../Common/uutil.h"


class SocketEventBinder;
///////////////////////
/** base class of ASYNC IP socket, with event callback
 */
class SocketBase : public PObject
{
	PCLASSINFO(SocketBase, PObject);
    
public:
    
	class Event
	{
		friend class SocketBase;
		friend class SocketTCP;
		friend class SocketEventBinder;
        
	public:
		Event(SocketBase & socket);
		virtual ~Event();
        
		int GetValue() const{return _value;}
        
		void Bind(const SocketEventGroup & group);
		void Unbind();
		
		int Register(int event,PBOOL urgent = FALSE);
		int Unregister(int event);
        
		void TickNow();
	public:
		static void Bind(std::vector<SocketBase * > & sockets, const SocketEventGroup & group);
	private:
		void SetBinder(SocketEventBinder * binder);
        
		void SetValue(int value){_value = value;}
        
		int _Register(int event,PBOOL urgent = FALSE);
		int _Unregister(int event);
        
	private:
		int _value;
		SocketBase & _socket;
		SocketEventBinder * _binder;
        
	private:
		NonCopyable ______nocopy;
	};
    
	class EventSink
	{
	public:
		virtual ~EventSink(){}
	public:
		virtual void OnReadable(SocketBase & socket,PBYTEArray& sharedBuffer)=0;
		virtual void OnWritable(SocketBase & socket,PBYTEArray& sharedBuffer)=0;
		virtual void OnTick(SocketBase & socket)=0;
		virtual void OnSocketOpen(SocketBase & socket)=0;
		virtual void OnConnect(SocketBase & socket,PChannel::Errors result)=0;
		virtual void OnHup(SocketBase & socket)=0;
	};
    
	friend class Event;
	friend class SocketEventBinder;
	friend class SocketTCP;
    
protected:
	virtual ~SocketBase();
public:
	virtual PBOOL Listen(
                        const IPPort & local,
                        DWORD backlog = 5,
                        PBOOL reuse = FALSE
                        );
    
	virtual PBOOL Read(void* buffer, PINDEX& len);
	virtual PBOOL ReadFrom(
                          void* buffer,
                          PINDEX & len,
                          IPPort & from
                          );
    
	virtual PBOOL Write(const void* buffer, PINDEX len);
	virtual PBOOL WriteTo(
                         const void* buffer,
                         PINDEX len,
                         const IPPort & to
                         );
    
	//µ±socket”√◊˜∑«¡˜ Ω¥´ ‰ ±£¨ø…“‘¡¢¬ÌπÿµÙ
	virtual void Close(PBOOL immediately = FALSE);
	virtual PBOOL IsOpen() const{return _core.IsOpen();}
    
    
	SocketError & GetError(){return _error;}
	Event & GetEvent(){return _event;}
	EventSink & GetEventSink(){return _eventSink;}
    
	IPPort GetLocalAddress();
	IPPort GetPeerAddress();
	
	PBOOL SetUrgent(PBOOL urgent);
	PBOOL SetLinger(PBOOL linger, unsigned short timeout);
	PBOOL SetKeepAlive(PBOOL ka);
    
	PBOOL SetOption(int option, const void* value, int vsize, int level);
	PBOOL GetOption(int option, void* value, int& vsize, int level);
    
	
	PBOOL IsReadable();
	PBOOL IsWritable();
	
	
	int GetType() const{return _type;}
    
public:
	static void Shutdown();
    int GetHandle() const {return _core.GetHandle();}
protected:
	SocketBase(int type,EventSink & eventSink);
    
	
protected:
    
	const int _type;
    
	SocketError _error;
	SocketCore _core;
	Event _event;
    
	EventSink & _eventSink;
    
private:
	NonCopyable ______nocopy;
    
};

#endif /* defined(__UMPStack__socket_base__) */
