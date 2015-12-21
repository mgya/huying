//
//  net_type.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "net_type.h"

#include "../Common/pprocess.h"
#include "../Common/prandom.h"

//////////////////////////
const DWORD MAX_SOCKET_PER_PUMP = 1024;

////////////////////////
IPs::IPs()
{
}

IPs::~IPs()
{
}

PString IPs::ToString() const
{
	PString str;
	for (unsigned i = 0; i < size() ; i++) {
        
		if (!str.IsEmpty())
			str += ";";
        
		str += at(i).AsString();
	}
    
	return str;
}

void IPs::FromString(const PString & str, PBOOL excludeRFC1918)
{
	clear();
	
	PStringArray array = str.Tokenise(";",FALSE);
	for (PINDEX i = 0; i < array.GetSize(); i++) {
		IP ip;
		if(!ip.FromString(array[i]))
			continue;
        
		if(excludeRFC1918){
			if(ip.IsRFC1918()|| ip.IsLoopback())
				continue;
		}
        
		push_back(ip);
	}
}
////////////////////

IPPort::IPPort()
: _ip(0), _port(0)
{
}

IPPort::IPPort(const IP & ip, WORD port)
: _ip(ip), _port(port)
{
}


IPPort::~IPPort()
{
}

PBOOL IPPort::FromString(const PString& str, WORD defPort)
{
	PString ipAddr = str.Trim();
	PINDEX p = ipAddr.Find(':');
	_port = (p != P_MAX_INDEX) ?
    WORD(ipAddr.Mid(p + 1).AsUnsigned()) :
	defPort;
	PString l = ipAddr.Left(p);
	
	if (l == "*" || l == "0.0.0.0") {
		_ip = 0;
		return TRUE;
	}
	return PIPSocket::GetHostAddress(l, _ip);
}

PString IPPort::ToString() const
{
	if (_ip == 0) {
		return "*:" + PString(_port);
	} else {
		return _ip.AsString() + ":" + PString(_port);
	}
}

PBOOL IPPort::FromSockAddr(const struct sockaddr& sa)
{
	if (AF_INET == ((sockaddr_in &) sa).sin_family) {
		_ip = ((struct sockaddr_in &) sa).sin_addr.s_addr;
		_port = ntohs(((struct sockaddr_in &) sa).sin_port);
		return TRUE;
	} else {
		return FALSE;
	}
}

void IPPort::ToSockAddr(struct sockaddr& sa) const
{
	memset(&sa, 0, sizeof(sockaddr));
	((struct sockaddr_in &) sa).sin_family = AF_INET;
	((struct sockaddr_in &) sa).sin_addr.s_addr = _ip;
	((struct sockaddr_in &) sa).sin_port = htons(_port);
}

void IPPort::PrintOn(ostream& strm) const
{
	strm <<ToString();
}

PObject::Comparison IPPort::Compare(
                                    const PObject & obj   // Object to compare against.
) const
{
	PAssert(PIsDescendant(&obj, IPPort), PInvalidCast);
	IPPort & other = (IPPort &)obj;
	
	if(other.GetPort() == _port&&other.GetIP() == _ip)
		return EqualTo;
	
	if(_ip>other.GetIP())
		return GreaterThan;
	else if(_ip<other.GetIP())
		return LessThan;
	else{
		if(_port>other.GetPort())
			return GreaterThan;
		else
			return LessThan;
	}
	
}
////////////////////////////
IPPorts::IPPorts()
{
    
}

IPPorts::~IPPorts()
{
}


PString IPPorts::ToString() const
{
	PString str;
	
	for (unsigned i = 0; i < size(); i++) {
        
		if (!str.IsEmpty())
			str += ";";
		
		str += at(i).ToString();
	}
    
	return str;
}

void IPPorts::FromString(const PString & str, WORD defPorts, PBOOL excludeRFC1918)
{
	clear();
	PStringArray array = str.Tokenise(";",FALSE);
	for (PINDEX i = 0; i < array.GetSize(); i++) {
		IPPort ipport;
        
		if(!ipport.FromString(array[i], defPorts))
			continue;
		
		if(excludeRFC1918){
			if(ipport.GetIP().IsRFC1918()||ipport.GetIP().IsLoopback())
				continue;
		}
		
		push_back(ipport);
	}
}

///////////////////
SocketEventGroup::SocketEventGroup(
								   const PString& name,
								   DWORD maxSockCount,
								   DWORD delay,
								   PThread::Priority priority)
:
_name(name),
_delay(delay),
_priority(priority)
{
	if (0 == maxSockCount)
		_maxSockCount = MAX_SOCKET_PER_PUMP;
	else
		_maxSockCount = PMIN(maxSockCount, MAX_SOCKET_PER_PUMP);
}

SocketEventGroup::SocketEventGroup()
:
_maxSockCount(MAX_SOCKET_PER_PUMP),
_delay(0),
_priority(PThread::NormalPriority)
{
}

PString SocketEventGroup::ToString() const
{
	return psprintf("%s|%d|%u|%d", (const char *) _name, _maxSockCount,
                    _delay, _priority);
}

PString SocketEventGroup::GetName() const
{
	return _name;
}

DWORD SocketEventGroup::GetMaxSockCount() const
{
	return _maxSockCount;
}

DWORD SocketEventGroup::GetDelay() const
{
	return _delay;
}

PThread::Priority SocketEventGroup::GetPriority() const
{
	return _priority;
}
////////////////////////////////
SocketFDSET::SocketFDSET()
: _maxHandlers(PProcess::Current().GetMaxHandles())
{
	_fd_set = (fd_set *) malloc((_maxHandlers + 7) / 8);
	Zero();
}


SocketFDSET::~SocketFDSET()
{
	free(_fd_set);
}

void SocketFDSET::Add(int fd)
{
	if (fd < 0 || fd >= _maxHandlers) {
		return;
	}
	FD_SET((SOCKET) fd, _fd_set);
}

PBOOL SocketFDSET::Has(int fd) const
{
	if (fd < 0 || fd >= _maxHandlers) {
		return FALSE;
	}
	return FD_ISSET(fd, _fd_set);
}


void SocketFDSET::Zero()
{
	memset(_fd_set, 0, (_maxHandlers + 7) / 8);
}

SocketFDSET::operator fd_set *()
{
	return _fd_set;
}

////////////////////////////


/////////////////
AsyncNameResolver::AsyncNameResolver(ANREventSink & sink)
:_sink(sink),
_threadCount(0)
{
}

AsyncNameResolver::~AsyncNameResolver()
{
	EndSync();
}

void AsyncNameResolver::Resolve(const PString & name, WORD defPort)
{
	++_threadCount;
	Param param(name,defPort);
	PThreadPool::RunA(this, &AsyncNameResolver::Thread, param ,"AsyncNameResolver::Thread");
}

void AsyncNameResolver::EndSync()
{
	while(_threadCount>0){
		PThread::Sleep(20);
	}
}

void AsyncNameResolver::Thread(Param param)
{
	{
		IPPort ipport;
		PBOOL success = ipport.FromString(param._name,param._defaultPort);
		_sink.OnResolved(*this,success, param,ipport);
		
	}
	--_threadCount;
}
/////////////////
IPv4Auth::IPv4Auth()
{
}

IPv4Auth::~IPv4Auth()
{
	Clear();
}

void IPv4Auth::_Split(const PString & str, PStringArray & array)
{
	PStringArray lines = str.Lines();
	for(int i = 0;i<lines.GetSize();i++){
		array += lines[i].Tokenise(";,", FALSE);
	}
}

void IPv4Auth::Set(const PString& allow, const PString& deny)
{
	PWaitAndSignal lock(_mutex);
    
	_Clear();
	{
		PStringArray ss;
		_Split(allow,ss);
		for (PINDEX i = 0; i < ss.GetSize(); i++) {
			if (ss[i].IsEmpty())
				continue;
			IPv4Range range;
			if(!range.FromString(ss[i]))
				continue;
            
			_Allow(range);
		}
	}
	{
		PStringArray ss;
		_Split(deny,ss);
		for (PINDEX i = 0; i < ss.GetSize(); i++) {
			if (ss[i].IsEmpty())
				continue;
            
			IPv4Range range;
			if(!range.FromString(ss[i]))
				continue;
            
			_Deny(range);
		}
	}
}



PBOOL IPv4Auth::IsAllowed(const IP & ip) const
{
	PWaitAndSignal lock(_mutex);
	return _IsAllowed(ip);
}

PBOOL IPv4Auth::_IsAllowed(const IP & ip) const
{
	IPv4Range range(ip,ip);
    
	if(_deny.find(range) != _deny.end())
		return FALSE;
    
	if(_allow.find(range) != _allow.end())
		return TRUE;
    
	return FALSE;
    
}

void IPv4Auth::Allow(const PString& s)
{
	if(s.IsEmpty())
		return;
    
	IPv4Range range;
	if(!range.FromString(s))
		return;
    
	Allow(range);
}

void IPv4Auth::Deny(const PString& s)
{
	if(s.IsEmpty())
		return;
	
	IPv4Range range;
	if(!range.FromString(s))
		return;
    
	Deny(range);
}

void IPv4Auth::Allow(const IPv4Range & range)
{
	PWaitAndSignal lock(_mutex);
	_Allow(range);
}

void IPv4Auth::Deny(const IPv4Range & range)
{
	PWaitAndSignal lock(_mutex);
	_Deny(range);
}

void IPv4Auth::_Add(RangeMap & rm,const IPv4Range & range)
{
	IPv4Range rgn = range;
	for(;;){
		
		RangeMap::iterator it = rm.find(rgn);
		if(rm.end() == it)
			break;
		
		rgn = rgn + it->first;
		rm.erase(it);
		
	}
	rm[rgn] = false;
}


void IPv4Auth::_Allow(const IPv4Range & range)
{
	_Add(_allow,range);
}

void IPv4Auth::_Deny(const IPv4Range & range)
{
	_Add(_deny,range);
}

void IPv4Auth::Clear()
{
	PWaitAndSignal lock(_mutex);
    
	_Clear();
}

void IPv4Auth::_Clear()
{
	_allow.clear();
	_deny.clear();
}

//////////////
IPv4Range::IPv4Range()
:_begin(0),
_end(0)
{
}

IPv4Range::IPv4Range(const IP & begin, const IP & end)
{
	_begin = PSocket::Net2Host((DWORD)begin);
	_end = PSocket::Net2Host((DWORD)end);
	_Normalize();
}


IP IPv4Range::GetBeginIP() const
{
	return IP(PSocket::Host2Net(_begin));
}

IP IPv4Range::GetEndIP() const
{
	return IP(PSocket::Host2Net(_end));
}

PBOOL IPv4Range::Empty() const
{
	return ((0==_begin)&&(0==_end));
}

PBOOL IPv4Range::In(const IP & ip) const
{
	DWORD v= PSocket::Net2Host((DWORD)ip);
	return (v>=_begin&&v<=_end);
}

PBOOL IPv4Range::FromString(const PString & str)
{
    
	if(str.FindOneOf("-")!=P_MAX_INDEX){
        
		if(_ParseNetworkRange(str)){
			_Normalize();
			return (!Empty());
			
		}
	}else{
		if(_ParseNetworkAndMask(str)){
			_Normalize();
			return (!Empty());
			
		}
	}
	_begin = 0;
	_end = 0;
	return FALSE;
}

PString IPv4Range::ToString(PBOOL full) const
{
	if(full)
		return  IP(PSocket::Host2Net(_begin)).AsString()+"-"+IP(PSocket::Host2Net(_end)).AsString();
	else
		return  IP(PSocket::Host2Net(_begin)).AsString()+"-"+ PString(_end-_begin);
}

bool IPv4Range::operator < (const IPv4Range & other) const
{
	return (_end<other._begin);
}

IPv4Range IPv4Range::operator + (const IPv4Range & other) const
{
	IPv4Range ret;
	ret._begin=PMIN(_begin,other._begin);
	ret._end=PMAX(_end,other._end);
	ret._Normalize();
	return ret;
}

void IPv4Range::_Normalize()
{
	if(_begin>_end)
		_begin = _end = 0;
}



static const DWORD masks[]={
	0x00000000,
    0x80000000,0xc0000000,0xe0000007,0xf0000000,
    0xf8000000,0xfc000000,0xfe000000,0xff000000,
    0xff800000,0xffc00000,0xffe00000,0xfff00000,
    0xfff80000,0xfffc0000,0xfffe0000,0xffff0000,
    0xffff8000,0xffffc000,0xffffe000,0xfffff000,
    0xfffff800,0xfffffc00,0xfffffe00,0xffffff00,
    0xffffff80,0xffffffc0,0xffffffe0,0xfffffff0,
    0xfffffff8,0xfffffffc,0xfffffffe,0xffffffff
};

PBOOL IPv4Range::_ParseNetworkAndMask(const PString & str)
{
	if (str *= "ALL") {
		_begin = 0;
		_end = 0xffffffff;
		return TRUE;
	}
	
	PINDEX slashPos = str.Find('/');
	if (slashPos == P_MAX_INDEX) {
		// a single IP
		_begin = _end = PSocket::Net2Host(IP(str));
		return TRUE;
	}
    
	
	_begin = PSocket::Net2Host(IP(str.Left(slashPos)));
	
	const PString netmaskString = str.Mid(slashPos + 1);
	
	DWORD mask = 0;
	
	
	if (netmaskString.Find(".") != P_MAX_INDEX) {
		// netmask as a network address
		mask = PSocket::Net2Host(inet_addr((const char *) netmaskString));
		
		PBOOL valid = FALSE;;
		for(PINDEX i =0;i<PARRAYSIZE(masks);i++){
			if(masks[i]==mask){
				valid = TRUE;
				break;
			}
		}
		
		if(!valid)
			return FALSE;
		
	} else {
		// netmask as an integer
		const DWORD netmaskLen = netmaskString.AsUnsigned();
		
		if(netmaskLen>= PARRAYSIZE(masks))
			return FALSE;
		
		mask = masks[netmaskLen];
	}
	_begin = (_begin&mask);
	_end = (_begin|(~mask));
	return TRUE;
}

PBOOL IPv4Range::_ParseNetworkRange(const PString & str)
{
	PINDEX pos = str.Find('-');
	if(P_MAX_INDEX == pos)
		return FALSE;
	
	_begin = PSocket::Net2Host(IP(str.Mid(0,pos)));
	PString end = str.Mid(pos+1);
	if(end.Find('.')!=P_MAX_INDEX)
		_end = PSocket::Net2Host(IP(end));
	else
		_end = _begin+end.AsUnsigned();
    
	return TRUE;
}
///////////////////////

///////////////

WORD PortRange::GetPort()
{
	if (_port == 0) {
		return 0;
	}
    
	PWaitAndSignal lock(_mutex);
	WORD result = _port++;
	if (_port > _maxport) {
		_port = _minport;
	}
	return result;
}

PortRange::PortRange()
{
	_maxport = 50000;
	_minport = 10000;
	_port = _minport;
}

PortRange::PortRange(WORD min, WORD max)
{
	_maxport = max;
	_minport = min;
	_port = _minport;
}

void PortRange::SetRange(WORD min, WORD max)
{
	_maxport = max;
	_minport = min;
	_port = _minport;
}
/////////////////
////////////////////
static PMutex guidMutex;
GloballyUniqueID::GloballyUniqueID()
: PBYTEArray(GUID_SIZE)
{
	PWaitAndSignal lock(guidMutex);
	// Want time of UTC in 0.1 microseconds since 15 Oct 1582.
	PInt64 timestamp;
	static PInt64 deltaTime = PInt64(10000000) * 24 * 60 * 60 * (16 		   // Days from 15th October
                                                                 +
                                                                 31   		 // Days in December 1583
                                                                 +
                                                                 30   		 // Days in November 1583
	+(1970 - 1583) * 365 // Days in years
	+ (1970 - 1583) / 4   // Leap days
	- 3);   		  // Allow for 1700, 1800, 1900 not leap years
    
	struct timeval tv;
	gettimeofday(&tv, NULL);
	timestamp = (tv.tv_sec * (PInt64) 1000000 + tv.tv_usec) * 10;
    
	timestamp += deltaTime;
    
	theArray[0] = (BYTE) (timestamp & 0xff);
	theArray[1] = (BYTE) ((timestamp >> 8) & 0xff);
	theArray[2] = (BYTE) ((timestamp >> 16) & 0xff);
	theArray[3] = (BYTE) ((timestamp >> 24) & 0xff);
	theArray[4] = (BYTE) ((timestamp >> 32) & 0xff);
	theArray[5] = (BYTE) ((timestamp >> 40) & 0xff);
	theArray[6] = (BYTE) ((timestamp >> 48) & 0xff);
	theArray[7] = (BYTE) (((timestamp >> 56) & 0x0f) + 0x10);  // Version number is 1
    
	static WORD clockSequence =  (WORD)PRandom::Number();
	static PInt64 lastTimestamp = 0;
	if (lastTimestamp < timestamp) {
		lastTimestamp = timestamp;
	} else {
		++clockSequence;
	}
    
	theArray[8] = (BYTE) (((clockSequence >> 8) & 0x1f) | 0x80); // DCE compatible GUID
	theArray[9] = (BYTE) clockSequence;

	theArray[10] = (BYTE) PRandom::Number();
	theArray[11] = (BYTE) PRandom::Number();
	theArray[12] = (BYTE) PRandom::Number();
	theArray[13] = (BYTE) PRandom::Number();
	theArray[14] = (BYTE) PRandom::Number();
	theArray[15] = (BYTE) PRandom::Number();


}


GloballyUniqueID::GloballyUniqueID(const char* cstr)
: PBYTEArray(GUID_SIZE)
{
	if (cstr != NULL && *cstr != '\0') {
		PStringStream strm(cstr);
		ReadFrom(strm);
	}
}


GloballyUniqueID::GloballyUniqueID(const PString& str)
: PBYTEArray(GUID_SIZE)
{
	PStringStream strm(str);
	ReadFrom(strm);
}


PObject* GloballyUniqueID::Clone() const
{
	PAssert(GetSize() == GUID_SIZE, "GloballyUniqueID is invalid size");
    
	return new GloballyUniqueID(*this);
}


PINDEX GloballyUniqueID::HashFunction() const
{
	PAssert(GetSize() == GUID_SIZE, "GloballyUniqueID is invalid size");
    
	DWORD* words = (DWORD*) theArray;
	DWORD sum = words[0] + words[1] + words[2] + words[3];
	return ((sum >> 25) + (sum >> 15) + sum) % 23;
}


void GloballyUniqueID::PrintOn(ostream& strm) const
{
	PAssert(GetSize() == GUID_SIZE, "GloballyUniqueID is invalid size");
    
	char fillchar = strm.fill();
	strm << hex << setfill('0') << setw(2) << (unsigned) (BYTE) theArray[0]
    << setw(2) << (unsigned) (BYTE) theArray[1] << setw(2)
    << (unsigned) (BYTE) theArray[2] << setw(2)
    << (unsigned) (BYTE) theArray[3] << '-' << setw(2)
    << (unsigned) (BYTE) theArray[4] << setw(2)
    << (unsigned) (BYTE) theArray[5] << '-' << setw(2)
    << (unsigned) (BYTE) theArray[6] << setw(2)
    << (unsigned) (BYTE) theArray[7] << '-' << setw(2)
    << (unsigned) (BYTE) theArray[8] << setw(2)
    << (unsigned) (BYTE) theArray[9] << '-' << setw(2)
    << (unsigned) (BYTE) theArray[10] << setw(2)
    << (unsigned) (BYTE) theArray[11] << setw(2)
    << (unsigned) (BYTE) theArray[12] << setw(2)
    << (unsigned) (BYTE) theArray[13] << setw(2)
    << (unsigned) (BYTE) theArray[14] << setw(2)
    << (unsigned) (BYTE) theArray[15] << dec << setfill(fillchar);
}


void GloballyUniqueID::ReadFrom(istream& strm)
{
	PAssert(GetSize() == GUID_SIZE, "GloballyUniqueID is invalid size");
	SetSize(16);
    
	strm >> ws;
    
	PINDEX count = 0;
    
	while (count < 2 * GUID_SIZE) {
		if (isxdigit(strm.peek())) {
			char digit = (char) (strm.get() - '0');
			if (digit >= 10) {
				digit -= 'A' - ('9' + 1);
				if (digit >= 16) {
					digit -= 'a' - 'A';
				}
			}
			theArray[count / 2] = (BYTE) ((theArray[count / 2] << 4) | digit);
			count++;
		} else if (strm.peek() == '-') {
			if (count != 8 && count != 12 && count != 16 && count != 20) {
				break;
			}
			strm.get(); // Ignore the dash if it was in the right place
		} else {
			break;
		}
	}
    
	if (count < 2 * GUID_SIZE) {
		memset(theArray, 0, GUID_SIZE);
		strm.clear(ios::failbit);
	}
}


PString GloballyUniqueID::ToString() const
{
	PStringStream strm;
	PrintOn(strm);
	return strm;
}


PBOOL GloballyUniqueID::IsNULL() const
{
	PAssert(GetSize() == GUID_SIZE, "GloballyUniqueID is invalid size");
    
	return memcmp(theArray, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) == 0;
}


////////////////
class ____RandInit {
public:
	____RandInit()
	{
		srand((unsigned int)PTimer::Tick().GetInterval());
	}
} _____randInit;









