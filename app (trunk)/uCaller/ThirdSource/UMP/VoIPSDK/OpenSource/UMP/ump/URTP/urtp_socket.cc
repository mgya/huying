//
//  urtp_socket.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-27.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "urtp_socket.h"

URTPSocket::Stat::Stat()
{
	Reset();
}

void URTPSocket::Stat::Reset()
{
	_frameSent = 0;
	_lastFrameSent = 0;
	_frameRecv = 0;
	_lastFrameRecv = 0;
	_recvIdleCount = 0;
}

URTPSocket::SendAddress::SendAddress(SocketUDP & socket)
:_step(1),
_socket(socket)
{
    
}

URTPSocket::SendAddress::~SendAddress()
{
    
}

void URTPSocket::SendAddress::Reset()
{
	_step = 1;
	_lastRecvAddr = IPPort();
	
	_lan = IPPort();
	_wan = IPPort();
	_forward = IPPort();
	
}

void URTPSocket::SendAddress::SetAddress(IPPort & toSet, const IPPort & newAddr)
{
	if(newAddr == toSet)
		return;
	
	if(!newAddr.IsValid())
		return;
	
	if(!IsValid(newAddr))
		return;
	
	PWaitAndSignal lock(_mutex);
	toSet = newAddr;
	Apply();
}

void URTPSocket::SendAddress::SetLastReceive(const IPPort & addr)
{
	SetAddress(_lastRecvAddr,addr);
}

void URTPSocket::SendAddress::SetLan(const IPPort & addr)
{
	_step = 0;
	SetAddress(_lan,addr);
}

void URTPSocket::SendAddress::SetWan(const IPPort & addr)
{
	SetAddress(_wan,addr);
}

void URTPSocket::SendAddress::SetForward(const IPPort & addr)
{
	SetAddress(_forward,addr);
}

void URTPSocket::SendAddress::TryNextStep()
{
	PWaitAndSignal lock(_mutex);
	_lastRecvAddr = IPPort();
	_step++;
	Apply();
}

void URTPSocket::SendAddress::Apply()
{
	IPPort addr;
	if(_lastRecvAddr.IsValid()){
        
		addr = _lastRecvAddr;
	}else if(0 == _step){
        
		if(_lan.IsValid()){
            
			addr = _lan;
		}else{
			if(_wan.IsValid()){
                
				addr = _wan;
			}
		}
	}else if(1 == _step){
		if(_wan.IsValid()){
            
			addr = _wan;
		}
	}else{
		if(_forward.IsValid()){
            
			addr = _forward;
		}
	}
    
	if(!addr.IsValid())
		return;
    
	_socket.SetSendAddress(addr);
}

PBOOL URTPSocket::SendAddress::IsValid(const IPPort & addr)
{
	if(!addr.IsValid())
		return FALSE;
	if(addr.GetPort()==_socket.GetLocalAddress().GetPort())
	{
		PIPSocket::InterfaceTable iftbl;
		PIPSocket::GetInterfaceTable(iftbl);
		for(PINDEX i=0;i<iftbl.GetSize();i++){
			if(iftbl[i].GetAddress()==addr.GetIP())
				return FALSE;
		}
	}
	return TRUE;
}
///////////////////////////
URTPSocket::URTPSocket(USEventSink & eventSink)
:_socket(*this),
_eventSink(eventSink),
_bindIf(0),
_sendAddress(_socket),
_reflectEnable(TRUE)
{
	_timeToCheckWanAddr.SetTimeout(5*1000);
}

URTPSocket::~URTPSocket()
{
	Close();
}

static SocketEventGroup group("RTP", 256, 5,PThread::HighPriority);

const SocketEventGroup & URTPSocket::GetEventGroup()
{
	return group;
}

static PortRange portRange(5000, 5999);

PortRange & URTPSocket::GetPortRange()
{
	return portRange;
}

//
// void URTPSocket::SetSendAddress(const IPPort& addr,BOOL check)
// {
// 	if(!addr.IsValid())
// 		return;
// 	if(check){
//
// 		if(addr.GetPort()==_socket.GetLocalAddress().GetPort())
// 		{
// 			PIPSocket::InterfaceTable iftbl;
// 			PIPSocket::GetInterfaceTable(iftbl);
// 			for(PINDEX i=0;i<iftbl.GetSize();i++){
// 				if(iftbl[i].GetAddress()==addr.GetIP())
// 					return;
// 			}
// 		}
// 	}
// 	{
// 		PWaitAndSignal lock(_transportMutex);
// 		if(!(_addrs._sendAddress==addr)){
// 			_addrs._sendAddress = addr;
// 			_socket.SetSendAddress(_addrs._sendAddress);
// 		}
// 	}
//
// }


PBOOL URTPSocket::Open()
{
	Close();
    
	_timeToCheckWanAddr.Reset();
    
	IPPort bind;
	if(_bindIf.IsValid())
		bind.SetIP(_bindIf);
	
	for (PINDEX i = 0; i < 100; i++) {
		bind.SetPort(GetPortRange().GetPort());
		if (_socket.Listen(bind, 1)) {
            
            /*
             
             int v=32768;
             if (!_socket.SetOption(SO_RCVBUF,&v,sizeof(v),SOL_SOCKET)) {
             }
             
             if (!_socket.SetOption(SO_SNDBUF,&v,sizeof(v),SOL_SOCKET)) {
             }*/
            
			_socket.GetEvent().Register(e_sock_ev_read);
			_socket.GetEvent().Bind(GetEventGroup());
            
			if(_reflectEnable){
				for(int i = 0;i<3;i++){
                    
                    cout << "send reflect date to:";
                    _reflectServer.PrintOn(cout);
                    cout<<endl;
                    
					_socket.WriteTo(_reflectData,_reflectData.GetSize(),_reflectServer);
				}
                
			}
			return TRUE;
		}
	}
	return FALSE;
}

void URTPSocket::Close()
{
	_socket.GetEvent().Unregister(e_sock_ev_all);
	_socket.GetEvent().Unbind();

	_stat.Reset();
	_sendAddress.Reset();
	_socket.Close();
}

void URTPSocket::SetWanAddress(const IPPort& addr)
{
	PWaitAndSignal lock(_transportMutex);
	if (addr != _wanAddress)
		_wanAddress = addr;
}

IPPort URTPSocket::GetWanAddress() const
{
	PWaitAndSignal lock(_transportMutex);
	return _wanAddress;
}


static URTPFrame emptyFrame;
void URTPSocket::OnTick(SocketBase & socket)
{
	if(socket.IsOpen()){
		
		if(_stat._frameSent!=_stat._lastFrameSent)
			_stat._lastFrameSent = _stat._frameSent;
		else{
			Write(emptyFrame);
		}
        
		if(_stat._frameRecv==_stat._lastFrameRecv){
			_stat._recvIdleCount++;
		}else{
			_stat._lastFrameRecv = _stat._frameRecv;
			_stat._recvIdleCount=0;
		}
        
		if(_reflectEnable){
			
			if(_timeToCheckWanAddr.IsTimeout()){
				_timeToCheckWanAddr.Reset();
				if(!_wanAddress.IsValid()){
					for(int i = 0;i<3;i++){
						_socket.WriteTo(_reflectData,_reflectData.GetSize(),_reflectServer);
					}
				}
				
			}
		}
		
		
		if(_stat._recvIdleCount>2){
			_stat._recvIdleCount = 0;
			_sendAddress.TryNextStep();
		}
        
        
	}
}

void URTPSocket::OnReadable(SocketBase & socket,PBYTEArray& sharedBuffer)
{
	PINDEX len = 1024;
	BYTE* pbuffer = sharedBuffer.GetPointer(len);
	IPPort lastRecvAddr;
	if (socket.ReadFrom(pbuffer, len, lastRecvAddr)) {
		IPPort wanAddress;
		if(_reflectData.HandleData(pbuffer,len,wanAddress)){

			if (!(wanAddress == _wanAddress)) {
				{
					
					PWaitAndSignal lock(_transportMutex);
					
					_wanAddress = wanAddress;
				}
				_eventSink.OnReflect(wanAddress,_socket.GetLocalAddress());
			}
		}
		else{
            
			if(len<URTP_HEAD_SIZE)
				return;
            
			if(_cypher.HasKey())
				_cypher.Decode(pbuffer,len,pbuffer);
			
            
			URTPFrame frame(pbuffer, len);
			if(!frame.IsValid())
				return;
            
			_stat._frameRecv++;
            
			if(frame.GetPayloadSize()<1)
				return;
            
			_sendAddress.SetLastReceive(lastRecvAddr);

			_eventSink.OnURTP(pbuffer, len);
            
		}
        
	}
}

PBOOL URTPSocket::Write(const URTPFrame & urtp)
{
	if(!_socket.IsOpen())
		return FALSE;
    
	if(_cypher.HasKey()){
		PWaitAndSignal lock(_writeBufferMutex);
		_cypher.Encode(urtp,urtp.GetTotalSize(),_writeBuffer.GetPointer(urtp.GetTotalSize()));
		if(!_socket.Write(_writeBuffer,urtp.GetTotalSize()))
			return FALSE;
	}else{
		
		if(!_socket.Write(urtp, urtp.GetTotalSize()))
			return FALSE;
		
	}
	
	_stat._frameSent ++;
    
	
	return TRUE;
}
