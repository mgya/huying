/*
 * URTPEncryption.h
 *
 *  Created on: 2014年6月28日
 *      Author: thehuah
 */

#ifndef URTPENCRYPTION_H_
#define URTPENCRYPTION_H_

//#include "../../gips/common_types.h"
#include "../Common/ump_cypher.h"

//using namespace gips;

class URTPEncryption
{
public:
    static URTPEncryption *getURTPEncryption();
public:
	UMPCypher::TEA & GetCypher() {return _cypher;}
	void SetCypherKey(const PBYTEArray & key){_cypher.SetKey(key);};
public:
	virtual void encrypt(
	        int channel,
	        unsigned char* in_data,
	        unsigned char* out_data,
	        int bytes_in,
	        int* bytes_out);

	    // Decrypts the given data. This should reverse the effects of encrypt().
	    //
	    // Args:
	    //   channel_no: The channel to decrypt data for.
	    //   in_data: The data to decrypt. This data is bytes_in bytes long.
	    //   out_data: The buffer to write the decrypted data to. You may write more
	    //       bytes of decrypted data than what you got as input, up to a maximum
	    //       of gips::kViEMaxMtu if you are encrypting in the video engine, or
	    //       gips::kVoiceEngineMaxIpPacketSizeBytes for the voice engine.
	    //   bytes_in: The number of bytes in the input buffer.
	    //   bytes_out: The number of bytes written in out_data.
	    virtual void decrypt(
	        int channel,
	        unsigned char* in_data,
	        unsigned char* out_data,
	        int bytes_in,
	        int* bytes_out);

	    // Encrypts a RTCP packet. Otherwise, this method has the same contract as
	    // encrypt().
	    virtual void encrypt_rtcp(
	        int channel,
	        unsigned char* in_data,
	        unsigned char* out_data,
	        int bytes_in,
	        int* bytes_out){}

	    // Decrypts a RTCP packet. Otherwise, this method has the same contract as
	    // decrypt().
	    virtual void decrypt_rtcp(
	        int channel,
	        unsigned char* in_data,
	        unsigned char* out_data,
	        int bytes_in,
	        int* bytes_out){}

private:
	    static URTPEncryption* urtpEncryption;
	    UMPCypher::TEA _cypher;
};

#endif /* URTPENCRYPTION_H_ */
