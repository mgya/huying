/*
 * urtp_utility.h
 *
 *  Created on: 2014年6月26日
 *      Author: thehuah
 */

#ifndef URTP_UTILITY_H_
#define URTP_UTILITY_H_

#include "webrtc/typedefs.h"
#include "webrtc/modules/rtp_rtcp/source/rtp_utility.h"


typedef int8_t              GIPS_Word8;
typedef int16_t             GIPS_Word16;
typedef int32_t             GIPS_Word32;
typedef int64_t             GIPS_Word64;
typedef uint8_t             GIPS_UWord8;
typedef uint16_t            GIPS_UWord16;
typedef uint32_t            GIPS_UWord32;
typedef uint64_t            GIPS_UWord64;


namespace gips
{

namespace ModuleRTPUtility
{
	class URTPUtility
	{
	public:
		URTPUtility(const GIPS_UWord8* rtpData,const GIPS_Word32 dataLength);
	    ~URTPUtility();
	public:
		bool ToRTP(GIPS_UWord8** rtpData,webrtc::WebRtcRTPHeader& parsedPacket,GIPS_UWord32 uSsrc);
		bool ToRTP(GIPS_UWord8** rtpData,GIPS_UWord32 uSsrc,GIPS_Word32* rtpDataLength,GIPS_Word32 payloadType);
		bool ToURTP(GIPS_UWord8** urtpData,GIPS_UWord8 chNumber,GIPS_Word32* urtpDataLength);

	private:
		const GIPS_UWord8* const _ptrRTPDataBegin;
		const GIPS_UWord8* const _ptrRTPDataEnd;
	};

}  // namespace ModuleRTPUtility

}  // namespace gips
#endif /* URTP_UTILITY_H_ */
