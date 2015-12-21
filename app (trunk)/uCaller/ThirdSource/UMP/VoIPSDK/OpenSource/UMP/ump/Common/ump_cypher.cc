//
//  ump_cypher.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-5.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "pcypher.h"
#include "ump_cypher.h"

static const char i2hex[] = {
	'0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
};

UMPCypher::Hex::Hex(const PString & hex)
:PString(hex)
{
}

UMPCypher::Hex::Hex(const void * bin, PINDEX len)
{
	InternalProcess(bin,len);
}

UMPCypher::Hex::Hex(const PBYTEArray & bin)
{
	InternalProcess(bin,bin.GetSize());
}

void UMPCypher::Hex::ToBin(PBYTEArray & bin) const
{
	PINDEX len = GetLength();
	
	bin.SetSize((len + 1) / 2);
	BYTE * binPtr = bin.GetPointer();
    
	PBOOL extra = len % 2;
	
	if(extra) {
		int l = Char2Int(theArray[0]);
		if(l<0){
			bin.SetSize(0);
			return;
		}
		
		binPtr[0] = (char)l;
	}
	
	int i = (extra?1:0);
	while(i<len){
		int h = Char2Int(theArray[i++]);
		if(h<0){
			bin.SetSize(0);
			return;
		}
		
		int l = Char2Int(theArray[i++]);
		if(l<0){
			bin.SetSize(0);
			return;
		}
		binPtr[(i-1)>>1] = (char)((h<<4)|l);
		
	}
}

PBYTEArray UMPCypher::Hex::ToBin() const
{
	PBYTEArray bin;
	ToBin(bin);
	return bin;
}

void UMPCypher::Hex::InternalProcess(const void * bin, PINDEX len)
{
	SetSize(len * 2 + 1);
	char* ptr = theArray;
	for (PINDEX i = 0; i < len; i++) {
		BYTE b = ((const BYTE *) bin)[i];
        
		*(ptr++) = i2hex[(b>>4)&0xf];
		*(ptr++) = i2hex[b&0xf];
	}
	*ptr = 0;
}


int UMPCypher::Hex::Char2Int(char c)
{
	if(c>='0'&&c<='9')
		return (c-'0');
	
	if(c>='a'&&c<='f')
		return (c+10-'a');
	
	if(c>='A'&&c<='F')
		return (c+10-'A');
	
	return -1;
	
}


UMPCypher::MD5::MD5(const void* in, PINDEX len)
{
	_value.SetSize(UMP_MD5_SIZE);
	PMessageDigest5::Encode(in, len, *((PMessageDigest5::Code *)_value.GetPointer()));
}

UMPCypher::MD5::MD5(const PBYTEArray& in)
{
	_value.SetSize(UMP_MD5_SIZE);
	PMessageDigest5::Encode(in, *((PMessageDigest5::Code *)_value.GetPointer()));
}

UMPCypher::RandomKey::RandomKey(PINDEX size)
{
	SetSize(size);
	for (int i = 0; i < size; i++)
		theArray[i] = (BYTE)(rand()&0xff);
}


/////////


//////////////////
UMPCypher::TEA::TEA(const void* key, PINDEX len)
{
	SetKey(key, len);
}

UMPCypher::TEA::TEA(const PBYTEArray & key)
{
	SetKey(key, key.GetSize());
}

UMPCypher::TEA::~TEA()
{
    
}

UMPCypher::TEA::TEA()
{
	SetKey(NULL, 0);
}
void UMPCypher::TEA::SetKey(const PBYTEArray & key)
{
	SetKey(key, key.GetSize());
}

void UMPCypher::TEA::SetKey(const void* key, PINDEX len)
{
	if(len>0)
	{
		
		MD5 md5(key, len);
        
		const BYTE * p = md5.GetValue();
		
		k0 = ((const PUInt32l *) p)[0];
		k1 = ((const PUInt32l *) p)[1];
		k2 = ((const PUInt32l *) p)[2];
		k3 = ((const PUInt32l *) p)[3];
		
		_subKey = MD5(p, md5.GetValue().GetSize()).GetValue();
		_hasKey=TRUE;
	}
	else
	{
		_hasKey=FALSE;
	}
}

static const DWORD TEADelta = 0x5ac66d85;    // Magic number for key schedule
#define TEA_BLOCK_SIZE	8
PBYTEArray UMPCypher::TEA::Encode(const PBYTEArray & clear) const
{
	PBYTEArray coded;
	Encode(clear,clear.GetSize(), coded.GetPointer(clear.GetSize()));
	return coded;
}

void UMPCypher::TEA::Encode(const void* clear, PINDEX len, void* coded) const
{
    
	if(_hasKey){
        
		PINDEX temp = len;
		
		const BYTE* in = (const BYTE*) clear;
		
		BYTE* out = (BYTE*) coded;
		
		while (len >= TEA_BLOCK_SIZE) {
            
			DWORD y = ((PUInt32b*) in)[0];
			DWORD z = ((PUInt32b*) in)[1];
			DWORD sum = 0;
			for (PINDEX count = 32; count > 0; count--) {
				sum += TEADelta;	// Magic number for key schedule
				y += (z << 4) + k0 ^ z + sum ^ (z >> 5) + k1;
				z += (y << 4) + k2 ^ y + sum ^ (y >> 5) + k3;   /* end cycle */
			}
			((PUInt32b *) out)[0] = y;
			((PUInt32b *) out)[1] = z;
            
			in += TEA_BLOCK_SIZE;
			out += TEA_BLOCK_SIZE;
			len -= TEA_BLOCK_SIZE;
		}
		
		if (len > 0) {
			const PINDEX subKeySize = _subKey.GetSize();
			//do sub encrypt
			for (PINDEX i = 0; i < len; i++){
				if(subKeySize>0){
					out[i] = (BYTE)
                    (in[i] ^ _subKey[_subKey[(i + temp) % subKeySize] % subKeySize]);
				}else
					out[i] = in[i];
			}
		}
	}else{
		if(coded != clear)
			memcpy(coded,clear, len);
	}
	
    
}

/////
PBYTEArray UMPCypher::TEA::Decode(const PBYTEArray & coded) const
{
	PBYTEArray clear;
	Decode(coded,coded.GetSize(), clear.GetPointer(coded.GetSize()));
	return clear;
}

void UMPCypher::TEA::Decode(const void* coded, PINDEX len, void* clear) const
{
	if(_hasKey){
		
		PINDEX temp = len;
		
		const BYTE* in = (const BYTE*) coded;
		BYTE* out = (BYTE*) clear;
		
		while (len >= TEA_BLOCK_SIZE) {
			DWORD y = ((PUInt32b*) in)[0];
			DWORD z = ((PUInt32b*) in)[1];
			
			DWORD sum = TEADelta << 5;
			for (PINDEX count = 32; count > 0; count--) {
				z -= (y << 4) + k2 ^ y + sum ^ (y >> 5) + k3;
				y -= (z << 4) + k0 ^ z + sum ^ (z >> 5) + k1;
				sum -= TEADelta;	// Magic number for key schedule
			}
			((PUInt32b *) out)[0] = y;
			((PUInt32b *) out)[1] = z;
            
			in += TEA_BLOCK_SIZE;
			out += TEA_BLOCK_SIZE;
			len -= TEA_BLOCK_SIZE;
		}
		
		if (len > 0) {
			const PINDEX subKeySize = _subKey.GetSize();
			//do sub decrypt
			for (PINDEX i = 0; i < len; i++)
				if(subKeySize>0){
					out[i] = (BYTE)
                    (in[i] ^ _subKey[_subKey[(i + temp) % subKeySize] % subKeySize]);
				}else
					out[i]=in[i];
		}
	}else{
		if(coded != clear)
			memcpy(clear,coded, len);
	}
}

////////////////

UMPCypher::NREncoder::NREncoder(const PBYTEArray & bin)
{
	PINDEX size = bin.GetSize();
	SetSize(size * 2 + 1);
    
	PINDEX pos = 0;
	const BYTE * p = bin;
	for (PINDEX i = 0; i < size; i++) {
		char c = (char)p[i];
		if (c == 0) {
			theArray[pos++] = '_';
			theArray[pos++] = '0';
		} else if (c == '_') {
			theArray[pos++] = '_';
			theArray[pos++] = '_';
		} else
			theArray[pos++] = c;
	}
	theArray[pos] = 0;
	MakeMinimumSize();
}

UMPCypher::NRDecoder::NRDecoder(const PString & str)
{
	PINDEX pos = 0;
	PINDEX size = str.GetLength();
	
	SetSize(size);
    
	for (PINDEX i = 0; i < size; i++) {
		char c = str[i];
		if (c == '_') {
			if (i + 1 < size) {
				char n = str[i + 1];
				if (n == '_') {
					theArray[pos++] = '_';
					i++;
					continue;
				} else if (n == '0') {
					theArray[pos++] = 0;
					i++;
					continue;
				}
			}
		}
		theArray[pos++] = c;
	}
	SetSize(pos);
	
}
