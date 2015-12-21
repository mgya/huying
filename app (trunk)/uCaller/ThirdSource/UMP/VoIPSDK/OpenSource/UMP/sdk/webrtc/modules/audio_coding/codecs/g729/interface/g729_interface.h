/*
 *  Copyright (c) 2011 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef MODULES_AUDIO_CODING_CODECS_G729_MAIN_INTERFACE_G729_INTERFACE_H_
#define MODULES_AUDIO_CODING_CODECS_G729_MAIN_INTERFACE_G729_INTERFACE_H_

#include "webrtc/typedefs.h"

/*
 * Solution to support multiple instances
 */

typedef struct G729_encinst_t_ G729EncInst;
typedef struct G729_decinst_t_ G729DecInst;

/*
 * Comfort noise constants
 */

#define G722_WEBRTC_SPEECH     1
#define G722_WEBRTC_CNG        2

#ifdef __cplusplus
extern "C" {
#endif


int16_t WebRtcG729_CreateEnc(G729EncInst** inst);
int16_t WebRtcG729_CreateDec(G729DecInst** inst);
int16_t WebRtcG729_FreeEnc(G729EncInst* inst);
int16_t WebRtcG729_FreeDec(G729DecInst* inst);
int16_t WebRtcG729_Encode(G729EncInst* encInst, const int16_t* input, int16_t len, uint8_t* output);
int16_t WebRtcG729_EncoderInit(G729EncInst* encInst, int16_t mode);
int16_t WebRtcG729_Decode(G729DecInst *G729dec_inst, const uint8_t *encoded, int16_t len, int16_t *decoded, int16_t *speechType);
int16_t WebRtcG729_DecodeBwe(G729DecInst* decInst, int16_t* input);
int16_t WebRtcG729_DecodePlc(G729DecInst* decInst);
int16_t WebRtcG729_DecoderInit(G729DecInst* decInst);
int16_t WebRtcG729_Version(char *versionStr, short len);

/**
int16_t WebRtcG722_CreateEncoder(G722EncInst **G722enc_inst);
int16_t WebRtcG722_EncoderInit(G722EncInst *G722enc_inst);
int16_t WebRtcG722_FreeEncoder(G722EncInst *G722enc_inst);
int16_t WebRtcG722_Encode(G722EncInst* G722enc_inst,
                          const int16_t* speechIn,
                          int16_t len,
                          uint8_t* encoded);
int16_t WebRtcG722_CreateDecoder(G722DecInst **G722dec_inst);
int16_t WebRtcG722_DecoderInit(G722DecInst *G722dec_inst);
int16_t WebRtcG722_FreeDecoder(G722DecInst *G722dec_inst);
int16_t WebRtcG722_Decode(G722DecInst *G722dec_inst,
                          const uint8_t* encoded,
                          int16_t len,
                          int16_t *decoded,
                          int16_t *speechType);
int16_t WebRtcG722_Version(char *versionStr, short len);
*/

#ifdef __cplusplus
}
#endif


#endif /* MODULES_AUDIO_CODING_CODECS_G729_MAIN_INTERFACE_G729_INTERFACE_H_ */
