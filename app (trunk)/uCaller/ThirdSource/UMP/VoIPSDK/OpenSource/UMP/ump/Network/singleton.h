//
//  singleton.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__singleton__
#define __UMPStack__singleton__


#include "../Common/uutil.h"
#include "../Common/psync.h"


// Base class for all singletons
class SingletonBase {
public:
	SingletonBase(const char*);
	virtual ~SingletonBase();
    
private:
	const char* _name;
	// Note the SingletonBase instance is not singleton itself :p
	// However, list of singletons *are* singleton
	// But we can't put the singleton into the list :(
private:
	NonCopyable ______nocopy;
};

//
// A singleton class should be derived from this template.
// class Ts : public Singleton<Ts> {
//     ...
// };
//
// If the class is instantiated more than once,
// a runtime error would be thrown
//
// I provide two ways to access the singleton:
// (since I'm not sure which is better)
// T::Instance()  or  InstanceOf<T>
//
template< class T>
class Singleton : public SingletonBase
{
public:
	static T& Instance();
    
	static void DestroyInstance();
	static PBOOL HasInstance(){return (_Instance!=NULL);}
    
protected:
	Singleton(const char*);
	~Singleton();
    
    
protected:
	static SingletonBase * _Instance;
	static PMutex _CreationLock;
    
};

template< class T> Singleton<T>::Singleton(const char* n)
: SingletonBase(n)
{
	PAssert((_Instance == 0),"Duplicate singleton instance");
}

template< class T> Singleton<T>::~Singleton()
{
	_Instance = 0;
}

template< class T> void Singleton<T>::DestroyInstance()
{
	PWaitAndSignal lock(_CreationLock);
	delete _Instance;
}


// Function to access the singleton
template< class T> T& Singleton<T>::Instance()
{
	if (_Instance == 0) {
		PWaitAndSignal lock(_CreationLock);
		// We have to check it again after we got the lock
		if (_Instance == 0) {
			_Instance = new T;
		}
	}
	return *((T*)_Instance);
}

// Function to access the singleton
template< class T> T& InstanceOf()
{
    
	return Singleton< T>::Instance();
}

// static members
template< class T> SingletonBase * Singleton< T> ::_Instance = 0;
template< class T> PMutex Singleton< T> ::_CreationLock;


#endif /* defined(__UMPStack__singleton__) */
