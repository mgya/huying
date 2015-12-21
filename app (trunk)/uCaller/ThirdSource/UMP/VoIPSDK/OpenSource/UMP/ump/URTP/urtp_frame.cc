//
//  urtp_frame.cxx
//  UMPTest
//
//  Created by thehuah on 14-3-26.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "urtp_frame.h"

URTPFrame::URTPFrame(DWORD payloadSize)
: PBYTEArray(URTP_HEAD_SIZE+payloadSize)
{
	_payloadSize = payloadSize;
	theArray[0] = '\x40';
}

URTPFrame::URTPFrame(const BYTE * buffer, DWORD length)
:PBYTEArray(buffer, length, FALSE)
{
	_payloadSize = length-URTP_HEAD_SIZE;
	if(_payloadSize<0)
		_payloadSize = 0;
	SetMinSize(URTP_HEAD_SIZE + _payloadSize);
}
