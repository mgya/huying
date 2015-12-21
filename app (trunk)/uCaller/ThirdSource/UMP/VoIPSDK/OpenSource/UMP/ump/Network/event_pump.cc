//
//  event_pump.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "event_pump.h"

#include "socket_base.h"

#include "../Common/pprocess.h"

#if (_MSC_VER >= 1200)
#pragma warning(disable:4355)
#endif



SocketEventPump::SocketEventPump(const SocketEventGroup& group)
:_group(group),_shutdown(FALSE),_idleTime(0)
{
	PPooledThread::Start(_group.GetPriority());
}

SocketEventPump::~SocketEventPump()
{
	_shutdown = TRUE;
	_eventNIO.Cancel(TRUE);
	Join();
}

void SocketEventPump::Cancel()
{
	_eventNIO.Cancel(FALSE);
}

void SocketEventPump::Main()
{
	_eventNIO.GetUnblockPipe().Open(PThread::Current());
	
	DWORD loopTick = 0;
	DWORD eventTick = PTimer::Tick().GetInterval();
	const DWORD delay = _group.GetDelay();
	DWORD now=0;
	while (!_shutdown) {
		
		if(delay>0)
			loopTick = PTimer::Tick().GetInterval();
		
		_eventNIO.Prepare();
		/** do event wait
         */
		int n = _eventNIO.Wait(1000);
		if(n >= 0){
            /** dispatch events
             */
			_eventNIO.Dispatch(n);
		} else {
			
			PChannel::Errors err;
			int oserr;
			SocketError::Convert(n, err, oserr);
			PTRACE(5,
                   "INFO\t" << GetClass() << " _eventNIO.Wait failed for "
                   << SocketError::GetText(err, oserr));
			PThread::Sleep(50);
		}
		
		
		now = PTimer::Tick().GetInterval();
		/** perform delay option
         */
		if (delay > 0) {
			
			if ((now - loopTick) < delay) {
				
				PThread::Sleep(delay - (now - loopTick));
			}
		}
		
		/** do tick event
         */
		if (now - eventTick >= 1000) {
			if(_eventNIO.Tick())
				_idleTime=0;
            else{
//                U_INFO("_idleTime = "<<_idleTime);
                _idleTime++;
            }
        
			eventTick = now;
		}
//        U_INFO("tick start");
		
	}
	
	_eventNIO.Clear();
	_eventNIO.GetUnblockPipe().Close();
    
}

DWORD SocketEventPump::GetSpaceFree()
{
	DWORD used = _eventNIO.GetMediatorCount();
	PAssert(used <= _group.GetMaxSockCount(), "SocketEventPump overflow");
	return (_group.GetMaxSockCount() - used);
}

DWORD SocketEventPump::GetIdleTime() const
{
	return _idleTime;
}

void SocketEventPump::Append(const std::vector<SocketEventBinder *> & binders)
{
	_idleTime = 0;
	_eventNIO.Append(binders);
    
}
///////////////////////////////////////


SocketEventPumpManager::SocketCloser::SocketCloser()
{
    
}

SocketEventPumpManager::SocketCloser::~SocketCloser()
{
    
}

void SocketEventPumpManager::SocketCloser::CloseSocket(int handle)
{
	if(handle < 0)
		return;
    
	/**linux has bug on non-blocking linger socket, we shoud shutdown here
     to prevent many sockets blocking on close.
     */
	::shutdown(handle,2);
	PWaitAndSignal lock(_handleListMutex);
	_handleList.push_back(handle);
}

PBOOL SocketEventPumpManager::SocketCloser::TryRealClose()
{

#define _closesocket	close

	int handle = -1;
	{
		PWaitAndSignal lock(_handleListMutex);
		if(!_handleList.empty()){
			handle = _handleList.front();
			_handleList.pop_front();
		}
	}
	if(handle < 0)
		return FALSE;
	::shutdown(handle, 2);
	if(::_closesocket(handle) == 0){
		//successful
		return TRUE;
	}
	
	switch(errno){
        case EBADF:
            break;
        default:
            CloseSocket(handle);
            break;
	}
	PTRACE(5,
           "INFO\t" << GetClass() << " failed to close socket h="
           << handle);
    
	return FALSE;
    
}

///////////////////////////////////////////
SocketEventPumpManager::SocketEventPumpManager()
:Singleton<SocketEventPumpManager>("SocketEventPumpManager"),
_end(FALSE)

{
	Start();
}

SocketEventPumpManager::~SocketEventPumpManager()
{
	{
		PWaitAndSignal lock(_groupToPumpListMutex);
		GroupToPumpList::iterator it=_groupToPumpList.begin(),eit=_groupToPumpList.end();
		while(it!=eit){
			DeleteObjectsInContainer(it->second);
			it++;
		}
		_groupToPumpList.clear();
	}
    
    
	_end = TRUE;
	_sync.Signal();
	Join();
	
}

void SocketEventPumpManager::Bind(std::vector<SocketBase * > & sockets,const SocketEventGroup & group)
{
	PAssert(sockets.size() <=
            group.GetMaxSockCount(),
            "SocketEventPumpManager::Bind\tcount must <= group.GetMaxSockCount()");
    
	PWaitAndSignal lock(_groupToPumpListMutex);
	SocketEventPump* pump = NULL;
    
    
	PString groupStr = group.ToString();
	PumpList & plist = _groupToPumpList[groupStr];
	
	
	DWORD maxFree = sockets.size();
	
	{
		PumpList::iterator it = plist.begin(),eit=plist.end();
		while(it!=eit){
            
			SocketEventPump * p=*(it++);
			
			DWORD f = p->GetSpaceFree();
			if (f >= maxFree) {
                
				maxFree = f;
				pump = p;
				if(f>group.GetMaxSockCount()/2)
					break;
			}
			
		}
	}
	if (pump == NULL) {
		pump = new SocketEventPump(group);
		plist.push_back(pump);
        
	}
	
	std::vector<SocketEventBinder * > binders;
    
	{
		
		for (DWORD i = 0; i < sockets.size(); i++) {
			SocketEventBinder * binder = new SocketEventBinder(pump->GetEventNIO(),pump->GetEventNIO().GetSharedBuffer());
			sockets[i]->GetEvent().Unbind();
			binder->Bind(sockets[i]);
            
			binders.push_back(binder);
		}
	}
	
	pump->Append(binders);
	
	pump->Cancel();
}



void SocketEventPumpManager::Main()
{
	do{
        
		if(_socketCloser.TryRealClose())
			continue;
        
        
		PumpList idles;
        
		{
			PWaitAndSignal lock(_groupToPumpListMutex);
			GroupToPumpList::iterator it =_groupToPumpList.begin(),
            eit=_groupToPumpList.end();
            
			while(it!=eit){
                
				PumpList& l = it->second;
				/** find out dead event pumps
				 */
				PumpList::iterator i=l.begin(),e=l.end();
				while(i!=e){
                    
					SocketEventPump * pump=*i;
					
					if (pump->GetIdleTime() > 300) {
						idles.push_back(pump);
						i=l.erase(i);
					}else
						i++;
				}
				/** destroy the dead event pumps
				 */
				if (l.empty())
					_groupToPumpList.erase(it++);
				else
					it++;
			}
		}
		DeleteObjectsInContainer(idles);
		idles.clear();
        
		_sync.Wait(1000);
	}while(!_end);
    
}


////////////////////////////////////

class SocketStartup : public PProcessStartup
{
	PCLASSINFO(SocketStartup, PProcessStartup);
public:
    void OnStartup()
    { 
        
    }
	
    void OnShutdown()
    {
		SocketEventPumpManager::DestroyInstance();
    }	
protected:
};

static PFactory<PProcessStartup>::Worker<SocketStartup> socketStartupFac("SocketStartup", true);