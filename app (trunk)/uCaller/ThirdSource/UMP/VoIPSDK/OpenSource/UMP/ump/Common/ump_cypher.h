//
//  ump_cypher.h
//  UMPStack
//
//  Created by thehuah on 14-3-5.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef UMP_CYPHER_H
#define UMP_CYPHER_H

//#include "sig_tag.h"
#include "pcommon.h"
#include "pstring.h"
#include "parray.h"

#define UMP_MD5_SIZE 16


//to cheat VC6's classview
#ifndef _NAMESPACE
#ifdef NEVER_DEFINED
#define _NAMESPACE struct
#else
#define _NAMESPACE namespace
#endif
#endif
_NAMESPACE UMPCypher
{
    
	/* Byte array∫Õ16Ω¯÷∆◊÷∑˚¥Æª•◊™
     */
	class Hex : public PString
	{
	public:
		Hex(const PString & hex);
		Hex(const PBYTEArray & bin);
		Hex(const void * bin, PINDEX len);
        
		void ToBin(PBYTEArray & bin) const;
		PBYTEArray ToBin() const;
	private:
		void InternalProcess(const void * bin, PINDEX len);
		static int Char2Int(char c);
        
	};
    
	class MD5
	{
	public:
		MD5(const void* in, PINDEX len);
		MD5(const PBYTEArray& in);
		const PBYTEArray & GetValue() const {return _value;}
	private:
		PBYTEArray _value;
	};
    
	class RandomKey : public PBYTEArray
	{
	public:
		RandomKey(PINDEX size);
	};
	
	
	/** convert byte array into a string/string to byte array
     */
	class NREncoder : public PString
	{
	public:
		NREncoder(const PBYTEArray & bin);
	};
    
	class NRDecoder : public PBYTEArray
	{
	public:
		NRDecoder(const PString & str);
	};
	
	
	/** Tiny Encryption Algorithm (modified).
     This class implements the Tiny Encryption Algorithm by David Wheeler and
     Roger Needham at Cambridge University.
     
     This is a simple algorithm using a 128 bit binary key and encrypts data in
     64 bit blocks.
     */
	
	class TEA
	{
	public:
		TEA(const void* key, PINDEX len);
		TEA(const PBYTEArray & key);
        
		TEA();
		virtual ~TEA();
		
		void SetKey(const void* key, PINDEX len);
		void SetKey(const PBYTEArray & key);
        
		PBOOL HasKey() const{return _hasKey;}
        
		
		void Encode(const void* clear, PINDEX len, void* coded) const;
		PBYTEArray Encode(const PBYTEArray & clear) const;
        
		void Decode(const void* coded, PINDEX len, void* clear) const;
		PBYTEArray Decode(const PBYTEArray & coded) const;
        
	private:
		DWORD k0, k1, k2, k3;
        
		PBYTEArray _subKey;
		PBOOL _hasKey;	
	};
};


#endif
