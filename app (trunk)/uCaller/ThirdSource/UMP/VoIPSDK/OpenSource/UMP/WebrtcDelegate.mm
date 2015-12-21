//
//  WebrtcDelegate.m
//  webRtc
//
//  Created by well on 15/2/2.
//  Copyright (c) 2015年 changzheng-Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WebrtcDelegate.h"

#include "webrtc/voice_engine/include/voe_base.h"
#include "webrtc/voice_engine/include/voe_codec.h"
#include "webrtc/voice_engine/include/voe_file.h"
#include "webrtc/voice_engine/include/voe_network.h"
#include "webrtc/voice_engine/include/voe_audio_processing.h"
#include "webrtc/voice_engine/include/voe_volume_control.h"
#include "webrtc/voice_engine/include/voe_hardware.h"
#include "channel_transport.h"

#include "ump/URTP/urtp_encryption.h"
#include "ump/UMPEngine.h"
#include "UMPListener.h"
#include "ump/Common/ulog.h"

using namespace webrtc;

@interface webrtcDelegate ()
{
    VoiceEngine* voeEngine;
    VoEBase* voeBase;
    VoECodec* voeCodec;
    VoEFile* voeFile;
    VoENetwork* voeNetwork;
    VoEAudioProcessing* voeApm;
    VoEVolumeControl* voeVolume;
    VoEHardware* voeHardware;
    test::VoiceChannelTransport* voiceChannelTransport;
    int audioChannel;
    
    URTPEncryption* urtpEncryption;
    UMPEngine * umpEngine;
    UMPListener * umpListener;
    LockForVoiceEngine *lockForVoiceEngine;

}
@end

static webrtcDelegate * wdSingleton = nil;

@implementation LockForVoiceEngine

@end

@implementation webrtcDelegate


+(webrtcDelegate*) getWebrtcDelegate{
    @synchronized(self){
        if(!wdSingleton){
            wdSingleton = [[webrtcDelegate alloc] init];
        }
    }
    return wdSingleton;
}

- (void)initWithVoiceEngine{
    voeEngine = VoiceEngine::Create();
    voeBase = VoEBase::GetInterface(voeEngine);
    voeCodec = VoECodec::GetInterface(voeEngine);
    voeFile = VoEFile::GetInterface(voeEngine);
    voeNetwork = VoENetwork::GetInterface(voeEngine);
    voeApm = VoEAudioProcessing::GetInterface(voeEngine);
    voeVolume = VoEVolumeControl::GetInterface(voeEngine);
    voeHardware = VoEHardware::GetInterface(voeEngine);
    urtpEncryption = URTPEncryption::getURTPEncryption();
    umpEngine = UMPEngine::getUMPEngine();
    umpListener = new UMPListener();
    umpEngine->SetEventSink(umpListener);
    lockForVoiceEngine = [[LockForVoiceEngine alloc] init];
    int error;
    error = voeBase->Init();
    if (error) {
        NSLog(@"Init audio error = %d", error);
    }
//    audioChannel=-1;
    audioChannel = voeBase->CreateChannel();
    
    voeApm->SetAgcStatus(true);
    voeApm->SetEcStatus(true,kEcAecm);
    voeApm->SetNsStatus(true,kNsModerateSuppression);
}

- (int32_t)login :(NSString*)username passwd:(NSString*)pwd{
    const char * username_in =[username UTF8String];
    const char * pwd_in =[pwd UTF8String];
    return umpEngine->Login(username_in, pwd_in,"");
}

- (void)logout:(BOOL)isAsync{
    umpEngine->Logout(isAsync);
}

- (void)call :(NSString*)number{
    const char * number_in =[number UTF8String];
    umpEngine->Call(number_in);
}

- (void)resetUmpEngine{
    umpEngine->ResetUppSession();
}

- (void)answerCall{
    umpEngine->AnswerCall();
}

- (void)endCall{
    umpEngine->EndCall();
}

- (void)refuseCall{
    umpEngine->RefuseCall();
}

- (void)setCallConnect :(BOOL)isconnected{
    voiceChannelTransport->SetCallConnected((bool)isconnected);
}

- (void)sendMsg :(NSString*)to_uid number:(NSString*)to_number content:(NSString*)to_content smsid:(NSString*) origsmsid type:(int)contenttype;{
    const char * to_uid_in =[to_uid UTF8String];
    const char * to_number_in =[to_number UTF8String];
    const char * to_content_in =[to_content UTF8String];
    const char * origsmsid_in =[origsmsid UTF8String];
    umpEngine->SendMsg(to_uid_in, to_number_in, to_content_in, origsmsid_in,contenttype);
}

- (void)sendDTMF :(NSString*)dtmf{
    const char * dtmf_in =[dtmf UTF8String];
    umpEngine->SendDTMF(dtmf_in);
}

- (void)addServer :(NSString*)addr clear:(BOOL)isclear{
    const char * addr_in =[addr UTF8String];
    umpEngine->AddServer(addr_in, (bool)isclear);
}

- (void)setClientInfo :(NSString*)localIP dev:(NSString*)devID os:(NSString*)osInfo{
    const char * localIP_in =[localIP UTF8String];
    const char * devID_in =[devID UTF8String];
    const char * osInfo_in =[osInfo UTF8String];
    umpEngine->SetClientInfo(localIP_in, devID_in, osInfo_in);
}

- (void)setLog :(BOOL)isOpen{
    if(isOpen){
        set_logon();
    }else{
        set_logoff();
    }
}

- (void)setLogToFile :(NSString*)path{
    const char * path_in =[path UTF8String];
    set_logtofile(path_in);
}

- (void)setAutoKeepAlive :(int) sec{
    umpEngine->SetAutoKeepAlive(sec);
}

- (void)sendKeepAlive{
    umpEngine->KeepAlive();
}

- (void)setInputMute :(BOOL)enable{
    voeVolume->SetInputMute(audioChannel, enable);
}

- (void)StartPlayingFileAsMicrophone :(NSString*)filename loop:(BOOL)isloop{
    const char * filename_in =[filename UTF8String];
    voeFile->StartPlayingFileAsMicrophone(audioChannel, filename_in,(bool)isloop,false,kFileFormatWavFile);
}

- (void)StopPlayingFileAsMicrophone{
    voeFile->StopPlayingFileAsMicrophone(audioChannel);
}

- (void)SetSpeakerVolume :(int)volume{
//    voeVolume->SetSpeakerVolume(volume);
    
    float gain = (float)volume *10/255;
    if(gain > 10.0)
        gain=10.0;
    voeVolume->SetChannelOutputVolumeScaling(audioChannel, gain);
}

- (int)GetSpeakerVolume{
    float volume = 0;
//    voeVolume->GetSpeakerVolume(volume);
    voeVolume->GetChannelOutputVolumeScaling(audioChannel, volume);
    NSLog(@"GetSpeakerVolume volume = %f",volume);
    return (int)volume;
}

- (void)SetMicrophoneVolume :(int)volume{
    voeVolume->SetMicVolume(volume);
}

- (int)GetMicrophoneVolume{
    uint volume = 0;
    voeVolume->GetMicVolume(volume);
    return volume;
}

- (void)startVoiceEngine :(unsigned short)localPort IP:(const char *)destIP port:(unsigned short)destPort payloadtype:(unsigned short)pt{
//    if(audioChannel >= 0){
//        NSLog(@"Audio channel already created");
//        [self stopVoiceEngine];
//        audioChannel=-1;
//    }
    
//    voeApm->SetAgcStatus(true);
//    voeApm->SetEcStatus(true,kEcAecm);
//    voeApm->SetNsStatus(true,kNsModerateSuppression);
    
    
//    audioChannel = voeBase->CreateChannel();
//    if (audioChannel < 0) {
//        NSLog(@"Audio create channel error");
//        return;
//    }
    
    NSLog(@"Audio channel is %d\n",audioChannel);
    
    if (voiceChannelTransport) {
        NSLog(@"voiceChannelTransport already created");
        [self stopVoiceEngine];
    }
    
    voiceChannelTransport = new test::VoiceChannelTransport(voeNetwork, audioChannel,urtpEncryption);
    voiceChannelTransport->SetLocalReceiver(localPort);
    voiceChannelTransport->SetSendDestination(destIP, destPort);
    voiceChannelTransport->SetPT(pt);
    
    webrtc::CodecInst codecToList;
    int i=0;
    for (i = 0; i < voeCodec->NumOfCodecs(); ++i) {
        voeCodec->GetCodec(i, codecToList);
        if(pt == codecToList.pltype) {
            break;
        }
        //NSLog(@"VoE Codec list %s, pltype=%d\n", codecToList.plname, codecToList.pltype);
    }
    NSLog(@"Select Codec list %s, pltype=%d\n", codecToList.plname, codecToList.pltype);
    voeCodec->SetSendCodec(audioChannel, codecToList);
    voeBase->StartReceive(audioChannel);
    voeBase->StartPlayout(audioChannel);
    voeBase->StartSend(audioChannel);
    
    voeVolume->SetChannelOutputVolumeScaling(audioChannel, 3.0);
    
    
}

- (void)stopVoiceEngine {
    
//    NSLog(@"will enter stopVoiceEngine");
    @synchronized(lockForVoiceEngine)
    {
        NSLog(@"enter stopVoiceEngine");
        voeBase->StopReceive(audioChannel);
        voeBase->StopPlayout(audioChannel);
        voeBase->StopSend(audioChannel);
        if (voiceChannelTransport) {
            delete voiceChannelTransport;
            voiceChannelTransport = NULL;
        }
        //    voeBase->DeleteChannel(audioChannel);
        //    audioChannel=-1;
        NSLog(@"exit stopVoiceEngine");
    }
//    NSLog(@"will exit stopVoiceEngine");
}

- (void)terminateVoiceEngine {
    voeBase->StopReceive(audioChannel);
    voeBase->StopPlayout(audioChannel);
    voeBase->StopSend(audioChannel);
    
    VoiceEngine::Delete(voeEngine);
    if (voiceChannelTransport) {
        delete voiceChannelTransport;
        voiceChannelTransport = NULL;
    }
    voeBase->DeleteChannel(audioChannel);
    
    voeBase->Release();
    
    voeCodec->Release();
    voeFile->Release();
    voeNetwork->Release();
    voeApm->Release();
    voeVolume->Release();
    voeHardware->Release();
    
    voeBase->Terminate();
    audioChannel=-1;
    
    if(umpEngine){
        umpEngine->Stop();
        delete umpEngine;
    }
    
    if(umpListener){
        delete umpListener;
        umpListener=NULL;
    }
    
//    if(lockForVoiceEngine){
//        [lockForVoiceEngine dealloc];
//        lockForVoiceEngine = nil;
//    }
}

- (void)setListenerDelegate:(id)voipDelegate
{
    umpListener->voipDelegate = voipDelegate;
}

-(void)startPlayout
{
    voeBase->StartPlayout(audioChannel);
}

-(void)stopPlayout
{
    voeBase->StopPlayout(audioChannel);
}

@end