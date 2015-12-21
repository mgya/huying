//
//  urtp_socket.h
//  UMPStack
//
//  Created by thehuah on 14-3-27.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__urtp_socket__
#define __UMPStack__urtp_socket__

#include "../Common/pcommon.h"
#include "../Common/ump_cypher.h"
#include "../Network/socket_udp.h"
#include "urtp_frame.h"
#include "urtp_reflect_data.h"

class URTPSocket : public PObject, public SocketBase::EventSink
{
	PCLASSINFO(URTPSocket, PObject);
	friend class UPPSession;
public:
	class USEventSink
	{
	public:
		virtual ~USEventSink(){}
	public:
		virtual void OnReflect(const IPPort & wan,const IPPort & lan) = 0;
		virtual void OnURTP(const BYTE * urtp, DWORD len) = 0;
        
	};
    
	class Stat
	{
	public:
		Stat();
		void Reset();
	public:
		DWORD _frameSent;
		DWORD _lastFrameSent;
		
		DWORD _frameRecv;
		DWORD _lastFrameRecv;
		
		DWORD _recvIdleCount;
	};
    
    
	class SendAddress
	{
	public:
		SendAddress(SocketUDP & socket);
		virtual ~SendAddress();
        
		void Reset();
        
		void SetLastReceive(const IPPort & addr);
        
		void SetLan(const IPPort & addr);
		void SetWan(const IPPort & addr);
		void SetForward(const IPPort & addr);
        
		void TryNextStep();
        
        
		PBOOL IsValid(const IPPort & addr);
	private:
		void SetAddress(IPPort & toSet, const IPPort & newAddr);
	private:
		void Apply();
	private:
		IPPort _lastRecvAddr;
        
		IPPort _lan;
		IPPort _wan;
		IPPort _forward;
        
		int _step;
        
		SocketUDP & _socket;
		PMutex _mutex;
	};
    
public:
	URTPSocket(USEventSink & eventSink);
	virtual ~URTPSocket();
    
	virtual PBOOL Open();
	virtual void Close();
    
	PBOOL Write(const URTPFrame & urtp);
    
	IPPort GetWanAddress() const;
	void SetWanAddress(const IPPort& addr);
    
	SocketBase & GetSocket(){return _socket;}
    
	UMPCypher::TEA & GetCypher(){return _cypher;}
	Stat & GetStat() {return _stat;}
    
	SendAddress & GetSendAddress(){return _sendAddress;}
    
	void SetBindInterface(const IP & bindIf){_bindIf = bindIf;}
	void SetReflectServer(const IPPort & server){_reflectServer = server;}
	void SetReflectEnable(PBOOL b){_reflectEnable = b;}
    
public:
	static const SocketEventGroup & GetEventGroup();
	static PortRange & GetPortRange();
    
protected:
    
	void OnReadable(SocketBase & socket,PBYTEArray& sharedBuffer);
	void OnWritable(SocketBase & /*socket*/,PBYTEArray& /*sharedBuffer*/){}
	void OnTick(SocketBase & socket);
	void OnSocketOpen(SocketBase & /*socket*/){}
	void OnConnect(SocketBase & /*socket*/,PChannel::Errors /*result*/){}
	void OnHup(SocketBase & /*socket*/){}
    
protected:
    
	SocketUDP _socket;
    
	USEventSink & _eventSink;
    
	PBYTEArray _writeBuffer;
	PMutex _writeBufferMutex;
    
	PMutex _transportMutex;
    
	UMPCypher::TEA _cypher;
    
	Stat _stat;
    
	IPPort _wanAddress;
	IPPort _reflectServer;
	IP _bindIf;
    
	SendAddress _sendAddress;
    
	Timeout _timeToCheckWanAddr;
	URTPReflectData _reflectData;
	PBOOL _reflectEnable;
};

#endif /* defined(__UMPStack__urtp_socket__) */
