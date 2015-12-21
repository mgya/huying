//
//  socket_udp.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__socket_udp__
#define __UMPStack__socket_udp__

#include "socket_base.h"

class SocketUDP: public SocketBase
{
	PCLASSINFO(SocketUDP,SocketBase);
public:
	SocketUDP(EventSink & eventSink);
	virtual ~SocketUDP();
    
	
	
	virtual PBOOL Write(const void* buffer, PINDEX len);
	
	void SetSendAddress(const IPPort& to);
	IPPort GetSendAddress() const;
protected:
	struct sockaddr _sendAddr;
	
};

#endif /* defined(__UMPStack__socket_udp__) */
