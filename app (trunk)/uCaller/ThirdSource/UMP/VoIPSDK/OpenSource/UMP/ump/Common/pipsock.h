//
//  pipsock.h
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__pipsock__
#define __UMPStack__pipsock__

#ifdef P_USE_PRAGMA
#pragma interface
#endif

#include "psocket.h"

/** This class describes a type of socket that will communicate using the
 Internet Protocol.
 If P_HAS_IPV6 is not set, IPv4 only is supported.
 If P_HAS_IPV6 is set, both IPv4 and IPv6 adresses are supported, with
 IPv4 as default. This allows to transparently use IPv4, IPv6 or Dual
 stack operating systems.
 */
class PIPSocket : public PSocket
{
    PCLASSINFO(PIPSocket, PSocket);
protected:
    /* Create a new Internet Protocol socket based on the port number
     specified.
     */
    PIPSocket();
    
public:
    /**
     A class describing an IP address
     */
    class Address : public PObject {
    public:
        
        /**@name Address constructors */
        //@{
        /// Create an IPv4 address with the default address: 127.0.0.1 (loopback)
        Address();
        
        /** Create an IP address from string notation.
         eg dot notation x.x.x.x. for IPv4, or colon notation x:x:x::xxx for IPv6
         */
        Address(const PString & dotNotation);
        
        /// Create an IPv4 or IPv6 address from 4 or 16 byte values
        Address(PINDEX len, const BYTE * bytes);
        
        /// Create an IP address from four byte values
        Address(BYTE b1, BYTE b2, BYTE b3, BYTE b4);
        
        /// Create an IPv4 address from a four byte value in network byte order
        Address(DWORD dw);
        
        /// Create an IPv4 address from an in_addr structure
        Address(const in_addr & addr);
        
#if P_HAS_IPV6
        /// Create an IPv6 address from an in_addr structure
        Address(const in6_addr & addr);
        
        /// Create an IP (v4 or v6) address from a sockaddr (sockaddr_in,
        /// sockaddr_in6 or sockaddr_in6_old) structure
        Address(const int ai_family, const int ai_addrlen,struct sockaddr *ai_addr);
#endif
        
#ifdef __NUCLEUS_NET__
        Address(const struct id_struct & addr);
        Address & operator=(const struct id_struct & addr);
#endif
        
        /// Copy an address from another IP v4 address
        Address & operator=(const in_addr & addr);
        
#if P_HAS_IPV6
        /// Copy an address from another IPv6 address
        Address & operator=(const in6_addr & addr);
#endif
        
        /// Copy an address from a string
        Address & operator=(const PString & dotNotation);
        
        /// Copy an address from a four byte value in network order
        Address & operator=(DWORD dw);
        //@}
        
        /// Compare two adresses for absolute (in)equality
        Comparison Compare(const PObject & obj) const;
        bool operator==(const Address & addr) const { return Compare(addr) == EqualTo; }
        bool operator!=(const Address & addr) const { return Compare(addr) != EqualTo; }
#if P_HAS_IPV6
        bool operator==(in6_addr & addr) const;
        bool operator!=(in6_addr & addr) const { return !operator==(addr); }
#endif
        bool operator==(in_addr & addr) const;
        bool operator!=(in_addr & addr) const { return !operator==(addr); }
        bool operator==(DWORD dw) const;
        bool operator!=(DWORD dw) const   { return !operator==(dw); }

        bool operator==(int i) const      { return  operator==((DWORD)i); }
        bool operator!=(int i) const      { return !operator==((DWORD)i); }
        
        /// Compare two addresses for equivalence. This will return TRUE
        /// if the two addresses are equivalent even if they are IPV6 and IPV4
#if P_HAS_IPV6
        bool operator*=(const Address & addr) const;
#else
        bool operator*=(const Address & addr) const { return operator==(addr); }
#endif
        
        /// Format an address as a string
        PString AsString() const;
        
        /// Convert string to IP address. Returns TRUE if was a valid address.
        PBOOL FromString(
                        const PString & str
                        );
        
        /// Format an address as a string
        operator PString() const;
        
        /// Return IPv4 address in network order
        operator in_addr() const;
        
#if P_HAS_IPV6
        /// Return IPv4 address in network order
        operator in6_addr() const;
#endif
        
        /// Return IPv4 address in network order
        operator DWORD() const;
        
        /// Return first byte of IPv4 address
        BYTE Byte1() const;
        
        /// Return second byte of IPv4 address
        BYTE Byte2() const;
        
        /// Return third byte of IPv4 address
        BYTE Byte3() const;
        
        /// Return fourth byte of IPv4 address
        BYTE Byte4() const;
        
        /// return specified byte of IPv4 or IPv6 address
        BYTE operator[](PINDEX idx) const;
        
        /// Get the address length (will be either 4 or 16)
        PINDEX GetSize() const;
        
        /// Get the pointer to IP address data
        const char * GetPointer() const { return (const char *)&v; }
        
        /// Get the version of the IP address being used
        unsigned GetVersion() const { return version; }
        
        /// Check address 0.0.0.0 or ::
        PBOOL IsValid() const;
        PBOOL IsAny() const;
        
        /// Check address 127.0.0.1 or ::1
        PBOOL IsLoopback() const;
        
        /// Check for Broadcast address 255.255.255.255
        PBOOL IsBroadcast() const;
        
        // Check if the remote address is a private address.
        // For IPV4 this is specified RFC 1918 as the following ranges:
        //    10.0.0.0    - 10.255.255.255.255
        //    172.16.0.0  - 172.31.255.255
        //    192.168.0.0 - 192.168.255.255
        // For IPV6 this is specified as any address having "1111 1110 1î for the first nine bits
        PBOOL IsRFC1918() const ;
        
#if P_HAS_IPV6
        /// Check for v4 mapped i nv6 address ::ffff:a.b.c.d
        PBOOL IsV4Mapped() const;
#endif
        
        static const Address & GetLoopback();
#if P_HAS_IPV6
        static const Address & GetLoopback6();
        static const Address & GetAny6();
#endif
        static const Address & GetBroadcast();
        
    protected:
        /// Runtime test of IP addresse type
        union {
            in_addr four;
#if P_HAS_IPV6
            in6_addr six;
#endif
        } v;
        unsigned version;
        
        /// need this to avoid intepreting string as addresses
        friend ostream & operator<<(ostream & s, const PString & str);
        
        /// output IPv6 & IPv4 address as a string to the specified string
        friend ostream & operator<<(ostream & s, const Address & a);
        
        /// input IPv4 (not IPv6 yet!) address as a string from the specified string
        friend istream & operator>>(istream & s, Address & a);
    };
    
    // Overrides from class PChannel
    /** Get the platform and I/O channel type name of the channel. For an IP
     socket this returns the host name of the peer the socket is connected
     to, followed by the socket number it is connected to.
     
     @return
     the name of the channel.
     */
    virtual PString GetName() const;
    
    // Set the default IP address familly.
    // Needed as lot of IPv6 stack are not able to receive IPv4 packets in IPv6 sockets
    // They are not RFC 2553, chapter 7.3, compliant.
    // As a concequence, when opening a socket to listen to port 1720 (for exemple) from any remot host
    // one must decide whether this an IPv4 or an IPv6 socket...
    static int GetDefaultIpAddressFamily();
    static void SetDefaultIpAddressFamily(int ipAdressFamily); // PF_INET, PF_INET6
    static void SetDefaultIpAddressFamilyV4(); // PF_INET
#if P_HAS_IPV6
    static void SetDefaultIpAddressFamilyV6(); // PF_INET6
    static PBOOL IsIpAddressFamilyV6Supported();
#endif
    static PIPSocket::Address GetDefaultIpAny();
    
    // Open an IPv4 or IPv6 socket
    virtual PBOOL OpenSocket(
                            int ipAdressFamily=PF_INET
                            ) = 0;
    
    
    // Overrides from class PSocket.
    /** Connect a socket to a remote host on the specified port number. This is
     typically used by the client or initiator of a communications channel.
     This connects to a "listening" socket at the other end of the
     communications channel.
     
     The port number as defined by the object instance construction or the
     #PIPSocket::SetPort()# function.
     
     @return
     TRUE if the channel was successfully connected to the remote host.
     */
    virtual PBOOL Connect(
                         const PString & address   ///< Address of remote machine to connect to.
    );
    virtual PBOOL Connect(
                         const Address & addr      ///< Address of remote machine to connect to.
    );
    virtual PBOOL Connect(
                         WORD localPort,           ///< Local port number for connection
                         const Address & addr      ///< Address of remote machine to connect to.
    );
    virtual PBOOL Connect(
                         const Address & iface,    ///< Address of local interface to us.
                         const Address & addr      ///< Address of remote machine to connect to.
    );
    virtual PBOOL Connect(
                         const Address & iface,    ///< Address of local interface to us.
                         WORD localPort,           ///< Local port number for connection
                         const Address & addr      ///< Address of remote machine to connect to.
    );
    
    /** Listen on a socket for a remote host on the specified port number. This
     may be used for server based applications. A "connecting" socket begins
     a connection by initiating a connection to this socket. An active socket
     of this type is then used to generate other "accepting" sockets which
     establish a two way communications channel with the "connecting" socket.
     
     If the #port# parameter is zero then the port number as
     defined by the object instance construction or the
     #PIPSocket::SetPort()# function.
     
     For the UDP protocol, the #queueSize# parameter is ignored.
     
     @return
     TRUE if the channel was successfully opened.
     */
    virtual PBOOL Listen(
                        unsigned queueSize = 5,  ///< Number of pending accepts that may be queued.
                        WORD port = 0,           ///< Port number to use for the connection.
                        Reusability reuse = AddressIsExclusive ///< Can/Cant listen more than once.
    );
    virtual PBOOL Listen(
                        const Address & bind,     ///< Local interface address to bind to.
                        unsigned queueSize = 5,   ///< Number of pending accepts that may be queued.
                        WORD port = 0,            ///< Port number to use for the connection.
                        Reusability reuse = AddressIsExclusive ///< Can/Can't listen more than once.
    );
    
    
    // New functions for class
    /** Get the "official" host name for the host specified or if none, the host
     this process is running on. The host may be specified as an IP number
     or a hostname alias and is resolved to the canonical form.
     
     @return
     Name of the host or IP number of host.
     */
    static PString GetHostName();
    static PString GetHostName(
                               const PString & hostname  ///< Hosts IP address to get name for
    );
    static PString GetHostName(
                               const Address & addr    ///< Hosts IP address to get name for
    );
    
    /** Get the Internet Protocol address for the specified host, or if none
     specified, for the host this process is running on.
     
     @return
     TRUE if the IP number was returned.
     */
    static PBOOL GetHostAddress(
                               Address & addr    ///< Variable to receive hosts IP address
    );
    static PBOOL GetHostAddress(
                               const PString & hostname,
                               /* Name of host to get address for. This may be either a domain name or
                                an IP number in "dot" format.
                                */
                               Address & addr    ///< Variable to receive hosts IP address
    );
    
    /** Get the alias host names for the specified host. This includes all DNS
     names, CNAMEs, names in the local hosts file and IP numbers (as "dot"
     format strings) for the host.
     
     @return
     array of strings for each alias for the host.
     */
    static PStringArray GetHostAliases(
                                       const PString & hostname
    /* Name of host to get address for. This may be either a domain name or
     an IP number in "dot" format.
     */
    );
    static PStringArray GetHostAliases(
                                       const Address & addr    ///< Hosts IP address
    /* Name of host to get address for. This may be either a domain name or
     an IP number in "dot" format.
     */
    );
    
    /** Determine if the specified host is actually the local machine. This
     can be any of the host aliases or multi-homed IP numbers or even
     the special number 127.0.0.1 for the loopback device.
     
     @return
     TRUE if the host is the local machine.
     */
    static PBOOL IsLocalHost(
                            const PString & hostname
    /* Name of host to get address for. This may be either a domain name or
     an IP number in "dot" format.
     */
    );
    
    /** Get the Internet Protocol address for the local host.
     
     @return
     TRUE if the IP number was returned.
     */
    virtual PBOOL GetLocalAddress(
                                 Address & addr    ///< Variable to receive hosts IP address
    );
    virtual PBOOL GetLocalAddress(
                                 Address & addr,    ///< Variable to receive peer hosts IP address
                                 WORD & port        ///< Variable to receive peer hosts port number
    );
    
    /** Get the Internet Protocol address for the peer host the socket is
     connected to.
     
     @return
     TRUE if the IP number was returned.
     */
    virtual PBOOL GetPeerAddress(
                                Address & addr    ///< Variable to receive hosts IP address
    );
    virtual PBOOL GetPeerAddress(
                                Address & addr,    ///< Variable to receive peer hosts IP address
                                WORD & port        ///< Variable to receive peer hosts port number
    );
    
    /** Get the host name for the local host.
     
     @return
     Name of the host, or an empty string if an error occurs.
     */
    PString GetLocalHostName();
    
    /** Get the host name for the peer host the socket is connected to.
     
     @return
     Name of the host, or an empty string if an error occurs.
     */
    PString GetPeerHostName();
    
    /** Clear the name (DNS) cache.
     */
    static void ClearNameCache();
    
    /** Get the IP address that is being used as the gateway, that is, the
     computer that packets on the default route will be sent.
     
     The string returned may be used in the Connect() function to open that
     interface.
     
     Note that the driver does not need to be open for this function to work.
     
     @return
     TRUE if there was a gateway.
     */
    static PBOOL GetGatewayAddress(
                                  Address & addr     ///< Variable to receive the IP address.
    );
    
    /** Get the name for the interface that is being used as the gateway,
     that is, the interface that packets on the default route will be sent.
     
     The string returned may be used in the Connect() function to open that
     interface.
     
     Note that the driver does not need to be open for this function to work.
     
     @return
     
     String name of the gateway device, or empty string if there is none.
     */
    static PString GetGatewayInterface();
    
    /**
     Describes a route table entry
     */
    class RouteEntry : public PObject
    {
        PCLASSINFO(RouteEntry, PObject);
    public:
        /// create a route table entry from an IP address
        RouteEntry(const Address & addr) : network(addr) { }
        
        /// Get the network address associated with the route table entry
        Address GetNetwork() const { return network; }
        
        /// Get the network address mask associated with the route table entry
        Address GetNetMask() const { return net_mask; }
        
        /// Get the default gateway address associated with the route table entry
        Address GetDestination() const { return destination; }
        
        /// Get the network address name associated with the route table entry
        const PString & GetInterface() const { return interfaceName; }
        
        /// Get the network metric associated with the route table entry
        long GetMetric() const { return metric; }
        
    protected:
        Address network;
        Address net_mask;
        Address destination;
        PString interfaceName;
        long    metric;
        
        friend class PIPSocket;
    };
    
    PLIST(RouteTable, RouteEntry);
    
    /** Get the systems route table.
     
     @return
     TRUE if the route table is returned, FALSE if an error occurs.
     */
    static PBOOL GetRouteTable(
                              RouteTable & table      ///< Route table
    );
    
    
    /**
     Describes an interface table entry
     */
    class InterfaceEntry : public PObject
    {
        PCLASSINFO(InterfaceEntry, PObject)
        
    public:
        /// create an interface entry from a name, IP addr and MAC addr
        InterfaceEntry(
                       const PString & _name,
                       const Address & _addr,
                       const Address & _mask,
                       const PString & _macAddr
#if P_HAS_IPV6
                       , const PString & _ip6Addr = PString::Empty()
#endif
        );
        
        /// Print to specified stream
        virtual void PrintOn(
                             ostream &strm   // Stream to print the object into.
        ) const;
        
        /// Get the name of the interface
        const PString & GetName() const { return name; }
        
        /// Get the address associated with the interface
        Address GetAddress() const { return ipAddr; }
        
        PBOOL HasIP6Address() const
#if ! P_HAS_IPV6
        { return FALSE;}
#else
        { return !ip6Addr.IsEmpty();}
        
        /// Get the address associated with the interface
        Address GetIP6Address() const { return ip6Addr; }
#endif
        
        /// Get the net mask associated with the interface
        Address GetNetMask() const { return netMask; }
        
        /// Get the MAC address associate with the interface
        const PString & GetMACAddress() const { return macAddr; }
        
    protected:
        PString name;
        Address ipAddr;
        Address netMask;
        PString macAddr;
#if P_HAS_IPV6
        PString ip6Addr;
#endif
    };
    
    PLIST(InterfaceTable, InterfaceEntry);
    
    /** Get a list of all interfaces
     @return
     TRUE if the interface table is returned, FALSE if an error occurs.
     */
    static PBOOL GetInterfaceTable(
                                  InterfaceTable & table      ///< interface table
    );
    
    /** Get the address of an interface that corresponds to a real network
     @return
     FALSE if only loopback interfaces could be found, else TRUE
     */
    static PBOOL GetNetworkInterface(PIPSocket::Address & addr);
    
#if P_HAS_RECVMSG
    
    /**
     * Set flag to capture destination address for incoming packets
     *
     * @return TRUE if host is able to capture incoming address, else FALSE
     */
    PBOOL SetCaptureReceiveToAddress()
    { if (!SetOption(IP_PKTINFO, 1, SOL_IP)) return FALSE; catchReceiveToAddr = TRUE; return TRUE; }
    
    /**
     * return the interface address of the last incoming packet
     */
    PIPSocket::Address GetLastReceiveToAddress() const
    { return lastReceiveToAddr; }
    
protected:
    void SetLastReceiveAddr(void * addr, int addrLen)
    { if (addrLen == sizeof(in_addr)) lastReceiveToAddr = *(in_addr *)addr; }
    
    PIPSocket::Address lastReceiveToAddr;
    
#else
    
    /**
     * Set flag to capture interface address for incoming packets
     *
     * @return TRUE if host is able to capture incoming address, else FALSE
     */
    PBOOL SetCaptureReceiveToAddress()
    { return FALSE; }
    
    /**
     * return the interface address of the last incoming packet
     */
    PIPSocket::Address GetLastReceiveToAddress() const
    { return PIPSocket::Address(); }
    
#endif

};

class PIPSocketAddressAndPort
{
public:
    PIPSocketAddressAndPort()
    : port(0)
    { }
    
    PIPSocket::Address address;
    WORD port;
};

typedef std::vector<PIPSocketAddressAndPort> PIPSocketAddressAndPortVector;


#endif /* defined(__UMPStack__pipsock__) */
