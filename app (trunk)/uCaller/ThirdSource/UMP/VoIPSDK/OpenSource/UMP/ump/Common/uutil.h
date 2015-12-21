//
//  uutil.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__uutil__
#define __UMPStack__uutil__

#include "pcommon.h"
#include <algorithm>

// Template of smart pointer
// The class T must have Lock() & Unlock() methods
template< class T> class SmartPtr
{
public:
	explicit SmartPtr(T* t = 0)
    : pt(t)
	{
		Inc();
	}
	SmartPtr(const SmartPtr< T>& p)
    : pt(p.pt)
	{
		Inc();
	}
	~SmartPtr()
	{
		Dec();
	}
	operator bool() const
	{
		return pt != 0;
	}
	T* operator->() const
	{
		return pt;
	}
    
	bool operator==(const SmartPtr< T>& p) const
	{
		return pt == p.pt;
	}
	bool operator!=(const SmartPtr< T>& p) const
	{
		return pt != p.pt;
	}
    
	SmartPtr< T>& operator=(const SmartPtr< T>& p)
	{
		if (pt != p.pt) {
			Dec(), pt = p.pt, Inc();
		}
		return *this;
	}
    
private:
	void Inc() const
	{
		if (pt) {
			pt->Lock();
		}
	}
	void Dec() const
	{
		if (pt) {
			pt->Unlock();
		}
	}
	T& operator*();
    
	T* pt;
};

class NonCopyable
{
public:
	NonCopyable(){}
private:
	NonCopyable(const NonCopyable &);
	const NonCopyable & operator = (const NonCopyable &);
};

#define NOCOPY	private: NonCopyable ______nocopy;



#if (_MSC_VER >= 1200)
#pragma warning( disable : 4355 ) // warning about using 'this' in initializer
#pragma warning( disable : 4786 ) // warning about too long debug symbol off
#pragma warning( disable : 4800 ) // warning about forcing value to bool
#pragma warning( disable : 4284 )
#pragma warning( disable : 4503 )

#endif
#include <list>
#include <vector>
#include <map>

template <class PT>
class deleteobj { // PT is a pointer type
public:
	void operator()(PT pt) { delete pt; }
};

template <class PAIR>
class deletepair { // PAIR::second_type is a pointer type
public:
	void operator()(const PAIR & p) { delete p.second; }
};

template <class C, class F>
inline void ForEachInContainer(const C & c, const F & f)
{
	std::for_each(c.begin(), c.end(), f);
}

template <class C>
inline void DeleteObjectsInContainer(const C & c)
{
	typedef typename C::value_type PT;
	std::for_each(c.begin(), c.end(), deleteobj<PT>());
}

template <class M>
inline void DeleteObjectsInMap(const M & m)
{
	typedef typename M::value_type PAIR;
	std::for_each(m.begin(), m.end(), deletepair<PAIR>());
}

template <class PT>
inline void DeleteObjectsInArray(PT *begin, PT *end)
{
	std::for_each(begin, end, deleteobj<PT>());
}

template <class Iterator>
inline void DeleteObjects(Iterator begin, Iterator end)
{
	typedef typename Iterator::value_type PT;
	std::for_each(begin, end, deleteobj<PT>());
}


#define stricmp strcasecmp

class CaselessStringLess
{
public:
	bool operator()(const char* str1,const char* str2) const
	{
		return stricmp(str1,str2)<0;
	}
};

#if 0
//////////////////////////////////////////////////////////////////////////
template <typename StrType>
class ServerList
{
public:
	typedef std::vector<StrType> StrTypeQueue;
    
protected:
	StrTypeQueue _serversQueue;
	StrType _curServer;
    
public:
	ServerList():
    _curServer(L"")
	{
	}
	virtual ~ServerList()
	{
		_serversQueue.clear();
	}
    
	void Clear()
	{
		_serversQueue.clear();
	}
    
    // 	void AppendServerList(PStringArray const & array)
    // 	{
    // 		//
    // 		for(int i = 0; i < array.GetSize(); i++){
    // 			//
    // 			_serversQueue.push_back(array[i]);
    // 		}
    // 	}
	void AppendServer(StrType const & server)
	{
		//
		_serversQueue.push_back(server);
	}
    
	void ReOrderList()
	{
		//
		StrTypeQueue temp;
		RandOrder(_serversQueue,temp);
		_serversQueue.clear();
        
		for(int i = 0; i < temp.size(); i++){
			_serversQueue.push_back(temp[i]);
		}
	}
    
	StrType GetNextServer()
	{
		if(_serversQueue.size() > 0){
			_curServer = _serversQueue[0];
			_serversQueue.erase(_serversQueue.begin());
		}
		return _curServer;
	}
    
	void ReuseCurServer()
	{
		if(!_curServer.IsEmpty()){
			_serversQueue.insert(_serversQueue.begin(), _curServer);
		}
	}
    
	StrType GetCurServer()
	{
		return _curServer;
	}
    
	PBOOL IsServerInQueue(const StrType &server)
	{
		if(server == _curServer){
			return TRUE;
		}
		for(int i = 0; i < (int)_serversQueue.size(); i++){
			if(_serversQueue.at(i) == server){
				return TRUE;
			}
		}
		return FALSE;
	}
    
	UINT GetServerListCount()
	{
		return _serversQueue.size();
	}
    
	StrType ToString()
	{
		//
		StrType str;
		for(int i = 0; i < _serversQueue.size(); i++){
			str += _serversQueue[i] + ";";
		}
		if( str.GetLength() ){
			str = str.Left(str.GetLength()-1);
		}
		return str;
	}
    
private:
	void RandOrder(StrTypeQueue const & src, StrTypeQueue & dest) const
	{
		//
		StrTypeQueue temp = src;
		while( temp.size() > 0){
			int i = rand()%temp.size();
			dest.push_back(temp[i]);
			temp.erase(temp.begin()+i);
		}
	}
};
#endif

#endif /* defined(__UMPStack__uutil__) */
