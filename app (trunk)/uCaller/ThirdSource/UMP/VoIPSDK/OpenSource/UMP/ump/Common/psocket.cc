//
//  psocket.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "psocket.h"

#include <ctype.h>
#include <netdb.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <net/if.h>

#include "pipsock.h"
#include "pipdsock.h"
#include "pudpsock.h"
#include "ptcpsock.h"
#include "ptimer.h"
#include "pprocess.h"

#if defined(SIOCGENADDR)
#define SIO_Get_MAC_Address SIOCGENADDR
#define  ifr_macaddr         ifr_ifru.ifru_enaddr
#elif defined(SIOCGIFHWADDR)
#define SIO_Get_MAC_Address SIOCGIFHWADDR
#define  ifr_macaddr         ifr_hwaddr.sa_data
#endif

#if defined(P_MACOSX) || defined(P_MACOS)
#define ifr_netmask ifr_addr

#include <sys/sysctl.h>

#include <net/if_dl.h>
#include <net/if_types.h>
#include <net/route.h>

#include <netinet/in.h>
#include <netinet/if_ether.h>

#define ROUNDUP(a) \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

#endif

int PX_NewHandle(const char *, int);

//////////////////////////////////////////////////////////////////////////////
// P_fd_set

void P_fd_set::Construct()
{
    max_fd = PProcess::Current().GetMaxHandles();
    set = (fd_set *)malloc((max_fd+7)>>3);
}


void P_fd_set::Zero()
{
    if (PAssertNULL(set) != NULL)
        memset(set, 0, (max_fd+7)>>3);
}


//////////////////////////////////////////////////////////////////////////////

PSocket::~PSocket()
{
    os_close();
}

int PSocket::os_close()
{
    if (os_handle < 0)
        return -1;
    
    // send a shutdown to the other end
    ::shutdown(os_handle, 2);
    
    return PXClose();
}


static int SetNonBlocking(int fd)
{
    if (fd < 0)
        return -1;
    
    // Set non-blocking so we can use select calls to break I/O block on close
    int cmd = 1;
    if (::ioctl(fd, FIONBIO, &cmd) == 0 && ::fcntl(fd, F_SETFD, 1) == 0)
            return fd;
    
    ::close(fd);
    return -1;
}


int PSocket::os_socket(int af, int type, int protocol)
{
    // attempt to create a socket
    return SetNonBlocking(PX_NewHandle(GetClass(), ::socket(af, type, protocol)));
}


PBOOL PSocket::os_connect(struct sockaddr * addr, PINDEX size)
{
    int val;
    //modified by brant
    for(;;) {
        val = ::connect(os_handle, addr, size);
        if(val != 0 && errno == EINTR)
            PThread::Yield();
        else
            break;
    }
    if (val == 0 || errno != EINPROGRESS)
        return ConvertOSError(val);
    
    if (!PXSetIOBlock(PXConnectBlock, readTimeout))
        return FALSE;
    
    // A successful select() call does not necessarily mean the socket connected OK.
    int optval = -1;
    socklen_t optlen = sizeof(optval);
    getsockopt(os_handle, SOL_SOCKET, SO_ERROR, (char *)&optval, &optlen);
    if (optval != 0) {
        errno = optval;
        return ConvertOSError(-1);
    }
    
    return TRUE;
}


PBOOL PSocket::os_accept(PSocket & listener, struct sockaddr * addr, PINDEX * size)
{
    if (!listener.PXSetIOBlock(PXAcceptBlock, listener.GetReadTimeout()))
        return SetErrorValues(listener.GetErrorCode(), listener.GetErrorNumber());
    
#if defined(E_PROTO)
    for (;;) {
        int new_fd = ::accept(listener.GetHandle(), addr, (socklen_t *)size);
        if (new_fd >= 0)
            return ConvertOSError(os_handle = SetNonBlocking(new_fd));
        
        if (errno != EPROTO)
            return ConvertOSError(-1);
        
        PTRACE(3, "PWLib\tAccept on " << sock << " failed with EPROTO - retrying");
    }
#else
    return ConvertOSError(os_handle = SetNonBlocking(::accept(listener.GetHandle(), addr, (socklen_t *)size)));
#endif
}


#if !defined(P_PTHREADS) && !defined(P_MAC_MPTHREADS)

PChannel::Errors PSocket::Select(SelectList & read,
                                 SelectList & write,
                                 SelectList & except,
                                 const PTimeInterval & timeout)
{
    PINDEX i, j;
    PINDEX nextfd = 0;
    int maxfds = 0;
    Errors lastError = NoError;
    PThread * unblockThread = PThread::Current();
    
    P_fd_set fds[3];
    SelectList * list[3] = { &read, &write, &except };
    
    for (i = 0; i < 3; i++) {
        for (j = 0; j < list[i]->GetSize(); j++) {
            PSocket & socket = (*list[i])[j];
            if (!socket.IsOpen())
                lastError = NotOpen;
            else {
                int h = socket.GetHandle();
                fds[i] += h;
                if (h > maxfds)
                    maxfds = h;
            }
            socket.px_selectMutex.Wait();
            socket.px_selectThread = unblockThread;
        }
    }
    
    if (lastError == NoError) {
        P_timeval tval = timeout;
        int result = ::select(maxfds+1,
                              (fd_set *)fds[0],
                              (fd_set *)fds[1],
                              (fd_set *)fds[2],
                              tval);
        
        int osError;
        (void)ConvertOSError(result, lastError, osError);
    }
    
    for (i = 0; i < 3; i++) {
        for (j = 0; j < list[i]->GetSize(); j++) {
            PSocket & socket = (*list[i])[j];
            socket.px_selectThread = NULL;
            socket.px_selectMutex.Signal();
            if (lastError == NoError) {
                int h = socket.GetHandle();
                if (h < 0)
                    lastError = Interrupted;
                else if (!fds[i].IsPresent(h))
                    list[i]->RemoveAt(j--);
            }
        }
    }
    
    return lastError;
}

#else

PChannel::Errors PSocket::Select(SelectList & read,
                                 SelectList & write,
                                 SelectList & except,
                                 const PTimeInterval & timeout)
{
    PINDEX i, j;
    int maxfds = 0;
    Errors lastError = NoError;
    PThread * unblockThread = PThread::Current();
    int unblockPipe = unblockThread->unblockPipe[0];
    
    P_fd_set fds[3];
    SelectList * list[3] = { &read, &write, &except };
    
    for (i = 0; i < 3; i++) {
        for (j = 0; j < list[i]->GetSize(); j++) {
            PSocket & socket = (*list[i])[j];
            if (!socket.IsOpen())
                lastError = NotOpen;
            else {
                int h = socket.GetHandle();
                fds[i] += h;
                if (h > maxfds)
                    maxfds = h;
            }
            socket.px_selectMutex.Wait();
            socket.px_selectThread = unblockThread;
        }
    }
    
    int result = -1;
    if (lastError == NoError) {
        fds[0] += unblockPipe;
        if (unblockPipe > maxfds)
            maxfds = unblockPipe;
        
        P_timeval tval = timeout;
        //modified by brant
        for(;;) {
            result = ::select(maxfds+1, (fd_set *)fds[0], (fd_set *)fds[1], (fd_set *)fds[2], tval);
            if(result < 0 && errno == EINTR)
                PThread::Yield();
            else
                break;
        }
        int osError;
        if (ConvertOSError(result, lastError, osError)) {
            if (fds[0].IsPresent(unblockPipe)) {
                PTRACE(6, "PWLib\tSelect unblocked fd=" << unblockPipe);
                BYTE ch;
                ::read(unblockPipe, &ch, 1);
                lastError = Interrupted;
            }
        }
    }
    
    for (i = 0; i < 3; i++) {
        for (j = 0; j < list[i]->GetSize(); j++) {
            PSocket & socket = (*list[i])[j];
            socket.px_selectThread = NULL;
            socket.px_selectMutex.Signal();
            if (lastError == NoError) {
                int h = socket.GetHandle();
                if (h < 0)
                    lastError = Interrupted;
                else if (!fds[i].IsPresent(h))
                    list[i]->RemoveAt(j--);
            }
        }
    }
    
    return lastError;
}

#endif


PIPSocket::Address::Address(DWORD dw)
{
    operator=(dw);
}


PIPSocket::Address & PIPSocket::Address::operator=(DWORD dw)
{
    if (dw == 0) {
        version = 0;
        memset(&v, 0, sizeof(v));
    }
    else {
        version = 4;
        v.four.s_addr = dw;
    }
    
    return *this;
}


PIPSocket::Address::operator DWORD() const
{
    return version != 4 ? 0 : (DWORD)v.four.s_addr;
}

BYTE PIPSocket::Address::Byte1() const
{
    return *(((BYTE *)&v.four.s_addr)+0);
}

BYTE PIPSocket::Address::Byte2() const
{
    return *(((BYTE *)&v.four.s_addr)+1);
}

BYTE PIPSocket::Address::Byte3() const
{
    return *(((BYTE *)&v.four.s_addr)+2);
}

BYTE PIPSocket::Address::Byte4() const
{
    return *(((BYTE *)&v.four.s_addr)+3);
}

PIPSocket::Address::Address(BYTE b1, BYTE b2, BYTE b3, BYTE b4)
{
    version = 4;
    BYTE * p = (BYTE *)&v.four.s_addr;
    p[0] = b1;
    p[1] = b2;
    p[2] = b3;
    p[3] = b4;
}

PBOOL PIPSocket::IsLocalHost(const PString & hostname)
{
    if (hostname.IsEmpty())
        return TRUE;
    
    if (hostname *= "localhost")
        return TRUE;
    
    // lookup the host address using inet_addr, assuming it is a "." address
    Address addr = hostname;
    if (addr.IsLoopback())  // Is 127.0.0.1
        return TRUE;
    if (!addr.IsValid())
        return FALSE;
    
    if (!GetHostAddress(hostname, addr))
        return FALSE;
    
#if P_HAS_IPV6
    {
        FILE * file;
        int dummy;
        int addr6[16];
        char ifaceName[255];
        PBOOL found = FALSE;
        if ((file = fopen("/proc/net/if_inet6", "r")) != NULL) {
            while (!found && (fscanf(file, "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x %x %x %x %x %255s\n",
                                     &addr6[0],  &addr6[1],  &addr6[2],  &addr6[3],
                                     &addr6[4],  &addr6[5],  &addr6[6],  &addr6[7],
                                     &addr6[8],  &addr6[9],  &addr6[10], &addr6[11],
                                     &addr6[12], &addr6[13], &addr6[14], &addr6[15],
                                     &dummy, &dummy, &dummy, &dummy, ifaceName) != EOF)) {
                Address ip6addr(
                                psprintf("%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
                                         addr6[0],  addr6[1],  addr6[2],  addr6[3],
                                         addr6[4],  addr6[5],  addr6[6],  addr6[7],
                                         addr6[8],  addr6[9],  addr6[10], addr6[11],
                                         addr6[12], addr6[13], addr6[14], addr6[15]
                                         )
                                );
                found = (ip6addr *= addr);
            }
            fclose(file);
        }
        if (found)
            return TRUE;
    }
#endif
    
    PUDPSocket sock;
    
    // check IPV4 addresses
    int ifNum;
#ifdef SIOCGIFNUM
    PAssert(::ioctl(sock.GetHandle(), SIOCGIFNUM, &ifNum) >= 0, "could not do ioctl for ifNum");
#else
    ifNum = 100;
#endif
    
    PBYTEArray buffer;
    struct ifconf ifConf;
    ifConf.ifc_len  = ifNum * sizeof(ifreq);
    ifConf.ifc_req = (struct ifreq *)buffer.GetPointer(ifConf.ifc_len);
    
    if (ioctl(sock.GetHandle(), SIOCGIFCONF, &ifConf) >= 0) {
#ifndef SIOCGIFNUM
        ifNum = ifConf.ifc_len / sizeof(ifreq);
#endif
        
        int num = 0;
        for (num = 0; num < ifNum; num++) {
            
            ifreq * ifName = ifConf.ifc_req + num;
            struct ifreq ifReq;
            strcpy(ifReq.ifr_name, ifName->ifr_name);
            
            if (ioctl(sock.GetHandle(), SIOCGIFFLAGS, &ifReq) >= 0) {
                int flags = ifReq.ifr_flags;
                if (ioctl(sock.GetHandle(), SIOCGIFADDR, &ifReq) >= 0) {
                    if ((flags & IFF_UP) && (addr *= Address(((sockaddr_in *)&ifReq.ifr_addr)->sin_addr)))
                        return TRUE;
                }
            }
        }
    }
    
    return FALSE;
}


////////////////////////////////////////////////////////////////
//
//  PTCPSocket
//
PBOOL PTCPSocket::Read(void * buf, PINDEX maxLen)

{
    lastReadCount = 0;
    
    // wait until select indicates there is data to read, or until
    // a timeout occurs
    if (!PXSetIOBlock(PXReadBlock, readTimeout))
        return FALSE;
    
    // attempt to read out of band data
    char buffer[32];
    int ooblen;
    while ((ooblen = ::recv(os_handle, buffer, sizeof(buffer), MSG_OOB)) > 0)
        OnOutOfBand(buffer, ooblen);
    
    // attempt to read non-out of band data
    int r = ::recv(os_handle, (char *)buf, maxLen, 0);
    if (!ConvertOSError(r, LastReadError))
        return FALSE;
    
    lastReadCount = r;
    return lastReadCount > 0;
}


#if P_HAS_RECVMSG

int PSocket::os_recvfrom(
                         void * buf,     // Data to be written as URGENT TCP data.
                         PINDEX len,     // Number of bytes pointed to by <CODE>buf</CODE>.
                         int    flags,
                         sockaddr * addr, // Address from which the datagram was received.
                         PINDEX * addrlen)
{
    lastReadCount = 0;
    
    if (!PXSetIOBlock(PXReadBlock, readTimeout))
        return FALSE;
    
    // if we don't care what interface the packet arrives on, then don't bother getting the information
    if (!catchReceiveToAddr) {
        int r = ::recvfrom(os_handle, (char *)buf, len, flags, (sockaddr *)addr, (socklen_t *)addrlen);
        if (!ConvertOSError(r, LastReadError))
            return FALSE;
        
        lastReadCount = r;
        return lastReadCount > 0;
    }
    
    msghdr readData;
    memset(&readData, 0, sizeof(readData));
    
    readData.msg_name       = addr;
    readData.msg_namelen    = *addrlen;
    
    iovec readVector;
    readVector.iov_base     = buf;
    readVector.iov_len      = len;
    readData.msg_iov        = &readVector;
    readData.msg_iovlen     = 1;
    
    char auxdata[50];
    readData.msg_control    = auxdata;
    readData.msg_controllen = sizeof(auxdata);
    
    // read a packet
    int r = ::recvmsg(os_handle, &readData, 0);
    if (!ConvertOSError(r, LastReadError))
        return FALSE;
    
    lastReadCount = r;
    
    if (r >= 0) {
        struct cmsghdr * cmsg;
        for (cmsg = CMSG_FIRSTHDR(&readData); cmsg != NULL; cmsg = CMSG_NXTHDR(&readData,cmsg)) {
            if (cmsg->cmsg_level == SOL_IP && cmsg->cmsg_type == IP_PKTINFO) {
                in_pktinfo * info = (in_pktinfo *)CMSG_DATA(cmsg);
                SetLastReceiveAddr(&info->ipi_spec_dst, sizeof(in_addr));
                break;
            }
        }
    }
    
    return lastReadCount > 0;
}

#else

PBOOL PSocket::os_recvfrom(
                          void * buf,     // Data to be written as URGENT TCP data.
                          PINDEX len,     // Number of bytes pointed to by <CODE>buf</CODE>.
                          int    flags,
                          sockaddr * addr, // Address from which the datagram was received.
                          PINDEX * addrlen)
{
    lastReadCount = 0;
    
    if (!PXSetIOBlock(PXReadBlock, readTimeout))
        return FALSE;
    
    // attempt to read non-out of band data
    int r = ::recvfrom(os_handle, (char *)buf, len, flags, (sockaddr *)addr, (socklen_t *)addrlen);
    if (!ConvertOSError(r, LastReadError))
        return FALSE;
    
    lastReadCount = r;
    return lastReadCount > 0;
}

#endif


PBOOL PSocket::os_sendto(
                        const void * buf,   // Data to be written as URGENT TCP data.
                        PINDEX len,         // Number of bytes pointed to by <CODE>buf</CODE>.
                        int flags,
                        sockaddr * addr, // Address to which the datagram is sent.
                        PINDEX addrlen)
{
    lastWriteCount = 0;
    
    if (!IsOpen())
        return SetErrorValues(NotOpen, EBADF, LastWriteError);
    
    // attempt to read data
    int result;
    for (;;) {
        if (addr != NULL)
            result = ::sendto(os_handle, (char *)buf, len, flags, (sockaddr *)addr, addrlen);
        else
            result = ::send(os_handle, (char *)buf, len, flags);
        
        if (result > 0)
            break;
        
        if (errno != EWOULDBLOCK)
            return ConvertOSError(-1, LastWriteError);
        
        if (!PXSetIOBlock(PXWriteBlock, writeTimeout))
            return FALSE;
    }
    
#if !defined(P_PTHREADS) && !defined(P_MAC_MPTHREADS)
    PThread::Yield(); // Starvation prevention
#endif
    
    lastWriteCount = result;
    return ConvertOSError(0, LastWriteError);
}


PBOOL PSocket::Read(void * buf, PINDEX len)
{
    if (os_handle < 0)
        return SetErrorValues(NotOpen, EBADF, LastReadError);
    
    if (!PXSetIOBlock(PXReadBlock, readTimeout))
        return FALSE;
    
    if (ConvertOSError(lastReadCount = ::recv(os_handle, (char *)buf, len, 0)))
        return lastReadCount > 0;
    
    lastReadCount = 0;
    return FALSE;
}

///////////////////////////////////////////////////////////////////////////////

PBOOL PIPSocket::GetGatewayAddress(Address & addr)
{
    RouteTable table;
    if (GetRouteTable(table)) {
        for (PINDEX i = 0; i < table.GetSize(); i++) {
            if (table[i].GetNetwork() == 0) {
                addr = table[i].GetDestination();
                return TRUE;
            }
        }
    }
    return FALSE;
}



PString PIPSocket::GetGatewayInterface()
{
    RouteTable table;
    if (GetRouteTable(table)) {
        for (PINDEX i = 0; i < table.GetSize(); i++) {
            if (table[i].GetNetwork() == 0)
                return table[i].GetInterface();
        }
    }
    return PString();
}

#if defined(P_LINUX)

PBOOL PIPSocket::GetRouteTable(RouteTable & table)
{
	return FALSE;
}

#elif defined(P_MACOSX)

PBOOL process_rtentry(struct rt_msghdr *rtm, char *ptr, unsigned long *p_net_addr,
                     unsigned long *p_net_mask, unsigned long *p_dest_addr, int *p_metric);
PBOOL get_ifname(int index, char *name);

PBOOL PIPSocket::GetRouteTable(RouteTable & table)
{
    int mib[6];
    size_t space_needed;
    char *limit, *buf, *ptr;
    struct rt_msghdr *rtm;
    
    InterfaceTable if_table;
    
    
    // Read the Routing Table
    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = 0;
    mib[4] = NET_RT_DUMP;
    mib[5] = 0;
    
    if (sysctl(mib, 6, NULL, &space_needed, NULL, 0) < 0) {
        printf("sysctl: net.route.0.0.dump estimate");
        return FALSE;
    }
    
    if ((buf = (char *)malloc(space_needed)) == NULL) {
        printf("malloc(%lu)", (unsigned long)space_needed);
        return FALSE;
    }
    
    // read the routing table data
    if (sysctl(mib, 6, buf, &space_needed, NULL, 0) < 0) {
        printf("sysctl: net.route.0.0.dump");
        free(buf);
        return FALSE;
    }
    
    
    // Read the interface table
    if (!GetInterfaceTable(if_table)) {
        printf("Interface Table Invalid\n");
        return FALSE;
    }
    
    
    // Process the Routing Table data
    limit = buf + space_needed;
    for (ptr = buf; ptr < limit; ptr += rtm->rtm_msglen) {
        
        unsigned long net_addr, dest_addr, net_mask;
        int metric;
        char name[16];
        
        rtm = (struct rt_msghdr *)ptr;
        
        if ( process_rtentry(rtm,ptr, &net_addr, &net_mask, &dest_addr, &metric) ){
            
            RouteEntry * entry = new RouteEntry(net_addr);
            entry->net_mask = net_mask;
            entry->destination = dest_addr;
            if ( get_ifname(rtm->rtm_index,name) )
                entry->interfaceName = name;
            entry->metric = metric;
            table.Append(entry);
            
        } // end if
        
    } // end for loop
    
    free(buf);
    return TRUE;
}

PBOOL process_rtentry(struct rt_msghdr *rtm, char *ptr, unsigned long *p_net_addr,
                     unsigned long *p_net_mask, unsigned long *p_dest_addr, int *p_metric) {
    
    struct sockaddr_in *sa_in;
    
    unsigned long net_addr, dest_addr, net_mask;
    int metric;
    
    sa_in = (struct sockaddr_in *)(rtm + 1);
    
    
    // Check for zero length entry
    if (rtm->rtm_msglen == 0) {
        printf("zero length message\n");
        return FALSE;
    }
    
    if ((~rtm->rtm_flags&RTF_LLINFO)
        && (~rtm->rtm_flags&RTF_WASCLONED)  // Free BSD/MAC has it another
        ) {
        
        //strcpy(name, if_table[rtm->rtm_index].GetName);
        
        net_addr=dest_addr=net_mask=metric=0;
        
        // NET_ADDR
        if(rtm->rtm_addrs&RTA_DST ) {
            if(sa_in->sin_family == AF_INET)
                net_addr = sa_in->sin_addr.s_addr;
            
            sa_in = (struct sockaddr_in *)((char *)sa_in + ROUNDUP(sa_in->sin_len));
        }
        
        // DEST_ADDR
        if(rtm->rtm_addrs&RTA_GATEWAY) {
            if(sa_in->sin_family == AF_INET)
                dest_addr = sa_in->sin_addr.s_addr;
            
            sa_in = (struct sockaddr_in *)((char *)sa_in + ROUNDUP(sa_in->sin_len));
        }
        
        // NETMASK
        if(rtm->rtm_addrs&RTA_NETMASK && sa_in->sin_len)
            net_mask = sa_in->sin_addr.s_addr;
        
        if( rtm->rtm_flags&RTF_HOST)
            net_mask = 0xffffffff;
        
        
        *p_metric = metric;
        *p_net_addr = net_addr;
        *p_dest_addr = dest_addr;
        *p_net_mask = net_mask;
        
        return TRUE;
        
    } else {
        return FALSE;
    }
    
}

PBOOL get_ifname(int index, char *name) {
    int mib[6];
    size_t needed;
    char *lim, *buf, *next;
    struct if_msghdr *ifm;
    struct  sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_INET;
    mib[4] = NET_RT_IFLIST;
    mib[5] = index;
    
    if (sysctl(mib, 6, NULL, &needed, NULL, 0) < 0) {
        printf("ERR route-sysctl-estimate");
        return FALSE;
    }
    
    if ((buf = (char *)malloc(needed)) == NULL) {
        printf("ERR malloc");
        return FALSE;
    }
    
    if (sysctl(mib, 6, buf, &needed, NULL, 0) < 0) {
        printf("ERR actual retrieval of routing table");
        free(buf);
        return FALSE;
    }
    
    lim = buf + needed;
    
    next = buf;
    if (next < lim) {
        
        ifm = (struct if_msghdr *)next;
        
        if (ifm->ifm_type == RTM_IFINFO) {
            sdl = (struct sockaddr_dl *)(ifm + 1);
        } else {
            printf("out of sync parsing NET_RT_IFLIST\n");
            free(buf);
            return FALSE;
        }
        next += ifm->ifm_msglen;
        
        strncpy(name, sdl->sdl_data, sdl->sdl_nlen);
        name[sdl->sdl_nlen] = '\0';
        
        free(buf);
        return TRUE;
        
    } else {
        free(buf);
        return FALSE;
    }
    
}

#else // unsupported platform

#if 0
PBOOL PIPSocket::GetRouteTable(RouteTable & table)
{
    // Most of this code came from the source code for the "route" command
    // so it should work on other platforms too.
    // However, it is not complete (the "address-for-interface" function doesn't exist) and not tested!
    
    route_table_req_t reqtable;
    route_req_t *rrtp;
    int i,ret;
    
    ret = get_route_table(&reqtable);
    if (ret < 0)
    {
        return FALSE;
    }
    
    for (i=reqtable.cnt, rrtp = reqtable.rrtp;i>0;i--, rrtp++)
    {
        //the datalink doesn't save addresses/masks for host and default
        //routes, so the route_req_t may not be filled out completely
        if (rrtp->flags & RTF_DEFAULT) {
            //the IP default route is 0/0
            ((struct sockaddr_in *)&rrtp->dst)->sin_addr.s_addr = 0;
            ((struct sockaddr_in *)&rrtp->mask)->sin_addr.s_addr = 0;
            
        } else if (rrtp->flags & RTF_HOST) {
            //host routes are addr/32
            ((struct sockaddr_in *)&rrtp->mask)->sin_addr.s_addr = 0xffffffff;
        }
        
        RouteEntry * entry = new RouteEntry(/* address_for_interface(rrtp->iface) */);
        entry->net_mask = rrtp->mask;
        entry->destination = rrtp->dst;
        entry->interfaceName = rrtp->iface;
        entry->metric = rrtp->refcnt;
        table.Append(entry);
    }
    
    free(reqtable.rrtp);
    
    return TRUE;
#endif // 0
    
    PBOOL PIPSocket::GetRouteTable(RouteTable & table)
    {
#warning Platform requires implemetation of GetRouteTable()
        return FALSE;
    }
#endif
    
    
    // fe800000000000000202e3fffe1ee330 02 40 20 80     eth0
    // 00000000000000000000000000000001 01 80 10 80       lo
    
    PBOOL PIPSocket::GetInterfaceTable(InterfaceTable & list)
    {
        return TRUE;
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // PUDPSocket
    
    void PUDPSocket::EnableGQoS()
    {
    }
    
    PBOOL PUDPSocket::SupportQoS(const PIPSocket::Address & )
    {
        return FALSE;
    }

///////////////////////////////////////////////////////////////////////////////
// PIPSocket::Address

static int defaultIpAddressFamily = PF_INET;  // PF_UNSPEC;   // default to IPV4

static PIPSocket::Address loopback4(127,0,0,1);
static PIPSocket::Address broadcast4(INADDR_BROADCAST);
static PIPSocket::Address any4(INADDR_ANY);
static in_addr inaddr_empty;
#if P_HAS_IPV6
static PIPSocket::Address loopback6(16,(const BYTE *)"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\001");
static PIPSocket::Address any6(16,(const BYTE *)"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0");
#endif


int PIPSocket::GetDefaultIpAddressFamily()
{
    return defaultIpAddressFamily;
}


void PIPSocket::SetDefaultIpAddressFamily(int ipAdressFamily)
{
    defaultIpAddressFamily = ipAdressFamily;
}


void PIPSocket::SetDefaultIpAddressFamilyV4()
{
    SetDefaultIpAddressFamily(PF_INET);
}


#if P_HAS_IPV6

void PIPSocket::SetDefaultIpAddressFamilyV6()
{
    SetDefaultIpAddressFamily(PF_INET6);
}


PBOOL PIPSocket::IsIpAddressFamilyV6Supported()
{
    int s = ::socket(PF_INET6, SOCK_DGRAM, 0);
    if (s < 0)
        return FALSE;
    
    ::close(s);
    return TRUE;
}

#endif


PIPSocket::Address PIPSocket::GetDefaultIpAny()
{
#if P_HAS_IPV6
    if (defaultIpAddressFamily != PF_INET)
        return any6;
#endif
    
    return any4;
}


#if P_HAS_IPV6

class Psockaddr
{
public:
    Psockaddr() { memset(&storage, 0, sizeof(storage)); }
    Psockaddr(const PIPSocket::Address & ip, WORD port);
    sockaddr* operator->() const { return (sockaddr *)&storage; }
    operator sockaddr*()   const { return (sockaddr *)&storage; }
    socklen_t GetSize() const;
    PIPSocket::Address GetIP() const;
    WORD GetPort() const;
private:
    sockaddr_storage storage;
};


Psockaddr::Psockaddr(const PIPSocket::Address & ip, WORD port)
{
    memset(&storage, 0, sizeof(storage));
    
    if (ip.GetVersion() == 6) {
        sockaddr_in6 * addr6 = (sockaddr_in6 *)&storage;
        addr6->sin6_family = AF_INET6;
        addr6->sin6_addr = ip;
        addr6->sin6_port = htons(port);
        addr6->sin6_flowinfo = 0;
        addr6->sin6_scope_id = 0; // Should be set to the right interface....
    }
    else {
        sockaddr_in * addr4 = (sockaddr_in *)&storage;
        addr4->sin_family = AF_INET;
        addr4->sin_addr = ip;
        addr4->sin_port = htons(port);
    }
}


socklen_t Psockaddr::GetSize() const
{
    switch (((sockaddr *)&storage)->sa_family) {
        case AF_INET :
            return sizeof(sockaddr_in);
        case AF_INET6 :
            // RFC 2133 (Old IPv6 spec) size is 24
            // RFC 2553 (New IPv6 spec) size is 28
            return sizeof(sockaddr_in6);
        default :
            return sizeof(storage);
    }
}


PIPSocket::Address Psockaddr::GetIP() const
{
    switch (((sockaddr *)&storage)->sa_family) {
        case AF_INET :
            return ((sockaddr_in *)&storage)->sin_addr;
        case AF_INET6 :
            return ((sockaddr_in6 *)&storage)->sin6_addr;
        default :
            return 0;
    }
}


WORD Psockaddr::GetPort() const
{
    switch (((sockaddr *)&storage)->sa_family) {
        case AF_INET :
            return ntohs(((sockaddr_in *)&storage)->sin_port);
        case AF_INET6 :
            return ntohs(((sockaddr_in6 *)&storage)->sin6_port);
        default :
            return 0;
    }
}

#endif

#if (defined(P_PTHREADS) && !defined(P_THREAD_SAFE_CLIB)) || defined(__NUCLEUS_PLUS__)
#define REENTRANT_BUFFER_LEN 1024
#endif


class PIPCacheData : public PObject
{
    PCLASSINFO(PIPCacheData, PObject)
public:
    PIPCacheData(struct hostent * ent, const char * original);
#if P_HAS_IPV6
    PIPCacheData(struct addrinfo  * addr_info, const char * original);
    void AddEntry(struct addrinfo  * addr_info);
#endif
    const PString & GetHostName() const { return hostname; }
    const PIPSocket::Address & GetHostAddress() const { return address; }
    const PStringList & GetHostAliases() const { return aliases; }
    PBOOL HasAged() const;
private:
    PString            hostname;
    PIPSocket::Address address;
    PStringList        aliases;
    PTime              birthDate;
};



PDICTIONARY(PHostByName_private, PCaselessString, PIPCacheData);

class PHostByName : PHostByName_private
{
public:
    PBOOL GetHostName(const PString & name, PString & hostname);
    PBOOL GetHostAddress(const PString & name, PIPSocket::Address & address);
    PBOOL GetHostAliases(const PString & name, PStringArray & aliases);
private:
    PIPCacheData * GetHost(const PString & name);
    PMutex mutex;
    friend void PIPSocket::ClearNameCache();
};


static PHostByName & pHostByName()
{
    static PHostByName t;
    return t;
}

class PIPCacheKey : public PObject
{
    PCLASSINFO(PIPCacheKey, PObject)
public:
    PIPCacheKey(const PIPSocket::Address & a)
    { addr = a; }
    
    PObject * Clone() const
    { return new PIPCacheKey(*this); }
    
    PINDEX HashFunction() const
    { return (addr[1] + addr[2] + addr[3])%41; }
    
private:
    PIPSocket::Address addr;
};

PDICTIONARY(PHostByAddr_private, PIPCacheKey, PIPCacheData);

class PHostByAddr : PHostByAddr_private
{
public:
    PBOOL GetHostName(const PIPSocket::Address & addr, PString & hostname);
    PBOOL GetHostAddress(const PIPSocket::Address & addr, PIPSocket::Address & address);
    PBOOL GetHostAliases(const PIPSocket::Address & addr, PStringArray & aliases);
private:
    PIPCacheData * GetHost(const PIPSocket::Address & addr);
    PMutex mutex;
    friend void PIPSocket::ClearNameCache();
};

static PHostByAddr & pHostByAddr()
{
    static PHostByAddr t;
    return t;
}

#define new PNEW


//////////////////////////////////////////////////////////////////////////////
// IP Caching

PIPCacheData::PIPCacheData(struct hostent * host_info, const char * original)
{
    if (host_info == NULL) {
        address = 0;
        return;
    }
    
    hostname = host_info->h_name;
    if (host_info->h_addr != NULL)
        address = *(DWORD *)host_info->h_addr;
    aliases.AppendString(host_info->h_name);
    
    PINDEX i;
    for (i = 0; host_info->h_aliases[i] != NULL; i++)
        aliases.AppendString(host_info->h_aliases[i]);
    
    for (i = 0; host_info->h_addr_list[i] != NULL; i++) {
        PIPSocket::Address ip(*(DWORD *)host_info->h_addr_list[i]);
        aliases.AppendString(ip.AsString());
    }
    
    for (i = 0; i < aliases.GetSize(); i++)
        if (aliases[i] *= original)
            return;
    
    aliases.AppendString(original);
}


#if P_HAS_IPV6

PIPCacheData::PIPCacheData(struct addrinfo * addr_info, const char * original)
{
    PINDEX i;
    if (addr_info == NULL) {
        address = 0;
        return;
    }
    
    // Fill Host primary informations
    hostname = addr_info->ai_canonname; // Fully Qualified Domain Name (FQDN)
    if (addr_info->ai_addr != NULL)
        address = PIPSocket::Address(addr_info->ai_family, addr_info->ai_addrlen, addr_info->ai_addr);
    
    // Next entries
    while (addr_info != NULL) {
        AddEntry(addr_info);
        addr_info = addr_info->ai_next;
    }
    
    // Add original as alias or allready added ?
    for (i = 0; i < aliases.GetSize(); i++) {
        if (aliases[i] *= original)
            return;
    }
    
    aliases.AppendString(original);
}


void PIPCacheData::AddEntry(struct addrinfo * addr_info)
{
    PINDEX i;
    
    if (addr_info == NULL)
        return;
    
    // Add canonical name
    PBOOL add_it = TRUE;
    for (i = 0; i < aliases.GetSize(); i++) {
        if (addr_info->ai_canonname != NULL && (aliases[i] *= addr_info->ai_canonname)) {
            add_it = FALSE;
            break;
        }
    }
    
    if (add_it && addr_info->ai_canonname != NULL)
        aliases.AppendString(addr_info->ai_canonname);
    
    // Add IP address
    PIPSocket::Address ip(addr_info->ai_family, addr_info->ai_addrlen, addr_info->ai_addr);
    add_it = TRUE;
    for (i = 0; i < aliases.GetSize(); i++) {
        if (aliases[i] *= ip.AsString()) {
            add_it = FALSE;
            break;
        }
    }
    
    if (add_it)
        aliases.AppendString(ip.AsString());
}

#endif


static PTimeInterval GetConfigTime(const char * /*key*/, DWORD dflt)
{
    //PConfig cfg("DNS Cache");
    //return cfg.GetInteger(key, dflt);
    return dflt;
}


PBOOL PIPCacheData::HasAged() const
{
    static PTimeInterval retirement = GetConfigTime("Age Limit", 300000); // 5 minutes
    PTime now;
    PTimeInterval age = now - birthDate;
    return age > retirement;
}


PBOOL PHostByName::GetHostName(const PString & name, PString & hostname)
{
    PIPCacheData * host = GetHost(name);
    
    if (host != NULL) {
        hostname = host->GetHostName();
        hostname.MakeUnique();
    }
    
    mutex.Signal();
    
    return host != NULL;
}


PBOOL PHostByName::GetHostAddress(const PString & name, PIPSocket::Address & address)
{
    PIPCacheData * host = GetHost(name);
    
    if (host != NULL)
        address = host->GetHostAddress();
    
    mutex.Signal();
    
    return host != NULL;
}


PBOOL PHostByName::GetHostAliases(const PString & name, PStringArray & aliases)
{
    PIPCacheData * host = GetHost(name);
    
    if (host != NULL) {
        const PStringList & a = host->GetHostAliases();
        aliases.SetSize(a.GetSize());
        for (PINDEX i = 0; i < a.GetSize(); i++)
            aliases[i] = a[i];
    }
    
    mutex.Signal();
    return host != NULL;
}


PIPCacheData * PHostByName::GetHost(const PString & name)
{
    mutex.Wait();
    
    PCaselessString key = name;
    PIPCacheData * host = GetAt(key);
    int localErrNo = NETDB_SUCCESS;
    
    if (host != NULL && host->HasAged()) {
        SetAt(key, NULL);
        host = NULL;
    }
    
    if (host == NULL) {
        mutex.Signal();
        
#if P_HAS_IPV6
        struct addrinfo *res;
        struct addrinfo hints = { AI_CANONNAME, PF_UNSPEC };
        hints.ai_family = defaultIpAddressFamily;
        
        localErrNo = getaddrinfo((const char *)name, NULL , &hints, &res);
        mutex.Wait();
        
        if (localErrNo != NETDB_SUCCESS)
            return NULL;
        host = new PIPCacheData(res, name);
        freeaddrinfo(res);
#else // P_HAS_IPV6
        
        int retry = 3;
        struct hostent * host_info;
        
#if defined(P_CYGWIN) || defined(P_MINGW)
        
        host_info = ::gethostbyname(name);
        localErrNo = h_errno;
        
#elif defined P_LINUX
        
        char buffer[REENTRANT_BUFFER_LEN];
        struct hostent hostEnt;
        do {
            if (::gethostbyname_r(name,
                                  &hostEnt,
                                  buffer, REENTRANT_BUFFER_LEN,
                                  &host_info,
                                  &localErrNo) == 0)
                localErrNo = NETDB_SUCCESS;
        } while (localErrNo == TRY_AGAIN && --retry > 0);
        
#elif (defined(P_PTHREADS) && !defined(P_THREAD_SAFE_CLIB)) && !defined(VOIPBASE_IOS) && !defined(VOIPBASE_MAC) || defined(__NUCLEUS_PLUS__)
        
        char buffer[REENTRANT_BUFFER_LEN];
        struct hostent hostEnt;
        do {
            host_info = ::gethostbyname_r(name,
                                          &hostEnt,
                                          buffer, REENTRANT_BUFFER_LEN,
                                          &localErrNo);
        } while (localErrNo == TRY_AGAIN && --retry > 0);
        
#else
        
        host_info = ::gethostbyname(name);
        localErrNo = h_errno;
        
#endif
        
        mutex.Wait();
        
        if (localErrNo != NETDB_SUCCESS || retry == 0)
            return NULL;
        host = new PIPCacheData(host_info, name);
        
#endif //P_HAS_IPV6
        
        SetAt(key, host);
    }
    
    if (host->GetHostAddress() == 0)
        return NULL;
    
    return host;
}


PBOOL PHostByAddr::GetHostName(const PIPSocket::Address & addr, PString & hostname)
{
    PIPCacheData * host = GetHost(addr);
    
    if (host != NULL) {
        hostname = host->GetHostName();
        hostname.MakeUnique();
    }
    
    mutex.Signal();
    return host != NULL;
}


PBOOL PHostByAddr::GetHostAddress(const PIPSocket::Address & addr, PIPSocket::Address & address)
{
    PIPCacheData * host = GetHost(addr);
    
    if (host != NULL)
        address = host->GetHostAddress();
    
    mutex.Signal();
    return host != NULL;
}


PBOOL PHostByAddr::GetHostAliases(const PIPSocket::Address & addr, PStringArray & aliases)
{
    PIPCacheData * host = GetHost(addr);
    
    if (host != NULL) {
        const PStringList & a = host->GetHostAliases();
        aliases.SetSize(a.GetSize());
        for (PINDEX i = 0; i < a.GetSize(); i++)
            aliases[i] = a[i];
    }
    
    mutex.Signal();
    return host != NULL;
}

PIPCacheData * PHostByAddr::GetHost(const PIPSocket::Address & addr)
{
    mutex.Wait();
    
    PIPCacheKey key = addr;
    PIPCacheData * host = GetAt(key);
    
    if (host != NULL && host->HasAged()) {
        SetAt(key, NULL);
        host = NULL;
    }
    
    if (host == NULL) {
        mutex.Signal();
        
        int retry = 3;
        int localErrNo = NETDB_SUCCESS;
        struct hostent * host_info;
        
#if defined VOIPBASE_ANDROID || defined P_CYGWIN || defined P_MINGW
        
        host_info = ::gethostbyaddr(addr.GetPointer(), addr.GetSize(), PF_INET);
        localErrNo = h_errno;
        
#elif defined P_LINUX && !defined(VOIPBASE_ANDROID)
        
        char buffer[REENTRANT_BUFFER_LEN];
        struct hostent hostEnt;
        do {
            ::gethostbyaddr_r(addr.GetPointer(), addr.GetSize(),
                              PF_INET,
                              &hostEnt,
                              buffer, REENTRANT_BUFFER_LEN,
                              &host_info,
                              &localErrNo);
        } while (localErrNo == TRY_AGAIN && --retry > 0);
        
#elif (defined(P_PTHREADS) && !defined(P_THREAD_SAFE_CLIB) && !defined(VOIPBASE_IOS) && !defined(VOIPBASE_MAC)) || defined(__NUCLEUS_PLUS__)
        
        char buffer[REENTRANT_BUFFER_LEN];
        struct hostent hostEnt;
        do {
            host_info = ::gethostbyaddr_r(addr.GetPointer(), addr.GetSize(),
                                          PF_INET,
                                          &hostEnt,
                                          buffer, REENTRANT_BUFFER_LEN,
                                          &localErrNo);
        } while (localErrNo == TRY_AGAIN && --retry > 0);
        
#else
        host_info = ::gethostbyaddr(addr.GetPointer(), addr.GetSize(), PF_INET);
        localErrNo = h_errno;

#endif
        
        mutex.Wait();
        
        if (localErrNo != NETDB_SUCCESS || retry == 0)
            return NULL;
        
        host = new PIPCacheData(host_info, addr.AsString());
        
        SetAt(key, host);
    }
    
    if (host->GetHostAddress() == 0)
        return NULL;
    
    return host;
}


//////////////////////////////////////////////////////////////////////////////
// P_fd_set

#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable:4127)
#endif

P_fd_set::P_fd_set()
{
    Construct();
    Zero();
}


P_fd_set::P_fd_set(SOCKET fd)
{
    Construct();
    Zero();
    FD_SET(fd, set);
}


P_fd_set & P_fd_set::operator=(SOCKET fd)
{
    PAssert(fd < max_fd, PInvalidParameter);
    Zero();
    FD_SET(fd, set);
    return *this;
}


P_fd_set & P_fd_set::operator+=(SOCKET fd)
{
    PAssert(fd < max_fd, PInvalidParameter);
    FD_SET(fd, set);
    return *this;
}


P_fd_set & P_fd_set::operator-=(SOCKET fd)
{
    PAssert(fd < max_fd, PInvalidParameter);
    FD_CLR(fd, set);
    return *this;
}

#ifdef _MSC_VER
#pragma warning(pop)
#endif


//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// PSocket

PSocket::PSocket()
{
    port = 0;
#if P_HAS_RECVMSG
    catchReceiveToAddr = FALSE;
#endif
}


PBOOL PSocket::Connect(const PString &)
{
    PAssertAlways("Illegal operation.");
    return FALSE;
}


PBOOL PSocket::Listen(unsigned, WORD, Reusability)
{
    PAssertAlways("Illegal operation.");
    return FALSE;
}


PBOOL PSocket::Accept(PSocket &)
{
    PAssertAlways("Illegal operation.");
    return FALSE;
}


PBOOL PSocket::SetOption(int option, int value, int level)
{
    return ConvertOSError(::setsockopt(os_handle, level, option,
                                       (char *)&value, sizeof(value)));
}


PBOOL PSocket::SetOption(int option, const void * valuePtr, PINDEX valueSize, int level)
{
    return ConvertOSError(::setsockopt(os_handle, level, option,
                                       (char *)valuePtr, valueSize));
}


PBOOL PSocket::GetOption(int option, int & value, int level)
{
    socklen_t valSize = sizeof(value);
    return ConvertOSError(::getsockopt(os_handle, level, option,
                                       (char *)&value, &valSize));
}


PBOOL PSocket::GetOption(int option, void * valuePtr, PINDEX valueSize, int level)
{
    return ConvertOSError(::getsockopt(os_handle, level, option,
                                       (char *)valuePtr, (socklen_t *)&valueSize));
}


PBOOL PSocket::Shutdown(ShutdownValue value)
{
    return ConvertOSError(::shutdown(os_handle, value));
}


WORD PSocket::GetProtocolByName(const PString & name)
{
#if !defined(__NUCLEUS_PLUS__)
    struct protoent * ent = getprotobyname(name);
    if (ent != NULL)
        return ent->p_proto;
#endif
    
    return 0;
}


PString PSocket::GetNameByProtocol(WORD proto)
{
#if !defined(__NUCLEUS_PLUS__)
    struct protoent * ent = getprotobynumber(proto);
    if (ent != NULL)
        return ent->p_name;
#endif
    
    return psprintf("%u", proto);
}


WORD PSocket::GetPortByService(const PString & serviceName) const
{
    return GetPortByService(GetProtocolName(), serviceName);
}


WORD PSocket::GetPortByService(const char * protocol, const PString & service)
{
    // if the string is a valid integer, then use integer value
    // this avoids stupid problems like operating systems that match service
    // names to substrings (like "2000" to "taskmaster2000")
    if (strspn(service, "0123456789") == strlen(service))
        return (WORD)service.AsUnsigned();
    
    PINDEX space = service.FindOneOf(" \t\r\n");
    struct servent * serv = ::getservbyname(service(0, space-1), protocol);
    if (serv != NULL)
        return ntohs(serv->s_port);
    
    long portNum;
    if (space != P_MAX_INDEX)
        portNum = atol(service(space+1, P_MAX_INDEX));
    else if (isdigit(service[0]))
        portNum = atoi(service);
    else
        portNum = -1;
    
    if (portNum < 0 || portNum > 65535)
        return 0;
    
    return (WORD)portNum;
}


PString PSocket::GetServiceByPort(WORD port) const
{
    return GetServiceByPort(GetProtocolName(), port);
}


PString PSocket::GetServiceByPort(const char * protocol, WORD port)
{
#if !defined(__NUCLEUS_PLUS__)
    struct servent * serv = ::getservbyport(htons(port), protocol);
    if (serv != NULL)
        return PString(serv->s_name);
    else
#endif
        return PString(PString::Unsigned, port);
}


void PSocket::SetPort(WORD newPort)
{
    PAssert(!IsOpen(), "Cannot change port number of opened socket");
    port = newPort;
}


void PSocket::SetPort(const PString & service)
{
    PAssert(!IsOpen(), "Cannot change port number of opened socket");
    port = GetPortByService(service);
}


WORD PSocket::GetPort() const
{
    return port;
}


PString PSocket::GetService() const
{
    return GetServiceByPort(port);
}


int PSocket::Select(PSocket & sock1, PSocket & sock2)
{
    return Select(sock1, sock2, PMaxTimeInterval);
}


int PSocket::Select(PSocket & sock1,
                    PSocket & sock2,
                    const PTimeInterval & timeout)
{
    SelectList read, dummy1, dummy2;
    read += sock1;
    read += sock2;
    
    Errors lastError;
    int osError;
    if (!ConvertOSError(Select(read, dummy1, dummy2, timeout), lastError, osError))
        return lastError;
    
    switch (read.GetSize()) {
        case 0 :
            return 0;
        case 2 :
            return -3;
        default :
            return &read[0] == &sock1 ? -1 : -2;
    }
}


PChannel::Errors PSocket::Select(SelectList & read)
{
    SelectList dummy1, dummy2;
    return Select(read, dummy1, dummy2, PMaxTimeInterval);
}


PChannel::Errors PSocket::Select(SelectList & read, const PTimeInterval & timeout)
{
    SelectList dummy1, dummy2;
    return Select(read, dummy1, dummy2, timeout);
}


PChannel::Errors PSocket::Select(SelectList & read, SelectList & write)
{
    SelectList dummy1;
    return Select(read, write, dummy1, PMaxTimeInterval);
}


PChannel::Errors PSocket::Select(SelectList & read,
                                 SelectList & write,
                                 const PTimeInterval & timeout)
{
    SelectList dummy1;
    return Select(read, write, dummy1, timeout);
}


PChannel::Errors PSocket::Select(SelectList & read,
                                 SelectList & write,
                                 SelectList & except)
{
    return Select(read, write, except, PMaxTimeInterval);
}

//////////////////////////////////////////////////////////////////////////////
// PIPSocket

PIPSocket::PIPSocket()
{
}


void PIPSocket::ClearNameCache()
{
    pHostByName().mutex.Wait();
    pHostByAddr().mutex.Wait();
    pHostByName().RemoveAll();
    pHostByAddr().RemoveAll();
    pHostByName().mutex.Signal();
    pHostByAddr().mutex.Signal();
}


PString PIPSocket::GetName() const
{
#if P_HAS_IPV6
    
    Psockaddr sa;
    socklen_t size = sa.GetSize();
    if (getpeername(os_handle, sa, &size) == 0)
        return GetHostName(sa.GetIP()) + psprintf(":%u", sa.GetPort());
    
#else
    
    sockaddr_in address;
    socklen_t size = sizeof(address);
    if (getpeername(os_handle, (struct sockaddr *)&address, &size) == 0)
        return GetHostName(address.sin_addr) + psprintf(":%u", ntohs(address.sin_port));
    
#endif
    
    return PString::Empty();
}


PString PIPSocket::GetHostName()
{
    char name[100];
    if (gethostname(name, sizeof(name)-1) != 0)
        return "localhost";
    name[sizeof(name)-1] = '\0';
    return name;
}


PString PIPSocket::GetHostName(const PString & hostname)
{
    // lookup the host address using inet_addr, assuming it is a "." address
    Address temp = hostname;
    if (temp != 0)
        return GetHostName(temp);
    
    PString canonicalname;
    if (pHostByName().GetHostName(hostname, canonicalname))
        return canonicalname;
    
    return hostname;
}


PString PIPSocket::GetHostName(const Address & addr)
{
    if (addr == 0)
        return addr.AsString();
    
    PString hostname;
    if (pHostByAddr().GetHostName(addr, hostname))
        return hostname;
    
    return addr.AsString();
}


PBOOL PIPSocket::GetHostAddress(Address & addr)
{
    return pHostByName().GetHostAddress(GetHostName(), addr);
}


PBOOL PIPSocket::GetHostAddress(const PString & hostname, Address & addr)
{
    if (hostname.IsEmpty())
        return FALSE;
    
    // Check for special case of "[ipaddr]"
    if (hostname[0] == '[') {
        PINDEX end = hostname.Find(']');
        if (end != P_MAX_INDEX) {
            if (addr.FromString(hostname(1, end-1)))
                return TRUE;
        }
    }
    
    // Assuming it is a "." address and return if so
    if (addr.FromString(hostname))
        return TRUE;
    
    // otherwise lookup the name as a host name
    return pHostByName().GetHostAddress(hostname, addr);
}


PStringArray PIPSocket::GetHostAliases(const PString & hostname)
{
    PStringArray aliases;
    
    // lookup the host address using inet_addr, assuming it is a "." address
    Address addr = hostname;
    if (addr != 0)
        pHostByAddr().GetHostAliases(addr, aliases);
    else
        pHostByName().GetHostAliases(hostname, aliases);
    
    return aliases;
}


PStringArray PIPSocket::GetHostAliases(const Address & addr)
{
    PStringArray aliases;
    
    pHostByAddr().GetHostAliases(addr, aliases);
    
    return aliases;
}


PBOOL PIPSocket::GetLocalAddress(Address & addr)
{
    WORD dummy;
    return GetLocalAddress(addr, dummy);
}




PBOOL PIPSocket::GetLocalAddress(Address & addr, WORD & portNum)
{
#if P_HAS_IPV6
    Address   addrv4;
    Address   peerv4;
    Psockaddr sa;
    socklen_t size = sa.GetSize();
    if (!ConvertOSError(::getsockname(os_handle, sa, &size)))
        return FALSE;
    
    addr = sa.GetIP();
    portNum = sa.GetPort();
    
    // If the remote host is an IPv4 only host and our interface if an IPv4/IPv6 mapped
    // Then return an IPv4 address instead of an IPv6
    if (GetPeerAddress(peerv4)) {
        if ((peerv4.GetVersion()==4)||(peerv4.IsV4Mapped())) {
            if (addr.IsV4Mapped()) {
                addr = Address(addr[12], addr[13], addr[14], addr[15]);
            }
        }
    }
    
#else
    
    sockaddr_in address;
    socklen_t size = sizeof(address);
    if (!ConvertOSError(::getsockname(os_handle,(struct sockaddr*)&address,&size)))
        return FALSE;
    
    addr = address.sin_addr;
    portNum = ntohs(address.sin_port);
    
#endif
    
    return TRUE;
}


PBOOL PIPSocket::GetPeerAddress(Address & addr)
{
    WORD portNum;
    return GetPeerAddress(addr, portNum);
}

PBOOL PIPSocket::GetPeerAddress(Address & addr, WORD & portNum)
{
#if P_HAS_IPV6
    
    Psockaddr sa;
    socklen_t size = sa.GetSize();
    if (!ConvertOSError(::getpeername(os_handle, sa, &size)))
        return FALSE;
    
    addr = sa.GetIP();
    portNum = sa.GetPort();
    
#else
    
    sockaddr_in address;
    socklen_t size = sizeof(address);
    if (!ConvertOSError(::getpeername(os_handle,(struct sockaddr*)&address,&size)))
        return FALSE;
    
    addr = address.sin_addr;
    portNum = ntohs(address.sin_port);
    
#endif
    
    return TRUE;
}


PString PIPSocket::GetLocalHostName()
{
    Address addr;
    
    if (GetLocalAddress(addr))
        return GetHostName(addr);
    
    return PString::Empty();
}


PString PIPSocket::GetPeerHostName()
{
    Address addr;
    
    if (GetPeerAddress(addr))
        return GetHostName(addr);
    
    return PString::Empty();
}


PBOOL PIPSocket::Connect(const PString & host)
{
    Address ipnum;
#if P_HAS_IPV6
    if (GetHostAddress(host, ipnum))
        return Connect(GetDefaultIpAny(), 0, ipnum);
#else
    if (GetHostAddress(host, ipnum))
        return Connect(INADDR_ANY, 0, ipnum);
#endif
    return FALSE;
}


PBOOL PIPSocket::Connect(const Address & addr)
{
#if P_HAS_IPV6
    return Connect(GetDefaultIpAny(), 0, addr);
#else
    return Connect(INADDR_ANY, 0, addr);
#endif
}


PBOOL PIPSocket::Connect(WORD localPort, const Address & addr)
{
#if P_HAS_IPV6
    return Connect(GetDefaultIpAny(), localPort, addr);
#else
    return Connect(INADDR_ANY, localPort, addr);
#endif
}


PBOOL PIPSocket::Connect(const Address & iface, const Address & addr)
{
    return Connect(iface, 0, addr);
}


PBOOL PIPSocket::Connect(const Address & iface, WORD localPort, const Address & addr)
{
    // close the port if it is already open
    if (IsOpen())
        Close();
    
    // make sure we have a port
    PAssert(port != 0, "Cannot connect socket without setting port");
    
#if P_HAS_IPV6
    
    Psockaddr sa(addr, port);
    
    // attempt to create a socket with the right family
    if (!OpenSocket(sa->sa_family))
        return FALSE;
    
    if (localPort != 0 || iface.IsValid()) {
        Psockaddr bind_sa(iface, localPort);
        
        if (!SetOption(SO_REUSEADDR, 0)) {
            os_close();
            return FALSE;
        }
        
        if (!ConvertOSError(::bind(os_handle, bind_sa, bind_sa.GetSize()))) {
            os_close();
            return FALSE;
        }
    }
    
    // attempt to connect
    if (os_connect(sa, sa.GetSize()))
        return TRUE;
    
#else
    
    // attempt to create a socket
    if (!OpenSocket())
        return FALSE;
    
    // attempt to connect
    sockaddr_in sin;
    if (localPort != 0 || iface.IsValid()) {
        if (!SetOption(SO_REUSEADDR, 0)) {
            os_close();
            return FALSE;
        }
        memset(&sin, 0, sizeof(sin));
        sin.sin_family = AF_INET;
        sin.sin_addr.s_addr = iface;
        sin.sin_port        = htons(localPort);       // set the port
        if (!ConvertOSError(::bind(os_handle, (struct sockaddr*)&sin, sizeof(sin)))) {
            os_close();
            return FALSE;
        }
    }
    
    memset(&sin, 0, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_port   = htons(port);  // set the port
    sin.sin_addr   = addr;
    if (os_connect((struct sockaddr *)&sin, sizeof(sin)))
        return TRUE;
    
#endif
    
    os_close();
    return FALSE;
}


PBOOL PIPSocket::Listen(unsigned queueSize, WORD newPort, Reusability reuse)
{
#if P_HAS_IPV6
    return Listen(GetDefaultIpAny(), queueSize, newPort, reuse);
#else
    return Listen(INADDR_ANY, queueSize, newPort, reuse);
#endif
}


PBOOL PIPSocket::Listen(const Address & bindAddr,
                       unsigned,
                       WORD newPort,
                       Reusability reuse)
{
    // make sure we have a port
    if (newPort != 0)
        port = newPort;
    
#if P_HAS_IPV6
    Psockaddr bind_sa(bindAddr, port);
    
    if (IsOpen()) {
        int socketType;
        if (!GetOption(SO_TYPE, socketType, SOL_SOCKET) || bind_sa->sa_family != socketType)
            Close();
    }
#endif
    
    if (!IsOpen()) {
        // attempt to create a socket
#if P_HAS_IPV6
        if (!OpenSocket(bind_sa->sa_family))
            return FALSE;
#else
        if (!OpenSocket())
            return FALSE;
#endif
    }
    
    // attempt to listen
    if (!SetOption(SO_REUSEADDR, reuse == CanReuseAddress ? 1 : 0)) {
        os_close();
        return FALSE;
    }
    
#if P_HAS_IPV6
    
    if (ConvertOSError(::bind(os_handle, bind_sa, bind_sa.GetSize()))) {
        Psockaddr sa;
        socklen_t size = sa.GetSize();
        if (!ConvertOSError(::getsockname(os_handle, sa, &size)))
            return FALSE;
        
        port = sa.GetPort();
        return TRUE;
    }
    
#else
    
    // attempt to listen
    sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_family      = AF_INET;
    sin.sin_addr.s_addr = bindAddr;
    sin.sin_port        = htons(port);       // set the port
    
#ifdef __NUCLEUS_NET__
    int bind_result;
    if (port == 0)
        bind_result = ::bindzero(os_handle, (struct sockaddr*)&sin, sizeof(sin));
    else
        bind_result = ::bind(os_handle, (struct sockaddr*)&sin, sizeof(sin));
    if (ConvertOSError(bind_result))
#else
        if (ConvertOSError(::bind(os_handle, (struct sockaddr*)&sin, sizeof(sin))))
#endif
        {
            socklen_t size = sizeof(sin);
            if (ConvertOSError(::getsockname(os_handle, (struct sockaddr*)&sin, &size))) {
                port = ntohs(sin.sin_port);
                return TRUE;
            }
        }
    
#endif
    
    os_close();
    return FALSE;
}


const PIPSocket::Address & PIPSocket::Address::GetLoopback()
{
    return loopback4;
}


#if P_HAS_IPV6

/// Check for v4 mapped i nv6 address ::ffff:a.b.c.d
PBOOL PIPSocket::Address::IsV4Mapped() const
{
    if (version != 6)
        return FALSE;
    return IN6_IS_ADDR_V4MAPPED(&v.six) || IN6_IS_ADDR_V4COMPAT(&v.six);
}


const PIPSocket::Address & PIPSocket::Address::GetLoopback6()
{
    return loopback6;
}


const PIPSocket::Address & PIPSocket::Address::GetAny6()
{
    return any6;
}

#endif


PBOOL PIPSocket::Address::IsAny() const
{
    return (!IsValid());
}


const PIPSocket::Address & PIPSocket::Address::GetBroadcast()
{
    return broadcast4;
}

//modified by brant
PIPSocket::Address::Address()
{
	//why not initialize with any??
    //*this = loopback4;
	*this = any4;
}


PIPSocket::Address::Address(const PString & dotNotation)
{
    operator=(dotNotation);
}


PIPSocket::Address::Address(PINDEX len, const BYTE * bytes)
{
    switch (len) {
#if P_HAS_IPV6
        case 16 :
            version = 6;
            memcpy(&v.six, bytes, len);
            break;
#endif
        case 4 :
            version = 4;
            memcpy(&v.four, bytes, len);
            break;
            
        default :
            version = 0;
    }
}


PIPSocket::Address::Address(const in_addr & addr)
{
    version = 4;
    v.four = addr;
}


#if P_HAS_IPV6
PIPSocket::Address::Address(const in6_addr & addr)
{
    version = 6;
    v.six = addr;
}

// Create an IP (v4 or v6) address from a sockaddr (sockaddr_in, sockaddr_in6 or sockaddr_in6_old) structure
PIPSocket::Address::Address(const int ai_family, const int ai_addrlen, struct sockaddr *ai_addr)
{
    switch (ai_family) {
#if P_HAS_IPV6
        case AF_INET6:
            if (ai_addrlen < (int)sizeof(sockaddr_in6))
                break;
            
            version = 6;
            v.six = ((struct sockaddr_in6 *)ai_addr)->sin6_addr;
            //sin6_scope_id, should be taken into account for link local addresses
            return;
#endif
        case AF_INET:
            if (ai_addrlen < (int)sizeof(sockaddr_in))
                break;
            
            version = 4;
            v.four = ((struct sockaddr_in  *)ai_addr)->sin_addr;
            return;
    }
    version = 0;
}

#endif


#ifdef __NUCLEUS_NET__
PIPSocket::Address::Address(const struct id_struct & addr)
{
    operator=(addr);
}


PIPSocket::Address & PIPSocket::Address::operator=(const struct id_struct & addr)
{
    s_addr = (((unsigned long)addr.is_ip_addrs[0])<<24) +
    (((unsigned long)addr.is_ip_addrs[1])<<16) +
    (((unsigned long)addr.is_ip_addrs[2])<<8) +
    (((unsigned long)addr.is_ip_addrs[3]));
    return *this;
}
#endif


PIPSocket::Address & PIPSocket::Address::operator=(const in_addr & addr)
{
    version = 4;
    v.four = addr;
    return *this;
}

#if P_HAS_IPV6
PIPSocket::Address & PIPSocket::Address::operator=(const in6_addr & addr)
{
    version = 6;
    v.six = addr;
    return *this;
}
#endif


PObject::Comparison PIPSocket::Address::Compare(const PObject & obj) const
{
    const PIPSocket::Address & other = (const PIPSocket::Address &)obj;
    
    if (version < other.version)
        return LessThan;
    if (version > other.version)
        return GreaterThan;
    
#if P_HAS_IPV6
    if (version == 6) {
        int result = memcmp(&v.six, &other.v.six, sizeof(v.six));
        if (result < 0)
            return LessThan;
        if (result > 0)
            return GreaterThan;
        return EqualTo;
    }
#endif
    
    if ((DWORD)*this < other)
        return LessThan;
    if ((DWORD)*this > other)
        return GreaterThan;
    return EqualTo;
}

#if P_HAS_IPV6
bool PIPSocket::Address::operator*=(const PIPSocket::Address & addr) const
{
    if (version == addr.version)
        return operator==(addr);
    
    if (this->GetVersion() == 6 && this->IsV4Mapped())
        return PIPSocket::Address((*this)[12], (*this)[13], (*this)[14], (*this)[15]) == addr;
    else if (addr.GetVersion() == 6 && addr.IsV4Mapped())
        return *this == PIPSocket::Address(addr[12], addr[13], addr[14], addr[15]);
    return FALSE;
}

bool PIPSocket::Address::operator==(in6_addr & addr) const
{
    PIPSocket::Address a(addr);
    return Compare(a) == EqualTo;
}
#endif


bool PIPSocket::Address::operator==(in_addr & addr) const
{
    PIPSocket::Address a(addr);
    return Compare(a) == EqualTo;
}


bool PIPSocket::Address::operator==(DWORD dw) const
{
    if (dw != 0)
        return (DWORD)*this == dw;
    
    return !IsValid();
}


PIPSocket::Address & PIPSocket::Address::operator=(const PString & dotNotation)
{
#if P_HAS_IPV6
    
    struct addrinfo *res;
    struct addrinfo hints = { AI_NUMERICHOST, PF_UNSPEC }; // Could be IPv4: x.x.x.x or IPv6: x:x:x:x::x
    
    version = 0;
    memset(&v, 0, sizeof(v));
    
    if (getaddrinfo((const char *)dotNotation, NULL , &hints, &res) == 0) {
        if (res->ai_family == PF_INET6) {
            // IPv6 addr
            version = 6;
            struct sockaddr_in6 * addr_in6 = (struct sockaddr_in6 *)res->ai_addr;
            v.six = addr_in6->sin6_addr;
        } else {
            // IPv4 addr
            version = 4;
            struct sockaddr_in * addr_in = (struct sockaddr_in *)res->ai_addr;
            v.four = addr_in->sin_addr;
        }
        freeaddrinfo(res);
    }
    
#else //P_HAS_IPV6
    
    if (::strspn(dotNotation, "0123456789.") < ::strlen(dotNotation))
        *this = 0;
    else {
        version = 4;
        v.four.s_addr = inet_addr((const char *)dotNotation);
        if (v.four.s_addr == (DWORD)INADDR_NONE)
            v.four.s_addr = 0;
    }
    
#endif
    
    return *this;
}


PString PIPSocket::Address::AsString() const
{
#if P_HAS_IPV6
    if (version == 6) {
        PString str;
        Psockaddr sa(*this, 0);
        PAssertOS(getnameinfo(sa, sa.GetSize(), str.GetPointer(1024), 1024, NULL, 0, NI_NUMERICHOST) == 0);
        PINDEX percent = str.Find('%'); // used for scoped address e.g. fe80::1%ne0, (ne0=network interface 0)
        if (percent != P_MAX_INDEX)
            str[percent] = '\0';
        str.MakeMinimumSize();
        return str;
    }
#endif
    return inet_ntoa(v.four);
}


PBOOL PIPSocket::Address::FromString(const PString & dotNotation)
{
    (*this) = dotNotation;
    return IsValid();
    
}


PIPSocket::Address::operator PString() const
{
    return AsString();
}


PIPSocket::Address::operator in_addr() const
{
    if (version != 4)
        return inaddr_empty;
    
    return v.four;
}


#if P_HAS_IPV6
PIPSocket::Address::operator in6_addr() const
{
    if (version != 6)
        return any6.v.six;
    
    return v.six;
}
#endif


BYTE PIPSocket::Address::operator[](PINDEX idx) const
{
    PASSERTINDEX(idx);
#if P_HAS_IPV6
    if (version == 6) {
        PAssert(idx <= 15, PInvalidParameter);
        return v.six.s6_addr[idx];
    }
#endif
    
    PAssert(idx <= 3, PInvalidParameter);
    return ((BYTE *)&v.four)[idx];
}


ostream & operator<<(ostream & s, const PIPSocket::Address & a)
{
    return s << a.AsString();
}

ostream & operator<<(ostream & s, const PString & str)
{
    return s << (const char *)str;
}

istream & operator>>(istream & s, PIPSocket::Address & a)
{
    /// Not IPv6 ready !!!!!!!!!!!!!
    char dot1, dot2, dot3;
    unsigned b1, b2, b3, b4;
    s >> b1;
    if (!s.fail()) {
        if (s.peek() != '.')
            a = htonl(b1);
        else {
            s >> dot1 >> b2 >> dot2 >> b3 >> dot3 >> b4;
            if (!s.fail() && dot1 == '.' && dot2 == '.' && dot3 == '.')
                a = PIPSocket::Address((BYTE)b1, (BYTE)b2, (BYTE)b3, (BYTE)b4);
        }
    }
    return s;
}


PINDEX PIPSocket::Address::GetSize() const
{
    switch (version) {
#if P_HAS_IPV6
        case 6 :
            return 16;
#endif
            
        case 4 :
            return 4;
    }
    
    return 0;
}


PBOOL PIPSocket::Address::IsValid() const
{
    switch (version) {
#if P_HAS_IPV6
        case 6 :
            return memcmp(&v.six, &any6.v.six, sizeof(v.six)) != 0;
#endif
            
        case 4 :
            return (DWORD)*this != INADDR_ANY;
    }
    return FALSE;
}


PBOOL PIPSocket::Address::IsLoopback() const
{
#if P_HAS_IPV6
    if (version == 6)
        return IN6_IS_ADDR_LOOPBACK(&v.six);
#endif
    return *this == loopback4;
}


PBOOL PIPSocket::Address::IsBroadcast() const
{
#if P_HAS_IPV6
    if (version == 6) // In IPv6, no broadcast exist. Only multicast
        return FALSE;
#endif
    
    return *this == broadcast4;
}

PBOOL PIPSocket::Address::IsRFC1918() const
{
#if P_HAS_IPV6
    if (version == 6) {
        if (IN6_IS_ADDR_LINKLOCAL(&v.six) || IN6_IS_ADDR_SITELOCAL(&v.six))
            return TRUE;
        if (IsV4Mapped())
            return PIPSocket::Address((*this)[12], (*this)[13], (*this)[14], (*this)[15]).IsRFC1918();
    }
#endif
    return (Byte1() == 10)
    ||
    (
     (Byte1() == 172)
     &&
     (Byte2() >= 16) && (Byte2() <= 31)
     )
    ||
    (
     (Byte1() == 192)
     &&
     (Byte2() == 168)
     );
}

PIPSocket::InterfaceEntry::InterfaceEntry(const PString & _name,
                                          const Address & _addr,
                                          const Address & _mask,
                                          const PString & _macAddr
#if P_HAS_IPV6
                                          ,const PString & _ip6Addr
#endif
)
: name(_name.Trim()),
ipAddr(_addr),
netMask(_mask),
macAddr(_macAddr)
#if P_HAS_IPV6
, ip6Addr(_ip6Addr)
#endif
{
}


void PIPSocket::InterfaceEntry::PrintOn(ostream & strm) const
{
    strm << ipAddr;
#if P_HAS_IPV6
    if (!ip6Addr)
        strm << " [" << ip6Addr << ']';
#endif
    if (!macAddr)
        strm << " <" << macAddr << '>';
    if (!name)
        strm << " (" << name << ')';
}


#ifdef __NUCLEUS_NET__
PBOOL PIPSocket::GetInterfaceTable(InterfaceTable & table)
{
    InterfaceEntry *IE;
    list<IPInterface>::iterator i;
    for(i=Route4Configuration->Getm_IPInterfaceList().begin();
        i!=Route4Configuration->Getm_IPInterfaceList().end();
        i++)
    {
        char ma[6];
        for(int j=0; j<6; j++) ma[j]=(*i).Getm_macaddr(j);
        IE = new InterfaceEntry((*i).Getm_name().c_str(), (*i).Getm_ipaddr(), ma );
        if(!IE) return false;
        table.Append(IE);
    }
    return true;
}
#endif

PBOOL PIPSocket::GetNetworkInterface(PIPSocket::Address & addr)
{
    PIPSocket::InterfaceTable interfaceTable;
    if (PIPSocket::GetInterfaceTable(interfaceTable)) {
        PINDEX i;
        for (i = 0; i < interfaceTable.GetSize(); ++i) {
            PIPSocket::Address localAddr = interfaceTable[i].GetAddress();
            if (!localAddr.IsLoopback() && (!localAddr.IsRFC1918() || !addr.IsRFC1918()))
                addr = localAddr;
        }
    }
    return addr.IsValid();
}

//////////////////////////////////////////////////////////////////////////////
// PTCPSocket

PTCPSocket::PTCPSocket(WORD newPort)
{
    SetPort(newPort);
}


PTCPSocket::PTCPSocket(const PString & service)
{
    SetPort(service);
}


PTCPSocket::PTCPSocket(const PString & address, WORD newPort)
{
    SetPort(newPort);
    Connect(address);
}


PTCPSocket::PTCPSocket(const PString & address, const PString & service)
{
    SetPort(service);
    Connect(address);
}


PTCPSocket::PTCPSocket(PSocket & socket)
{
    Accept(socket);
}


PTCPSocket::PTCPSocket(PTCPSocket & tcpSocket)
{
    Accept(tcpSocket);
}


PObject * PTCPSocket::Clone() const
{
    return new PTCPSocket(port);
}


// By default IPv4 only adresses
PBOOL PTCPSocket::OpenSocket()
{
    return ConvertOSError(os_handle = os_socket(AF_INET, SOCK_STREAM, 0));
}


// ipAdressFamily should be AF_INET or AF_INET6
PBOOL PTCPSocket::OpenSocket(int ipAdressFamily)
{
    return ConvertOSError(os_handle = os_socket(ipAdressFamily, SOCK_STREAM, 0));
}


const char * PTCPSocket::GetProtocolName() const
{
    return "tcp";
}


PBOOL PTCPSocket::Write(const void * buf, PINDEX len)
{
    flush();
    PINDEX writeCount = 0;
    
    while (len > 0) {
        if (!os_sendto(((char *)buf)+writeCount, len, 0, NULL, 0))
            return FALSE;
        writeCount += lastWriteCount;
        len -= lastWriteCount;
    }
    
    lastWriteCount = writeCount;
    return TRUE;
}


PBOOL PTCPSocket::Listen(unsigned queueSize, WORD newPort, Reusability reuse)
{
#if P_HAS_IPV6
    return Listen(GetDefaultIpAny(), queueSize, newPort, reuse);
#else
    return Listen(INADDR_ANY, queueSize, newPort, reuse);
#endif
}


PBOOL PTCPSocket::Listen(const Address & bindAddr,
                        unsigned queueSize,
                        WORD newPort,
                        Reusability reuse)
{
    if (PIPSocket::Listen(bindAddr, queueSize, newPort, reuse) &&
        ConvertOSError(::listen(os_handle, queueSize)))
        return TRUE;
    
    os_close();
    return FALSE;
}


PBOOL PTCPSocket::Accept(PSocket & socket)
{
    PAssert(PIsDescendant(&socket, PIPSocket), "Invalid listener socket");
    
#if P_HAS_IPV6
    
    Psockaddr sa;
    PINDEX size = sa.GetSize();
    if (!os_accept(socket, sa, &size))
        return FALSE;
    
#else
    
    sockaddr_in address;
    address.sin_family = AF_INET;
    PINDEX size = sizeof(address);
    if (!os_accept(socket, (struct sockaddr *)&address, &size))
        return FALSE;
    
#endif
    
    port = ((PIPSocket &)socket).GetPort();
    
    return TRUE;
}


PBOOL PTCPSocket::WriteOutOfBand(void const * buf, PINDEX len)
{
#ifdef __NUCLEUS_NET__
    PAssertAlways("WriteOutOfBand unavailable on Nucleus Plus");
    //int count = NU_Send(os_handle, (char *)buf, len, 0);
    int count = ::send(os_handle, (const char *)buf, len, 0);
#else
    int count = ::send(os_handle, (const char *)buf, len, MSG_OOB);
#endif
    if (count < 0) {
        lastWriteCount = 0;
        return ConvertOSError(count, LastWriteError);
    }
    else {
        lastWriteCount = count;
        return TRUE;
    }
}


void PTCPSocket::OnOutOfBand(const void *, PINDEX)
{
}


//////////////////////////////////////////////////////////////////////////////
// PIPDatagramSocket

PIPDatagramSocket::PIPDatagramSocket()
{
}


PBOOL PIPDatagramSocket::ReadFrom(void * buf, PINDEX len,
                                 Address & addr, WORD & port)
{
    lastReadCount = 0;
    
#if P_HAS_IPV6
    
    Psockaddr sa;
    PINDEX size = sa.GetSize();
    if (os_recvfrom(buf, len, 0, sa, &size)) {
        addr = sa.GetIP();
        port = sa.GetPort();
    }
    
#else
    
    sockaddr_in sockAddr;
    PINDEX addrLen = sizeof(sockAddr);
    if (os_recvfrom(buf, len, 0, (struct sockaddr *)&sockAddr, &addrLen)) {
        addr = sockAddr.sin_addr;
        port = ntohs(sockAddr.sin_port);
    }
    
#endif
    
    return lastReadCount > 0;
}


PBOOL PIPDatagramSocket::WriteTo(const void * buf, PINDEX len,
                                const Address & addr, WORD port)
{
    lastWriteCount = 0;
    
#if P_HAS_IPV6
    
    Psockaddr sa(addr, port);
    return os_sendto(buf, len, 0, sa, sa.GetSize()) && lastWriteCount >= len;
    
#else
    
    sockaddr_in sockAddr;
    sockAddr.sin_family = AF_INET;
    sockAddr.sin_addr = addr;
    sockAddr.sin_port = htons(port);
    return os_sendto(buf, len, 0, (struct sockaddr *)&sockAddr, sizeof(sockAddr))
    && lastWriteCount >= len;
    
#endif
}


//////////////////////////////////////////////////////////////////////////////
// PUDPSocket

PUDPSocket::PUDPSocket(WORD newPort)
{
    sendPort = 0;
    SetPort(newPort);
    OpenSocket();
}

PUDPSocket::PUDPSocket(PQoS * qos, WORD newPort)
{
    if (qos != NULL)
        qosSpec = *qos;
    sendPort = 0;
    SetPort(newPort);
    OpenSocket();
}


PUDPSocket::PUDPSocket(const PString & service, PQoS * qos)
{
    if (qos != NULL)
        qosSpec = *qos;
    sendPort = 0;
    SetPort(service);
    OpenSocket();
}


PUDPSocket::PUDPSocket(const PString & address, WORD newPort)
{
    sendPort = 0;
    SetPort(newPort);
    Connect(address);
}


PUDPSocket::PUDPSocket(const PString & address, const PString & service)
{
    sendPort = 0;
    SetPort(service);
    Connect(address);
}


PBOOL PUDPSocket::ModifyQoSSpec(PQoS * qos)
{
    if (qos==NULL)
        return FALSE;
    
    qosSpec = *qos;
    return TRUE;
}

#if P_HAS_QOS
PQoS & PUDPSocket::GetQoSSpec()
{
    return qosSpec;
}
#endif

PBOOL PUDPSocket::ApplyQoS()
{
    char DSCPval = 0;
    if (qosSpec.GetDSCP() < 0 ||
        qosSpec.GetDSCP() > 63) {
        if (qosSpec.GetServiceType() == SERVICETYPE_PNOTDEFINED)
            return TRUE;
        else {
            switch (qosSpec.GetServiceType()) {
                case SERVICETYPE_GUARANTEED:
                    DSCPval = PQoS::guaranteedDSCP;
                    break;
                case SERVICETYPE_CONTROLLEDLOAD:
                    DSCPval = PQoS::controlledLoadDSCP;
                    break;
                case SERVICETYPE_BESTEFFORT:
                default:
                    DSCPval = PQoS::bestEffortDSCP;
                    break;
            }
        }
    }
    else
        DSCPval = (char)qosSpec.GetDSCP();
    
    unsigned int setDSCP = DSCPval<<2;
    
    int rv = 0;
    unsigned int curval = 0;
    socklen_t cursize = sizeof(curval);
//    rv = ::getsockopt(os_handle,IPPROTO_IP, IP_TOS, (char *)(&curval), &cursize);
    if (curval == setDSCP)
        return TRUE;    //Required DSCP already set
    
    
    rv = ::setsockopt(os_handle, IPPROTO_IP, IP_TOS, (char *)&setDSCP, sizeof(setDSCP));
    
    if (rv != 0) {
        int err;

        err = errno;

        PTRACE(3,"QOS\tsetsockopt failed with code " << err);
        return FALSE;
    }
    
    return TRUE;
}

PBOOL PUDPSocket::OpenSocketGQOS(int af, int type, int proto)
{
    PBOOL retval = ConvertOSError(os_handle = os_socket(af, type, proto));

    return retval;
}

    
PBOOL PUDPSocket::OpenSocket()
{
#ifdef COULD_HAVE_QOS
    if (CheckOSVersion()) 
        return OpenSocketGQOS(AF_INET, SOCK_DGRAM, 0);
#endif
    
    return ConvertOSError(os_handle = os_socket(AF_INET,SOCK_DGRAM, 0));
}

PBOOL PUDPSocket::OpenSocket(int ipAdressFamily)
{
#ifdef COULD_HAVE_QOS
    if (CheckOSVersion()) 
        return OpenSocketGQOS(ipAdressFamily, SOCK_DGRAM, 0);
#endif
    
    return ConvertOSError(os_handle = os_socket(ipAdressFamily,SOCK_DGRAM, 0));
}

const char * PUDPSocket::GetProtocolName() const
{
    return "udp";
}


PBOOL PUDPSocket::Connect(const PString & address)
{
    sendPort = 0;
    return PIPDatagramSocket::Connect(address);
}


PBOOL PUDPSocket::Read(void * buf, PINDEX len)
{
    return PIPDatagramSocket::ReadFrom(buf, len, lastReceiveAddress, lastReceivePort);
}


PBOOL PUDPSocket::Write(const void * buf, PINDEX len)
{
    if (sendPort == 0)
        return PIPDatagramSocket::Write(buf, len);
    else
        return PIPDatagramSocket::WriteTo(buf, len, sendAddress, sendPort);
}


void PUDPSocket::SetSendAddress(const Address & newAddress, WORD newPort)
{
    sendAddress = newAddress;
    sendPort    = newPort;
    ApplyQoS();
}


void PUDPSocket::GetSendAddress(Address & address, WORD & port)
{
    address = sendAddress;
    port    = sendPort;
}


void PUDPSocket::GetLastReceiveAddress(Address & address, WORD & port)
{
    address = lastReceiveAddress;
    port    = lastReceivePort;
}

PBOOL PUDPSocket::CheckLocalPort(WORD port)
{
	int sockfd;
	struct sockaddr_in servaddr;
	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servaddr.sin_port = htons(port);

	int result = ::bind(sockfd, (struct sockaddr *) &servaddr, sizeof(servaddr));
	close(sockfd);
	if(result < 0) {
		return FALSE;
	}
	return TRUE;
}

WORD PUDPSocket::GetLocalPort(WORD startPort)
{
	WORD port = 0;
	for(WORD i= startPort; i< 65535; i++)
	{
		if(CheckLocalPort(i))
		{
			port = i;
			break;
		} else {
			continue;
		}
	}
	return port;
}
//////////////////////////////////////////////////////////////////////////////
// End Of File ///////////////////////////////////////////////////////////////
