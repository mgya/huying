//
//  Util.m
//  uCaller
//
//  Created by 崔远方 on 14-3-10.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <stdio.h>
#import <stdlib.h>
#import <unistd.h>
#import <string.h>
#import <errno.h>

#import <pthread.h>

#import <sys/ioctl.h>
#import <sys/sysctl.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <sys/sockio.h>
#import <netinet/in.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <netdb.h>
#import <arpa/inet.h>

#import <MessageUI/MessageUI.h>

#import "Util.h"
#import "UAdditions.h"
#import "UDefine.h"
#import "Reachability.h"
#import "UMP/VoIPSDK/OpenSource/OpenUDID.h"
#import "UCallerGTMBase64.h"

#import "Media2BytesUtil.h"
#import "VoiceConverter.h"

#import "DBManager.h"
#import "Util.h"
#import "UCore.h"
#import "XAlertView.h"
#import "iToast.h"
#import "XAlert.h"
#import "ContactManager.h"
#import "UConfig.h"
#import "UAppDelegate.h"
#import "ShareContent.h"
#import "UIUtil.h"

#import "TabBarViewController.h"

#define    min(a,b)    ((a) < (b) ? (a) : (b))
#define    max(a,b)    ((a) > (b) ? (a) : (b))

#define xmppServKey @"24c78d59" //XMPP通讯录上传加密Key
#define xmppServIv @"37ed6548" //XMPP通讯录上传加密偏移向量
#define USER_APP_PATH                 @"/User/Applications/"

@implementation Util

+(BOOL)isEmpty:(NSString *)str
{
    if((str == nil) || (str.length == 0))
        return YES;
    else
        return NO;
}

+(BOOL)matchString:(NSString *)str1 and:(NSString *)str2
{
    if(str1 == nil && str2 == nil)
        return YES;
    if(str1 == nil || str2 == nil)
        return NO;
    return [str1 isEqualToString:str2];
}

+(NSString *)substringFromStart:(NSString *)str sep:(NSString *)sep
{
    if([Util isEmpty:str])
        return @"";
    NSRange range = [str rangeOfString:sep];
    long index = range.location;
    NSString *subStr = (range.length > 0) ? [str substringToIndex:index]:str;
    return subStr;
}

+(BOOL)ConnectionState
{
    return [[UAppDelegate uApp] networkOK];
}

+(BOOL)canConnectTo:(NSString *)host
{
    Reachability *netReach = [Reachability reachabilityWithHostName:host];
    return [netReach isReachable];
}

+(NSString*)getIPByDomain:(NSString*)strDomain
{
    NSString *strName = nil;
    NSString *strPort = nil;
    NSRange range =[strDomain rangeOfString:@":"];
    if(range.length == 0)
        strName = strDomain;
    else
    {
        strName = [strDomain substringToIndex:range.location];
        strPort = [strDomain substringFromIndex:range.location+1];
    }
    
    if([Util canConnectTo:strName] == NO)
    {
        return nil;
    }
    
    const char* name = [strName UTF8String];
    
    BOOL isIP = YES;
    if (NULL == name) return nil;
    const char* p = name;
    for (; *p != '\0'; p++)
    {
        if ((isalpha(*p)) && (*p != '.'))
        {
            isIP = NO;
            break;
        }
    }
    
    if(isIP)
        return strDomain;
    
    struct hostent* host = gethostbyname(name);
    if(!host)
        return nil;
    
    struct in_addr ip_addr;
    memcpy(&ip_addr,host->h_addr_list[0],4);
    
    char ip[20] = {0};
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    
    NSMutableString* strIPAddress = [NSMutableString stringWithUTF8String:ip];
    
    if(strPort && strPort.length)
        [strIPAddress appendFormat:@":%@",strPort];
    return strIPAddress;
}

+(NSString *)DevicePlatform
{
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) {
        
        platform = @"iPhone";
        
    } else if ([platform isEqualToString:@"iPhone1,2"]) {
        
        platform = @"iPhone 3G";
        
    } else if ([platform isEqualToString:@"iPhone2,1"]) {
        
        platform = @"iPhone 3GS";
        
    } else if ([platform isEqualToString:@"iPhone3,1"]||[platform isEqualToString:@"iPhone3,2"]||[platform isEqualToString:@"iPhone3,3"]) {
        
        platform = @"iPhone 4";
        
    } else if ([platform isEqualToString:@"iPhone4,1"]) {
        
        platform = @"iPhone 4S";
        
    } else if ([platform isEqualToString:@"iPhone5,1"]||[platform isEqualToString:@"iPhone5,2"]) {
        
        platform = @"iPhone 5";
        
    }else if ([platform isEqualToString:@"iPhone5,3"]||[platform isEqualToString:@"iPhone5,4"]) {
        
        platform = @"iPhone 5C";
        
    }else if ([platform isEqualToString:@"iPhone6,2"]||[platform isEqualToString:@"iPhone6,1"]) {
        
        platform = @"iPhone 5S";
        
    }else if ([platform isEqualToString:@"iPhone7,1"])
    {
        platform = @"iPhone 6 Plus";
        
    }else if ([platform isEqualToString:@"iPhone7,2"])
    {
        platform = @"iPhone 6";
        
    }else if ([platform isEqualToString:@"iPhone8,1"])
    {
        platform = @"iPhone 6s Plus";
        
    }else if ([platform isEqualToString:@"iPhone8,2"])
    {
        platform = @"iPhone 6s";
        
    }else if ([platform isEqualToString:@"iPod4,1"]) {
        
        platform = @"iPod touch 4";
        
    }else if ([platform isEqualToString:@"iPod5,1"]) {
        
        platform = @"iPod touch 5";
        
    }else if ([platform isEqualToString:@"iPod3,1"]) {
        
        platform = @"iPod touch 3";
        
    }else if ([platform isEqualToString:@"iPod2,1"]) {
        
        platform = @"iPod touch 2";
        
    }else if ([platform isEqualToString:@"iPod1,1"]) {
        
        platform = @"iPod touch";
        
    } else if ([platform isEqualToString:@"iPad3,2"]||[platform isEqualToString:@"iPad3,1"]) {
        
        platform = @"iPad 3";
        
    } else if ([platform isEqualToString:@"iPad2,2"]||[platform isEqualToString:@"iPad2,1"]||[platform isEqualToString:@"iPad2,3"]||[platform isEqualToString:@"iPad2,4"]) {
        
        platform = @"iPad 2";
        
    }else if ([platform isEqualToString:@"iPad1,1"]) {
        
        platform = @"iPad 1";
        
    }else if ([platform isEqualToString:@"iPad2,5"]||[platform isEqualToString:@"iPad2,6"]||[platform isEqualToString:@"iPad2,7"]) {
        
        platform = @"ipad mini";
        
    } else if ([platform isEqualToString:@"iPad3,3"]||[platform isEqualToString:@"iPad3,4"]||[platform isEqualToString:@"iPad3,5"]||[platform isEqualToString:@"iPad3,6"]) {
        
        platform = @"ipad 3";
        
    }
    
    return platform;
}

+(NSString *)getDevInfo
{
    UIDevice* dev = [UIDevice currentDevice];
    
    NSString* model = [Util DevicePlatform];//[dev model];
    
    NSString* osVer = [dev systemVersion];
    
    //    NSMutableString *devID = [NSMutableString stringWithString:[dev uniqueIdentifier]];
    //    [devID replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [devID length])];
    
    NSString *strMac = [Util getDevID];
    NSString* devInfo = [NSString stringWithFormat:@"%@ iOS %@*%@",model,osVer,strMac];
    
    return devInfo;
}

+(NSString *)getDevID
{
    //    UIDevice* dev = [UIDevice currentDevice];
    //    NSMutableString *devID = [NSMutableString stringWithString:[dev uniqueIdentifier]];
    //    [devID replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [devID length])];
    //    return devID;
    
    NSString *mac = [OpenUDID value];
    if (mac == nil || [mac length] == 0) {
        mac = [OpenUDID value];
    }
    return mac;
}

#define MAXADDRS    10
#define BUFFERSIZE    4000
+(NSArray *)getLocalIPs
{
    int                 len, flags;
    char                buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifconf       ifc;
    struct ifreq        *ifr, ifrcopy;
    struct sockaddr_in    *sin;
    
    char temp[80];
    
    int sockfd;
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("socket failed");
        return nil;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0)
    {
        perror("ioctl error");
        return nil;
    }
    
    lastname[0] = 0;
    
    NSMutableArray* localIPS = [NSMutableArray array];
    
    for (ptr = buffer; ptr < buffer + ifc.ifc_len; )
    {
        ifr = (struct ifreq *)ptr;
        len = max(sizeof(struct sockaddr), ifr->ifr_addr.sa_len);
        ptr += sizeof(ifr->ifr_name) + len;    // for next one in buffer
        
        if (ifr->ifr_addr.sa_family != AF_INET)
        {
            continue;    // ignore if not desired address family
        }
        
        if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL)
        {
            *cptr = 0;        // replace colon will null
        }
        
        if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0)
        {
            continue;    /* already processed this interface */
        }
        
        memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
        
        ifrcopy = *ifr;
        ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
        flags = ifrcopy.ifr_flags;
        if ((flags & IFF_UP) == 0)
        {
            continue;    // ignore if interface not up
        }
        
        sin = (struct sockaddr_in *)&ifr->ifr_addr;
        strcpy(temp, inet_ntoa(sin->sin_addr));
        
        if(strcmp(temp,"127.0.0.1") != 0)
            //[ipStrings appendFormat:@"%@;",[NSString stringWithCString:temp encoding:NSUTF8StringEncoding]];
            [localIPS addObject:[NSString stringWithCString:temp encoding:NSUTF8StringEncoding]];
        
    }
    
    close(sockfd);
    
#ifdef QQVOICE_DEBUG
    if(localIPS && [localIPS count] > 0)
        NSLog(@"Local IPs:%@",[localIPS componentsJoinedByString:@";"]);
#endif
    return localIPS;
}

+(NSString *)getCurrentTime
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return [localeDate description];
}

+(NSString *)getClientInfo
{
    UIDevice* dev = [UIDevice currentDevice];
    
    NSString* model = [dev model];
    
    NSString* osVer = [dev systemVersion];
    
    BOOL isBroken = [Util isJailBreak];
    
    NSString* clientInfo = [NSString stringWithFormat:@"%@@%@ iOS %@@broken=%d",UCLIENT_INFO,model,osVer, isBroken];
    
    return clientInfo;
}

+ (BOOL)isJailBreak
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH]) {
        NSLog(@"The device is jail broken!");
        NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:USER_APP_PATH error:nil];
        NSLog(@"applist = %@", applist);
        return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}

+(NSString*)md5:(NSString*)string
{
    const char* str =[string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *md5Str = [NSMutableString string];
    for(int i =0; i<CC_MD5_DIGEST_LENGTH; i++)
    {
        [md5Str appendFormat:@"%02x",result[i]];
    }
    return md5Str;
}

+(NSString *)des:(NSString *)key plain:(NSString *)plainText
{
    NSData *keyData = [UCallerGTMBase64 decodeString:key];
    
    NSData *textData = [UCallerGTMBase64 decodeString:plainText];
    
    char buffer[1024];
    
    memset(buffer,0,sizeof(buffer));
    
    size_t numBytesEncrypted ;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          
                                          kCCAlgorithmDES,
                                          
                                          kCCOptionPKCS7Padding| kCCOptionECBMode,
                                          
                                          keyData.bytes,
                                          
                                          kCCKeySizeDES,
                                          
                                          NULL,
                                          
                                          textData.bytes,
                                          
                                          [textData length],
                                          
                                          buffer,
                                          
                                          1024,
                                          
                                          &numBytesEncrypted);
    
    
    NSData *desData = [UCallerGTMBase64 encodeBytes:buffer length:numBytesEncrypted];
    
    NSString *desString = [[NSString alloc] initWithData:desData encoding:NSUTF8StringEncoding];
    return desString;
}

+(NSString *)xmppDecode:(NSString *)encryText
{
    NSStringEncoding EnC = NSUTF8StringEncoding;
    
    NSData *ivData = [xmppServIv dataUsingEncoding:EnC];
    //const char *ivBytes = [xmppServIv UTF8String];
    
    NSData *preEncryData = [encryText dataUsingEncoding:EnC];
    NSData *encryData = [UCallerGTMBase64 decodeData:preEncryData];
    
    NSMutableData *keyData = [[xmppServKey dataUsingEncoding:EnC] mutableCopy];
    [keyData setLength:kCCKeySizeDES];
    
    uint8_t *buffer = NULL;
    size_t bufferSize = 0;
    
    bufferSize = ([encryText length] + kCCKeySizeDES) & ~(kCCKeySizeDES -1);
    buffer = malloc(bufferSize * sizeof(uint8_t));
    memset((void *)buffer, 0x00, bufferSize);
    
    size_t numBytesEncrypted ;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          
                                          kCCAlgorithmDES,
                                          
                                          ccNoPadding,
                                          
                                          keyData.bytes,
                                          
                                          keyData.length,
                                          
                                          ivData.bytes,
                                          
                                          encryData.bytes,
                                          
                                          encryData.length,
                                          
                                          buffer,
                                          
                                          bufferSize,
                                          
                                          &numBytesEncrypted);
    
    
    NSData *plainData = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    
    NSString *plainString = [[NSString alloc] initWithData:plainData encoding:EnC];
    
    //NSLog(@"xmppDecode==>%@",plainString);
    return plainString;
}

+(NSData *)fillDataWithZero:(NSString *)strData
{
    NSData *rawData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    int length = rawData.length;
    int remainder = length % 8;
    if(remainder == 0)
        return rawData;
    
    length += (8 - remainder);
    char *bytes = malloc(length);
    memset(bytes, 0, length);
    memcpy(bytes, rawData.bytes, rawData.length);
    
    NSData *returnData = [NSData dataWithBytes:bytes length:length];
    free(bytes);
    return returnData;
}

+(NSString *)xmppEncode:(NSString *)plainText
{
    NSStringEncoding EnC = NSUTF8StringEncoding;
    
    NSData *ivData = [xmppServIv dataUsingEncoding:EnC];
    
    NSData *plainData = [Util fillDataWithZero:plainText];//[plainText dataUsingEncoding:EnC];
    
    NSMutableData *keyData = [[xmppServKey dataUsingEncoding:EnC] mutableCopy];
    [keyData setLength:kCCKeySizeDES];
    
    uint8_t *buffer = NULL;
    size_t bufferSize = 0;
    
    bufferSize = ([plainText length] + kCCKeySizeDES) & ~(kCCKeySizeDES -1);
    buffer = malloc(bufferSize * sizeof(uint8_t));
    memset((void *)buffer, 0x00, bufferSize);
    
    size_t numBytesEncrypted ;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          
                                          kCCAlgorithmDES,
                                          
                                          ccNoPadding,
                                          
                                          keyData.bytes,
                                          
                                          keyData.length,
                                          
                                          ivData.bytes,
                                          
                                          plainData.bytes,
                                          
                                          plainData.length,
                                          
                                          buffer,
                                          
                                          bufferSize,
                                          
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCParamError) return @"PARAM ERROR";
    else if (cryptStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
    else if (cryptStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
    else if (cryptStatus == kCCAlignmentError) return @"ALIGNMENT";
    else if (cryptStatus == kCCDecodeError) return @"DECODE ERROR";
    else if (cryptStatus == kCCUnimplemented) return @"UNIMPLEMENTED";
    
    
    NSData *encryData = [UCallerGTMBase64 encodeBytes:buffer length:numBytesEncrypted];
    
    NSString *encryString = [[NSString alloc] initWithData:encryData encoding:EnC];
    
    //NSLog(@"xmppDesEecode==>%@",encryString);
    return encryString;
}

+(NSString *)getArea:(NSString *)number
{
    NSString *numberArea = number;
    numberArea = [[DBManager sharedInstance] getAreaByNumber:number];
    return numberArea;
}

+(NSString*)getSystemInfo
{
    UIDevice* dev = [UIDevice currentDevice];
    NSString* osVer = [dev systemVersion];
    NSString* onLineStyle = [Util getOnLineStyle];
    NSString *strSystemInfo = [NSString stringWithFormat:@"%@@%@@%@",onLineStyle,UCLIENT_INFO,osVer];
    return strSystemInfo;
}

+(NSString *)cachePhotoFolder
{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Photo"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+(NSString *)documentFolder
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

+(NSString *)bundleFolder
{
    return [[NSBundle mainBundle] bundlePath];
}

+(NSString*)getOnLineStyle{
    Reachability *r = [Reachability reachabilityWithHostName:PES_SERVER];
    NSString *strOnLineStyle = @"Wifi";
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            // 没有网络连接
            strOnLineStyle = @"";
            break;
        case ReachableViaWWAN:
            // 使用3G网络
            strOnLineStyle = @"3G";
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
            strOnLineStyle = @"Wifi";
            break;
    }
    return strOnLineStyle;
}

+(NSString *)getValidNumber:(NSString *)number
{
    if([Util isEmpty:number])
        return @"";
    NSString *validNumber = [number trim];
    if ([validNumber startWith:@"095013"]) {
        validNumber = [validNumber substringFromIndex:1];
    }
    else if ([number startWith:@"01"] && (number.length == 12)) {
        validNumber = [validNumber substringFromIndex:1];
    }
    else if ([number startWith:@"86"] && (number.length == 13)) {
        validNumber = [validNumber substringFromIndex:2];
    }
    else if ([number startWith:@"+86"] && (number.length == 14)) {
        validNumber = [validNumber substringFromIndex:3];
    }
    else if ([number startWith:@"0086"] && (number.length == 15)) {
        validNumber = [validNumber substringFromIndex:4];
    }
    else if ([number startWith:@"+0086"] && (number.length == 16)) {
        validNumber = [validNumber substringFromIndex:5];
    }
    return validNumber;
}
+(NSString *)getErrorMsg:(NSInteger)errCode
{
    NSString *errorMsg = nil;
    switch (errCode)
    {
        case 100101:
        case 100102:
        case 100103:
        case 100104:errorMsg = @"服务器错误";
            break;
        case 100201:
        case 100202:
        case 100203:errorMsg = @"请求失败，请稍后再试";
            break;
        case 100204:
        case 100205:
        {
            errorMsg = @"账号验证失效，\n为了您账号安全，请重新登陆。";
            [[UAppDelegate uApp] logout];
        }
            break;
        case 100301:errorMsg = @"该号码已存在";
            break;
        case 100302:errorMsg = @"号码为空";
            break;
        case 100303:errorMsg = @"无效号码";
            break;
        case 100304:errorMsg = @"用户不存在";
            break;
        case 100401:errorMsg = @"密码为空";
            break;
        case 100402:errorMsg = @"密码不正确";
            break;
        case 100403:errorMsg = @"密码格式错误";
            break;
        case 100501:errorMsg = @"验证码不能为空";
            break;
        case 100502:errorMsg = @"验证码不正确";
            break;
        case 100503:errorMsg = @"您获取的验证码次数超过\n最大次数,请明天再试。";
            break;
        case 100601:
        case 100602:errorMsg = @"短信发送失败";
            break;
        case 100701:errorMsg = @"余额不足";
            break;
        case 100702:errorMsg = @"充值金额为空";
            break;
        case 100703:errorMsg = @"套餐ID为空";
            break;
            ///后添加的。
        case 100720:errorMsg = @"无效订单";
            break;
        case 100721:errorMsg = @"订单状态不正常";
            break;
        case 100722:errorMsg = @"支付失败";
            break;
        case 100723:errorMsg = @"应币不足";
            break;
        case 100724:errorMsg = @"时长不足";
            break;
            /////////
        case 100801:errorMsg = @"您邀请好友过于频繁，请稍后再试";
            break;
        case 100802:errorMsg = @"呼朋唤友过于频繁？";
            break;
        case 100901:errorMsg = @"卡号格式错误";
            break;
        case 100902:errorMsg = @"卡已过期或无效";
            break;
        case 100903:errorMsg = @"卡已激活";
            break;
        
        case 333:errorMsg = @"数据库操作错误";
            break;
        case 444:errorMsg = @"memcache错误";
            break;
        case 555:errorMsg = @"并发错误";
            break;
        case 666:errorMsg = @"redis错误";
            break;
        case 777:errorMsg = @"鉴权错误";
            break;
        case 999:errorMsg = @"未知错误";
            break;
        case 1001:errorMsg = @"参数缺失或非法";
            break;
        case 1002:errorMsg = @"超过阀值";
            break;
        case 1003:errorMsg = @"只读";
            break;
        case 1004:errorMsg = @"禁止操作";
            break;
        case 1011:errorMsg = @"平台信息不存在";
            break;
        case 2000:errorMsg = @"呼应号已经被注册";
            break;
        case 2001:errorMsg = @"用户不存在或已被删除";
            break;
        case 2002:errorMsg = @"用户基本信息不存在或已被删除";
            break;
        case 2003:errorMsg = @"用户注册信息不存在或已被删除";
            break;
        case 2004:errorMsg = @"用户计数信息不存在";
            break;
        case 2005:errorMsg = @"用户密码错误";
            break;
        case 2006:errorMsg = @"用户设置不存在或已被删除";
            break;
        case 2007:errorMsg = @"用户无呼转号码";
            break;
        case 2008:errorMsg = @"用户未绑定其它平台账户";
            break;
        case 2009:errorMsg = @"用户监控记录不存在";
            break;
        case 2010:errorMsg = @"用户登录记录不存在";
            break;
        case 2011:errorMsg = @"用户未绑定某平台";
            break;
        case 2012:errorMsg = @"用户不在线";
            break;
        case 2013:errorMsg = @"非运营账号";
            break;
        case 2020:errorMsg = @"用户被封停";
            break;
        case 2030:errorMsg = @"合作方id错误";
            break;
        case 2100:errorMsg = @"手机账户不存在或已删除";
            break;
        case 2101:errorMsg = @"手机账户已被封停";
            break;
        case 2200:errorMsg = @"创建手机号账户失败";
            break;
        case 2201:errorMsg = @"创建用户失败";
            break;
        case 2300:errorMsg = @"运营用户权限信息不存在";
            break;
        default:
            errorMsg = @"操作失败，请稍后再试。";
            break;
    }
    
    return errorMsg;
}

+(void)checkCallNumber:(NSMutableString *)number
{
    if([number hasPrefix:@"86"] && (number.length == 13))
    {
        NSRange range = NSMakeRange(0,2);
        [number deleteCharactersInRange:range];
    }
    
    if([number hasPrefix:@"0"] == NO)
    {
        if([number hasPrefix:@"1"] && (number.length == 11))
        {
            [number insertString:@"0" atIndex:0];
        }
    }
}

+(BOOL)isPhoneNumber:(NSString *)number
{
    if([Util isEmpty:number])
        return NO;
    if([number startWith:@"1"] && (number.length >= 7))
        return YES;
    //    if([number startWith:@"01"] && (number.length == 12))
    //        return YES;
    return NO;
}

+(NSString *)getXMPPID:(NSString *)user
{
    if([Util isEmpty:user])
        return @"";
    NSString *xmppID = [Util substringFromStart:user sep:@"@"];
    return xmppID;
}

+(NSString *)getUNumber:(NSString *)user
{
    if([Util isEmpty:user])
        return @"";
    NSString *xmppID = [Util substringFromStart:user sep:@"@"];
    if([Util isEmpty:xmppID])
        return @"";
    NSString *uNumber = xmppID;
    //    if([uNumber startWith:TZ_PREFIX] == NO)
    //        uNumber = [NSString stringWithFormat:@"%@%@",TZ_PREFIX,uNumber];
    return uNumber;
}

+(BOOL)isPNumber:(NSString *)number
{
    if([Util isEmpty:number])
        return NO;
    if([number isEqualToString:UCALLER_NUMBER])
        return NO;
    if([number startWith:@"1"] && (number.length == 11))
        return YES;
    if([number startWith:@"01"] && (number.length == 12))
        return YES;
    return NO;
}

+(BOOL)isUNumber:(NSString *)number
{
    if([Util isEmpty:number])
        return NO;
    if([number startWith:TZ_PREFIX])
    {
        if (number.length <= 16) {
            return YES;
        }
    }
    return NO;
}

+(NSString *)getPNumber:(NSString *)number
{
    NSString *validNumber = [Util getValidNumber:number];
    if([Util isEmpty:validNumber])
        return @"";
    if([validNumber isEqualToString:UCALLER_NUMBER])
        return validNumber;
    if([Util isPNumber:validNumber])
        return validNumber;
    NSString *pNumber = validNumber;
    if ([pNumber startWith:TZ_PREFIX]) {
        pNumber = [pNumber substringFromIndex:TZ_PREFIX.length];
    }
    if([Util isPNumber:pNumber])
        return pNumber;
    return validNumber;
}

+(BOOL)matchNumber:(NSString *)number1 with:(NSString *)number2
{
    if([Util isEmpty:number1] || [Util isEmpty:number2])
        return NO;
    NSString *validNumber1 = [Util getValidNumber:number1];
    NSString *validNumber2 = [Util getValidNumber:number2];
    if([validNumber1 isEqualToString:validNumber2])
        return YES;
    return NO;
}

+(BOOL)matchPNumber:(NSString *)number1 with:(NSString *)number2
{
    if([Util isEmpty:number1] || [Util isEmpty:number2])
        return NO;
    NSString *validNumber1 = [Util getPNumber:number1];
    NSString *validNumber2 = [Util getPNumber:number2];
    if([validNumber1 isEqualToString:validNumber2])
        return YES;
    return NO;
}

+(NSString *)getAudioFileName:(NSString *)number suffix:(NSString *)suffix
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
    NSString *fileName;
    if([Util isEmpty:suffix])
       fileName = [NSString stringWithFormat:@"%@-%@",number,[formatter stringFromDate:[NSDate date]]];
    else
        fileName = [NSString stringWithFormat:@"%@-%@%@",number,[formatter stringFromDate:[NSDate date]],suffix];
    return fileName;
}

+(NSString*)saveAudio:(NSData *)audioData fileName:(NSString *)fileName
{
//    NSData *data = [Media2BytesUtil base64ToData:audioString];
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *savePath = [searchPaths objectAtIndex: 0];
    
    NSString *amrFilePath = [savePath stringByAppendingPathComponent:fileName];
    [audioData writeToFile:amrFilePath atomically:YES];
    
    NSString* wavFilePath = nil;
    if (![VoiceConverter amrToWav:amrFilePath storedPath:&wavFilePath]) {
        //TODO:
        NSLog(@"VoiceConverter error!");
    }
    
    if ([fileName hasSuffix:@"amr"]) {
        wavFilePath = [fileName stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"];
    }
    return wavFilePath;
}

+(void)removeAudioFile:(NSString *)fileName
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentPath_ = [searchPaths objectAtIndex: 0];
    
    NSString *filePath = [documentPath_ stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath])
    {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

+(NSString *)getShowTime:(NSDate*)date bTime:(BOOL)btime{
    
    
   //added by yfCui
    BOOL isCurYear = YES;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now;
    NSDateComponents *compNow = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    now=[NSDate date];
    compNow = [calendar components:unitFlags fromDate:now];
    
    NSDateComponents *compDate = [[NSDateComponents alloc] init];
    compDate = [calendar components:unitFlags fromDate:date];
    

    if(compDate.year != compNow.year)
    {
        isCurYear = NO;
    }
    //end

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //modified by yfCui in 2014-3-31
    if(isCurYear)
    {
        dateFormatter.dateFormat = @"YYYY年MM月dd日 HH:mm:ss";
    }
    else
    {
        dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    }
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSString *strDate = nil;
    NSString *strTime = nil;
    if(isCurYear)
    {
        strTime = [dateString substringWithRange:NSMakeRange(12,5)];
    }
    else
    {
        strTime = [dateString substringWithRange:NSMakeRange(11,5)];
    }
    NSDate *logDate = date;
    NSTimeInterval timeInterval = [logDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    temp = timeInterval/60;
    temp = temp/60;
    if (temp >= 48)
    {
        if(isCurYear == YES)
        {
            strDate = [dateString substringWithRange:NSMakeRange(5,6)];
            if([strDate startWith:@"0"])
            {
                strDate = [strDate substringFromIndex:1];
            }
            NSArray *dayArray = [strDate componentsSeparatedByString:@"月"];
            NSString *curDay = [dayArray objectAtIndex:1];
            if([curDay startWith:@"0"])
            {
                curDay = [curDay substringFromIndex:1];
            }
            strDate = [NSString stringWithFormat:@"%@月%@",[dayArray objectAtIndex:0],curDay];
        }
        else
        {
            strDate = [dateString substringWithRange:NSMakeRange(2,8)];
            NSArray *dateArray = [strDate componentsSeparatedByString:@"-"];
            NSString *month = [dateArray objectAtIndex:1];
            if([month startWith:@"0"])
            {
                month = [month substringFromIndex:1];
            }
            NSString *day = [dateArray objectAtIndex:2];
            if([day startWith:@"0"])
            {
                day = [day substringFromIndex:1];
            }
            strDate = [NSString stringWithFormat:@"%@-%@-%@",[dateArray objectAtIndex:0],month,day];
        }
    }
    else if (temp >= 24 && temp <48)
    {
        NSString *strDay = [dateString substringWithRange:NSMakeRange(8,2)];
        NSInteger nDay = [strDay intValue];
        NSString *nowDateString = [dateFormatter stringFromDate:[NSDate date]];
        NSString *strNowDay = [nowDateString substringWithRange:NSMakeRange(8, 2)];
        NSInteger nNowDay = [strNowDay intValue];
        if (nNowDay < nDay)
        {
            strDate = @"昨天";
        }
        else
        {
            if (nNowDay-nDay ==1)
            {
                strDate = @"昨天";
            }
            else
            {
                strDate = [dateString substringWithRange:NSMakeRange(5,6)];
            }
        }
    }
    else
    {
        NSString *strDay = [dateString substringWithRange:NSMakeRange(8,2)];
        NSString *nowDateString = [dateFormatter stringFromDate:[NSDate date]];
        NSString *strNowDay = [nowDateString substringWithRange:NSMakeRange(8, 2)];
        if ([strDay isEqualToString:strNowDay])
        {
            strDate = @"今天";
        }
        else
        {
            strDate = @"昨天";
        }
    }
    NSString *strShowTime = nil;
//    if(btime)
//    {
        if(isCurYear)
        {
            if([strDate isEqualToString:@"今天"])
            {
                strShowTime = [NSString stringWithFormat:@"%@",strTime];
            }
            else
            {
                strShowTime = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
            }
        }
        else
        {
            strShowTime = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
        }
        
//    }
//    else
//        strShowTime = [NSString stringWithFormat:@"%@",strDate];
    
    return strShowTime;
}
+(NSString *)getShowTime:(NSDate*)adate aTime:(BOOL)atime{
    
    //added by yfCui
    BOOL isCurYear = YES;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now;
    NSDateComponents *compNow = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    now=[NSDate date];
    
    compNow = [calendar components:unitFlags fromDate:now];
    
    NSDateComponents *compDate = [[NSDateComponents alloc] init];
    compDate = [calendar components:unitFlags fromDate:adate];
    
    
    if(compDate.year != compNow.year)
    {
        isCurYear = NO;
    }
    //end
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //modified by yfCui in 2014-3-31
    if(isCurYear)
    {
        dateFormatter.dateFormat = @"YYYY年MM月dd日 HH:mm:ss";
    }
    else
    {
        dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    }
    NSString *dateString = [dateFormatter stringFromDate:adate];
    
    NSString *strDate = nil;
    NSString *strTime = nil;
    if(isCurYear)
    {
        strTime = [dateString substringWithRange:NSMakeRange(12,5)];
    }
    else
    {
        strTime = [dateString substringWithRange:NSMakeRange(11,5)];
    }
    NSDate *logDate = adate;
    NSTimeInterval timeInterval = [logDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    temp = timeInterval/60;
    temp = temp/60;
    if (temp >= 48)
    {
        if(isCurYear == YES)
        {
            if (temp>=48&&temp<=24*7){
//                NSData *resultDate = [NSData dataWithBase64EncodedString:dateString];
               strDate = [self weekdayStringFromDate:adate];
            }else{
                strDate = [dateString substringWithRange:NSMakeRange(5,6)];
                if([strDate startWith:@"0"])
                {
                    strDate = [strDate substringFromIndex:1];
                }
                NSArray *dayArray = [strDate componentsSeparatedByString:@"月"];
                NSString *curDay = [dayArray objectAtIndex:1];
                if([curDay startWith:@"0"])
                {
                    curDay = [curDay substringFromIndex:1];
                }
                strDate = [NSString stringWithFormat:@"%@月%@",[dayArray objectAtIndex:0],curDay];
            }
           
        }
        else
        {
            strDate = [dateString substringWithRange:NSMakeRange(0,10)];
            NSArray *dateArray = [strDate componentsSeparatedByString:@"-"];
            NSString *month = [dateArray objectAtIndex:1];
            if([month startWith:@"0"])
            {
                month = [month substringFromIndex:1];
            }
            NSString *day = [dateArray objectAtIndex:2];
            if([day startWith:@"0"])
            {
                day = [day substringFromIndex:1];
            }
            strDate = [NSString stringWithFormat:@"%@-%@-%@",[dateArray objectAtIndex:0],month,day];
            
            NSString *year = [dateString substringWithRange:NSMakeRange(0,4)];
            NSString *nowYear = [NSString stringWithFormat:@"%d",compNow.year];
            
            if ([nowYear integerValue] - [year integerValue] == 1) {
                strDate = [NSString stringWithFormat:@"去年%@-%@",month,day];
            }
           
        }
    }
    else if (temp >= 24 && temp <48)
    {
        NSString *strDay = [dateString substringWithRange:NSMakeRange(8,2)];
        NSInteger nDay = [strDay intValue];
        NSString *nowDateString = [dateFormatter stringFromDate:[NSDate date]];
        NSString *strNowDay = [nowDateString substringWithRange:NSMakeRange(8, 2)];
        NSInteger nNowDay = [strNowDay intValue];
        if (nNowDay < nDay)
        {
            strDate = @"昨天";
        }
        else
        {
            if (nNowDay-nDay ==1)
            {
                strDate = @"昨天";
            }
            else
            {
                strDate = [dateString substringWithRange:NSMakeRange(5,6)];
            }
        }
    }
    else
    {
        NSString *strDay = [dateString substringWithRange:NSMakeRange(8,2)];
        NSString *nowDateString = [dateFormatter stringFromDate:[NSDate date]];
        NSString *strNowDay = [nowDateString substringWithRange:NSMakeRange(8, 2)];
        if ([strDay isEqualToString:strNowDay])
        {
            strDate = @"今天";
        }
        else
        {
            strDate = @"昨天";
        }
    }
    NSString *strShowTime = nil;
    //    if(btime)
    //    {
    if(isCurYear)
    {
        if([strDate isEqualToString:@"今天"])
        {
            strShowTime = [NSString stringWithFormat:@"今天 %@",strTime];
        }
        else
        {
            strShowTime = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
        }
    }
    else
    {
        strShowTime = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
    }
    
    //    }
    //    else
    //        strShowTime = [NSString stringWithFormat:@"%@",strDate];
    
    return strShowTime;
}
+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSWeekdayCalendarUnit;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
}
+(NSString *)getShowTime:(double)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    return [Util getShowTime:date aTime:YES];
}

+(BOOL)systemBeforeSeven
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
        return YES;
    else
        return NO;
}

+(BOOL)systemBeforeFive
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 5.0)
        return YES;
    else
        return NO;
}

+(NSString *)getCurrentSystem
{
    NSString *currentDevice;
    currentDevice = [UIDevice currentDevice].systemVersion;
    return currentDevice;
}

+(NSString *)getCurrentDeviceInfo
{
    NSString *currentStr;
    currentStr = [Util DevicePlatform];
    return currentStr;
}

+(NSString *)getAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}

+(BOOL)isNum:(NSString *)phone
{
    phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(phone.length <= 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+(NSString *)getGender:(NSString *)gender
{
    NSString *genderType;
    if([Util isEmpty:gender])
        return @"";
    if ([gender isEqualToString:MALE] ||[gender isEqualToString:@"2"]) {
        genderType = @"男";
    }else if ([gender isEqualToString:FEMALE] || [gender isEqualToString:@"1"])
    {
        genderType = @"女";
    }
    else{
        genderType = @"";
    }
    return genderType;
}

+(NSString *)getAge:(NSString *)birthday
{
    //    NSLog(@"%@",birthday);
    if([Util isEmpty:birthday] || [birthday isEqualToString:@"0"])
        return @"";
    NSDate *today = [NSDate date];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
     NSString *currentDateStr = [dateFormat stringFromDate:today];
    
    NSDate *birthdayDate = [NSDate dateWithTimeIntervalSince1970:birthday.doubleValue/1000];
    NSString *birthdayStr = [dateFormat stringFromDate:birthdayDate];
   
    //    NSLog(@"%@",birthdayStr);
    //    NSLog(@"%@",currentDateStr);
    NSArray *currentArray = [currentDateStr componentsSeparatedByString:@"-"];
    NSArray *birthArray = [birthdayStr componentsSeparatedByString:@"-"];
    
    NSInteger curYear = [[currentArray objectAtIndex:0] integerValue];
    NSInteger birthYear = [[birthArray objectAtIndex:0] integerValue];
    //    NSLog(@"%ld,%ld",curYear,birthYear);
    if(birthYear == 0)
        return @"";
    if(birthYear > curYear)
    {
        return @"0岁";
    }
    NSInteger ageCount = curYear - birthYear;
    //    NSLog(@"%ld",ageCount);
    NSInteger curMonth = [[currentArray objectAtIndex:1] integerValue];
    NSInteger birthMonth = [[birthArray objectAtIndex:1] integerValue];
    //    NSLog(@"%ld,%ld",curMonth,birthMonth);
    if(!(birthMonth>0 && birthMonth <=12))
    {
        return @"";
    }
    if(curMonth < birthMonth)
    {
        ageCount++;
    }
    else if(curMonth == birthMonth)
    {
        NSInteger curday = [[currentArray objectAtIndex:2] integerValue];
        NSInteger birthDay = [[birthArray objectAtIndex:2] integerValue];
        if(curday >= birthDay)
        {
            ageCount++;
        }
    }
    
    if(ageCount <= 0)
        return @"0岁";
    //    NSLog(@"%d",ageCount);
    return [NSString stringWithFormat:@"%d岁",ageCount];
}

// 计算生日
//+(NSString *)getAge:(NSString *)birthday
//{
////    NSLog(@"%@",birthday);
//    if([Util isEmpty:birthday] || [birthday isEqualToString:@"0"])
//        return @"";
//    NSDate *today = [NSDate date];
//    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-mm-dd"];
//    NSString *currentDateStr = [dateFormat stringFromDate:today];
//    
////    int a = birthday.doubleValue;
////    
////    NSDate *birthdayDate = [NSDate dateWithTimeIntervalSince1970:birthday.doubleValue/1000];
////    
////    NSLog(@"++++%@++++",birthdayDate);
////    
////    NSString *birthdayStr = [dateFormat stringFromDate:birthdayDate];
//
//    NSArray *currentArray = [currentDateStr componentsSeparatedByString:@"-"];
//    NSArray *birthArray = [birthday componentsSeparatedByString:@"-"];
//    
//    NSInteger curYear = [[currentArray objectAtIndex:0] integerValue];
//    NSInteger birthYear = [[birthArray objectAtIndex:0] integerValue];
////    NSLog(@"%ld,%ld",curYear,birthYear);
//    if(birthYear == 0)
//        return @"";
//    if(birthYear > curYear)
//    {
//        return @"";
//    }
//    NSInteger ageCount = curYear - birthYear;
////    NSLog(@"%ld",ageCount);
//    NSInteger curMonth = [[currentArray objectAtIndex:1] integerValue];
//    NSInteger birthMonth = [[birthArray objectAtIndex:1] integerValue];
////    NSLog(@"%ld,%ld",curMonth,birthMonth);
//    if(!(birthMonth>0 && birthMonth <=12))
//    {
//        return @"";
//    }
//    if(curMonth < birthMonth)
//    {
//        ageCount++;
//    }
//    else if(curMonth == birthMonth)
//    {
//        NSInteger curday = [[currentArray objectAtIndex:2] integerValue];
//        NSInteger birthDay = [[birthArray objectAtIndex:2] integerValue];
//        if(curday >= birthDay)
//        {
//            ageCount++;
//        }
//    }
//
//    if(ageCount <= 0)
//        return @"";
////    NSLog(@"%d",ageCount);
//    return [NSString stringWithFormat:@"%d岁",ageCount];
//}



//星座
+(NSString *)constellationFunction:(NSString *)dateStr//(yyyy-MM-dd格式)
{
//    if ([dateStr isEqualToString:@""]) {
//        return nil;
//    }
    NSArray *timeArr = [dateStr componentsSeparatedByString:@"-"];
    NSString *year = timeArr[0];
    NSString *month = timeArr[1];
    NSString *day = timeArr[2];
    
    NSString *constallationStr = [self getAstroWithYear:year.integerValue Month:month.integerValue day:day.integerValue];
    NSLog(@"%@",constallationStr);
    return constallationStr;

}
//计算星座
+(NSString *)getAstroWithYear:(NSInteger)y Month:(NSInteger)m day:(NSInteger)d
{
    NSString *astroString = @"魔羯座水瓶座双鱼座白羊座金牛座双子座巨蟹座狮子座处女座天秤座天蝎座射手座魔羯座";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    if (m<1||m>12||d<1||d>31){
        return @"错误日期格式!";
    }
    if(m==2)
    {
        BOOL isLeapYear = [self checkLeapYear:y];
        if (isLeapYear && d>29) {
            return @"错误日期格式!";
        }else{
            if (d>28) {
                return @"错误日期格式!";
            }
        }
        
    }else if(m==4 || m==6 || m==9 || m==11) {
        if (d>30) {
            return @"错误日期格式!";
        }
    }
    result=[NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(m*3-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*3,3)]];
    return result;
}
//判断是否为闰年
+(BOOL)checkLeapYear:(NSInteger)year
{
    if ( (year%4 == 0 && year%100 != 0) || year%400 == 0 )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+(NSInteger)stringTransfromInterger:(NSDictionary *)aDic//学历，收入，感情状况转换
{
    NSInteger rInt;
    NSArray *feelArr = [NSArray arrayWithObjects:@"保密",@"单身",@"求勾搭",@"热恋中",@"已婚",@"同性", nil];
    NSArray *diplomaArr = [NSArray arrayWithObjects:@"保密",@"中学",@"高中",@"专科",@"本科",@"硕士",@"博士", nil];
    NSArray *incomeArr = [NSArray arrayWithObjects:@"保密",@"2千以下",@"2-6千元",@"6千-1万元",@"1-2万元",@"2-5万元",@"5万元以上", nil];
    NSString *feeling = [aDic objectForKey:@"feeling_status"];
    NSString *diploma = [aDic objectForKey:@"diploma"];
    NSString *income = [aDic objectForKey:@"month_income"];
    if (![Util isEmpty:feeling]) {
        
        for (NSInteger i=0; i<feelArr.count; i++) {
            NSString *str = [feelArr objectAtIndex:i];
            if ([str isEqualToString:feeling]) {
                rInt = i;
                break;
            }
            else
            {
                rInt = 0;//暂时先处理成0
            }
        }
    }
    else if (![Util isEmpty:diploma])
    {
        for (NSInteger i=0; i<diplomaArr.count; i++) {
            NSString *str = [diplomaArr objectAtIndex:i];
            if ([str isEqualToString:diploma]) {
                rInt = i;
                break;
            }
            else
            {
                rInt = 0;//暂时先处理成0
            }
        }
    }
    else if (![Util isEmpty:income])
    {
        for (NSInteger i=0; i<incomeArr.count; i++) {
            NSString *str = [incomeArr objectAtIndex:i];
            if ([str isEqualToString:income]) {
                rInt = i;
                break;
            }
            else
            {
                rInt = 0;//暂时先处理成0
            }
        }
    }
    else
    {
        rInt = 0;
    }
    
    return rInt;
}
+(NSString *)intergerTransfromString:(NSDictionary *)aDic
{
    NSString *rString;
    NSArray *feelArr = [NSArray arrayWithObjects:@"保密",@"单身",@"求勾搭",@"热恋中",@"已婚",@"同性", nil];
    NSArray *diplomaArr = [NSArray arrayWithObjects:@"保密",@"中学",@"高中",@"专科",@"本科",@"硕士",@"博士", nil];
    NSArray *incomeArr = [NSArray arrayWithObjects:@"保密",@"2千以下",@"2-6千元",@"6千-1万元",@"1-2万元",@"2-5万元",@"5万元以上", nil];
    
    NSString *feelingInt = [aDic objectForKey:@"feeling_status"];
    NSString *diplomaInt = [aDic objectForKey:@"diploma"];
    NSString *incomeInt = [aDic objectForKey:@"month_income"];
    if (![Util isEmpty:feelingInt]) {
        NSInteger num = feelingInt.integerValue;
        if (  num < feelArr.count && num >= 0 )
        {
            rString = [feelArr objectAtIndex:num];
        }
    }
    else if (![Util isEmpty:diplomaInt])
    {
        NSInteger num = diplomaInt.integerValue;
        if (  num < diplomaArr.count && num >= 0 )
        {
            rString = [diplomaArr objectAtIndex:num];
        }
    }
    else if (![Util isEmpty:incomeInt])
    {
        NSInteger num = incomeInt.integerValue;
        if (  num < incomeArr.count && num >= 0 )
        {
            rString = [incomeArr objectAtIndex:num];
        }
    }
    else
    {
        rString = nil;
    }
    
    return rString;
}

+(CGSize ) countTextSize:(NSString *)contentStr MaxWidth:(CGFloat )maxWidth MaxHeight:(CGFloat )maxHeight UFont:(UIFont *)uFont LineBreakMode:(NSLineBreakMode )lineBreakMode Other:(id)other
{
    CGSize rSize;
    CGSize constraint = CGSizeMake(maxWidth, maxHeight);
    rSize= [contentStr sizeWithFont:uFont constrainedToSize:constraint lineBreakMode:lineBreakMode];
    
    return rSize;
}


+(NSDictionary *)getMoodDict
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"faceMap_ch" ofType:@"plist"]];
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    NSMutableArray *valueArray = [[NSMutableArray alloc] init];
    for(NSString *key in dict)
    {
        [valueArray addObject:[NSString stringWithFormat:@"%@.png",key]];
        [keyArray addObject:[dict objectForKey:key]];
    }
    NSDictionary *imgDict = [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
    return imgDict;
}

+(void)sendInvite:(NSArray *)numbers from:(UIViewController *)vc andContent:(NSString *)smsContent
{
    BOOL canSendSMS = [MFMessageComposeViewController canSendText];
    if(canSendSMS)
    {
        MFMessageComposeViewController *sendMsgView = [[MFMessageComposeViewController alloc] init];
        sendMsgView.messageComposeDelegate = (id<MFMessageComposeViewControllerDelegate>)vc;
        sendMsgView.navigationBar.tintColor = [UIColor blackColor];
        sendMsgView.body = smsContent;
        sendMsgView.recipients = numbers;
        [vc presentViewController:sendMsgView animated:YES completion:nil];
    }
    else
    {
        [XAlert showAlert:nil message:@"您的设备不支持发短信功能" buttonText:@"确定"];
    }
}

+(BOOL)addXMPPContact:(NSString *)strNumber andMessage:(NSString *)message
{
    NSString *number = strNumber;
    NSString *errMsg = @"请输入有效的呼应号码!";
    
    if([Util ConnectionState])
    {
        if(![Util isNum:number])
        {
            [XAlert showAlert:nil message:errMsg buttonText:@"确定"];
            return NO;
        }
        
        number = [Util getValidNumber:number];
        if([Util isUNumber:number] == NO)
        {
            [XAlert showAlert:@"提示" message:errMsg buttonText:@"确定"];
            return NO;
        }
        else if([[ContactManager sharedInstance] getUCallerContact:number] != nil)
        {
            
            if (iOS9) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"该用户已经是您的好友，不能重复添加！" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                [[UAppDelegate uApp].rootViewController.navigationController presentViewController:alertController animated:YES completion:nil];
                
            }else{
                [XAlert showAlert:@"提示" message:@"该用户已经是您的好友，不能重复添加！" buttonText:@"确定"];
            }
            return NO;
        }
        else if([[UConfig getUNumber] isEqualToString:number])
        {
            [XAlert showAlert:@"提示" message:@"抱歉，不能添加自己为好友！" buttonText:@"确定"];
            return NO;
        }
        
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setValue:number forKey:KUNumber];
        [info setValue:message forKey:KRemark];
        [[UCore sharedInstance] newTask:U_ADD_CONTACT data:info];
        
        [[[iToast makeText:@"添加请求已发送"] setGravity:iToastGravityCenter] show];
        
        return YES;
    }
    else
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle: nil message:@"网络不可用,添加请求发送失败!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    return NO;
}


+(void)pushView:(UIViewController *)fromView
{
    fromView.view.hidden = YES;
	// set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[fromView.view.superview layer] addAnimation:animation forKey:@"Push"];
}

//+(BOOL)checkShareTimeInterval
//{
//    if([UConfig getRequestShareTime])
//    {
//        NSDate *today = [NSDate date];
//        NSDate *shareDate = [UConfig getRequestShareTime];
//        NSTimeInterval time=[today timeIntervalSinceDate:shareDate];
//        if(time > (24*60*60))
//        {
//            [UConfig setRequestShareTime:nil];
//            return YES;
//        }
//        else
//        {
//            return NO;
//        }
//    }
//    return YES;
//}

//+(BOOL)checkShareInfo
//{
//    if(![UConfig getRequestShareInfoState])
//    {
//        NSDate *now = [NSDate date];
//        NSCalendar *cal = [NSCalendar currentCalendar];
//        NSDateComponents *comps = [cal
//                                   components:NSYearCalendarUnit | NSMonthCalendarUnit
//                                   fromDate:now];
//        comps.day = 1;
//        NSDate *firstDay = [cal dateFromComponents:comps];
//        NSComparisonResult result = [now compare:firstDay];
//        if(result == NSOrderedSame || result == NSOrderedDescending)
//        {
//            return YES;
//        }
//        return NO;
//    }
//    else
//    {
//        return NO;
//    }
//}

+ (BOOL)validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,20}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}
+(BOOL)isNumber:(NSString *)number
{
    //判断字符串是否为数字组成的串
    NSString *string = [number stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(string.length > 0)
    {
        //不是数字
        return NO;
    }
    else
    {
        //都是数字
        return YES;
    }
}

+(BOOL)checkNotice
{
    if([UConfig getNoticeTime])
    {
        NSDate *today = [NSDate date];
        NSDate *shareDate = [UConfig getNoticeTime];
        NSTimeInterval time=[today timeIntervalSinceDate:shareDate];
        if(time > (24*60*60))
        {
            [UConfig setNoticeTime:nil];
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

+(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

+(NSString*)makeUUID
{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    CFStringRef resultRef = CFStringCreateCopy( NULL, uuidString);
    NSString * result = (__bridge_transfer NSString *)resultRef;
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

+(UIButton *)getNaviBackBtn:(UIViewController *)aTarget
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    [btn setFrame:NAVI_BACK_FRAME];
    [btn setImage:[UIImage imageNamed:@"moreBack_nor"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"moreBack_sel"] forState:UIControlStateHighlighted];
    [btn addTarget:aTarget action:@selector(returnLastPage) forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

@end