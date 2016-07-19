//
//  HYVoIPCore.m
//  VoIPSDK
//
//  Created by admin on 15/3/18.
//  Copyright (c) 2015年 Dev. All rights reserved.
//

#import "HYVoIPCore.h"
#import "WebrtcDelegate.h"
#import "VoIPUtil.h"
#import <netdb.h>
#include <arpa/inet.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioSession.h>
#import <CoreFoundation/CFString.h>
#import <AVFoundation/AVAudioSession.h>
#import <UIKit/UIAlertView.h>

#define KUCaller_Number @"KUCaller_Number"
#define KUCaller_PlainPWD @"KUCaller_PlainPWD"

#define MASTER_HCP_DOMAIN @"hcp.yxhuying.com"
#define SLAVE_HCP_SERVERDOMAIN @"hcp2.yxhuying.com"
#define MASTER_HCP_SERVER @"210.21.118.202:1800"// 默认主IP
#define SLAVE_HCP_SERVER1 @"219.141.178.104:1800"
#define SLAVE_HCP_SERVER2 @"121.8.199.6:1800"

#define VOICE_MAX 255
#define VOICE_MIN 0

@implementation HYVoIPCore
{
    webrtcDelegate * webrtc;
    
    NSThread *coreThread;
    CFRunLoopRef coreRunLoop;
    BOOL isRunning;
    
    NSString *account;
    NSString *md5Pwd;
    
    NSTimeInterval serverIPtimeInterval;
    NSArray *domainUrls;
    NSString *clientVersion;
}

@synthesize voipDelegate;
@synthesize isOnline;
//@synthesize isCalling;
@synthesize isIPV6;

static HYVoIPCore *sharedInstance = nil;

+(HYVoIPCore *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[HYVoIPCore alloc] init];
        }
    }
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self startNewThread];
        webrtc = [webrtcDelegate getWebrtcDelegate];
        [webrtc initWithVoiceEngine];
        [webrtc setLog:YES];
        serverIPtimeInterval = [[NSDate date] timeIntervalSince1970];
        clientVersion = [VoIPUtil getClientInfo];
    }
    return self;
}

-(void)dealloc
{
    [webrtc terminateVoiceEngine];
    [self stopThread];
}

-(void)start
{
    [self perform:@selector(startSync)];
}

-(void)stop
{
    //nothing
}

-(void)login:(NSString *)number password:(NSString *)passwd
{
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:number, KUCaller_Number, passwd, KUCaller_PlainPWD, nil];
    [self perform:@selector(loginSyncWithPlainPsw:) withData:data];
}

-(void)loginWithMD5Psw:(NSString *)number password:(NSString *)passwd
{
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:number, KUCaller_Number, passwd, KUCaller_PlainPWD, nil];
    [self perform:@selector(loginSyncWithMD5Psw:) withData:data];
}

-(void)reLogin
{
    [self perform:@selector(reLoginSync)];
}


-(void)logout
{
    [self perform:@selector(logoutSync)];
}

-(BOOL)call:(NSString *)number
{
    if(number.length < 5){
        return NO;
    }
    
    NSString *subStr = [number substringToIndex:1];
    NSString *sub95013 = nil;
    if (number && number.length > 5) {
        sub95013 = [number substringToIndex:5];
    }
    
    NSString *validNumber;
    if ([subStr compare:@"0"] == NSOrderedSame ||
        [sub95013 compare:@"95013"] == NSOrderedSame) {
        //以‘0’开头的号码
        validNumber = number;
    }
    else {
        //非‘0’开头的号码
        validNumber = [NSString stringWithFormat:@"0%@", number];
    }
    
    NSLog(@"call to number = %@", validNumber);
    [webrtc call:validNumber];
    return YES;
}

-(void)answerCall
{
    [self perform:@selector(answerCallSync)];
}

-(void)endCall
{
    [self perform:@selector(endCallSync)];
}

-(void)sendDTMF:(NSString *)dtmf
{
    [self perform:@selector(setDTMFSync:) withData:dtmf];
}

-(void)setSpeaker:(BOOL)on
{
    [self perform:@selector(setSpeakerSync:) withData:[NSNumber numberWithBool:on]];
}

-(void)setMute:(BOOL)on
{
    [self perform:@selector(setMuteSync:) withData:[NSNumber numberWithBool:on]];
}

- (void)StartPlayingFileAsMicrophone :(NSString*)filename loop:(BOOL)isloop
{
    [webrtc StartPlayingFileAsMicrophone:filename loop:isloop];
}

- (void)StopPlayingFileAsMicrophone
{
    [webrtc StopPlayingFileAsMicrophone];
}

-(void)setServerDomaines:(NSArray *)domaines
{
    domainUrls = domaines;
}

-(void)sendMessage:(NSDictionary *)info
{
    [webrtc sendMsg:[info objectForKey:@"uid"] number:[info objectForKey:@"number"] content:[info objectForKey:@"content"] smsid:[info objectForKey:@"smsid"] type:1];
}
- (void)sendCardMessage:(NSDictionary *)info
{
   [webrtc sendMsg:[info objectForKey:@"uid"] number:[info objectForKey:@"number"] content:[info objectForKey:@"content"] smsid:[info objectForKey:@"smsid"] type:6];
}
-(void)sendLocation:(NSDictionary *)info
{
    [webrtc sendMsg:[info objectForKey:@"uid"] number:[info objectForKey:@"number"] content:[info objectForKey:@"content"] smsid:[info objectForKey:@"smsid"] type:5];
}

-(void)setClientVersion:(NSString *)aClientVersion
{
    clientVersion = aClientVersion;
}


-(NSString *)setServerIP:(NSArray *)aDomainURLs
{
    NSString *ipMaster;
    //    NSLog(@"domainUrls.count = %ld", aDomainURLs.count);
    //    for (NSString *domainUrl in domainUrls) {
    //        NSString *serverIP = nil;
    //        serverIP = domainUrl;
    //
    //        NSLog(@"UMP Server IP :%@",serverIP);
    //        if ([domainUrl isEqualToString:domainUrls[0]]) {
    //            ipMaster = domainUrl;
    //            [webrtc addServer:serverIP clear:YES];
    //        }
    //        else {
    //            [webrtc addServer:serverIP clear:NO];
    //        }
    //    }
    
    
    struct hostent *ipV6Hostent = gethostbyname2("www.baidu.com",AF_INET6);
    if (ipV6Hostent) {
        isIPV6 = YES;
    }else{
        isIPV6 = NO;
    }
    
    NSLog(@"domainUrls.count = %ld", aDomainURLs.count);
    for (NSString *domainUrl in domainUrls) {
        NSString *serverIP = nil;
        //NSString to char*
        const char *webSite = [domainUrl cStringUsingEncoding:NSASCIIStringEncoding];
        // Get host entry info for given host
        struct hostent *remoteHostEnt = gethostbyname(webSite);
        if (remoteHostEnt != nil) {
            struct in_addr *remoteInAddr = (struct in_addr *) remoteHostEnt->h_addr_list[0];
            // Convert numeric addr to ASCII string
            char *sRemoteInAddr = inet_ntoa(*remoteInAddr);
            //char* to NSString
            NSString *ipAddress = [[NSString alloc] initWithCString:sRemoteInAddr
                                                           encoding:NSASCIIStringEncoding];
            NSString *ipAddressWithPort = [NSString stringWithFormat:@"%@:1800",ipAddress];
            serverIP = ipAddressWithPort;
        }
        else {
            serverIP = domainUrl;
        }
        
        NSLog(@"UMP Server IP :%@",serverIP);
        if ([domainUrl isEqualToString:domainUrls[0]]) {
            ipMaster = domainUrl;
            [webrtc addServer:serverIP clear:YES];
        }
        else {
            [webrtc addServer:serverIP clear:NO];
        }
    }
    
    return ipMaster;
}


-(void)startSync
{
    NSLog(@"VoIPSDKCore UMP start!");
    [webrtc setListenerDelegate:voipDelegate];
    [webrtc setClientInfo:MASTER_HCP_SERVER dev:[self uuid] os:clientVersion];
}

-(NSString*) uuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    CFStringRef resultRef = CFStringCreateCopy( NULL, uuidString);
    NSString * result = (__bridge_transfer NSString *)resultRef;
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

-(void)loginSyncWithPlainPsw:(NSDictionary *)data
{
    NSString *number = [data objectForKey:KUCaller_Number];
    NSString *passwd = [data objectForKey:KUCaller_PlainPWD];
    
    NSString *md5PWD = [[VoIPUtil md5:passwd] uppercaseString];
    NSLog(@"number = %@, passwd = %@", number, passwd);
    
    account = number;
    md5Pwd = md5PWD;
    
    [self setServerIP:nil];
    [webrtc login:account passwd:md5Pwd];
}

-(void)loginSyncWithMD5Psw:(NSDictionary *)data
{
    NSString *number = [data objectForKey:KUCaller_Number];
    NSString *passwd = [data objectForKey:KUCaller_PlainPWD];
    NSLog(@"number = %@, passwd = %@", number, passwd);
    
    account = number;
    md5Pwd = passwd;
    
    [self setServerIP:nil];
    [webrtc login:account passwd:md5Pwd];
    
}


-(void)reLoginSync
{
    static NSInteger count = 0;
    if (count >= 10) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        if ((time-serverIPtimeInterval-600.0) > 0.00001) {
            //比上一次间隔超过10分钟
            count = 0;
        }
        else{
            return ;
        }
    }
    
    NSLog(@"reLoginSync count = %ld", (long)count);
    serverIPtimeInterval = [[NSDate date] timeIntervalSince1970];
    count++;
    
    [self setServerIP:domainUrls];
    [webrtc login:account passwd:md5Pwd];
}

-(void)logoutSync
{
    NSLog(@"VoIPSDKCore UMP logout!");
    account = nil;
    md5Pwd = nil;
    [webrtc logout:NO];//同步登出
    isOnline = NO;
    NSLog(@"logoutSync%d",isOnline);
}

-(void)endCallSync
{
    NSLog(@"VoIPCore endCallSync start");
    [webrtc endCall];
    NSLog(@"VoIPCore endCallSync end");
}

-(void)answerCallSync
{
    NSLog(@"obj-C answerCallSync succ!");
    [webrtc answerCall];
}

-(void)setDTMFSync:(NSString *)dtmf
{
    [webrtc sendDTMF:dtmf];
}

-(void)setSpeakerSync:(NSNumber *)enable
{
    BOOL success;
    NSError* error;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                             error:&error];
    if (!success){
         NSLog(@"AVAudioSession error setting category:%@",error);
    }
    
    UInt32 route;
    route = enable.boolValue ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone;
    success = [session overrideOutputAudioPort:route
                                         error:&error];
    if (!success){
        NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
    }
    
    success = [session setActive:YES error:&error];
    if (!success){
        NSLog(@"AVAudioSession error activating: %@",error);
    }
    else{
        NSLog(@"audioSession active");
    }
}

-(void)setMuteSync:(NSNumber *)enable
{
    [webrtc setInputMute:enable.boolValue];
}

- (void)setAutoKeepAlive :(int) sec
{
    [webrtc setAutoKeepAlive:sec];
}

- (void)sendKeepAlive
{
    [webrtc sendKeepAlive];
}

#pragma mark ------------ corebase --------------------
-(void)startNewThread
{
    [NSThread detachNewThreadSelector:@selector(runThread) toTarget:self withObject:nil];
}

-(void)runThread
{
    @autoreleasepool {
        coreThread = [NSThread currentThread];
        coreThread.name = @"VoIPSDKThread";
        NSLog(@"VoIPSDKCore coreThread.name = %@, create succ!", coreThread.name);
        coreRunLoop = CFRunLoopGetCurrent();
        
        CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
        CFRunLoopSourceRef src = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), src, kCFRunLoopDefaultMode);
        
        isRunning = YES;
        while (isRunning) {
            CFRunLoopRun();
        }
        
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), src, kCFRunLoopDefaultMode);
        CFRelease(src);
    }
}

-(void)stopThread
{
    NSLog(@"VoIPSDKCore coreThread.name = VoIIPSDKThread cancel succ!");
    isRunning = NO;
    CFRunLoopStop(coreRunLoop);
    [coreThread cancel];
}

-(void)perform:(SEL)selector
{
    [self performSelector:selector onThread:coreThread withObject:nil waitUntilDone:NO];
}

-(void)perform:(SEL)selector withData:(id)data
{
    [self performSelector:selector onThread:coreThread withObject:data waitUntilDone:NO];
}

@end
