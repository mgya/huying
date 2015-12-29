//
//  sig_wrap.h
//  UMPStack
//
//  Created by thehuah on 14-3-5.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef SIG_WRAP_H
#define SIG_WRAP_H

#include <iostream>
#include <vector>
#include <map>

#include "sig_tag.h"
#include "ump_base.h"

typedef std::vector<E_InteractType> CapabilityArray;
typedef std::vector<E_ChannelCapability> ChannelCapabilityArray;
typedef std::map<E_ChannelCapability, bool> ChannelCapabilityMap;

//to cheat VC6's classview
#ifndef _NAMESPACE
#ifdef NEVER_DEFINED
#define _NAMESPACE struct
#else
#define _NAMESPACE namespace
#endif
#endif
_NAMESPACE Sig
{
    /**
     */
	class Wrap
	{
	public:
		Wrap(UMPSignal& sig);
		Wrap(const Wrap& other);
		virtual ~Wrap(){}
		
		E_UMPTag GetTag() const;
		void SetTag(E_UMPTag tag);
		PString GetTagName() const;
		
		UMPSignal& GetSignal() const;
		
		PBOOL GetSubSignal(E_UMPTag sigTag, UMPSignal& subSig) const;
		void SetSubSignal(E_UMPTag sigTag, const UMPSignal& subSig);
		
		DWORD GetCmdNumber() const;
		void SetCmdNumber(DWORD cmdNumber);
		
		DWORD GetSeqNumber() const;
		void SetSeqNumber(DWORD seqNumber);
	protected:
		UMPSignal& _signal;
	};
	/////
	class GetBaseUserInfo : public Wrap
	{
	public:
		GetBaseUserInfo(UMPSignal& sig);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 & uid);
		
		PString GetUserName() const;
		void SetUserName(const PString& uname);
		
		PString GetUserNumber() const;
		void SetUserNumber(const PString& unumber);
        
        //added by liyr 2015-12-03
        PUInt64 GetAID() const;
        void SetAID(const PUInt64 & uid);
        
        PUInt64 GetCID() const;
        void SetCID(const PUInt64 & uid);
        //added by liyr 2015-12-03
	};
	
	typedef GetBaseUserInfo BaseUserInfo;
	////////
	
	class GetBaseGroupInfo : public Wrap
	{
	public:
		GetBaseGroupInfo(UMPSignal& sig);
		
		PUInt64 GetGroupID() const;
		void SetGroupID(const PUInt64 & gid);
		
		PString GetGroupName() const;
		void SetGroupName(const PString& gname);
	};
	
	typedef GetBaseGroupInfo BaseGroupInfo;
	/////
	
	class Login : public Wrap
	{
	public:
		Login(UMPSignal& sig);
		
		void SetBaseUserInfo(const UMPSignal& bui);
		PBOOL GetBaseUserInfo(UMPSignal& bui) const;
		
		void SetVersion(DWORD version);
		DWORD GetVersion() const;
		
		void SetForceFlag(PBOOL force);
		PBOOL HasForceFlag() const;
		
		void SetEncryptFlag(PBOOL encrypt);
		PBOOL HasEncryptFlag() const;
		
		void SetClientType(E_ClientType ctype);
		E_ClientType GetClientType() const;
		
		void SetForwardFlag(PBOOL b);
		PBOOL HasForwardFlag() const;
		
		PBOOL GetCapabilities(CapabilityArray & caps) const;
		void SetCapabilities(const CapabilityArray& caps);
        
		PString getClientId() const;
		void setClientId(const PString & id);
		
	};
	
	class Logout: public Wrap
	{
	public:
		Logout(UMPSignal & sig);
	};
	
	class RoundTrip : public Wrap
	{
	public:
		RoundTrip(UMPSignal & sig);
		
		DWORD GetOnlineCount() const;
		void SetOnlineCount(DWORD onlineCount);
	};
	
	class RoundTripAck : public Wrap
	{
	public:
		RoundTripAck(UMPSignal & sig);
	};
	/////////
	class LoginAck : public Wrap
	{
	public:
		LoginAck(UMPSignal& sig);
		
		E_ResultReason GetResult() const;
		void SetResult(E_ResultReason result);
		
		PBYTEArray GetKey() const;
		void SetKey(const PBYTEArray& key);
		
		PString GetForwardTo() const;
		void SetForwardTo(const PString& to);
        
        //added by liyr 2015-12-03
        PString GetForwardToList() const;
        void SetForwardToList(const PString& tolist);
        //added by liyr 2015-12-03
        
		PString GetURL() const;
		void SetURL(const PString& url);
	};
	////////
	class Pologin : public Wrap
	{
	public:
		Pologin(UMPSignal& sig);
		
		PBYTEArray GetKey() const;
		void SetKey(const PBYTEArray& key);
		
		PBYTEArray GetLastSessionGUID() const;
		void SetLastSessionGUID(const PBYTEArray & lastSGUID);
        
		PBOOL GetClientInfo(UMPSignal & clientInfo) const;
		void SetClientInfo(const UMPSignal & clientInfo);
		
	};
	/////
	class PologinAck : public Wrap
	{
	public:
		PologinAck(UMPSignal& sig);
		
		E_ResultReason GetResult() const;
		void SetResult(E_ResultReason result);
		
		PBYTEArray GetUserInfo() const;
		void SetUserInfo(const PBYTEArray& userInfo);
		
		PBYTEArray GetSessionGUID() const;
		void SetSessionGUID(const PBYTEArray& guid);
	};
	/////////
	class ServerInfo : public Wrap
	{
	public:
		ServerInfo(UMPSignal& sig);
		
		PString GetName() const;
		void SetName(const PString& name);
		
		PString GetReflector() const;
		void SetReflector(const PString& reflector);
        
		PString GetUDPProxy() const;
		void SetUDPProxy(const PString &proxy);
		
		PString GetFX() const;
		void SetFX(const PString & fx);
		
		DWORD GetOnlineCount() const;
		void SetOnlineCount(DWORD onlineCount);
		
		time_t GetServerTime() const;
		void SetServerTime(time_t t);
	};
	
	//////////////
	class ClientInfo : public Wrap
	{
	public:
		ClientInfo(UMPSignal& sig);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 & uid);
		
		PString GetOSInfo() const;
		void SetOSInfo(const PString& osInfo);
		
		E_ClientType GetClientType() const;
		void SetClientType(E_ClientType type);
		
		DWORD GetVersion() const;
		void SetVersion(DWORD version);
		
		PString GetLocalInterface() const;
		void SetLocalInterface(const PString& ifs);
		
		PString GetMacInfo() const;
		void SetMacInfo(const PString& macInfo);
	};
	///////
	class SetUserMainState : public Wrap
	{
	public:
		SetUserMainState(UMPSignal& sig);
		
		void SetForceFlag(PBOOL force);
		PBOOL HasForceFlag() const;
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 & uid);
		
		E_UserMainState GetMainState() const;
		void SetMainState(E_UserMainState ums);
		
		PBYTEArray GetSessionGUID() const;
		void SetSessionGUID(const PBYTEArray& guid);
		
		PBYTEArray GetLastSessionGUID() const;
		void SetLastSessionGUID(const PBYTEArray & lastGUID);
		
		PString GetUserIP() const;
		void SetUserIP(const PString& ip);
        
	};
	////////////
	class SetUserSubState : public Wrap
	{
	public:
		SetUserSubState(UMPSignal& sig);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 &uid);
		
		PUInt64 GetRelatedUserID() const;
		void SetRelatedUserID(const PUInt64 & ruid);
		
		PBOOL HasReplyFlag() const;
		void SetReplyFlag(PBOOL f);
		
		E_UserSubState GetSubState() const;
		void SetSubState(E_UserSubState subState);
		
		E_ClientType GetClientType() const;
		void SetClientType(E_ClientType ctype);
		
		PString GetDescription() const;
		void SetDescription(const PString& desc);
		
		PBOOL GetFullRelated(PBOOL & b) const;
		void SetFullRelated(PBOOL b);
	};
	
	typedef SetUserSubState UserSubState;
	
	////////
	
	////////
	class GetUserPassword : public Wrap
	{
	public:
		GetUserPassword(UMPSignal& sig);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64& uid);
	};
	
	///////
	class KeepAlive : public Wrap
	{
	public:
		KeepAlive(UMPSignal& sig);
		
		DWORD GetTick() const;
		void SetTick(DWORD tick);
	};
	
	class KeepAliveAck : public Wrap
	{
	public:
		KeepAliveAck(UMPSignal& sig);
	};
	//////////
	class UMPInit : public Wrap
	{
	public:
		UMPInit(UMPSignal& sig);
		
		PString GetNeighborListeners() const;
		void SetNeighborListeners(const PString& nls);
		
		PString GetUMPListeners() const;
		void SetUMPListeners(const PString& uls);
		
		PString GetName() const;
		void SetName(const PString& name);
	};
	
	///////////
	
	class BridgeInit : public Wrap
	{
	public:
		BridgeInit(UMPSignal& sig);
		
		PString GetListeners() const;
		void SetListeners(const PString& bls);
		
		PString GetName() const;
		void SetName(const PString& name);
	};
	/////////
	class InterInit : public Wrap
	{
	public:
		InterInit(UMPSignal& sig);
		
		PBOOL GetUMPInit(UMPSignal& init);
		void SetUMPInit(const UMPSignal& init);
		
		PBOOL GetBridgeInit(UMPSignal& init);
		void SetBridgeInit(const UMPSignal& init);
		
		DWORD GetIdentifier() const;
		void SetIdentifier(DWORD id);
		
		
		time_t GetStartupTime() const;
		void SetStartupTime(time_t t);
		
		
		DWORD GetVersion() const;
		void SetVersion(DWORD version);
	};
	/////////
	class UpdateServerListeners : public Wrap
	{
	public:
		UpdateServerListeners(UMPSignal& sig);
		
		DWORD GetServerCount() const;
		PBOOL GetListeners(PINDEX index, DWORD& lid, UMPSignal& serverListeners) const;
		void AddListeners(DWORD lid, const UMPSignal& serverListeners);
	};
	
	class ServerListeners : public Wrap
	{
	public:
		ServerListeners(UMPSignal& sig);
		
		PString GetUMPListeners() const;
		void SetUMPListeners(const PString& uls);
		
		PString GetNeighborListeners() const;
		void SetNeighborListeners(const PString& nls);
		
		PString GetBridgeListeners() const;
		void SetBridgeListeners(const PString& bls);
	};
	
	/////////
	class NeighborInit : public Wrap
	{
	public:
		NeighborInit(UMPSignal& sig);
		
		DWORD GetIdentifier() const;
		void SetIdentifier(DWORD id);
	};
	/////////////
	class ForceOffline : public Wrap
	{
	public:
		ForceOffline(UMPSignal& sig);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 &uid);
		
		E_ResultReason GetResult() const;
		void SetResult(E_ResultReason result);
	};
	/////////
	class GetRelatedUsers : public Wrap
	{
	public:
		GetRelatedUsers(UMPSignal& sig);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64& uid);
		
		void SetTimestamp(DWORD ts);
		DWORD GetTimestamp() const;
		
	};
	////////////
	class RelatedUsers : public GetRelatedUsers
	{
	public:
		RelatedUsers(UMPSignal& sig);
		
		void SetRUsers(const PString& ruid2gid);
		PString GetRUsers() const;
		
		void SetResult(E_ResultReason result);
		E_ResultReason GetResult() const;
	};
	///////////////
	class GetUserLocation : public Wrap
	{
	public:
		GetUserLocation(UMPSignal& sig);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 &userID);
		
		E_InteractType GetInteractType() const;
		void SetInteractType(E_InteractType itype);
	};
	///////
	class AddRelatedUser : public Wrap
	{
	public:
		AddRelatedUser(UMPSignal& sig);
		
		void SetRelatedBaseUserInfo(const UMPSignal& bui);
		PBOOL GetRelatedBaseUserInfo(UMPSignal& bui) const;
		
		void SetBaseGroupInfo(const UMPSignal& bgi);
		PBOOL GetBaseGroupInfo(UMPSignal& bgi) const;
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 &uid);
		
		PString GetComment() const;
		void SetComment(const PString& comment);
		
	};
	/////////
	class ModRelatedUser : public Wrap
	{
	public:
		ModRelatedUser(UMPSignal& sig);
		
		void SetRelatedBaseUserInfo(const UMPSignal& bui);
		PBOOL GetRelatedBaseUserInfo(UMPSignal& bui) const;
		
		void SetOldBaseGroupInfo(const UMPSignal& bgi);
		PBOOL GetOldBaseGroupInfo(UMPSignal& bgi) const;
		
		void SetNewBaseGroupInfo(const UMPSignal& bgi);
		PBOOL GetNewBaseGroupInfo(UMPSignal& bgi) const;
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 &uid);
		
	};
	/////
	class DelRelatedUser : public Wrap
	{
	public:
		DelRelatedUser(UMPSignal& sig);
		
		void SetRelatedBaseUserInfo(const UMPSignal& bui);
		PBOOL GetRelatedBaseUserInfo(UMPSignal& bui) const;
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64& uid);
	};
	//////
	class Interact : public Wrap
	{
	public:
		Interact(UMPSignal& sig);
		
		PBOOL GetTo(UMPSignal& to) const;
		void SetTo(const UMPSignal& to);
		
		PBOOL GetFrom(UMPSignal& from) const;
		void SetFrom(const UMPSignal& from);
		
		PBOOL GetForwarder(UMPSignal& forwarder) const;
		void SetForwarder(const UMPSignal& forwarder);
		
		PBOOL GetBody(UMPSignal& body) const;
		void SetBody(const UMPSignal& body);
		
		E_InteractType GetType() const;
		void SetType(E_InteractType type);
		
		time_t GetTime() const;
		void SetTime(time_t t);
		
		void SetTemporaryFlag(PBOOL temp);
		PBOOL HasTemporaryFlag() const;
		
		void SetNoackFlag(PBOOL noack);
		PBOOL HasNoackFlag() const;
		
		PBYTEArray GetGUID() const;
		void SetGUID(const PBYTEArray& guid);
		
		PBOOL HasServiceFlag() const;
		void SetServiceFlag(PBOOL extend);
		
		PString GetFromIP() const;
		void SetFromIP(const PString& ip);
        
		/************************************************************************/
		/*
         20100416 ÃÌº”Ω‚Œˆ¿¥÷¡ISµƒ–≈¡Ó£®Caller «∑Ò «ÃÂ—È”√ªß£©
         */
		/************************************************************************/
		PBOOL HasCallerIsExpFlag() const;
		void SetCallerIsExpFlag(PBOOL isExpUser);
        
	};
	////////
	class InteractAck : public Wrap
	{
	public:
		InteractAck(UMPSignal& sig);
		
		E_ResultReason GetResult() const;
		void SetResult(E_ResultReason result);
		
		PBOOL GetBridge(UMPSignal& bridge) const;
		void SetBridge(const UMPSignal& bridge);
		
		PString GetSMSID() const;
		void SetSMSID(PString smsid);
		
		PBYTEArray GetGUID() const;
		void SetGUID(const PBYTEArray& guid);
	};
	/////////
	class InteractBody : public Wrap
	{
	public:
		InteractBody(UMPSignal& sig);
		
		PString GetContent() const;
		void SetContent(const PString& content);
		
		PBYTEArray GetKey() const;
		void SetKey(const PBYTEArray& key);
	};
    /////////
    class SMSContent : public InteractBody
	{
	public:
		SMSContent(UMPSignal & signal);
		virtual ~SMSContent(){}
		
	public:
		PString GetContent();
		void SetContent(PString const & content);
        
		PString GetTiming();
		void SetTiming(PString const & timing);
        
		PString GetTimeStamp();
		void SetTimeStamp(PString const & timestamp);
        
		E_ResultReason GetResultReason();
		void SetResultReason(E_ResultReason r);
	};
	////
	class InteractBodyStart : public InteractBody
	{
	public:
		InteractBodyStart(UMPSignal& sig);
		
		PBOOL GetBridge(UMPSignal& bridge) const;
		void SetBridge(const UMPSignal& bridge);
		
		PString GetPeerIP() const;
		void SetPeerIP(const PString& ip);
	};
	///////////////////////////////
	class InteractBodyStop : public InteractBody
	{
	public:
		InteractBodyStop(UMPSignal& sig);
		
		E_ResultReason GetResult() const;
		void SetResult(E_ResultReason result);
	};
	////////
	class InteractBodyMessage : public InteractBody
	{
	public:
		InteractBodyMessage(UMPSignal& sig);
		
		PUInt64 GetRoomId() const;
		void SetRoomId(const PUInt64 & id);
        
		PBOOL HasAutoReplyFlag() const;
		void SetAutoReplyFlag(PBOOL b);
        
        
	};
	
	/////////
	class InteractBodyShock : public InteractBody
	{
	public:
		InteractBodyShock(UMPSignal& sig);
	};
	
	/////////
	class InteractBodyFileTransport : public InteractBody
	{
	public:
		InteractBodyFileTransport(UMPSignal& sig);
		
		PString GetFileName() const;
		void SetFileName(const PString& name);
        
		void SetResult(const E_ResultReason result);
		E_ResultReason GetResult() const;
        
		void SetWanAddress(const PString &ipport);
		PString GetWanAddress() const;
        
		void SetLanAddress(const PString &ipport);
		PString GetLanAddress() const;
        
		DWORD GetFileSize() const;
		void SetFileSize(DWORD size);
        
		PBOOL GetForceFlag() const;
		void SetForceFlag(PBOOL flag);
	};
	//////////////////////////////////////////////////////////////////////////
	class CallPayer : public Wrap{
	public:
		CallPayer(UMPSignal& sig);
        
		PUInt64 GetPayerId() const;
		void SetPayerId(PUInt64 id);
        
		DWORD GetCallType() const;
		void setCallType(DWORD type);
	};
	//////////
	class InteractBodyPhone : public InteractBody
	{
	public:
		InteractBodyPhone(UMPSignal& sig);
        
		PBOOL GetPayer(UMPSignal& payer) const;
		void SetPayer(const UMPSignal& payer);
	};
	/////////
	class InteractBodyRoomCtrl : public InteractBody
	{
	public:
		InteractBodyRoomCtrl(UMPSignal & sig);
	};
    
	class InteractBodyInputIndication : public InteractBody
	{
	public:
		InteractBodyInputIndication(UMPSignal & sig);
        
		PBOOL GetTyping() const;
		void SetTyping(PBOOL typing);
	};
    
    
	class Result : public Wrap
	{
	public:
		Result(UMPSignal& sig);
		
		
		E_ResultReason GetResult() const;
		void SetResult(E_ResultReason result);
		
		PString GetUserPassword() const;
		void SetUserPassword(const PString& password);
		
		DWORD GetLocationID() const;
		void SetLocationID(DWORD lid);
		
		void SetBaseUserInfo(const UMPSignal& bui);
		PBOOL GetBaseUserInfo(UMPSignal& bui) const;
		
		void SetBaseGroupInfo(const UMPSignal& bgi);
		PBOOL GetBaseGroupInfo(UMPSignal& bgi) const;
		
		PBOOL GetUserInfo(UMPSignal& userInfo) const;
		void SetUserInfo(const UMPSignal& userInfo);
		
		PBOOL GetUserData(UMPSignal& userData) const;
		void SetUserData(const UMPSignal& userData);
		
		PString GetRelatedUsers() const;
		void SetRelatedUsers(const PString & ruis);
		
		DWORD GetTimestamp() const;
		void SetTimestamp(DWORD ts);
	};
	///////////
	
	////////////
	
	////////
	class StoreInteract : public Wrap
	{
	public:
		StoreInteract(UMPSignal& sig);
		
		PBOOL GetInteract(UMPSignal& interact);
		void SetInteract(const UMPSignal& interact);
	};
	/////////////
	class GetTempInteract : public Wrap
	{
	public:
		GetTempInteract(UMPSignal& sig);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 &uid);
		
		PBOOL GetCapabilities(CapabilityArray & caps) const;
		void SetCapabilities(const CapabilityArray& caps);
	};
	////////////
	class BridgeSetup : public Wrap
	{
	public:
		BridgeSetup(UMPSignal& sig);
		
		PBOOL HasMasterFlag() const;
		void SetMasterFlag(PBOOL master);
		
		PBYTEArray GetBridgeGUID() const;
		void SetBridgeGUID(const PBYTEArray& guid);
		
		PBYTEArray GetHalfKey() const;
		void SetHalfKey(const PBYTEArray& key);
		
		PBYTEArray GetEncryptGUID() const;
		void SetEncryptGUID(const PBYTEArray& guid);
		
		E_InteractType GetType() const;
		void SetType(E_InteractType type);
		
		PBOOL HasUDPForwarderFlag() const;
		void SetUDPForwarderFlag(PBOOL b);
	};
	//////////////
	class BridgeReady : public Wrap
	{
	public:
		BridgeReady(UMPSignal& sig);
		
		PString GetName() const;
		void SetName(const PString& name);
		
		void SetUDPForwarder(const PString & fwd);
		PString GetUDPForwarder() const;
		
		void SetPeerAddress(const PString & addr);
		PString GetPeerAddress() const;
        
		void SetSelfAddress(const PString & addr);
		PString GetSelfAddress() const;
	};
	
	class Release : public Wrap
	{
	public:
		Release(UMPSignal& sig);
		E_ResultReason GetResult() const;
		void SetResult(E_ResultReason result);
	};
	///////////
	class Bridge : public Wrap
	{
	public:
		Bridge(UMPSignal& sig);
		
		PString GetListener() const;
		void SetListener(const PString& l);
		
		PString GetPeerListener() const;
		void SetPeerListener(const PString & l);
		
		PBYTEArray GetGUID() const;
		void SetGUID(const PBYTEArray& guid);
		
		PBYTEArray GetKey() const;
		void SetKey(const PBYTEArray& key);
		
	};
	
	////////
	
	////////////////
	//sig for upp
    
	
	class CallSignal : public Wrap
	{
	public:
		CallSignal(UMPSignal & sig);
		
		PBOOL GetCapabilities(ChannelCapabilityArray & caps) const;
		void SetCapabilities(const ChannelCapabilityArray& caps);
		
		DWORD GetVersion() const;
		void SetVersion(DWORD version);
		
		E_PhoneType GetPhoneType() const;
		void SetPhoneType(E_PhoneType type);
		
		PBOOL GetAcceptInbandDTMF() const;
		void SetAcceptInbandDTMF(PBOOL b);
		
		PBOOL IsURTPViaTCP() const;
		void SetURTPViaTCP(PBOOL b);
		
		PBOOL IsSupportRAC() const;
		void SetSupportRAC(PBOOL b);
		
		PBOOL GetProxyTo(UMPSignal & proxyTo) const;
		void SetProxyTo(const UMPSignal & proxyTo);
        
		
	};
	
	//////////////////////////////////////////////////////////////////////////
	typedef CallSignal CallSetup;
	
	typedef CallSignal CallAlert;
	
	typedef CallSignal CallConnect;
	
	typedef CallSignal CallIndicator;
	/////////
	
	class OpenChannel : public Wrap
	{
	public:
		OpenChannel(UMPSignal& sig);
		
		char GetNumber() const;
		void SetNumber(char chNumber);
		
		E_ChannelCapability GetCapability() const;
		void SetCapability(E_ChannelCapability cap);
	};
	
	////////////
	class CloseChannel : public Wrap
	{
	public:
		CloseChannel(UMPSignal& sig);
		
		char GetNumber() const;
		void SetNumber(char chNumber);
		
		E_ResultReason GetResult() const;
		void SetResult(E_ResultReason result);
		
		E_ChannelDirection GetDirection() const;
		void SetDirection(E_ChannelDirection dir);
	};
	
	/////////////////////
	class URTPTransport : public Wrap
	{
	public:
		URTPTransport(UMPSignal& sig);
		
		PString GetWanAddress() const;
		void SetWanAddress(const PString& addr);
        
		PString GetLanAddress() const;
		void SetLanAddress(const PString & addr);
	};
	
	//////////
	class URTPReport : public Wrap
	{
	public:
		URTPReport(UMPSignal& sig);
		
		char GetChannelNumber() const;
		void SetChannelNumber(char chNumber);
		
		DWORD GetFrameRecvd() const;
		void SetFrameRecvd(DWORD recvd);
		
		DWORD GetFrameLost() const;
		void SetFrameLost(DWORD lost);
		
		DWORD GetLostFraction() const;
		void SetLostFraction(DWORD fraction);
	};
	
	/////////////
	class DurationLimit : public Wrap
	{
	public:
		DurationLimit(UMPSignal& sig);
		
		DWORD GetLimit() const;
		void SetLimit(DWORD second);
	};
	
	/////////////
	class RegisterService : public Wrap
	{
	public:
		RegisterService(UMPSignal& sig);
		
		E_InteractType GetType() const;
		void SetType(E_InteractType type);
		
		PString GetKey() const;
		void SetKey(const PString& key);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64& userID);
		
		PString GetIP() const;
		void SetIP(const PString& ip);
	};
	
	
	class RegisterServiceAck : public Wrap
	{
	public:
		RegisterServiceAck(UMPSignal& sig);
		
		E_InteractType GetType() const;
		void SetType(E_InteractType type);
		
		E_ResultReason GetResult() const;
		void SetResult(E_ResultReason r);
	};
	
	
	class UnregisterService : public Wrap
	{
	public:
		UnregisterService(UMPSignal& sig);
		
		E_InteractType GetType() const;
		void SetType(E_InteractType type);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 &userID);
	};
	
	class UpdateServiceProvider : public Wrap
	{
	public:
		UpdateServiceProvider(UMPSignal& sig);
		
		PString GetProviders() const;
		void SetProviders(const PString& p);
	};
	
	class UpdateRouteTable : public Wrap
	{
	public:
		UpdateRouteTable(UMPSignal& sig);
		
		PString GetRouteTable() const;
		void SetRouteTable(const PString& rt);
	};
	
	class UserInfo : public Wrap
	{
	public:
		UserInfo(UMPSignal& sig);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 & userID);
		
		PBOOL GetBaseUserInfo(UMPSignal& bui) const;
		void SetBaseUserInfo(const UMPSignal& bui);
		
		PBOOL GetBalance(double& balance) const;
		void SetBalance(double balance);
		
		PBOOL GetBalanceExpire(time_t & t) const;
		void SetBalanceExpire(time_t t);
		
		PBOOL GetPoint(PInt64 & point) const;
		void SetPoint(const PInt64 & point);
		
		PBOOL GetLastLoginTime(time_t& t) const;
		void SetLastLoginTime(time_t t);
		
		PBOOL GetCurrentLoginTime(time_t& t) const;
		void SetCurrentLoginTime(time_t t);
		
		PBOOL GetLastLoginIP(PString& ip) const;
		void SetLastLoginIP(const PString& ip);
		
		PBOOL GetCurrentLoginIP(PString& ip) const;
		void SetCurrentLoginIP(const PString& ip);
		
		PBOOL GetLoginCount(DWORD& count) const;
		void SetLoginCount(DWORD count);
		
		PBOOL GetOnlineTime(DWORD& t) const;
		void SetOnlineTime(DWORD t);
	};
	
	typedef UserInfo GetUserInfo;
	
	class SetUserData : public Wrap
	{
	public:
		SetUserData(UMPSignal& sig);
		
		PString GetDataBlock() const;
		void SetDataBlock(const PString& dataBlock);
		
		DWORD GetType() const;
		void SetType(DWORD type);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 & userID);
        
		PString GetKey() const;
		void SetKey(const PString & key);
		
		PBOOL HasShareFlag() const;
		void SetShareFlag(PBOOL share);
		
		DWORD GetTimestamp() const;
		void SetTimestamp(DWORD ts);
		
	};
	
	typedef SetUserData GetUserData;
	typedef SetUserData UserData;
	
	class DTMF : public Wrap
	{
	public:
		DTMF(UMPSignal& sig);
		
		PString GetDTMF() const;
		void SetDTMF(const PString& dtmf);
	};
	
	class Forward : public Wrap
	{
	public:
		Forward(UMPSignal& sig);
		
		PBOOL GetForwardTo(UMPSignal& to) const;
		void SetForwardTo(const UMPSignal& to);
	};
	///////////////////
	class Notify : public Wrap
	{
	public:
		Notify(UMPSignal& sig);
		
		PUInt64 GetTo() const;
		void SetTo(const PUInt64 & to);
		
		E_NotifyType GetType() const;
		void SetType(E_NotifyType type);
		
		time_t GetTime() const;
		void SetTime(time_t t);
		
		PBOOL GetBody(UMPSignal& body) const;
		void SetBody(const UMPSignal& body);
		
		E_Priority GetPriority() const;
		void SetPriority(E_Priority prio);
		
		void SetTemporaryFlag(PBOOL temp);
		PBOOL HasTemporaryFlag() const;
	};
	
	class NotifyBody : public Wrap
	{
	public:
		NotifyBody(UMPSignal& sig);
		
		PString GetTitle() const;
		void SetTitle(const PString& title);
		
		PString GetContent() const;
		void SetContent(const PString& content);
		
		PString GetWebContent() const;
		void SetWebContent(const PString& content);
		
		PString GetHyperLink() const;
		void SetHyperLink(const PString& hlink);
		
		PString GetVar() const;
		void SetVar(const PString& var);
	};
	
	class NotifyBodyAddedAsRUser : public NotifyBody
	{
	public:
		NotifyBodyAddedAsRUser(UMPSignal& sig);
		
		
		PBOOL GetBaseUserInfo(UMPSignal& bui) const;
		void SetBaseUserInfo(const UMPSignal& bui);
		
	};
	
	class NotifyBodyRUserSubState : public NotifyBody
	{
	public:
		NotifyBodyRUserSubState(UMPSignal& sig);
		
		PBOOL GetRUserSubState(UMPSignal& uss) const;
		void SetRUserSubState(const UMPSignal& uss);
	};
	
	class NotifyBodyAcctInfo : public NotifyBody
	{
	public:
		NotifyBodyAcctInfo(UMPSignal& sig);
        
		double GetAmount() const;
		void SetAmount(double amount);
		
        
		double GetBalance() const;
		void SetBalance(double balance);
        
		time_t GetExpireTime() const;
		void SetExpireTime(time_t t);
        
		
		time_t GetAcctTime() const;
		void SetAcctTime(time_t t);
	};
	
	class NotifyBodySys : public NotifyBody
	{
	public:
		NotifyBodySys(UMPSignal& sig);
		
		DWORD GetType() const;
		void SetType(DWORD type);
	};
	
	
	////////////////////
	class GetTempNotify : public Wrap
	{
	public:
		GetTempNotify(UMPSignal& sig);
		
		PUInt64 GetUserID() const;
		void SetUserID(const PUInt64 & userID);
	};
	
	class StoreNotify : public Wrap
	{
	public:
		StoreNotify(UMPSignal& sig);
		
		PBOOL GetNotify(UMPSignal& notify);
		void SetNotify(const UMPSignal& notify);
	};
	
	/////////////
	class SetNotify : public Wrap
	{
	public:
		SetNotify(UMPSignal& sig);
		
		PBOOL Get(UMPSignal& notify);
		void Set(const UMPSignal& notify);
	};
	
	class StatusReport: public Wrap
	{
	public:
		StatusReport(UMPSignal& sig);
		
		PString GetDataBlock() const;
		void SetDataBlock(const PString & data);
	};
	
	/////////////////////////
	
	class FX : public Wrap
	{
		
	public:
		FX(UMPSignal& sig);
		
		void SetHash(const PString & hash);
		PString GetHash() const;
		
		void SetId(DWORD id);
		DWORD GetId() const;
		
		void SetDirection(E_ChannelDirection dir);
		E_ChannelDirection GetDirection() const;
	};
	
	class FileGet : public FX
	{
	public:
		FileGet(UMPSignal& sig);
		
		void SetStore(E_Store store);
		E_Store GetStore() const;
		
	};
	
	typedef FileGet FilePut;
	
	class FileAck : public FX
	{
	public:
		FileAck(UMPSignal& sig);
		
		E_ResultReason GetResult() const;
		void SetResult(E_ResultReason result);
	};
	
	typedef FileAck FileDone;
    
    
	class MonitorSubState : public Wrap
	{
	public:
		MonitorSubState(UMPSignal& sig);
        
		void SetUserID(const PUInt64 & uid);
		PUInt64 GetUserID() const;
        
		//#id/name/number
		void SetUsers(const PStringArray & users);
		PStringArray GetUsers() const;
		
	};
	
	class CallExtraInfo : public Wrap
	{
	public:
		CallExtraInfo(UMPSignal & signal);
		
	public:
		
		PString GetCalledNumber() const;
		void SetCalledNumber(const PString & number);
		
		PString GetCalledName() const;
		void SetCalledName(const PString & name);
		
		PString GetCallerNumber() const;
		void SetCallerNumber(const PString & number);
		
		PString GetCallerName() const;
		void SetCallerName(const PString & name);
        
		PString GetCalledAddress() const;
		void SetCalledAddress(const PString & addr);
		
		PString GetCallerAddress() const;
		void SetCallerAddress(const PString & addr);
        
		
		PString GetCallIdentifier() const;
		void SetCallIdentifier(const PString & id);
        
		void SetRTPAddress(const PString & addr);
		PString GetRTPAddress() const;
        
		void SetRTCPAddress(const PString & addr);
		PString GetRTCPAddress() const;
        
		PString GetRTPType() const;
		void SetRTPType(const PString & type);
        
		PBYTEArray GetKey() const;
		void SetKey(const PBYTEArray & key);
        
		PString GetProtocolSpecifiedReason() const;
		void SetProtocolSpecifiedReason(const PString & reason);
        
		PString GetVendor() const;
		void SetVendor(const PString & vendor);
        
		PString GetCandidateRtpIps() const;
		void SetCandidateRtpIps(const PString & rtp_ips);
        
		PString GetSelectedRtpIp() const;
		void SetSelectedRtpIp(const PString & rtp_ip);
        
	};
    
	class MessagePush : public Sig::Wrap
	{
	public:
		MessagePush(UMPSignal& sig);
        
		PString GetMsgId() const;
		void SetMsgId(const PString& msgId);
        
		PUInt64 GetWindowType() const;
		void SetWindowType(PUInt64 windowType);
        
		PString GetWindowSize() const;
		void SetWindowSize(const PString& windowSize);
        
		PUInt64 GetKeepTime() const;
		void SetKeepTime(PUInt64 keepTime);
        
		PString GetPageUrl() const;
		void SetPageUrl(const PString& url);
	};
    
	class UserLevel : public Sig::Wrap
	{
	public:
		UserLevel(UMPSignal& sig);
        
		PInt64 GetLevel() const;
		void SetLevel(const PInt64 level);
        
		PInt64 GetExperience() const;
		void SetExperience(const PInt64 values);
        
		PInt64 GetExperienceCapability() const;
		void SetExperienceCapability(const PInt64 values);
        
		PUInt64 GetInteractTypeExtend() const;
		void SetInteractTypeExtend(const PUInt64 values);
	};
    
    
	class CBSRequest : public Sig::Wrap
	{
	public:
		CBSRequest(UMPSignal& sig);
		
		PString GetCommand() const;
		void SetCommand(const PString& cmd);
		
		PString GetSessionId() const;
		void SetSessionId(const PString& guid);
        
		PBOOL GetSub(UMPSignal & sub) const;
		void SetSub(const UMPSignal & sub);
	};
    
	class CBSResponse : public CBSRequest
	{
	public:
		CBSResponse(UMPSignal & sig);
        
		E_ResultReason GetResult() const;
		void SetResult(E_ResultReason result);
        
		PString GetDescription() const;
		void SetDescription(const PString & desc);
        
	};
    
	class FetchUserEInfo : public Wrap
	{
	public:
		FetchUserEInfo(UMPSignal& sig);
		void SetUserNumber(const PString& userNumber);
		void SetCalleeNumber(const PString& calleeNumber);
		void SetCallSessionId(const PString& callSesssionId);
	};
    
	class UserEInfo : public Wrap
	{
	public:
		UserEInfo(UMPSignal& sig);
		PBOOL GetBaseUserInfo(UMPSignal& bui) const;
		PString GetUserPasswd() const; //e_ele_userPasswd
		PString GetCalledNumber() const; //e_ele_calledNumber
		PString GetCallSessionId() const; //e_ele_guid
	};
    
	class CBSConnInfo : public Sig::Wrap
	{
	public:
		CBSConnInfo(UMPSignal& sig);
		
		PString GetOperator() const;
		void SetOperator(const PString& op);		
	};
    
	class CBSConnInfoAck : public Sig::Wrap
	{
	public:
		CBSConnInfoAck(UMPSignal& sig);
		
		E_ResultReason GetResult() const;
		void SetResult(E_ResultReason result);
		
	};
};

#endif
