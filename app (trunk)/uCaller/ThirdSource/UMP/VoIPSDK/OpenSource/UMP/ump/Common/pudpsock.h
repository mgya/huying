//
//  pudpsock.h
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__pudpsock__
#define __UMPStack__pudpsock__

#include "pipdsock.h"

#ifdef P_USE_PRAGMA
#pragma interface
#endif

#include "pqos.h"

/**
 A socket channel that uses the UDP transport on the Internet Protocol.
 */
class PUDPSocket : public PIPDatagramSocket
{
    PCLASSINFO(PUDPSocket, PIPDatagramSocket);
    
public:
    /**@name Construction */
    //@{
    /** Create a UDP socket. If a remote machine address or
     a "listening" socket is specified then the channel is also opened.
     */
    PUDPSocket(
               WORD port = 0             ///< Port number to use for the connection.
    );
    PUDPSocket(
               PQoS * qos,              ///< Pointer to a QOS structure for the connection
               WORD port = 0             ///< Port number to use for the connection.
    );
    PUDPSocket(
               const PString & service,   ///< Service name to use for the connection.
               PQoS * qos = NULL          ///< Pointer to a QOS structure for the connection
    );
    PUDPSocket(
               const PString & address,  ///< Address of remote machine to connect to.
               WORD port                 ///< Port number to use for the connection.
    );
    PUDPSocket(
               const PString & address,  ///< Address of remote machine to connect to.
               const PString & service   ///< Service name to use for the connection.
    );
    //@}
    
    /**@name Overrides from class PSocket */
    //@{
    /** Override of PChannel functions to allow connectionless reads
     */
    PBOOL Read(
              void * buf,   ///< Pointer to a block of memory to read.
              PINDEX len    ///< Number of bytes to read.
    );
    
    /** Override of PChannel functions to allow connectionless writes
     */
    PBOOL Write(
               const void * buf, ///< Pointer to a block of memory to write.
               PINDEX len        ///< Number of bytes to write.
    );
    
    /** Override of PSocket functions to allow connectionless writes
     */
    PBOOL Connect(
                 const PString & address   ///< Address of remote machine to connect to.
    );
    //@}
    
    /**@name New functions for class */
    //@{
    /** Set the address to use for connectionless Write() or Windows QoS
     */
    void SetSendAddress(
                        const Address & address,    ///< IP address to send packets.
                        WORD port                   ///< Port to send packets.
    );
    
    /** Get the address to use for connectionless Write().
     */
    void GetSendAddress(
                        Address & address,    ///< IP address to send packets.
                        WORD & port           ///< Port to send packets.
    );
    
    
    /** Change the QOS spec for the socket and try to apply the changes
     */
    virtual PBOOL ModifyQoSSpec(
                               PQoS * qos            ///< QoS specification to use
    );
    
#if P_HAS_QOS
    /** Get the QOS object for the socket.
     */
    virtual PQoS & GetQoSSpec();
#endif
    /** Get the address of the sender in the last connectionless Read().
     Note that thsi only applies to the Read() and not the ReadFrom()
     function.
     */
    void GetLastReceiveAddress(
                               Address & address,    ///< IP address to send packets.
                               WORD & port           ///< Port to send packets.
    );
    
    static PBOOL CheckLocalPort(WORD port);

    static WORD GetLocalPort(WORD startPort);

    /** Check to See if the socket will support QoS on the given local Address
     */
    static PBOOL SupportQoS(const PIPSocket::Address & address);
    
    /** Manually Enable GQoS Support
     */
    static void EnableGQoS();
    //@}
    
protected:
    // Open an IPv4 socket (for backward compatibility)
    virtual PBOOL OpenSocket();
    
    // Open an IPv4 or IPv6 socket
    virtual PBOOL OpenSocket(
                            int ipAdressFamily
                            );
    
    // Create a QOS-enabled socket
    virtual int OpenSocketGQOS(int af, int type, int proto);
    
    // Modify the QOS settings
    virtual PBOOL ApplyQoS();
    
    virtual const char * GetProtocolName() const;
    
    Address sendAddress;
    WORD    sendPort;
    
    Address lastReceiveAddress;
    WORD    lastReceivePort;
    
    PQoS    qosSpec;

};


#endif /* defined(__UMPStack__pudpsock__) */
