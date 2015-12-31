//
//  ump_session.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "ump_session.h"

#include "../Common/pprocess.h"
#include "../Common/purl.h"
#include "../Common/ulog.h"
//////////////////////////////////
UMPSession::UCSStateMonitor::UCSStateMonitor() :
		UMPHandlerBase::StateMonitor<E_ClientState>(e_offline) {
	_gotFirstSignal = FALSE;
	_loginTimeout.SetTimeout(50 * 1000);
}

PBOOL UMPSession::UCSStateMonitor::Filter(UMPHandlerBase & /*handler*/,
		UMPSignal & /*signal*/) {
	return TRUE;
}

////////////////////////////
UMPSession::SessionInfo::SessionInfo() :
		_serverOnlineCount(0) {
}

void UMPSession::SessionInfo::Reset() {
	PWaitAndSignal lock(_mutex);

	_guid.SetSize(0);
	_key.SetSize(0);
	_serverName.MakeEmpty();

	_serverAddress = IPPort();
	_udpReflectorAddress = IPPort();
	_udpProxyAddress = IPPort();
	_fxServerAddress = IPPort();

	_updateURL.MakeEmpty();

	_serverOnlineCount = 0;
}

PBYTEArray UMPSession::SessionInfo::GetGUID() const {
	PWaitAndSignal lock(_mutex);
	PBYTEArray ret = _guid;
	ret.MakeUnique();
	return ret;
}

void UMPSession::SessionInfo::SetGUID(const PBYTEArray & guid) {
	PWaitAndSignal lock(_mutex);
	_guid = guid;
	_guid.MakeUnique();
}

PBYTEArray UMPSession::SessionInfo::GetKey() const {
	PWaitAndSignal lock(_mutex);
	PBYTEArray ret = _key;
	ret.MakeUnique();
	return ret;
}

void UMPSession::SessionInfo::SetKey(const PBYTEArray & key) {
	PWaitAndSignal lock(_mutex);
	_key = key;
	_key.MakeUnique();
}

void UMPSession::SessionInfo::SetUpdateURL(const PString & updateURL) {
	PWaitAndSignal lock(_mutex);
	_updateURL = updateURL;
}

PString UMPSession::SessionInfo::GetUpdateURL() const {
	PWaitAndSignal lock(_mutex);
	return _updateURL;
}

IPPort UMPSession::SessionInfo::GetReflectServerAddress() const {
	PWaitAndSignal lock(_mutex);
	return _udpReflectorAddress;
}

void UMPSession::SessionInfo::SetReflectServerAddress(const IPPort & address) {
	PWaitAndSignal lock(_mutex);
	_udpReflectorAddress = address;
}

IPPort UMPSession::SessionInfo::GetUDPProxyAddress() const {
	PWaitAndSignal lock(_mutex);
	return _udpProxyAddress;
}

void UMPSession::SessionInfo::SetUDPProxyAddress(const IPPort & address) {
	PWaitAndSignal lock(_mutex);
	_udpProxyAddress = address;
}

IPPort UMPSession::SessionInfo::GetFXServerAddress() const {
	PWaitAndSignal lock(_mutex);
	return _fxServerAddress;
}

void UMPSession::SessionInfo::SetFXServerAddress(const IPPort & address) {
	PWaitAndSignal lock(_mutex);
	_fxServerAddress = address;
}

IPPort UMPSession::SessionInfo::GetServerAddress() const {
	PWaitAndSignal lock(_mutex);
	return _serverAddress;
}

void UMPSession::SessionInfo::SetServerAddress(const IPPort & address) {
	PWaitAndSignal lock(_mutex);
	_serverAddress = address;
}

PString UMPSession::SessionInfo::GetServerName() const {
	PWaitAndSignal lock(_mutex);
	return _serverName;
}

void UMPSession::SessionInfo::SetServerName(const PString & name) {
	PWaitAndSignal lock(_mutex);
	_serverName = name;
}
///////////////
UMPSession::UserInfo::UserInfo() {
}

void UMPSession::UserInfo::Reset() {
	PWaitAndSignal lock(_mutex);
	_passwordMD5Hex.MakeEmpty();
	_sig_userInfo.Clear();

}

BaseUserInfo UMPSession::UserInfo::GetBaseUserInfo() const {
	PWaitAndSignal lock(_mutex);
	BaseUserInfo bui;
	UMPSignal sig_bui;
	Sig::UserInfo(_sig_userInfo).GetBaseUserInfo(sig_bui);
	bui.GetFrom(sig_bui);
	return bui;
}

PString UMPSession::UserInfo::GetPasswordMD5Hex() const {
	PWaitAndSignal lock(_mutex);
	return _passwordMD5Hex;
}

void UMPSession::UserInfo::SetPasswordMD5Hex(const PString & passwd) {
	PWaitAndSignal lock(_mutex);
	_passwordMD5Hex = passwd;
}

double UMPSession::UserInfo::GetBalance() const {
	PWaitAndSignal lock(_mutex);
	double bal = 0;
	Sig::UserInfo(_sig_userInfo).GetBalance(bal);
	return bal;
}

IP UMPSession::UserInfo::GetCurrentLoginIP() const {
	PWaitAndSignal lock(_mutex);
	PString ip;
	Sig::UserInfo(_sig_userInfo).GetCurrentLoginIP(ip);
	return IP(ip);
}

UMPSignal UMPSession::UserInfo::GetUserInfo() const {
	PWaitAndSignal lock(_mutex);
	return _sig_userInfo;
}

void UMPSession::UserInfo::SetUserInfo(const UMPSignal & userInfo) {
	PWaitAndSignal lock(_mutex);
	for (DWORD i = 0; i < userInfo.GetSize(); i++) {
		E_UMPTag tag = e_ele_null;
		PString str;
		if (userInfo.GetAt(i, tag, str))
			_sig_userInfo.Set(tag, str);
	}

}
/////////////////////////
UMPSession::InteractCopyMap::InteractCopy::InteractCopy() {
	_timeout.SetTimeout(20 * 1000);
}

//////////////////////
UMPSession::InteractCopyMap::InteractCopyMap() {
}

UMPSession::InteractCopyMap::~InteractCopyMap() {
	Clear();
}

void UMPSession::InteractCopyMap::Clear() {
	PWaitAndSignal lock(_mapMutex);
	_map.clear();
}

PBOOL UMPSession::InteractCopyMap::Exist(DWORD seq) {
	PWaitAndSignal lock(_mapMutex);
	return (_map.find(seq) != _map.end());
}

void UMPSession::InteractCopyMap::Add(DWORD seq, const UMPSignal & interact) {
	PWaitAndSignal lock(_mapMutex);
	_map[seq]._sigInteract = interact;
}

PBOOL UMPSession::InteractCopyMap::Remove(DWORD seq, UMPSignal & interact) {
	PWaitAndSignal lock(_mapMutex);
	Map::iterator it = _map.find(seq);
	if (_map.end() != it) {
		interact = it->second._sigInteract;
		_map.erase(it);
		return TRUE;
	} else
		return FALSE;
}

void UMPSession::InteractCopyMap::Remove(DWORD seq) {
	PWaitAndSignal lock(_mapMutex);
	_map.erase(seq);
}

void UMPSession::InteractCopyMap::GetTimeout(Array & l) {
	PWaitAndSignal lock(_mapMutex);
	Map::iterator it = _map.begin(), eit = _map.end();
	while (it != eit) {
		if (it->second._timeout.IsTimeout()) {
			l.push_back(it->second._sigInteract);
			_map.erase(it++);
		} else
			it++;
	}

}
/////////////////
UMPSession::UMPSession(E_ClientType type, UMPSEventSink & eventSink) :
		UMPHandlerBase((UMPHandlerBase::UHEventSink&) *this), _type(type), _umpsEventSink(
				eventSink), _externalLogouted(FALSE), _externalLogoutReason(
				e_r_unknownError), _asyncNameResolver(
				(AsyncNameResolver::ANREventSink&) *this) {
	GetEvent().Register(e_sock_ev_read | e_sock_ev_tick);

	SetRoundTrip(TRUE);

	GetEvent().Bind(SocketEventGroup("UMPSession"));
            
#if defined(VOIPBASE_IOS) || defined(VOIPBASE_MAC)
            _streamIsOpened=FALSE;
#endif
}

UMPSession::~UMPSession() {
	Logout(e_r_interrupted, FALSE);
	GetEvent().Unbind();
	_asyncNameResolver.EndSync();
}

void UMPSession::SetClientInfo(const char* localIP, const char* devID,
		const char* osInfo) {
	Sig::ClientInfo clientInfo(_clientInfo);

	clientInfo.SetLocalInterface(PString(localIP));
	clientInfo.SetMacInfo(PString(devID));
	clientInfo.SetOSInfo(PString(osInfo));
}

E_ResultReason UMPSession::Login(const PString & u) {
	PURL url = u;
	if (url.GetScheme() != PCaselessString("ump"))
		return e_r_capabilityUnsupport;

	BaseUserInfo bui;
	PString alias = url.GetUserName_();
	if (alias.Find("#", 0) == 0)
		bui.SetID(alias.Mid(1).AsUnsigned64());
	else if (UMPUtility::IsDigits(alias))
		bui.SetNumber(alias);
	else
		bui.SetName(alias);

	PBOOL force = FALSE;
	if (url.GetQueryVars().Contains("force"))
		force = (url.GetQueryVars()["force"].AsInteger() != 0);

	PBOOL lastforward = FALSE;
	if (url.GetQueryVars().Contains("forward"))
		lastforward = (url.GetQueryVars()["forward"].AsInteger() != 0);

	return Login(url.GetHostName() + ":" + PString(url.GetPort()),
			url.GetPassword(), bui, force, lastforward);

}

E_ResultReason UMPSession::Login(const PString& server, const PString& passwd,
		const BaseUserInfo& bui, PBOOL force, PBOOL lastForward) {
	PWaitAndSignal lock(_transportMutex);

	E_ResultReason ret = e_r_unknownError;

	if (_stateMonitor.GetState() != e_offline) {
		return e_r_duplicateLogin;
	}
	if (server.IsEmpty()) {
		return e_r_invalidAddress;
	}

	Sig::Login login(_sig_login);
	UMPSignal sig_bui;

	bui.SetTo(sig_bui);
	if (sig_bui.GetSize() < 1) {
		ret = e_r_infoMissing;
		goto RET;
	}

	Reset();

	if (passwd.GetLength() == 32) {
		_userInfo.SetPasswordMD5Hex(passwd.ToUpper());
	} else {
		_userInfo.SetPasswordMD5Hex(
				UMPCypher::Hex(
						UMPCypher::MD5((const char *) passwd,
								passwd.GetLength()).GetValue()).ToUpper());
	}

	login.SetBaseUserInfo(sig_bui);
	login.SetVersion(ump_version);
	login.SetEncryptFlag(TRUE);
	login.SetForceFlag(force);
	login.SetClientType(GetType());

	//貌似没用
	login.setClientId("8bcde0c0-aab3-401e-903f-77ce929f018a");
	//login.setClientId("");
	{
		CapabilityArray caps;
		_umpsEventSink.OnGetInteractCapabilities(*this, caps);
		login.SetCapabilities(caps);
	}

	login.SetForwardFlag(lastForward);

	_stateMonitor.GetLoginTimeout().Reset();
	_stateMonitor.SetState(e_login);

	_serverNameToResove = server;
	U_DBG("Login ,login to server:"<<server);
	_asyncNameResolver.Resolve(server, defaultUMPPort);
	ret = e_r_ok;
	RET: if (ret != e_r_ok)
		Logout(ret);
	return ret;
}

PBOOL UMPSession::Logout(E_ResultReason reason, PBOOL async) {
	PWaitAndSignal lock(_transportMutex);

	if (_stateMonitor.GetState() == e_offline)
		return FALSE;

	if (async) {

		if (!_externalLogouted) {

			_externalLogouted = TRUE;
			_externalLogoutReason = reason;
			GetEvent().TickNow();
		}
	} else {
		InternalLogout(reason);
	}
	return TRUE;

}

PBOOL UMPSession::SetSubState(E_UserSubState subState,
		const PString& description/* = ""*/) {
	if (_stateMonitor.GetState() != e_online)
		return FALSE;

	UMPSignal sig_setUserSubState(e_sig_setUserSubState);

	Sig::SetUserSubState setUserSubState(sig_setUserSubState);
	setUserSubState.SetSubState(subState);
	setUserSubState.SetDescription(description);

	return WriteSignal(sig_setUserSubState);
}

PBOOL UMPSession::FetchTempInteract() {
	if (_stateMonitor.GetState() != e_online)
		return FALSE;

	UMPSignal sig_getTempInteract(e_sig_getTempInteract);

	return WriteSignal(sig_getTempInteract);
}

PBOOL UMPSession::FetchTempNotify() {
	if (_stateMonitor.GetState() != e_online)
		return FALSE;

	UMPSignal sig_getTempNotify(e_sig_getTempNotify);
	return WriteSignal(sig_getTempNotify);
}

PBOOL UMPSession::AddRelatedUser(const BaseUserInfo & rbui,
		const BaseGroupInfo & bgi, const PString & comment/* = ""*/) {
	if (_stateMonitor.GetState() != e_online)
		return FALSE;

	UMPSignal sig_addRelatedUser(e_sig_addRelatedUser);
	Sig::AddRelatedUser addRelatedUser(sig_addRelatedUser);

	UMPSignal sig_rbaseUserInfo;
	rbui.SetTo(sig_rbaseUserInfo);
	addRelatedUser.SetRelatedBaseUserInfo(sig_rbaseUserInfo);

	UMPSignal sig_bgi;
	bgi.SetTo(sig_bgi);
	addRelatedUser.SetBaseGroupInfo(sig_bgi);
	addRelatedUser.SetComment(comment);

	return WriteSignal(sig_addRelatedUser);
}

PBOOL UMPSession::RemoveRelatedUser(const BaseUserInfo & rbui) {
	if (_stateMonitor.GetState() != e_online)
		return FALSE;

	UMPSignal sig_delRelatedUser(e_sig_delRelatedUser);
	Sig::DelRelatedUser delRelatedUser(sig_delRelatedUser);

	UMPSignal sig_rbaseUserInfo;
	rbui.SetTo(sig_rbaseUserInfo);
	delRelatedUser.SetRelatedBaseUserInfo(sig_rbaseUserInfo);

	return WriteSignal(sig_delRelatedUser);
}

PBOOL UMPSession::ModifyRelatedUser(const BaseUserInfo & rbui,
		const BaseGroupInfo & bgi, const BaseGroupInfo & newBgi) {
	if (_stateMonitor.GetState() != e_online)
		return FALSE;

	UMPSignal sig_modRelatedUser(e_sig_modRelatedUser);
	Sig::ModRelatedUser modRelatedUser(sig_modRelatedUser);

	UMPSignal sig_rbaseUserInfo;
	rbui.SetTo(sig_rbaseUserInfo);
	modRelatedUser.SetRelatedBaseUserInfo(sig_rbaseUserInfo);

	UMPSignal sig_oldBgi;
	bgi.SetTo(sig_oldBgi);
	modRelatedUser.SetOldBaseGroupInfo(sig_oldBgi);

	UMPSignal sig_newBgi;
	newBgi.SetTo(sig_newBgi);
	modRelatedUser.SetNewBaseGroupInfo(sig_newBgi);

	return WriteSignal(sig_modRelatedUser);
}

PBOOL UMPSession::FetchRelatedUsers() {
	if (_stateMonitor.GetState() != e_online)
		return FALSE;

	UMPSignal sig_getRelatedUsers(e_sig_getRelatedUsers);

	return WriteSignal(sig_getRelatedUsers);
}

PBOOL UMPSession::FetchBaseUserInfo(const BaseUserInfo & bui) {
	if (_stateMonitor.GetState() != e_online)
		return FALSE;

	UMPSignal sig_getBaseUserInfo(e_sig_getBaseUserInfo);
	if (!bui.SetTo(sig_getBaseUserInfo))
		return FALSE;

	return WriteSignal(sig_getBaseUserInfo);
}

PBOOL UMPSession::FetchBaseGroupInfo(const BaseGroupInfo & bgi) {
	if (_stateMonitor.GetState() != e_online)
		return FALSE;

	UMPSignal sig_getBaseGroupInfo(e_sig_getBaseGroupInfo);
	if (!bgi.SetTo(sig_getBaseGroupInfo))
		return FALSE;

	return WriteSignal(sig_getBaseGroupInfo);
}

PBOOL UMPSession::FetchUserData(const PUInt64 & userId, const PString & key,
		DWORD type) {
	if (_stateMonitor.GetState() != e_online)
		return FALSE;

	UMPSignal sig_getUserData(e_sig_getUserData);
	Sig::GetUserData getUserData(sig_getUserData);
	getUserData.SetUserID(userId);
	getUserData.SetKey(key);
	getUserData.SetType(type);
	return WriteSignal(sig_getUserData);
}

PBOOL UMPSession::SetUserData(const PString & key, const PString& dataBlock,
		DWORD type, PBOOL shared) {
	if (_stateMonitor.GetState() != e_online)
		return FALSE;

	UMPSignal sig_setUserData(e_sig_setUserData);
	Sig::SetUserData setUserData(sig_setUserData);

	setUserData.SetKey(key);
	setUserData.SetShareFlag(shared);
	setUserData.SetType(type);
	setUserData.SetDataBlock(dataBlock);

	return WriteSignal(sig_setUserData);
}

PBOOL UMPSession::Interact(const BaseUserInfo & to, const BaseUserInfo & from,
		const UMPSignal& body, E_InteractType type, const PBYTEArray& guid,
		PBOOL serviceFlag /*= FALSE*/) {
	if (_stateMonitor.GetState() != e_online){
		U_WARN("account is offline");
		return FALSE;
	}

	const DWORD seq = _interactSequenceNumber.Next();

	UMPSignal sig_interact(e_sig_interact);

	Sig::Interact interact(sig_interact);

	{
		UMPSignal sig_to;
		to.SetTo(sig_to);
		interact.SetTo(sig_to);
	}

	if (from.GetID() != 0 || !from.GetName().IsEmpty()
			|| !from.GetNumber().IsEmpty()) {
		UMPSignal sig_from;
		from.SetTo(sig_from);
		interact.SetFrom(sig_from);
	}

	interact.SetBody(body);
	interact.SetType(type);

    if (guid.GetSize() > 0){
		interact.SetGUID(guid);
    }

	interact.SetSeqNumber(seq);
	interact.SetServiceFlag(serviceFlag);

	_interactCopyMap.Add(seq, sig_interact);
	if (!WriteSignal(sig_interact)) {
		if(type != e_interactType_message)
			_interactCopyMap.Remove(seq);

		U_WARN("WriteSignal failed");
		return FALSE;
	}

	return TRUE;
}

PBOOL UMPSession::FetchUserEInfo(const PString & userNumber,
		const PString & calleeNumber, const PString & callSessionId) {
	if (_stateMonitor.GetState() != e_online)
		return FALSE;

	UMPSignal sig_fetchUserEInfo(e_sig_fetch_user_einfo);
	Sig::FetchUserEInfo fetchUserEInfo(sig_fetchUserEInfo);

	fetchUserEInfo.SetUserNumber(userNumber);
	fetchUserEInfo.SetCalleeNumber(calleeNumber);
	fetchUserEInfo.SetCallSessionId(callSessionId);

	return WriteSignal(sig_fetchUserEInfo);
}

void UMPSession::OnReadSignal(UMPHandlerBase & /*handler*/, UMPSignal* signal,
		PBOOL & /*noDelete*/) {
	_stateMonitor.SetGotFirstSignal(TRUE);
	PBOOL ret = TRUE;
	switch (signal->GetTag()) {
	case e_sig_loginAck:
		ret = HandleLoginAck(*signal);
		break;
	case e_sig_pologinAck:
		ret = HandlePologinAck(*signal);
		break;
	case e_sig_forceOffline: {
		Sig::ForceOffline forceOffline(*signal);
		InternalLogout(forceOffline.GetResult());
		ret = TRUE;
	}
		break;
	case e_sig_interactAck:
		ret = HandleInteractAck(*signal);
		break;
	case e_sig_interact:
		ret = HandleInteract(*signal);
		break;
	case e_sig_relatedUsers:
		ret = HandleRelatedUsers(*signal);
		break;
	case e_sig_baseUserInfo:
		ret = HandleBaseUserInfo(*signal);
		break;
	case e_sig_baseGroupInfo:
		ret = HandleBaseGroupInfo(*signal);
		break;
	case e_sig_serverInfo:
		ret = HandleServerInfo(*signal);
		break;
	case e_sig_userInfo:
		ret = HandleUserInfo(*signal);
		break;
	case e_sig_userData:
		ret = HandleUserData(*signal);
		break;
	case e_sig_user_einfo:
		ret = HandleUserEInfo(*signal);
		break;
	case e_sig_notify:
		ret = HandleNotify(*signal);
		break;
	default: {
	}
	}
	if (!ret) {
	}
}

void UMPSession::OnReadBinary(UMPHandlerBase & /*handler*/, const void* /*bin*/,
		PINDEX /*size*/) {
}

void UMPSession::OnTransportError(UMPHandlerBase & /*handler*/) {
	InternalLogout(e_r_transportError);
}

void UMPSession::OnProtocolError(UMPHandlerBase & /*handler*/) {
	InternalLogout(e_r_protocolError);
}

PBOOL UMPSession::OnFilter(UMPHandlerBase & handler, UMPSignal& signal) {
	return _stateMonitor.Filter(handler, signal);
}

void UMPSession::OnConnect(UMPHandlerBase & handler,
		PChannel::Errors result) {
	if (result == PChannel::NoError) {
        
        int streamHandler = handler.GetHandle();
#if defined(VOIPBASE_IOS) || defined(VOIPBASE_MAC)
        
        U_INFO("onconnect 后台委托 start");
        
        
        if (!_streamIsOpened)
        {
            
            CFStreamCreatePairWithSocket(kCFAllocatorDefault, streamHandler, &readStream, &writeStream);
            
            U_INFO("readstream " << (int)CFReadStreamGetStatus(readStream));
            U_INFO("writestream " << (int)CFWriteStreamGetStatus(writeStream));
            
            if (!readStream || !writeStream ||
                CFReadStreamSetProperty(readStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP) != TRUE ||
                CFWriteStreamSetProperty(writeStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP) != TRUE ||
                CFReadStreamOpen(readStream) != TRUE ||
                CFWriteStreamOpen(writeStream) != TRUE)
            {
                CFReadStreamClose(readStream);
                CFWriteStreamClose(writeStream);
                CFRelease(readStream);
                CFRelease(writeStream);
                Close();
            }else{
                _streamIsOpened=TRUE;
            }
        }
        
        
#endif

		UMPCypher::RandomKey initKey(INIT_KEY_SIZE);
		GetCypher().SetKey(initKey, INIT_KEY_SIZE);
		Write(initKey, INIT_KEY_SIZE);
		U_DBG("OnConnect no Error");
		_sig_login.SetTag(e_sig_login);
		WriteSignal(_sig_login);

		GetEvent().Register(e_sock_ev_read | e_sock_ev_tick);
	} else {
		U_DBG("OnConnect error:"<<result);
		IPPort address = _sessionInfo.GetServerAddress();

		InternalLogout(e_r_connectFail);
	}
}

void UMPSession::OnTick(UMPHandlerBase & /*handler*/) {
	switch (_stateMonitor.GetState()) {
	case e_login:
	case e_pologin:
		if (_stateMonitor.GetLoginTimeout().IsTimeout()) {
			InternalLogout(e_r_timeout);
		}
		break;
	case e_online: {
		InteractCopyMap::Array array;
		_interactCopyMap.GetTimeout(array);
		if (!array.empty()) {
			UMPSignal sig_interactAck(e_sig_interactAck);
			Sig::InteractAck interactAck(sig_interactAck);
			interactAck.SetResult(e_r_timeout);

			for (unsigned i = 0; i < array.size(); i++) {
				interactAck.SetSeqNumber(
						Sig::Interact(array[i]).GetSeqNumber());
				_umpsEventSink.OnInteractAck(*this, interactAck, array[i]);

			}
		}
	}
		break;
	default:
		break;
	}

	if (_stateMonitor.GetState() != e_offline) {
		if (_externalLogouted) {
			if (_stateMonitor.GetState() == e_online) {
				WriteSignal(UMPSignal(e_sig_logout));
				InternalLogout(_externalLogoutReason);
			} else
				InternalLogout(_externalLogoutReason);
		}
	}

	_umpsEventSink.OnUMPSTick(*this);

}

void UMPSession::OnReadable(SocketBase & socket, PBYTEArray& sharedBuffer) {
	PWaitAndSignal lock(_transportMutex);
	UMPHandlerBase::OnReadable(socket, sharedBuffer);
}

void UMPSession::OnGotBlock(void* block, PINDEX blockSize) {
	if (_stateMonitor.HasGotFirstSignal())
		UMPHandlerBase::OnGotBlock(block, blockSize);
	else {
		if (blockSize <= 1) {
			return;
		}

		UMPSignal signal;

		if (((const BYTE *) block)[0] == 1
				&& signal.Decode(((const BYTE *) block) + 1, blockSize - 1)
				&& signal.GetTag() == e_sig_loginAck) {
			HandleLoginAck(signal);
		} else {
			UMPHandlerBase::OnGotBlock(block, blockSize);
		}
	}
}

void UMPSession::OnWriteRoundTrip(Sig::RoundTrip & rt) {
	_umpsEventSink.OnWriteRoundTrip(rt);
}

void UMPSession::OnWriteRoundTripAck(Sig::RoundTripAck & rta) {
	_umpsEventSink.OnWriteRoundTripAck(rta);
}

void UMPSession::OnReadRoundTrip(const Sig::RoundTrip & rt) {
	_sessionInfo.SetServerOnlineCount(rt.GetOnlineCount());
	_umpsEventSink.OnReadRoundTrip(rt);
}

void UMPSession::OnReadRoundTripAck(const Sig::RoundTripAck & rta) {
	_umpsEventSink.OnReadRoundTripAck(rta);
}

PBOOL UMPSession::HandleLoginAck(const Sig::LoginAck & loginAck) {
	E_ResultReason result = loginAck.GetResult();

	switch (result) {
	case e_r_ok: {
		PString passwd = _userInfo.GetPasswordMD5Hex();

		PBYTEArray key = UMPCypher::TEA((const char *) passwd,
				passwd.GetLength()).Decode(loginAck.GetKey());

		_sessionInfo.SetKey(key);
		_stateMonitor.SetState(e_pologin);

		UMPSignal sig_pologin(e_sig_pologin);

		Sig::Pologin pologin(sig_pologin);

		pologin.SetClientInfo(_clientInfo);

		pologin.SetKey(
				UMPCypher::MD5(
						UMPCypher::MD5(UMPCypher::MD5(key).GetValue()).GetValue()).GetValue());

		PBYTEArray lastSessionGUID;
		_umpsEventSink.OnGetLastSessionGUID(*this, lastSessionGUID);
		pologin.SetLastSessionGUID(lastSessionGUID);

		WriteSignal(sig_pologin);
	}
		break;
	case e_r_forward: {
		Sig::Login login(_sig_login);
		UMPSignal bui;

		login.GetBaseUserInfo(bui);
		PBOOL force = login.HasForceFlag();

		PString passwd = _userInfo.GetPasswordMD5Hex();
		_stateMonitor.SetState(e_offline);

		InternalLogout(e_r_forward);
		//Init();

		GetCypher().SetKey(NULL, 0);
		U_DBG("login forward to :"<<loginAck.GetForwardTo());
		E_ResultReason r = Login(loginAck.GetForwardTo(), passwd, bui, force,
				TRUE);
		U_DBG("login res :"<<r);
		if (r != e_r_ok) {
			_stateMonitor.SetState(e_login);
			InternalLogout(r);
		}
	}
		break;
	default: {
		if (e_r_versionFail == result) {
			_sessionInfo.SetUpdateURL(loginAck.GetURL());
		}
		InternalLogout(result);
	}
		break;
	}
	return TRUE;
}

PBOOL UMPSession::HandlePologinAck(const Sig::PologinAck & pologinAck) {
	E_ResultReason result = pologinAck.GetResult();

	if (result == e_r_ok) {

		PBYTEArray bin_guid = pologinAck.GetSessionGUID();
		PBYTEArray bin_userInfo = pologinAck.GetUserInfo();

		PBYTEArray key = _sessionInfo.GetKey();
		GetCypher().SetKey(key);

		GetCypher().Decode(bin_guid, bin_guid.GetSize(), bin_guid.GetPointer());
		GetCypher().Decode(bin_userInfo, bin_userInfo.GetSize(),
				bin_userInfo.GetPointer());

		_sessionInfo.SetGUID(bin_guid);
		UMPSignal sig_userInfo;

		sig_userInfo.Decode(bin_userInfo);
		_userInfo.SetUserInfo(sig_userInfo);

		_stateMonitor.SetState(e_online);

		_umpsEventSink.OnLogin(*this, e_r_ok);

		_umpsEventSink.OnUserInfo(*this, sig_userInfo);

	} else
		InternalLogout(result);
	return TRUE;
}

PBOOL UMPSession::HandleInteractAck(const Sig::InteractAck & interactAck) {
	const DWORD seqNO = interactAck.GetSeqNumber();

	UMPSignal sig_interact;

	if (_interactCopyMap.Remove(seqNO, sig_interact)) {
		_umpsEventSink.OnInteractAck(*this, interactAck, sig_interact);
		return TRUE;
	} else
		return FALSE;

}

PBOOL UMPSession::HandleInteract(const Sig::Interact & interact) {
	_umpsEventSink.OnInteract(*this, interact);
	return TRUE;
}

PBOOL UMPSession::HandleNotify(const Sig::Notify & notify) {
	return TRUE;
}

PBOOL UMPSession::HandleRelatedUsers(const Sig::RelatedUsers & relatedUsers) {
	RelatedUserMap ruis;
	ruis.FromString(relatedUsers.GetRUsers());

	_umpsEventSink.OnRelatedUsers(*this, ruis);
	return TRUE;
}

PBOOL UMPSession::HandleBaseUserInfo(const Sig::BaseUserInfo & baseUserInfo) {
	BaseUserInfo bui(baseUserInfo.GetSignal());

	_umpsEventSink.OnBaseUserInfo(*this, bui);
	return TRUE;
}

PBOOL UMPSession::HandleBaseGroupInfo(
		const Sig::BaseGroupInfo & baseGroupInfo) {
	BaseGroupInfo bgi(baseGroupInfo.GetSignal());
	_umpsEventSink.OnBaseGroupInfo(*this, bgi);
	return TRUE;
}

PBOOL UMPSession::HandleServerInfo(const Sig::ServerInfo & serverInfo) {
	PString proxyServerAddr = serverInfo.GetUDPProxy();
	PString reflectServerAddr = serverInfo.GetReflector();
	PString fxServerAddr = serverInfo.GetFX();
//	DWORD onlineCount = serverInfo.GetOnlineCount();

	IPPort ipport;
	ipport.FromString(serverInfo.GetReflector(), defaultUDPReflectPort);
	if (!ipport.GetIP().IsValid())
		ipport.SetIP(GetPeerAddress().GetIP());

	_sessionInfo.SetReflectServerAddress(ipport);

	ipport.FromString(serverInfo.GetUDPProxy(), defaultUDPProxyPort);
	if (!ipport.GetIP().IsValid())
		ipport.SetIP(GetPeerAddress().GetIP());

	_sessionInfo.SetUDPProxyAddress(ipport);

	ipport.FromString(serverInfo.GetFX(), defaultFXPort);
	if (!ipport.GetIP().IsValid())
		ipport.SetIP(GetPeerAddress().GetIP());

	_sessionInfo.SetFXServerAddress(ipport);

	_sessionInfo.SetServerName(serverInfo.GetName());

	_sessionInfo.SetServerOnlineCount(serverInfo.GetOnlineCount());

	_umpsEventSink.OnServerInfo(*this, serverInfo);
	return TRUE;
}

PBOOL UMPSession::HandleUserInfo(const Sig::UserInfo & userInfo) {
	_userInfo.SetUserInfo(userInfo.GetSignal());
	_umpsEventSink.OnUserInfo(*this, userInfo);
	return TRUE;
}

PBOOL UMPSession::HandleUserData(const Sig::UserData & userData) {
	_umpsEventSink.OnUserData(*this, userData);
	return TRUE;
}

PBOOL UMPSession::HandleUserEInfo(const Sig::UserEInfo & userEInfo) {
	_umpsEventSink.OnUserEInfo(*this, userEInfo);
	return TRUE;
}

void UMPSession::InternalLogout(E_ResultReason reason) {
	Close();
    
#if defined(VOIPBASE_IOS) || defined(VOIPBASE_MAC)
    if(_streamIsOpened)
    {
        U_INFO("onconnect 后台委托 end");
        CFReadStreamClose(readStream);
        CFWriteStreamClose(writeStream);
        CFRelease(readStream);
        CFRelease(writeStream);
        _streamIsOpened=FALSE;
    }
#endif
    
	if (_externalLogouted)
		reason = _externalLogoutReason;

	if (_stateMonitor.GetState() != e_offline) {
	}

	U_DBG("InternalLogout:"<<reason<<" state:"<<_stateMonitor.GetState());

	switch (_stateMonitor.GetState()) {

	case e_online:
        _umpsEventSink.ForceEndCall(*this, reason);
        _stateMonitor.SetState(e_offline);
		_umpsEventSink.OnLogout(*this, reason);
		break;
	case e_login:
	case e_pologin:
		_stateMonitor.SetState(e_offline);
		_umpsEventSink.OnLogin(*this,
				(reason == e_r_ok) ? e_r_interrupted : reason);
		break;
	default:
		break;
	}

}

void UMPSession::Reset() {
	_sessionInfo.Reset();
	_userInfo.Reset();
	_interactCopyMap.Clear();
	_sig_login.Clear();
	_stateMonitor.SetGotFirstSignal(FALSE);

	GetCypher().SetKey(NULL, 0);
	_externalLogouted = FALSE;
	_externalLogoutReason = e_r_unknownError;

	_serverNameToResove = "";
}

void UMPSession::OnResolved(AsyncNameResolver & /*anr*/, PBOOL success,
		const AsyncNameResolver::Param & param, const IPPort & addr) {
	PWaitAndSignal lock(_transportMutex);
	U_DBG(
			"OnResolved: state:"<<_stateMonitor.GetState()<<"server:"<<_serverNameToResove);
	if (_stateMonitor.GetState() != e_login)
		return;

	if (param._name != _serverNameToResove) {
		U_DBG("OnResolved param.name:"<<param._name);
		return;
	}
	if (success) {
		_sessionInfo.SetServerAddress(addr);
		GetEvent().Register(e_sock_ev_connect);
		U_DBG(
				"OnResolved success: state:"<<_stateMonitor.GetState()<<"server:"<<_serverNameToResove);
		if (!Connect(addr)) {
			U_DBG("OnResolved connect fail:server:"<<_serverNameToResove);
			InternalLogout(e_r_connectFail);
		} else {
			U_DBG("OnResolved connect success"<<_serverNameToResove);
		}

	} else {
		InternalLogout(e_r_invalidAddress);
	}
	_serverNameToResove = "";
}

///////////////////////

#define DEFINE_LEGACY_URL_SCHEME(schemeName, user, pass, host, def, defhost, query, params, frags, path, rel, port) \
class PURLLegacyScheme_##schemeName : public PURLLegacyScheme \
{ \
public: \
	PURLLegacyScheme_##schemeName() \
	: PURLLegacyScheme(#schemeName )  \
    { \
        hasUsername           = user; \
        hasPassword           = pass; \
        hasHostPort           = host; \
        defaultToUserIfNoAt   = def; \
        defaultHostToLocal    = defhost; \
        hasQuery              = query; \
        hasParameters         = params; \
        hasFragments          = frags; \
        hasPath               = path; \
        relativeImpliesScheme = rel; \
        defaultPort           = port; \
    } \
}; \
static PFactory<PURLScheme>::Worker<PURLLegacyScheme_##schemeName> schemeName##Factory(#schemeName, true); \

DEFINE_LEGACY_URL_SCHEME(ump, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, FALSE,
		TRUE, FALSE, defaultUMPPort)
