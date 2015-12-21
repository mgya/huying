//
//  bridge_channel.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__bridge_channel__
#define __UMPStack__bridge_channel__


#include "ump_handler.h"

//Base class for communication session between client which need bridge
//
class BridgeChannel : public UMPHandlerBase, public UMPHandlerBase::UHEventSink
{
	PCLASSINFO(BridgeChannel, UMPHandlerBase)
    
public:
	class BCInfo
	{
	public:
		BCInfo(PBOOL isMaster);
		virtual ~BCInfo();
        
		DWORD GetBeginTick() const;
		void SetBeginTick(DWORD tick);
        
		DWORD GetEndTick() const;
		void SetEndTick(DWORD tick);
        
		PString GetName() const;
		void SetName(const PString & name);
        
        
		PString GetUDPForwarder() const;
		void SetUDPForwarder(const PString & forwarder);
        
		PINLINE PBOOL IsMaster() const {return _isMaster;}
		DWORD GetDuration() const;
        
		IPPort GetPeerAddress() const;
		void SetPeerAddress(const IPPort & addr);
        
		IPPort GetSelfAddress() const;
		void SetSelfAddress(const IPPort & addr);
        
	private:
		
		DWORD _beginTick;
		DWORD _endTick;
		PString _name;
        
		PString _udpForwarder;
        
		const PBOOL _isMaster;//Caller:true,Callee:false
        
		IPPort _peerAddress;
		IPPort _selfAddress;
		
        
		PMutex _mutex;
		
		
	};
	class BCEventSink
	{
	public:
		virtual ~BCEventSink(){}
	public:
		virtual void OnReady(BridgeChannel & channel) = 0;
		virtual void OnRelease(BridgeChannel & channel,E_ResultReason reason, E_Actor actor) = 0;
		
	};
	enum E_BridgeState {
		e_release,
		e_connecting,
		e_connected,
		e_ready,
	};
    
	class BCStateMonitor: public UMPHandlerBase::StateMonitor<E_BridgeState>
	{
		PCLASSINFO(BCStateMonitor,StateMonitor<E_BridgeState>);
	public:
		BCStateMonitor()
        :StateMonitor<E_BridgeState>(e_release)
		{
		}
		virtual PBOOL Filter(UMPHandlerBase & handler,UMPSignal & signal);
        
		Timeout & GetStartTimeout() {return _startTimeout;}
		
	private:
		Timeout _startTimeout;
		
	};
    
	BridgeChannel(PBOOL isMaster, BCEventSink & eventSink);
	virtual ~BridgeChannel();
    
	virtual PBOOL Connect(const Sig::Bridge& bridge);
	virtual PBOOL Release(E_ResultReason reason, E_Actor actor, PBOOL async = TRUE);
    
    
public:
	virtual E_InteractType GetType() const = 0;
    
public:
    
	void EnableUDPForwarder(PBOOL b);
	
	PBYTEArray GetCypherKey() const;
	void SetCypherKey(const PBYTEArray & key);
    
    
	const BCStateMonitor & GetBCStateMonitor() const{return _bcStateMonitor;}
    
	BCInfo & GetBCInfo() {return _bcInfo;}
	
public:
	static PBOOL MakeBridgeSetup(const Sig::Bridge& bridge,
                                UMPSignal& sig_bridgeSetup, PBOOL isMaster, E_InteractType type);
    
protected:
	void OnReadSignal(UMPHandlerBase & handler,UMPSignal * signal, PBOOL & noDelete);
	void OnReadBinary(UMPHandlerBase & handler,const void* bin, PINDEX size);
	
	
	void OnTransportError(UMPHandlerBase & handler);
	void OnProtocolError(UMPHandlerBase & handler);
	PBOOL OnFilter(UMPHandlerBase & handler,UMPSignal& signal);
	
	void OnConnect(UMPHandlerBase & handler, PChannel::Errors result);
	void OnTick(UMPHandlerBase & handler);
    
    
protected:
    
	void InternalRelease(E_ResultReason reason, E_Actor actor);
    
	PBOOL HandleBridgeReady(const Sig::BridgeReady & bridgeReady);
	PBOOL HandleRelease(const Sig::Release & release);
    
protected:
	Timeout _bsetupTimeout;
    
protected:
	PMutex _transportMutex;
	
	BCStateMonitor _bcStateMonitor;
	BCEventSink & _bcEventSink;
	BCInfo _bcInfo;
    
	PBOOL _released;
	UMPSignal _sig_bridgeSetup;
    
	PBYTEArray _cypherKey;
	PMutex _cypherKeyMutex;
    
	PBOOL _externalReleased;
	E_ResultReason _externalReleaseReason;
	E_Actor _externalReleaseActor;
    
	PBOOL _UDPForwarderFlag;
    
	IPPort _serverAddr;
    
    
};


#endif /* defined(__UMPStack__bridge_channel__) */
