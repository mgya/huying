//
//  VoIPUtil.h
//  VoIPSDK
//
//  Created by thehuah on 11-11-10.
//  Copyright 2011年 X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "VoIPDefine.h"

@interface VoIPUtil : NSObject

+(NSString *)des:(NSString *)aKey plain:(NSString *)plainText;
+(NSString*)md5:(NSString*)string;

+(NSString*)makeUUID;

+(NSString *)trimString:(NSString *)string;
+(NSString*)getIPByDomain:(NSString*)strDomain;

+(NSString *)getClientInfo;
+(NSString *)getDevID;
+(NSString *)getDevInfo;
+(NSString *)getLocalIP;
+(NSArray *)getLocalIPs;

+(BOOL)isEmpty:(NSString *)str;
//+(BOOL)matchNumber:(NSString *)number1 with:(NSString *)number2;
+(NSString *)substringFromStart:(NSString *)str sep:(NSString *)sep;

//判断是否为正确手机号本地判断
+(NSString *)correctPhone:(NSString *)phone;

+(BOOL)isNum:(NSString *)phone;

+(void)checkCallNumber:(NSMutableString *)number;

+(NSString *)getShowTime:(double)time;
+(NSString *)getShowTime:(NSDate*)date bTime:(BOOL)btime;

+(NSString *)documentFolder;
+(NSString *)bundleFolder;

+(NSString *)getCurrentTime;
+(NSString *)getCurrentTime2;
+(NSString *)stringFromDate:(NSDate*)date;
+(NSString *)stringFromExpireDate:(NSDate*)date;
+(NSDate *)dateFromString:(NSString*)string;
// 由date转变成NSDateComponents
+(NSDateComponents*) date2DateComponent: (NSDate*)date;

+(NSString*)saveAudio:(NSString*)audioString;

+(BOOL)canConnectTo:(NSString *)host;
+(BOOL)systemBeforeSeven;
+(BOOL)systemBeforeFive;

@end
