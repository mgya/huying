//
//  ump_handler.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef UMP_HANDLER_H
#define UMP_HANDLER_H

#include "../Network/socket_tcp.h"
#include "../Protocol/sig_wrap.h"
#include "../Protocol/ump_base.h"
#include "../Common/ump_cypher.h"
#include "../Common/ulog.h"
#import <CoreFoundation/CFStream.h>


//for some handler, UMPServerSession, UMPSession...
#define INIT_KEY_SIZE 4

#define L_HEAD  (sizeof(WORD)+1)

class UMPHandlerBase : public SocketTCP ,public SocketBase::EventSink
{
	PCLASSINFO(UMPHandlerBase, PObject);
public:
    
	class UHEventSink
	{
	public:
		virtual ~UHEventSink(){}
	public:
		virtual void OnReadSignal(UMPHandlerBase & handler,UMPSignal* signal, PBOOL & noDelete) = 0;
		virtual void OnReadBinary(UMPHandlerBase & handler,const void* bin, PINDEX size) = 0;
        
		
		virtual void OnTransportError(UMPHandlerBase & handler) = 0;
		virtual void OnProtocolError(UMPHandlerBase & handler) = 0;
		virtual PBOOL OnFilter(UMPHandlerBase & handler,UMPSignal& signal) = 0;
		
		virtual void OnConnect(UMPHandlerBase & handler, PChannel::Errors result) = 0;
		virtual void OnTick(UMPHandlerBase & handler) = 0;
		
	};
    
	template<typename T>
	class StateMonitor: public PObject
	{
		PCLASSINFO(StateMonitor , PObject);
	public:
		StateMonitor(T initState):_state(initState)
		{
		}
		virtual void SetState(T status)
		{
			_state=status;
		}
		virtual T GetState() const
		{
			return _state;
		}
		
		virtual PBOOL Filter(UMPHandlerBase & handler,UMPSignal & signal)=0;
	protected:
		T _state;
	};
    
	class DataReader: public PBYTEArray
	{
		PCLASSINFO(DataReader,PBYTEArray);
	public:
		enum E_DR_Result{
			e_dr_ok,
			e_dr_transportError,
			e_dr_protocolError,
			e_dr_noData,
		};
		DataReader();
        
        
		void Reset();
        
		E_DR_Result Read(SocketBase & socket);
        
		WORD GetBlockSize() const{return _blockSize;}
        
		
        
	private:
		PINDEX _readCount;
		WORD _blockSize;
	};
    
	class InitKeyReader: public PObject
	{
		PCLASSINFO(InitKeyReader, PObject);
	public:
		InitKeyReader();
        
		PBOOL Read(SocketBase & socket);
        
		void Reset();
        
		const BYTE * GetInitKey() const{return _initKey;}
        
		PINDEX GetReadCount() const	{return _readCount;	}
        
	private:
		BYTE _initKey[INIT_KEY_SIZE];
		PINDEX _readCount;
	};
    
    
	UMPHandlerBase(UHEventSink & eventSink);
    
	virtual PBOOL WriteSignal(const UMPSignal& signal);
	virtual PBOOL WriteBinary(const void* bin, PINDEX size);
	virtual PBOOL WriteBinary(const PBYTEArray& bin);
    
    
    
	unsigned GetUsedCount() const;
	void Lock();
	void Unlock();
	
	virtual void SetDeletable();
    
	virtual void Close();
    
	UMPCypher::TEA & GetCypher(){return _cypher;}
    
	void SetRoundTrip(PBOOL b);

	void SetRoundTripTime(int sec);
    
protected:
    
	virtual void OnReadable(SocketBase & socket,PBYTEArray& sharedBuffer);
	virtual void OnWritable(SocketBase & socket,PBYTEArray& sharedBuffer);
	virtual void OnTick(SocketBase & socket);
	virtual void OnSocketOpen(SocketBase & socket);
	virtual void OnConnect(SocketBase & socket,PChannel::Errors result);
	virtual void OnHup(SocketBase & socket);
    
	virtual void OnGotBlock(void* block, PINDEX blockSize);
    
	virtual void OnWriteRoundTrip(Sig::RoundTrip & rt);
	virtual void OnReadRoundTrip(const Sig::RoundTrip & rt);
	virtual void OnWriteRoundTripAck(Sig::RoundTripAck & rta);
	virtual void OnReadRoundTripAck(const Sig::RoundTripAck & rta);
	
    
protected:
	PBYTEArray _writeBuffer;
	PMutex _writeBufferMutex;
    
	PBOOL _doRoundTrip;
	PBOOL _waitRoundTripAck;
	Timeout _timeToRoundTrip;
	Timeout _roundTripTimeout;
    
    
	DataReader _dataReader;
	UMPCypher::TEA _cypher;
    
//#if defined(VOIPBASE_IOS) || defined(VOIPBASE_MAC)
//    CFReadStreamRef    _readStream;
//    CFWriteStreamRef    _writeStream;
//#endif
    
private:
	PBOOL _deletable;	
	PAtomicInteger _usedCount;	
	UHEventSink & _uhEventSink;
    

	
    
};

typedef SmartPtr<UMPHandlerBase> UMPHandlerPtr;


#endif
