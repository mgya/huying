//
//  Util.h
//  uCaller
//
//  Created by 崔远方 on 14-3-10.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface Util : NSObject

+(BOOL)isEmpty:(NSString *)str;
+(BOOL)matchString:(NSString *)str1 and:(NSString *)str2;
+(NSString *)substringFromStart:(NSString *)str sep:(NSString *)sep;
+(BOOL)canConnectTo:(NSString *)host;
+(BOOL)ConnectionState;
+(NSString*)getIPByDomain:(NSString*)strDomain;
+(NSString *)DevicePlatform;
+(NSString *)getDevInfo;
+(NSString *)getDevID;
+(NSArray *)getLocalIPs;
+(NSString *)getCurrentTime;
+(NSString *)getClientInfo;
+(NSString*)md5:(NSString*)string;//加密
+(NSString *)des:(NSString *)key plain:(NSString *)plainText;//解密
+(NSString *)getArea:(NSString *)number;//获得当前号码所在地
+(NSString*)getSystemInfo;
+(NSString*)getOnLineStyle;
+(NSString *)cachePhotoFolder;
+(NSString *)documentFolder;
+(NSString *)bundleFolder;

+(NSString *)xmppEncode:(NSString *)plainText;
+(NSString *)xmppDecode:(NSString *)encryText;

+(NSString *)getErrorMsg:(NSInteger)errCode;//获取相应错误码对应的错误提示

+(NSString *)getXMPPID:(NSString *)user;
+(NSString *)getUNumber:(NSString *)user;
+(NSString *)getPNumber:(NSString *)number;
+(NSString *)getValidNumber:(NSString *)number;

+(BOOL)isPhoneNumber:(NSString *)number;//判断是否为手机号
+(BOOL)isUNumber:(NSString *)number;
+(BOOL)isPNumber:(NSString *)number;

+(void)checkCallNumber:(NSMutableString *)number;
+(BOOL)matchNumber:(NSString *)number1 with:(NSString *)number2;
+(BOOL)matchPNumber:(NSString *)number1 with:(NSString *)number2;

+(void)sendInvite:(NSArray *)numbers from:(UIViewController *)vc andContent:(NSString *)smsContent;
+(NSString *)getAudioFileName:(NSString *)number suffix:(NSString *)suffix;
+(NSString*)saveAudio:(NSData *)audioData fileName:(NSString *)fileName;
+(void)removeAudioFile:(NSString *)fileName;

+(NSString *)getShowTime:(double)time;
+(NSString *)getShowTime:(NSDate*)date bTime:(BOOL)btime;
+(NSString *)getShowTime:(NSDate*)adate aTime:(BOOL)atime;

+(BOOL)systemBeforeFive;
+(BOOL)systemBeforeSeven;
+(NSString *)getCurrentSystem;//当前手机系统版本 如8.0
+(NSString *)getCurrentDeviceInfo;//获取当前设备信息
+(NSString *)getShowData:(double)time;

+(NSString *)getAppVersion;
+(BOOL)isNum:(NSString *)phone;

+(NSString *)getGender:(NSString *)gender;//计算性别
+(NSString *)getAge:(NSString *)birthday;//计算生日
//计算星座
+(NSString *)constellationFunction:(NSString *)dateStr;//(dateStr为yyyy-MM-dd格式)

+(NSInteger)stringTransfromInterger:(NSDictionary *)aDic;//学历，收入，感情状况转换
+(NSString *)intergerTransfromString:(NSDictionary *)aDic;

//计算文本size
+(CGSize ) countTextSize:(NSString *)contentStr MaxWidth:(CGFloat )maxWidth MaxHeight:(CGFloat )maxHeight UFont:(UIFont *)uFont LineBreakMode:(NSLineBreakMode )lineBreakMode Other:(id)other;

+(NSDictionary *)getMoodDict;//获取表情
+(BOOL)addXMPPContact:(NSString *)strNumber andMessage:(NSString *)message;//添加XMPP好友
+(void)pushView:(UIViewController *)fromView;//引导页动画

//+(BOOL)checkShareTimeInterval;
//+(BOOL)checkShareInfo;

+ (BOOL)validatePassword:(NSString *)passWord;//是否是合法的密码
+(BOOL)isNumber:(NSString *)number;//判断是否是号码

+(BOOL)checkNotice;//是否获取公告内容

+(int)getRandomNumber:(int)from to:(int)to;//随机数

+(NSString*)makeUUID;//获取mac唯一标识

+(UIButton *)getNaviBackBtn:(UIViewController *)aTarget;
@end
