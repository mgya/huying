//
//  ump_base.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-5.
//  Copyright (c) 2014年 Dev. All rights reserved.
//


#include "prandom.h"

#include "sig_wrap.h"
#include "ump_base.h"
#include "ump_cypher.h"
//#include "Network/types.h"

PBOOL UMPUtility::LimitString(PString& str, PINDEX limit)
{
	PINDEX len = str.GetLength();
    
	int n = 0;
	for (PINDEX i = 0; i < limit&&n < len; i++) {
        
		char c = str[n];
		if (c < 0) {
			n+=2;
		}else
			n++;
        
	}
    
	if(n < len)
		str[n] = 0;
    
	return TRUE;
}

PBOOL UMPUtility::IsDigits(const PString& str)
{
	return (strspn(str, "1234567890*#") == strlen(str));
}

PBOOL UMPUtility::IsValidUserName(const PString& str)
{
	PINDEX len = str.GetLength();
	if (len < 1)
		return FALSE;
	else {
		if (!isalpha(str[0]))
			return FALSE;
	}
    
	for (PINDEX i = 1; i < len; i++) {
		char c = str[i];
		if (isalpha(c) || isdigit(c) || c == '_' || c == '-' || c == '@' || c == '.') {
		} else
			return FALSE;
	}
	return TRUE;
}

////////////////
UMPSequenceNumber::UMPSequenceNumber()
{
	_number = PRandom::Number();
}

UMPSequenceNumber::~UMPSequenceNumber()
{
}

DWORD UMPSequenceNumber::Next()
{
	DWORD ret = (DWORD)++_number;
	while (ret == 0)
		ret = (DWORD)++_number;
	return ret;
}

////////////////////
UMPSignal::UMPSignal(E_UMPTag tag/* =0 */)
: _tag(tag),_size(0)
{
}

UMPSignal::UMPSignal(const UMPSignal& other)
{
	*this = other;
}


UMPSignal::~UMPSignal()
{
	Clear();
}

PString UMPSignal::ToString() const
{
	PBYTEArray bin;
    
	if (Encode(bin)) {
		return UMPCypher::NREncoder(bin);
	}
	else
		return "";
}

PBOOL UMPSignal::FromString(const PString& str)
{
	return Decode(UMPCypher::NRDecoder(str));
}


PBOOL UMPSignal::Get(E_UMPTag elemTag, PString& elem) const
{
	Map::const_iterator it = _map.find(elemTag);
	if(_map.end()!=it){
		elem = it->second;
		return TRUE;
	} else
		return FALSE;
}

PBOOL UMPSignal::Get(E_UMPTag elemTag, char& elem) const
{
	Map::const_iterator it = _map.find(elemTag);
	if(_map.end()!=it){
		elem = (char) it->second.AsInteger(16);
		return TRUE;
	} else
		return FALSE;
}

PBOOL UMPSignal::Get(E_UMPTag elemTag, BYTE& elem) const
{
	Map::const_iterator it = _map.find(elemTag);
	if(_map.end()!=it){
		elem = (BYTE) it->second.AsUnsigned(16);
		return TRUE;
	} else
		return FALSE;
}


PBOOL UMPSignal::Get(E_UMPTag elemTag, short& elem) const
{
	Map::const_iterator it = _map.find(elemTag);
	if(_map.end()!=it){
		elem = (short) it->second.AsInteger(16);
		return TRUE;
	} else
		return FALSE;
    
}

PBOOL UMPSignal::Get(E_UMPTag elemTag, WORD& elem) const
{
	Map::const_iterator it = _map.find(elemTag);
	if(_map.end()!=it){
		elem = (WORD)it->second.AsUnsigned(16);
		return TRUE;
	} else
		return FALSE;
    
}

PBOOL UMPSignal::Get(E_UMPTag elemTag, int& elem) const
{
	Map::const_iterator it = _map.find(elemTag);
	if(_map.end()!=it){
		elem = (int) it->second.AsInteger(16);
		return TRUE;
	} else
		return FALSE;
	
}

PBOOL UMPSignal::Get(E_UMPTag elemTag, DWORD& elem) const
{
	Map::const_iterator it = _map.find(elemTag);
	if(_map.end()!=it){
		elem = (DWORD) it->second.AsUnsigned(16);
		return TRUE;
	} else
		return FALSE;
    
}

PBOOL UMPSignal::Get(E_UMPTag elemTag, double& elem) const
{
	Map::const_iterator it = _map.find(elemTag);
	if(_map.end()!=it){
		elem = (double)it->second.AsReal();
		return TRUE;
	} else
		return FALSE;
}

PBOOL UMPSignal::Get(E_UMPTag elemTag, PBYTEArray& elem) const
{
	Map::const_iterator it = _map.find(elemTag);
	if(_map.end()!=it){
		elem = UMPCypher::NRDecoder(it->second);
		return TRUE;
	} else
		return FALSE;
}

PBOOL UMPSignal::Get(E_UMPTag elemTag, UMPSignal& elem) const
{
	PBYTEArray bin;
	if (Get(elemTag, bin))
		return elem.Decode(bin);
	return FALSE;
}

PBOOL UMPSignal::Get(E_UMPTag elemTag, PUInt64& elem) const
{
	Map::const_iterator it = _map.find(elemTag);
	if(_map.end()!=it){
		elem = it->second.AsUnsigned64(10);
		return TRUE;
	} else
		return FALSE;
    
}

PBOOL UMPSignal::Get(E_UMPTag elemTag, PInt64& elem) const
{
	Map::const_iterator it = _map.find(elemTag);
	if(_map.end()!=it){
		elem = it->second.AsInt64(10);
		return TRUE;
	} else
		return FALSE;
}


void UMPSignal::InternalSet(E_UMPTag elemTag, const PString & str)
{
	std::pair<Map::iterator, bool> p = _map.insert(
                                                   Map::value_type(elemTag,str));
	if(p.second){
		_size++;
	}else{
		p.first->second = str;
	}
}

void UMPSignal::Set(E_UMPTag elemTag, const PString& elem)
{
	InternalSet(elemTag,elem);
}


void UMPSignal::Set(E_UMPTag elemTag, char		elem)
{
	InternalSet(elemTag, PString(PString::Signed, (long) elem, 16));
}

void UMPSignal::Set(E_UMPTag elemTag, BYTE		elem)
{
	InternalSet(elemTag, PString(PString::Unsigned, (long) elem, 16));
}

void UMPSignal::Set(E_UMPTag elemTag, short		elem)
{
	InternalSet(elemTag,PString(PString::Signed, (long) elem, 16));
}

void UMPSignal::Set(E_UMPTag elemTag, WORD		elem)
{
	InternalSet(elemTag, PString(PString::Unsigned, (long) elem, 16));
}

void UMPSignal::Set(E_UMPTag elemTag, int		elem)
{
	InternalSet(elemTag, PString(PString::Signed, (long) elem, 16));
}

void UMPSignal::Set(E_UMPTag elemTag, DWORD		elem)
{
	InternalSet(elemTag, PString(PString::Unsigned, (long) elem, 16));
}

void UMPSignal::Set(E_UMPTag elemTag, double		elem)
{
	InternalSet(elemTag, psprintf("%f", elem));
}


void UMPSignal::Set(E_UMPTag elemTag, const PBYTEArray& elem)
{
	InternalSet(elemTag, UMPCypher::NREncoder(elem));
}

void UMPSignal::Set(E_UMPTag elemTag, const UMPSignal& elem)
{
	PBYTEArray bin;
	if (elem.Encode(bin))
		Set(elemTag, bin);
}


void UMPSignal::Set(E_UMPTag elemTag, const PUInt64		&	elem)
{
	InternalSet(elemTag, PString(elem));
}

void UMPSignal::Set(E_UMPTag elemTag, const PInt64	&		elem)
{
	InternalSet(elemTag,PString(elem));
}

PBOOL UMPSignal::GetAt(PINDEX i , E_UMPTag & key, PString & value) const
{
	if(i<0||i>=(PINDEX)GetSize())
		return FALSE;
    
	Map::const_iterator it = _map.begin(),eit = _map.end();
	while(it!=eit){
		if(0 == i--){
			key = it->first;
			value = it->second;
			return TRUE;
		}
		it++;
	}
	return FALSE;
}

PBOOL UMPSignal::Remove(E_UMPTag elemTag)
{
	Map::iterator it = _map.find(elemTag);
	if(_map.end()!=it){
		_map.erase(it);
		_size--;
		return TRUE;
	}else
		return FALSE;
}

void UMPSignal::Clear()
{
	_map.clear();
	_size = 0;
}


PBOOL UMPSignal::Exist(E_UMPTag elemTag) const
{
	return (_map.find(elemTag)!=_map.end());
}

DWORD UMPSignal::CalcSize() const
{
	DWORD size = CalcTagSize(_tag) + 1;
	Map::const_iterator it = _map.begin(),eit=_map.end();
	while(it!=eit){
		size += CalcTagSize(it->first)+1;
		size += it->second.GetLength() + 1;
		it++;
	}
	if(_map.empty())
		size++;
	return size;
}


const DWORD __mask[] = {
	0xf0000000, 0x0f000000, 0x00f00000, 0x000f0000, 0x0000f000, 0x00000f00,
	0x000000f0, 0x0000000f
};

DWORD UMPSignal::CalcTagSize(E_UMPTag tag) const
{
	for (int i = 0; i < 8; i++) {
		if (tag & __mask[i])
			return (8 - i);
	}
	return 1;
}


PBOOL UMPSignal::Encode(PBYTEArray& buffer) const
{
	PINDEX size = CalcSize();
	if(size > MAX_BLOCK_LEN)
		return FALSE;
    
	buffer.SetSize(size);
    
	InternalEncode(buffer.GetPointer());
	return TRUE;
}

PBOOL UMPSignal::Encode(void* buffer, PINDEX& len) const
{
	PINDEX size = CalcSize();
	if(size > MAX_BLOCK_LEN){
		len = 0;
		return FALSE;
	}
    
	if (size > len) {
		len = size;
		return FALSE;
	}
	len = size;
    
	InternalEncode(buffer);
	return TRUE;
}

void UMPSignal::InternalEncode(void* buffer) const
{
	char* ptr = (char*) buffer;
    
	DWORD l;
    
	
	l = sprintf(ptr,"%X|",_tag);
    
	ptr += l;
    
	
	Map::const_iterator it = _map.begin(),eit=_map.end();
	while(it!=eit){
        
		l = sprintf(ptr,"%X=",it->first);
		ptr += l;
		
		const PString& data = it->second;
		l = data.GetLength();
		memcpy(ptr, (const char *) data, l + 1);
		ptr += (l + 1);
        
		it++;
	}
    
}


PBOOL UMPSignal::Decode(const PBYTEArray& buffer)
{
	return Decode(buffer, buffer.GetSize());
}
PBOOL UMPSignal::Decode(const void* buffer, PINDEX len)
{
	Clear();
	const char* ptr = (const char*) buffer;
	const PINDEX size = len;
    
	PBOOL gotTag = FALSE;
	PINDEX i;
    
	DWORD tag = 0;
    
	for (i = 0; i< (9>size ? size : 9); i++) {
		if (ptr[i] == '|') {
			sscanf(ptr,"%X",&tag);
			_tag = (E_UMPTag)tag;
			gotTag = TRUE;
			break;
		}
	}
	if(!gotTag)
		return FALSE;
    
	i++;
    
    
	PINDEX start = i;
    
	for (; i < size; i++) {
		if (ptr[i] == 0) {
			//PBOOL gotElem = FALSE;
			for (PINDEX j = start; j < i; j++) {
				if (ptr[j] == '=') {
                    
					sscanf(ptr+start,"%X",&tag);
                    
					InternalSet((E_UMPTag)tag, ptr + j + 1);
					//gotElem = TRUE;
					break;
				}
			}
			//FAIL_RET(gotElem);
			start = i + 1;
		}
	}
    
	return TRUE;
}

void UMPSignal::SetTag(E_UMPTag tag)
{
	_tag = tag;
}

E_UMPTag UMPSignal::GetTag() const
{
	return _tag;
}

PString UMPSignal::GetTagName() const
{
	return TagName(GetTag());
}




void UMPSignal::PrintOn(ostream& strm) const
{
	strm << "Sig:\t" << GetTagName() << "\n";
	Map::const_iterator it = _map.begin(),eit=_map.end();
	while(it!=eit){
		PString tagName = TagName(it->first);
		strm << tagName << setw(30 - tagName.GetLength()) << "=\t"
			<< it->second.ToLiteral() << "\n";

		it++;
	}
}

////////////////////

BaseUserInfo::BaseUserInfo()
{
	SetID(0);
    //added by liyr 2015-12-03
    SetCID(0);
    SetAID(0);
    //added by liyr 2015-12-03
}

BaseUserInfo::BaseUserInfo(const UMPSignal& signal)
{
	GetFrom(signal);
}


BaseUserInfo::~BaseUserInfo()
{
}

PBOOL BaseUserInfo::IsFull() const
{
	return (_id!=0&&
            !_name.IsEmpty()&&
            !_number.IsEmpty());
}


PBOOL BaseUserInfo::GetFrom(const UMPSignal& signal)
{
	PUInt64 id= 0 ;
	PString name;
	PString number;
    //added by liyr 2015-12-03
    PUInt64 cid= 0 ;
    PUInt64 aid= 0 ;
    //added by liyr 2015-12-03
    
	PBOOL ret = FALSE;
    
	ret = signal.Get(e_ele_userID, id) || ret;
	ret = signal.Get(e_ele_userName, name) || ret;
	ret = signal.Get(e_ele_userNumber, number) || ret;
    //added by liyr 2015-12-03
    ret = signal.Get(e_ele_CID, cid) || ret;
    ret = signal.Get(e_ele_AID, aid) || ret;
    //added by liyr 2015-12-03
    
	SetID(id);
	SetName(name);
	SetNumber(number);
    //added by liyr 2015-12-03
    SetCID(cid);
    SetAID(aid);
    //added by liyr 2015-12-03
	return ret;
}

PBOOL BaseUserInfo::SetTo(UMPSignal& signal) const
{
	if (_id)
		signal.Set(e_ele_userID, _id);
	if (!_name.IsEmpty())
		signal.Set(e_ele_userName, _name);
	if (!_number.IsEmpty())
		signal.Set(e_ele_userNumber, _number);
    //added by liyr 2015-12-03
    if (_cid)
        signal.Set(e_ele_CID, _cid);
    if (_aid)
        signal.Set(e_ele_AID, _aid);
    //added by liyr 2015-12-03
	return TRUE;
}


BaseUserInfo::BaseUserInfo(const BaseUserInfo& other)
{
	(*this) = other;
}

BaseUserInfo::BaseUserInfo(const PUInt64 & uid, const PString& uname,
                           const PString& unumber, const PUInt64 & cid,const PUInt64 & aid)//modified by liyr 2015-12-03 for adding cid&aid
{
	SetID(uid);
	SetName(uname);
	SetNumber(unumber);
    //added by liyr 2015-12-03
    SetCID(cid);
    SetAID(aid);
    //added by liyr 2015-12-03
}


void BaseUserInfo::MakeSimple()
{
	if (_id) {
		_name.MakeEmpty();
		_number.MakeEmpty();
	} else if (!_name.IsEmpty()) {
		_number.MakeEmpty();
	}
}

void BaseUserInfo::SetName(const PString & name)
{
	_name = name;
	UMPUtility::LimitString(_name,30);
}

void BaseUserInfo::SetNumber(const PString & number)
{
	_number = number;
	//≤‚ ‘µ»µ»–Ë«Û£¨–Ë“™≥§∂»≥¨π˝30µƒ∫≈¬Î£¨œ»∏ƒŒ™100£¨lxh20100507
	UMPUtility::LimitString(_number,100);
}


//////////////
BaseGroupInfo::BaseGroupInfo()
{
	_id = 0;
}

BaseGroupInfo::BaseGroupInfo(const UMPSignal& signal)
{
	GetFrom(signal);
}

BaseGroupInfo::BaseGroupInfo(const PUInt64 & gid, const PString& gname)
{
	SetID(gid);
	SetName(gname);
}

BaseGroupInfo::~BaseGroupInfo()
{
}

PBOOL BaseGroupInfo::IsFull() const
{
	return (_id!=0&&
            !_name.IsEmpty());
}

void BaseGroupInfo::SetName(const PString & name)
{
	_name = name;
	UMPUtility::LimitString(_name,20);
}

PBOOL BaseGroupInfo::GetFrom(const UMPSignal& signal)
{
	PUInt64 id = 0;
	PString name;
	
	PBOOL ret = FALSE;
	//ret = signal.Get(e_ele_groupID, id) || ret;   //deleted by liyr 2015-12-03
	//ret = signal.Get(e_ele_groupName, name) || ret;   //deleted by liyr 2015-12-03
    
	SetID(id);
	SetName(name);
	return ret;
}

PBOOL BaseGroupInfo::SetTo(UMPSignal& signal) const
{
    //deleted by liyr 2015-12-03
	//if (_id)
	//	signal.Set(e_ele_groupID, _id);
	//if (!_name.IsEmpty())
	//	signal.Set(e_ele_groupName, _name);
    //deleted by liyr 2015-12-03
    
	return TRUE;
}

//////////////////


/////////////////

//////////////////////////

///////////////////////////////////////

/////////////////////
UserSubState::UserSubState(const UMPSignal& signal)
{
	GetFromSignal(signal);
}

UserSubState::UserSubState(
						   E_UserSubState sstate,
						   E_ClientType ctype,
						   const PString& desc)
{
	_subState = sstate;
	_description = desc;
	_clientType = ctype;
}

UserSubState::UserSubState()
{
	_subState = e_subState_hide;
	_clientType = e_clt_t_unknown;
}

UserSubState::~UserSubState()
{
}

PBOOL UserSubState::GetFromSignal(const UMPSignal& signal)
{
	_subState = e_subState_hide;
	_description.MakeEmpty();
	_clientType = e_clt_t_unknown;
	PBOOL ret = FALSE;
	DWORD temp = 0;
	if(signal.Get(e_ele_userSubState, temp)){
		_subState = (E_UserSubState)temp;
		ret = TRUE;
	}
    
	if(signal.Get(e_ele_description, _description))
		ret = TRUE;
    
	if(signal.Get(e_ele_clientType, temp)){
		_clientType = (E_ClientType)temp;
		ret = TRUE;
	}
    
	return ret;
}

PBOOL UserSubState::SetToSignal(UMPSignal& signal) const
{
	signal.Set(e_ele_userSubState, (DWORD) _subState);
	signal.Set(e_ele_clientType, (DWORD) _clientType);
	if (!_description.IsEmpty())
		signal.Set(e_ele_description, _description);
    
	return TRUE;
}



/////////////
BaseUserStatusInfo::BaseUserStatusInfo()
:_uid(0),
_loginTime(0),
_lastLoginTime(0),
_serverID(0),
_onlineTime(0),
_loginCount(0),
_curOnlineTime(0),
_version(0),
_clientType(0)
{
}

BaseUserStatusInfo::BaseUserStatusInfo(const BaseUserStatusInfo& other)
{
	(*this) = other;
}




//////////

RelatedUserMap::RelatedUserMap()
{
}

RelatedUserMap::~RelatedUserMap()
{
}

PString RelatedUserMap::ToString() const
{
	//gid:ruid_fullRelated,ruid_fullRelated|gid:....
	PStringToString sts;
    
	const_iterator it = begin();
    
	while (it != end()) {
        
		PString gid(it->second.first);
		PString* v = sts.GetAt(gid);
		
		PString ruidFullRelated = PString(it->first) + PString("_") + PString(it->second.second?1:0);
		if (v) {
			(*v) += (PString(",") + ruidFullRelated);
		} else
			sts.SetAt(gid, ruidFullRelated);
		it++;
	}
	
	PString ret;
	for (PINDEX i = 0; i < sts.GetSize(); i++) {
		if (!ret.IsEmpty())
			ret += "|";
		ret += sts.GetKeyAt(i);
		ret += ":";
		ret += sts.GetDataAt(i);
	}
	
	return ret;
}

void RelatedUserMap::FromString(const PString & str)
{
	clear();
	const PStringArray groups = str.Tokenise("|", FALSE);
    
	for(PINDEX i=0;i<groups.GetSize();i++){
		const PString & s = groups[i];
		const PINDEX posGid =s.Find(":");
		if(P_MAX_INDEX==posGid)
			continue;
		
		const PUInt64 gid = s.Mid(0,posGid).AsUnsigned64();
        
		const PStringArray ruids = s.Mid(posGid+1).Tokenise(",", FALSE);
		for(PINDEX j=0;j<ruids.GetSize();j++){
			const PString & ruidFullRelated = ruids[j];
			if(ruidFullRelated.IsEmpty())
				continue;
			
			const PINDEX posRuid = ruidFullRelated.Find("_");
			
			const PUInt64 ruid = ruidFullRelated.Mid(0,posRuid).AsUnsigned64();
			const PBOOL fullRelated = ruidFullRelated.Mid(posRuid + 1).AsInteger()!=0;
            
			GID_FullRelated & gidFullRelated = (*this)[ruid];
			gidFullRelated.first = gid;
			gidFullRelated.second = fullRelated;
			
		}
	}
}
