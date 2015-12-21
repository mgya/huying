//
//  bridge_channel.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "bridge_channel.h"

#include "../Common/ump_cypher.h"

////////////////////

PBOOL BridgeChannel::BCStateMonitor::Filter(UMPHandlerBase & /*handler*/,UMPSignal & /*signal*/)
{
	return TRUE;
}
////////////////////
BridgeChannel::BCInfo::BCInfo(PBOOL isMaster)
:_beginTick(0),
_endTick(0),
_isMaster(isMaster)
{
}

BridgeChannel::BCInfo::~BCInfo()
{
}

DWORD BridgeChannel::BCInfo::GetDuration() const
{
	PWaitAndSignal lock(_mutex);
	if (_beginTick == 0)
		return 0;
	else {
		if (_endTick != 0)
			return (DWORD) (((_endTick - _beginTick) + 999) / 1000);
		else
			return (DWORD)
			(((PTimer::Tick().GetInterval() - _beginTick) + 999) / 1000);
	}
}
DWORD BridgeChannel::BCInfo::GetBeginTick() const
{
	PWaitAndSignal lock(_mutex);
	return _beginTick;
}

void BridgeChannel::BCInfo::SetBeginTick(DWORD tick)
{
	PWaitAndSignal lock(_mutex);
	_beginTick = tick;
}
DWORD BridgeChannel::BCInfo::GetEndTick() const
{
	PWaitAndSignal lock(_mutex);
	
	return _endTick;
}
void BridgeChannel::BCInfo::SetEndTick(DWORD tick)
{
	PWaitAndSignal lock(_mutex);
	_endTick = tick;
}

PString BridgeChannel::BCInfo::GetName() const
{
	PWaitAndSignal lock(_mutex);
	
	return _name;
}

void BridgeChannel::BCInfo::SetName(const PString & name)
{
	PWaitAndSignal lock(_mutex);
	
	_name = name;
}

PString BridgeChannel::BCInfo::GetUDPForwarder() const
{
	PWaitAndSignal lock(_mutex);
	return _udpForwarder;
}
void BridgeChannel::BCInfo::SetUDPForwarder(const PString & forwarder)
{
	PWaitAndSignal lock(_mutex);
	_udpForwarder = forwarder;
}

IPPort BridgeChannel::BCInfo::GetPeerAddress() const
{
	PWaitAndSignal lock(_mutex);
	return _peerAddress;
}
void BridgeChannel::BCInfo::SetPeerAddress(const IPPort & addr)
{
	PWaitAndSignal lock(_mutex);
	_peerAddress = addr;
}

IPPort BridgeChannel::BCInfo::GetSelfAddress() const
{
	PWaitAndSignal lock(_mutex);
	return _selfAddress;
}

void BridgeChannel::BCInfo::SetSelfAddress(const IPPort & addr)
{
	PWaitAndSignal lock(_mutex);
	_selfAddress = addr;
}
///////////////////
BridgeChannel::BridgeChannel(PBOOL isMaster, BCEventSink & eventSink)
:UMPHandlerBase((UMPHandlerBase::UHEventSink&)*this),
_bcEventSink(eventSink),
_bcInfo(isMaster),
_released(FALSE),
_externalReleased(FALSE),
_externalReleaseReason(e_r_ok),
_externalReleaseActor(e_actor_self),
_UDPForwarderFlag(FALSE)
{
	_bsetupTimeout.SetTimeout(20 * 1000);
	_bcStateMonitor.SetState(e_release);
    
}

BridgeChannel::~BridgeChannel()
{
}

PBYTEArray BridgeChannel::GetCypherKey() const
{
	PWaitAndSignal lock(_cypherKeyMutex);
	PBYTEArray ret = _cypherKey;
	ret.MakeUnique();
	return ret;
}

void BridgeChannel::SetCypherKey(const PBYTEArray & key)
{
	PWaitAndSignal lock(_cypherKeyMutex);
	
	_cypherKey = key;
	_cypherKey.MakeUnique();
}

void BridgeChannel::EnableUDPForwarder(PBOOL b)
{
	_UDPForwarderFlag = b;
}

PBOOL BridgeChannel::Release(E_ResultReason reason, E_Actor actor, PBOOL async)
{
	PWaitAndSignal lock(_transportMutex);//that's important
	
	U_INFO("reason:"<<reason<<",actor:"<<actor<<",async:" << async << ",externalReleased:" << _externalReleaseReason);
	if(_released)
	{
		return FALSE;
	}
    
	if(async){
		
		if(!_externalReleased){

			_externalReleaseReason = reason;
			_externalReleaseActor = actor;
			
			_externalReleased = TRUE;
			GetEvent().TickNow();
			U_INFO("end tick");
			
		}
	}else{
		InternalRelease(reason, actor);
	}
	
	return TRUE;
}


PBOOL BridgeChannel::Connect(const Sig::Bridge& bridge)
{
	_sig_bridgeSetup.SetTag(e_sig_bridgeSetup);
	if(!MakeBridgeSetup(bridge, _sig_bridgeSetup, _bcInfo.IsMaster(), GetType()))
		return FALSE;
    
	PString l = bridge.GetListener();
    U_INFO("l= " << l);
	if (!_serverAddr.FromString(l, defaultBridgePort)) {
		Release(e_r_invalidAddress, e_actor_self);
		return FALSE;
	}
    
    U_INFO("server addr = " << _serverAddr);
	_bcStateMonitor.SetState(e_connecting);

	GetEvent().Register(e_sock_ev_connect);
	if (!UMPHandlerBase::Connect(_serverAddr)) {
		Release(e_r_connectFail, e_actor_self);
		return FALSE;
	}
    
	return TRUE;
}

void BridgeChannel::OnReadSignal(UMPHandlerBase & /*handler*/,UMPSignal * signal, PBOOL & /*noDelete*/)
{
	PBOOL ret = TRUE;
	switch (signal->GetTag()) {
        case e_sig_bridgeReady:
            ret = HandleBridgeReady(*signal);
            break;
        case e_sig_release:
            ret = HandleRelease(*signal);
            break;
        default:
		{
		}
	}
	if(!ret){
	}
}

void BridgeChannel::OnReadBinary(UMPHandlerBase & /*handler*/,const void* /*bin*/, PINDEX /*size*/)
{
}

void BridgeChannel::OnTransportError(UMPHandlerBase & /*handler*/)
{
	InternalRelease(e_r_transportError, e_actor_self);
}

void BridgeChannel::OnProtocolError(UMPHandlerBase & /*handler*/)
{
	InternalRelease(e_r_protocolError, e_actor_self);
}

PBOOL BridgeChannel::OnFilter(UMPHandlerBase & handler,UMPSignal& signal)
{
	return _bcStateMonitor.Filter(handler,signal);
}

void BridgeChannel::OnConnect(UMPHandlerBase & /*handler*/, PChannel::Errors result)
{
	if (result == PChannel::NoError) {
		_bcStateMonitor.SetState(e_connected);
		_bsetupTimeout.Reset();
		UMPCypher::RandomKey initKey(INIT_KEY_SIZE);
		GetCypher().SetKey(initKey, INIT_KEY_SIZE);
		
		Write(initKey,INIT_KEY_SIZE);
        
		Sig::BridgeSetup(_sig_bridgeSetup).SetUDPForwarderFlag(_UDPForwarderFlag);
        
		WriteSignal(_sig_bridgeSetup);
        
		GetEvent().Register(e_sock_ev_tick | e_sock_ev_read,TRUE);
		
	} else {
		InternalRelease(e_r_connectFail, e_actor_self);
	}
}

void BridgeChannel::OnTick(UMPHandlerBase & /*handler*/)
{
	switch (_bcStateMonitor.GetState()) {
        case e_connected:
            if (_bsetupTimeout.IsTimeout()) {
                InternalRelease(e_r_timeout, e_actor_self);
            }break;
        case e_release:
		{
			if(_bcStateMonitor.GetStartTimeout().GetTimeout() == 0){
				_bcStateMonitor.GetStartTimeout().SetTimeout(30*1000);
			} else {
				if(_bcStateMonitor.GetStartTimeout().IsTimeout()){
					_bcStateMonitor.GetStartTimeout().SetTimeout((DWORD)-1);
					InternalRelease(e_r_timeout,e_actor_self);
				}
			}
		}break;
        default:
            break;
	}
    
	if(!_released){
		if(_externalReleased)
		{
			InternalRelease(_externalReleaseReason,_externalReleaseActor);
		}
	}
	
}

PBOOL BridgeChannel::HandleBridgeReady(const Sig::BridgeReady & bridgeReady)
{
	_bcInfo.SetName(bridgeReady.GetName());
	_bcInfo.SetUDPForwarder(bridgeReady.GetUDPForwarder());
    
	IPPort paddr;
	paddr.FromString(bridgeReady.GetPeerAddress(),0);
	_bcInfo.SetPeerAddress(paddr);
	IPPort saddr;
	saddr.FromString(bridgeReady.GetSelfAddress(),0);
	_bcInfo.SetSelfAddress(saddr);
	
	_bcStateMonitor.SetState(e_ready);
	{
		PWaitAndSignal lock(_cypherKeyMutex);
		
		if (_cypherKey.GetSize() > 0) {
			GetCypher().SetKey(_cypherKey);
		}else{
			GetCypher().SetKey(NULL,0);
		}
	}
    
	
	GetEvent().Register(e_sock_ev_write);
	_bcEventSink.OnReady(*this);
	return TRUE;
}

void BridgeChannel::InternalRelease(E_ResultReason reason, E_Actor actor)
{
	U_WARN("fordbg:enter internal release");
	if(_released)
		return;
	_released = TRUE;
	
	if(_externalReleased){
		reason = _externalReleaseReason;
		actor = _externalReleaseActor;
	}
    
	if (actor == e_actor_self&&_bcStateMonitor.GetState()==e_ready){
		UMPSignal sig_release(e_sig_release);
		Sig::Release release(sig_release);
		release.SetResult(reason);
		WriteSignal(sig_release);
	}
	
	_bcStateMonitor.SetState(e_release);
	
//	if (IsOpen()){
//		Close();
//	}
	_bcInfo.SetEndTick(PTimer::Tick().GetInterval());

	U_WARN("fordbg:enter internal release,onrelease");
	_bcEventSink.OnRelease(*this,reason, actor);

	//_bcStateMonitor.SetState(e_release);

	if (IsOpen()){
		Close();
	}
	
}

PBOOL BridgeChannel::HandleRelease(const Sig::Release & release)
{
	InternalRelease(release.GetResult(), e_actor_peer);
	return TRUE;
}

PBOOL BridgeChannel::MakeBridgeSetup(const Sig::Bridge& bridge,
                                    UMPSignal& sig_bridgeSetup, PBOOL isMaster, E_InteractType type)
{
	sig_bridgeSetup.Clear();
	sig_bridgeSetup.SetTag(e_sig_bridgeSetup);
	Sig::BridgeSetup bridgeSetup(sig_bridgeSetup);
    
	PBYTEArray guid = bridge.GetGUID();
	if (guid.GetSize() != GUID_SIZE) {
		return FALSE;
	}
    
	PBYTEArray key = bridge.GetKey();
	if (key.GetSize() < 1) {
		return FALSE;
	}
    
	bridgeSetup.SetMasterFlag(isMaster);
	bridgeSetup.SetBridgeGUID(guid);
	bridgeSetup.SetEncryptGUID(UMPCypher::TEA(key).Encode(guid));
    
	PBYTEArray halfKey;
	if (isMaster) {
		PINDEX halfKeySize = key.GetSize() / 2;
		halfKey.SetSize(halfKeySize);
		memcpy(halfKey.GetPointer(), key, halfKeySize);
	} else {
		PINDEX halfKeySize = key.GetSize() - (key.GetSize() / 2);		
		halfKey.SetSize(halfKeySize);
		memcpy(halfKey.GetPointer(), key + (key.GetSize() - halfKeySize),
               halfKeySize);
	}
	bridgeSetup.SetHalfKey(halfKey);
	bridgeSetup.SetType(type);
	return TRUE;
}
