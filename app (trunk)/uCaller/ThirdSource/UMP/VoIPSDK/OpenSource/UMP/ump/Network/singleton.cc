//
//  singleton.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "singleton.h"

#if PTRACING
static int singleton_cnt = 0;
#endif


// STL


//
// a list of pointers that would delete all objects
// referred by the pointers in the list on destruction
//
template< class T> class listptr : public std::list< void*> {
public:
	listptr()
    : clear_list(false)
	{
	}
	~listptr()
	{
		clear_list = true;
		std::for_each(begin(), end(), delete_obj);
	}
	bool clear_list;
	
private:
	static void delete_obj(void* t)
	{
		delete static_cast< T*>(t);
	}
};



static listptr< SingletonBase> _instance_list;

SingletonBase::SingletonBase(const char* n)
: _name(n)
{
#if PTRACING
	++singleton_cnt;
	PTRACE(4,
           "INFO\tcreate instance: " << _name << '(' << singleton_cnt << ')');
#endif
	_instance_list.push_back(this);
}

SingletonBase::~SingletonBase()
{
#if PTRACING
	--singleton_cnt;
	PTRACE(4,
           "INFO\tdelete instance: " << _name << '(' << singleton_cnt
           << " objects left)");
#endif
	if (!_instance_list.clear_list) {
		_instance_list.remove(this);
	}
}
