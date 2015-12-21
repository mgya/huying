//
//  sig_wrap.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-5.
//  Copyright (c) 2014年 Dev. All rights reserved.
//



#include "ump_base.h"
#include "sig_wrap.h"

Sig::Wrap::Wrap(UMPSignal& sig)
: _signal(sig)
{
}

Sig::Wrap::Wrap(const Wrap& other)
: _signal(other._signal)
{
}

E_UMPTag Sig::Wrap::GetTag() const
{
	return _signal.GetTag();
}
PString Sig::Wrap::GetTagName() const
{
	return _signal.GetTagName();
}
void Sig::Wrap::SetTag(E_UMPTag tag)
{
	_signal.SetTag(tag);
}

UMPSignal& Sig::Wrap::GetSignal() const
{
	return _signal;
}

PBOOL Sig::Wrap::GetSubSignal(E_UMPTag sigTag, UMPSignal& subSig) const
{
	return _signal.Get(sigTag, subSig);
}

void Sig::Wrap::SetSubSignal(E_UMPTag sigTag, const UMPSignal& subSig)
{
	_signal.Set(sigTag, subSig);
}

DWORD Sig::Wrap::GetCmdNumber() const
{
	DWORD cmdNO = 0;
	_signal.Get(e_ele_cmdNumber, cmdNO);
	return cmdNO;
}
void Sig::Wrap::SetCmdNumber(DWORD cmdNumber)
{
	_signal.Set(e_ele_cmdNumber, cmdNumber);
}

DWORD Sig::Wrap::GetSeqNumber() const
{
	DWORD seqNO = 0;
	_signal.Get(e_ele_seqNumber, seqNO);
	return seqNO;
}
void Sig::Wrap::SetSeqNumber(DWORD seqNumber)
{
	_signal.Set(e_ele_seqNumber, seqNumber);
}
/////////////
Sig::GetBaseUserInfo::GetBaseUserInfo(UMPSignal& sig)
: Wrap(sig)
{
}

PUInt64 Sig::GetBaseUserInfo::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}

void Sig::BaseUserInfo::SetUserID(const PUInt64 &uid)
{
	_signal.Set(e_ele_userID, uid);
}

PString Sig::GetBaseUserInfo::GetUserName() const
{
	PString uname;
	_signal.Get(e_ele_userName, uname);
	return uname;
}
void Sig::GetBaseUserInfo::SetUserName(const PString& uname)
{
	_signal.Set(e_ele_userName, uname.Trim());
}

PString Sig::GetBaseUserInfo::GetUserNumber() const
{
	PString unumber;
	_signal.Get(e_ele_userNumber, unumber);
	return unumber;
}

void Sig::GetBaseUserInfo::SetUserNumber(const PString& unumber)
{
	_signal.Set(e_ele_userNumber, unumber.Trim());
}

////////////////
Sig::GetBaseGroupInfo::GetBaseGroupInfo(UMPSignal& sig)
: Wrap(sig)
{
}

PUInt64 Sig::GetBaseGroupInfo::GetGroupID() const
{
	PUInt64 gid = 0;
	//_signal.Get(e_ele_groupID, gid);
	return gid;
}

void Sig::GetBaseGroupInfo::SetGroupID(const PUInt64 &gid)
{
	//_signal.Set(e_ele_groupID, gid);
}

PString Sig::GetBaseGroupInfo::GetGroupName() const
{
	PString gname;
	//_signal.Get(e_ele_groupName, gname);
	return gname;
}

void Sig::GetBaseGroupInfo::SetGroupName(const PString& gname)
{
	//_signal.Set(e_ele_groupName, gname.Trim());
}
/////////////////////
Sig::Login::Login(UMPSignal& sig)
: Wrap(sig)
{
}

void Sig::Login::SetBaseUserInfo(const UMPSignal& bui)
{
	SetSubSignal(e_sig_baseUserInfo, bui);
}

PBOOL Sig::Login::GetBaseUserInfo(UMPSignal& bui) const
{
	return GetSubSignal(e_sig_baseUserInfo, bui);
}

void Sig::Login::SetVersion(DWORD version)
{
	_signal.Set(e_ele_version, version);
}

DWORD Sig::Login::GetVersion() const
{
	DWORD ver = 0;
	_signal.Get(e_ele_version, ver);
	return ver;
}

void Sig::Login::SetForceFlag(PBOOL force)
{
	if (force)
		_signal.Set(e_ele_forceFlag, "");
	else
		_signal.Remove(e_ele_forceFlag);
}

PBOOL Sig::Login::HasForceFlag() const
{
	return _signal.Exist(e_ele_forceFlag);
}

void Sig::Login::SetEncryptFlag(PBOOL encrypt)
{
	if (encrypt)
		_signal.Set(e_ele_encryptFlag, "");
	else
		_signal.Remove(e_ele_encryptFlag);
}

PBOOL Sig::Login::HasEncryptFlag() const
{
	return _signal.Exist(e_ele_encryptFlag);
}

void Sig::Login::SetClientType(E_ClientType ctype)
{
	_signal.Set(e_ele_clientType, (DWORD) ctype);
}

E_ClientType Sig::Login::GetClientType() const
{
	DWORD ctype = e_clt_t_unknown;
	_signal.Get(e_ele_clientType, ctype);
	return (E_ClientType) ctype;
}

void Sig::Login::SetForwardFlag(PBOOL b)
{
	if (b)
		_signal.Set(e_ele_forwardFlag, "");
	else
		_signal.Remove(e_ele_forwardFlag);
}

PBOOL Sig::Login::HasForwardFlag() const
{
	return _signal.Exist(e_ele_forwardFlag);
}


PBOOL Sig::Login::GetCapabilities(CapabilityArray & caps) const
{
	PString str;
	if(!_signal.Get(e_ele_capabilities, str))
		return FALSE;
    
	caps.clear();
	PStringArray strs = str.Tokenise(";",FALSE);
    
	for (PINDEX i = 0; i < strs.GetSize(); i++) {
		caps.push_back((E_InteractType)strs[i].AsUnsigned(16));
        
	}
	return TRUE;
}

void Sig::Login::SetCapabilities(const CapabilityArray & caps)
{
	PString str;
	for (unsigned i = 0; i < caps.size(); i++) {
		if (!str.IsEmpty())
			str += ";";
		str += PString(PString::Unsigned, (long) caps[i], 16);
	}
    
	_signal.Set(e_ele_capabilities, str);
}


PString Sig::Login::getClientId() const{
	PString id;
	_signal.Get(e_ele_clientId, id);
	return id;
}
void Sig::Login::setClientId(const PString & id){
	_signal.Set(e_ele_clientId, id);
}


////////////
Sig::Logout::Logout(UMPSignal & sig)
:Wrap(sig)
{
    
}

//////////////////////
Sig::RoundTrip::RoundTrip(UMPSignal & sig)
:Wrap(sig)
{
}

DWORD Sig::RoundTrip::GetOnlineCount() const
{
	DWORD oc = 0;
	_signal.Get(e_ele_onlineCount,oc);
	return oc;
}

void Sig::RoundTrip::SetOnlineCount(DWORD onlineCount)
{
	_signal.Set(e_ele_onlineCount,onlineCount);
}

////////////////////
Sig::RoundTripAck::RoundTripAck(UMPSignal & sig)
:Wrap(sig)
{
    
}
///////////////

Sig::LoginAck::LoginAck(UMPSignal& sig)
: Wrap(sig)
{
}

E_ResultReason Sig::LoginAck::GetResult() const
{
	DWORD result = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, result);
	return (E_ResultReason) result;
}

void Sig::LoginAck::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator, (DWORD) result);
}

PBYTEArray Sig::LoginAck::GetKey() const
{
	PBYTEArray key;
	_signal.Get(e_ele_key, key);
	return key;
}
void Sig::LoginAck::SetKey(const PBYTEArray& key)
{
	_signal.Set(e_ele_key, key);
}

PString Sig::LoginAck::GetForwardTo() const
{
	PString to;
	_signal.Get(e_ele_forwardTo, to);
	return to;
}

void Sig::LoginAck::SetForwardTo(const PString& to)
{
	_signal.Set(e_ele_forwardTo, to);
}

PString Sig::LoginAck::GetURL() const
{
	PString url;
	_signal.Get(e_ele_url, url);
	return url;
}

void Sig::LoginAck::SetURL(const PString& url)
{
	_signal.Set(e_ele_url, url);
}
//////////
Sig::Pologin::Pologin(UMPSignal& sig)
: Wrap(sig)
{
}

PBYTEArray Sig::Pologin::GetKey() const
{
	PBYTEArray key;
	_signal.Get(e_ele_key, key);
	return key;
}

void Sig::Pologin::SetKey(const PBYTEArray& key)
{
	_signal.Set(e_ele_key, key);
}

PBYTEArray Sig::Pologin::GetLastSessionGUID() const
{
	PBYTEArray lastSGUID;
	_signal.Get(e_ele_lastGUID,lastSGUID);
	return lastSGUID;
}

void Sig::Pologin::SetLastSessionGUID(const PBYTEArray & lastSGUID)
{
	_signal.Set(e_ele_lastGUID,lastSGUID);
}

PBOOL Sig::Pologin::GetClientInfo(UMPSignal & clientInfo) const
{
	return _signal.Get(e_sig_clientInfo, clientInfo);
}

void Sig::Pologin::SetClientInfo(const UMPSignal & clientInfo)
{
	_signal.Set(e_sig_clientInfo, clientInfo);
}
///////
Sig::PologinAck::PologinAck(UMPSignal& sig)
: Wrap(sig)
{
}

E_ResultReason Sig::PologinAck::GetResult() const
{
	DWORD result = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, result);
	return (E_ResultReason) result;
}

void Sig::PologinAck::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator, (DWORD) result);
}

PBYTEArray Sig::PologinAck::GetUserInfo() const
{
	PBYTEArray userInfo;
	_signal.Get(e_sig_userInfo, userInfo);
	return userInfo;
}

void Sig::PologinAck::SetUserInfo(const PBYTEArray& userInfo)
{
	_signal.Set(e_sig_userInfo, userInfo);
}

PBYTEArray Sig::PologinAck::GetSessionGUID() const
{
	PBYTEArray guid;
	_signal.Get(e_ele_guid, guid);
	return guid;
}

void Sig::PologinAck::SetSessionGUID(const PBYTEArray& guid)
{
	_signal.Set(e_ele_guid, guid);
}
///////////////
Sig::ServerInfo::ServerInfo(UMPSignal& sig)
: Wrap(sig)
{
}

PString Sig::ServerInfo::GetName() const
{
	PString name;
	_signal.Get(e_ele_name, name);
	return name;
}

void Sig::ServerInfo::SetName(const PString& name)
{
	_signal.Set(e_ele_name, name);
}

PString Sig::ServerInfo::GetReflector() const
{
	PString r;
	_signal.Get(e_ele_reflectorListener, r);
	return r;
}


void Sig::ServerInfo::SetReflector(const PString& reflector)
{
	_signal.Set(e_ele_reflectorListener, reflector);
}


PString Sig::ServerInfo::GetUDPProxy() const
{
	PString p;
	_signal.Get(e_ele_udpProxy, p);
	return p;
}

void Sig::ServerInfo::SetUDPProxy(const PString &proxy)
{
	_signal.Set(e_ele_udpProxy,proxy);
}

PString Sig::ServerInfo::GetFX() const
{
	PString r;
	_signal.Get(e_ele_fxListener,r);
	return r;
}

void Sig::ServerInfo::SetFX(const PString & fx)
{
	_signal.Set(e_ele_fxListener,fx);
}

DWORD Sig::ServerInfo::GetOnlineCount() const
{
	DWORD oc = 0;
	_signal.Get(e_ele_onlineCount, oc);
	return oc;
}
void Sig::ServerInfo::SetOnlineCount(DWORD onlineCount)
{
	_signal.Set(e_ele_onlineCount, onlineCount);
}


time_t Sig::ServerInfo::GetServerTime() const
{
	DWORD t=0;
	_signal.Get(e_ele_time,t);
	return (time_t)t;
}

void Sig::ServerInfo::SetServerTime(time_t t)
{
	_signal.Set(e_ele_time,(DWORD)t);
}
//////////////////
Sig::ClientInfo::ClientInfo(UMPSignal& sig)
: Wrap(sig)
{
}


PUInt64 Sig::ClientInfo::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}
void Sig::ClientInfo::SetUserID(const PUInt64& uid)
{
	_signal.Set(e_ele_userID, uid);
}


E_ClientType Sig::ClientInfo::GetClientType() const
{
	DWORD type = e_clt_t_unknown;
    
	_signal.Get(e_ele_clientType, type);
	return (E_ClientType) type;
}

void Sig::ClientInfo::SetClientType(E_ClientType type)
{
	_signal.Set(e_ele_clientType, (DWORD) type);
}

PString Sig::ClientInfo::GetOSInfo() const
{
	PString osInfo;
	_signal.Get(e_ele_osInfo, osInfo);
	return osInfo;
}

void Sig::ClientInfo::SetOSInfo(const PString& osInfo)
{
	_signal.Set(e_ele_osInfo, osInfo);
}

DWORD Sig::ClientInfo::GetVersion() const
{
	DWORD ver = 0;
	_signal.Get(e_ele_version, ver);
	return ver;
}
void Sig::ClientInfo::SetVersion(DWORD version)
{
	_signal.Set(e_ele_version, version);
}


PString Sig::ClientInfo::GetLocalInterface() const
{
	PString ifs;
	_signal.Get(e_ele_interfaces, ifs);
	return ifs;
}

void Sig::ClientInfo::SetLocalInterface(const PString& ifs)
{
	_signal.Set(e_ele_interfaces, ifs);
}


PString Sig::ClientInfo::GetMacInfo() const
{
	PString macInfo;
	_signal.Get(e_ele_mac, macInfo);
	return macInfo;
}

void Sig::ClientInfo::SetMacInfo(const PString& macInfo)
{
	_signal.Set(e_ele_mac, macInfo);
}

////////
Sig::SetUserMainState::SetUserMainState(UMPSignal& sig)
: Wrap(sig)
{
}

void Sig::SetUserMainState::SetForceFlag(PBOOL force)
{
	if (force)
		_signal.Set(e_ele_forceFlag, "");
	else
		_signal.Remove(e_ele_forceFlag);
}
PBOOL Sig::SetUserMainState::HasForceFlag() const
{
	return _signal.Exist(e_ele_forceFlag);
}

PUInt64 Sig::SetUserMainState::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}

void Sig::SetUserMainState::SetUserID(const PUInt64& uid)
{
	_signal.Set(e_ele_userID, uid);
}

E_UserMainState Sig::SetUserMainState::GetMainState() const
{
	DWORD ums = 0;
	_signal.Get(e_ele_userMainState, ums);
	return (E_UserMainState) ums;
}
void Sig::SetUserMainState::SetMainState(E_UserMainState ums)
{
	_signal.Set(e_ele_userMainState, (DWORD) ums);
}

PBYTEArray Sig::SetUserMainState::GetSessionGUID() const
{
	PBYTEArray guid;
	_signal.Get(e_ele_guid, guid);
	return guid;
}

void Sig::SetUserMainState::SetSessionGUID(const PBYTEArray& guid)
{
	_signal.Set(e_ele_guid, guid);
}

PBYTEArray Sig::SetUserMainState::GetLastSessionGUID() const
{
	PBYTEArray guid;
	_signal.Get(e_ele_lastGUID,guid);
	return guid;
}

void Sig::SetUserMainState::SetLastSessionGUID(const PBYTEArray & lastGUID)
{
	_signal.Set(e_ele_lastGUID,lastGUID);
}

PString Sig::SetUserMainState::GetUserIP() const
{
	PString ip;
	_signal.Get(e_ele_ip, ip);
	return ip;
}
void Sig::SetUserMainState::SetUserIP(const PString& ip)
{
	_signal.Set(e_ele_ip, ip);
}

//////////////
Sig::SetUserSubState::SetUserSubState(UMPSignal& sig)
: Wrap(sig)
{
}

PUInt64 Sig::SetUserSubState::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}

void Sig::SetUserSubState::SetUserID(const PUInt64 &uid)
{
	_signal.Set(e_ele_userID, uid);
}

PUInt64 Sig::SetUserSubState::GetRelatedUserID() const
{
	PUInt64 ruid = 0;
	_signal.Get(e_ele_relatedUserID,ruid);
	return ruid;
}

void Sig::SetUserSubState::SetRelatedUserID(const PUInt64 & ruid)
{
	_signal.Set(e_ele_relatedUserID,ruid);
}

PBOOL Sig::SetUserSubState::HasReplyFlag() const
{
	return _signal.Exist(e_ele_replyFlag);
}

void Sig::SetUserSubState::SetReplyFlag(PBOOL f)
{
	if(f)
		_signal.Set(e_ele_replyFlag,"");
	else
		_signal.Remove(e_ele_replyFlag);
}

E_UserSubState Sig::SetUserSubState::GetSubState() const
{
	DWORD subState = e_subState_normal;
	_signal.Get(e_ele_userSubState, subState);
	return (E_UserSubState) subState;
}
void Sig::SetUserSubState::SetSubState(E_UserSubState subState)
{
	_signal.Set(e_ele_userSubState, (DWORD) subState);
}

E_ClientType Sig::SetUserSubState::GetClientType() const
{
	DWORD ctype = e_clt_t_unknown;
	_signal.Get(e_ele_clientType, ctype);
	return (E_ClientType) ctype;
}


void Sig::SetUserSubState::SetClientType(E_ClientType ctype)
{
	_signal.Set(e_ele_clientType, (DWORD) ctype);
}

PString Sig::SetUserSubState::GetDescription() const
{
	PString desc;
	_signal.Get(e_ele_description, desc);
	return desc;
}

void Sig::SetUserSubState::SetDescription(const PString& desc)
{
	_signal.Set(e_ele_description, desc);
}


PBOOL Sig::SetUserSubState::GetFullRelated(PBOOL & b) const
{
	int fr = FALSE;
	if(!_signal.Get(e_ele_fullRelated, fr))
		return FALSE;
    
	b = (fr!=0);
    
	return TRUE;
}

void  Sig::SetUserSubState::SetFullRelated(PBOOL b)
{
	_signal.Set(e_ele_fullRelated, b?1:0);
}

///////////////

/////////////////
Sig::GetUserPassword::GetUserPassword(UMPSignal& sig)
: Wrap(sig)
{
}

PUInt64 Sig::GetUserPassword::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}

void Sig::GetUserPassword::SetUserID(const PUInt64 &uid)
{
	_signal.Set(e_ele_userID, uid);
}

////////////
////////////
Sig::KeepAlive::KeepAlive(UMPSignal& sig)
: Wrap(sig)
{
}

DWORD Sig::KeepAlive::GetTick() const
{
	DWORD tick = 0;
	_signal.Get(e_ele_time, tick);
	return tick;
}

void Sig::KeepAlive::SetTick(DWORD tick)
{
	_signal.Set(e_ele_time, tick);
}
/////////
Sig::UMPInit::UMPInit(UMPSignal& sig)
: Wrap(sig)
{
}

PString Sig::UMPInit::GetNeighborListeners() const
{
	PString nls;
	_signal.Get(e_ele_neighborListeners, nls);
	return nls;
}
void Sig::UMPInit::SetNeighborListeners(const PString& nls)
{
	_signal.Set(e_ele_neighborListeners, nls);
}

PString Sig::UMPInit::GetUMPListeners() const
{
	PString uls;
	_signal.Get(e_ele_umpListeners, uls);
	return uls;
}
void Sig::UMPInit::SetUMPListeners(const PString& uls)
{
	_signal.Set(e_ele_umpListeners, uls);
}


PString Sig::UMPInit::GetName() const
{
	PString name;
	_signal.Get(e_ele_name, name);
	return name;
}

void Sig::UMPInit::SetName(const PString& name)
{
	_signal.Set(e_ele_name, name);
}
/////////
Sig::BridgeInit::BridgeInit(UMPSignal& sig)
: Wrap(sig)
{
}


PString Sig::BridgeInit::GetListeners() const
{
	PString bls;
	_signal.Get(e_ele_bridgeListeners, bls);
	return bls;
}
void Sig::BridgeInit::SetListeners(const PString& bls)
{
	_signal.Set(e_ele_bridgeListeners, bls);
}


PString Sig::BridgeInit::GetName() const
{
	PString name;
	_signal.Get(e_ele_name, name);
	return name;
}

void Sig::BridgeInit::SetName(const PString& name)
{
	_signal.Set(e_ele_name, name);
}
///////////
Sig::InterInit::InterInit(UMPSignal& sig)
: Wrap(sig)
{
}

PBOOL Sig::InterInit::GetUMPInit(UMPSignal& init)
{
	return _signal.Get(e_sig_umpInit, init);
}

void Sig::InterInit::SetUMPInit(const UMPSignal& init)
{
	_signal.Set(e_sig_umpInit, init);
}

PBOOL Sig::InterInit::GetBridgeInit(UMPSignal& init)
{
	return _signal.Get(e_sig_bridgeInit, init);
}

void Sig::InterInit::SetBridgeInit(const UMPSignal& init)
{
	_signal.Set(e_sig_bridgeInit, init);
}

DWORD Sig::InterInit::GetIdentifier() const
{
	DWORD id = 0;
	_signal.Get(e_ele_identifier, id);
	return id;
}

void Sig::InterInit::SetIdentifier(DWORD id)
{
	_signal.Set(e_ele_identifier, id);
}

time_t Sig::InterInit::GetStartupTime() const
{
	DWORD t = 0;
	_signal.Get(e_ele_time, t);
	return (time_t) t;
}

void Sig::InterInit::SetStartupTime(time_t t)
{
	_signal.Set(e_ele_time, (DWORD) t);
}

DWORD Sig::InterInit::GetVersion() const
{
	
	DWORD version = 0;
	_signal.Get(e_ele_version, version);
	return version;
}

void Sig::InterInit::SetVersion(DWORD version)
{
	_signal.Set(e_ele_version, version);
	
}
/////////////
Sig::NeighborInit::NeighborInit(UMPSignal& sig)
: Wrap(sig)
{
}
DWORD Sig::NeighborInit::GetIdentifier() const
{
	DWORD id = 0;
	_signal.Get(e_ele_identifier, id);
	return id;
}

void Sig::NeighborInit::SetIdentifier(DWORD id)
{
	_signal.Set(e_ele_identifier, id);
}

//////////
Sig::UpdateServerListeners::UpdateServerListeners(UMPSignal& sig)
: Wrap(sig)
{
}

DWORD Sig::UpdateServerListeners::GetServerCount() const
{
	return _signal.GetSize();
}

PBOOL Sig::UpdateServerListeners::GetListeners(PINDEX index, DWORD& lid,
                                              UMPSignal& serverListeners) const
{
	PString str;
	if(_signal.GetAt(index,(E_UMPTag&)lid,str)){
		serverListeners.FromString(str);
		return TRUE;
	}else
		return FALSE;
}

void Sig::UpdateServerListeners::AddListeners(DWORD lid,
                                              const UMPSignal& serverListeners)
{
	_signal.Set((E_UMPTag) lid, serverListeners);
}

//////////

Sig::ServerListeners::ServerListeners(UMPSignal& sig)
: Wrap(sig)
{
}

PString Sig::ServerListeners::GetUMPListeners() const
{
	PString uls;
	_signal.Get(e_ele_umpListeners, uls);
	return uls;
}

void Sig::ServerListeners::SetUMPListeners(const PString& uls)
{
	_signal.Set(e_ele_umpListeners, uls);
}


PString Sig::ServerListeners::GetNeighborListeners() const
{
	PString nls;
	_signal.Get(e_ele_neighborListeners, nls);
	return nls;
}

void Sig::ServerListeners::SetNeighborListeners(const PString& nls)
{
	_signal.Set(e_ele_neighborListeners, nls);
}

PString Sig::ServerListeners::GetBridgeListeners() const
{
	PString bls;
	_signal.Get(e_ele_bridgeListeners, bls);
	return bls;
}

void Sig::ServerListeners::SetBridgeListeners(const PString& bls)
{
	_signal.Set(e_ele_bridgeListeners, bls);
}

//////
Sig::ForceOffline::ForceOffline(UMPSignal& sig)
: Wrap(sig)
{
}


PUInt64 Sig::ForceOffline::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}

void Sig::ForceOffline::SetUserID(const PUInt64 &uid)
{
	_signal.Set(e_ele_userID, uid);
}


E_ResultReason Sig::ForceOffline::GetResult() const
{
	DWORD result = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, result);
	return (E_ResultReason) result;
}

void Sig::ForceOffline::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator, (DWORD) result);
}

///////////
Sig::GetRelatedUsers::GetRelatedUsers(UMPSignal& sig)
: Wrap(sig)
{
}

PUInt64 Sig::GetRelatedUsers::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}
void Sig::GetRelatedUsers::SetUserID(const PUInt64& uid)
{
	_signal.Set(e_ele_userID, uid);
}

void Sig::GetRelatedUsers::SetTimestamp(DWORD ts)
{
	_signal.Set(e_ele_timestamp,ts);
}

DWORD Sig::GetRelatedUsers::GetTimestamp() const
{
	DWORD ts=0;
	_signal.Get(e_ele_timestamp, ts);
	return ts;
}
///////
Sig::RelatedUsers::RelatedUsers(UMPSignal& sig)
: GetRelatedUsers(sig)
{
}

void Sig::RelatedUsers::SetRUsers(const PString& ruid2gid)
{
	_signal.Set(e_ele_dataBlock, ruid2gid);
}

PString Sig::RelatedUsers::GetRUsers() const
{
	PString s;
	_signal.Get(e_ele_dataBlock, s);
	return s;
}

E_ResultReason Sig::RelatedUsers::GetResult() const
{
	DWORD result = e_r_ok;
	_signal.Get(e_ele_resultIndicator, result);
	return (E_ResultReason) result;
}

void Sig::RelatedUsers::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator, (DWORD) result);
}

/////////
Sig::GetUserLocation::GetUserLocation(UMPSignal& sig)
: Wrap(sig)
{
}


PUInt64 Sig::GetUserLocation::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}
void Sig::GetUserLocation::SetUserID(const PUInt64 &uid)
{
	_signal.Set(e_ele_userID, uid);
}

E_InteractType Sig::GetUserLocation::GetInteractType() const
{
	DWORD itype = 0;
	_signal.Get(e_ele_type, itype);
	return (E_InteractType) itype;
}

void Sig::GetUserLocation::SetInteractType(E_InteractType itype)
{
	_signal.Set(e_ele_type, (DWORD) itype);
}
/////////////
Sig::AddRelatedUser::AddRelatedUser(UMPSignal& sig)
: Wrap(sig)
{
}

void Sig::AddRelatedUser::SetRelatedBaseUserInfo(const UMPSignal& bui)
{
	SetSubSignal(e_sig_baseUserInfo, bui);
}
PBOOL Sig::AddRelatedUser::GetRelatedBaseUserInfo(UMPSignal& bui) const
{
	return GetSubSignal(e_sig_baseUserInfo, bui);
}

void Sig::AddRelatedUser::SetBaseGroupInfo(const UMPSignal& bgi)
{
	SetSubSignal(e_sig_baseGroupInfo, bgi);
}
PBOOL Sig::AddRelatedUser::GetBaseGroupInfo(UMPSignal& bgi) const
{
	return GetSubSignal(e_sig_baseGroupInfo, bgi);
}

PUInt64 Sig::AddRelatedUser::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}
void Sig::AddRelatedUser::SetUserID(const PUInt64& uid)
{
	_signal.Set(e_ele_userID, uid);
}

PString Sig::AddRelatedUser::GetComment() const
{
	PString comment;
	_signal.Get(e_ele_comment, comment);
	return comment;
}

void Sig::AddRelatedUser::SetComment(const PString& comment)
{
	_signal.Set(e_ele_comment, comment);
}

///////////
Sig::ModRelatedUser::ModRelatedUser(UMPSignal& sig)
: Wrap(sig)
{
}

void Sig::ModRelatedUser::SetRelatedBaseUserInfo(const UMPSignal& bui)
{
	SetSubSignal(e_sig_baseUserInfo, bui);
}
PBOOL Sig::ModRelatedUser::GetRelatedBaseUserInfo(UMPSignal& bui) const
{
	return GetSubSignal(e_sig_baseUserInfo, bui);
}

void Sig::ModRelatedUser::SetOldBaseGroupInfo(const UMPSignal& bgi)
{
	SetSubSignal(e_ele_oldBaseGroupInfo, bgi);
}

PBOOL Sig::ModRelatedUser::GetOldBaseGroupInfo(UMPSignal& bgi) const
{
	return GetSubSignal(e_ele_oldBaseGroupInfo, bgi);
}


void Sig::ModRelatedUser::SetNewBaseGroupInfo(const UMPSignal& bgi)
{
	SetSubSignal(e_ele_newBaseGroupInfo, bgi);
}

PBOOL Sig::ModRelatedUser::GetNewBaseGroupInfo(UMPSignal& bgi) const
{
	return GetSubSignal(e_ele_newBaseGroupInfo, bgi);
}

PUInt64 Sig::ModRelatedUser::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}
void Sig::ModRelatedUser::SetUserID(const PUInt64 &uid)
{
	_signal.Set(e_ele_userID, uid);
}

/////////////////
Sig::DelRelatedUser::DelRelatedUser(UMPSignal& sig)
: Wrap(sig)
{
}

void Sig::DelRelatedUser::SetRelatedBaseUserInfo(const UMPSignal& bui)
{
	SetSubSignal(e_sig_baseUserInfo, bui);
}
PBOOL Sig::DelRelatedUser::GetRelatedBaseUserInfo(UMPSignal& bui) const
{
	return GetSubSignal(e_sig_baseUserInfo, bui);
}

PUInt64 Sig::DelRelatedUser::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}
void Sig::DelRelatedUser::SetUserID(const PUInt64 &uid)
{
	_signal.Set(e_ele_userID, uid);
}
////////////
Sig::Interact::Interact(UMPSignal& sig)
: Wrap(sig)
{
}

PBOOL Sig::Interact::GetTo(UMPSignal& to) const
{
	return _signal.Get(e_ele_to, to);
}

void Sig::Interact::SetTo(const UMPSignal& to)
{
	_signal.Set(e_ele_to, to);
}

PBOOL Sig::Interact::GetFrom(UMPSignal& from) const
{
	return _signal.Get(e_ele_from, from);
}
void Sig::Interact::SetFrom(const UMPSignal& from)
{
	_signal.Set(e_ele_from, from);
}

PBOOL Sig::Interact::GetForwarder(UMPSignal& forwarder) const
{
	return _signal.Get(e_ele_forwarder, forwarder);
}

void Sig::Interact::SetForwarder(const UMPSignal& forwarder)
{
	_signal.Set(e_ele_forwarder, forwarder);
}

PBOOL Sig::Interact::GetBody(UMPSignal& body) const
{
	return _signal.Get(e_ele_body, body);
}
void Sig::Interact::SetBody(const UMPSignal& body)
{
	_signal.Set(e_ele_body, body);
}

E_InteractType Sig::Interact::GetType() const
{
	DWORD type = 0;
	_signal.Get(e_ele_type, type);
	return (E_InteractType) type;
}
void Sig::Interact::SetType(E_InteractType type)
{
	_signal.Set(e_ele_type, (DWORD) type);
}

time_t Sig::Interact::GetTime() const
{
	DWORD t = 0;
	_signal.Get(e_ele_time, t);
    
	return (time_t) t;
}
void Sig::Interact::SetTime(time_t t)
{
	_signal.Set(e_ele_time, (DWORD) t);
}

void Sig::Interact::SetTemporaryFlag(PBOOL temp)
{
	if (temp)
		_signal.Set(e_ele_temporaryFlag, "");
	else
		_signal.Remove(e_ele_temporaryFlag);
}

PBOOL Sig::Interact::HasTemporaryFlag() const
{
	return _signal.Exist(e_ele_temporaryFlag);
}

void Sig::Interact::SetNoackFlag(PBOOL noack)
{
	if (noack)
		_signal.Set(e_ele_noAckFlag, "");
	else
		_signal.Remove(e_ele_noAckFlag);
}

PBOOL Sig::Interact::HasNoackFlag() const
{
	return _signal.Exist(e_ele_noAckFlag);
}


PBYTEArray Sig::Interact::GetGUID() const
{
	PBYTEArray guid;
	_signal.Get(e_ele_guid, guid);
	return guid;
}

void Sig::Interact::SetGUID(const PBYTEArray& guid)
{
	_signal.Set(e_ele_guid, guid);
}

PBOOL Sig::Interact::HasServiceFlag() const
{
	return _signal.Exist(e_ele_serviceFlag);
}

void Sig::Interact::SetServiceFlag(PBOOL b)
{
	if (b)
		_signal.Set(e_ele_serviceFlag, "");
	else
		_signal.Remove(e_ele_serviceFlag);
}

PString Sig::Interact::GetFromIP() const
{
	PString ip;
	_signal.Get(e_ele_ip, ip);
	return ip;
}

void Sig::Interact::SetFromIP(const PString& ip)
{
	_signal.Set(e_ele_ip, ip);
}


PBOOL Sig::Interact::HasCallerIsExpFlag() const {
	return _signal.Exist(e_ele_caller_isexp);
}

void Sig::Interact::SetCallerIsExpFlag(PBOOL b) {
	if (b) {
		_signal.Set(e_ele_caller_isexp, "");
	} else {
		_signal.Remove(e_ele_caller_isexp);
	}
}


/////////
Sig::InteractAck::InteractAck(UMPSignal& sig)
: Wrap(sig)
{
}

E_ResultReason Sig::InteractAck::GetResult() const
{
	DWORD result = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, result);
	return (E_ResultReason) result;
}

void Sig::InteractAck::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator, (DWORD) result);
}


PBOOL Sig::InteractAck::GetBridge(UMPSignal& bridge) const
{
	return _signal.Get(e_sig_bridge, bridge);
}

void Sig::InteractAck::SetBridge(const UMPSignal& bridge)
{
	_signal.Set(e_sig_bridge, bridge);
}

PString Sig::InteractAck::GetSMSID() const
{
	PString smsid;
	_signal.Get(e_ele_smsID, smsid);
	return smsid;
}

void Sig::InteractAck::SetSMSID(PString smsid)
{
	_signal.Set(e_ele_smsID, smsid);
}

PBYTEArray Sig::InteractAck::GetGUID() const
{
	PBYTEArray guid;
	_signal.Get(e_ele_guid, guid);
	return guid;
}
void Sig::InteractAck::SetGUID(const PBYTEArray& guid)
{
	_signal.Set(e_ele_guid, guid);
}
//////////////////////////////////////////////////////////////////////////
Sig::CallPayer::CallPayer(UMPSignal& sig)
: Wrap(sig){
    
}

PUInt64 Sig::CallPayer::GetPayerId() const{
	PUInt64 id;
	_signal.Get(e_ele_userID, id);
	return id;
}
void Sig::CallPayer::SetPayerId(PUInt64 id){
	_signal.Set(e_ele_userID, id);
}

DWORD Sig::CallPayer::GetCallType() const{
	DWORD type;
	_signal.Get(e_ele_type, type);
	return type;
}
void Sig::CallPayer::setCallType(DWORD type){
	_signal.Set(e_ele_type, type);
}

//////////////////////////////////////////////////////////////////////////
PBOOL Sig::InteractBodyPhone::GetPayer(UMPSignal& payer) const
{
	return _signal.Get(e_ele_callPayer, payer);
}
void Sig::InteractBodyPhone::SetPayer(const UMPSignal& payer)
{
	_signal.Set(e_ele_callPayer, payer);
}

/////////
Sig::InteractBody::InteractBody(UMPSignal& sig)
: Wrap(sig)
{
}


PString Sig::InteractBody::GetContent() const
{
	PString content;
	_signal.Get(e_ele_content, content);
	return content;
}
void Sig::InteractBody::SetContent(const PString& content)
{
	_signal.Set(e_ele_content, content);
}


PBYTEArray Sig::InteractBody::GetKey() const
{
	PBYTEArray key;
	_signal.Get(e_ele_key, key);
	return key;
}
void Sig::InteractBody::SetKey(const PBYTEArray& key)
{
	_signal.Set(e_ele_key, key);
}

//////////////////////////////////////////////////////////////////////////
//SMSContent
Sig::SMSContent::SMSContent(UMPSignal & signal):
InteractBody(signal)
{
}

PString Sig::SMSContent::GetContent()
{
	return InteractBody::GetContent();
}
void Sig::SMSContent::SetContent(PString const & content)
{
	InteractBody::SetContent(content);
}

PString Sig::SMSContent::GetTiming()
{
	PString val;
	_signal.Get(e_ele_time, val);
	return val;
}
void Sig::SMSContent::SetTiming(PString const & timing)
{
	_signal.Set(e_ele_time, timing);
}

PString Sig::SMSContent::GetTimeStamp()
{
	PString val;
	_signal.Get(e_ele_timestamp, val);
	return val;
}
void Sig::SMSContent::SetTimeStamp(PString const & timestamp)
{
	_signal.Set(e_ele_timestamp, timestamp);
}

E_ResultReason Sig::SMSContent::GetResultReason()
{
	DWORD result = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, result);
	return (E_ResultReason) result;
}
void Sig::SMSContent::SetResultReason(E_ResultReason r)
{
	_signal.Set(e_ele_resultIndicator,(DWORD)r);
}

///////////////
Sig::InteractBodyStart::InteractBodyStart(UMPSignal& sig)
: InteractBody(sig)
{
}

PBOOL Sig::InteractBodyStart::GetBridge(UMPSignal& bridge) const
{
	return _signal.Get(e_sig_bridge, bridge);
}
void Sig::InteractBodyStart::SetBridge(const UMPSignal& bridge)
{
	_signal.Set(e_sig_bridge, bridge);
}

PString Sig::InteractBodyStart::GetPeerIP() const
{
	PString str;
	_signal.Get(e_ele_ip, str);
	return str;
}

void Sig::InteractBodyStart::SetPeerIP(const PString& ip)
{
	_signal.Set(e_ele_ip, ip);
}
//////
Sig::InteractBodyStop::InteractBodyStop(UMPSignal& sig)
: InteractBody(sig)
{
}

E_ResultReason Sig::InteractBodyStop::GetResult() const
{
	DWORD result = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, result);
	return (E_ResultReason) result;
}

void Sig::InteractBodyStop::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator, (DWORD) result);
}

/////////
Sig::InteractBodyMessage::InteractBodyMessage(UMPSignal& sig)
: InteractBody(sig)
{
}

PUInt64 Sig::InteractBodyMessage::GetRoomId() const
{
	PUInt64 id = 0;
	_signal.Get(e_ele_roomId,id);
	return id;
}
void Sig::InteractBodyMessage::SetRoomId(const PUInt64 & id)
{
	_signal.Set(e_ele_roomId,id);
}

PBOOL Sig::InteractBodyMessage::HasAutoReplyFlag() const
{
	return _signal.Exist(e_ele_autoReplyFlag);
}

void Sig::InteractBodyMessage::SetAutoReplyFlag(PBOOL b)
{
	if(b)
		_signal.Set(e_ele_autoReplyFlag, "");
	else
		_signal.Remove(e_ele_autoReplyFlag);
}
////////////////////
Sig::InteractBodyShock::InteractBodyShock(UMPSignal& sig)
:InteractBody(sig)
{
    
}
/////////

///////////
Sig::InteractBodyFileTransport::InteractBodyFileTransport(UMPSignal& sig)
: InteractBody(sig)
{
}
PString Sig::InteractBodyFileTransport::GetFileName() const
{
	PString name;
	_signal.Get(e_ele_name, name);
	return name;
}
void Sig::InteractBodyFileTransport::SetFileName(const PString& name)
{
	_signal.Set(e_ele_name, name);
}


DWORD Sig::InteractBodyFileTransport::GetFileSize() const
{
	DWORD size = 0;
	_signal.Get(e_ele_size, size);
	return size;
}

void Sig::InteractBodyFileTransport::SetFileSize(DWORD size)
{
	_signal.Set(e_ele_size, size);
}

void Sig::InteractBodyFileTransport::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator, result);
}

E_ResultReason Sig::InteractBodyFileTransport::GetResult() const
{
    DWORD r = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, r);
	return (E_ResultReason)r;
}

void Sig::InteractBodyFileTransport::SetWanAddress(const PString &ipport)
{
	_signal.Set(e_ele_wanAddress, ipport);
}

PString Sig::InteractBodyFileTransport::GetWanAddress() const
{
	PString ipport;
	_signal.Get(e_ele_wanAddress, ipport);
	return ipport;
}

void Sig::InteractBodyFileTransport::SetLanAddress(const PString &ipport)
{
	_signal.Set(e_ele_lanAddress, ipport);
}

PString Sig::InteractBodyFileTransport::GetLanAddress() const
{
	PString ipport;
	_signal.Get(e_ele_lanAddress, ipport);
	return ipport;
}


void Sig::InteractBodyFileTransport::SetForceFlag(PBOOL flag)
{
	_signal.Set(e_ele_forceFlag, flag);
}

PBOOL Sig::InteractBodyFileTransport::GetForceFlag() const
{
	PBOOL flag = 0;
	_signal.Get(e_ele_forceFlag, flag);
	return flag;
}

////////////
Sig::InteractBodyPhone::InteractBodyPhone(UMPSignal& sig)
: InteractBody(sig)
{
}
/////////////////////
Sig::InteractBodyRoomCtrl::InteractBodyRoomCtrl(UMPSignal & sig)
: InteractBody(sig)
{
    
}
//////////////////////////
Sig::InteractBodyInputIndication::InteractBodyInputIndication(UMPSignal & sig)
:InteractBody(sig)
{
    
}



PBOOL Sig::InteractBodyInputIndication::GetTyping() const
{
	PBOOL v = FALSE;
	_signal.Get(e_ele_typing, v);
	return v;
}

void Sig::InteractBodyInputIndication::SetTyping(PBOOL typing)
{
	_signal.Set(e_ele_typing, typing);
}

///////////////
Sig::Result::Result(UMPSignal& sig)
: Wrap(sig)
{
}

E_ResultReason Sig::Result::GetResult() const
{
	DWORD result = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, result);
	return (E_ResultReason) result;
}

void Sig::Result::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator, (DWORD) result);
}

PString Sig::Result::GetUserPassword() const
{
	PString password;
	_signal.Get(e_ele_userPasswd, password);
	return password;
}
void Sig::Result::SetUserPassword(const PString& password)
{
	_signal.Set(e_ele_userPasswd, password);
}

DWORD Sig::Result::GetLocationID() const
{
	DWORD lid = 0;
	_signal.Get(e_ele_locationID, lid);
	return lid;
}

void Sig::Result::SetLocationID(DWORD lid)
{
	_signal.Set(e_ele_locationID, lid);
}

void Sig::Result::SetBaseUserInfo(const UMPSignal& bui)
{
	SetSubSignal(e_sig_baseUserInfo, bui);
}

PBOOL Sig::Result::GetBaseUserInfo(UMPSignal& bui) const
{
	return GetSubSignal(e_sig_baseUserInfo, bui);
}
void Sig::Result::SetBaseGroupInfo(const UMPSignal& bgi)
{
	SetSubSignal(e_sig_baseGroupInfo, bgi);
}

PBOOL Sig::Result::GetBaseGroupInfo(UMPSignal& bgi) const
{
	return GetSubSignal(e_sig_baseGroupInfo, bgi);
}

PBOOL Sig::Result::GetUserInfo(UMPSignal& userInfo) const
{
	return GetSubSignal(e_sig_userInfo, userInfo);
}

void Sig::Result::SetUserInfo(const UMPSignal& userInfo)
{
	SetSubSignal(e_sig_userInfo, userInfo);
}

PBOOL Sig::Result::GetUserData(UMPSignal& userData) const
{
	return GetSubSignal(e_sig_userData, userData);
}

void Sig::Result::SetUserData(const UMPSignal& userData)
{
	SetSubSignal(e_sig_userData, userData);
}

PString Sig::Result::GetRelatedUsers() const
{
	PString s;
	_signal.Get(e_sig_relatedUsers, s);
	return s;
	
}

void Sig::Result::SetRelatedUsers(const PString & ruis)
{
	_signal.Set(e_sig_relatedUsers,ruis);
}

DWORD Sig::Result::GetTimestamp() const
{
	DWORD ts=0;
	_signal.Get(e_ele_timestamp, ts);
	return ts;
}

void Sig::Result::SetTimestamp(DWORD ts)
{
	_signal.Set(e_ele_timestamp,ts);
}
/////////////
/////////
Sig::StoreInteract::StoreInteract(UMPSignal& sig)
: Wrap(sig)
{
}

PBOOL Sig::StoreInteract::GetInteract(UMPSignal& interact)
{
	return _signal.Get(e_sig_interact, interact);
}

void Sig::StoreInteract::SetInteract(const UMPSignal& interact)
{
	_signal.Set(e_sig_interact, interact);
}
//////////
Sig::GetTempInteract::GetTempInteract(UMPSignal& sig)
: Wrap(sig)
{
}

PUInt64 Sig::GetTempInteract::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}
void Sig::GetTempInteract::SetUserID(const PUInt64 & uid)
{
	_signal.Set(e_ele_userID, uid);
}

PBOOL Sig::GetTempInteract::GetCapabilities(CapabilityArray & caps) const
{
	PString str;
	if(!_signal.Get(e_ele_capabilities, str))
		return FALSE;
    
	caps.clear();
    
	PStringArray strs = str.Tokenise(";",FALSE);
    
	for (PINDEX i = 0; i < strs.GetSize(); i++) {
		caps.push_back((E_InteractType)strs[i].AsUnsigned(16));
	}
	return TRUE;
}

void Sig::GetTempInteract::SetCapabilities(const CapabilityArray& caps)
{
	PString str;
	for (unsigned i = 0; i < caps.size(); i++) {
		if (!str.IsEmpty())
			str += ";";
		str += PString(PString::Unsigned, (long) caps[i], 16);
	}
    
	_signal.Set(e_ele_capabilities, str);
}

///////////
Sig::BridgeSetup::BridgeSetup(UMPSignal& sig)
: Wrap(sig)
{
}

PBOOL Sig::BridgeSetup::HasMasterFlag() const
{
	return _signal.Exist(e_ele_masterFlag);
}

void Sig::BridgeSetup::SetMasterFlag(PBOOL master)
{
	if (master)
		_signal.Set(e_ele_masterFlag, "");
	else
		_signal.Remove(e_ele_masterFlag);
}

PBYTEArray Sig::BridgeSetup::GetBridgeGUID() const
{
	PBYTEArray guid;
	_signal.Get(e_ele_guid, guid);
	return guid;
}
void Sig::BridgeSetup::SetBridgeGUID(const PBYTEArray& guid)
{
	_signal.Set(e_ele_guid, guid);
}

PBYTEArray Sig::BridgeSetup::GetHalfKey() const
{
	PBYTEArray key;
	_signal.Get(e_ele_key, key);
	return key;
}
void Sig::BridgeSetup::SetHalfKey(const PBYTEArray& key)
{
	_signal.Set(e_ele_key, key);
}

PBYTEArray Sig::BridgeSetup::GetEncryptGUID() const
{
	PBYTEArray guid;
	_signal.Get(e_ele_dataBlock, guid);
	return guid;
}
void Sig::BridgeSetup::SetEncryptGUID(const PBYTEArray& guid)
{
	_signal.Set(e_ele_dataBlock, guid);
}

E_InteractType Sig::BridgeSetup::GetType() const
{
	DWORD type = 0;
	_signal.Get(e_ele_type, type);
	return (E_InteractType) type;
}

void Sig::BridgeSetup::SetType(E_InteractType type)
{
	_signal.Set(e_ele_type, (DWORD) type);
}

PBOOL Sig::BridgeSetup::HasUDPForwarderFlag() const
{
	return _signal.Exist(e_ele_udpForwarderFlag);
}

void Sig::BridgeSetup::SetUDPForwarderFlag(PBOOL b)
{
	if (b)
		_signal.Set(e_ele_udpForwarderFlag, "");
	else
		_signal.Remove(e_ele_udpForwarderFlag);
}
/////////
Sig::BridgeReady::BridgeReady(UMPSignal& sig)
: Wrap(sig)
{
}


PString Sig::BridgeReady::GetName() const
{
	PString name;
	_signal.Get(e_ele_name, name);
	return name;
}

void Sig::BridgeReady::SetName(const PString& name)
{
	_signal.Set(e_ele_name, name);
}

void Sig::BridgeReady::SetUDPForwarder(const PString & fwd)
{
	_signal.Set(e_ele_udpForwarder,fwd);
}

PString Sig::BridgeReady::GetUDPForwarder() const
{
	PString fwd;
	_signal.Get(e_ele_udpForwarder,fwd);
	return fwd;
}

void Sig::BridgeReady::SetPeerAddress(const PString & addr)
{
	_signal.Set(e_ele_peerAddress,addr);
}
PString Sig::BridgeReady::GetPeerAddress() const
{
	PString addr;
	_signal.Get(e_ele_peerAddress,addr);
	return addr;
}

void Sig::BridgeReady::SetSelfAddress(const PString & addr)
{
	_signal.Set(e_ele_selfAddress,addr);
}
PString Sig::BridgeReady::GetSelfAddress() const
{
	PString addr;
	_signal.Get(e_ele_selfAddress,addr);
	return addr;
}
/////////////
Sig::Release::Release(UMPSignal& sig)
: Wrap(sig)
{
}

E_ResultReason Sig::Release::GetResult() const
{
	DWORD result = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, result);
	return (E_ResultReason) result;
}

void Sig::Release::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator, (DWORD) result);
}
/////

Sig::Bridge::Bridge(UMPSignal& sig)
: Wrap(sig)
{
}

PString Sig::Bridge::GetListener() const
{
	PString l;
	_signal.Get(e_ele_listener, l);
	return l;
}

void Sig::Bridge::SetListener(const PString& l)
{
	_signal.Set(e_ele_listener, l);
}

PString Sig::Bridge::GetPeerListener() const
{
	PString l;
	_signal.Get(e_ele_peerListener, l);
	return l;
}

void Sig::Bridge::SetPeerListener(const PString& l)
{
	_signal.Set(e_ele_peerListener, l);
}

PBYTEArray Sig::Bridge::GetGUID() const
{
	PBYTEArray guid;
	_signal.Get(e_ele_guid, guid);
	return guid;
}
void Sig::Bridge::SetGUID(const PBYTEArray& guid)
{
	_signal.Set(e_ele_guid, guid);
}
PBYTEArray Sig::Bridge::GetKey() const
{
	PBYTEArray key;
	_signal.Get(e_ele_key, key);
	return key;
}

void Sig::Bridge::SetKey(const PBYTEArray& key)
{
	_signal.Set(e_ele_key, key);
}

///////
Sig::CallSignal::CallSignal(UMPSignal& sig)
: Wrap(sig)
{
}

PBOOL Sig::CallSignal::GetCapabilities(ChannelCapabilityArray & caps) const
{
	PString str;
	if(!_signal.Get(e_ele_capabilities, str))
		return FALSE;
    
	caps.clear();
	PStringArray strs = str.Tokenise(";",FALSE);
    
	for (PINDEX i = 0; i < strs.GetSize(); i++) {
		caps.push_back((E_ChannelCapability)strs[i].AsUnsigned(16));
	}
	return TRUE;
}

void Sig::CallSignal::SetCapabilities(const ChannelCapabilityArray& caps)
{
	PString str;
	for (unsigned i = 0; i < caps.size(); i++) {
		if (!str.IsEmpty())
			str += ";";
		str += PString(PString::Unsigned, (long) caps[i], 16);
	}
    
	_signal.Set(e_ele_capabilities, str);
}

DWORD Sig::CallSignal::GetVersion() const
{
	DWORD version = 0;
	_signal.Get(e_ele_version, version);
	return version;
}
void Sig::CallSignal::SetVersion(DWORD version)
{
	_signal.Set(e_ele_version, version);
}

E_PhoneType Sig::CallSignal::GetPhoneType() const
{
	DWORD type = 0;
	_signal.Get(e_ele_type, type);
	return (E_PhoneType) type;
}
void Sig::CallSignal::SetPhoneType(E_PhoneType type)
{
	_signal.Set(e_ele_type, type);
}

PBOOL Sig::CallSignal::GetAcceptInbandDTMF() const
{
	return _signal.Exist(e_ele_acceptInbandDTMF);
}



void Sig::CallSignal::SetAcceptInbandDTMF(PBOOL b)
{
	if (b)
		_signal.Set(e_ele_acceptInbandDTMF, "");
	else
		_signal.Remove(e_ele_acceptInbandDTMF);
}


PBOOL Sig::CallSignal::IsURTPViaTCP() const
{
	return _signal.Exist(e_ele_urtpViaTCP);
}

void Sig::CallSignal::SetURTPViaTCP(PBOOL b)
{
	if(b)
		_signal.Set(e_ele_urtpViaTCP,"");
	else
		_signal.Remove(e_ele_urtpViaTCP);
}

PBOOL Sig::CallSignal::IsSupportRAC() const
{
	return _signal.Exist(e_ele_supportRAC);
}

void Sig::CallSignal::SetSupportRAC(PBOOL b)
{
	if(b)
		_signal.Set(e_ele_supportRAC,"");
	else
		_signal.Remove(e_ele_supportRAC);
}


PBOOL Sig::CallSignal::GetProxyTo(UMPSignal & proxyTo) const
{
	return _signal.Get(e_ele_proxyTo,proxyTo);
}

void Sig::CallSignal::SetProxyTo(const UMPSignal & proxyTo)
{
	_signal.Set(e_ele_proxyTo,proxyTo);
}



////////////////
Sig::OpenChannel::OpenChannel(UMPSignal& sig)
: Wrap(sig)
{
}

char Sig::OpenChannel::GetNumber() const
{
	char chNumber = -1;
	_signal.Get(e_ele_identifier, chNumber);
	return chNumber;
}

void Sig::OpenChannel::SetNumber(char chNumber)
{
	_signal.Set(e_ele_identifier, chNumber);
}

E_ChannelCapability Sig::OpenChannel::GetCapability() const
{
	DWORD cap = e_chc_null;
	_signal.Get(e_ele_type, cap);
	return (E_ChannelCapability) cap;
}

void Sig::OpenChannel::SetCapability(E_ChannelCapability cap)
{
	_signal.Set(e_ele_type, (DWORD) cap);
}

////////////
Sig::CloseChannel::CloseChannel(UMPSignal& sig)
: Wrap(sig)
{
}

char Sig::CloseChannel::GetNumber() const
{
	char chNumber = -1;
	_signal.Get(e_ele_identifier, chNumber);
	return chNumber;
}

void Sig::CloseChannel::SetNumber(char chNumber)
{
	_signal.Set(e_ele_identifier, chNumber);
}

E_ResultReason Sig::CloseChannel::GetResult() const
{
	DWORD result = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, result);
	return (E_ResultReason) result;
}

void Sig::CloseChannel::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator, (DWORD) result);
}

void Sig::CloseChannel::SetDirection(E_ChannelDirection dir)
{
	_signal.Set(e_ele_direction, (DWORD) dir);
}

E_ChannelDirection Sig::CloseChannel::GetDirection() const
{
	DWORD dir = e_cd_transmit;
	_signal.Get(e_ele_direction, dir);
	return (E_ChannelDirection) dir;
}

///////////
Sig::URTPTransport::URTPTransport(UMPSignal& sig)
: Wrap(sig)
{
}

PString Sig::URTPTransport::GetWanAddress() const
{
	PString addr;
	_signal.Get(e_ele_wanAddress, addr);
	return addr;
}

void Sig::URTPTransport::SetWanAddress(const PString& addr)
{
	_signal.Set(e_ele_wanAddress, addr);
}

PString Sig::URTPTransport::GetLanAddress() const
{
	PString addr;
	_signal.Get(e_ele_lanAddress, addr);
	return addr;
}

void Sig::URTPTransport::SetLanAddress(const PString & addr)
{
	_signal.Set(e_ele_lanAddress, addr);
}
////////////

Sig::URTPReport::URTPReport(UMPSignal& sig)
: Wrap(sig)
{
}

char Sig::URTPReport::GetChannelNumber() const
{
	char number = -1;
	_signal.Get(e_ele_identifier, number);
	return number;
}

void Sig::URTPReport::SetChannelNumber(char chNumber)
{
	_signal.Set(e_ele_identifier, chNumber);
}

DWORD Sig::URTPReport::GetFrameRecvd() const
{
	DWORD recvd = 0;
	_signal.Get(e_ele_frameRecvd, recvd);
	return recvd;
}

void Sig::URTPReport::SetFrameRecvd(DWORD recvd)
{
	_signal.Set(e_ele_frameRecvd, recvd);
}

DWORD Sig::URTPReport::GetFrameLost() const
{
	DWORD lost = 0;
	_signal.Get(e_ele_frameLost, lost);
	return lost;
}

void Sig::URTPReport::SetFrameLost(DWORD lost)
{
	_signal.Set(e_ele_frameLost, lost);
}

DWORD Sig::URTPReport::GetLostFraction() const
{
	DWORD fraction = 0;
	_signal.Get(e_ele_frameLostFraction, fraction);
	return fraction;
}

void Sig::URTPReport::SetLostFraction(DWORD fraction)
{
	_signal.Set(e_ele_frameLostFraction, fraction);
}

///////////////
Sig::DurationLimit::DurationLimit(UMPSignal& sig)
: Wrap(sig)
{
}

DWORD Sig::DurationLimit::GetLimit() const
{
	DWORD second = 0;
	_signal.Get(e_ele_time, second);
	return second;
}

void Sig::DurationLimit::SetLimit(DWORD second)
{
	_signal.Set(e_ele_time, second);
}

///////////
Sig::RegisterService::RegisterService(UMPSignal& sig)
: Wrap(sig)
{
}

E_InteractType Sig::RegisterService::GetType() const
{
	DWORD type = 0;
	_signal.Get(e_ele_type, type);
	return (E_InteractType) type;
}
void Sig::RegisterService::SetType(E_InteractType type)
{
	_signal.Set(e_ele_type, (DWORD) type);
}


PString Sig::RegisterService::GetKey() const
{
	PString key;
	_signal.Get(e_ele_key, key);
	return key;
}

void Sig::RegisterService::SetKey(const PString& key)
{
	_signal.Set(e_ele_key, key);
}


PUInt64 Sig::RegisterService::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}

void Sig::RegisterService::SetUserID(const PUInt64 &userID)
{
	_signal.Set(e_ele_userID, userID);
}

PString Sig::RegisterService::GetIP() const
{
	PString ip;
	_signal.Get(e_ele_ip, ip);
	return ip;
}

void Sig::RegisterService::SetIP(const PString& ip)
{
	_signal.Set(e_ele_ip, ip);
}
/////////
Sig::RegisterServiceAck::RegisterServiceAck(UMPSignal& sig)
: Wrap(sig)
{
}

E_InteractType Sig::RegisterServiceAck::GetType() const
{
	DWORD type = 0;
	_signal.Get(e_ele_type, type);
	return (E_InteractType) type;
}
void Sig::RegisterServiceAck::SetType(E_InteractType type)
{
	_signal.Set(e_ele_type, (DWORD) type);
}

E_ResultReason Sig::RegisterServiceAck::GetResult() const
{
	DWORD r = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, r);
	return (E_ResultReason) r;
}

void Sig::RegisterServiceAck::SetResult(E_ResultReason r)
{
	_signal.Set(e_ele_resultIndicator, r);
}
////////////////
Sig::UnregisterService::UnregisterService(UMPSignal& sig)
: Wrap(sig)
{
}

E_InteractType Sig::UnregisterService::GetType() const
{
	DWORD type = 0;
	_signal.Get(e_ele_type, type);
	return (E_InteractType) type;
}
void Sig::UnregisterService::SetType(E_InteractType type)
{
	_signal.Set(e_ele_type, (DWORD) type);
}

PUInt64 Sig::UnregisterService::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}

void Sig::UnregisterService::SetUserID(const PUInt64 &userID)
{
	_signal.Set(e_ele_userID, userID);
}

///////////
Sig::UpdateServiceProvider::UpdateServiceProvider(UMPSignal& sig)
: Wrap(sig)
{
}

PString Sig::UpdateServiceProvider::GetProviders() const
{
	PString p;
	_signal.Get(e_ele_dataBlock, p);
	return p;
}

void Sig::UpdateServiceProvider::SetProviders(const PString& p)
{
	_signal.Set(e_ele_dataBlock, p);
}

//////////////////////////////
Sig::UpdateRouteTable::UpdateRouteTable(UMPSignal& sig)
: Wrap(sig)
{
}

PString Sig::UpdateRouteTable::GetRouteTable() const
{
	PString rt;
	_signal.Get(e_ele_dataBlock, rt);
	return rt;
}

void Sig::UpdateRouteTable::SetRouteTable(const PString& rt)
{
	_signal.Set(e_ele_dataBlock, rt);
}
//////////////
Sig::UserInfo::UserInfo(UMPSignal& sig)
: Wrap(sig)
{
}
PUInt64 Sig::UserInfo::GetUserID() const
{
	PUInt64 uid = 0;
	_signal.Get(e_ele_userID, uid);
	return uid;
}

void Sig::UserInfo::SetUserID(const PUInt64 &userID)
{
	_signal.Set(e_ele_userID, userID);
}

PBOOL Sig::UserInfo::GetBaseUserInfo(UMPSignal& bui) const
{
	return GetSubSignal(e_sig_baseUserInfo, bui);
}

void Sig::UserInfo::SetBaseUserInfo(const UMPSignal& bui)
{
	SetSubSignal(e_sig_baseUserInfo, bui);
}

PBOOL Sig::UserInfo::GetBalance(double& balance) const
{
	return _signal.Get(e_ele_userBalance, balance);
}

void Sig::UserInfo::SetBalance(double balance)
{
	_signal.Set(e_ele_userBalance, balance);
}

PBOOL Sig::UserInfo::GetBalanceExpire(time_t & t) const
{
	return _signal.Get(e_ele_expireTime,(DWORD&)t);
}

void Sig::UserInfo::SetBalanceExpire(time_t t)
{
	_signal.Set(e_ele_expireTime,(DWORD)t);
}

PBOOL Sig::UserInfo::GetPoint(PInt64 & point) const
{
	return _signal.Get(e_ele_point,point);
}

void Sig::UserInfo::SetPoint(const PInt64 & point)
{
	_signal.Set(e_ele_point,point);
}

PBOOL Sig::UserInfo::GetLastLoginTime(time_t& t) const
{
	return _signal.Get(e_ele_lastLoginTime, (DWORD &) t);
}

void Sig::UserInfo::SetLastLoginTime(time_t t)
{
	_signal.Set(e_ele_lastLoginTime, (DWORD) t);
}

PBOOL Sig::UserInfo::GetCurrentLoginTime(time_t& t) const
{
	return _signal.Get(e_ele_currentLoginTime, (DWORD &) t);
}

void Sig::UserInfo::SetCurrentLoginTime(time_t t)
{
	_signal.Set(e_ele_currentLoginTime, (DWORD) t);
}

PBOOL Sig::UserInfo::GetLastLoginIP(PString& ip) const
{
	return _signal.Get(e_ele_lastLoginIP, ip);
}

void Sig::UserInfo::SetLastLoginIP(const PString& ip)
{
	_signal.Set(e_ele_lastLoginIP, ip);
}

PBOOL Sig::UserInfo::GetCurrentLoginIP(PString& ip) const
{
	return _signal.Get(e_ele_currentLoginIP, ip);
}

void Sig::UserInfo::SetCurrentLoginIP(const PString& ip)
{
	_signal.Set(e_ele_currentLoginIP, ip);
}


PBOOL Sig::UserInfo::GetLoginCount(DWORD& count) const
{
	return _signal.Get(e_ele_loginCount, count);
}
void Sig::UserInfo::SetLoginCount(DWORD count)
{
	_signal.Set(e_ele_loginCount, count);
}


PBOOL Sig::UserInfo::GetOnlineTime(DWORD& t) const
{
	return _signal.Get(e_ele_onlineTime, t);
}

void Sig::UserInfo::SetOnlineTime(DWORD t)
{
	_signal.Set(e_ele_onlineTime, t);
}

/////////////////////////
Sig::SetUserData::SetUserData(UMPSignal& sig)
: Wrap(sig)
{
}

PString Sig::SetUserData::GetDataBlock() const
{
	PString block;
	_signal.Get(e_ele_dataBlock, block);
	return block;
}

void Sig::SetUserData::SetDataBlock(const PString& dataBlock)
{
	_signal.Set(e_ele_dataBlock, dataBlock);
}

DWORD Sig::SetUserData::GetType() const
{
	DWORD type = 0;
	_signal.Get(e_ele_type, type);
	return type;
}
void Sig::SetUserData::SetType(DWORD type)
{
	_signal.Set(e_ele_type, type);
}

PUInt64 Sig::SetUserData::GetUserID() const
{
	PUInt64 userID = 0;
	_signal.Get(e_ele_userID, userID);
	return userID;
}
void Sig::SetUserData::SetUserID(const PUInt64 &userID)
{
	_signal.Set(e_ele_userID, userID);
}


PString Sig::SetUserData::GetKey() const
{
	PString key;
	_signal.Get(e_ele_key, key);
	return key;
}


void Sig::SetUserData::SetKey(const PString & key)
{
	_signal.Set(e_ele_key,key);
}

PBOOL Sig::SetUserData::HasShareFlag() const
{
	return _signal.Exist(e_ele_shareFlag);
}
void Sig::SetUserData::SetShareFlag(PBOOL share)
{
	if (share)
		_signal.Set(e_ele_shareFlag, "");
	else
		_signal.Remove(e_ele_shareFlag);
}


DWORD Sig::SetUserData::GetTimestamp() const
{
	DWORD ts=0;
	_signal.Get(e_ele_timestamp, ts);
	return ts;
}

void Sig::SetUserData::SetTimestamp(DWORD ts)
{
	_signal.Set(e_ele_timestamp,ts);
	
}
////////////////////
Sig::DTMF::DTMF(UMPSignal& sig)
: Wrap(sig)
{
}

PString Sig::DTMF::GetDTMF() const
{
	PString str;
	_signal.Get(e_ele_dataBlock, str);
	return str;
}

void Sig::DTMF::SetDTMF(const PString& dtmf)
{
	_signal.Set(e_ele_dataBlock, dtmf);
}
////////////////////////////
Sig::Forward::Forward(UMPSignal& sig)
: Wrap(sig)
{
}

PBOOL Sig::Forward::GetForwardTo(UMPSignal& to) const
{
	return GetSubSignal(e_ele_forwardTo, to);
}

void Sig::Forward::SetForwardTo(const UMPSignal& to)
{
	SetSubSignal(e_ele_forwardTo, to);
}
////////////////////////////
Sig::Notify::Notify(UMPSignal& sig)
: Wrap(sig)
{
}

PUInt64 Sig::Notify::GetTo() const
{
	PUInt64 to = 0;
	_signal.Get(e_ele_to, to);
	return to;
}
void Sig::Notify::SetTo(const PUInt64 &to)
{
	_signal.Set(e_ele_to, to);
}


E_NotifyType Sig::Notify::GetType() const
{
	DWORD type = 0;
	_signal.Get(e_ele_type, type);
	return (E_NotifyType) type;
}

void Sig::Notify::SetType(E_NotifyType type)
{
	_signal.Set(e_ele_type, (DWORD) type);
}

time_t Sig::Notify::GetTime() const
{
	DWORD t = 0;
	_signal.Get(e_ele_time, t);
	return (time_t) t;
}
void Sig::Notify::SetTime(time_t t)
{
	_signal.Set(e_ele_time, (DWORD) t);
}

PBOOL Sig::Notify::GetBody(UMPSignal& body) const
{
	return  GetSubSignal(e_ele_body, body);
}

void Sig::Notify::SetBody(const UMPSignal& body)
{
	SetSubSignal(e_ele_body, body);
}

E_Priority Sig::Notify::GetPriority() const
{
	DWORD prio = e_prio_normal;
	_signal.Get(e_ele_priority, prio);
	return (E_Priority) prio;
}

void Sig::Notify::SetPriority(E_Priority prio)
{
	_signal.Set(e_ele_priority, (DWORD) prio);
}


void Sig::Notify::SetTemporaryFlag(PBOOL temp)
{
	if (temp)
		_signal.Set(e_ele_temporaryFlag, "");
	else
		_signal.Remove(e_ele_temporaryFlag);
}

PBOOL Sig::Notify::HasTemporaryFlag() const
{
	return _signal.Exist(e_ele_temporaryFlag);
}
///////////////////////////

Sig::NotifyBody::NotifyBody(UMPSignal& sig)
: Wrap(sig)
{
}

PString Sig::NotifyBody::GetTitle() const
{
	PString title;
	_signal.Get(e_ele_title, title);
	return title;
}

void Sig::NotifyBody::SetTitle(const PString& title)
{
	_signal.Set(e_ele_title, title);
}

PString Sig::NotifyBody::GetContent() const
{
	PString content;
	_signal.Get(e_ele_content, content);
	return content;
}

void Sig::NotifyBody::SetContent(const PString& content)
{
	_signal.Set(e_ele_content, content);
}

PString Sig::NotifyBody::GetWebContent() const
{
	PString content;
	_signal.Get(e_ele_url, content);
	return content;
}

void Sig::NotifyBody::SetWebContent(const PString& content)
{
	_signal.Set(e_ele_url, content);
}

PString Sig::NotifyBody::GetHyperLink() const
{
	PString hlink;
	_signal.Get(e_ele_hyperLink, hlink);
	return hlink;
}
void Sig::NotifyBody::SetHyperLink(const PString& hlink)
{
	_signal.Set(e_ele_hyperLink, hlink);
}

PString Sig::NotifyBody::GetVar() const
{
	PString var;
	_signal.Get(e_ele_var, var);
	return var;
}

void Sig::NotifyBody::SetVar(const PString& var)
{
	_signal.Set(e_ele_var, var);
}
//////////////
Sig::NotifyBodyAddedAsRUser::NotifyBodyAddedAsRUser(UMPSignal& sig)
: NotifyBody(sig)
{
}


PBOOL Sig::NotifyBodyAddedAsRUser::GetBaseUserInfo(UMPSignal& bui) const
{
	return GetSubSignal(e_sig_baseUserInfo, bui);
}

void Sig::NotifyBodyAddedAsRUser::SetBaseUserInfo(const UMPSignal& bui)
{
	SetSubSignal(e_sig_baseUserInfo, bui);
}

///////////////////
Sig::NotifyBodyRUserSubState::NotifyBodyRUserSubState(UMPSignal& sig)
: NotifyBody(sig)
{
}

PBOOL Sig::NotifyBodyRUserSubState::GetRUserSubState(UMPSignal& uss) const
{
	return GetSubSignal(e_sig_userSubState, uss);
}

void Sig::NotifyBodyRUserSubState::SetRUserSubState(const UMPSignal& uss)
{
	SetSubSignal(e_sig_userSubState, uss);
}

////////////////////
Sig::NotifyBodyAcctInfo::NotifyBodyAcctInfo(UMPSignal& sig)
: NotifyBody(sig)
{
}

double Sig::NotifyBodyAcctInfo::GetAmount() const
{
	double amount = 0;
	_signal.Get(e_ele_amount, amount);
	return amount;
}

void Sig::NotifyBodyAcctInfo::SetAmount(double amount)
{
	_signal.Set(e_ele_amount, amount);
}

double Sig::NotifyBodyAcctInfo::GetBalance() const
{
	double bal = 0;
	_signal.Get(e_ele_userBalance, bal);
	return bal;
}

void Sig::NotifyBodyAcctInfo::SetBalance(double balance)
{
	_signal.Set(e_ele_userBalance, balance);
}

time_t Sig::NotifyBodyAcctInfo::GetExpireTime() const
{
	DWORD t = 0;
	_signal.Get(e_ele_expireTime, t);
	return (time_t) t;
}

void Sig::NotifyBodyAcctInfo::SetExpireTime(time_t t)
{
	_signal.Set(e_ele_expireTime, (DWORD) t);
    
}

time_t Sig::NotifyBodyAcctInfo::GetAcctTime() const
{
	DWORD t = 0;
	_signal.Get(e_ele_time, t);
	return (time_t) t;
}

void Sig::NotifyBodyAcctInfo::SetAcctTime(time_t t)
{
	_signal.Set(e_ele_time, (DWORD) t);
}
///////////////////
Sig::NotifyBodySys::NotifyBodySys(UMPSignal& sig)
: NotifyBody(sig)
{
}

DWORD Sig::NotifyBodySys::GetType() const
{
	DWORD type = 0;
	_signal.Get(e_ele_type, type);
	return type;
}

void Sig::NotifyBodySys::SetType(DWORD type)
{
	_signal.Set(e_ele_type, type);
}

////////////
Sig::GetTempNotify::GetTempNotify(UMPSignal& sig)
: Wrap(sig)
{
}

PUInt64 Sig::GetTempNotify::GetUserID() const
{
	PUInt64 userID = 0;
	_signal.Get(e_ele_userID, userID);
	return userID;
}

void Sig::GetTempNotify::SetUserID(const PUInt64 &userID)
{
	_signal.Set(e_ele_userID, userID);
}
/////////////
Sig::StoreNotify::StoreNotify(UMPSignal& sig)
: Wrap(sig)
{
}

PBOOL Sig::StoreNotify::GetNotify(UMPSignal& notify)
{
	return GetSubSignal(e_sig_notify, notify);
}

void Sig::StoreNotify::SetNotify(const UMPSignal& notify)
{
	SetSubSignal(e_sig_notify, notify);
}

//////////////
Sig::SetNotify::SetNotify(UMPSignal& sig)
: Wrap(sig)
{
}

PBOOL Sig::SetNotify::Get(UMPSignal& notify)
{
	return GetSubSignal(e_sig_notify, notify);
}

void Sig::SetNotify::Set(const UMPSignal& notify)
{
	SetSubSignal(e_sig_notify, notify);
}

////////////////////////
Sig::StatusReport::StatusReport(UMPSignal& sig)
:Wrap(sig)
{
}

PString Sig::StatusReport::GetDataBlock() const
{
	PString data;
	_signal.Get(e_ele_dataBlock,data);
	return data;
}

void Sig::StatusReport::SetDataBlock(const PString & data)
{
	_signal.Set(e_ele_dataBlock,data);
}
///////////////////////
Sig::FX::FX(UMPSignal& sig)
:Wrap(sig)
{
}

void Sig::FX::SetHash(const PString & hash)
{
	_signal.Set(e_ele_hash,hash);
}

PString Sig::FX::GetHash() const
{
	PString hash;
	_signal.Get(e_ele_hash,hash);
	return hash;
}

void Sig::FX::SetId(DWORD id)
{
	_signal.Set(e_ele_identifier,id);
}

DWORD Sig::FX::GetId() const
{
	DWORD id = 0;
	_signal.Get(e_ele_identifier,id);
	return id;
}

void Sig::FX::SetDirection(E_ChannelDirection dir)
{
	_signal.Set(e_ele_direction,(DWORD)dir);
}

E_ChannelDirection Sig::FX::GetDirection() const
{
	DWORD dir = 0;
	_signal.Get(e_ele_direction,dir);
	return (E_ChannelDirection)dir;
}
/////////////
Sig::FileGet::FileGet(UMPSignal& sig)
:FX(sig)
{
	
}

void Sig::FileGet::SetStore(E_Store store)
{
	_signal.Set(e_ele_store,(DWORD)store);
}

E_Store Sig::FileGet::GetStore() const
{
	DWORD store = 0;
	_signal.Get(e_ele_store,store);
	return (E_Store)store;
}
////////////////////////////
Sig::FileAck::FileAck(UMPSignal & sig)
:FX(sig)
{
	
}

E_ResultReason Sig::FileAck::GetResult() const
{
	DWORD r = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator,r);
	return (E_ResultReason)r;
}

void Sig::FileAck::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator,(DWORD)result);
}

//////////////////////////
Sig::MonitorSubState::MonitorSubState(UMPSignal& sig)
:Wrap(sig)
{
    
}

void Sig::MonitorSubState::SetUserID(const PUInt64 & uid)
{
	_signal.Set(e_ele_userID, uid);
}


PUInt64 Sig::MonitorSubState::GetUserID() const
{
	PUInt64 ret = 0;
	_signal.Get(e_ele_userID, ret);
	return ret;
}

void Sig::MonitorSubState::SetUsers(const PStringArray & users)
{
	PString str;
	for(int i = 0;i<users.GetSize();i++)
		str += (users[i] + "|");
	_signal.Set(e_ele_dataBlock, str);
}

PStringArray Sig::MonitorSubState::GetUsers() const
{
	PString str;
	_signal.Get(e_ele_dataBlock, str);
	
	return str.Tokenise("|", FALSE);
}


//////////////////////
Sig::CallExtraInfo::CallExtraInfo(UMPSignal & signal)
:Wrap(signal)
{
	
}

PString Sig::CallExtraInfo::GetCalledNumber() const
{
	PString v;
	_signal.Get(e_ele_calledNumber, v);
	return v;
}

void Sig::CallExtraInfo::SetCalledNumber(const PString & number)
{
	_signal.Set(e_ele_calledNumber, number);
}

PString Sig::CallExtraInfo::GetCalledName() const
{
	PString v;
	_signal.Get(e_ele_calledName, v);
	return v;
	
}

void Sig::CallExtraInfo::SetCalledName(const PString & name)
{
	_signal.Set(e_ele_calledName, name);
}

PString Sig::CallExtraInfo::GetCallerNumber() const
{
	PString v;
	_signal.Get(e_ele_callerNumber, v);
	return v;
}

void Sig::CallExtraInfo::SetCallerNumber(const PString & number)
{
	_signal.Set(e_ele_callerNumber, number);
}

PString Sig::CallExtraInfo::GetCallerName() const
{
	PString v;
	_signal.Get(e_ele_callerName, v);
	return v;
}
void Sig::CallExtraInfo::SetCallerName(const PString & name)
{
	_signal.Set(e_ele_callerName, name);
}

PString Sig::CallExtraInfo::GetCalledAddress() const
{
	PString v;
	_signal.Get(e_ele_calledAddress, v);
	return v;
}

void Sig::CallExtraInfo::SetCalledAddress(const PString & addr)
{
	_signal.Set(e_ele_calledAddress, addr)	;
}

PString Sig::CallExtraInfo::GetCallerAddress() const
{
	PString v;
	_signal.Get(e_ele_callerAddress, v);
	return v;
}
void Sig::CallExtraInfo::SetCallerAddress(const PString & addr)
{
	_signal.Set(e_ele_callerAddress, addr);
}

PString Sig::CallExtraInfo::GetCallIdentifier() const
{
	PString v;
	_signal.Get(e_ele_identifier, v);
	return v;
}
void Sig::CallExtraInfo::SetCallIdentifier(const PString & id)
{
	_signal.Set(e_ele_identifier, id);
}


void Sig::CallExtraInfo::SetRTPAddress(const PString & addr)
{
	_signal.Set(e_ele_rtpAddress, addr);
}

PString Sig::CallExtraInfo::GetRTPAddress() const
{
	PString addr;
	_signal.Get(e_ele_rtpAddress,addr);
	return addr;
}

void Sig::CallExtraInfo::SetRTCPAddress(const PString & addr)
{
	_signal.Set(e_ele_rtcpAddress, addr);
}

PString Sig::CallExtraInfo::GetRTCPAddress() const
{
	PString addr;
	_signal.Get(e_ele_rtcpAddress, addr);
	return addr;
}

PString Sig::CallExtraInfo::GetRTPType() const
{
	PString type;
	_signal.Get(e_ele_rtpType, type);
	return type;
    
}

void Sig::CallExtraInfo::SetRTPType(const PString & type)
{
	_signal.Set(e_ele_rtpType, type);
}


PBYTEArray Sig::CallExtraInfo::GetKey() const
{
	PBYTEArray key;
	_signal.Get(e_ele_key, key);
	return key;
}

void Sig::CallExtraInfo::SetKey(const PBYTEArray & key)
{
	_signal.Set(e_ele_key, key);
}

PString Sig::CallExtraInfo::GetProtocolSpecifiedReason() const
{
	PString v;
	_signal.Get(e_ele_resultIndicator, v);
	return v;
}


void Sig::CallExtraInfo::SetProtocolSpecifiedReason(const PString & reason)
{
	_signal.Set(e_ele_resultIndicator, reason);
}

PString Sig::CallExtraInfo::GetVendor() const
{
	PString v;
	_signal.Get(e_ele_vendor, v);
	return v;
}

void Sig::CallExtraInfo::SetVendor(const PString & vendor)
{
	_signal.Set(e_ele_vendor, vendor);
}

/*
 PString Sig::CallExtraInfo::GetCandidateRtpIps() const
 {
 PString v;
 _signal.Get(e_ele_candidate_rtp_ips, v);
 return v;
 }
 
 void Sig::CallExtraInfo::SetCandidateRtpIps(const PString & rtp_ips)
 {
 _signal.Set(e_ele_candidate_rtp_ips, rtp_ips);
 }
 
 PString Sig::CallExtraInfo::GetSelectedRtpIp() const
 {
 PString v;
 _signal.Get(e_ele_selected_rtp_ip, v);
 return v;
 }
 
 void Sig::CallExtraInfo::SetSelectedRtpIp(const PString & rtp_ip)
 {
 _signal.Set(e_ele_selected_rtp_ip, rtp_ip);
 }
 */
//////////////////////////////////////////////////////////////////////////

Sig::MessagePush::MessagePush(UMPSignal& sig)
:Wrap(sig)
{
    
}

PString Sig::MessagePush::GetMsgId() const
{
	PString msgId;
	_signal.Get(e_ele_mp_msg_id, msgId);
	return msgId;
}

void Sig::MessagePush::SetMsgId(const PString& msgId)
{
	_signal.Set(e_ele_mp_msg_id, msgId);
}

PUInt64 Sig::MessagePush::GetWindowType() const
{
	PUInt64 windowType;
	_signal.Get(e_ele_mp_window_type, windowType);
	return windowType;
}

void Sig::MessagePush::SetWindowType(PUInt64 windowType)
{
	_signal.Set(e_ele_mp_window_type, windowType);
}

PString Sig::MessagePush::GetWindowSize() const
{
	PString size;
	_signal.Get(e_ele_mp_window_size, size);
	return size;
}

void Sig::MessagePush::SetWindowSize(const PString& windowSize)
{
	_signal.Set(e_ele_mp_window_size, windowSize);
}

PUInt64 Sig::MessagePush::GetKeepTime() const
{
	PUInt64 keepTime;
	_signal.Get(e_ele_mp_window_keep, keepTime);
	return keepTime;
}

void Sig::MessagePush::SetKeepTime(PUInt64 keepTime)
{
	_signal.Set(e_ele_mp_window_keep, keepTime);
}

PString Sig::MessagePush::GetPageUrl() const
{
	PString url;
	_signal.Get(e_ele_mp_page_url, url);
	return url;
}

void Sig::MessagePush::SetPageUrl(const PString& url)
{
	_signal.Set(e_ele_mp_page_url, url);
}

Sig::UserLevel::UserLevel(UMPSignal& sig)
:Wrap(sig)
{
    
}

PInt64 Sig::UserLevel::GetLevel()const
{
	PInt64 level=1;
	_signal.Get(e_ele_level,level);
	return level;
}
void Sig::UserLevel::SetLevel(const PInt64 level)
{
	_signal.Set(e_ele_level,level);
}


void Sig::UserLevel::SetExperience(const PInt64 values)
{
	_signal.Set(e_ele_experience,values);
}

PInt64 Sig::UserLevel::GetExperience() const
{
	PInt64 values=1;
	_signal.Get(e_ele_experience,values);
	return values;
}

void Sig::UserLevel::SetExperienceCapability(const PInt64 values)
{
	_signal.Set(e_ele_experienceCapability,values);
}

PInt64 Sig::UserLevel::GetExperienceCapability() const
{
	PInt64 values=10;
	_signal.Get(e_ele_experienceCapability,values);
	return values;
}

void Sig::UserLevel::SetInteractTypeExtend(const PUInt64 values)
{
	_signal.Set(e_ele_interactTypeExtend,values);
}

PUInt64 Sig::UserLevel::GetInteractTypeExtend() const
{
	PUInt64 values=0;
	_signal.Get(e_ele_interactTypeExtend,values);
	return values;
}

//////////////////////////////////////////////////////////////////////////

Sig::CBSRequest::CBSRequest(UMPSignal& sig)
:Wrap(sig)
{
    
}

PString Sig::CBSRequest::GetCommand() const
{
	PString cmd;
	_signal.Get(e_ele_command, cmd);
	return cmd;
    
}

void Sig::CBSRequest::SetCommand(const PString& cmd)
{
	_signal.Set(e_ele_command, cmd);
}

PString Sig::CBSRequest::GetSessionId() const
{
	PString guid;
	_signal.Get(e_ele_guid, guid);
	return guid;
}

void Sig::CBSRequest::SetSessionId(const PString& guid)
{
	_signal.Set(e_ele_guid, guid);
}



PBOOL Sig::CBSRequest::GetSub(UMPSignal & sub) const
{
	return GetSubSignal(e_sig_cbsSub, sub);
}

void Sig::CBSRequest::SetSub(const UMPSignal & sub)
{
	SetSubSignal(e_sig_cbsSub, sub);
}

///////////////////////
Sig::CBSResponse::CBSResponse(UMPSignal & sig)
:CBSRequest(sig)
{
    
}

E_ResultReason Sig::CBSResponse::GetResult() const
{
	DWORD r = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, r);
	return (E_ResultReason)r;
}

void Sig::CBSResponse::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator, result);
}

PString Sig::CBSResponse::GetDescription() const
{
	PString desc;
	_signal.Get(e_ele_description, desc);
	return desc;
}

void Sig::CBSResponse::SetDescription(const PString & desc)
{
	_signal.Set(e_ele_description, desc);
}



Sig::FetchUserEInfo::FetchUserEInfo(UMPSignal& sig)
:Wrap(sig)
{
}
void Sig::FetchUserEInfo::SetUserNumber(const PString& userNumber)
{
	_signal.Set(e_ele_userNumber, userNumber);
}

void Sig::FetchUserEInfo::SetCalleeNumber(const PString& calleeNumber)
{
	_signal.Set(e_ele_calledNumber, calleeNumber);
}

void Sig::FetchUserEInfo::SetCallSessionId(const PString& callSesssionId)
{
	_signal.Set(e_ele_guid, callSesssionId);
}

Sig::UserEInfo::UserEInfo(UMPSignal& sig)
:Wrap(sig)
{
}

PBOOL Sig::UserEInfo::GetBaseUserInfo(UMPSignal& bui) const
{
	return GetSubSignal(e_sig_baseUserInfo, bui);
}
PString Sig::UserEInfo::GetUserPasswd() const
{
	PString ret;
	_signal.Get(e_ele_userPasswd, ret);
	return ret;
}

PString Sig::UserEInfo::GetCalledNumber() const
{
	PString ret;
	_signal.Get(e_ele_calledNumber, ret);
	return ret;
}

PString Sig::UserEInfo::GetCallSessionId() const
{
	PString ret;
	_signal.Get(e_ele_guid, ret);
	return ret;
}

Sig::CBSConnInfo::CBSConnInfo(UMPSignal& sig)
:Wrap(sig)
{
    
}

PString Sig::CBSConnInfo::GetOperator() const
{
	PString op;
	_signal.Get(e_ele_operator, op);
	return op;
    
}

void Sig::CBSConnInfo::SetOperator(const PString& op)
{
	_signal.Set(e_ele_operator, op);
}


Sig::CBSConnInfoAck::CBSConnInfoAck(UMPSignal& sig)
:Wrap(sig)
{
    
}

E_ResultReason Sig::CBSConnInfoAck::GetResult() const
{
	DWORD r = e_r_unknownError;
	_signal.Get(e_ele_resultIndicator, r);
	return (E_ResultReason) r;
    
}

void Sig::CBSConnInfoAck::SetResult(E_ResultReason result)
{
	_signal.Set(e_ele_resultIndicator, (DWORD) result);
}
