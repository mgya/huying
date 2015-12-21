
#import "HYHTTPInterface.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "VoIPUtil.h"
#import "HTTPResultParser.h"
#import "TZHttpRequestDelegate.h"
#import "TZHttpRequest.h"

#define WEB_SERVER_URL @"http://pes.yxhuying.com:9999/httpservice?"
#define POST_URL @"http://pes.yxhuying.com:9999/httpservice"
#define TOKEN_URL @"http://redirect.yxhuying.com:780/getlogintoken1"

#define CONTENT_TYPE @"application/x-www-form-urlencoded; charset=utf-8"

#define SIGN_KEY @"96E79218965EB72C92A549DD5A330112"
#define DES_KEY @"2452ed5ef00a5a1e3d22b0267d8b84ca"

@implementation HYUserInfoResult

@synthesize strNumber;
@synthesize strPhone;
@synthesize strUID;
@synthesize resultCode;
@synthesize isNew;

@end

@implementation HYPackageInfo

@synthesize strName;
@synthesize strTime;
@synthesize strExpireDate;

@end

@implementation HYPackageInfoResult

@synthesize resultCode;
@synthesize strFreeMinute;
@synthesize strPayMinute;
@synthesize freeArray;
@synthesize payArray;

-(id)init
{
    self = [super init];
    if(self)
    {
        freeArray = [[NSMutableArray alloc] init];
        payArray = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

@implementation HYHTTPInterface

+(NSString*)urlEncode:(NSString *)string
{
    return (__bridge NSString *)
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef) string,
                                            NULL,
                                            (CFStringRef) @"!*'();:@&=+$,/?%#[]{}<>",
                                            kCFStringEncodingUTF8);
}

+(NSString*)urlDecode:(NSString *)string
{
    return (__bridge NSString *)
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                            (CFStringRef) string,
                                                            CFSTR(""),
                                                            kCFStringEncodingUTF8);
}

+(NSString *)des:(NSString *)plainText
{
    return [VoIPUtil des:DES_KEY plain:plainText];
}

+(NSString *)makeSign:(NSArray *)array
{
    unsigned char signCStr[CC_MD5_DIGEST_LENGTH] = {0};
    
    for(NSString *str in array)
    {
        const char *cStr = [str UTF8String];
        unsigned char md5Str[CC_MD5_DIGEST_LENGTH];
        CC_MD5(cStr, strlen(cStr), md5Str);
        
        for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
        {
            signCStr[i] = (unsigned char)((int)signCStr[i] ^ (int)md5Str[i]);
        }
    }
    
    NSMutableString *signMD5Str = [NSMutableString string];
    for(int i =0; i<CC_MD5_DIGEST_LENGTH; i++)
    {
        [signMD5Str appendFormat:@"%02x",signCStr[i]];
    }
    return signMD5Str;
}

//拼接url
+(NSString*)makeRequestURL:(NSString*)strUrl : (NSArray*)params : (NSString*)strPwd{
    
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:strUrl];
    NSMutableArray *paramArray = [[NSMutableArray alloc] init];
    for(NSDictionary *param in params)
    {
        NSString *name = [param objectForKey:@"Name"];
        NSString *value = [param objectForKey:@"Value"];
        [paramArray addObject:[NSString stringWithFormat:@"%@%@%@",name,strPwd,value]];
        NSString *ueValue = [HYHTTPInterface urlEncode:value];
        [urlString appendFormat:@"%@=%@&",name,ueValue];
    }
    NSString *signString = [HYHTTPInterface makeSign:paramArray];
    NSString *ueValue = [HYHTTPInterface urlEncode:signString];
    [urlString appendFormat:@"%@=%@",@"sign",ueValue];
    return urlString;
}

+(NSString *)getToken
{
    NSURL *url = [NSURL URLWithString:TOKEN_URL];
    
    TZHttpRequest *request = [TZHttpRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        NSString *token = [response substringToIndex:32];
        return token;
    }
    else
        return nil;
}

+(NSInteger)getCode:(int)type phone:(NSString*)strPhone
{
    NSInteger resultCode = -1;
    if (strPhone == nil) {
        return resultCode;
    }
    
    NSString *strType = [NSString stringWithFormat:@"%d",type];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"sdkgetcode",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",strType,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"phone",@"Name",strPhone,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appid",@"Name",@"5",@"Value",nil]];

    NSString *strUrlString = [HYHTTPInterface makeRequestURL:WEB_SERVER_URL :params :SIGN_KEY];
    TZHttpRequest *request = [TZHttpRequest requestWithURL:[NSURL URLWithString:strUrlString]];
    [request startSynchronous];
    NSError *error = [request error];
    if(error != nil)
    {
        resultCode = error.code;
    }
    else
    {
        resultCode = [HTTPResultParser parseResponse:request.responseString];
    }
    return resultCode;
}

+(NSInteger)getRegisterCode:(NSString*)strPhone
{
    return [HYHTTPInterface getCode:3 phone:strPhone];
}

+(NSInteger)getOtherCode:(NSString*)strPhone
{
    return [HYHTTPInterface getCode:2 phone:strPhone];
}

+(NSInteger)checkRegisterCode:(NSString*)strPhone code:(NSString*)strCode
{
    NSInteger resultCode = [HYHTTPInterface checkCode:3 phone:strPhone code:strCode];
    return resultCode;
}

+(NSInteger)checkOtherCode:(NSString*)strPhone code:(NSString*)strCode
{
    return [HYHTTPInterface checkCode:2 phone:strPhone code:strCode];
}

+(NSInteger)checkCode:(int)type phone:(NSString*)strPhone code:(NSString*)strCode
{
    NSInteger resultCode = -1;
    if (strPhone == nil || strCode == nil) {
        return resultCode;
    }
    
    NSString *strType = [NSString stringWithFormat:@"%d",type];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"sdkcheckcode",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",strType,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"phone",@"Name",strPhone,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"code",@"Name",strCode,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appid",@"Name",@"5",@"Value",nil]];
    
    NSString *strUrlString = [HYHTTPInterface makeRequestURL:WEB_SERVER_URL :params :SIGN_KEY];
    TZHttpRequest *request = [TZHttpRequest requestWithURL:[NSURL URLWithString:strUrlString]];
    [request startSynchronous];
    NSError *error = [request error];
    if(error != nil)
    {
        resultCode = error.code;
    }
    else
    {
        resultCode = [HTTPResultParser parseResponse:request.responseString];
    }
    return resultCode;
    
}

+(HYUserInfoResult *)registerAccount:(NSString *)strPhone andCode:(NSString *)strCode andPwd:(NSString *)password
{
    HYUserInfoResult *regResult;
    
    NSString *strDevInfo = [VoIPUtil getClientInfo];
    NSString *strMac = [VoIPUtil getDevID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"sdkregorlogin",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"name",@"Name",strPhone,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"code",@"Name",strCode,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"isfwd",@"Name",@"0",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"osinfo",@"Name",strDevInfo,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mac",@"Name",strMac,@"Value",nil]];
    
    NSString *strUrlString = [HYHTTPInterface makeRequestURL:WEB_SERVER_URL :params :SIGN_KEY];
    TZHttpRequest *request = [TZHttpRequest requestWithURL:[NSURL URLWithString:strUrlString]];
    [request startSynchronous];
    NSError *error = [request error];
    if(error != nil)
    {
        regResult = [[HYUserInfoResult alloc] init];
        regResult.resultCode = error.code;
    }
    else
    {
        regResult = [HTTPResultParser parseUserInfoResponse:request.responseString];
        if(regResult)
        {
            if(regResult.resultCode == 1)
            {
                regResult.resultCode = [self resetPassword:strPhone newPassword:password];
            }
        }
    }
    return regResult;
}

//获取套餐信息
+(HYPackageInfoResult *)getPackageInfo:(NSString *)strUID
{
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"sdkgetusablebizdetail",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",strUID,@"Value",nil]];
    //[params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",[NSString stringWithFormat:@"%d",0],@"Value",nil]];
    
    NSString *strUrlString = [HYHTTPInterface makeRequestURL:WEB_SERVER_URL :params :SIGN_KEY];
    TZHttpRequest *request = [TZHttpRequest requestWithURL:[NSURL URLWithString:strUrlString]];
    [request startSynchronous];
    NSError *error = [request error];
    HYPackageInfoResult *theDataSource = nil;
    if(error != nil)
    {
        theDataSource = [[HYPackageInfoResult alloc] init];
        theDataSource.resultCode = error.code;
    }
    else
    {
        theDataSource = [HTTPResultParser parseWareInfoResponse:request.responseString];
    }
    return theDataSource;
}

+(NSInteger)resetPassword:(NSString*)strPhone newPassword:(NSString*)strNewPwd
{
    NSInteger resultCode = -1;
    if (strPhone == nil || strNewPwd == nil) {
        return resultCode;
    }
    
    NSString *strToken = [HYHTTPInterface getToken];
    NSString *strMD5Pwd = [[VoIPUtil md5:strNewPwd] uppercaseString];
    NSString *strDESPwd = [HYHTTPInterface des:strMD5Pwd];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"sdksetpwd",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"token",@"Name",strToken,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"phone",@"Name",strPhone,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"newpwd",@"Name",strDESPwd,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appid",@"Name",@"5",@"Value",nil]];
    
    NSString *strUrlString = [HYHTTPInterface makeRequestURL:WEB_SERVER_URL :params :SIGN_KEY];
    TZHttpRequest *request = [TZHttpRequest requestWithURL:[NSURL URLWithString:strUrlString]];
    [request startSynchronous];
    NSError *error = [request error];
    if(error != nil)
    {
        resultCode = error.code;
    }
    else
    {
        //NSString *responseString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        resultCode = [HTTPResultParser parseResponse:request.responseString];
    }
    return resultCode;
}

//登录需要的参数
+(HYUserInfoResult *)getUserInfo:(NSString*)strUser password:(NSString*)strPwd
{
    if (strUser == nil || strPwd == nil) {
        return nil;
    }

    NSString *strUserType = @"name";
    if([strUser hasPrefix:@"95013"])
        strUserType = @"number";
    
    HYUserInfoResult *userInfoResult;
    NSString *strMD5Pwd = [[VoIPUtil md5:strPwd] uppercaseString];
    NSString *strDESPwd = [HYHTTPInterface des:strMD5Pwd];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"sdkgetuserinfo",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:strUserType,@"Name",strUser,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"password",@"Name",strDESPwd,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appid",@"Name",@"5",@"Value",nil]];

    NSString *strUrlString = [HYHTTPInterface makeRequestURL:WEB_SERVER_URL :params :SIGN_KEY];
    TZHttpRequest *request = [TZHttpRequest requestWithURL:[NSURL URLWithString:strUrlString]];
    [request startSynchronous];
    NSError *error = [request error];
    if(error != nil)
    {
        userInfoResult = [[HYUserInfoResult alloc] init];
        userInfoResult.resultCode = error.code;
    }
    else
    {
        userInfoResult = [HTTPResultParser parseUserInfoResponse:request.responseString];
    }
    return userInfoResult;
}

@end
