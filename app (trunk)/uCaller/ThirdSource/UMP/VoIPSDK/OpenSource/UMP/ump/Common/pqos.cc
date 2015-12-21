//
//  pqos.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "pqos.h"

char PQoS::bestEffortDSCP = 0;
char PQoS::controlledLoadDSCP = 26;
char PQoS::guaranteedDSCP = 46;


PQoS::PQoS()
{
    serviceType = SERVICETYPE_PNOTDEFINED;
    dscp = -1;
    tokenRate = QOS_NOT_SPECIFIED;
    tokenBucketSize = QOS_NOT_SPECIFIED;
    peakBandwidth = QOS_NOT_SPECIFIED;
}

PQoS::PQoS(int DSCPvalue)
{
    serviceType = SERVICETYPE_PNOTDEFINED;
    dscp = DSCPvalue;
    tokenRate = QOS_NOT_SPECIFIED;
    tokenBucketSize = QOS_NOT_SPECIFIED;
    peakBandwidth = QOS_NOT_SPECIFIED;
}

PQoS::PQoS(DWORD avgBytesPerSec,
           DWORD winServiceType,
           int DSCPalternative,
           DWORD maxFrameBytes,
           DWORD peakBytesPerSec)
{
    tokenRate = avgBytesPerSec;
    serviceType = winServiceType;
    dscp = DSCPalternative;
    tokenBucketSize = maxFrameBytes;
    peakBandwidth = peakBytesPerSec;
}

void PQoS::SetWinServiceType(DWORD winServiceType)
{
    serviceType = winServiceType;
}

void PQoS::SetAvgBytesPerSec(DWORD avgBytesPerSec)
{
    tokenRate = avgBytesPerSec;
}

void PQoS::SetDSCP(int DSCPvalue)
{
    if (DSCPvalue < 63)
        dscp = DSCPvalue;
}

void PQoS::SetMaxFrameBytes(DWORD maxFrameBytes)
{
    tokenBucketSize = maxFrameBytes;
}

void PQoS::SetPeakBytesPerSec(DWORD peakBytesPerSec)
{
    peakBandwidth = peakBytesPerSec;
}


void PQoS::SetDSCPAlternative(DWORD winServiceType, UINT dscp)
{
    if (dscp < 63 &&
        winServiceType != SERVICETYPE_PNOTDEFINED)
    {
        switch (winServiceType)
        {
            case SERVICETYPE_BESTEFFORT:
                bestEffortDSCP = (char)dscp;
                break;
            case SERVICETYPE_CONTROLLEDLOAD:
                controlledLoadDSCP = (char)dscp;
                break;
            case SERVICETYPE_GUARANTEED:
                guaranteedDSCP = (char)dscp;
                break;
        }
    }
}
