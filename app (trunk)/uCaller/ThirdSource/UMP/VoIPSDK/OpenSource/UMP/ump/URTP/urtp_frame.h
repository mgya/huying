//
//  urtp_frame.h
//  UMPTest
//
//  Created by thehuah on 14-3-26.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__urtp_frame__
#define __UMPStack__urtp_frame__

#include "../Common/pcommon.h"
#include "../Common/parray.h"


#define URTP_HEAD_SIZE 8

class URTPFrame : public PBYTEArray
{
	PCLASSINFO(URTPFrame, PBYTEArray);
	
public:
	
	URTPFrame(DWORD payloadSize = 0);
	URTPFrame(const BYTE * buffer, DWORD length);
	
	PBOOL IsValid() const{ return (GetVersion()==1);}
	BYTE GetVersion() const{return ((BYTE) ((theArray[0] >> 6) & 0x03));}
	
	DWORD GetHeaderSize() const{return URTP_HEAD_SIZE;}
	
	DWORD GetTotalSize() const{return (GetHeaderSize() + GetPayloadSize());}
	
	PBOOL GetMarker() const{return (theArray[0] & '\x08');}
	void SetMarker(PBOOL m)
	{
		if (m)
			theArray[0] |= '\x08';
		else
			theArray[0] &= (~'\x08');
	}
    
	char GetChannelNumber() const{	return (theArray[1]);}
	void SetChannelNumber(char chNumber){theArray[1] = chNumber;}
	
	WORD GetSequenceNumber() const{	return *(PUInt16b *) &theArray[2];}
	void SetSequenceNumber(WORD seqNumber){*(PUInt16b *) &theArray[2] = seqNumber;}
	
	DWORD GetTimestamp() const{	return *(PUInt32b *) &theArray[4];}
	void SetTimestamp(DWORD t){	*(PUInt32b *) &theArray[4] = t;}
	
	PBOOL SetPayloadSize(DWORD size)
	{
		_payloadSize = size;
		return SetMinSize(URTP_HEAD_SIZE + size);
	}
	
	DWORD GetPayloadSize() const{return _payloadSize;}
	BYTE* GetPayloadPtr() {return (BYTE *) (theArray + URTP_HEAD_SIZE);}
	const BYTE* GetPayloadPtr() const{return (BYTE *) (theArray + URTP_HEAD_SIZE);}
    
protected:
	
	DWORD _payloadSize;
    
};

#endif /* defined(__UMPStack__urtp_frame__) */
