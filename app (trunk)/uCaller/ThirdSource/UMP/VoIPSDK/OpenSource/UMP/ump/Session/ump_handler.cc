//
//  ump_handler.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "ump_handler.h"


#include "../Protocol/ump_base.h"
/////////////

//////////////////////////
UMPHandlerBase::DataReader::DataReader()
:_readCount(0),
_blockSize(0)
{
    
}

void UMPHandlerBase::DataReader::Reset()
{
	_readCount = 0;
	_blockSize = 0;
}

UMPHandlerBase::DataReader::E_DR_Result UMPHandlerBase::DataReader::Read(SocketBase & socket)
{
	do{
		PINDEX len = 0;
		BYTE * ptr = NULL;
		if(_readCount<(PINDEX)sizeof(_blockSize)){
			len = sizeof(_blockSize) - _readCount;
			ptr = ((BYTE*)&_blockSize)+_readCount;
		}
		else{
			len = sizeof(_blockSize)+_blockSize-_readCount;
			ptr = ((BYTE*)theArray)+_readCount-sizeof(_blockSize);
		}
        
		if(!socket.Read(ptr,len)){
			return e_dr_transportError;
		}
		
		_readCount+= len;
        
		if(_readCount==sizeof(_blockSize)){
			_blockSize = *((PUInt16b*) &_blockSize);
			if(_blockSize<1){
				return e_dr_ok;
                
			}
			SetMinSize(_blockSize);
		}
		else if(_readCount == (PINDEX)(sizeof(_blockSize)+_blockSize)){
			return e_dr_ok;
		}
        
	}while(socket.IsReadable());
    
	return e_dr_noData;
}

/////////////////
UMPHandlerBase::InitKeyReader::InitKeyReader()
:_readCount(0)
{
    
}

PBOOL UMPHandlerBase::InitKeyReader::Read(SocketBase & socket)
{
	PINDEX len = INIT_KEY_SIZE - _readCount;
	if(len<1)
		return TRUE;
	if(socket.Read(_initKey+_readCount, len)){
		_readCount+=len;
		return TRUE;
	}else{
		return FALSE;
	}
}

void UMPHandlerBase::InitKeyReader::Reset()
{
	_readCount = 0;
}

//////////////////
#define TIME_TO_ROUND_TRIP		(90*1000)//(60*1000)
#define ROUND_TRIP_TIMEOUT		(45*1000)//(30*1000)

UMPHandlerBase::UMPHandlerBase(UHEventSink & eventSink)
:SocketTCP((SocketBase::EventSink&)*this),
_doRoundTrip(FALSE),
_waitRoundTripAck(FALSE),
_deletable(FALSE),
_usedCount(0),
_uhEventSink(eventSink)
{
	_timeToRoundTrip.SetTimeout(TIME_TO_ROUND_TRIP);
	_roundTripTimeout.SetTimeout(ROUND_TRIP_TIMEOUT);
}

void UMPHandlerBase::SetRoundTrip(PBOOL b)
{
	_doRoundTrip = b;
	if(_doRoundTrip){
		_timeToRoundTrip.Reset();
		_roundTripTimeout.Reset();
		_waitRoundTripAck = FALSE;
        
	}
}

void UMPHandlerBase::SetRoundTripTime(int sec)
{
	if(sec <= 0)
	{
		_doRoundTrip = FALSE;
	}
	else
	{
		_doRoundTrip = TRUE;
		_timeToRoundTrip.SetTimeout(sec*1000);
		_roundTripTimeout.SetTimeout(sec*500);
		_timeToRoundTrip.Reset();
		_roundTripTimeout.Reset();
		_waitRoundTripAck = FALSE;
	}
}

unsigned UMPHandlerBase::GetUsedCount() const
{
	return _usedCount;
}

void UMPHandlerBase::Lock()
{
	++_usedCount;
}

void UMPHandlerBase::Unlock()
{
	--_usedCount;
	if (_deletable && 0 == _usedCount) {
		GetEvent().Register(e_sock_ev_destroy);
	}
}

void UMPHandlerBase::OnReadable(SocketBase & socket,PBYTEArray& /*sharedBuffer*/)
{
	//_timeToRoundTrip.Reset();
	_roundTripTimeout.Reset();
	_waitRoundTripAck = FALSE;
    
	//_deadTimeout.Reset();
	switch(_dataReader.Read(socket)){
        case DataReader::e_dr_ok:
            if(_dataReader.GetBlockSize()>0)
                OnGotBlock(_dataReader.GetPointer(), _dataReader.GetBlockSize());
            
            _dataReader.Reset();
            break;
        case DataReader::e_dr_transportError:
            _uhEventSink.OnTransportError(*this);
            _dataReader.Reset();
            break;
        case DataReader::e_dr_protocolError:
            _uhEventSink.OnProtocolError(*this);
            _dataReader.Reset();
            break;
        default:
            break;
	}
}

void UMPHandlerBase::OnWritable(SocketBase & /*socket*/,PBYTEArray& /*sharedBuffer*/)
{
}

void UMPHandlerBase::OnTick(SocketBase & /*socket*/)
{
	_uhEventSink.OnTick(*this);
	if (IsOpen()) {
		if(_doRoundTrip){
			if(_timeToRoundTrip.IsTimeout()){

				_timeToRoundTrip.Reset();
				
				UMPSignal sig_roundTrip(e_sig_roundTrip);
				Sig::RoundTrip roundTrip(sig_roundTrip);
				OnWriteRoundTrip(roundTrip);
				WriteSignal(sig_roundTrip);
				
				_roundTripTimeout.Reset();
				_waitRoundTripAck = TRUE;
			}
            
			if(_waitRoundTripAck){
				if(_roundTripTimeout.IsTimeout()){
					_timeToRoundTrip.Reset();
					_roundTripTimeout.Reset();
					_waitRoundTripAck = FALSE;

					_uhEventSink.OnTransportError(*this);
					
				}
			}
            
		}
	}
    
}


//#if defined(VOIPBASE_IOS) || defined(VOIPBASE_MAC)
//static CFReadStreamRef    _readStream;
//static CFWriteStreamRef    _writeStream;
//#endif

void UMPHandlerBase::OnSocketOpen(SocketBase & socket)
{
	socket.SetUrgent(TRUE);
	socket.SetLinger(TRUE, 2);
	socket.SetKeepAlive(TRUE);
    
	_timeToRoundTrip.Reset();
	_roundTripTimeout.Reset();
	_waitRoundTripAck = FALSE;
    
//    int streamHandler = GetHandle();
//#if defined(VOIPBASE_IOS) || defined(VOIPBASE_MAC)
//    
//    U_INFO("enter OnSocketOpen");
//            CFReadStreamRef testreadStream;
//            CFWriteStreamRef testwriteStream;
//            //用CFStreamCreatePairWithSocket 在已有的socket 上创建输入输出流
//    CFStreamCreatePairWithSocket(NULL, streamHandler, &testreadStream, &testwriteStream);
//            //设置属性kCFStreamNetworkServiceTypeVoIP
//            CFReadStreamSetProperty(testreadStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP);
//            CFWriteStreamSetProperty(testwriteStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP);
//    
//            CFReadStreamOpen(testreadStream);
//            CFWriteStreamOpen(testwriteStream);
//    
//            CFStreamCreatePairWithSocket(kCFAllocatorDefault, streamHandler, &_readStream, &_writeStream);
//            if (!_readStream || !_writeStream ||
//                CFReadStreamSetProperty(_readStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP) != TRUE ||
//                CFWriteStreamSetProperty(_writeStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP) != TRUE ||
//                CFReadStreamOpen(_readStream) != TRUE ||
//                CFWriteStreamOpen(_writeStream) != TRUE)
//            {
//                CFReadStreamClose(_readStream);
//                CFWriteStreamClose(_writeStream);
//                Close();
//                U_WARN("back error");
//            }
//            CFRelease(_readStream);
//#endif
    
}

void UMPHandlerBase::OnConnect(SocketBase & /*socket*/,PChannel::Errors result)
{
	_timeToRoundTrip.Reset();
	_roundTripTimeout.Reset();
	_waitRoundTripAck = FALSE;
    
	_uhEventSink.OnConnect(*this,result);
}

void UMPHandlerBase::OnHup(SocketBase & /*socket*/)
{
	_uhEventSink.OnTransportError(*this);
}

PBOOL UMPHandlerBase::WriteSignal(const UMPSignal& signal)
{
	PWaitAndSignal lock(_writeBufferMutex);
	PINDEX size = _writeBuffer.GetSize() - L_HEAD;
    
	BYTE* bsptr = _writeBuffer.GetPointer();
	if (!signal.Encode(bsptr + L_HEAD, size)) {
		/*_writeBuffer.SetSize(0);*/
		if(size<=0)
			return FALSE;
		bsptr = _writeBuffer.GetPointer(size + L_HEAD);
		if(!signal.Encode(bsptr + L_HEAD, size))
			return FALSE;
	}
    
	*((PUInt16b *) bsptr) = (WORD) (size + 1);
	*(bsptr + sizeof(WORD)) = 1;
    
	_cypher.Encode(bsptr + sizeof(WORD), size + 1, bsptr + sizeof(WORD));

	if(signal.GetTag() == e_sig_roundTrip || signal.GetTag() == e_sig_roundTripAck)
	{
		U_DBG("send signal " << signal.GetTagName() << " to " << GetPeerAddress());
		U_DBG("content:\n--------\n" <<
				signal <<
				"--------");
	}
	else
	{
		U_INFO("send signal " << signal.GetTagName() << " to " << GetPeerAddress());
		U_INFO("content:\n--------\n" <<
				signal <<
				"--------");
	}

	return Write(bsptr, size + L_HEAD);
}


PBOOL UMPHandlerBase::WriteBinary(const PBYTEArray& bin)
{
	return Write(bin, bin.GetSize());
}

PBOOL UMPHandlerBase::WriteBinary(const void* bin, PINDEX size)
{
	if (bin == NULL || size< 0 || size>MAX_BLOCK_LEN)
		return FALSE;
    
	PWaitAndSignal lock(_writeBufferMutex);
    
	BYTE* bsptr = _writeBuffer.GetPointer(size + L_HEAD);
	
	*((PUInt16b *) bsptr) = (WORD) (size + 1);
	*(bsptr + sizeof(WORD)) = 0;
    
	memcpy(bsptr + L_HEAD, bin, size);
	_cypher.Encode(bsptr + sizeof(WORD), size + 1, bsptr + sizeof(WORD));

	return Write(_writeBuffer, size + L_HEAD);
}

void UMPHandlerBase::OnGotBlock(void* block, PINDEX blockSize)
{
	if (blockSize <= 1) {
		return;
	}
    
	_cypher.Decode(block, blockSize, block);
    
	const BYTE bf = ((const BYTE*) block)[0];
    
    
	if (bf == 0){
		//a binary block
		_uhEventSink.OnReadBinary(*this,((const BYTE *) block) + 1, blockSize - 1);
		return;
        
	}
	
	if (bf == 1){
		//a signal block
		UMPSignal * signal = new UMPSignal;
		PBOOL noDelete = FALSE;
		if (signal->Decode(((const BYTE *) block) + 1, blockSize - 1)) {
			switch(signal->GetTag()){
                case e_sig_roundTrip:
				{
					U_DBG("recv signal " << signal->GetTagName() << " from " << GetPeerAddress());
					U_DBG("content:\n--------\n" <<
							(*signal) <<
							"--------");

					OnReadRoundTrip(*signal);
                    
					UMPSignal sig_roundTripAck(e_sig_roundTripAck);
					if(signal->Exist(e_ele_timestamp)){
						PString ts;
						signal->Get(e_ele_timestamp,ts);
						sig_roundTripAck.Set(e_ele_timestamp, ts);
					}
                    
					Sig::RoundTripAck roundTripAck(sig_roundTripAck);
					OnWriteRoundTripAck(roundTripAck);
					WriteSignal(sig_roundTripAck);
				}
                    break;
                case e_sig_roundTripAck:
				{
					U_DBG("recv signal " << signal->GetTagName() << " from " << GetPeerAddress());
					U_DBG("content:\n--------\n" <<
							(*signal) <<
							"--------");

					OnReadRoundTripAck(*signal);
				}
                    break;
                    //已废弃
                case e_sig_keepAlive:
                case e_sig_keepAliveAck:
                	U_DBG("recv signal " << signal->GetTagName() << " from " << GetPeerAddress());
                	U_DBG("content:\n--------\n" <<
                			(*signal) <<
                			"--------");

                    break;
                default:
                	U_INFO("recv signal " << signal->GetTagName() << " from " << GetPeerAddress());
                	U_INFO("content:\n--------\n" <<
                			(*signal) <<
                			"--------");

                    if (!_uhEventSink.OnFilter(*this,*signal)) {
                    } else{
                        _uhEventSink.OnReadSignal(*this,signal,noDelete);
                    }
                    break;
			}
            
		} else {
			_uhEventSink.OnProtocolError(*this);
		}
        
		if(!noDelete)
			delete signal;
		
		return;
	}

	_uhEventSink.OnProtocolError(*this);
}

void UMPHandlerBase::OnWriteRoundTrip(Sig::RoundTrip & /*rt*/)
{
}

void UMPHandlerBase::OnReadRoundTrip(const Sig::RoundTrip & /*rt*/)
{
}

void UMPHandlerBase::OnWriteRoundTripAck(Sig::RoundTripAck & /*rta*/)
{
}

void UMPHandlerBase::OnReadRoundTripAck(const Sig::RoundTripAck & /*rta*/)
{
}

void UMPHandlerBase::SetDeletable()
{
	if (GetUsedCount() == 0)
		GetEvent().Register(e_sock_ev_destroy);
	else{
        
		GetEvent().Unregister(e_sock_ev_all);	
		_deletable = TRUE;
	}
}

void UMPHandlerBase::Close()
{
	SocketTCP::Close();
	_dataReader.Reset();
}
