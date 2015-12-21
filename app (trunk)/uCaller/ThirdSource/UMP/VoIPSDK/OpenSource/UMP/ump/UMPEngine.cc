//
//  UMPEngine.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-13.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "Common/ulog.h"
#include "UMPEngine.h"

class ServerList {
public:
	ServerList() :
			_curServer("") {
		ReLoadList();
	}

	virtual ~ServerList() {
		_serversQueue.clear();
	}

	void Clear() {
		_curServer = "";
		_serversQueue.clear();
	}

	void ReLoadList() {
		Clear();
		if (_curServer.IsEmpty()) {

			PStringArray permanentServers;


//			do {
				//	permanentServers.AppendString("210.21.118.202:1800");
				//permanentServers.AppendString("114.251.39.43:1800");
				//permanentServers.AppendString("114.251.39.49:1800");
//#if 0
//				permanentServers.AppendString("1.uulogin01.com:1800");
//#endif
//			} while (0);

			PStringArray temp;
			RandOrder(permanentServers, temp);

			for (int i = 0; i < temp.GetSize(); i++) {
				_serversQueue.push_back(temp[i]);
			}
		}
	}

	void AddServer(const char* server) {
		_serversQueue.push_back(PString(server));
	}

	PString GetNextServer() {
		if (_serversQueue.size() > 0) {
			_curServer = _serversQueue[0];
			_serversQueue.erase(_serversQueue.begin());
		}
		return _curServer;
	}

	void ReuseCurServer() {
		if (!_curServer.IsEmpty())
			_serversQueue.insert(_serversQueue.begin(), _curServer);
	}

	PString GetCurServer() {
		return _curServer;
	}

	PBOOL IsServerInQueue(const PString &server) {
		if (server == _curServer)
			return TRUE;
		for (int i = 0; i < (int) _serversQueue.size(); i++) {
			if (_serversQueue.at(i) == server)
				return TRUE;
		}
		return FALSE;
	}

	UINT GetServerListCount() {
		return _serversQueue.size();
	}

private:
	void RandOrder(const PStringArray & src, PStringArray & dest) const {
		PStringArray temp = src;

		while (temp.GetSize() > 0) {
			PINDEX i = rand() % temp.GetSize();
			dest.AppendString(temp[i]);
			temp.RemoveAt(i);
		}
	}

private:
	typedef std::vector<PString> ServersQueue;
	ServersQueue _serversQueue;
	PString _curServer;
};

static ServerList gServerList;

struct LoginInfo {
	BaseUserInfo _userInfo;
	PString _password;
	PBOOL _forceLogin;
	PString _curLoginServer;
};
static LoginInfo gLoginInfo;

UMPEngine* UMPEngine::umpEngine = 0;

UMPEngine *UMPEngine::getUMPEngine() {
	if (umpEngine == 0) {
		umpEngine = new UMPEngine();
	}
	return umpEngine;
}

UMPEngine::UMPEngine() {
	umpSession = new UMPSession(e_clt_t_mobile, *this);
	uppSession = NULL;
	//umpSession->GetEvent().Bind(SocketEventGroup("UMPSession"));

	urtpEncryption = URTPEncryption::getURTPEncryption();

#ifndef VOIPBASE_ANDROID
    _umpEngineEventSink = NULL;
#endif

	bHangup = FALSE;
}

UMPEngine::~UMPEngine() {
	delete umpSession;
	if (uppSession) {
		delete uppSession;
		uppSession = NULL;
	}
    
#ifndef VOIPBASE_ANDROID
    _umpEngineEventSink = NULL;
#endif
}

#ifdef VOIPBASE_ANDROID
void UMPEngine::SetJNIObjects(JavaVM* jvm, JNIEnv* env) {
	if (env) {
		// get java class type (note path to class packet)
		jclass javaScClassLocal = env->FindClass(UMPListenerClass);
		if (!javaScClassLocal) {
			return;
		}

		// create a global reference to the class (to tell JNI that we are
		// referencing it after this function has returned)
		javaUMPListenerClass = reinterpret_cast<jclass>(env->NewGlobalRef(
				javaScClassLocal));
		if (!javaUMPListenerClass) {
			return;
		}

		// Delete local class ref, we only use the global ref
		env->DeleteLocalRef(javaScClassLocal);

		// get the method ID for the void(void) constructor
		jmethodID cid = env->GetMethodID(javaUMPListenerClass, "<init>", "()V");
		if (cid == NULL) {
			return; /* exception thrown */
		}

		// construct the object
		jobject javaScObjLocal = env->NewObject(javaUMPListenerClass, cid);
		if (!javaScObjLocal) {
			return;
		}

		// create a reference to the object (to tell JNI that we are referencing it
		// after this function has returned)
		javaUMPListenerObject = env->NewGlobalRef(javaScObjLocal);
		if (!javaUMPListenerObject) {
			return;
		}

		// Delete local object ref, we only use the global ref
		env->DeleteLocalRef(javaScObjLocal);
	} else {
		if (gJNIEnv) {
			if (javaUMPListenerObject != NULL)
				gJNIEnv->DeleteLocalRef(javaUMPListenerObject);
			if (javaUMPListenerClass != NULL)
				gJNIEnv->DeleteLocalRef(javaUMPListenerClass);
		}
	}

	gJNIVM = jvm;
	gJNIEnv = env;
}
#endif

bool UMPEngine::Start() {
	return true;
}

void UMPEngine::Stop() {
}

void UMPEngine::AddServer(const char* server, bool clear) {
	if (clear == true)
		gServerList.Clear();

	gServerList.AddServer(server);
}

void UMPEngine::SetClientInfo(const char* localIP, const char* devID,
		const char* osInfo) {
	umpSession->SetClientInfo(localIP, devID, osInfo);
}

int UMPEngine::Login(const char* user, const char* password,
		const char* server) {
	gLoginInfo._password = password;
	gLoginInfo._forceLogin = false;
	gLoginInfo._userInfo.SetName("");
	gLoginInfo._userInfo.SetNumber("");

	gLoginInfo._curLoginServer = server;
	if (gLoginInfo._curLoginServer.IsEmpty()) {
		if (gServerList.GetServerListCount() == 0)
			gServerList.ReLoadList();

		gLoginInfo._curLoginServer = gServerList.GetNextServer();
		if (gLoginInfo._curLoginServer.IsEmpty())
			return e_r_invalidAddress;
	}

	PString strUser = user;
	if (UMPUtility::IsDigits(strUser))
		gLoginInfo._userInfo.SetNumber(strUser);
	else
		gLoginInfo._userInfo.SetName(strUser);

	U_INFO("start login to " << gLoginInfo._curLoginServer);
	return umpSession->Login(gLoginInfo._curLoginServer, gLoginInfo._password,
			gLoginInfo._userInfo, gLoginInfo._forceLogin, false);
}

void UMPEngine::TryNextLoginServer() {
	gLoginInfo._curLoginServer = gServerList.GetNextServer();
	umpSession->Login(gLoginInfo._curLoginServer, gLoginInfo._password,
			gLoginInfo._userInfo, gLoginInfo._forceLogin, false);
}

void UMPEngine::Logout(PBOOL async) {
	umpSession->Logout(e_r_ok, async);
}

bool UMPEngine::MatchGUID(const PBYTEArray & guid) const {
	return (sessionID.GetSize() == guid.GetSize()
			&& memcmp(sessionID, guid, sessionID.GetSize()) == 0);
}

void UMPEngine::CreateSession(bool master) {
	uppSession = new UPPSession(master, *this, reflectServer);
}

void UMPEngine::SetPeerUser(const BaseUserInfo &bui) {
	peerUser.SetID(bui.GetID());
	if (peerUser.GetName().IsEmpty())
		peerUser.SetName(bui.GetName());

	if (peerUser.GetNumber().IsEmpty())
		peerUser.SetNumber(bui.GetNumber());
}

void UMPEngine::Call(const char* number) {
	PString strNumber(number); // = new PString(number);
	if (strNumber.IsEmpty()){
		U_WARN("strNumber is empty,return");
		return;
	}

	BaseUserInfo to;
	if (UMPUtility::IsDigits(strNumber))
		to.SetNumber(strNumber);
	else {
		PStringArray numberList = strNumber.Tokenise("-");
		if (numberList.GetSize() > 0 && UMPUtility::IsDigits(numberList[0]))
			to.SetNumber(numberList[0]);
	}

	PBYTEArray guid = PBYTEArray();

	if (uppSession) {
		U_WARN("uppSession is not null,force logout");
        
        {
            PWaitAndSignal lock(_mutex);
            U_INFO("Call::set bHangup false");
            bHangup = FALSE;
        }
        
        EndCall();
        
//        umpSession->Logout(e_r_unknownError, TRUE);
		return;
	}

	UMPSignal sig_body;
	Sig::InteractBodyPhone body(sig_body);

	body.SetKey(UMPCypher::RandomKey(rand() % 16 + 8));

	if (guid.GetSize() > 0) {
		sessionID = guid;
		sessionID.MakeUnique();
	} else
		sessionID = GloballyUniqueID();

	CreateSession(true);
	uppSession->SetCypherKey(body.GetKey());
	urtpEncryption->SetCypherKey(body.GetKey());
	SetPeerUser(to);

	BaseUserInfo from = BaseUserInfo();

	umpSession->Interact(to, from, sig_body,
			(E_InteractType) e_interactType_phone, sessionID,
			(PBOOL) strNumber[0] == '0' ? TRUE : FALSE);
}


void UMPEngine::ResetUppSession(){
    if (uppSession) {
        U_WARN("uppSession is not null,force ResetUppSession");
        
        {
            PWaitAndSignal lock(_mutex);
            U_INFO("ResetUppSession::set bHangup false");
            bHangup = FALSE;
        }
        
        EndCall();
        
        //        umpSession->Logout(e_r_unknownError, TRUE);
        return;
    }
}



void UMPEngine::SendMsg(const char* to_uid, const char* to_number,
		const char* content,const char* origsmsid,int contenttype) {
	PUInt64 intUid = PString(to_uid).AsUnsigned64();
	PString strNumber(to_number); // = new PString(number);
	PString strContent(content);
	PString strOrigsmsid(origsmsid);
	if ((intUid == 0) && strNumber.IsEmpty())
		return;
	if (strContent.IsEmpty() || strOrigsmsid.IsEmpty())
		return;
	BaseUserInfo to;
	if (intUid)
		to.SetID(intUid);

	if (UMPUtility::IsDigits(strNumber))
		to.SetNumber(strNumber);
	else {
		PStringArray numberList = strNumber.Tokenise("-");
		if (numberList.GetSize() > 0 && UMPUtility::IsDigits(numberList[0]))
			to.SetNumber(numberList[0]);
	}

	PBYTEArray guid = PBYTEArray();

	UMPSignal sig_body;
	sig_body.Set(e_ele_content, strContent);
	sig_body.Set(e_ele_comment, strOrigsmsid);
    sig_body.Set(e_ele_type,contenttype);

	//body.SetKey(UMPCypher::RandomKey(rand() % 16 + 8));

	if (guid.GetSize() > 0) {
		sessionID = guid;
		sessionID.MakeUnique();
	} else
		sessionID = GloballyUniqueID();

	BaseUserInfo from = BaseUserInfo();
	umpSession->Interact(to, from, sig_body,
			(E_InteractType) e_interactType_message, sessionID,
			(PBOOL) strNumber[0] == '0' ? TRUE : FALSE);

}

void UMPEngine::AnswerCall() {
	if (uppSession)
		uppSession->Answer();
}

void UMPEngine::RefuseCall() {
//	if (uppSession)
//		uppSession->Release(e_r_refuse, e_actor_self);
	EndCall(e_r_refuse,e_actor_self);
}

void UMPEngine::EndCall(E_ResultReason reason, E_Actor actor) {
    
    {
        PWaitAndSignal lock(_mutex);
        
        if (0 == uppSession){
            U_WARN("EndCall:uppSession is null,return");
            return;
        }
        
        if (bHangup){
            U_WARN("EndCall:bHangup is true,return");
            return;
        }
        
        U_INFO("EndCall:set bHangup true");
        bHangup = TRUE;
        U_WARN("fordbg:EndCall is call,and change bHangup to true,reason"<<reason<<": actor:"<<actor);
    }
    
    if (uppSession->GetBCStateMonitor().GetState() != BridgeChannel::e_ready)
        StopCall(peerUser, reason, sessionID);
    
    uppSession->Release(
                        (uppSession->GetUPPStateMonitor().GetState()
                         == UPPSession::e_upps_connect) ? e_r_ok : reason, actor);
    
    //    if(uppSession->GetBCStateMonitor().GetState() != BridgeChannel::e_ready)
    //        StopCall(peerUser,reason, sessionID);
    
    U_INFO("EndCall  before delete uppSession");
    delete uppSession;
    uppSession = NULL;
    U_INFO("EndCall  end delete uppSession");
    
    sessionID.SetSize(0);
    peerUser = BaseUserInfo();
    
    
#ifdef VOIPBASE_ANDROID
    JNIEnv* jniEnv;
    bool isAttached = AttachJNIEnv(&jniEnv);
    U_WARN("fordbg:enter umpengine OnRelease,isAttached " << isAttached);
    if (isAttached) {
        onCallEndID = jniEnv->GetMethodID(javaUMPListenerClass, onCallEndMethod,
                                          onCallEndSignature);
        if (onCallEndID == NULL) {
            U_WARN("fordbg:enter umpengine OnRelease, onCallEndID is null");
        } else {
            U_WARN("fordbg:enter umpengine OnRelease,call CallVoidMethod");
            jniEnv->CallVoidMethod(javaUMPListenerObject, onCallEndID, reason);
        }
        
        // Detach this thread if it was attached
        DetachJNIEnv();
    }
#else
    if(_umpEngineEventSink)
        _umpEngineEventSink->onCallEnd((int)reason);
#endif
    
    
    {
        PWaitAndSignal lock(_mutex);
        U_INFO("EndCall:set bHangup false");
        bHangup = FALSE;
    }
    

    
}

void UMPEngine::SendDTMF(const char* dtmf) {
	PString strDTMF(dtmf);
	if (strDTMF.IsEmpty())
		return;

	if (!uppSession) {
		return;
	}
	uppSession->WriteDTMF(strDTMF);
}

void UMPEngine::StartCall(const BaseUserInfo & to, const PString & peerIP,
		const PBYTEArray & guid) {
	UMPSignal sig_body;
	Sig::InteractBodyStart body(sig_body);
	body.SetPeerIP(peerIP);

	umpSession->Interact(to, BaseUserInfo(), sig_body,
			(E_InteractType) e_interactType_start, guid);
}

void UMPEngine::StopCall(const BaseUserInfo & to, E_ResultReason r,
		const PBYTEArray & guid) {
	U_INFO("enter StopCall");
	if (to.GetID() == 0 && to.GetName().IsEmpty() && to.GetNumber().IsEmpty())
		return;

	UMPSignal sig_bodyStop;
	Sig::InteractBodyStop stop(sig_bodyStop);
	stop.SetResult(r);

	//modify by yanyu 2015-1-26
		umpSession->Interact(to, BaseUserInfo(), sig_bodyStop,
				(E_InteractType) e_interactType_stop, guid);
}

void UMPEngine::SetAutoKeepAlive(int sec) {
	if (umpSession)
		umpSession->SetRoundTripTime(sec);
}

void UMPEngine::KeepAlive() {
	U_DBG("keepalive");
	UMPSignal sig_roundTrip(e_sig_roundTrip);
	Sig::RoundTrip roundTrip(sig_roundTrip);
	OnWriteRoundTrip(roundTrip);
	if(!umpSession->WriteSignal(sig_roundTrip))
	{
		U_WARN("send keepalive failed");
	}

	U_DBG("send keepalive success");
}

void UMPEngine::HandleInteractPhone(const Sig::Interact & interact) {
	UMPSignal sig_from;
	Sig::BaseUserInfo from(sig_from);
	interact.GetFrom(sig_from);
	UMPSignal sig_body;
	interact.GetBody(sig_body);

	if (interact.HasTemporaryFlag()) {
		//offline call
	} else {
		if (uppSession) {
			U_WARN("fordbg:HandleInteractPhone uppSession is not null");
			StopCall(BaseUserInfo(from.GetUserID(), "", ""), e_r_busy,
					interact.GetGUID());
		} else {
			sessionID = interact.GetGUID();
			SetPeerUser(BaseUserInfo(sig_from));

			CreateSession(false);
			uppSession->SetCypherKey(Sig::InteractBodyPhone(sig_body).GetKey());
			urtpEncryption->SetCypherKey(
					Sig::InteractBodyPhone(sig_body).GetKey());

			StartCall(BaseUserInfo(from.GetUserID(), "", ""),
					interact.GetFromIP(), interact.GetGUID());
		}
	}
}

void UMPEngine::HandleInteractPhoneStart(const Sig::Interact & interact) {
	if (0 == uppSession){
		U_INFO("uppSession is null");
		return;
	}

	if (!MatchGUID(interact.GetGUID())){
		U_INFO("guid is not matched");
		return;
	}

	UMPSignal sig_from;
	interact.GetFrom(sig_from);
	SetPeerUser(BaseUserInfo(sig_from));

	UMPSignal sig_bridge;

	UMPSignal sig_body;
	Sig::InteractBodyStart body(sig_body);
	interact.GetBody(sig_body);

	body.GetBridge(sig_bridge);
	U_INFO("start connect to bridge");
	uppSession->Connect(Sig::Bridge(sig_bridge));
}

void UMPEngine::HandleInteractPhoneStop(const Sig::Interact & interact,bool force/*=false*/) {
	if (0 == uppSession)
		return;


	if (!force && !MatchGUID(interact.GetGUID()))
		return;

//	if (!uppSession->IsRecvCallReleaseSignal()){
//		PThread::Sleep(1000);
//	}

	UMPSignal sig_body;
	Sig::InteractBodyStop body(sig_body);
	interact.GetBody(sig_body);
	E_ResultReason result=body.GetResult();
	U_WARN("fordbg:HandleInteractPhoneStop ,call EndCall method result code:"<<result);
	EndCall(result, e_actor_peer);

#ifdef VOIPBASE_ANDROID
		JNIEnv* jniEnv;
		bool isAttached = AttachJNIEnv(&jniEnv);
		U_WARN("fordbg:enter umpengine HandleInteractPhoneStop,isAttached " << isAttached);
		if (isAttached) {
			onCallEndID = jniEnv->GetMethodID(javaUMPListenerClass,
					onCallEndMethod, onCallEndSignature);
			if (onCallEndID == NULL) {
				U_WARN("fordbg:enter umpengine HandleInteractPhoneStop, onCallEndID is null");
			} else {
				U_WARN("fordbg:enter umpengine HandleInteractPhoneStop,call CallVoidMethod");
				jniEnv->CallVoidMethod(javaUMPListenerObject, onCallEndID,
						result);
			}
			// Detach this thread if it was attached
			DetachJNIEnv();
		}
#else
    if(_umpEngineEventSink)
        _umpEngineEventSink->onCallEnd((int)result);
#endif

}

void UMPEngine::HandleInteractMessage(const Sig::Interact & interact) {
	PString from_uid, from_number, content;
	UMPSignal from, body;
	interact.GetFrom(from);
	from.Get(e_ele_userNumber, from_number);
	from.Get(e_ele_userID, from_uid);
	interact.GetBody(body);
	body.Get(e_ele_content, content);

#ifdef VOIPBASE_ANDROID
	JNIEnv* jniEnv;
	bool isAttached = AttachJNIEnv(&jniEnv);
	if (isAttached) {
		jstring jstrFromUID = jniEnv->NewStringUTF(from_uid.toChar());
		jstring jstrFromNumber = jniEnv->NewStringUTF(from_number.toChar());
		jstring jstrContent = jniEnv->NewStringUTF(content.toChar());
		onMessageID = jniEnv->GetMethodID(javaUMPListenerClass, onMessageMethod,
				onMessageSignature);
		if (onMessageID == NULL) {
			U_WARN(
					"fordbg:enter umpengine HandleInteractMessage, onMessageID is null");
		} else {
			U_WARN(
					"fordbg:enter umpengine HandleInteractMessage,call onReceivedMessage");
			jniEnv->CallVoidMethod(javaUMPListenerObject, onMessageID,
					jstrFromUID, jstrFromNumber, jstrContent);
		}
		// Detach this thread if it was attached
		DetachJNIEnv();
	}
#else
    if(_umpEngineEventSink){
        _umpEngineEventSink->onMessage(from_uid.toChar(), from_number.toChar(), content.toChar());
    }
#endif
}

void UMPEngine::HandleInteractAckMessage(const Sig::Interact & interact,
		const Sig::InteractAck & ack) {
	
	
	UMPSignal body;
	PString origsmsid,newsmsid;
	UINT16 result;
	
	interact.GetBody(body);
	body.Get(e_ele_comment,origsmsid);
	/*result=*/(UINT16)ack.GetResult();
	if(ack.GetResult() == e_r_ok){
		newsmsid = ack.GetSMSID();
	}
	
	U_INFO("HandleInteractAckMessage response code is " << ack.GetResult() << ",origsmsid:" << origsmsid << ",newsmsid:" << newsmsid);

#ifdef VOIPBASE_ANDROID
		JNIEnv* jniEnv;
		bool isAttached = AttachJNIEnv(&jniEnv);
		if (isAttached) {
			onMessageAckID = jniEnv->GetMethodID(javaUMPListenerClass,
					onMessageAckMethod, onMessageAckSignature);
			if (onMessageAckID == NULL) {
				U_WARN("HandleInteractAckMessage, onMessageAckID is null");
			} else {
				//U_WARN("fordbg:enter umpengine OnRelease,call CallVoidMethod");
				jstring jstrOrigsmsid = jniEnv->NewStringUTF(origsmsid.toChar());
				jstring jstrNewsmsid = jniEnv->NewStringUTF(newsmsid.toChar());
				
				jniEnv->CallVoidMethod(javaUMPListenerObject, onMessageAckID,
						result,jstrOrigsmsid,jstrNewsmsid);
				
				jniEnv->DeleteLocalRef(jstrOrigsmsid);
				jniEnv->DeleteLocalRef(jstrNewsmsid);
			}

			// Detach this thread if it was attached
			DetachJNIEnv();
		}
#else
    if(_umpEngineEventSink){
        _umpEngineEventSink->onMessageAck(origsmsid.toChar(), newsmsid.toChar());
    }
#endif

}

void UMPEngine::HandleInteractAckPhone(const Sig::Interact & interact,
		const Sig::InteractAck & ack) {
	if (0 == uppSession)
		return;

	if (!MatchGUID(interact.GetGUID()))
		return;

	if (ack.GetResult() != e_r_ok) {
		U_WARN("fordbg:HandleInteractAckPhone ,call EndCall method");
		EndCall(ack.GetResult(), e_actor_peer);

#ifdef VOIPBASE_ANDROID
		JNIEnv* jniEnv;
		bool isAttached = AttachJNIEnv(&jniEnv);
		U_WARN("fordbg:enter umpengine OnRelease,isAttached " << isAttached);
		if (isAttached) {
			onCallEndID = jniEnv->GetMethodID(javaUMPListenerClass,
					onCallEndMethod, onCallEndSignature);
			if (onCallEndID == NULL) {
				U_WARN("fordbg:enter umpengine OnRelease, onCallEndID is null");
			} else {
				U_WARN("fordbg:enter umpengine OnRelease,call CallVoidMethod");
				jniEnv->CallVoidMethod(javaUMPListenerObject, onCallEndID,
						ack.GetResult());
			}

			// Detach this thread if it was attached
			DetachJNIEnv();
		}
#else
        if(_umpEngineEventSink)
            _umpEngineEventSink->onCallEnd(ack.GetResult());
#endif

	}
}

void UMPEngine::HandleInteractAckPhoneStart(const Sig::Interact & interact,
		const Sig::InteractAck & ack) {
	if (0 == uppSession)
		return;

	if (!MatchGUID(interact.GetGUID()))
		return;

	if (ack.GetResult() != e_r_ok) {
		U_WARN("fordbg:HandleInteractAckPhoneStart ,call EndCall method");
		EndCall(ack.GetResult(), e_actor_peer);
	} else {
		UMPSignal sig_bridge;
		ack.GetBridge(sig_bridge);
		uppSession->Connect(Sig::Bridge(sig_bridge));
	}
}

void UMPEngine::HandleInteractAckPhoneStop(const Sig::Interact & interact,
		const Sig::InteractAck & ack) {
    
    {
        UMPSignal sig_bodyStop;
        interact.GetBody(sig_bodyStop);
        Sig::InteractBodyStop stop(sig_bodyStop);
        E_ResultReason stop_reason = stop.GetResult();
        
        if (stop_reason == e_r_busy)
            return;
        
        PWaitAndSignal lock(_mutex);
        
        if (0 == uppSession) {
            U_WARN("HandleInteractAckPhoneStop::0==uppSession, so return");
            return;
        }
        if (bHangup) {
            U_WARN("HandleInteractAckPhoneStop::bHangup is true,so return");
            return;
        }
        
        U_INFO("HandleInteractAckPhoneStop:set bHangup true");
        bHangup = TRUE;
        
    }
    
//	if (0 == uppSession)
//		return;

	if (!MatchGUID(interact.GetGUID()))
		return;

    U_INFO("HandleInteractAckPhoneStop  before delete uppSession");
	delete uppSession;
	uppSession = NULL;
    U_INFO("HandleInteractAckPhoneStop  end delete uppSession");

	sessionID.SetSize(0);
	peerUser = BaseUserInfo();
    
#ifdef VOIPBASE_ANDROID
    JNIEnv* jniEnv;
    bool isAttached = AttachJNIEnv(&jniEnv);
    U_WARN("fordbg:enter umpengine OnRelease,isAttached " << isAttached);
    if (isAttached) {
        onCallEndID = jniEnv->GetMethodID(javaUMPListenerClass, onCallEndMethod,
                                          onCallEndSignature);
        if (onCallEndID == NULL) {
            U_WARN("fordbg:enter umpengine OnRelease, onCallEndID is null");
        } else {
            U_WARN("fordbg:enter umpengine OnRelease,call CallVoidMethod");
            jniEnv->CallVoidMethod(javaUMPListenerObject, onCallEndID, reason);
        }
        
        // Detach this thread if it was attached
        DetachJNIEnv();
    }
#else
    if(_umpEngineEventSink)
        _umpEngineEventSink->onCallEnd((int)_releaseReason);
#endif
    
    
    {
        PWaitAndSignal lock(_mutex);
        U_INFO("HandleInteractAckPhoneStop bHangup false");
        bHangup = FALSE;
    }
}

//////////////////////////////////////////////////////////////////////
//UMPSession::UMPSEventSink Methods
void UMPEngine::OnBaseUserInfo(UMPSession & session, const BaseUserInfo & bui) {
}

void UMPEngine::OnBaseGroupInfo(UMPSession & session,
		const BaseGroupInfo& bgi) {
}

void UMPEngine::OnLogin(UMPSession & session, E_ResultReason result) {
	if (result == e_r_transportError || result == e_r_timeout
			|| result == e_r_connectFail || result == e_r_invalidAddress) {
		if (gServerList.GetServerListCount() > 0) {
			TryNextLoginServer();
			return;
		}
	}

#ifdef VOIPBASE_ANDROID
	JNIEnv* jniEnv;
	bool isAttached = AttachJNIEnv(&jniEnv);
	if (isAttached) {
		onLoginResultID = jniEnv->GetMethodID(javaUMPListenerClass,
				onLoginResultMethod, onLoginResultSignature);
		if (onLoginResultID == NULL) {
		} else {
			jniEnv->CallVoidMethod(javaUMPListenerObject, onLoginResultID,
					result);
		}

		// Detach this thread if it was attached
		DetachJNIEnv();
	}
#else
    if(_umpEngineEventSink)
        _umpEngineEventSink->onLoginResult((int)result);
#endif
}

void UMPEngine::OnLogout(UMPSession & session, E_ResultReason reason) {
    
    //EndCall(reason,e_actor_peer);

#ifdef VOIPBASE_ANDROID
	JNIEnv* jniEnv;
	bool isAttached = AttachJNIEnv(&jniEnv);
	U_WARN("fordbg:enter umpengine onLogout,isAttached " << isAttached);
	if (isAttached) {
		onLogoutID = jniEnv->GetMethodID(javaUMPListenerClass, onLogoutMethod,
				onLogoutSignature);
		if (onLogoutID == NULL) {
			U_WARN("fordbg:enter umpengine onLogout, onLogoutID is null");
		} else {
			U_WARN("fordbg:enter umpengine onLogout,call onLogoutMethod");
			jniEnv->CallVoidMethod(javaUMPListenerObject, onLogoutID, reason);
		}

		// Detach this thread if it was attached
		DetachJNIEnv();
	}
#else
    if(_umpEngineEventSink)
        _umpEngineEventSink->onLogout((int)reason);
#endif

}

void UMPEngine::OnInteractAck(UMPSession& session, const Sig::InteractAck& ack,
		const Sig::Interact& interact) {
	E_InteractType type = interact.GetType();
	if (type == e_interactType_phone)
		HandleInteractAckPhone(interact, ack);
	else if (type == e_interactType_start)
		HandleInteractAckPhoneStart(interact, ack);
	else if (type == e_interactType_stop)
		HandleInteractAckPhoneStop(interact, ack);
	else if (type == e_interactType_message)
		HandleInteractAckMessage(interact, ack);
}

void UMPEngine::OnInteract(UMPSession & session,
		const Sig::Interact& interact) {
	E_InteractType type = interact.GetType();

	switch (type) {
	case e_interactType_phone:
		HandleInteractPhone(interact);
		break;
	case e_interactType_start:
		HandleInteractPhoneStart(interact);
		break;
	case e_interactType_stop:
		HandleInteractPhoneStop(interact);
		break;
	case e_interactType_message:
		HandleInteractMessage(interact);
		break;
	default:
		break;
	}
}

void UMPEngine::OnUserInfo(UMPSession & session,
		const Sig::UserInfo& userInfo) {
}

void UMPEngine::OnServerInfo(UMPSession & session,
		const Sig::ServerInfo& serverInfo) {
	UMPSignal sig_serverInfo = serverInfo.GetSignal();
	UMPSession::SessionInfo sessionInfo = session.GetSessionInfo();

	PString serverAddr = sessionInfo.GetServerAddress().ToString();
	PString serverName = sessionInfo.GetServerName();
	PString proxyServerAddr = sessionInfo.GetUDPProxyAddress().ToString();
	PString reflectServerAddr =
			sessionInfo.GetReflectServerAddress().ToString();
	PString fxServerAddr = sessionInfo.GetFXServerAddress().ToString();
	DWORD onlineCount = serverInfo.GetOnlineCount();

	reflectServer.FromString(sessionInfo.GetReflectServerAddress().ToString(),
			defaultUDPReflectPort);

	sig_serverInfo.Set(e_ele_reflectorListener, reflectServerAddr);
	sig_serverInfo.Set(e_ele_udpProxy, proxyServerAddr);
	sig_serverInfo.Set(e_ele_fxListener, reflectServerAddr);
	sig_serverInfo.Set(e_ele_name, reflectServerAddr);
	sig_serverInfo.Set(e_ele_onlineCount, onlineCount);
}

void UMPEngine::OnUserData(UMPSession & session,
		const Sig::UserData& userData) {
}
void UMPEngine::OnUserEInfo(UMPSession & session,
		const Sig::UserEInfo& userEInfo) {
}
void UMPEngine::OnNotify(UMPSession & session, const Sig::Notify& notify) {
}

void UMPEngine::OnGetInteractCapabilities(UMPSession & session,
		CapabilityArray & caps) {
	caps.push_back(e_interactType_start);
	caps.push_back(e_interactType_stop);
	caps.push_back(e_interactType_phone);
}

void UMPEngine::OnGetLastSessionGUID(UMPSession & session, PBYTEArray & guid) {
}

void UMPEngine::OnRelatedUsers(UMPSession & session,
		const RelatedUserMap & ruis) {
}

void UMPEngine::OnUMPSTick(UMPSession & session) {
}

void UMPEngine::OnWriteRoundTrip(Sig::RoundTrip & rt) {
}

void UMPEngine::OnWriteRoundTripAck(Sig::RoundTripAck & rta) {
}

void UMPEngine::OnReadRoundTrip(const Sig::RoundTrip & rt) {
#ifdef VOIPBASE_ANDROID
	JNIEnv* jniEnv;
	bool isAttached = AttachJNIEnv(&jniEnv);
	if (isAttached) {
		onKeepAliveID = jniEnv->GetMethodID(javaUMPListenerClass,
				onKeepAliveMethod, onKeepAliveSignature);
		if (onKeepAliveID == NULL) {
		} else {
			jniEnv->CallVoidMethod(javaUMPListenerObject, onKeepAliveID);
		}

		DetachJNIEnv();
	}
#else
    if(_umpEngineEventSink)
        _umpEngineEventSink->onKeepAlive();
#endif
}

void UMPEngine::OnReadRoundTripAck(const Sig::RoundTripAck & rta) {
#ifdef VOIPBASE_ANDROID
	JNIEnv* jniEnv;
	bool isAttached = AttachJNIEnv(&jniEnv);
	if (isAttached) {
		onKeepAliveAckID = jniEnv->GetMethodID(javaUMPListenerClass,
				onKeepAliveAckMethod, onKeepAliveAckSignature);
		if (onKeepAliveAckID == NULL) {
		} else {
			jniEnv->CallVoidMethod(javaUMPListenerObject, onKeepAliveAckID);
		}

		DetachJNIEnv();
	}
#else
    if(_umpEngineEventSink)
        _umpEngineEventSink->onKeepAliveAck();
#endif
}

/////////////////////////////////////////////////////////////////////////////////
//UPPSession::UPPSEventSink Methods
void UMPEngine::OnSetup(UPPSession & upps) {
#ifdef VOIPBASE_ANDROID
	JNIEnv* jniEnv;
	bool isAttached = AttachJNIEnv(&jniEnv);
	if (isAttached) {
		onCallInID = jniEnv->GetMethodID(javaUMPListenerClass, onCallInMethod,
				onCallInSignature);
		if (onCallInID == NULL) {
		} else {
			jstring jstrRemoteCallNumber = NULL;
			jstring jstrRemoteIP = NULL;
			jstring jstrLocalIP = NULL;

			PString callNumber = peerUser.GetNumber();
			IPPort remoteAddr = upps.GetURTPWan();
//			if(!remoteAddr.IsValid()){
//				remoteAddr=upps.Get
//			}
			WORD remoteRTPPort = remoteAddr.GetPort();
			IP localIP = upps.GetLocalIP();
			WORD localRTPPort = upps.GetLocalRTPPort();
			WORD pt = upps.GetPayloadType();

			jstrRemoteCallNumber = jniEnv->NewStringUTF(callNumber.toChar());
			jstrRemoteIP = jniEnv->NewStringUTF(
					remoteAddr.GetIP().AsString().toChar());
			jstrLocalIP = jniEnv->NewStringUTF(localIP.AsString().toChar());

			jniEnv->CallVoidMethod(javaUMPListenerObject, onCallInID,
					jstrRemoteCallNumber, jstrRemoteIP, remoteRTPPort,
					jstrLocalIP, localRTPPort, pt);
			jniEnv->DeleteLocalRef(jstrRemoteCallNumber);
			jniEnv->DeleteLocalRef(jstrRemoteIP);
			jniEnv->DeleteLocalRef(jstrLocalIP);
		}
		// Detach this thread if it was attached
		DetachJNIEnv();
	}
#else
    PString callNumber = peerUser.GetNumber();
    IPPort remoteAddr = upps.GetURTPWan();
    WORD remoteRTPPort = remoteAddr.GetPort();
    IP localIP = upps.GetLocalIP();
    WORD localRTPPort = upps.GetLocalRTPPort();
    WORD pt = upps.GetPayloadType();
    if(_umpEngineEventSink)
        _umpEngineEventSink->onCallIn(callNumber.toChar(), remoteAddr.GetIP().AsString().toChar(), remoteRTPPort, localIP.AsString().toChar(), localRTPPort, pt);
#endif
}

void UMPEngine::OnAlert(UPPSession & upps) {
#ifdef VOIPBASE_ANDROID
	JNIEnv* jniEnv;
	bool isAttached = AttachJNIEnv(&jniEnv);
	if (isAttached) {
		onCallRingID = jniEnv->GetMethodID(javaUMPListenerClass,
				onCallRingMethod, onCallRingSignature);
		if (onCallRingID == NULL) {
		} else {
			jstring jstrRemoteIP = NULL;
			jstring jstrLocalIP = NULL;

			IPPort remoteAddr = upps.GetURTPWan();
			WORD remoteRTPPort = remoteAddr.GetPort();
			IP localIP = upps.GetLocalIP();
			WORD localRTPPort = upps.GetLocalRTPPort();
			WORD pt = upps.GetPayloadType();

			jstrRemoteIP = jniEnv->NewStringUTF(
					remoteAddr.GetIP().AsString().toChar());
			jstrLocalIP = jniEnv->NewStringUTF(localIP.AsString().toChar());

			jniEnv->CallVoidMethod(javaUMPListenerObject, onCallRingID,
					jstrRemoteIP, remoteRTPPort, jstrLocalIP, localRTPPort, pt);
			jniEnv->DeleteLocalRef(jstrRemoteIP);
			jniEnv->DeleteLocalRef(jstrLocalIP);
		}
		// Detach this thread if it was attached
		DetachJNIEnv();
	}
#else
    IPPort remoteAddr = upps.GetURTPWan();
    WORD remoteRTPPort = remoteAddr.GetPort();
    IP localIP = upps.GetLocalIP();
    WORD localRTPPort = upps.GetLocalRTPPort();
    WORD pt = upps.GetPayloadType();
    if(_umpEngineEventSink)
        _umpEngineEventSink->onCallRing(remoteAddr.GetIP().AsString().toChar(), remoteRTPPort, localIP.AsString().toChar(), localRTPPort, pt);
#endif
}

void UMPEngine::OnAlertAndOpenChannel(UPPSession & upps) {
#ifdef VOIPBASE_ANDROID
	JNIEnv* jniEnv;
	bool isAttached = AttachJNIEnv(&jniEnv);
	if (isAttached) {
		onCallRingAndOpenChannelID = jniEnv->GetMethodID(javaUMPListenerClass,
				onCallRingAndOpenChannelMethod,
				onCallRingAndOpenChannelSignature);
		if (onCallRingAndOpenChannelID == NULL) {
		} else {
			jstring jstrRemoteIP = NULL;
			jstring jstrLocalIP = NULL;

			IPPort remoteAddr = upps.GetURTPWan();
			WORD remoteRTPPort = remoteAddr.GetPort();
			IP localIP = upps.GetLocalIP();
			WORD localRTPPort = upps.GetLocalRTPPort();
			WORD pt = upps.GetPayloadType();

			jstrRemoteIP = jniEnv->NewStringUTF(
					remoteAddr.GetIP().AsString().toChar());
			jstrLocalIP = jniEnv->NewStringUTF(localIP.AsString().toChar());

			jniEnv->CallVoidMethod(javaUMPListenerObject,
					onCallRingAndOpenChannelID, jstrRemoteIP, remoteRTPPort,
					jstrLocalIP, localRTPPort, pt);
			jniEnv->DeleteLocalRef(jstrRemoteIP);
			jniEnv->DeleteLocalRef(jstrLocalIP);
		}
		// Detach this thread if it was attached
		DetachJNIEnv();
	}
#else
    IPPort remoteAddr = upps.GetURTPWan();
    WORD remoteRTPPort = remoteAddr.GetPort();
    IP localIP = upps.GetLocalIP();
    WORD localRTPPort = upps.GetLocalRTPPort();
    WORD pt = upps.GetPayloadType();
    if(_umpEngineEventSink)
        _umpEngineEventSink->onCallRingAndOpenChannel(remoteAddr.GetIP().AsString().toChar(), remoteRTPPort, localIP.AsString().toChar(), localRTPPort, pt);
#endif
}

void UMPEngine::OnConnect(UPPSession & upps) {
#ifdef VOIPBASE_ANDROID
	JNIEnv* jniEnv;
	bool isAttached = AttachJNIEnv(&jniEnv);
	if (isAttached) {
		onCallOKID = jniEnv->GetMethodID(javaUMPListenerClass, onCallOKMethod,
				onCallOKSignature);
		if (onCallOKID == NULL) {
		} else {
			jstring jstrRemoteIP = NULL;
			jstring jstrLocalIP = NULL;

			IPPort remoteAddr = upps.GetURTPWan();
			WORD remoteRTPPort = remoteAddr.GetPort();
			IP localIP = upps.GetLocalIP();
			WORD localRTPPort = upps.GetLocalRTPPort();
			WORD pt = upps.GetPayloadType();

			jstrRemoteIP = jniEnv->NewStringUTF(
					remoteAddr.GetIP().AsString().toChar());
			jstrLocalIP = jniEnv->NewStringUTF(localIP.AsString().toChar());

			jniEnv->CallVoidMethod(javaUMPListenerObject, onCallOKID,
					jstrRemoteIP, remoteRTPPort, jstrLocalIP, localRTPPort, pt);
			jniEnv->DeleteLocalRef(jstrRemoteIP);
			jniEnv->DeleteLocalRef(jstrLocalIP);
		}
		DetachJNIEnv();
	}
#else
    IPPort remoteAddr = upps.GetURTPWan();
    WORD remoteRTPPort = remoteAddr.GetPort();
    IP localIP = upps.GetLocalIP();
    WORD localRTPPort = upps.GetLocalRTPPort();
    WORD pt = upps.GetPayloadType();
    if(_umpEngineEventSink)
        _umpEngineEventSink->onCallOK(remoteAddr.GetIP().AsString().toChar(), remoteRTPPort, localIP.AsString().toChar(), localRTPPort, pt);
#endif
}

void UMPEngine::OnRelease(UPPSession & upps, E_ResultReason reason,
		E_Actor actor) {
	U_WARN("fordbg:enter umpengine OnRelease");
    
    {
        PWaitAndSignal lock(_mutex);
        
        if (0 == uppSession) {
            U_WARN("OnRelease::0==uppSession, so return");
            return;
        }
        if (bHangup) {
            U_WARN("OnRelease::bHangup is true,so return");
            return;
        }
        
        U_INFO("OnRelease:set bHangup true");
        bHangup = TRUE;
        
    }

	if (uppSession->GetBCStateMonitor().GetState() != BridgeChannel::e_ready) {
		//U_WARN("start StopCall");
		StopCall(peerUser, reason, sessionID);
		//U_WARN("end StopCall");
	}

//	delete uppSession;
//	uppSession = NULL;
//
//	sessionID.SetSize(0);
//	peerUser = BaseUserInfo();

//#ifdef VOIPBASE_ANDROID
//	JNIEnv* jniEnv;
//	bool isAttached = AttachJNIEnv(&jniEnv);
//	U_WARN("fordbg:enter umpengine OnRelease,isAttached " << isAttached);
//	if (isAttached) {
//		onCallEndID = jniEnv->GetMethodID(javaUMPListenerClass, onCallEndMethod,
//				onCallEndSignature);
//		if (onCallEndID == NULL) {
//			U_WARN("fordbg:enter umpengine OnRelease, onCallEndID is null");
//		} else {
//			U_WARN("fordbg:enter umpengine OnRelease,call CallVoidMethod");
//			jniEnv->CallVoidMethod(javaUMPListenerObject, onCallEndID, reason);
//		}
//
//		// Detach this thread if it was attached
//		DetachJNIEnv();
//	}
//#else
//    if(_umpEngineEventSink)
//        _umpEngineEventSink->onCallEnd((int)reason);
//#endif
    
    _releaseReason = reason;
    
    
    {
        PWaitAndSignal lock(_mutex);
        U_INFO("OnRelease:set bHangup false");
        bHangup = FALSE;
    }
    
//#ifdef VOIPBASE_ANDROID
//    JNIEnv* jniEnv;
//    bool isAttached = AttachJNIEnv(&jniEnv);
//    U_WARN("fordbg:enter umpengine OnRelease,isAttached " << isAttached);
//    if (isAttached) {
//        onCallEndID = jniEnv->GetMethodID(javaUMPListenerClass, onCallEndMethod,
//                                          onCallEndSignature);
//        if (onCallEndID == NULL) {
//            U_WARN("fordbg:enter umpengine OnRelease, onCallEndID is null");
//        } else {
//            U_WARN("fordbg:enter umpengine OnRelease,call CallVoidMethod");
//            jniEnv->CallVoidMethod(javaUMPListenerObject, onCallEndID, reason);
//        }
//        
//        // Detach this thread if it was attached
//        DetachJNIEnv();
//    }
//#else
//    if(_umpEngineEventSink)
//        _umpEngineEventSink->onCallEnd((int)reason);
//#endif
}

void UMPEngine::OnURTPTansportReady(UPPSession & upps) {
#ifdef VOIPBASE_ANDROID
	JNIEnv* jniEnv;
	bool isAttached = AttachJNIEnv(&jniEnv);
	if (isAttached) {
		onURTPReadyID = jniEnv->GetMethodID(javaUMPListenerClass,
				onURTPReadyMethod, onURTPReadySignature);
		if (onURTPReadyID == NULL) {
		} else {
			jstring jstrRemoteIP = NULL;
			jstring jstrLocalIP = NULL;

			IPPort remoteAddr = upps.GetURTPWan();
			WORD remoteRTPPort = remoteAddr.GetPort();
			IP localIP = upps.GetLocalIP();
			WORD localRTPPort = upps.GetLocalRTPPort();
			WORD pt = upps.GetPayloadType();

			jstrRemoteIP = jniEnv->NewStringUTF(
					remoteAddr.GetIP().AsString().toChar());
			jstrLocalIP = jniEnv->NewStringUTF(localIP.AsString().toChar());

			jniEnv->CallVoidMethod(javaUMPListenerObject, onURTPReadyID,
					jstrRemoteIP, remoteRTPPort, jstrLocalIP, localRTPPort, pt);
			jniEnv->DeleteLocalRef(jstrRemoteIP);
			jniEnv->DeleteLocalRef(jstrLocalIP);
		}
		DetachJNIEnv();
	}
#else
    IPPort remoteAddr = upps.GetURTPWan();
    WORD remoteRTPPort = remoteAddr.GetPort();
    IP localIP = upps.GetLocalIP();
    WORD localRTPPort = upps.GetLocalRTPPort();
    WORD pt = upps.GetPayloadType();
    if(_umpEngineEventSink)
        _umpEngineEventSink->onURTPReady(remoteAddr.GetIP().AsString().toChar(), remoteRTPPort, localIP.AsString().toChar(), localRTPPort, pt);
#endif
}

void UMPEngine::OnStartVoice(UPPSession & upps, E_ChannelCapability cap) {
#ifdef VOIPBASE_ANDROID
	JNIEnv* jniEnv;
	bool isAttached = AttachJNIEnv(&jniEnv);
	if (isAttached) {
		onStartVoiceID = jniEnv->GetMethodID(javaUMPListenerClass,
				onStartVoiceMethod, onStartVoiceSignature);
		if (onStartVoiceID == NULL) {
		} else {
			jstring jstrRemoteIP = NULL;
			jstring jstrLocalIP = NULL;

			IPPort remoteAddr = upps.GetURTPWan();
			WORD remoteRTPPort = remoteAddr.GetPort();
			IP localIP = upps.GetLocalIP();
			WORD localRTPPort = upps.GetLocalRTPPort();
			WORD pt = upps.GetPayloadType();

			jstrRemoteIP = jniEnv->NewStringUTF(
					remoteAddr.GetIP().AsString().toChar());
			jstrLocalIP = jniEnv->NewStringUTF(localIP.AsString().toChar());

			jniEnv->CallVoidMethod(javaUMPListenerObject, onStartVoiceID,
					jstrRemoteIP, remoteRTPPort, jstrLocalIP, localRTPPort, pt);
			jniEnv->DeleteLocalRef(jstrRemoteIP);
			jniEnv->DeleteLocalRef(jstrLocalIP);
		}
		DetachJNIEnv();
	}
#else
    IPPort remoteAddr = upps.GetURTPWan();
    WORD remoteRTPPort = remoteAddr.GetPort();
    IP localIP = upps.GetLocalIP();
    WORD localRTPPort = upps.GetLocalRTPPort();
    WORD pt = upps.GetPayloadType();
    if(_umpEngineEventSink)
        _umpEngineEventSink->onStartVoice(remoteAddr.GetIP().AsString().toChar(), remoteRTPPort, localIP.AsString().toChar(), localRTPPort, pt);
#endif
}

void UMPEngine::OnStopVoice(UPPSession & upps, E_ChannelCapability cap) {
#ifdef VOIPBASE_ANDROID
	JNIEnv* jniEnv;
	bool isAttached = AttachJNIEnv(&jniEnv);
	if (isAttached) {
		onStopVoiceID = jniEnv->GetMethodID(javaUMPListenerClass,
				onStopVoiceMethod, onStopVoiceSignature);
		if (onStopVoiceID == NULL) {
		} else {
			jniEnv->CallVoidMethod(javaUMPListenerObject, onStopVoiceID);
		}

		DetachJNIEnv();
	}
#else
    if(_umpEngineEventSink)
        _umpEngineEventSink->onStopVoice();
#endif
}

void UMPEngine::OnDTMF(UPPSession & upps, const PString& dtmf, PBOOL inband) {
}

void UMPEngine::OnForwardTo(UPPSession & upps, const BaseUserInfo& to) {
}

void UMPEngine::OnDurationLimit(UPPSession & upps, DWORD second) {
}

void UMPEngine::OnGetCodecCapabilities(UPPSession & upps,
		ChannelCapabilityArray & caps) {
	caps.push_back(e_chc_g729);
	//caps.push_back(e_chc_g711a);
	//caps.push_back(e_chc_g711u);
}

void UMPEngine::OnUPPSTick(UPPSession & upps) {
}

void UMPEngine::ForceEndCall(UMPSession & session,E_ResultReason reason){
    UMPSignal sig_interact(e_sig_interact);
    Sig::Interact interact(sig_interact);
    
    
    UMPSignal sig_body;
    Sig::InteractBodyStop body(sig_body);
    body.SetResult(reason);
    
    interact.SetBody(sig_body);
    
    {
        PWaitAndSignal lock(_mutex);
        U_INFO("ForceEndCall:set bHangup false");
        bHangup = FALSE;
    }
    
    HandleInteractPhoneStop(interact,true);
}

#ifdef VOIPBASE_ANDROID
bool UMPEngine::AttachJNIEnv(JNIEnv** jniEnv) {
	bool isAttached = false;
	if (gJNIVM->GetEnv((void**) jniEnv, JNI_VERSION_1_4) != JNI_OK) {
		if (JNI_OK != gJNIVM->AttachCurrentThread(jniEnv, NULL)) {
		} else if (*jniEnv != NULL) {
			isAttached = true;
		}
	}
	return isAttached;
}

void UMPEngine::DetachJNIEnv() {
	if (gJNIVM->DetachCurrentThread() < 0) {
	}
}
#endif
