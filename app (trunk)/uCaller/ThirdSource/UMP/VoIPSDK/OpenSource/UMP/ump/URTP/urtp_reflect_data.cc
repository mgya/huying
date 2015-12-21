//
//  urtp_reflect_data.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-27.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "urtp_reflect_data.h"
#include "../Common/ump_cypher.h"

URTPReflectData::URTPReflectData()
{
	PBYTEArray::operator = (UMPCypher::RandomKey(10));
	
}

PBOOL URTPReflectData::HandleData(const void * data, PINDEX len, IPPort & wanAddr)
{
	if (len != (PINDEX)(GetSize() + sizeof(DWORD) + sizeof(WORD)))
		return FALSE;
	
	if (memcmp(theArray, data,GetSize()) != 0)
		return FALSE;
    
	IP ip;
	WORD port = 0;
	ExtractAddress(((BYTE*)data) + GetSize(), ip, port);
	if(!ip.IsValid()||
       port == 0)
		return FALSE;
    
	wanAddr.SetIP(ip);
	wanAddr.SetPort(port);
	return TRUE;
}

void URTPReflectData::PackAddress(void * ptr,  const IP & ip, WORD port)
{
	*((PUInt32b*)ptr) = ~((DWORD)ip);
	*((PUInt16b*)(((BYTE*)ptr) + sizeof(DWORD))) = (WORD)~port;
}

void URTPReflectData::ExtractAddress(const void * ptr, IP & ip, WORD & port)
{
	ip = (~*((PUInt32b*)ptr));
	port = ((WORD)~*((PUInt16b*)(((BYTE*)ptr) + sizeof(DWORD))));
}