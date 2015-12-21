//
//  VoiceConverter.m
//  Converting
//
//  Created by 309 on 13-3-20.
//  Copyright (c) 2013年 309. All rights reserved.
//

#import "VoiceConverter.h"
#import "wav.h"
#import "interf_dec.h"
#import "dec_if.h"
#import "interf_enc.h"
#import "amrFileCodec.h"

@implementation VoiceConverter

+ (NSString*)getDocumentPath {
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return documentDir;
}

+ (BOOL)wavToAmr:(NSString *)filePath storedPath:(NSString **)armPath{
    BOOL result = NO;
     NSString* newFilePath = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    if (filePath && [fm fileExistsAtPath:filePath]) {
       
        NSString* fileName = [filePath lastPathComponent];
        if ([fileName hasSuffix:@"wav"]) {
            newFilePath = [filePath stringByReplacingOccurrencesOfString:@"wav" withString:@"amr"];
        } else {
            NSString* fileDir = [filePath stringByDeletingLastPathComponent];
            fileName = [fileName stringByAppendingString:@".amr"];
            newFilePath = [fileDir stringByAppendingPathComponent:fileName];
        }
        
        // WAVE音频采样频率是8khz
        // 音频样本单元数 = 8000*0.02 = 160 (由采样频率决定)
        // 声道数 1 : 160
        //        2 : 160*2 = 320
        // bps决定样本(sample)大小
        // bps = 8 --> 8位 unsigned char
        //       16 --> 16位 unsigned short
        const char* fpStr = [filePath cStringUsingEncoding:NSASCIIStringEncoding];
        const char* nfpStr = [newFilePath cStringUsingEncoding:NSASCIIStringEncoding];
        if (fpStr && nfpStr && EncodeWAVEFileToAMRFile(fpStr, nfpStr, 1, 16)) {
            result = YES;
        }
    }
    
    *armPath = newFilePath;
    return result;
}

+ (BOOL)amrToWav:(NSString *)filePath storedPath:(NSString **)wavPath{
    BOOL result = NO;
    NSString* newFilePath = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    if (filePath && [fm fileExistsAtPath:filePath]) {
        
        NSString* fileName = [filePath lastPathComponent];
        if ([fileName hasSuffix:@"amr"]) {
            newFilePath = [filePath stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"];
        } else {
            NSString* fileDir = [filePath stringByDeletingLastPathComponent];
            fileName = [fileName stringByAppendingString:@".wav"];
            newFilePath = [fileDir stringByAppendingPathComponent:fileName];
        }
        
        const char* fpStr = [filePath cStringUsingEncoding:NSASCIIStringEncoding];
        const char* nfpStr = [newFilePath cStringUsingEncoding:NSASCIIStringEncoding];
        if (fpStr && nfpStr && DecodeAMRFileToWAVEFile(fpStr, nfpStr)) {
            result = YES;
        }
    }
    
    *wavPath = newFilePath;
    return result;
}

@end
