//
//  upp_session.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-10.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "upp_session.h"

#include "../Common/pudpsock.h"

#define AUDIO_CHANNEL_NUMBER 0

#define DEFAULT_RTP_PORT 21000
////////////////////
#define SUPPORT_RAC	1	//support redundant audio coding
///////////////////

UPPSession::OutbandDTMFKeeper::OutbandDTMFKeeper()
{
}

PString UPPSession::OutbandDTMFKeeper::Pop()
{
	PWaitAndSignal lock(_mutex);
	PString ret = _dtmf;
	_dtmf.MakeEmpty();
	return ret;
}

PBOOL UPPSession::OutbandDTMFKeeper::IsEmpty()
{
	return _dtmf.IsEmpty();
}
void UPPSession::OutbandDTMFKeeper::Push(const PString & dtmf)
{
	PWaitAndSignal lock(_mutex);
	_dtmf +=dtmf;
}

void UPPSession::OutbandDTMFKeeper::Clear()
{
	PWaitAndSignal lock(_mutex);
	_dtmf.MakeEmpty();
}

///////////////////

UPPSession::RemoteInfo::RemoteInfo()
:_version(0),
_phoneType(e_pt_unknown),
_acceptInbandDTMF(FALSE),
_noRouter(FALSE),
_supportRAC(FALSE)
{
}

UPPSession::URTPStat::URTPStat()
{
	Reset();
}

void UPPSession::URTPStat::Reset()
{
	_frameCount = 0;
	_lostCount = 0;
	_lastFrameCount =0;
	_lastLostCount =0;
}

DWORD UPPSession::URTPStat::GetLostFraction()
{
	DWORD fraction = 0;
	DWORD deltaCount = _frameCount - _lastFrameCount;
	DWORD deltaLostCount = _lostCount - _lastLostCount;
	
	if (deltaCount != 0)
		fraction = deltaLostCount * 256 / deltaCount;
	
	_lastFrameCount = _frameCount;
	_lastLostCount = _lostCount;
	return fraction;
}

///////////////////

PBOOL UPPSession::UPPStateMonitor::Filter(UMPHandlerBase & /*handler*/,UMPSignal & signal)
{
	if (_session.GetBCStateMonitor().GetState() == e_ready) {
		const E_UMPTag tag=signal.GetTag();
		switch(tag){
            case e_sig_dtmf:
            case e_sig_durationLimit:
            case e_sig_urtpReport:
            case e_sig_forward:
            case e_sig_urtpTransport:
            case e_sig_callIndicator:
                return TRUE;
            default:
                break;
		}
		
		switch (GetState()) {
            case e_upps_idle:
                if (tag != e_sig_callSetup && tag != e_sig_release)
                    return FALSE;
                break;
            case e_upps_proceed:
                if (tag != e_sig_release &&
                    tag != e_sig_openChannel &&
                    tag != e_sig_closeChannel)
                    return FALSE;
                break;
            case e_upps_setup:
                if (tag != e_sig_callAlert &&
                    tag != e_sig_release &&
                    tag != e_sig_callConnect &&
                    tag != e_sig_openChannel &&
                    tag != e_sig_closeChannel)
                    return FALSE;
                break;
            case e_upps_alert:
                if (tag != e_sig_callConnect &&
                    tag != e_sig_release &&
                    tag != e_sig_openChannel &&
                    tag != e_sig_closeChannel)
                    return FALSE;
                break;
            case e_upps_connect:
                if (tag != e_sig_release &&
                    tag != e_sig_openChannel &&
                    tag != e_sig_closeChannel)
                    return FALSE;
                break;
		}
	}
	return TRUE;
}

////////////////////
UPPSession::UPPStateMonitor::UPPStateMonitor(UPPSession & session)
:UMPHandlerBase::StateMonitor<E_UPPState>(e_upps_idle),
_session(session),
_answered(FALSE)
{
	_setupTimeout.SetTimeout(20 * 1000);
	_alertTimeout.SetTimeout(30 * 1000);
	_connectTimeout.SetTimeout(120 * 1000);
	
	_urtpReportTimeout.SetTimeout(10 * 1000);
}

/////////////////////
UPPSession::UPPSession(
					   PBOOL isMaster,
					   UPPSEventSink & eventSink)
: BridgeChannel(isMaster,*this),
_uppStateMonitor(*this),
_outbandDTMFDetection(FALSE),
_uppsEventSink(eventSink),
_noRouter(FALSE),
_channelOpened(FALSE),
_isRecvCallReleaseSignal(FALSE)
{
	_localIP = GetLocalAddress().GetIP();
	_localRTPPort = PUDPSocket::GetLocalPort(DEFAULT_RTP_PORT);
	_channelNumber = AUDIO_CHANNEL_NUMBER;
    EnableUDPForwarder(TRUE);
	GetEvent().Register(e_sock_ev_read|e_sock_ev_tick);
    GetEvent().Bind(SocketEventGroup("UPPSession"));

    _cap = e_chc_g729;
}

UPPSession::UPPSession(
					   PBOOL isMaster,
					   UPPSEventSink & eventSink,
					   const IPPort & reflectServer)
: BridgeChannel(isMaster,*this),
_uppStateMonitor(*this),
_outbandDTMFDetection(FALSE),
_uppsEventSink(eventSink),
_noRouter(FALSE),
_channelOpened(FALSE)
{
	_localIP = GetLocalAddress().GetIP();
	_localRTPPort = PUDPSocket::GetLocalPort(DEFAULT_RTP_PORT);
	_channelNumber = AUDIO_CHANNEL_NUMBER;
    EnableUDPForwarder(TRUE);
	GetEvent().Register(e_sock_ev_read|e_sock_ev_tick);
    GetEvent().Bind(SocketEventGroup("UPPSession"));

    _cap = e_chc_g729;
}

UPPSession::~UPPSession()
{
	Release(e_r_interrupted, e_actor_self,FALSE);
	GetEvent().Unbind();
}

IPPort UPPSession::GetURTPWan()
{
	return _urtpWan;
}

IP UPPSession::GetLocalIP()
{
	return _localIP;
}

WORD UPPSession::GetLocalRTPPort()
{
	return _localRTPPort;
}

WORD UPPSession::GetPayloadType()
{
	WORD pt = 0;
	if(_cap == e_chc_g711a)
	{
		pt = 8;
	}
	else if(_cap == e_chc_g711u)
	{
		pt = 0;
	}
	else if(_cap == e_chc_g729)
	{
		pt = 18;
	}
	return pt;
}

PBOOL UPPSession::IsRecvCallReleaseSignal()
{
	return _isRecvCallReleaseSignal;
}

PBOOL UPPSession::Answer()
{
	PWaitAndSignal lock(_transportMutex);
	if (GetBCInfo().IsMaster() ||
		_uppStateMonitor.GetState() != e_upps_alert)
		return FALSE;
	
    WriteURTPTransport();
	
	UMPSignal sig_callConnect(e_sig_callConnect);
	Sig::CallConnect callConnect(sig_callConnect);
	
	callConnect.SetAcceptInbandDTMF(TRUE);
	
	OnWriteCallSignal(sig_callConnect);
	
	WriteSignal(sig_callConnect);
	
	_uppStateMonitor.SetAnswered(TRUE);
	GetEvent().TickNow();
	return TRUE;
}

PBOOL UPPSession::WriteDTMF(const PString & dtmf)
{
	if (GetBCStateMonitor().GetState() != e_ready)
		return FALSE;
	
	if (!GetBCInfo().IsMaster() && GetUPPStateMonitor().GetState() != e_upps_connect)
		return FALSE;
	
	if (_remoteInfo._acceptInbandDTMF){
		UMPSignal sig_dtmf(e_sig_dtmf);
		Sig::DTMF(sig_dtmf).SetDTMF(dtmf);
		return WriteSignal(sig_dtmf);
	}else{
		_outbandDTMFKeeper.Push(dtmf);
		return TRUE;
	}
}

void UPPSession::SetOutbandDTMFDetection(PBOOL b)
{
	_outbandDTMFDetection = b;
}

PBOOL UPPSession::GetOutbandDTMFDetection() const
{
	return _outbandDTMFDetection;
}

void UPPSession::SetLocalCapabilities(const ChannelCapabilityArray & caps)
{
	if(!_capabilityArray.empty()){
		return;
	}
    
	for(DWORD i=0;i<caps.size();i++){
		E_ChannelCapability cap = caps[i];
        {
			if(_capabilityMap.find(cap) == _capabilityMap.end()){
				_capabilityMap[cap] = true;
				_capabilityArray.push_back(cap);
			}
		}
	}
    
}

void UPPSession::SetRemoteCapabilities(const ChannelCapabilityArray & caps)
{
	if(caps.empty())
		return;
	if(!_remoteInfo._capabilityArray.empty()){
		return;
	}
    
	for(unsigned i=0;i<caps.size();i++){
		E_ChannelCapability cap = (E_ChannelCapability)caps[i];
		if(_remoteInfo._capabilityMap.find(cap) == _remoteInfo._capabilityMap.end()){
			_remoteInfo._capabilityMap[cap] = true;
			_remoteInfo._capabilityArray.push_back(cap);
		}
	}
}

PBOOL UPPSession::OnFilter(UMPHandlerBase & handler,UMPSignal& signal)
{
	if(!BridgeChannel::OnFilter(handler,signal))
		return FALSE;
	
	return _uppStateMonitor.Filter(handler,signal);
	
}

void UPPSession::OnTick(UMPHandlerBase & handler)
{
	PWaitAndSignal lock(_transportMutex);
    
	_uppsEventSink.OnUPPSTick(*this);
    
	BridgeChannel::OnTick(handler);
    
	if (GetBCStateMonitor().GetState() == e_ready) {

		if (_uppStateMonitor.GetState() == e_upps_idle) {
			if (!GetBCInfo().IsMaster()) {
				if (_uppStateMonitor.GetSetupTimeout().IsTimeout()) {
					InternalRelease(e_r_timeout, e_actor_self);
				}
			}
		} else {
			if(GetBCInfo().IsMaster()){
				switch(_uppStateMonitor.GetState()){
                    case e_upps_setup:
                        if (_uppStateMonitor.GetAlertTimeout().IsTimeout()) {
                            InternalRelease(e_r_timeout, e_actor_self);
                        }
                        break;
                    case e_upps_alert:
                        if (_uppStateMonitor.GetConnectTimeout().IsTimeout()) {
                            InternalRelease(e_r_noAnswer, e_actor_self);
                        }
                        break;
                    default:
                        break;
				}
			}else{
				if(_uppStateMonitor.GetState() == e_upps_alert&&
                   _uppStateMonitor.IsAnswered()){
                    
					_uppStateMonitor.SetState(e_upps_connect);
					_bcInfo.SetBeginTick(PTimer::Tick().GetInterval());
					_uppsEventSink.OnConnect(*this);
				}
			}
            
		}
	}
}

void UPPSession::OnReadSignal(UMPHandlerBase & handler,UMPSignal * signal,PBOOL & noDelete)
{
	PWaitAndSignal lock(_transportMutex);
	PBOOL ret = TRUE;
	switch (signal->GetTag()) {
        case e_sig_callSetup:
            ret = HandleCallSetup(*signal);
            break;
        case e_sig_callAlert:
            ret = HandleCallAlert(*signal);
            break;
        case e_sig_callConnect:
            ret = HandleCallConnect(*signal);
            break;
        case e_sig_openChannel:
            ret = HandleOpenChannel(*signal);
            break;
        case e_sig_closeChannel:
            ret = HandleCloseChannel(*signal);
            break;
        case e_sig_urtpReport:
            ret = HandleURTPReport(*signal);
            break;
        case e_sig_durationLimit:
            ret = HandleDurationLimit(*signal);
            break;
        case e_sig_dtmf:
            ret = HandleDTMF(*signal);
            break;
        case e_sig_forward:
            ret = HandleForward(*signal);
            break;
        case e_sig_urtpTransport:
            ret = HandleURTPTransport(*signal);
            break;
        case e_sig_callIndicator:
            ret = HandleCallSignal(*signal);
            break;
        default:
		{
			BridgeChannel::OnReadSignal(handler,signal,noDelete);
		}
	}
    
	if(!ret){
	}
}

void UPPSession::OnReadBinary(UMPHandlerBase & /*handler*/,const void* bin, PINDEX len)
{
}

PBOOL UPPSession::HandleCallSignal(const Sig::CallSignal & callSig)
{
    WriteURTPTransport();
	
	if(!_remoteInfo._acceptInbandDTMF)
		_remoteInfo._acceptInbandDTMF = callSig.GetAcceptInbandDTMF();
	
	if (0 == _remoteInfo._version)
		_remoteInfo._version = callSig.GetVersion();
	if (0 == _remoteInfo._phoneType)
		_remoteInfo._phoneType = callSig.GetPhoneType();
	
	ChannelCapabilityArray remoteCaps;
	callSig.GetCapabilities(remoteCaps);
	SetRemoteCapabilities(remoteCaps);
    
	if(!_remoteInfo._noRouter)
		_remoteInfo._noRouter = callSig.IsURTPViaTCP();
    
	if(!_remoteInfo._supportRAC)
		_remoteInfo._supportRAC = callSig.IsSupportRAC();
    
	return TRUE;
}

void UPPSession::WriteOpenChannel()
{
	ChannelCapabilityArray & caps = GetBCInfo().IsMaster() ? _remoteInfo._capabilityArray:_capabilityArray;
	ChannelCapabilityMap & capsMap = GetBCInfo().IsMaster() ? _capabilityMap:_remoteInfo._capabilityMap;

	for (unsigned i=0;i<caps.size();i++){
		if(capsMap.find(caps[i]) != capsMap.end()){
			if(WriteOpenChannel(caps[i]))
				break;
		}
	}
}

PBOOL UPPSession::WriteOpenChannel(E_ChannelCapability cap)
{
	if(_channelOpened == TRUE)
		return TRUE;
	_channelOpened = TRUE;

	_cap = cap;

	UMPSignal sig_openChannel(e_sig_openChannel);
	Sig::OpenChannel openChannel(sig_openChannel);
	openChannel.SetNumber(_channelNumber);
	openChannel.SetCapability(cap);

	return WriteSignal(sig_openChannel);
}

PBOOL UPPSession::WriteCloseChannel(char chNumber,PBOOL transmit,E_ResultReason reason)
{
	if(GetUPPStateMonitor().GetState()==e_upps_idle)
		return FALSE;
    
	UMPSignal sig_closeChannel(e_sig_closeChannel);
	Sig::CloseChannel closeChannel(sig_closeChannel);
	closeChannel.SetNumber(chNumber);
	closeChannel.SetResult(reason);
	closeChannel.SetDirection(transmit?e_cd_transmit:e_cd_receive);
	return WriteSignal(sig_closeChannel);
}

PBOOL UPPSession::HandleCallSetup(const Sig::CallSetup & callSetup)
{
	_uppStateMonitor.SetState(e_upps_proceed);
	
	HandleCallSignal(callSetup);
	
	UMPSignal sig_callAlert(e_sig_callAlert);
	Sig::CallAlert callAlert(sig_callAlert);
	
	callAlert.SetCapabilities(_capabilityArray);
	callAlert.SetVersion(upp_version);
	callAlert.SetAcceptInbandDTMF(TRUE);
	if(_noRouter)
		callAlert.SetURTPViaTCP(TRUE);
    
	OnWriteCallSignal(sig_callAlert);
	
	WriteSignal(sig_callAlert);
	
	_uppStateMonitor.SetState(e_upps_alert);

	WriteOpenChannel();

	_uppsEventSink.OnSetup(*this);
    
	return TRUE;
}

PBOOL UPPSession::HandleCallAlert(const Sig::CallAlert & callAlert)
{
	_uppStateMonitor.GetConnectTimeout().Reset();
	
	HandleCallSignal(callAlert);
	
	_uppStateMonitor.SetState(e_upps_alert);
	
	_uppsEventSink.OnAlert(*this);

	return TRUE;
}

PBOOL UPPSession::HandleCallConnect(const Sig::CallConnect & callConnect)
{
	HandleCallSignal(callConnect);
	
	_uppStateMonitor.SetState(e_upps_connect);
    
	_bcInfo.SetBeginTick(PTimer::Tick().GetInterval());
    
	if(!GetBCInfo().IsMaster()){
			WriteOpenChannel();
	}
	_uppsEventSink.OnConnect(*this);
	
	return TRUE;
}

PBOOL UPPSession::HandleOpenChannel(const Sig::OpenChannel & openChannel)
{
	E_ChannelCapability cap = openChannel.GetCapability();
//	char number = openChannel.GetNumber();
	_cap = cap;
    
	if(GetBCInfo().IsMaster())
		WriteOpenChannel(cap);

	if(_uppStateMonitor.GetState() == e_upps_alert)
		_uppsEventSink.OnAlertAndOpenChannel(*this);
    
	return TRUE;
}

PBOOL UPPSession::HandleCloseChannel(const Sig::CloseChannel & closeChannel)
{
	return TRUE;
}

PBOOL UPPSession::HandleURTPReport(const Sig::URTPReport & urtpReport)
{
	return TRUE;
}

PBOOL UPPSession::HandleDurationLimit(const Sig::DurationLimit & durationLimit)
{
	_uppsEventSink.OnDurationLimit(*this,durationLimit.GetLimit());
	return TRUE;
}

PBOOL UPPSession::HandleDTMF(const Sig::DTMF & dtmf)
{
	_uppsEventSink.OnDTMF(*this,dtmf.GetDTMF(),TRUE);
	return TRUE;
}

PBOOL UPPSession::HandleForward(const Sig::Forward & forward)
{
	UMPSignal sig_to;
	forward.GetForwardTo(sig_to);
	_uppsEventSink.OnForwardTo(*this,BaseUserInfo(sig_to));
	return TRUE;
}

PBOOL UPPSession::HandleURTPTransport(const Sig::URTPTransport & urtpTransport)
{
    IPPort wan;
	if(wan.FromString(urtpTransport.GetWanAddress(),0))
    {
		_urtpWan = wan;
		_uppsEventSink.OnURTPTansportReady(*this);
    }
    
	if(GetBCInfo().GetPeerAddress().GetIP().IsValid() &&
       (GetBCInfo().GetPeerAddress().GetIP() == GetBCInfo().GetSelfAddress().GetIP())){
		IPPort lan;
		if(lan.FromString(urtpTransport.GetLanAddress(),0))
		{
			_urtpLan = lan;
		}
	}
	return TRUE;
}

PBOOL UPPSession::OnRecvURTP(const URTPFrame &frame)
{
    _urtpStat._frameCount++;
    
    WORD curSeqNumber = frame.GetSequenceNumber();
    DWORD curTimestamp = frame.GetTimestamp();
    
    if (_lastSeqNumber != 0) {
        int diff = (curSeqNumber - _lastSeqNumber - 1);
        if (diff>0&&diff<100) {
            _urtpStat._frameCount+=diff;
            _urtpStat._lostCount += diff;
        }
    }
	
    _lastSeqNumber = curSeqNumber;
    _lastTimestamp = curTimestamp;
    
    return TRUE;
}

PBOOL UPPSession::OnSendURTP(const URTPFrame &frame)
{
    return TRUE;
}

PBOOL UPPSession::WriteURTPTransport(
									const IPPort & wan,
									const IPPort & lan
									)
{
	if(GetBCStateMonitor().GetState()!=e_ready)
		return FALSE;
    
	UMPSignal sig_urtpTransport(e_sig_urtpTransport);
	Sig::URTPTransport urtpTransport(sig_urtpTransport);
	if(wan.IsValid())
		urtpTransport.SetWanAddress(wan.ToString());
    
	IPPort l = lan;
	l.SetIP(GetLocalAddress().GetIP());
	if(l.IsValid())
		urtpTransport.SetLanAddress(l.ToString());
    
	return WriteSignal(sig_urtpTransport);
}

PBOOL UPPSession::WriteURTPTransport()
{
	if(GetBCStateMonitor().GetState()!=e_ready)
		return FALSE;

	UMPSignal sig_urtpTransport(e_sig_urtpTransport);
	Sig::URTPTransport urtpTransport(sig_urtpTransport);

	IPPort lan(_localIP,_localRTPPort);
//	U_WARN("lan1: "<<lan.ToString());
	if(lan.IsValid())
	{
		urtpTransport.SetLanAddress(lan.ToString());
	}

	return WriteSignal(sig_urtpTransport);
}

void UPPSession::OnReady(BridgeChannel & /*channel*/)
{
	/** while a wince device connect with pc via USB port,
     only tcp is available and with no router. So we check if
     we have a router
     */

	//i do not know why _localIP in 0.0.0.0 when initialize,set again when bridgeready
	_localIP = GetLocalAddress().GetIP();
//	U_WARN("_localIP:"<<_localIP);
	PIPSocket::RouteTable rt;
    if (1)
    {
		WriteURTPTransport();

		const PString forwarder = GetBCInfo().GetUDPForwarder();
		if(!forwarder.IsEmpty()){
			PINDEX pos = forwarder.Find(";");
            
			if(P_MAX_INDEX!=pos){
				IPPort forward;
				
				if(forward.FromString(forwarder.Mid(0,pos),0))
					_urtpForward = forward;
                
			}	
		}
	} else {
		_noRouter = TRUE;
		//disable RAC(TCP case no need RAC)
	}
    
	_uppStateMonitor.GetSetupTimeout().Reset();
	_uppStateMonitor.GetAlertTimeout().Reset();
	
	ChannelCapabilityArray localCaps;
	_uppsEventSink.OnGetCodecCapabilities(*this,localCaps);
	SetLocalCapabilities(localCaps);
    
	if (GetBCInfo().IsMaster()) {
		//we send callSetup here
		UMPSignal sig_callSetup(e_sig_callSetup);
		Sig::CallSetup callSetup(sig_callSetup);
		callSetup.SetVersion(upp_version);
		callSetup.SetPhoneType(e_pt_umpPhone);		
        
		callSetup.SetCapabilities(_capabilityArray);
		callSetup.SetVersion(upp_version);
		callSetup.SetAcceptInbandDTMF(TRUE);
		if(_noRouter)
			callSetup.SetURTPViaTCP(TRUE);
		
		OnWriteCallSignal(sig_callSetup);
		
		WriteSignal(sig_callSetup);
		_uppStateMonitor.SetState(e_upps_setup);
	}
}

void UPPSession::OnRelease(BridgeChannel & /*channel*/,E_ResultReason reason, E_Actor actor)
{
	_outbandDTMFKeeper.Clear();
	U_WARN("UPPSession::OnRelease GetCurrentThreadId  "<<PThread::GetCurrentThreadId());
	if(_channelOpened == TRUE)
	{
		WriteCloseChannel(_channelNumber,FALSE,e_r_ok);
		WriteCloseChannel(_channelNumber,TRUE,e_r_ok);
		//_uppsEventSink.OnStopVoice(*this,_cap);
	}

	_channelOpened = FALSE;
	_uppStateMonitor.SetState(e_upps_idle);
    
	U_WARN("fordbg:call upp onrelease");
	_uppsEventSink.OnRelease(*this,reason,actor);
	_isRecvCallReleaseSignal=TRUE;
}

void UPPSession::OnReflect(const IPPort & wan,const IPPort & lan)
{
	WriteURTPTransport(wan,lan);
}


void UPPSession::OnURTP(const BYTE * urtp, DWORD len)
{
}

void UPPSession::SetDeletable()
{
	BridgeChannel::SetDeletable();
}
