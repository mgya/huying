/*
 * urtp_utility.cxx
 *
 *  Created on: 2014年6月26日
 *      Author: thehuah
 */
#include "urtp_utility.h"

#include "webrtc/system_wrappers/interface/trace.h"

using namespace webrtc;

namespace gips {

namespace ModuleRTPUtility {

URTPUtility::URTPUtility(const GIPS_UWord8* rtpData,const GIPS_Word32 rtpDataLength)
  : _ptrRTPDataBegin(rtpData),
    _ptrRTPDataEnd(rtpData ? (rtpData + rtpDataLength) : NULL) {
}

URTPUtility::~URTPUtility() {
}

bool URTPUtility::ToRTP(GIPS_UWord8** rtpData,WebRtcRTPHeader& parsedPacket,GIPS_UWord32 uSsrc)
{
  const ptrdiff_t length = _ptrRTPDataEnd - _ptrRTPDataBegin;
  if (length < 8) {
      return false;
    }

  // Version
  const GIPS_UWord8 V  = (GIPS_UWord8)((_ptrRTPDataBegin[0] >> 6) & 0x03);
  if (V != 1) {
        return false;
      }
  // Padding
  const bool          P  = ((_ptrRTPDataBegin[0] & 0x20) == 0) ? false : true;
  // eXtension
//  const bool          X  = ((_ptrRTPDataBegin[0] & 0x10) == 0) ? false : true;
  const GIPS_UWord8 CC = _ptrRTPDataBegin[0] & 0x0f;

  const bool          M  = ((_ptrRTPDataBegin[0] & '\x08') == 0) ? false : true;
  const GIPS_UWord8 PT = 18;

  const GIPS_UWord16 sequenceNumber = (_ptrRTPDataBegin[2] << 8) + _ptrRTPDataBegin[3];

  const GIPS_UWord8* ptr = &_ptrRTPDataBegin[4];
  GIPS_UWord32 RTPTimestamp = *ptr++ << 24;
  RTPTimestamp += *ptr++ << 16;
  RTPTimestamp += *ptr++ << 8;
  RTPTimestamp += *ptr++;

  GIPS_UWord32 SSRC = uSsrc;

  parsedPacket.header.markerBit      = M;
  parsedPacket.header.payloadType    = PT;
  parsedPacket.header.sequenceNumber = sequenceNumber;
  parsedPacket.header.timestamp      = RTPTimestamp;
  parsedPacket.header.ssrc           = SSRC;
  parsedPacket.header.numCSRCs       = CC;
  parsedPacket.header.paddingLength  = P ? *(_ptrRTPDataEnd - 1) : 0;

  parsedPacket.type.Audio.numEnergy = parsedPacket.header.numCSRCs;

  parsedPacket.header.headerLength   = 12;

  // If in effect, MAY be omitted for those packets for which the offset
  // is zero.
  //parsedPacket.extension.transmissionTimeOffset = 0;
    parsedPacket.ntp_time_ms = 0;
#if 0
  GIPS_UWord8* newRTPData = (GIPS_UWord8*)malloc(length - 8 + 12);

  newRTPData[0] = static_cast<GIPS_UWord8>(0x80);            // version 2
  newRTPData[1] = static_cast<GIPS_UWord8>(PT);
  if (M)
  {
	  newRTPData[1] |= kRtpMarkerBitMask;  // MarkerBit is set
  }
  ModuleRTPUtility::AssignUWord16ToBuffer(newRTPData+2, sequenceNumber);
  ModuleRTPUtility::AssignUWord32ToBuffer(newRTPData+4, RTPTimestamp);
  ModuleRTPUtility::AssignUWord32ToBuffer(newRTPData+8, SSRC);
  memcpy(newRTPData+12,*rtpData+8,length-8);
  free(*rtpData);
  *rtpData = newRTPData;
#endif
  //*rtpData = realloc(*rtpData,length - 8 + 12);
  GIPS_UWord8* newRTPData = *rtpData;
  memmove(newRTPData+12,newRTPData+8,length-8);
  newRTPData[0] = static_cast<GIPS_UWord8>(0x80);            // version 2
  newRTPData[1] = static_cast<GIPS_UWord8>(PT);
  if (M)
  {
	  newRTPData[1] |= kRtpMarkerBitMask;  // MarkerBit is set
  }
  webrtc::RtpUtility::AssignUWord16ToBuffer(newRTPData+2, sequenceNumber);
  webrtc::RtpUtility::AssignUWord32ToBuffer(newRTPData+4, RTPTimestamp);
  webrtc::RtpUtility::AssignUWord32ToBuffer(newRTPData+8, SSRC);
  return true;
}

bool URTPUtility::ToRTP(GIPS_UWord8** rtpData,GIPS_UWord32 uSsrc,GIPS_Word32* rtpDataLength,GIPS_Word32 payloadType)
{
  const ptrdiff_t length = _ptrRTPDataEnd - _ptrRTPDataBegin;
  if (length < 8) {
      return false;
    }

  *rtpDataLength = length -8 + 12;

  WebRtcRTPHeader parsedPacket;
  // Version
  const GIPS_UWord8 V  = (GIPS_UWord8)((_ptrRTPDataBegin[0] >> 6) & 0x03);
  if (V != 1) {
        return false;
      }
  // Padding
  const bool          P  = ((_ptrRTPDataBegin[0] & 0x20) == 0) ? false : true;
  // eXtension
//  const bool          X  = ((_ptrRTPDataBegin[0] & 0x10) == 0) ? false : true;
  const GIPS_UWord8 CC = _ptrRTPDataBegin[0] & 0x0f;

  const bool          M  = ((_ptrRTPDataBegin[0] & '\x08') == 0) ? false : true;
  const GIPS_UWord8 PT = (GIPS_UWord8)payloadType;

  const GIPS_UWord16 sequenceNumber = (_ptrRTPDataBegin[2] << 8) + _ptrRTPDataBegin[3];

  const GIPS_UWord8* ptr = &_ptrRTPDataBegin[4];
  GIPS_UWord32 RTPTimestamp = *ptr++ << 24;
  RTPTimestamp += *ptr++ << 16;
  RTPTimestamp += *ptr++ << 8;
  RTPTimestamp += *ptr++;

  GIPS_UWord32 SSRC = uSsrc;

  parsedPacket.header.markerBit      = M;
  parsedPacket.header.payloadType    = PT;
  parsedPacket.header.sequenceNumber = sequenceNumber;
  parsedPacket.header.timestamp      = RTPTimestamp;
  parsedPacket.header.ssrc           = SSRC;
  parsedPacket.header.numCSRCs       = CC;
  parsedPacket.header.paddingLength  = P ? *(_ptrRTPDataEnd - 1) : 0;

  parsedPacket.type.Audio.numEnergy = parsedPacket.header.numCSRCs;

  parsedPacket.header.headerLength   = 12;

  // If in effect, MAY be omitted for those packets for which the offset
  // is zero.
  //parsedPacket.extension.transmissionTimeOffset = 0;
  parsedPacket.ntp_time_ms = 0;

  //*rtpData = realloc(*rtpData,length - 8 + 12);
  GIPS_UWord8* newRTPData = *rtpData;
  memmove(newRTPData+12,newRTPData+8,length-8);
  newRTPData[0] = static_cast<GIPS_UWord8>(0x80);            // version 2
  newRTPData[1] = static_cast<GIPS_UWord8>(PT);
  if (M)
  {
	  newRTPData[1] |= kRtpMarkerBitMask;  // MarkerBit is set
  }
  webrtc::RtpUtility::AssignUWord16ToBuffer(newRTPData+2, sequenceNumber);
  webrtc::RtpUtility::AssignUWord32ToBuffer(newRTPData+4, RTPTimestamp);
  webrtc::RtpUtility::AssignUWord32ToBuffer(newRTPData+8, SSRC);
  return true;
}

bool URTPUtility::ToURTP(GIPS_UWord8** urtpData,GIPS_UWord8 chNumber,GIPS_Word32* urtpDataLength)
{
  const ptrdiff_t length = _ptrRTPDataEnd - _ptrRTPDataBegin;
  if (length < 12) {
      return false;
    }

  *urtpDataLength = length -12 +8;

    // Version
    const GIPS_UWord8 V  = _ptrRTPDataBegin[0] >> 6;
    if (V != 2) {
          return false;
        }

    // Padding
//    const bool          P  = ((_ptrRTPDataBegin[0] & 0x20) == 0) ? false : true;
    // eXtension
//    const bool          X  = ((_ptrRTPDataBegin[0] & 0x10) == 0) ? false : true;
//    const GIPS_UWord8 CC = _ptrRTPDataBegin[0] & 0x0f;
    const bool          M  = ((_ptrRTPDataBegin[1] & 0x80) == 0) ? false : true;

//    const GIPS_UWord8 PT = _ptrRTPDataBegin[1] & 0x7f;

    const GIPS_UWord16 sequenceNumber = (_ptrRTPDataBegin[2] << 8) +
        _ptrRTPDataBegin[3];

    const GIPS_UWord8* ptr = &_ptrRTPDataBegin[4];

    GIPS_UWord32 RTPTimestamp = *ptr++ << 24;
    RTPTimestamp += *ptr++ << 16;
    RTPTimestamp += *ptr++ << 8;
    RTPTimestamp += *ptr++;
//
//    GIPS_UWord32 SSRC = *ptr++ << 24;
//    SSRC += *ptr++ << 16;
//    SSRC += *ptr++ << 8;
//    SSRC += *ptr++;

    GIPS_UWord8* newURTPData = *urtpData;
    memmove(newURTPData+8,newURTPData+12,length-12);
    //*urtpData = realloc(*urtpData,length - 12 + 8);

    newURTPData[0] = '\x40';
    if(M)
    {
    	newURTPData[0] |= '\x08';
    }
    else
    {
    	newURTPData[0] &= (~'\x08');
    }
    newURTPData[1] = chNumber;
    webrtc::RtpUtility::AssignUWord16ToBuffer(newURTPData+2, sequenceNumber);
    webrtc::RtpUtility::AssignUWord32ToBuffer(newURTPData+4, RTPTimestamp);
    return true;
}

}  // namespace ModuleRTPUtility

}  // namespace gips
