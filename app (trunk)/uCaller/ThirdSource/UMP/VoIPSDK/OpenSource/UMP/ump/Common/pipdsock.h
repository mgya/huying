//
//  pipdsock.h
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__pipdsock__
#define __UMPStack__pipdsock__


#include "pipsock.h"

#ifdef P_USE_PRAGMA
#pragma interface
#endif

/** Internet Protocol Datagram Socket class.
 */
class PIPDatagramSocket : public PIPSocket
{
    PCLASSINFO(PIPDatagramSocket, PIPSocket);
protected:
    /**Create a TCP/IP protocol socket channel. If a remote machine address or
     a "listening" socket is specified then the channel is also opened.
     */
    PIPDatagramSocket();
    
    
public:
    // New functions for class
    /**Read a datagram from a remote computer.
     
     @return TRUE if any bytes were sucessfully read.
     */
    virtual PBOOL ReadFrom(
                          void * buf,     ///< Data to be written as URGENT TCP data.
                          PINDEX len,     ///< Number of bytes pointed to by #buf#.
                          Address & addr, ///< Address from which the datagram was received.
                          WORD & port     ///< Port from which the datagram was received.
    );
    
    /**Write a datagram to a remote computer.
     
     @return TRUE if all the bytes were sucessfully written.
     */
    virtual PBOOL WriteTo(
                         const void * buf,   ///< Data to be written as URGENT TCP data.
                         PINDEX len,         ///< Number of bytes pointed to by #buf#.
                         const Address & addr, ///< Address to which the datagram is sent.
                         WORD port           ///< Port to which the datagram is sent.
    );
    
};

#endif /* defined(__UMPStack__pipdsock__) */
