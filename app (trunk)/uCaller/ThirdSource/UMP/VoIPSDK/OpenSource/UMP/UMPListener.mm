//
//  UMPListener.m
//  webRtc
//
//  Created by 华崇辉 on 15-3-17.
//  Copyright (c) 2015年 changzheng-Mac. All rights reserved.
//

//#import "UMPListener.h"
//
//@implementation UMPListener
//
//@end

#include "UMPListener.h"
#include "WebrtcDelegate.h"

UMPListener::UMPListener(){
    lastRemoteIP = IP();
    lastRemotePort = 0;
    lastlocalIP = IP();
    lastlocalPort = 0;
    lastPT = 0;
}


UMPListener::~UMPListener(){
    
}


void UMPListener::onLoginResult(int code){
    NSLog(@"onLoginResult code=%d",code);
    if (code == e_r_ok) {
        [HYVoIPCore sharedInstance].isOnline = YES;
        if (voipDelegate && [voipDelegate respondsToSelector:@selector(onLoginOK)]) {
            [voipDelegate onLoginOK];
        }
    }
    else {
        [HYVoIPCore sharedInstance].isOnline = NO;
        if (voipDelegate && [voipDelegate respondsToSelector:@selector(onLoginError:)]) {
            [voipDelegate onLoginError:code];
        }
        
        if (code == e_r_authFail) {
            //验证失败，则不执行其他逻辑，立即退出function
            return ;
        }
        [[HYVoIPCore sharedInstance] reLogin];
    }
}
void UMPListener::onLogout(int code){
    NSLog(@"onLogout code=%d",code);
    [HYVoIPCore sharedInstance].isOnline = NO;
    if(code == e_r_duplicateLogin) {
        if (voipDelegate && [voipDelegate respondsToSelector:@selector(onKicked)]) {
            [voipDelegate onKicked];
        }
    }
    else if(code == e_r_ok){
        if (voipDelegate && [voipDelegate respondsToSelector:@selector(onLogOut)]) {
            [voipDelegate onLogOut];
        }
    }
    else /*if(code == e_r_transportError)*/ {
        if (voipDelegate && [voipDelegate respondsToSelector:@selector(onLogOut)]) {
            [voipDelegate onLogOut];
        }
        [[HYVoIPCore sharedInstance] reLogin];
    }
    
}
void UMPListener::onCallIn(const char * number,const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt){
    //webrtcDelegate * webrtc = [webrtcDelegate getWebrtcDelegate];
    NSLog(@"onCallIn number:%s, remoteIP:%s remotePort:%d localIP:%s localPort:%d pt:%d",number,remoteIP,remotePort,localIP,localPort,pt);

//    [HYVoIPCore sharedInstance].isCalling = YES;
    
    webrtcDelegate * webrtc = [webrtcDelegate getWebrtcDelegate];
//    [webrtc setCallConnect:FALSE];
    
//    if(!compare(IP(remoteIP),remotePort,IP(localIP),localPort,pt)){
        NSLog(@"onCallIn startVoiceEngine");
        set(IP(remoteIP),remotePort,IP(localIP),localPort,pt);
//        webrtcDelegate * webrtc = [webrtcDelegate getWebrtcDelegate];
        [webrtc startVoiceEngine:localPort IP:remoteIP port:remotePort payloadtype:pt];

//    }
    
    PThread::Sleep(50);
    
    if (voipDelegate && [voipDelegate respondsToSelector:@selector(onCallIn:)]) {
        [voipDelegate onCallIn:[NSString stringWithUTF8String:number]];
    }
    
    NSString * bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"VoIPSDK.bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *filename = @"ringback";
    if ( resourceBundle && filename ){
        NSString * s=[[resourceBundle resourcePath ] stringByAppendingPathComponent : filename];
        NSLog ( @"resourceBundle path = %@" ,s);
        NSString *wavPath = [NSString stringWithFormat:@"%@.wav", s];
        [[HYVoIPCore sharedInstance] StartPlayingFileAsMicrophone:wavPath loop:YES];
    }
    
    [webrtc stopPlayout];
}
void UMPListener::onCallRing(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt){
    NSLog(@"onCallRing remoteIP:%s remotePort:%d localIP:%s localPort:%d pt:%d",remoteIP,remotePort,localIP,localPort,pt);
    webrtcDelegate * webrtc = [webrtcDelegate getWebrtcDelegate];
//    [webrtc setCallConnect:FALSE];
    
    if(!compare(IP(remoteIP),remotePort,IP(localIP),localPort,pt)){
        NSLog(@"onCallRing startVoiceEngine");
        set(IP(remoteIP),remotePort,IP(localIP),localPort,pt);
//        webrtcDelegate * webrtc = [webrtcDelegate getWebrtcDelegate];
        [webrtc startVoiceEngine:localPort IP:remoteIP port:remotePort payloadtype:pt];
    }
    
    if (voipDelegate && [voipDelegate respondsToSelector:@selector(onCallRing)]) {
        [voipDelegate onCallRing];
    }
}
void UMPListener::onCallRingAndOpenChannel(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt){
    NSLog(@"onCallRingAndOpenChannel remoteIP:%s remotePort:%d localIP:%s localPort:%d pt:%d",remoteIP,remotePort,localIP,localPort,pt);
}
void UMPListener::onCallOK(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt){
    NSLog(@"onCallOK remoteIP:%s remotePort:%d localIP:%s localPort:%d pt:%d",remoteIP,remotePort,localIP,localPort,pt);
    
    webrtcDelegate * webrtc = [webrtcDelegate getWebrtcDelegate];
//    [webrtc setCallConnect:TRUE];
    if(!compare(IP(remoteIP),remotePort,IP(localIP),localPort,pt)){
        NSLog(@"onCallOK startVoiceEngine");
        set(IP(remoteIP),remotePort,IP(localIP),localPort,pt);
//        webrtcDelegate * webrtc = [webrtcDelegate getWebrtcDelegate];
        [webrtc startVoiceEngine:localPort IP:remoteIP port:remotePort payloadtype:pt];
    }
    
    if (voipDelegate && [voipDelegate respondsToSelector:@selector(onCallOK)]) {
        [voipDelegate onCallOK];
    }
    
    [[HYVoIPCore sharedInstance] StopPlayingFileAsMicrophone];
    
    [webrtc startPlayout];
}
void UMPListener::onCallEnd(int code){
    NSLog(@"onCallEnd code=%d",code);
//    [HYVoIPCore sharedInstance].isCalling = NO;
    webrtcDelegate * webrtc = [webrtcDelegate getWebrtcDelegate];
    [webrtc stopVoiceEngine];
    if (voipDelegate && [voipDelegate respondsToSelector:@selector(onCallEnd:)]) {
        NSLog(@"voipDelegate onCallEnd = %d", code);
        [voipDelegate onCallEnd:code];
    }
}
void UMPListener::onURTPReady(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt){
    NSLog(@"onURTPReady remoteIP:%s remotePort:%d localIP:%s localPort:%d pt:%d",remoteIP,remotePort,localIP,localPort,pt);
    if(!compare(IP(remoteIP),remotePort,IP(localIP),localPort,pt)){
        NSLog(@"onURTPReady startVoiceEngine");
        set(IP(remoteIP),remotePort,IP(localIP),localPort,pt);
        webrtcDelegate * webrtc = [webrtcDelegate getWebrtcDelegate];
        [webrtc startVoiceEngine:localPort IP:remoteIP port:remotePort payloadtype:pt];
    }
}
void UMPListener::onKeepAlive(){
    NSLog(@"onKeepAlive");
}
void UMPListener::onKeepAliveAck(){
    NSLog(@"onKeepAliveAck");
}
void UMPListener::onStartVoice(const char * remoteIP,unsigned short remotePort,const char * localIP,unsigned short localPort,unsigned short pt){
    NSLog(@"onStartVoice remoteIP:%s remotePort:%d localIP:%s localPort:%d pt:%d",remoteIP,remotePort,localIP,localPort,pt);
}
void UMPListener::onStopVoice(){
    NSLog(@"onStopVoice");
}

void UMPListener::onMessage(const char * fromuid,const char * fromnumber,const char * content){
    NSLog(@"onMessage fromuid=%s,fromnumber=%s,content=%s",fromuid,fromnumber,content);
    if (voipDelegate && [voipDelegate respondsToSelector:@selector(onMessage:Uid:Number:)]) {
        [voipDelegate onMessage:[NSString stringWithUTF8String:content]
                            Uid:[NSString stringWithUTF8String:fromuid]
                         Number:[NSString stringWithUTF8String:fromnumber]];
    }
}

void UMPListener::onMessageAck(const char * origsmsid,const char * newsmsid){
    NSLog(@"onMessageAck origsmsid=%s,newsmsid=%s",origsmsid,newsmsid);
    if (voipDelegate && [voipDelegate respondsToSelector:@selector(onMessageAckOldID:NewID:)]) {
        [voipDelegate onMessageAckOldID:[NSString stringWithUTF8String:origsmsid]
                                  NewID:[NSString stringWithUTF8String:newsmsid]];
    }
}

bool UMPListener::compare(const IP& remoteIP,unsigned short remotePort,const IP& localIP,unsigned short localPort,unsigned short pt){
    return ((lastRemoteIP==remoteIP) && (lastRemotePort==remotePort) && (lastlocalIP==localIP) && (lastlocalPort==localPort) && (lastPT == pt));
}

void UMPListener::set(const IP& remoteIP,unsigned short remotePort,const IP& localIP,unsigned short localPort,unsigned short pt){
    lastRemoteIP = remoteIP;
    lastRemotePort = remotePort;
    lastlocalIP = localIP;
    lastlocalPort = localPort;
    lastPT = pt;
}

