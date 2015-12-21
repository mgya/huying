//
//  socket_udp.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "socket_udp.h"




SocketUDP::SocketUDP(EventSink & eventSink)
:SocketBase(SOCK_DGRAM,eventSink)
{
	memset(&_sendAddr,0,sizeof(_sendAddr));
}

SocketUDP::~SocketUDP()
{
	Close();
}

PBOOL SocketUDP::Write(const void* buffer, PINDEX len)
{
	if (((sockaddr_in *) &_sendAddr)->sin_port) {
		return _core.SendTo(buffer, len, 0, _sendAddr);
	} else {
		return _core.Send(buffer, len, 0);
	}
}

void SocketUDP::SetSendAddress(const IPPort& to)
{
	to.ToSockAddr(_sendAddr);
}

IPPort SocketUDP::GetSendAddress() const
{
	IPPort addr;
	addr.FromSockAddr(_sendAddr);
	return addr;
}