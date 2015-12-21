#include <stdlib.h>
#include <string.h>
#include "g729_interface.h"
#include "webrtc/typedefs.h"
#include "basic_op.h"
#include "ld8a.h"
#include "g729a.h"

/*
#include "modules/audio_coding/codecs/g729/interface/g729_interface.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "gtypedef.h"
#include "basic_op.h"
#include "ld8a.h"
#include "g729a.h"
*/
int16_t WebRtcG729_CreateEnc(G729EncInst** inst)
{
	int32_t encodersize = g729a_enc_mem_size();
	*inst = calloc(1, encodersize * sizeof(uint8_t));
	if (*inst == NULL)
	{
		return -1;
	}
	return 0;
}

int16_t WebRtcG729_CreateDec(G729DecInst** inst)
{
	int32_t decodersize = g729a_dec_mem_size();
	*inst = calloc(1, decodersize * sizeof(uint8_t));
	if (*inst == NULL)
	{
		return -1;
	}
	return 0;
}

int16_t WebRtcG729_FreeEnc(G729EncInst* inst)
{
	g729a_enc_deinit(inst);
	free(inst);
	return 0;
}

int16_t WebRtcG729_FreeDec(G729DecInst* inst)
{
	g729a_dec_deinit(inst);
	free(inst);
	return 0;
}

int16_t WebRtcG729_Encode(G729EncInst* encInst, 
								const int16_t* input, 
								int16_t len, 
								uint8_t* output)
{


//	int encodeLen;

	if(len < 80)
		return -1;

	int inpos=0;
	int outpos=0;
	int outlen = 0;
	while(len >= 80)
	{
		//g729a_enc_process(encInst, (short *)input+inpos, (short *)output+outpos);
		g729a_enc_process(encInst, (short *)input+inpos, (unsigned char*)output+outpos);
		len -= 80;
		outlen += 10;
		inpos += 80;
		outpos += 10;
	}


//	g729a_enc_process(encInst, (short *)input, (unsigned char*)output);
//	encodeLen = 10;
	return outlen;
}

int16_t WebRtcG729_EncoderInit(G729EncInst* encInst, int16_t mode)
{
	int en=g729a_enc_init(encInst);
	if(en == 0)
	{
		return -1;
	}
	return 0;
}

int16_t WebRtcG729_Decode(G729DecInst *decInst,
                                const uint8_t *encoded,
                                int16_t len,
                                int16_t *decoded,
                                int16_t *speechType)
{

	int inpos=0;
	int outpos=0;
	int outlen = 0;

	*speechType = 1;

	while(len >= 10)
	{
		g729a_dec_process(decInst, (unsigned char*)encoded+inpos, (short *)decoded+outpos, 0);
		//g729a_dec_process(decInst, (short*)encoded+inpos, (short *)decoded+outpos, 0);
		len -= 10;
		outlen += 80;
		inpos += 10;
		outpos += 80;
	}
	return outlen;
}

int16_t WebRtcG729_DecoderInit(G729DecInst* decInst)
{
	int de=g729a_dec_init(decInst);
	if (de == 0)
	{
		return -1;
	}
	return 0;
}

int16_t WebRtcG729_DecodeBwe(G729DecInst* decInst, int16_t* input)
{
	return 0;
}

int16_t WebRtcG729_DecodePlc(G729DecInst* decInst)
{
	return 0;
}

int16_t WebRtcG729_Version(char *versionStr, short len)
{
        return 0;
}
