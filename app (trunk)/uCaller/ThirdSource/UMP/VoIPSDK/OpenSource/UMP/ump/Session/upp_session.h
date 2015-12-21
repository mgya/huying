//
//  upp_session.h
//  UMPStack
//
//  Created by thehuah on 14-3-10.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__upp_session__
#define __UMPStack__upp_session__

#include "../Common/utype.h"
#include "bridge_channel.h"
#include "../URTP/urtp_socket.h"
/////////////////

/////////////////////
using namespace ump;
using namespace ump::codec;

class UPPSession : public BridgeChannel, public BridgeChannel::BCEventSink,public URTPSocket::USEventSink
{
	PCLASSINFO(UPPSession, BridgeChannel);
  
public:
    
	class RemoteInfo
	{
	public:
		RemoteInfo();
	public:
		
		DWORD			_version;
		E_PhoneType		_phoneType;
		PBOOL			_acceptInbandDTMF;
		ChannelCapabilityMap	_capabilityMap;
		ChannelCapabilityArray	_capabilityArray;
        
		PBOOL _noRouter;
		PBOOL _supportRAC;
	};
    
    class SpeechInfo {
        
        E_Type type;
        
        Format format;
        
        UINT32 samplePerFrame;
        UINT32 maxCodedFrameBytes;
        UINT32 preferredFramePerRTP;
        
    public:
        SpeechInfo() :
        type(e_null),
		samplePerFrame(0),
		maxCodedFrameBytes(0),
		preferredFramePerRTP(0)
        {
        }
        explicit SpeechInfo(
                            E_Type t,
                            const Format & f,
                            UINT32 spf,
                            UINT32 mcfb,
                            UINT32 pfpr)
        :type(t),
        format(f),
        samplePerFrame(spf),
        maxCodedFrameBytes(mcfb),
        preferredFramePerRTP(pfpr) 
        {
        }
        
        virtual ~SpeechInfo() {
            
        }
    };
    
	class UPPSEventSink
	{
	public:
		virtual ~UPPSEventSink(){}
	public:
		virtual void OnSetup(UPPSession & upps) = 0;
		virtual void OnAlert(UPPSession & upps) = 0;
		virtual void OnAlertAndOpenChannel(UPPSession & upps) = 0;
		virtual void OnConnect(UPPSession & upps) = 0;
		virtual void OnRelease(UPPSession & upps,E_ResultReason reason,E_Actor actor) = 0;
		virtual void OnDTMF(UPPSession & upps,const PString& dtmf, PBOOL inband) = 0;
		virtual void OnForwardTo(UPPSession & upps,const BaseUserInfo& to) = 0;
		virtual void OnDurationLimit(UPPSession & upps,DWORD second) = 0;
		virtual void OnGetCodecCapabilities(UPPSession & upps,ChannelCapabilityArray & caps) = 0;
        
		virtual void OnURTPTansportReady(UPPSession & upps) = 0;

        virtual void OnStartVoice(UPPSession & upps, E_ChannelCapability cap) = 0;
		virtual void OnStopVoice(UPPSession & upps, E_ChannelCapability cap) = 0;
        
		virtual void OnUPPSTick(UPPSession & upps) = 0;
	};
    
	enum E_UPPState {
		e_upps_idle,
		e_upps_setup,
		e_upps_proceed,
		e_upps_alert,
		e_upps_connect
	};
    
    class URTPStat
    {
    public:
        URTPStat();
        
        void Reset();
        
        DWORD GetLostFraction();
        
        
        DWORD _frameCount;
        DWORD _lostCount;
        
        DWORD _lastFrameCount;
        DWORD _lastLostCount;
    };
    
	class UPPStateMonitor : public UMPHandlerBase::StateMonitor<E_UPPState>
	{
		PCLASSINFO(UPPStateMonitor,StateMonitor<E_UPPState>);
	public:
		UPPStateMonitor(UPPSession & session);
		
		PBOOL Filter(UMPHandlerBase & handler,UMPSignal & signal);
        
		PINLINE Timeout & GetSetupTimeout(){return _setupTimeout;}
		PINLINE Timeout & GetAlertTimeout(){return _alertTimeout;}
		PINLINE Timeout & GetConnectTimeout(){return _connectTimeout;}
		PINLINE Timeout & GetURTPReportTimeout(){return _urtpReportTimeout;}
		PBOOL IsAnswered() const{return _answered;}
		void SetAnswered(PBOOL a){_answered = a;}
	private:
		UPPSession & _session;
        
		Timeout _setupTimeout;
		Timeout _alertTimeout;
		Timeout _connectTimeout;
		
		Timeout _urtpReportTimeout;
		
		PBOOL _answered;
	};
    
	class OutbandDTMFKeeper
	{
	public:
		OutbandDTMFKeeper();
		
		PString Pop();
		PBOOL IsEmpty();
		void Push(const PString & dtmf);
        
		void Clear();
        
	private:
		PMutex _mutex;
		PString _dtmf;
	};
    
public:
    UPPSession(PBOOL isMaster,
			   UPPSEventSink & eventSink);
	UPPSession(PBOOL isMaster,
			   UPPSEventSink & eventSink,
			   const IPPort & reflectServer);
	virtual ~UPPSession();
    
	E_InteractType GetType() const{	return e_interactType_phone;}
	//PINLINE Channels & GetChannels(){return _channels;}

	PINLINE const RemoteInfo & GetRemoteInfo() const{return _remoteInfo;}
	PINLINE const UPPStateMonitor & GetUPPStateMonitor() const{return _uppStateMonitor;}
	
	PBOOL WriteURTPTransport(const IPPort & wan,
							const IPPort & local);
	PBOOL WriteURTPTransport();
	
	PBOOL WriteDTMF(const PString & dtmf);
	PBOOL GetOutbandDTMFDetection() const;
	void SetOutbandDTMFDetection(PBOOL b);

public:
	PBOOL Answer();
	virtual void SetDeletable();
	
    
protected:
	void SetLocalCapabilities(const ChannelCapabilityArray & caps);
	void SetRemoteCapabilities(const ChannelCapabilityArray & caps);
	
protected:
	void OnReadSignal(UMPHandlerBase & handler,UMPSignal * signal,PBOOL & noDelete);
	void OnReadBinary(UMPHandlerBase & handler,const void* bin, PINDEX size);

	void OnTick(UMPHandlerBase & handler);
	PBOOL OnFilter(UMPHandlerBase & handler,UMPSignal& signal);
	
protected:
	void OnReady(BridgeChannel & channel);
	void OnRelease(BridgeChannel & channel,E_ResultReason reason, E_Actor actor);
    
protected:
	virtual void OnWriteCallSignal(UMPSignal & /*signal*/){}
    
protected:
	virtual PBOOL HandleCallSetup(const Sig::CallSetup & callSetup);
	virtual PBOOL HandleCallAlert(const Sig::CallAlert & callAlert);
	virtual PBOOL HandleCallConnect(const Sig::CallConnect & callConnect);
	virtual PBOOL HandleOpenChannel(const Sig::OpenChannel & openChannel);
	virtual PBOOL HandleCloseChannel(const Sig::CloseChannel & closeChannel);
	virtual PBOOL HandleURTPReport(const Sig::URTPReport & urtpReport);
	virtual PBOOL HandleDurationLimit(const Sig::DurationLimit & durationLimit);
	virtual PBOOL HandleDTMF(const Sig::DTMF & dtmf);
	virtual PBOOL HandleForward(const Sig::Forward & forward);
	virtual PBOOL HandleURTPTransport(const Sig::URTPTransport & urtpTransport);
    
protected:
	virtual PBOOL HandleCallSignal(const Sig::CallSignal & callSig);
    
    //override from URTPSocket::USEventSink
	void OnReflect(const IPPort & wan,const IPPort & lan);
	void OnURTP(const BYTE * urtp, DWORD len);
    
    virtual PBOOL OnRecvURTP(const URTPFrame &frame);
	virtual PBOOL OnSendURTP(const URTPFrame &frame);
	virtual void WriteOpenChannel();
	virtual PBOOL WriteOpenChannel(E_ChannelCapability cap);
	virtual PBOOL WriteCloseChannel(char chNumber,PBOOL transmit,E_ResultReason reason);

public:
	IPPort GetURTPWan();
	IP GetLocalIP();
	WORD GetLocalRTPPort();
	WORD GetPayloadType();
	PBOOL IsRecvCallReleaseSignal();

protected:
	ChannelCapabilityMap _capabilityMap;
	ChannelCapabilityArray _capabilityArray;
protected:
	RemoteInfo _remoteInfo;
protected:
	UPPStateMonitor _uppStateMonitor;

    URTPStat _urtpStat;
    WORD _lastSeqNumber;
    DWORD _lastTimestamp;
    
    IPPort _urtpWan;
    IPPort _urtpLan;
    IPPort _urtpForward;

    IP _localIP;
    WORD _localRTPPort;

    PBOOL _channelOpened;
    BYTE _channelNumber;
    
    //SpeechInfo _speechInfo;
    E_ChannelCapability _cap;

	OutbandDTMFKeeper _outbandDTMFKeeper;
	PBOOL _outbandDTMFDetection;

	//some times internetstop signal is processed before callrelease,if this happened,sleep 10 ms
	PBOOL _isRecvCallReleaseSignal;
    
private:
	UPPSEventSink & _uppsEventSink;
	PBOOL _noRouter;
};


#endif /* defined(__UMPStack__upp_session__) */
