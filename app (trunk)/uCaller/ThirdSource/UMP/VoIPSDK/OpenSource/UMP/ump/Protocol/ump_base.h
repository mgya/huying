//
//  ump_base.h
//  UMPStack
//
//  Created by thehuah on 14-3-5.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef UMP_BASE_H
#define UMP_BASE_H

#include "sig_tag.h"
#include <map>


#define MAX_BLOCK_LEN (65535-16)


///////////////////
#define defaultUMPPort					((WORD)1800)
#define defaultInterServerPort			((WORD)1900)
#define defaultNeighborPort				((WORD)2000)
#define defaultBridgePort				((WORD)1440)
#define defaultUDPReflectPort			((WORD)1890)
#define defaultUDPProxyPort				((WORD)1892)
#define defaultFXPort					((WORD)1430)


#define ump_version						((DWORD)7) //modified by liyr 2015-12-03 ump_version 6->7
#define upp_version						((DWORD)6)

#define uip_verson						((DWORD)2)


//typedef std::map< PUInt64,PUInt64> RelatedUserId2GroupId;


//typedef std::map< PUInt64,RelatedUserId2GroupId> UserId2RelatedUsers;

//<groupid, < <ruserid, full-related> > >
//typedef std::map<PUInt64, std::vector<std::pair<PUInt64, PBOOL> > > GroupId2RelatedUsers;
//typedef std::map< PUInt64, std::vector<PUInt64> > GroupId2RelatedUsers;


class UMPUtility
{
public:
	static PBOOL LimitString(PString& str, PINDEX limit);
    
	static PBOOL IsDigits(const PString& str);
	static PBOOL IsValidUserName(const PString& str);
    
};


class UMPSequenceNumber
{
public:
	UMPSequenceNumber();
	virtual ~UMPSequenceNumber();
    
	DWORD Next();
protected:
    int _number;
};

/** UMP Signal based on key-value.
 The key is integer, and the value is string.
 */
class UMPSignal : public PObject
{
	PCLASSINFO(UMPSignal, PObject);
public:
	UMPSignal(E_UMPTag tag = e_ele_null);
	UMPSignal(const UMPSignal& other);
	virtual ~UMPSignal();
    
	PString ToString() const;
	PBOOL FromString(const PString& str);
    
	PBOOL Get(E_UMPTag elemTag, PString& elem) const;
	PBOOL Get(E_UMPTag elemTag, char& elem) const;
	PBOOL Get(E_UMPTag elemTag, BYTE& elem) const;
	PBOOL Get(E_UMPTag elemTag, short& elem) const;
	PBOOL Get(E_UMPTag elemTag, WORD& elem) const;
	PBOOL Get(E_UMPTag elemTag, int& elem) const;
	PBOOL Get(E_UMPTag elemTag, DWORD& elem) const;
	PBOOL Get(E_UMPTag elemTag, double& elem) const;
	PBOOL Get(E_UMPTag elemTag, PBYTEArray& elem) const;
	PBOOL Get(E_UMPTag elemTag, UMPSignal& elem) const;
	PBOOL Get(E_UMPTag elemTag, PUInt64& elem) const;
	PBOOL Get(E_UMPTag elemTag, PInt64& elem) const;
    
	void Set(E_UMPTag elemTag, const PString& elem);
	void Set(E_UMPTag elemTag, char			elem);
	void Set(E_UMPTag elemTag, BYTE			elem);
	void Set(E_UMPTag elemTag, short			elem);
	void Set(E_UMPTag elemTag, WORD			elem);
	void Set(E_UMPTag elemTag, int				elem);
	void Set(E_UMPTag elemTag, DWORD			elem);
	void Set(E_UMPTag elemTag, double			elem);
	void Set(E_UMPTag elemTag, const PBYTEArray& elem);
	void Set(E_UMPTag elemTag, const UMPSignal& elem);
	void Set(E_UMPTag elemTag, const PUInt64		&	elem);
	void Set(E_UMPTag elemTag, const PInt64		&	elem);
    
	PBOOL GetAt(PINDEX i , E_UMPTag & key, PString & value) const;
    
	PBOOL Remove(E_UMPTag elemTag);
	PBOOL Exist(E_UMPTag elemTag) const;
	void Clear();
    
	virtual PBOOL Encode(PBYTEArray& buffer) const;
	virtual PBOOL Encode(void* buffer, PINDEX& len) const;
    
	virtual PBOOL Decode(const PBYTEArray& buffer);
	virtual PBOOL Decode(const void* buffer, PINDEX len);
    
	E_UMPTag GetTag() const;
	void SetTag(E_UMPTag tag);
    
	PString GetTagName() const;
    
	DWORD GetSize() const{return _size;}
    
	virtual void PrintOn(ostream& strm) const;
    
protected:
	void InternalSet(E_UMPTag elemTag, const PString & str);
	void InternalEncode(void* buffer) const;
	DWORD CalcSize() const;
	DWORD CalcTagSize(E_UMPTag tag) const;
protected:
	E_UMPTag _tag;
	typedef std::map<E_UMPTag, PString> Map;
	Map _map;
	DWORD _size;
};


class UserSubState
{
public:
	UserSubState(const UMPSignal& signal);
	UserSubState(
                 E_UserSubState sstate,
                 E_ClientType ctype,
                 const PString& desc);
    
	UserSubState();
	virtual ~UserSubState();
    
	virtual PBOOL GetFromSignal(const UMPSignal& signal);
	virtual PBOOL SetToSignal(UMPSignal& signal) const;
    
	E_UserSubState GetSubState() const{	return _subState;}
	void SetSubState(E_UserSubState state){	_subState = state;}
    
	E_ClientType GetClientType() const{return _clientType;}
	void SetClientType(E_ClientType type){_clientType = type;}
    
	const PString & GetDescription() const{return _description;}
	void SetDescription(const PString & desc){_description = desc;}
    
protected:
    
	E_UserSubState _subState;
	E_ClientType _clientType;
	PString _description;
};
/////////////////
class BaseUserInfo
{
public:
	BaseUserInfo();
	BaseUserInfo(const UMPSignal& signal);
    
	BaseUserInfo(const BaseUserInfo& other);
	BaseUserInfo(const PUInt64 & uid, const PString& uname, const PString& unumber,const PUInt64 & cid=0,const PUInt64 & aid=0);//modified by liyr 2015-12-03
    
	virtual ~BaseUserInfo();
    
    
	PBOOL GetFrom(const UMPSignal& signal);
	PBOOL SetTo(UMPSignal& signal) const;
    
	void MakeSimple();
    
	const PUInt64 & GetID() const{return _id;}
	void SetID( const PUInt64 & id){_id = id;}
    
	const PString & GetName() const{return _name;}
	void SetName(const PString & name);
	
	const PString & GetNumber() const{return _number;}
	void SetNumber(const PString & number);
    
    //added by liyr 2015-12-03
    const PUInt64 & GetCID() const{return _cid;}
    void SetCID( const PUInt64 & cid){_cid = cid;}
    
    const PUInt64 & GetAID() const{return _aid;}
    void SetAID( const PUInt64 & aid){_aid = aid;}
    //added by liyr 2015-12-03
    
	PBOOL IsFull() const;
protected:
	PUInt64 _id;
	PString _name; //
	PString _number;
    //added by liyr 2015-12-03
    PUInt64 _cid;
    PUInt64 _aid;
    //added by liyr 2015-12-03
};

PSCALAR_ARRAY(UInt64Array, PUInt64);

//////////////////

class BaseGroupInfo
{
public:
	BaseGroupInfo();
	BaseGroupInfo(const UMPSignal& signal);
	BaseGroupInfo(const PUInt64 & gid, const PString& gname);
    
	virtual ~BaseGroupInfo();
	PBOOL GetFrom(const UMPSignal& signal);
	PBOOL SetTo(UMPSignal& signal) const;
    
	const PUInt64 & GetID() const{return _id;}
	void SetID(const PUInt64 & id){_id = id;}
    
	const PString & GetName() const{return _name;}
	void SetName(const PString & name);
    
	PBOOL IsFull() const;
private:
	PUInt64 _id;
	PString _name;
};

/////////////


class ForwardData
{
public:
	ForwardData()
    :_enable(FALSE)
	{
		
	}
	
    
	BaseUserInfo _bui;
	PBOOL _enable;
};

//////////////////

class UserData
{
public:
	UserData()
    :_shared(FALSE)
	{
		
	}
	
	PBOOL _shared;
	PString _dataBlock;
};


//////////////////

class BaseUserStatusInfo
{
public:
	BaseUserStatusInfo();
	BaseUserStatusInfo(const BaseUserStatusInfo& other);
	
	const PUInt64 & GetUID() const{return _uid;}
	
public:
	PUInt64 _uid;
	PString _sguid;
	time_t _loginTime;
	time_t _lastLoginTime;
	PString _loginIP;
	PString _lastLoginIP;
	PString _server;
	DWORD _serverID;
	PString _lastServer;
	DWORD _onlineTime;
	DWORD _loginCount;
	DWORD _curOnlineTime; // ±æ¥Œµ«¬º‘⁄œﬂ ±º‰
    
	DWORD _version;
	PString _osInfo;
	DWORD _clientType;
	PString _localInterface;
};




//////////////////////////

//<ruserid, < groupid, full-related> >
typedef std::pair<PUInt64, PBOOL> GID_FullRelated;
class RelatedUserMap : public std::map< PUInt64, GID_FullRelated >
{
public:
	RelatedUserMap();
	virtual ~RelatedUserMap();
	
	PString ToString() const;
	void FromString(const PString & str);
private:
	
};

struct UserInfoAndGroup{
	BaseUserInfo bui;
	PString group;
	bool fullRelated;
    
};
class RelatedUserMap2 : public std::map<PUInt64, UserInfoAndGroup >
{
public:
	RelatedUserMap2();
	virtual ~RelatedUserMap2();
    
	PString ToString() const;
	void FromString(const PString & str);
    
};

#endif
