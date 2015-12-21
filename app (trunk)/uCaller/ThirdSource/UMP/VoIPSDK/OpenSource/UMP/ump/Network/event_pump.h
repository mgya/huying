//
//  event_pump.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__event_pump__
#define __UMPStack__event_pump__

#include "event_nio.h"
#include "singleton.h"
#include "net_type.h"

#include "../Common/uutil.h"

/** event pump class, thread to wait/dispatch socket IO event.
 large amount of sockets can be handled, with high performence.
 
 on win32 and linux<=2.4			traditional "select"
 on linux>=2.6						"epoll"
 
 */
class SocketEventPump : public PPooledThread
{
	PCLASSINFO(SocketEventPump, PPooledThread);
public:
	SocketEventPump(const SocketEventGroup & group);
	virtual ~SocketEventPump();
    
    
	/** break the blocking operation while waiting for socket IO event
     */
	void Cancel();
    
	void Append(const std::vector<SocketEventBinder *> & binders);
    
    
	DWORD GetSpaceFree();
    
	DWORD GetIdleTime() const;
    
	SocketEventNIO & GetEventNIO(){return _eventNIO;}
    
private:
	/** entry of pump thread
     */
	void Main();
protected:
    
private:
	const SocketEventGroup _group;
	
	volatile PBOOL _shutdown;
    
	SocketEventNIO  _eventNIO;
	
	DWORD _idleTime;
    
private:
	NonCopyable ______nocopy;
    
};

////////////////////////////



/////////////////////////

/** to manage all event pumps
 */
class SocketEventPumpManager:
public PPooledThread,
public Singleton< SocketEventPumpManager>
{
	PCLASSINFO(SocketEventPumpManager, PObject);
public:
	/** delayed socket close thread
     we always close socket gracefully
	 */
	class SocketCloser: public PObject
	{
		PCLASSINFO(SocketCloser, PObject);
	public:
		SocketCloser();
		virtual ~SocketCloser();
        
		void CloseSocket(int handle);
		
		PBOOL TryRealClose();
	protected:
		typedef std::list<int> HandleList;
		HandleList _handleList;
		PMutex _handleListMutex;
        
		
	};
    
public:
	SocketEventPumpManager();
	virtual ~SocketEventPumpManager();
    
	/** Bind socket(s) to event pump(s)
	 */
	void Bind(std::vector<SocketBase * > & sockets,const SocketEventGroup & group);
    
    
	SocketCloser & GetSocketCloser()
	{
		return _socketCloser;
	}
    
private:
	/** clean dead event pump and ...
	 */
	void Main();
	
private:
	SocketCloser _socketCloser;
    
	typedef std::list<SocketEventPump*> PumpList;
	typedef std::map<PString,PumpList> GroupToPumpList;
	
	GroupToPumpList _groupToPumpList;
	
	PMutex _groupToPumpListMutex;
    
	PSyncPoint _sync;
	volatile PBOOL _end;
};

#endif /* defined(__UMPStack__event_pump__) */
