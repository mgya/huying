/*
 * URTPEncryption.cxx
 *
 *  Created on: 2014年6月28日
 *      Author: thehuah
 */

#include "urtp_encryption.h"

URTPEncryption* URTPEncryption::urtpEncryption = 0;

URTPEncryption *URTPEncryption::getURTPEncryption()
{
    if(urtpEncryption == 0)
    {
    	urtpEncryption = new URTPEncryption();
    }
    //setEncryption(urtpEncryption);
    return urtpEncryption;
}

void URTPEncryption::encrypt(
	        int channel,
	        unsigned char* in_data,
	        unsigned char* out_data,
	        int bytes_in,
	        int* bytes_out)
{
	//ModuleRTPUtility::URTPUtility urtpUtil(in_data,bytes_in);
	//urtpUtil.ToURTP((GIPS_UWord8**)&in_data,channel);
	if(_cypher.HasKey())
		_cypher.Encode(in_data,bytes_in,out_data);
	*bytes_out = bytes_in;
}

void URTPEncryption::decrypt(
	        int channel,
	        unsigned char* in_data,
	        unsigned char* out_data,
	        int bytes_in,
	        int* bytes_out)
{
	if(_cypher.HasKey())
		_cypher.Decode(in_data,bytes_in,out_data);
	*bytes_out = bytes_in;
	//ModuleRTPUtility::URTPUtility urtpUtil(out_data,bytes_in);
	//urtpUtil.ToRTP((GIPS_UWord8**)&out_data,1234567890);
}



