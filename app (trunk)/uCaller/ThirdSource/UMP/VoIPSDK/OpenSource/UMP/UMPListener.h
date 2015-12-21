//
//  UMPListener.h
//  webRtc
//
//  Created by 华崇辉 on 15-3-17.
//  Copyright (c) 2015年 changzheng-Mac. All rights reserved.
//

//#import <Foundation/Foundation.h>
//
//@interface UMPListener : NSObject
//
//@end

#include "ump/UMPEngine.h"
#import "HYVoIPCore.h"

class UMPListener: public UMPEngine::UMPEngineEventSink{
public:
    UMPListener();
    ~UMPListener();
    virtual void onLoginResult(int code);
    virtual void onLogout(int code);
    virtual void onCallIn(const char * number,const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt);
    virtual void onCallRing(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt);
    virtual void onCallRingAndOpenChannel(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt);
    virtual void onCallOK(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt);
    virtual void onCallEnd(int code);
    virtual void onURTPReady(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt);
    virtual void onKeepAlive();
    virtual void onKeepAliveAck();
    virtual void onStartVoice(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt);
    virtual void onStopVoice();
    virtual void onMessage(const char * fromuid,const char * fromnumber,const char * content);
    virtual void onMessageAck(const char * origsmsid,const char * newsmsid);
private:
    bool compare(const IP& remoteIP,unsigned short remotePort,const IP& localIP,unsigned short localPort,unsigned short pt);
    void set(const IP& remoteIP,unsigned short remotePort,const IP& localIP,unsigned short localPort,unsigned short pt);
private:
    IP lastRemoteIP;
    unsigned short lastRemotePort;
    IP lastlocalIP;
    unsigned short lastlocalPort;
    unsigned short lastPT;
    
public:
    id<HYVoIPDelegate> voipDelegate;
    
};




