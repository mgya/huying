//
//  net_type.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__net_type__
#define __UMPStack__net_type__

#include "../Common/pcommon.h"
#include "../Common/pipsock.h"
#include "../Common/ptimer.h"
#include "../Common/uutil.h"

/** event values
 */
enum E_SocketEvent{
	e_sock_ev_none			=	0,
	e_sock_ev_read			=	1,
	e_sock_ev_write			=	2,
	e_sock_ev_tick			=	4,
	e_sock_ev_connect		=	8,
	e_sock_ev_destroy		=	16,
	e_sock_ev_hup			=	32,
	e_sock_ev_io			=	(e_sock_ev_read|e_sock_ev_write|e_sock_ev_connect),
	e_sock_ev_all			=	0xFFFFFFFF,
};

//////////////////////
typedef PIPSocket::Address IP;


class IPs : public std::vector<IP>
{
public:
	IPs();
	virtual ~IPs();
	
	PString ToString() const;
	void FromString(const PString & str, PBOOL excludeRFC1918 = FALSE);
	
};

/** wrapping of IP and port
 
 */
class IPPort : public PObject
{
	PCLASSINFO(IPPort, PObject)
public:
	IPPort();
	IPPort(const IP & ip, WORD port);
    
	virtual ~IPPort();
    
	const IP & GetIP() const{return _ip;}
	void SetIP(const IP & ip){_ip = ip;}
	WORD GetPort() const{return _port;}
	void SetPort(WORD port){_port = port;}
    
	PBOOL FromString(const PString& str, WORD defPort);
	PString ToString() const;
    
	PBOOL FromSockAddr(const struct sockaddr& sa);
	void ToSockAddr(struct sockaddr& sa) const;
    
	
	PBOOL IsValid() const{return (_ip.IsValid() && _port != 0);}
	
	virtual void PrintOn(ostream& strm) const;
    
    
protected:
	virtual Comparison Compare(
                               const PObject & obj   // Object to compare against.
    ) const;
    
protected:
	IP _ip;
	WORD _port;
};
//////////////////////////

class IPPorts : public std::vector<IPPort>
{
public:
	IPPorts();
	virtual ~IPPorts();
    
	PString ToString() const;
	void FromString(const PString & str, WORD defPorts, PBOOL excludeRFC1918 = FALSE);
	
};
///////////////////
/** include the properties of event pump, pumps have
 same properties are in the same group
 */
class SocketEventGroup
{
public:
	SocketEventGroup(
                     const PString& name,
                     DWORD maxSockCount = 0,
                     DWORD delay = 0, /* delay of every event query, useful
                                       for large amount of busy IO sockets */
                     PThread::Priority priority = PThread::NormalPriority /* priority of event pump thread*/
    );
    
	SocketEventGroup();
    
	PString ToString() const;
    
	PString GetName() const;
	DWORD GetMaxSockCount() const;
	DWORD GetDelay() const;
	PThread::Priority GetPriority() const;
    
protected:
	PString _name;
	DWORD _maxSockCount;
	DWORD _delay;
	PThread::Priority _priority;
};

/** growable fdset depend on system config
 on linux/unix depend on limit of openfiles per process
 */
class SocketFDSET
{
public:
	SocketFDSET();
	virtual ~SocketFDSET();
    
	void Add(int fd);
	PBOOL Has(int fd) const;
	void Zero();
	operator fd_set *();
    
protected:
	fd_set* _fd_set;
    
	const int _maxHandlers;

private:
	NonCopyable ______nocopy;
};

/////////////////////
//“Ï≤Ω”Ú√˚Ω‚Œˆ
class AsyncNameResolver
{
public:
	class Param
	{
	public:
		Param(const PString & name, WORD defPort)
        :_name(name),
        _defaultPort(defPort)
		{
		}
		
		Param()
        :_defaultPort(0)
		{
		}
		virtual ~Param(){}
	public:
		PString _name;
		WORD _defaultPort;
	};
    
	class ANREventSink
	{
	public:
		virtual void OnResolved(
                                AsyncNameResolver & anr,
                                PBOOL success,
                                const Param & param,
                                const IPPort & addr) = 0;
	protected:
		virtual ~ANREventSink(){}
	};
    
    
public:
	AsyncNameResolver(ANREventSink & sink);
	virtual ~AsyncNameResolver();
    
	void Resolve(const PString & name, WORD defPort);
    
	void EndSync();
    
    
private:
	void Thread(Param param);
private:
	ANREventSink & _sink;
	PAtomicInteger _threadCount;
private:
	NonCopyable ______nocopy;
};

/** IP v4Õ¯∂Œ
 ÷ß≥÷∑∂Œß∫Õ—⁄¬Î–Œ Ω
 */
class IPv4Range
{
public:
	IPv4Range();
	IPv4Range(const IP & begin, const IP & end);
    
	IP GetBeginIP() const;
	IP GetEndIP() const;
    
	PBOOL Empty() const;
	PBOOL In(const IP & ip) const;
    
	/** eg. 192.168.1.0-255 or 192.168.1.0-192.168.1.255 for a network range
     192.168.1.0/24 or 192.168.1.0/255.255.255.0 for a networkmask pair
     */
	PBOOL FromString(const PString & str);
	PString ToString(PBOOL full) const;
    
	bool operator < (const IPv4Range & other) const;
	
	IPv4Range operator + (const IPv4Range & other) const;
    
private:
	PBOOL _ParseNetworkAndMask(const PString & str);
	PBOOL _ParseNetworkRange(const PString & str);
	void _Normalize();
private:
	DWORD _begin;
	DWORD _end;
    
};

/** IPv4 auth
 priority: deny > allow
 »Áπ˚¥¶”⁄∑«∑®IP∑∂Œß£¨ƒ«√¥ Ù”⁄∑«∑®IP;
 »Áπ˚≤ª¥¶”⁄∫œ∑®IP∑∂Œß£¨ƒ«√¥“≤ Ù”⁄∑«∑®IP
 
 ∆•≈‰À„∑®ª˘”⁄map
 */
class IPv4Auth
{
public:
	IPv4Auth();
	virtual ~IPv4Auth();
    
	PBOOL IsAllowed(const IP & ip) const;
    
	//…Ë÷√∫œ∑®IP∑∂Œß
	void Allow(const IPv4Range & range);
	//…Ë÷√∑«∑®IP∑∂Œß
	void Deny(const IPv4Range & range);
    
	void Allow(const PString& s);
	void Deny(const PString& s);
    
    
	void Set(const PString& allow, const PString& deny);
    
	void Clear();
private:
	typedef std::map<IPv4Range,bool> RangeMap;
    
	void _Allow(const IPv4Range & range);
	void _Deny(const IPv4Range & range);
    
	void _Add(RangeMap & rm,const IPv4Range & range);
    
	void _Clear();
    
	PBOOL _IsAllowed(const IP & ip) const;
    
	void _Split(const PString & str, PStringArray & array);
private:
    
	RangeMap _allow;
	RangeMap _deny;
    
	PMutex _mutex;
};

///////
class PortRange
{
public:
	PortRange();
	PortRange(WORD min, WORD max);
	WORD GetPort();
	void SetRange(WORD min, WORD max);
private:
	PMutex _mutex;
	WORD _port, _minport, _maxport;
};

#define GUID_SIZE 16

class GloballyUniqueID : public PBYTEArray
{
	PCLASSINFO(GloballyUniqueID, PBYTEArray);
    
public:
	/**@name Construction */
	//@{
	/**Create a new ID.
     The ID created with this will be initialised to a globally unique ID
     as per specification.
     */
	GloballyUniqueID();
    
	/**Create an ID from a C string of hex (as produced by AsString()).
     A useful construct is to construct a OpalGloballyUniqueID() with
     NULL which produces an all zero GUID, etectable with the isNULL()
     function.
     */
	GloballyUniqueID(const char* cstr    /// C string to convert
	);
	/**Create an ID from a PString of hex (as produced by AsString()).
     */
	GloballyUniqueID(const PString& str  /// String of hex to convert
	);
    
	//@}
    
	/**@name Overrides from PObject */
	//@{
	/**Standard stream print function.
     The PObject class has a << operator defined that calls this function
     polymorphically.
     */
	virtual void PrintOn(ostream& strm    /// Stream to output text representation
	) const;
    
	/**Standard stream read function.
     The PObject class has a >> operator defined that calls this function
     polymorphically.
     */
	virtual void ReadFrom(istream& strm    /// Stream to output text representation
	);
    
	/**Create a clone of the ID.
     The duplicate ID has the same value as the source. Required for having
     this object as a key in dictionaries.
     */
	virtual PObject* Clone() const;
    
	/**Get the hash value for the ID.
     Creates a number based on the ID value for use in the hash table of
     a dictionary. Required for having this object as a key in dictionaries.
     */
	virtual PINDEX HashFunction() const;
	//@}
    
	/**@name Operations */
	//@{
	/**Convert the ID to human readable string.
     */
	PString ToString() const;
    
	/**Test if the GUID is null, ie consists of all zeros.
     */
	PBOOL IsNULL() const;
    
	bool operator!() const
	{
		return !IsNULL();
	}
	//@}
};

//ª˘”⁄∂®∆⁄ºÏ≤‚µƒ≥¨ ±
class Timeout
{
public:
	Timeout()
	{
		_start = 0;
		_timeout = 0;
	}
	
	Timeout(DWORD ms)
	{
		SetTimeout(ms);
	}
	
	void SetTimeout(DWORD ms)
	{
		if(((DWORD)-1)==ms){
			_start = 0;
			_timeout = 0;
		}else{
			
			_timeout = ms;
			_start = PTimer::Tick().GetInterval();
		}
	}
	
	DWORD GetTimeout() const
	{
		return _timeout;
	}
	
	void Reset()
	{
		if (_start != 0) {
			_start = PTimer::Tick().GetInterval();
		}
	}
	
	PBOOL IsTimeout() const
	{
		if (_start == 0) {
			return FALSE;
		}
		return (((DWORD) (PTimer::Tick().GetInterval() - _start)) >= _timeout);
	}
	
protected:
	DWORD _start;
	DWORD _timeout;
};


#endif /* defined(__UMPStack__net_type__) */
