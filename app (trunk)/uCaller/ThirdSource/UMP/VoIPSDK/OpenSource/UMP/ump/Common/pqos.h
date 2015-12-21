//
//  pqos.h
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__pqos__
#define __UMPStack__pqos__

#include "pcommon.h"

#ifdef P_USE_PRAGMA
#pragma interface
#endif

#ifndef QOS_NOT_SPECIFIED
#define QOS_NOT_SPECIFIED 0xFFFFFFFF
#endif

#ifndef SERVICETYPE
#define SERVICETYPE DWORD
#endif

#ifndef SERVICETYPE_GUARANTEED
#define SERVICETYPE_GUARANTEED 0x00000003
#endif

#ifndef SERVICETYPE_CONTROLLEDLOAD
#define SERVICETYPE_CONTROLLEDLOAD 0x00000002
#endif

#ifndef SERVICETYPE_BESTEFFORT
#define SERVICETYPE_BESTEFFORT 0x00000001
#endif

#define SERVICETYPE_PNOTDEFINED 0xFFFFFFFF

class PQoS : public PObject
{
    PCLASSINFO(PQoS, PObject);
    
public:
    PQoS();
    PQoS(DWORD avgBytesPerSec,
         DWORD winServiceType,
         int DSCPalternative = -1,
         DWORD maxFrameBytes = 1500,
         DWORD peakBytesPerSec = QOS_NOT_SPECIFIED);
    PQoS(int DSCPvalue);
    
    void SetAvgBytesPerSec(DWORD avgBytesPerSec);
    void SetWinServiceType(DWORD winServiceType);
    void SetDSCP(int DSCPvalue);
    void SetMaxFrameBytes(DWORD maxFrameBytes);
    void SetPeakBytesPerSec(DWORD peakBytesPerSec);
    
    DWORD GetTokenRate() const       { return tokenRate;}
    DWORD GetTokenBucketSize() const { return tokenBucketSize;}
    DWORD GetPeakBandwidth() const   { return peakBandwidth;}
    DWORD GetServiceType() const     { return serviceType;}
    int GetDSCP() const              { return dscp;}
    
    static void SetDSCPAlternative(DWORD winServiceType,
                                   UINT dscp);
    static char bestEffortDSCP;
    static char controlledLoadDSCP;
    static char guaranteedDSCP;
    
protected:
    int dscp;
    DWORD tokenRate;
    DWORD tokenBucketSize;
    DWORD peakBandwidth;
    DWORD serviceType;
    
};


#endif /* defined(__UMPStack__pqos__) */
