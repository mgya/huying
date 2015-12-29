//
//  ump_session.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__ump_session__
#define __UMPStack__ump_session__

#include "ump_handler.h"

class UMPSession :
public UMPHandlerBase,
public UMPHandlerBase::UHEventSink,
public AsyncNameResolver::ANREventSink
{
	PCLASSINFO(UMPSession, UMPHandlerBase);
    
public:
    
	enum E_ClientState {
		e_offline,
		e_online,
		e_login,
		e_pologin
	};
    
	class UCSStateMonitor: public UMPHandlerBase::StateMonitor<E_ClientState>
	{
		PCLASSINFO(UCSStateMonitor,StateMonitor<E_ClientState>);
	public:
		UCSStateMonitor();
		PBOOL Filter(UMPHandlerBase & handler,UMPSignal & signal);
        
		PINLINE void SetGotFirstSignal(PBOOL got){_gotFirstSignal = got;}
		PINLINE PBOOL HasGotFirstSignal() const{return _gotFirstSignal;}
        
		PINLINE Timeout & GetLoginTimeout(){return _loginTimeout;}
	private:
		PBOOL _gotFirstSignal;
		Timeout _loginTimeout;
		
	};
    
	class UserInfo
	{
	public:
		UserInfo();
        
		void Reset();
        
		BaseUserInfo GetBaseUserInfo() const;
        
		PString GetPasswordMD5Hex() const;
		void SetPasswordMD5Hex(const PString & passwd);
        
		double GetBalance() const;
        
		IP GetCurrentLoginIP() const;
        
		UMPSignal GetUserInfo() const;
		void SetUserInfo(const UMPSignal & userInfo);
        
	private:
        
		PString _passwordMD5Hex;
		mutable UMPSignal _sig_userInfo;
		
		PMutex _mutex;
        
	};
    
	class SessionInfo
	{
	public:
		SessionInfo();
        
		void Reset();
		
        
		PBYTEArray GetGUID() const;
		void SetGUID(const PBYTEArray & guid);
        
		PBYTEArray GetKey() const;
		void SetKey(const PBYTEArray & key);
        
		PString GetUpdateURL() const;
		void SetUpdateURL(const PString & updateURL);
        
        
		IPPort GetReflectServerAddress() const;
		void SetReflectServerAddress(const IPPort & address);
        
		IPPort GetUDPProxyAddress() const;
		void SetUDPProxyAddress(const IPPort & address);
        
		IPPort GetServerAddress() const;
		void SetServerAddress(const IPPort & address);
        
		IPPort GetFXServerAddress() const;
		void SetFXServerAddress(const IPPort & address);
        
		PString GetServerName() const;
		void SetServerName(const PString & name);
        
		DWORD GetServerOnlineCount() const {return _serverOnlineCount;}
		void SetServerOnlineCount(DWORD count){_serverOnlineCount = count;}
	private:
        
		
		PBYTEArray _guid;
		PBYTEArray _key;
		PString _serverName;
        
		IPPort _serverAddress;
		IPPort _udpReflectorAddress;
		IPPort _udpProxyAddress;
        
		IPPort _fxServerAddress;
		
		PString _updateURL;
        
		DWORD _serverOnlineCount;
        
		PMutex _mutex;
        
	};
    
	
	class InteractCopyMap
	{
	public:
		class InteractCopy
		{
		public:
			InteractCopy();
			
			UMPSignal _sigInteract;
			Timeout _timeout;
			
		};
        
	public:
		typedef std::map< DWORD,InteractCopy> Map;
		typedef std::vector<UMPSignal> Array;
		
        
		InteractCopyMap();
		virtual ~InteractCopyMap();
        
		void Clear();
        
		PBOOL Exist(DWORD seq);
        
		void Add(DWORD seq, const UMPSignal & interact);
		PBOOL Remove(DWORD seq,UMPSignal & interact);
		void Remove(DWORD seq);
        
		void GetTimeout(Array & l);
	private:
		
		Map _map;
		PMutex _mapMutex;
        
	};
    
	class UMPSEventSink
	{
	public:
        //UMPSEventSink(){}
		virtual ~UMPSEventSink(){}
	public:
		virtual void OnBaseUserInfo(UMPSession & session, const BaseUserInfo & bui) = 0;
		virtual void OnBaseGroupInfo(UMPSession & session,const BaseGroupInfo& bgi) = 0;
        
		virtual void OnLogin(UMPSession & session,E_ResultReason result) = 0;
		virtual void OnLogout(UMPSession & session, E_ResultReason reason) = 0;
		virtual void OnInteractAck(
                                   UMPSession& session,
                                   const Sig::InteractAck& ack,
                                   const Sig::Interact& interact) = 0;
        
		virtual void OnInteract(UMPSession & session,const Sig::Interact& interact) = 0;
		virtual void OnUserInfo(UMPSession & session,const Sig::UserInfo& userInfo) = 0;
		virtual void OnServerInfo(UMPSession & session,const Sig::ServerInfo& serverInfo) = 0;
		virtual void OnUserData(UMPSession & session,const Sig::UserData& userData) = 0;
		virtual void OnUserEInfo(UMPSession & session,const Sig::UserEInfo& userEInfo) = 0;
		virtual void OnNotify(UMPSession & session,const Sig::Notify& notify) = 0;
		
		virtual void OnGetInteractCapabilities(UMPSession & session,CapabilityArray & caps) = 0;
		virtual void OnGetLastSessionGUID(UMPSession & session, PBYTEArray & guid) = 0;
		
		virtual void OnRelatedUsers(UMPSession & session,const RelatedUserMap & ruis) = 0;
		virtual void OnUMPSTick(UMPSession & session) = 0;
        
		virtual void OnWriteRoundTrip(Sig::RoundTrip & rt) = 0;
		virtual void OnWriteRoundTripAck(Sig::RoundTripAck & rta) = 0;
        
		virtual void OnReadRoundTrip(const Sig::RoundTrip & rt) = 0;
		virtual void OnReadRoundTripAck(const Sig::RoundTripAck & rta) = 0;
        
        //added by liyr 2015-12-03
        virtual void OnForwardTo(const PStringArray& forwardList) = 0;
        //added by liyr 2015-12-03
        
        virtual void ForceEndCall(UMPSession & session,E_ResultReason reason) = 0;
	};
    
    
    
public:
    
	UMPSession(E_ClientType type,UMPSEventSink & eventSink);
	virtual ~UMPSession();
    
	E_ClientType GetType() const{return _type;}
    
	void SetClientInfo(const char* localIP,const char* mac,const char* osinfo);
	//  ump://alias:pass@host:port/?force=0
	//  ump://#id:pass@host:port/?force=0
	E_ResultReason Login(
                         const PString & url);
    
	E_ResultReason Login(
                         const PString& server,
                         const PString& passwd,
                         const BaseUserInfo& bui,
                         PBOOL force = FALSE,
                         PBOOL lastForward = FALSE
                         );
    
	PBOOL Logout(E_ResultReason reason = e_r_ok, PBOOL async = TRUE);
    
    
	PBOOL SetSubState(E_UserSubState subState, const PString& description = "");
    
    //added by liyr 2015-12-03
    PBOOL SendMessageAck(const UMPSignal & body, const time_t & time);
    //added by liyr 2015-12-03
    
	PBOOL FetchTempInteract();
	PBOOL FetchTempNotify();
    
	PBOOL AddRelatedUser(
                        const BaseUserInfo & rbui,
                        const BaseGroupInfo & bgi,
                        const PString & comment = "");
	
	PBOOL RemoveRelatedUser(const BaseUserInfo & rbui);
	PBOOL ModifyRelatedUser(
                           const BaseUserInfo & rbui,
                           const BaseGroupInfo & bgi,
                           const BaseGroupInfo & newBgi);
	
	PBOOL FetchRelatedUsers();
    
	PBOOL FetchBaseUserInfo(const BaseUserInfo & bui);
    
	PBOOL FetchBaseGroupInfo(const BaseGroupInfo & bgi);
	
    
	PBOOL FetchUserData(const PUInt64 & userId, const PString & key, DWORD type);
	PBOOL SetUserData(const PString & key,const PString& dataBlock, DWORD type, PBOOL shared);
    
	PBOOL Interact(
                  const BaseUserInfo& to,
                  const BaseUserInfo& from,
                  const UMPSignal& body,
                  E_InteractType type,
                  const PBYTEArray& guid,
                  PBOOL serviceFlag = FALSE);
    
	PBOOL FetchUserEInfo(const PString & userNumber, const PString & calleeNumber, const PString & callSessionId); //»°µ√”√ªß¿©’πµƒ–≈œ¢
    
    
protected:
	void OnReadSignal(UMPHandlerBase & handler,UMPSignal* signal,PBOOL & noDelete);
	void OnReadBinary(UMPHandlerBase & handler,const void* bin, PINDEX size);
	
	
	void OnTransportError(UMPHandlerBase & handler);
	void OnProtocolError(UMPHandlerBase & handler);
	PBOOL OnFilter(UMPHandlerBase & handler,UMPSignal& signal);
	
	void OnConnect(UMPHandlerBase & handler, PChannel::Errors result);
	void OnTick(UMPHandlerBase & handler);
protected:
	void OnReadable(SocketBase & socket,PBYTEArray& sharedBuffer);
	void OnGotBlock(void* block, PINDEX blockSize);
    
	void OnWriteRoundTrip(Sig::RoundTrip & rt);
	void OnWriteRoundTripAck(Sig::RoundTripAck & rta);
    
	void OnReadRoundTrip(const Sig::RoundTrip & rt);
	void OnReadRoundTripAck(const Sig::RoundTripAck & rta);
protected:
	virtual void OnResolved(
                            AsyncNameResolver & anr,
                            PBOOL success,
                            const AsyncNameResolver::Param & param,
                            const IPPort & addr);
protected:
    
	PBOOL HandleLoginAck(const Sig::LoginAck & loginAck);
	PBOOL HandlePologinAck(const Sig::PologinAck & pologinAck);
	PBOOL HandleInteractAck(const Sig::InteractAck & interactAck);
	PBOOL HandleInteract(const Sig::Interact & interact);
	PBOOL HandleNotify(const Sig::Notify & notify);
	PBOOL HandleRelatedUsers(const Sig::RelatedUsers & relatedUsers);
	PBOOL HandleBaseUserInfo(const Sig::BaseUserInfo & baseUserInfo);
	PBOOL HandleBaseGroupInfo(const Sig::BaseGroupInfo & baseGroupInfo);
	PBOOL HandleServerInfo(const Sig::ServerInfo & serverInfo);
	PBOOL HandleUserInfo(const Sig::UserInfo & userInfo);
	PBOOL HandleUserData(const Sig::UserData & userData);
	PBOOL HandleUserEInfo(const Sig::UserEInfo & userEInfo);
    
protected:
	void InternalLogout(E_ResultReason reason);
	void Reset();
public:
	const UCSStateMonitor & GetStateMonitor() const{return _stateMonitor;}
	const SessionInfo & GetSessionInfo() const{return _sessionInfo;}
	const UserInfo & GetUserInfo() const{return _userInfo;}

protected:
	PMutex _transportMutex;
private:
	const E_ClientType _type;
	UMPSignal _sig_login;	
    
	UMPSignal _clientInfo;
	UserInfo _userInfo;
	SessionInfo _sessionInfo;
    
	UCSStateMonitor _stateMonitor;
	UMPSEventSink & _umpsEventSink;
    
	InteractCopyMap _interactCopyMap;
	UMPSequenceNumber _interactSequenceNumber;
    
	PBOOL _externalLogouted;
	E_ResultReason _externalLogoutReason;
    
	PString _serverNameToResove;
	AsyncNameResolver _asyncNameResolver;
#if defined(VOIPBASE_IOS) || defined(VOIPBASE_MAC)
    CFReadStreamRef    readStream;
    CFWriteStreamRef   writeStream;
    PBOOL _streamIsOpened;
#endif
};

#endif /* defined(__UMPStack__ump_session__) */
