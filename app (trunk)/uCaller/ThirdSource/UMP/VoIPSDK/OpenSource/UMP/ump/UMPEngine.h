//
//  UMPEngine.h
//  UMPStack
//
//  Created by thehuah on 14-3-13.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__UMPEngine__
#define __UMPStack__UMPEngine__

#include "Session/ump_session.h"
#include "Session/upp_session.h"

#include "URTP/urtp_encryption.h"

#ifdef VOIPBASE_ANDROID
#include <jni.h>


#define UMPListenerClass "com/cvtt/voipbase/UMPListener"

#define onLoginResultMethod "onLoginResult"
#define onLoginResultSignature "(I)V"

//String number,String remoteIP,short remotePort,String localIP,short localPort,int pt
#define onCallInMethod "onCallIn"
#define onCallInSignature "(Ljava/lang/String;Ljava/lang/String;SLjava/lang/String;SS)V"

#define onCallRingMethod "onCallRing"
#define onCallRingSignature "(Ljava/lang/String;SLjava/lang/String;SS)V"

#define onCallRingAndOpenChannelMethod "onCallRingAndOpenChannel"
#define onCallRingAndOpenChannelSignature "(Ljava/lang/String;SLjava/lang/String;SS)V"

#define onCallOKMethod "onCallOK"
#define onCallOKSignature "(Ljava/lang/String;SLjava/lang/String;SS)V"

#define onCallEndMethod "onCallEnd"
#define onCallEndSignature "(I)V"

#define onURTPReadyMethod "onURTPReady"
#define onURTPReadySignature "(Ljava/lang/String;SLjava/lang/String;SS)V"

#define onStartVoiceMethod "onStartVoice"
#define onStartVoiceSignature "(Ljava/lang/String;SLjava/lang/String;SS)V"

#define onStopVoiceMethod "onStopVoice"
#define onStopVoiceSignature "()V"

#define onKeepAliveMethod "onKeepAlive"
#define onKeepAliveSignature "()V"

#define onKeepAliveAckMethod "onKeepAliveAck"
#define onKeepAliveAckSignature "()V"

#define onLogoutMethod "onLogout"
#define onLogoutSignature "(I)V"

#define onMessageMethod "onReceivedMessage"
#define onMessageSignature "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"

#define onMessageAckMethod "onReceivedMessageAck"
#define onMessageAckSignature "(SLjava/lang/String;Ljava/lang/String;)V"

#endif


//using namespace std;

class UMPEngine : public UMPSession::UMPSEventSink,public UPPSession::UPPSEventSink
{
protected:
    UMPEngine();
    
public:
    static UMPEngine *getUMPEngine();
    
    virtual ~UMPEngine();
    
#ifdef VOIPBASE_ANDROID
    void SetJNIObjects(JavaVM* jvm, JNIEnv* env);
#endif

    bool Start();
    void Stop();
    
    void AddServer(const char* server,bool clear);
    void SetClientInfo(const char* localIP,const char* mac,const char* osinfo);
    int Login(const char* user,const char* password,const char* server);
    void Logout(PBOOL async = TRUE);
    
    void Call(const char* number);
    void ResetUppSession();
    void SendMsg(const char* to_uid, const char* to_number,const char* content,const char * origsmsid,int contenttype);
    void AnswerCall();
    void RefuseCall();
    void EndCall(E_ResultReason reason = e_r_interrupted, E_Actor actor = e_actor_self);
    void SendDTMF(const char* dtmf);
    
    void SetAutoKeepAlive(int sec);
    void KeepAlive();

private:
    bool MatchGUID(const PBYTEArray & guid) const;
    void CreateSession(bool master);
    void TryNextLoginServer();
    void SetPeerUser(const BaseUserInfo &bui);
    
    void StartCall(const BaseUserInfo & to,const PString & peerIP,const PBYTEArray & guid);
    void StopCall(const BaseUserInfo & to,E_ResultReason r,const PBYTEArray & guid);

    void HandleInteractPhone(const Sig::Interact & interact);
    void HandleInteractPhoneStart( const Sig::Interact & interact);
    void HandleInteractPhoneStop( const Sig::Interact & interact,bool force=false);
    void HandleInteractMessage(const Sig::Interact & interact);
    void HandleInteractAckPhone(const Sig::Interact & interact,const Sig::InteractAck & ack);
    void HandleInteractAckPhoneStart(const Sig::Interact & interact,const Sig::InteractAck & ack);
    void HandleInteractAckPhoneStop(const Sig::Interact & interact,const Sig::InteractAck & ack);
    void HandleInteractAckMessage(const Sig::Interact & interact,const Sig::InteractAck & ack);
    
    //UMPSession::UMPSEventSink Methods
private:
    void OnBaseUserInfo(UMPSession & session, const BaseUserInfo & bui);
    void OnBaseGroupInfo(UMPSession & session,const BaseGroupInfo& bgi);
    
    void OnLogin(UMPSession & session,E_ResultReason result);
    void OnLogout(UMPSession & session, E_ResultReason reason);
    void OnInteractAck(
                       UMPSession& session,
                       const Sig::InteractAck& ack,
                       const Sig::Interact& interact);
    
    void OnInteract(UMPSession & session,const Sig::Interact& interact);
    void OnUserInfo(UMPSession & session,const Sig::UserInfo& userInfo);
    void OnServerInfo(UMPSession & session,const Sig::ServerInfo& serverInfo);
    void OnUserData(UMPSession & session,const Sig::UserData& userData);
    void OnUserEInfo(UMPSession & session,const Sig::UserEInfo& userEInfo);
    void OnNotify(UMPSession & session,const Sig::Notify& notify);
    
    void OnGetInteractCapabilities(UMPSession & session,CapabilityArray & caps);
    void OnGetLastSessionGUID(UMPSession & session, PBYTEArray & guid);
    
    void OnRelatedUsers(UMPSession & session,const RelatedUserMap & ruis);
    void OnUMPSTick(UMPSession & /*session*/);
    
    void OnWriteRoundTrip(Sig::RoundTrip & rt);
    void OnWriteRoundTripAck(Sig::RoundTripAck & rta);
    
    void OnReadRoundTrip(const Sig::RoundTrip & rt);
    void OnReadRoundTripAck(const Sig::RoundTripAck & rta);
    
    void ForceEndCall(UMPSession & session,E_ResultReason reason);
    
    //UPPSession::UPPSEventSink Methods
private:
    void OnSetup(UPPSession & upps);
    void OnAlert(UPPSession & upps);
    void OnAlertAndOpenChannel(UPPSession & upps);
    void OnConnect(UPPSession & upps);
    void OnRelease(UPPSession & upps,E_ResultReason reason,E_Actor actor);
    void OnDTMF(UPPSession & upps,const PString& dtmf, PBOOL inband);
    void OnForwardTo(UPPSession & upps,const BaseUserInfo& to);
    void OnDurationLimit(UPPSession & upps,DWORD second);
    void OnGetCodecCapabilities(UPPSession & upps,ChannelCapabilityArray & caps);
    
    void OnURTPTansportReady(UPPSession & upps);
    void OnStartVoice(UPPSession & upps,E_ChannelCapability cap);
    void OnStopVoice(UPPSession & upps,E_ChannelCapability cap);
    
    void OnUPPSTick(UPPSession & upps);
    
#ifdef VOIPBASE_ANDROID
    bool AttachJNIEnv(JNIEnv** jniEnv);
    void DetachJNIEnv();
#endif

private:
    static UMPEngine *umpEngine;
    
    UMPSession *umpSession;
    UPPSession *uppSession;
    
    URTPEncryption *urtpEncryption;

    PString strUserID;
    PString strUserName;
    PString strUserNumber;
    PString strUserPassword;
    PString strServer;
    
    IPPort reflectServer;
    int nPort;
    
    BaseUserInfo peerUser;
    PBYTEArray sessionID;
    
    PMutex _mutex;
    PBOOL bHangup;
    
    E_ResultReason _releaseReason;
    
#ifdef VOIPBASE_ANDROID
    JavaVM* gJNIVM;
    JNIEnv* gJNIEnv;
    jclass javaUMPListenerClass;
    jobject javaUMPListenerObject;

    jmethodID onLoginResultID;
    jmethodID onCallInID;
    jmethodID onCallRingID;
    jmethodID onCallRingAndOpenChannelID;
    jmethodID onCallOKID;
    jmethodID onCallEndID;
    jmethodID onURTPReadyID;
    jmethodID onStartVoiceID;
    jmethodID onStopVoiceID;
    jmethodID onKeepAliveID;
    jmethodID onKeepAliveAckID;
    jmethodID onLogoutID;
    jmethodID onMessageID;
    jmethodID onMessageAckID;
#else
public:
    class UMPEngineEventSink{
    public:
        UMPEngineEventSink(){};
        ~UMPEngineEventSink(){};
    public:
        virtual void onLoginResult(int code) = 0;
        virtual void onLogout(int code) = 0;
        virtual void onCallIn(const char * number,const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt) = 0;
        virtual void onCallRing(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt) = 0;
        virtual void onCallRingAndOpenChannel(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt) = 0;
        virtual void onCallOK(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt) = 0;
        virtual void onCallEnd(int code) = 0;
        virtual void onURTPReady(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt) = 0;
        virtual void onKeepAlive() = 0;
        virtual void onKeepAliveAck() = 0;
        virtual void onStartVoice(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt) = 0;
        virtual void onStopVoice() = 0;
        
        virtual void onMessage(const char * fromuid,const char * fromnumber,const char * content) = 0;
        virtual void onMessageAck(const char * origsmsid,const char * newsmsid) = 0;
        //        jmethodID onStartVoiceID;
        //        jmethodID onStopVoiceID;
        //
        //        jmethodID onMessageID;
        //        jmethodID onMessageAckID;
    };
    
    void SetEventSink(UMPEngineEventSink* eventSink) {_umpEngineEventSink=eventSink;};
private:
    UMPEngineEventSink* _umpEngineEventSink;
#endif
};

#endif /* defined(__UMPStack__UMPEngine__) */
