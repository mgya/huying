//
//  WebrtcDelegate.h
//  webRtc
//
//  Created by well on 15/2/2.
//  Copyright (c) 2015年 changzheng-Mac. All rights reserved.
//

#ifndef webRtc_WebrtcDelegate_h
#define webRtc_WebrtcDelegate_h

#import <Foundation/Foundation.h>

@interface LockForVoiceEngine : NSObject

@end

@interface webrtcDelegate : NSObject

+ (webrtcDelegate*) getWebrtcDelegate;

- (void)initWithVoiceEngine;
- (void)terminateVoiceEngine;

- (void)startVoiceEngine :(short)localPort IP:(const char *)destIP port:(short)destPort payloadtype:(short)pt;
- (void)stopVoiceEngine;

- (int32_t)login :(NSString*)username passwd:(NSString*)pwd c_id:(NSString*)cid;//modified by liyr 2015-12-03
- (void)logout:(BOOL)isAsync;

- (void)call :(NSString*)number;
- (void)resetUmpEngine;
- (void)answerCall;
- (void)refuseCall;
- (void)endCall;
- (void)setCallConnect :(BOOL)isconnected;

//one of to_uid and to_number can be empty
- (void)sendMsg :(NSString*)to_uid number:(NSString*)to_number content:(NSString*)to_content smsid:(NSString*) origsmsid type:(int)contenttype;
- (void)sendDTMF :(NSString*)dtmf;

- (void)addServer:(NSString*)addr clear:(BOOL)isclear;//注册的server ip地址
- (void)setClientInfo :(NSString*)localIP dev:(NSString*)devID os:(NSString*)osInfo;
- (void)setLog :(BOOL)isOpen;
- (void)setLogToFile :(NSString*)path;

//sec=-1 means close keepalive of lib
- (void)setAutoKeepAlive :(int) sec;
- (void)sendKeepAlive;

- (void)setInputMute :(BOOL)enable;
- (void)StartPlayingFileAsMicrophone :(NSString*)filename loop:(BOOL)isloop;
- (void)StopPlayingFileAsMicrophone;

//0-255
//耳机
- (void)SetSpeakerVolume :(int)volume;
- (int)GetSpeakerVolume;

//mai
- (void)SetMicrophoneVolume :(int)volume;
- (int)GetMicrophoneVolume;

- (void)setListenerDelegate:(id)voipDelegate;

-(void)startPlayout;
-(void)stopPlayout;

@end

#endif
