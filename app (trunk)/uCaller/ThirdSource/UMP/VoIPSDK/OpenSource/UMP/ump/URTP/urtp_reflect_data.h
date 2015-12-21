//
//  urtp_reflect_data.h
//  UMPStack
//
//  Created by thehuah on 14-3-27.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__urtp_reflect_handler__
#define __UMPStack__urtp_reflect_handler__

#include "../Common/pcommon.h"
#include "../Common/parray.h"
#include "../Network/net_type.h"


class URTPReflectData : public PBYTEArray
{
	PCLASSINFO(URTPReflectData,PBYTEArray);
public:
    
	URTPReflectData();
    
	PBOOL HandleData(const void * data, PINDEX len,IPPort & wanAddr);
    
	static void PackAddress(void * ptr,  const IP & ip, WORD port);
	static void ExtractAddress(const void * ptr, IP & ip, WORD & port);
    
};

#endif /* defined(__UMPStack__urtp_reflect_handler__) */
