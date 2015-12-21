//
//  Util.m
//  VoIPSDK
//
//  Created by thehuah on 11-11-10.
//  Copyright 2011年 X. All rights reserved.
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

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIDevice.h>

#import "VoIPUtil.h"
#import "HYVoIPSDK_GTMBase64.h"
//#import "Reachability.h"
#import "OpenUDID.h"

#import "TZHttpRequest.h"


#define    min(a,b)    ((a) < (b) ? (a) : (b))
#define    max(a,b)    ((a) > (b) ? (a) : (b))

@implementation VoIPUtil

+(NSString *)des:(NSString *)key plain:(NSString *)plainText
{    
    NSData *keyData = [HYVoIPSDK_GTMBase64 decodeString:key];
    
    NSData *textData = [HYVoIPSDK_GTMBase64 decodeString:plainText];
    
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
    
    
    NSData *desData = [HYVoIPSDK_GTMBase64 encodeBytes:buffer length:numBytesEncrypted];
    
    NSString *desString = [[NSString alloc] initWithData:desData encoding:NSUTF8StringEncoding];
    
    return desString;
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
#ifdef QQVOICE_DEBUG
    //NSLog(@"md5(%@)=%@",string,md5Str);
#endif
    return md5Str;
}

+(NSString*)makeUUID
{
    CFUUIDRef uuidObj = CFUUIDCreate(kCFAllocatorDefault);
    
    CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidObj);
    
    NSMutableString* uuidString = [NSMutableString stringWithString:(__bridge NSString*)strRef];
    
    CFRelease(strRef);
    
    CFRelease(uuidObj);
    
    [uuidString replaceOccurrencesOfString:@"-" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [uuidString length])];
    
    NSString *uuid = [[NSString alloc] initWithString:[uuidString lowercaseString]];
    
    return uuid;
}

+(NSString *)trimString:(NSString *)string
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [string stringByTrimmingCharactersInSet:whitespace];
    
}

+(NSString *)getClientInfo
{
    UIDevice* dev = [UIDevice currentDevice];
    
    NSString* model = [dev model]; 
    
    NSString* osVer = [dev systemVersion];
    
    NSString* clientInfo = [NSString stringWithFormat:@"%@@%@ iOS %@",UCLIENT_INFO,model,osVer];
    
    return clientInfo;
}

+(NSString *)getDevID
{
    NSString *mac = [OpenUDID value];
    if (mac == nil || [mac length] == 0) {
        mac = [OpenUDID value];
    }
    return mac;
}

+(NSString *)getDevInfo
{
    UIDevice* dev = [UIDevice currentDevice];
    
    NSString* model = [dev model]; 
    
    NSString* osVer = [dev systemVersion];
        
    NSString *strMac = [VoIPUtil getDevID];
    NSString* devInfo = [NSString stringWithFormat:@"%@ iOS %@*%@",model,osVer,strMac];
    
    return devInfo;
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
    
    if([VoIPUtil canConnectTo:strName] == NO)
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

+(NSString *)getLocalHost
{
    char baseHostName[256];
    int success = gethostname(baseHostName, 255);
    if (success != 0) return nil;
    baseHostName[255] = '\0';
    
#if TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"%s", baseHostName];
#else
    return [NSString stringWithFormat:@"%s.local", baseHostName];
#endif
}

+(NSString *)getLocalIP
{
    struct hostent *host = gethostbyname([[VoIPUtil getLocalHost] UTF8String]);
    if (!host) {herror("resolv"); return nil;}
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
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

+(BOOL)isEmpty:(NSString *)str
{
    if((str == nil) || (str.length == 0))
        return YES;
    else
        return NO;
}

+(NSString *)substringFromStart:(NSString *)str sep:(NSString *)sep
{
    if([VoIPUtil isEmpty:str])
        return @"";
    NSRange range = [str rangeOfString:sep];
    int index = range.location;
    NSString *subStr = (range.length > 0) ? [str substringToIndex:index]:str;
    return subStr;
}

+(NSString *)correctPhone:(NSString *)phone
{
    NSString *strError = nil;
    if (phone == nil) {
        strError = @"手机号码不能为空!";
    }
    else
    {
        if(([phone length] == 11) && [[phone substringWithRange:NSMakeRange(0,1)] isEqualToString:@"1"])
        {
            strError = nil;
        }
        else
        {
            strError = @"请输入11位手机号码!";
        }
    }
    return strError;
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

+ (NSString *)getShowTime:(NSDate*)date bTime:(BOOL)btime{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSString *strDate = nil;
    NSString *strTime = [dateString substringWithRange:NSMakeRange(11,5)];
    NSDate *logDate = date;
    NSTimeInterval timeInterval = [logDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    temp = timeInterval/60;
    temp = temp/60;
    if (temp >= 48) {
        strDate = [dateString substringWithRange:NSMakeRange(0,10)];
    }else if (temp >= 24 && temp <48)
    {
        NSString *strDay = [dateString substringWithRange:NSMakeRange(8,2)];
        NSInteger nDay = [strDay intValue];
        NSString *nowDateString = [dateFormatter stringFromDate:[NSDate date]];
        NSString *strNowDay = [nowDateString substringWithRange:NSMakeRange(8, 2)];
        NSInteger nNowDay = [strNowDay intValue];
        if (nNowDay < nDay) {
            strDate = @"昨天";
        }else{
            if (nNowDay-nDay ==1) {
                strDate = @"昨天";
            }else{
                strDate = [dateString substringWithRange:NSMakeRange(0,10)];
            }
        }
    }
    else{
        NSString *strDay = [dateString substringWithRange:NSMakeRange(8,2)];
        NSString *nowDateString = [dateFormatter stringFromDate:[NSDate date]];
        NSString *strNowDay = [nowDateString substringWithRange:NSMakeRange(8, 2)];
        if ([strDay isEqualToString:strNowDay]) {
            strDate = @"今天";
        }else{
            strDate = @"昨天";
        }
    }
    NSString *strShowTime = nil;
    if(btime)
        strShowTime = [NSString stringWithFormat:@"%@ %@",strDate,strTime];
    else
        strShowTime = [NSString stringWithFormat:@"%@",strDate];
    return strShowTime;
}

+(NSString *)documentFolder
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

+(NSString *)bundleFolder
{
    return [[NSBundle mainBundle] bundlePath];
}

+(NSString *)getCurrentTime{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return [localeDate description];
}

+(NSString *)getCurrentTime2
{
    NSDate *nowUTC = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    return [dateFormatter stringFromDate:nowUTC];
    
}

+(NSString *)stringFromDate:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

+(NSString *)stringFromExpireDate:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

+(NSDate *)dateFromString:(NSString*)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    // [dateFormatter setTimeZone:GTMzone];
    [dateFormatter setAMSymbol:@"上午"];
    [dateFormatter setPMSymbol:@"下午"];
    [dateFormatter setDateFormat: @"yyyy-MM-dd ahh:mm:ss"];
    
    NSDate *destDate = [dateFormatter dateFromString:string];
    
    return destDate;
}

+(NSDate *)dateFromString2:(NSString*)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    // [dateFormatter setTimeZone:GTMzone];
    [dateFormatter setAMSymbol:@"上午"];
    [dateFormatter setPMSymbol:@"下午"];
    [dateFormatter setDateFormat: @"yyyy-MM-dd ahh:mm:ss"];
    
    NSDate *destDate = [dateFormatter dateFromString:string];
    
    return destDate;
    
}

+(NSDateComponents*) date2DateComponent: (NSDate*)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *comps  = [calendar components:unitFlags fromDate: date];
    
    return comps;
}


+(BOOL)canConnectTo:(NSString *)host
{
    return [TZHttpRequest canConnectTo:host];
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

@end
