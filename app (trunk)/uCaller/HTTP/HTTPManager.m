//
//  HTTPManager.m
//  uCaller
//
//  Created by 崔远方 on 14-3-10.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "UDefine.h"
#import "UConfig.h"
#import "iToast.h"
#import "ASIFormDataRequest.h"
#import "GetCodeDataSource.h"
#import "ClientRegDataSource.h"
#import "Util.h"
#import "GetSharedDataSource.h"
#import "CheckCodeDataSource.h"
#import "CheckRegisterDataSource.h"
#import "ResetPassWordDataSource.h"
#import "GetUserInfoDataSource.h"
#import "GiveGiftDataSource.h"
#import "GetUserTimeDataSource.h"
#import "UsablebizDetailDataSource.h"
#import "GetFwdDataSource.h"
#import "SimpleDataSource.h"
#import "CheckSetPwdDataSource.h"
#import "GetWareDataSource.h"
#import "CheckInviteCodeDataSource.h"
#import "GetTipsDataSource.h"
#import "VertifyOrderDataSource.h"
#import "CheckUpdateDataSource.h"
#import "CheckShareDataSource.h"

#import "FeedBackDataSource.h"
#import "GetNoticeDataSource.h"
#import "GetActiveAddsDataSource.h"
#import "GetIapEnvironmentDataSource.h"
#import "CallbackCallerDataSource.h"
#import "SinaWeiboUserInfoDataSource.h"

#import "TaskInfoTimeDataSource.h"
#import "GetAdsContentDataSource.h"
#import "CheckExchangeCode.h"
#import "ExchangeLog.h"
#import "BeforeLoginInfoDataSource.h"
#import "WXAccessTokenDataSource.h"
#import "GetWXInfoDataSource.h"
#import "WXRefreshTokenDataSource.h"
#import "UserTaskDetailDataSource.h"
#import "AfterLoginInfoDataSource.h"
#import "GetContactListDataSource.h"
#import "GetUserBaseInfoDataSource.h"
#import "GetBindAccountsDataSource.h"
#import "GetAvatarDetailDataSource.h"
#import "GetNewFriendDataSource.h"
#import "GetOfflineMsgDataSource.h"
#import "GetContactInfoDataSource.h"
#import "GetUserStatsDataSource.h"
#import "SendMediaMsgDataSource.h"
#import "GetUnreadFriendChangeListDataSource.h"
#import "GetMediaMsgDataSource.h"
#import "UploadAvatarDataSource.h"
#import "GetUserSettingsDataSource.h"
#import "UpdateUserSettingsDataSource.h"
#import "GetBlackListDataSource.h"
#import "AddBlackDataSource.h"
#import "RemoveBlackDataSource.h"
#import "ActivitytipDataSource.h"
#import "GetOccupationAll.h"
#import "GetRegionsByLevelDataSource.h"
#import "GetRegionsByParentDataSource.h"
#import "NewTaskGiveDataSource.h"
#import "CheckTaskDataSource.h"
#import "GetRefreshToken.h"
#import "GetTagNamesDataSource.h"
#import "GetFriendRecommendlistDataSource.h"
#import "AddStatDataSource.h"
#import "NewSendSmsDataSource.h"
#import "CreateOrderDataSource.h"
#import "GetAccountBalanceDataSource.h"
#import "UserDurationtransDataSource.h"
#import "GetreserveaddressDataSource.h"
#import "UpdateSafeStateDatasource.h"
#import "RequestgetSafeStateDatasource.h"
#import "MsgLog.h"
#import "getmediatipsDataSource.h"





#define POST_URL @"http://pes.yxhuying.com:9999/httpservice"
#define TOKEN_URL @"http://redirect.yxhuying.com:780/getlogintoken1"

//#define XMPP_SERVER_URL @"http://im.yxhuying.com:5280/webservice"
#define TPNS_SERVER_URL @"http://push.yxhuying.com:8765?"

#define SIGN_KEY @"96E79218965EB72C92A549DD5A330112"
#define SIGN_KEY_VERSION @"108C93B25D2A464031EEFF7CC86BCFDF"
#define DES_KEY @"2452ed5ef00a5a1e3d22b0267d8b84ca"
#define DES_KEY_VERSION @"ca7b83d8d16cf03183d3002a2a93a847"
#define PUSH_SIGN_KEY @"E388C1C5DF4933FA01F6DA9F92595589"

#define OS_NAME @"iOS"


@implementation HTTPManager
{
    RequestType _eType;
    NSTimeInterval secTimeOut;
    ASIHTTPRequest *lastRequest;
    NSMutableDictionary *vaildomainDic;

}

@synthesize asiHTTPRequest;
@synthesize dataSource;
@synthesize delegate;

static NSMutableArray *failCount = nil;
static NSString *domainUrl = nil;


-(id)init
{
    if(self = [super init])
    {
        secTimeOut = 30;
        vaildomainDic = [[NSMutableDictionary alloc]init];

    }
    return self;
}
+(NSMutableArray *)getFailCountArray{
    return failCount;
}
+(void)initFailCountArray{
    failCount = [[NSMutableArray alloc] init];
}

+(NSString*)urlEncode:(NSString *)string
{
    return (__bridge_transfer NSString *)
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (__bridge CFStringRef) string,
                                            NULL,
                                            CFSTR("!*'();:@&=+$,/?%#[]{}<>"),
                                            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

+(NSString*)urlDecode:(NSString *)string
{
    return (__bridge_transfer NSString *)
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                            (__bridge CFStringRef) string,
                                                            CFSTR(""),
                                                            kCFStringEncodingUTF8);
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

+(NSString *)des:(NSString *)plainText
{
    return [Util des:DES_KEY_VERSION plain:plainText];
}

//拼接url
+(NSString*)encryptPar:(NSString*)strUrl : (NSArray*)params : (NSString*)strPwd{
    
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:strUrl];
    NSMutableArray *paramArray = [[NSMutableArray alloc] init];
    for(NSDictionary *param in params)
    {
        NSString *name = [param objectForKey:@"Name"];
        NSString *value;
        if (([name isEqualToString:@"v"] || [name isEqualToString:@"version"])&& [UConfig getTestVersion] ) {
            value = [UConfig getTestVersion];
        }else{
            value = [param objectForKey:@"Value"];
        }
        [paramArray addObject:[NSString stringWithFormat:@"%@%@%@",name,strPwd,value]];
        NSString *ueValue = [HTTPManager urlEncode:value];
        [urlString appendFormat:@"%@=%@&",name,ueValue];
    }
    NSString *signString = [HTTPManager makeSign:paramArray];
    NSString *ueValue = [HTTPManager urlEncode:signString];
    [urlString appendFormat:@"%@=%@",@"sign",ueValue];
    return urlString;
}

//建立请求
-(void)requestUrl:(NSURL*)strUrl
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:strUrl];
    [request setDelegate:self];
    request.timeOutSeconds = secTimeOut;
    @synchronized(self.asiHTTPRequest){
        if (self.asiHTTPRequest != nil) {
            [self.asiHTTPRequest setDelegate:nil];
            [self.asiHTTPRequest clearDelegatesAndCancel];
        }
    }
    self.asiHTTPRequest = request;
    [request startAsynchronous];
}

-(void)sendHTTPRequest:(NSArray*)params : (NSString*)md5Pwd{
    
    NSString *strPwd = md5Pwd;
    if (md5Pwd == nil || [md5Pwd length] == 0) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        strPwd = [userDefault objectForKey:KUPassword];
    }
    
    NSString *strUrlString = [HTTPManager encryptPar:[HTTPManager domainUrl:_eType] :params :strPwd];
    NSLog(@"sendHTTPRequest = %@", strUrlString);
    [self requestUrl:[NSURL URLWithString:strUrlString]];
}

-(void)postHTTPRequest:(NSString *)urlString params:(NSArray *)params
{
#if LOG_HTTP
    NSLog(@"HTTP Post:\n%@",urlString);
#endif
    
    NSURL *url = [NSURL URLWithString: urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    
    if(params && [params count])
    {
        NSString *signString;
        NSMutableArray *paramArray = [[NSMutableArray alloc] init];
        for(NSDictionary *param in params)
        {
            NSString *name = [param objectForKey:@"Name"];
            NSString *value = [param objectForKey:@"Value"];
            [paramArray addObject:[NSString stringWithFormat:@"%@%@%@",name,SIGN_KEY_VERSION,value]];
            [request setPostValue:value forKey:name];
        }
        signString = [HTTPManager makeSign:paramArray];
        [request setPostValue:signString forKey:@"sign"];
    }
    [request startAsynchronous];
}

-(void)postHTTPRequest:(NSArray *)params
{
    [self postHTTPRequest:POST_URL params:params];
}

+(void)postHTTPRequest:(NSString *)urlString params:(NSArray *)params
{
#if LOG_HTTP
    NSLog(@"HTTP Post:\n%@",urlString);
#endif
    
    NSURL *url = [NSURL URLWithString: urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    
    if(params && [params count])
    {
        NSString *signString;
        NSMutableArray *paramArray = [[NSMutableArray alloc] init];
        for(NSDictionary *param in params)
        {
            NSString *name = [param objectForKey:@"Name"];
            NSString *value = [param objectForKey:@"Value"];
            [paramArray addObject:[NSString stringWithFormat:@"%@%@%@",name,SIGN_KEY_VERSION,value]];
            [request setPostValue:value forKey:name];
        }
        signString = [HTTPManager makeSign:paramArray];
        [request setPostValue:signString forKey:@"sign"];
    }
    [request startAsynchronous];
}

+(void)postHTTPRequest:(NSArray *)params
{
    [HTTPManager postHTTPRequest:POST_URL params:params];
}

+(void)postCrashReport:(NSString *)crashInfo
{
    NSString *appVersion = [NSString stringWithFormat:@"App Version:%@",UCLIENT_INFO];
    
    UIDevice* dev = [UIDevice currentDevice];
    
    NSString* osVer = [dev systemVersion];
    
    NSString* model = [dev model];
    
    NSString* devInfo = [NSString stringWithFormat:@"Device Info:%@ iOS %@",model,osVer];
    
    NSString *uid = [UConfig getUNumber];
    NSString *phone = [UConfig getPNumber];
    
    NSString *userInfo = [NSString stringWithFormat:@"User Info:%@(%@)",uid,phone];
    
    NSString *reportInfo = [NSString stringWithFormat:@"\r\n=========uCaller Crash Info===========\r\n%@\r\n%@\r\n%@\r\n Crash info:\r\n\%@",appVersion,devInfo,userInfo,crashInfo];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"log2email",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"title",@"Name",@"uCaller for iOS Crash Report",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"content",@"Name",reportInfo,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [HTTPManager postHTTPRequest:params];
}

//获取验证码
-(void)getCode:(NSInteger)curType andPhoneNumber:(NSString *)phoneNumber
{
    [MobClick event:@"e_req_code"];
    self.dataSource = [[GetCodeDataSource alloc] init];
    _eType = RequestCode;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getcode",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",[NSString stringWithFormat:@"%d",curType],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"phone",@"Name",phoneNumber,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appid",@"Name",[NSString stringWithFormat:@"%d",5],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",@"",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//检查验证码的有效性
-(void)checkCode:(NSInteger)curType andCode:(NSString *)curCode andPhoneNumber:(NSString *)phoneNumber
{
    self.dataSource = [[CheckCodeDataSource alloc] init];
    _eType = RequestCheckCode;
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"checkcode",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",[NSString stringWithFormat:@"%d",curType],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"phone",@"Name",phoneNumber,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"code",@"Name",curCode,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appid",@"Name",[NSString stringWithFormat:@"%d",5],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

//注册或登录
-(void)regOrLogin:(NSString *)userName andCode:(NSString *)codeStr
{
    if (userName == nil || codeStr == nil)
    {
        return;
    }
    
    _eType = RequestRegOrLogin;
    self.dataSource = [[ClientRegDataSource alloc] init];
    NSString *strDevInfo = [Util getClientInfo];
    NSString *strMac = [Util getDevID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"regorlogin",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"name",@"Name",userName,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"code",@"Name",codeStr,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"isfwd",@"Name",@"0",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"osinfo",@"Name",strDevInfo,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mac",@"Name",strMac,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];

}

//请求分享内容
-(void)getShareMsg
{
    NSDate *today = [NSDate date];
    NSDate *shareDate = [UConfig getRequestShareTime];
    NSTimeInterval time=[today timeIntervalSinceDate:shareDate];
    if(time < (24*60*60))
    {
        NSDictionary *shareDic = [NSKeyedUnarchiver unarchiveObjectWithFile:KShareContentsPath];
        if (shareDic != nil) {
            //有时间戳，且有缓存
            return ;
        }
    }
    
    _eType = RequestShared;
    self.dataSource = [[GetSharedDataSource alloc] init];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getsharemsg",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",@"IOS",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}
- (void)getShareMsgForAppDelegate{
    _eType = RequestShared;
    self.dataSource = [[GetSharedDataSource alloc] init];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getsharemsg",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",@"IOS",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}
//验证手机号是否注册
-(void)checkUser:(NSString *)phoneNumber
{
    _eType = RequestCheckUser;
    self.dataSource = [[CheckRegisterDataSource alloc] init];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"checkuser",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"phone",@"Name",phoneNumber,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//重设密码
-(void)resetPassWord:(NSString *)phoneNumber andPassWord:(NSString *)passWord
{
    _eType = RequestResetPassWord;
    self.dataSource = [[ResetPassWordDataSource alloc] init];

    NSString *pwdDes = [HTTPManager des:passWord];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"setpwd",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"phone",@"Name",phoneNumber,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"newpwd",@"Name",pwdDes,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appid",@"Name",@"5",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//基本用户信息获取
-(void)getUserInfo:(GetUserInfoType)curType andNumper:(NSString *)curNumber andPassWord:(NSString *)passWord
{
    _eType = RequestLogin;
    self.dataSource = [[GetUserInfoDataSource alloc] init];
    
    NSString *loginType;
    if(curType == UserId)
    {
        loginType = @"uid";
    }
    else if(curType == PhoneNumber)
    {
        //手机号
        loginType = @"name";
    }
    else
    {
        //95013号
        loginType = @"number";
    }
    NSString *pwdDes = [HTTPManager des:passWord];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getuserinfo",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:loginType,@"Name",curNumber,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"password",@"Name",pwdDes,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appid",@"Name",@"5",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}
//安全通话设置按钮是否打开
-(void)updateSafeState:(NSString*)userUid andSafeState:(NSString*)state{
    _eType = RequestupdateSafeState;
    self.dataSource = [[UpdateSafeStateDatasource alloc]init];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"updateSafeState",@"Value",nil]];
     [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"state",@"Name",state,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",userUid,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
   
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];

}
//刷新安全通话状态
-(void)getSafeState:(NSString*)userUid{
    _eType = RequestgetSafeState;
    self.dataSource = [[RequestgetSafeStateDatasource alloc]init];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getSafeState",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",userUid,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];

    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//获取赠送时长
-(void)giveGift:(NSString *)type andSubType:(NSString *)subType andInviteNumber:(NSArray *)numbers
{
    _eType = RequestGiveGift;
    self.dataSource = [[GiveGiftDataSource alloc] init];
    NSMutableString *numberStr;
    if(numbers == nil)
    {
        numberStr = nil;
    }
    else
    {
        numberStr = [[NSMutableString alloc] init];
        for(NSString *number in numbers)
        {
            [numberStr appendString:number];
            [numberStr appendString:@","];
        }
        if(numbers.count > 0)
        {
            numberStr = [NSMutableString stringWithFormat:@"%@",[numberStr substringToIndex:numberStr.length-1]];
        }
    }
    
    NSString *uid = [UConfig getUID];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"givegift",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",uid,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",type,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"subtype",@"Name",subType,@"Value",nil]];
    if(numberStr != nil)
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"invite",@"Name",numberStr,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//获取剩余时长
-(void)getUserTimer:(NSString *)type
{
    NSString *uid = [UConfig getUID];
    if(uid == nil || uid.length <= 0)
        return ;
    
    _eType = RequestUserTime;
    self.dataSource = [[GetUserTimeDataSource alloc] init];

    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getusertimer",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",uid,@"Value",nil]];
    if(type != nil)
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",type,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//用户详细业务查询
-(void)getUsablebizDetail:(NSString *)producttype
{
    _eType = RequestUsablebizDetail;
    self.dataSource = [[UsablebizDetailDataSource alloc] init];
    
    NSString *uid = [UConfig getUID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getusablebizdetail",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",uid,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"producttype", @"Name", producttype, @"Value", nil]];
    
    
    
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//用户指定月份的时间详情
-(void)getUserDurationtrans:(NSString*)month page:(NSString*)index pageSize:(NSString*)size
{
    _eType = RequestDurationtrans;
    self.dataSource = [[UserDurationtransDataSource alloc] init];
    
    NSString *uid = [UConfig getUID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getuserdurationtrans",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",uid,@"Value",nil]];
    
    if (month) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"month",@"Name",month,@"Value",nil]];
    }
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"page",@"Name",index,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"pageSize",@"Name",size,@"Value",nil]];
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
    
}





//查看用户每月任务详情
-(void)getUserTaskDetail:(NSString *)type Subtype:(NSString *)subtype
{
    _eType = RequestUserTaskDetail;
    self.dataSource = [[UserTaskDetailDataSource alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getusertaskdetail",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",type,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"subtype",@"Name",subtype,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//获取离线呼转号码
-(void)getfwd:(NSUInteger)fwdtype
{
    _eType = RequestGetfwd;
    self.dataSource = [[GetFwdDataSource alloc] init];
    NSString *strUserID = [UConfig getUID];
    NSString *strFwdType = [NSString stringWithFormat:@"%d",fwdtype];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getfwd",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",strUserID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"fwdtype",@"Name",strFwdType,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

//前转设置
-(void)setfwd:(NSUInteger)fwdtype :(BOOL)bforce :(NSString*)strfwdnumber :(BOOL)benable
{
    
    if ((strfwdnumber == nil) || (strfwdnumber.length == 0) ) {
        return;
    }
    
    _eType = RequestSetfwd;
    self.dataSource = [[SimpleDataSource alloc] init];
    
    NSString *strUserID = [UConfig getUID];
    NSString *strFwdType = [NSString stringWithFormat:@"%d",fwdtype];
    NSInteger nForce = bforce ? 1 : 0;
    NSString *strForce = [NSString stringWithFormat:@"%d",nForce];
    NSInteger nEnable = benable ? 1 : 0;
    NSString *strEnable = [NSString stringWithFormat:@"%d",nEnable];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"setfwd",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",strUserID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"fwdtype",@"Name",strFwdType,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"force",@"Name",strForce,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"fwdnumber",@"Name",strfwdnumber,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"enable",@"Name",strEnable,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//意见反馈
-(void)feedback:(NSString *)email andContent:(NSString *)text
{
    _eType = RequestFeedBack;
    self.dataSource = [[FeedBackDataSource alloc] init];
    
    NSString *uid = [UConfig getUID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"feedback",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",uid,@"Value",nil]];
    
    if (![Util isEmpty:email]) {
        //2.0版本 邮箱这个参数不传
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"email",@"Name",email,@"Value",nil]];
    }
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"text",@"Name",text,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self postHTTPRequest:params];
}

//是否设置密码
-(void)checkSetPwd
{
    _eType = RequestCheckSetPwd;
    self.dataSource = [[CheckSetPwdDataSource alloc] init];
    NSString *uid = [UConfig getUID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"checksetpwd",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",uid,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}
//获取token
+(NSString *)getToken
{
    NSURL *url = [NSURL URLWithString:TOKEN_URL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSString *token = [response substringToIndex:32];
        return token;
    }
    else
        return nil;
}
//设置密码
-(void)setpwd:(NSString*)strPhone :(NSString*)md5NewPwd
{
    if (strPhone == nil || md5NewPwd == nil) {
        return;
    }
    
    _eType = RequestSetPwd;
    self.dataSource = [[SimpleDataSource alloc] init];
    
    NSString *desNewPwd = [HTTPManager des:md5NewPwd];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"setpwd",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"phone",@"Name",strPhone,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"newpwd",@"Name",desNewPwd,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appid",@"Name",@"5",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//验证邀请码
-(void)checkInviteCode:(NSString *)inviteCode
{
    _eType = RequestCheckInviteCode;
    self.dataSource = [[CheckInviteCodeDataSource alloc] init];
    NSString *strUserID = [UConfig getUID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"checkinvitecode",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",strUserID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"invitecode",@"Name",inviteCode,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//获取界面提示文字
-(BOOL)getTips
{
    NSDate *today = [NSDate date];
    NSDate *shareDate = [UConfig GetRequestTipsTime];
    NSTimeInterval time=[today timeIntervalSinceDate:shareDate];
    if(time < (24*60*60))
    {
        return NO;
    }
    
    [UConfig setRequestTipsTime:today];
    _eType = RequestGetTips;
    self.dataSource = [GetTipsDataSource sharedInstance];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"gettips",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"code",@"Name",@"",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
    
    return YES;
}

//获取appStore套餐列表
-(void)getWareForAppStore:(NSString *)strAppInfo Type:(NSString *)aType
{
    _eType = RequestGetWareForIap;
    self.dataSource = [[GetWareDataSource alloc] init];
    NSString *strUserID = [UConfig getUID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getwareforiap",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",strUserID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",aType,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appinfo",@"Name",strAppInfo,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//获得应币余额
-(void)GetAccountBalance
{
    _eType = RequestGetAccountBalance;
    self.dataSource = [[GetAccountBalanceDataSource alloc] init];
    NSString *strUserID = [UConfig getUID];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getaccountbalance",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",strUserID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//APPStore IAP购买套餐
-(void)iapBuyWare:(WareInfo*)curWare receiptdata:(NSString*)strData order:(NSString*)orderId
{
    NSLog(@"curWare.strIAPID=%@\n,receiptdata=\n%@",curWare.strIAPID,strData);
    _eType = PostIAPForWare;
    VertifyOrderDataSource *dSource = [[VertifyOrderDataSource alloc] init];
    self.dataSource = dSource;
    NSMutableArray *params = [[NSMutableArray alloc] init];
    NSString *uid = [UConfig getUID];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"iapbuyware",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",uid,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"wareid",@"Name",curWare.strID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"orderId",@"Name",orderId,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"receiptdata",@"Name",strData,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appgoodid",@"Name",curWare.strIAPID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"osinfo",@"Name",[Util getClientInfo],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mac",@"Name",[Util getDevID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    
    [self postHTTPRequest:params];
}

//软件更新
-(void)checkUpdate:(NSString *)strVersion
{
    if (strVersion == nil || [strVersion length] == 0) {
        return;
    }
    _eType = RequestCheckUpdate;
    self.dataSource = [[CheckUpdateDataSource alloc] init];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"checkupdate",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"version",@"Name",strVersion,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appid",@"Name",@"5",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

//抽奖（大转盘）
-(void)lottery:(SharedType)curType
{
    _eType = RequestLottery;
    self.dataSource = [[SimpleDataSource alloc] init];
    NSString *strUserID = [UConfig getUID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"lottery",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",strUserID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",[NSString stringWithFormat:@"%d",curType],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//判断各平台是否分享
-(void)checkShare
{
    _eType = RequestCheckShare;
    self.dataSource = [CheckShareDataSource sharedInstance];
    NSString *strUserID = [UConfig getUID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"checkshare",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",strUserID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//获取公告提示内容
-(void)getNoticeInfo
{
    _eType = RequestGetNotice;
    self.dataSource = [[GetNoticeDataSource alloc] init];
    NSString *strDevInfo = [Util getClientInfo];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getnoticeinfo",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"osinfo",@"Name",strDevInfo,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//广告推广激活数据采集
-(void)ActiveAdds
{
    _eType = RequestGetActiveAdds;
    NSString *at = [UConfig getAToken];
    if (at == nil) {
        return ;
    }
    
    self.dataSource = [[GetActiveAddsDataSource alloc] init];
    NSString *strDevInfo = [Util getClientInfo];
    NSString *strMac = [Util getDevID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"activeadds",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"osinfo",@"Name",strDevInfo,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mac",@"Name",strMac,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",at,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//判断当前版本状态
-(void)getIapEnvironment
{
    _eType = RequestGetIapEnvironment;
    self.dataSource = [[GetIapEnvironmentDataSource alloc] init];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getIapEnvironment",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"version",@"Name",UCLIENT_UPDATE_VER,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//刷新token
- (void)accesstokenrefreshed
{
    _eType = RequestRefresh;
    self.dataSource = [[GetRefreshToken alloc] init];
    NSString *strUserID = [UConfig getUID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"accesstokenrefresh",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",strUserID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
    
}


//Modified by huah in 2013-05-05
+(void)uploadLocalContacts:(NSString *)uNumber numbers:(NSArray *)numbers
{
//    if([Util ConnectionState] == NO)
//        return;
//    
//    //TODO:大数量时需做拆分分批上传
//    NSMutableString *numberParam = [NSMutableString stringWithString:@""];
//    for(NSString *number in numbers)
//    {
//        if([Util isPhoneNumber:number])
//            [numberParam appendFormat:@"%@$0|",number];
//    }
//    
//    NSString *encryNumberParam = [Util xmppEncode:numberParam];
//    NSString *params = [NSString stringWithFormat:@"<contacts><jid>%@</jid><contactsvalue>%@</contactsvalue><signature></signature></contacts>",uNumber,encryNumberParam];
//    NSString *uploadUrl = [NSString stringWithFormat:@"%@%@",XMPP_SERVER_URL,@"/uploadContacts"];
//    
//    NSURL *url = [NSURL URLWithString:uploadUrl];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    [request setRequestMethod:@"POST"];
//    [request setPostValue:params forKey:@"param"];
//    
//    dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(globalConcurrentQueue, ^{
//        [request startSynchronous];
//    });
}

+(NSString *)updatePushInfo:(NSString*)strToken
{
    if ([Util isEmpty:strToken]) {
        return @"";
    }
    
    NSString *strSystemInfo = [Util getSystemInfo];
    NSString *strDeviceInfo = [NSString stringWithFormat:@"ios@%@",strToken];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *strUID = [userDefault objectForKey:KUNumber];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"updateuser",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appid",@"Name",@"1010",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"device_info",@"Name",strDeviceInfo,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",strUID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"sys_info",@"Name",strSystemInfo,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    
    NSString *strUrlString = [HTTPManager encryptPar:TPNS_SERVER_URL :params :PUSH_SIGN_KEY];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strUrlString]];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        return response;
    }
    else
        return @"";
}

-(void)updatePushInfo:(NSString*)strToken
{
    if (strToken == nil) {
        return;
    }
    _eType = RequestUpdatePushInfo;
    
    NSString *strSystemInfo = [Util getSystemInfo];
    NSString *strDeviceInfo = [NSString stringWithFormat:@"ios@%@",strToken];
    NSString *strUNumber = [UConfig getUNumber];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"updateuser",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"appid",@"Name",@"1010",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"device_info",@"Name",strDeviceInfo,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",strUNumber,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"sys_info",@"Name",strSystemInfo,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    
    NSString *strUrlString = [HTTPManager encryptPar:TPNS_SERVER_URL :params :PUSH_SIGN_KEY];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strUrlString]];
    [request setDelegate:self];
    self.asiHTTPRequest = request;
    [request startAsynchronous];
}

-(void) getSinaWeiboUserInfo
{
    _eType = RequestSinaWeiboUserInfo;
    self.dataSource = [[SinaWeiboUserInfoDataSource alloc] init];
    
    NSString* str = [[NSString alloc] initWithFormat:@"https://api.weibo.com/2/users/show.json?source=%@&access_token=%@&uid=%@", KSinaAppKey, [UConfig getSinaToken], [UConfig getSinaUId]];
    NSURL* url =  [NSURL URLWithString:str];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    self.asiHTTPRequest = request;
    [request startAsynchronous];
}

#pragma mart------回拨请求
-(void) RequestCallback:(NSString*)callee
{
    _eType = RequestCallback;
    self.dataSource = [[CallbackCallerDataSource alloc] init];
    NSString* uid = [UConfig getUID];
    NSString* calleer = [UConfig getPNumber];
    
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"dialphone",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",uid,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"calleer",@"Name",calleer,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"callee",@"Name",callee,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
    
}

#pragma mark------任务剩余时长
-(void)getTaskInfoTime
{
    _eType = RequestTaskInfoTime;
    self.dataSource = [TaskInfoTimeDataSource sharedInstance];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"gettaskinfo",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"version",@"Name",UCLIENT_UPDATE_VER,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//广告内容获取
-(void)getadscontent:(NSString *)resolution
{
    _eType = RequestGetAdsContent;
    self.dataSource = [GetAdsContentDataSource sharedInstance];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getadscontent",@"Value",nil]];
    //分辨率这个参数先加了一个默认的中图
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"resolution", @"Name", resolution, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"os", @"Name", OS_NAME, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

//兑换码验证
-(void)checkExchangeCode:(NSString *)exchangeCode
{
    _eType = RequestCheckExchangeCode;
    self.dataSource = [[CheckExchangeCode alloc] init];
    
    NSMutableArray* params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd", @"Name", @"checkexchangecode", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid", @"Name", [UConfig getUID], @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"invitecode", @"Name", exchangeCode, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//用户兑换记录
-(void)getExchangeLog
{
    _eType = RequestExchangeLogCode;
    self.dataSource = [[ExchangeLog alloc] init];
    
    NSMutableArray* params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd", @"Name", @"getuserexchangelog", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid", @"Name", [UConfig getUID], @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//获取登录前信息
-(void)getBeforeLoginInfo
{
    if ([[NSDate date] timeIntervalSinceDate:[UConfig getDoaminTimeInterval]] < 24*60*60) {
        //距离上次request小于24小时
        return ;
    }
    
    _eType = RequestBeforeLoginInfo;
    self.dataSource = [BeforeLoginInfoDataSource sharedInstance];
    
    NSMutableArray* params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd", @"Name", @"beforelogininfo", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

//获取登录后信息
-(void)getAfterLoginInfo
{
    _eType = RequestAfterLoginInfo;
    self.dataSource = [[AfterLoginInfoDataSource alloc]init];
    
    NSMutableArray* params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd", @"Name", @"afterlogininfo", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid", @"Name", [UConfig getUID], @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

#pragma mark -----活动内容获取-----
-(void)getActityTip
{
    _eType = RequestGetActityTip;
    self.dataSource = [[ActivitytipDataSource alloc]init];
    
    NSMutableArray* params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd", @"Name", @"getactivitytip", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid", @"Name", [UConfig getUID], @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"activitycode", @"Name", @"qiangpiao", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type", @"Name", @"2", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
}

#pragma mark -----微信登陆授权-----
//微信授权-第二步-通过code获取access_token
-(void)getWXaccessToken:(NSString *)code APPID:(NSString *)appId APPSECRET:(NSString *)secret
{
    _eType = RequestWXAccessToken;
    self.dataSource = [[WXAccessTokenDataSource alloc] init];
    
    NSString *str = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",appId,secret,code];
    NSURL* url =  [NSURL URLWithString:str];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    self.asiHTTPRequest = request;
    [request startAsynchronous];
}
//微信授权-第三步-通过access_token调用接口
-(void)getWXInfoAccessToken:(NSString *)accessToken OpenId:(NSString *)openId
{
    _eType = RequestWXInfo;
    self.dataSource = [[GetWXInfoDataSource alloc] init];
    
    NSString *str = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openId];
    NSURL* url =  [NSURL URLWithString:str];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    self.asiHTTPRequest = request;
    [request startAsynchronous];
}
//微信授权-刷新access_token有效期
-(void)getWXRefreshToken:(NSString *)appId RefreshToken:(NSString *)refreshToken
{
    _eType = RequestWXRefreshToken;
    self.dataSource = [[WXRefreshTokenDataSource alloc] init];
    
    NSString *str = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",appId,refreshToken];
    
    NSURL* url =  [NSURL URLWithString:str];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    self.asiHTTPRequest = request;
    [request startAsynchronous];
}

#pragma mark --------- 获取用户运营账号列表接口 ---------
-(void)getOpUsersList
{
    _eType = RequestOpUsersList;
    //暂时先不实现
}

#pragma mark --------- 获取用户好友列表接口 ---------
-(void)getContactList:(NSInteger)page
{
    _eType = RequestContactList;
    self.dataSource = [[GetContactListDataSource alloc] init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"friend_getfriendlist",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid", @"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"updatetime", @"Name",[UConfig getContactListUpdateTime],@"Value",nil]];
//    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"page", @"Name",[NSString stringWithFormat:@"%ld", (long)page],@"Value",nil]];
//    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"pagesize",@"Name",@"20",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 获取未读好友变更接口 ---------
-(void)getUnreadFriendChangeList
{
    _eType = RequestGetUnreadFriendChangeList;
    self.dataSource = [[GetUnreadFriendChangeListDataSource alloc] init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"friend_getunreadfriendchangelist",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid", @"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 获取用户基本信息接口 ---------
-(void)getUserBaseInfo
{
    
    [MobClick event:@"e_client_online"];
    
    _eType = RequestUserBaseInfo;
    self.dataSource = [[GetUserBaseInfoDataSource alloc] init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"user_getuserbaseinfo",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 获取陌生人详情信息接口 ---------
-(void)getStrangerInfoOfUNumber:(NSString *)aUNumber
{
    _eType = RequestStrangerInfo;
    self.dataSource = [[GetContactInfoDataSource alloc] init];
    self.dataSource.dataParams = aUNumber;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"user_getuserbaseinfo",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"number",@"Name",aUNumber,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 获取联系人详情信息接口 ---------
-(void)getContactInfo:(unsigned long long)updatetime Uid:(NSString *)contactUid UNumber:(NSString *)aUNumber
{
    
    _eType = RequestContactInfo;
    self.dataSource = [[GetContactInfoDataSource alloc] init];
    if (contactUid != nil && contactUid.length > 0) {
        self.dataSource.dataParams = contactUid;
    }
    else {
        self.dataSource.dataParams = aUNumber;
    }
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"user_getuserbaseinfo",@"Value",nil]];
    if (contactUid != nil && contactUid.length > 0) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",contactUid,@"Value",nil]];
    }
    else if (aUNumber != nil && aUNumber.length > 0){
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"number",@"Name",aUNumber,@"Value",nil]];
    }
    
    if (updatetime > 0) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"updatetime",@"Name",[NSString stringWithFormat:@"%llu",updatetime] ,@"Value",nil]];
    }
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}


#pragma mark --------- 上传用户基本信息接口 ---------
-(void)updateUserBaseInfo:(NSDictionary *)dicInfo
{
    _eType = RequestUpdateUserBaseInfo;
    self.dataSource = [[HTTPDataSource alloc] init];
    
    //uid, 昵称， 头像， 手机号， 心情， 性别， 生日，情感状态，学历，收入，兴趣爱好，自标签
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"user_updateuserbaseinfo",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    
    if ([dicInfo objectForKey:@"photoMid"] != nil) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"avatar",@"Name",[dicInfo objectForKey:@"photoMid"],@"Value",nil]];
        
    }
    if ([dicInfo objectForKey:@"nickname"] != nil) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"nickname",@"Name",[dicInfo objectForKey:@"nickname"],@"Value",nil]];
    }
    if ([dicInfo objectForKey:@"gender"] != nil) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"gender",@"Name",[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"gender"]],@"Value",nil]];
    }
    if ([dicInfo objectForKey:@"birthday"] != nil) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"birthday",@"Name",[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"birthday"]],@"Value",nil]];
    }
    if ([dicInfo objectForKey:@"emotion"] != nil) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"emotion",@"Name",[dicInfo objectForKey:@"emotion"],@"Value",nil]];
    }
    if ([dicInfo objectForKey:@"occupation"] != nil) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"occupation",@"Name",[dicInfo objectForKey:@"occupation"],@"Value",nil]];
    }
    if ([dicInfo objectForKey:@"company"] != nil) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"company",@"Name",[dicInfo objectForKey:@"company"],@"Value",nil]];
    }
    if ([dicInfo objectForKey:@"school"] != nil) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"school",@"Name",[dicInfo objectForKey:@"school"],@"Value",nil]];
    }
    if ([dicInfo objectForKey:@"native_region"] != nil) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"native_region",@"Name",[dicInfo objectForKey:@"native_region"],@"Value",nil]];
    }
    if ([dicInfo objectForKey:@"feeling_status"] != nil) {
        NSString *aStr = [dicInfo objectForKey:@"feeling_status"];
        NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:aStr,@"feeling_status", nil];
        NSInteger aInt = [Util stringTransfromInterger:aDic];
        
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"feeling_status",@"Name",[NSString stringWithFormat:@"%ld",aInt],@"Value",nil]];
    }
    if ([dicInfo objectForKey:@"diploma"] != nil) {
        NSString *aStr = [dicInfo objectForKey:@"diploma"];
        NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:aStr,@"diploma", nil];
        NSInteger aInt = [Util stringTransfromInterger:aDic];
        
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"diploma",@"Name",[NSString stringWithFormat:@"%ld",aInt],@"Value",nil]];
    }
    if ([dicInfo objectForKey:@"month_income"] != nil) {
        NSString *aStr = [dicInfo objectForKey:@"month_income"];
        NSDictionary *aDic = [NSDictionary dictionaryWithObjectsAndKeys:aStr,@"month_income", nil];
        NSInteger aInt = [Util stringTransfromInterger:aDic];
        
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"month_income",@"Name",[NSString stringWithFormat:@"%ld",aInt],@"Value",nil]];
    }
    if ([dicInfo objectForKey:@"interest"] != nil) {
        
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"interest",@"Name",[dicInfo objectForKey:@"interest"],@"Value",nil]];
    }
    if ([dicInfo objectForKey:@"self_tags"] != nil) {
        
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"self_tags",@"Name",[dicInfo objectForKey:@"self_tags"],@"Value",nil]];
    }
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 获取用户头像详情接口 ---------
-(void)getAvatarDetail:(NSDictionary *)avatarDic
{
    _eType = RequestGetAvatarDetail;
    self.dataSource = [[GetAvatarDetailDataSource alloc] init];
    
    if (avatarDic == nil) {
        return;
    }
    if ([avatarDic objectForKey:@"uid"] == nil) {
        return;
    }
    if ([avatarDic objectForKey:@"photoMid"]== nil) {
        return;
    }
    
    NSString *uid = [avatarDic objectForKey:@"uid"];
    NSString *photoMid = [avatarDic objectForKey:@"photoMid"];
    self.dataSource.dataParams = avatarDic;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getavatardetail",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",uid,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"avatar",@"Name",photoMid,@"Value",nil]];

    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

//获取大头像详情
-(void)getAvatarDetailBigPhoto:(NSDictionary *)avatarDic
{
    _eType = RequestGetAvatarDetailBigPhoto;
    self.dataSource = [[GetAvatarDetailDataSource alloc] init];
    
    if (avatarDic == nil) {
        return;
    }
    if ([avatarDic objectForKey:@"uid"] == nil) {
        return;
    }
    if ([avatarDic objectForKey:@"photoMid"]== nil) {
        return;
    }
    
    NSString *uid = [avatarDic objectForKey:@"uid"];
    NSString *photoMid = [avatarDic objectForKey:@"photoMid"];
    self.dataSource.dataParams = avatarDic;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getavatardetail",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",uid,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"avatar",@"Name",photoMid,@"Value",nil]];
    
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",@"big",@"Value",nil]];
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 上传用户头像mid接口 ---------
-(void)uploadAvatar
{
    NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",[UConfig getPhotoURL]]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePaths]) {
        return ;
    }
    
    _eType = RequestUploadAvatar;
    self.dataSource = [[UploadAvatarDataSource alloc] init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"uploadavatar",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"filetype",@"Name",@"jpg",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    NSString *strUrlString = [HTTPManager encryptPar:[HTTPManager domainUrl:_eType] :params :SIGN_KEY_VERSION];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strUrlString]];
    [request setDelegate:self];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePaths];
    [request appendPostData:data];
    [request setRequestMethod:@"POST"];
    self.asiHTTPRequest = request;
    [request startAsynchronous];
}

#pragma mark --------- 上传第三方平台绑定信息接口 ---------
-(void)OAuthInfo:(SharedType)shareType
{
    //目前新浪微博授权， 腾讯qq授权
    _eType = RequestOAuthInfo;
    self.dataSource = [[HTTPDataSource alloc] init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"oauthinfo",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",[NSString stringWithFormat:@"%d",shareType],@"Value",nil]];
    
    switch (shareType) {
        case SinaWbShared:
        {
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"nickname",@"Name",[UConfig getSinaNickName],@"Value",nil]];
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"openid",@"Name",[UConfig getSinaUId],@"Value",nil]];
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"accesstoken",@"Name",[UConfig getSinaToken],@"Value",nil]];
            double timeDou = [[UConfig getSinaExpiredate] timeIntervalSince1970];
            NSInteger timeSec = (NSInteger)timeDou;
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"expiretoken",@"Name",[NSString stringWithFormat:@"%ld",timeSec],@"Value",nil]];
        }
            break;
        case QQOAuth:
        {
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"nickname",@"Name",[UConfig getTencentNickName],@"Value",nil]];
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"openid",@"Name",[UConfig getTencentOpenId],@"Value",nil]];
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"accesstoken",@"Name",[UConfig getTencentToken],@"Value",nil]];
            double timeDou = [[UConfig getTencentExpireDate] timeIntervalSince1970];
            NSInteger timeSec = (NSInteger)timeDou;
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"expiretoken",@"Name",[NSString stringWithFormat:@"%ld",timeSec],@"Value",nil]];
        }
            break;
        case WXShared:
        case WXCircleShared:
        {
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"nickname",@"Name",[UConfig getWXNickName],@"Value",nil]];
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"openid",@"Name",[UConfig getWXUnionid],@"Value",nil]];
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"accesstoken",@"Name",[UConfig getWXToken],@"Value",nil]];
            double timeDou = [[UConfig getWXExpireDate] timeIntervalSince1970];
            NSInteger timeSec = (NSInteger)timeDou;
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"expiretoken",@"Name",[NSString stringWithFormat:@"%ld",timeSec],@"Value",nil]];
        }
            break;
        default:
            break;
    }
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 获取第三方平台绑定信息接口 ---------
-(void)getBindAccounts
{
    //目前新浪微博授权， 腾讯qq授权
    _eType = RequestGetBindAccounts;
    self.dataSource = [[GetBindAccountsDataSource alloc] init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"bind_getbindaccounts",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 发送好友请求接口 ---------
-(void)sendAddContact:(NSString *)uNumber VerifyInfo:(NSString *)verifyInfo NoteName:(NSString *)noteName ListID:(NSString *)listID
{
    _eType = RequestAddFriend;
    self.dataSource = [[HTTPDataSource alloc] init];
    self.dataSource.dataParams = uNumber;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"friend_sendfriendrequest",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"reqnumber",@"Name",uNumber,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"verifyInfo",@"Name",verifyInfo,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"channel",@"Name",UCLIENT_UPDATE_CHANNEL,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 好友请求处理接口 ---------
-(void)processFriend:(NSString *)msgID Result:(BOOL)isAgree
{
    _eType = RequestProcessFriend;
    self.dataSource = [[HTTPDataSource alloc] init];
    self.dataSource.dataParams = msgID;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"friend_processfriendrequest",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"reqmsgid",@"Name",msgID,@"Value",nil]];
    if (isAgree) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"status",@"Name",@"2",@"Value",nil]];
    }
    else{
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"status",@"Name",@"5",@"Value",nil]];
    }
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 删除好友接口 ---------
-(void)deleteContact:(NSString *)uid WithUnumber:(NSString *)uNumber
{
    _eType = RequestDeleteFriend;
    self.dataSource = [[HTTPDataSource alloc] init];
    self.dataSource.dataParams = uid;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"friend_cancelfriend",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"frienduid",@"Name",uid,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 获取未读新的朋友信息接口 ---------
-(void)getNewContact
{
    _eType = RequestGetNewContact;
    self.dataSource = [[GetNewFriendDataSource alloc] init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"friend_getnewfriendreq",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 上传联系人接口 ---------
-(void)uploadAddressbook:(NSArray *)addressBookArray
{
    _eType = RequestUploadAddressBook;
    self.dataSource = [[HTTPDataSource alloc] init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"contact_uploadcontacts",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    
    NSMutableString *strAddressBook = [[NSMutableString alloc] init];
    for (UContact *localContact in addressBookArray) {
        [strAddressBook appendFormat:@"%@|%@,", localContact.pNumber, localContact.name];
    }
    NSLog(@"contact_uploadcontacts = %@", strAddressBook);
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"contacts",@"Name",strAddressBook,@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self postHTTPRequest:params];
}

#pragma mark --------- 获取未读消息接口 ---------
-(void)getOfflineMsg:(NSInteger)type
{
    _eType = RequestOfflineMsg;
    self.dataSource = [[GetOfflineMsgDataSource alloc] init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"msg_getunreadmsg",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",[NSString stringWithFormat:@"%zd", type],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 获取统计信息接口 ---------
-(void)getUserStats:(UserStats)statType
{
    _eType = RequestUserStats;
    self.dataSource = [[GetUserStatsDataSource alloc] init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"stat_getuserstats",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    if (statType != EUserStatsAll) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",[NSString stringWithFormat:@"%d", statType],@"Value",nil]];
    }
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark --------- 发送消息接口 ---------
-(void)sendTextMsgWithRecevierUID:(NSString *)recevierUid
                          Content:(NSString *)content
                       DataParams:(id)dataParams
{
    _eType = RequestSendTextMediaMsg;
    self.dataSource = [[SendMediaMsgDataSource alloc] init];
    self.dataSource.dataParams = dataParams;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"msg_sendmediamsg",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"recevieruid",@"Name",recevierUid,@"Value",nil]];
    
    //位置
    if ([content rangeOfString:@"longitude" options:NSCaseInsensitiveSearch].length > 0 &&
        [content rangeOfString:@"latitude" options:NSCaseInsensitiveSearch].length > 0) {
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",@"5",@"Value",nil]];
        
    }else if([content rangeOfString:@"uid" options:NSCaseInsensitiveSearch].length > 0 &&
             [content rangeOfString:@"hyid" options:NSCaseInsensitiveSearch].length > 0&&
             [content rangeOfString:@"nickname" options:NSCaseInsensitiveSearch].length > 0){
        //名片
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",@"6",@"Value",nil]];
        
    }else{
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",@"1",@"Value",nil]];
    }
    
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"text",@"Name",content,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

-(void)sendAudioMsgWithRecevierUID:(NSString *)recevierUid
                          Duration:(NSInteger)duration
                              Data:(NSData *)data
                        DataParams:(id)dataParams
{
    _eType = RequestSendAudioMediaMsg;
    self.dataSource = [[SendMediaMsgDataSource alloc] init];
    self.dataSource.dataParams = dataParams;

    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    
    if (recevierUid.length > 10) {
        


        if([[recevierUid substringToIndex:1] isEqualToString:@"s"]){
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"receiver",@"Name",            [recevierUid substringFromIndex:1],@"Value",nil]];
            
        }else{

            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"receiver",@"Name",recevierUid,@"Value",nil]];
        }
        
        
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"msg_sendmediamsgbyphone",@"Value",nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",@"4",@"Value",nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"caller",@"Name",[UConfig getUNumber],@"Value",nil]];

        MsgLog *msg = (MsgLog*)dataParams;
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"isSms", @"Name", [NSString stringWithFormat:@"%d", msg.isSendLeaveMsg], @"Value", nil]];
        
    }else{
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"msg_sendmediamsg",@"Value",nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",@"2",@"Value",nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"recevieruid",@"Name",recevierUid,@"Value",nil]];
    }

    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];


    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"duration", @"Name", [NSString stringWithFormat:@"%zd", duration], @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"filetype", @"Name", @"amr", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    NSString *strUrlString = [HTTPManager encryptPar:[HTTPManager domainUrl:_eType] :params :SIGN_KEY_VERSION];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strUrlString]];
    [request setDelegate:self];
    [request appendPostData:data];
    [request setRequestMethod:@"POST"];
    self.asiHTTPRequest = request;
    [request startAsynchronous];
}

//-(void)sendFileMsg:(NSString *)recevierUid FileType:(NSInteger)fileType Data:(NSData *)data
//{
//    _eType = RequestSendPictureMediaMsg;
//    self.dataSource = [[HTTPDataSource alloc] init];
////    self.dataSource.dataParams = dataParams;
//    
//    NSMutableArray *params = [[NSMutableArray alloc] init];
//    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"msg_sendmediamsg",@"Value",nil]];
//    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
//    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"recevieruid",@"Name",recevierUid,@"Value",nil]];
//    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",@"3",@"Value",nil]];
//    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"filetype", @"Name", fileType, @"Value", nil]];
//    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
//    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
//    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
//    NSString *strUrlString = [HTTPManager encryptPar:[HTTPManager domainUrl:_eType] :params :SIGN_KEY_VERSION];
//    
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strUrlString]];
//    [request setDelegate:self];
//    [request appendPostData:data];
//    [request setRequestMethod:@"POST"];
//    self.asiHTTPRequest = request;
//    [request startAsynchronous];
//}

-(void)sendPhotoMsgWithRecevierUID:(NSString *)recevierUid
                           FileType:(NSString *)aType
                              Data:(NSData *)data
                        DataParams:(id)dataParams
{
    if (data == nil || data.length == 0) {
        return ;
    }
    _eType = RequestSendPictureMediaMsg;
    self.dataSource = [[SendMediaMsgDataSource alloc] init];
    self.dataSource.dataParams = dataParams;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"msg_sendmediamsg",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"recevieruid",@"Name",recevierUid,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",@"3",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"filetype",@"Name",aType,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    NSString *strUrlString = [HTTPManager encryptPar:[HTTPManager domainUrl:_eType] :params :SIGN_KEY_VERSION];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strUrlString]];
    [request setDelegate:self];
    [request appendPostData:data];
    [request setRequestMethod:@"POST"];
    self.asiHTTPRequest = request;
    [request startAsynchronous];
}

//-(void)sendVoiceMailMsg:(NSString *)uid Duration:(double)duration Caller:(NSString *)number Data:(NSData *)data
//{
//    
//}

#pragma mark ------ 获取多媒体消息文件 ------
-(void)getMediaMsg:(NSString *)msgID DataParams:(id)dataParams
{
    _eType = RequestGetMediaMsg;
    self.dataSource = [[GetMediaMsgDataSource alloc] init];
    self.dataSource.dataParams = dataParams;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"msg_getmediamsg",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"msgid",@"Name",msgID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

-(void)getMediaMsgBigPic:(NSString *)msgID DataParams:(id)dataParams
{
    _eType = RequestGetMediaMsgBigPic;
    self.dataSource = [[GetMediaMsgDataSource alloc] init];
    self.dataSource.dataParams = dataParams;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"msg_getmediamsg",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"msgid",@"Name",msgID,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"pictype",@"Name",@"big",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

//服务器下发短信
-(void)newSendSms:(NSString *)receivePhone MessageType:(NSString *)mType
{
    _eType = RequestNewSendSms;
    self.dataSource = [[NewSendSmsDataSource alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"newsendsms",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"number",@"Name",[UConfig getUNumber],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"phone",@"Name",receivePhone,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",mType,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"os", @"Name", OS_NAME, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark ------用户设置和黑名单---------
//获取用户设置
-(void)getUserSettings
{
    _eType = RequestGetUserSettings;
    self.dataSource = [[GetUserSettingsDataSource alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"usersetting_getusersettings",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}
//更新用户设置
-(void)updateUserSettings:(NSString *)type Params:(NSDictionary *)modelDic
{
    /*调用时格式
    //        NSDictionary *mdic = [[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"friend_recommend", nil];
    //        [updateUserSettingsHttp updateUserSettings:@"friend_recommend" Params:mdic];
    NSDictionary *mdic = [[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"call_model",@"1",@"forward_type",@"18700000001",@"forward_number", nil];
    [updateUserSettingsHttp updateUserSettings:@"call_setting" Params:mdic];*/
    
    _eType = RequestUpdateUserSettings;
    self.dataSource = [[UpdateUserSettingsDataSource alloc]init];
    
    //将字典数据转化为json
    NSString *model =[self dictionaryTransformJson:modelDic];// @"{friend_verify:2}";
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"usersetting_updateusersettings",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",type,@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"params",@"Name",model,@"Value", nil]];
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

-(NSString *)dictionaryTransformJson:(NSDictionary *)aDic
{
    //用来将字典类型的数据转化成符合服务器使用的json对象
    NSError *aError;
    NSData *dataForJson = [NSJSONSerialization dataWithJSONObject:aDic options:NSJSONWritingPrettyPrinted error:&aError];
    
    NSString *str = [[NSString alloc] initWithData:dataForJson encoding:NSUTF8StringEncoding];
    
    NSArray *arr  = [str componentsSeparatedByString:@"{"];
    NSArray *arr1 = [arr[1] componentsSeparatedByString:@"}"];
    
    NSString *text = [arr1[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    
//    text = [self checkParaNumber:text];
    
    NSString *textResult = [NSString stringWithFormat:@"{%@}",text];
    
    return textResult;
}
-(NSString *)checkParaNumber:(NSString *)aStr
{
    //检测有几个参数,若三个把错乱位置的参数位置转化成正确的
    NSString *strRes;
    if ([aStr rangeOfString:@","].length) {
        NSArray *arr = [aStr componentsSeparatedByString:@","];
        NSArray *arr1 = [arr[1] componentsSeparatedByString:@"\n "];
        NSArray *arr2 = [arr[2] componentsSeparatedByString:@"\n "];
        aStr = [NSString stringWithFormat:@"%@,%@,%@",arr2[1],arr[0],arr1[1]];
        
    }
    return strRes;
}
//获取黑名单列表
-(void)getBlackList
{
    _eType = RequestGetBlackList;
    self.dataSource = [[GetBlackListDataSource alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"usersetting_getblacklist",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}
//添加黑名单
-(void)addBlack:(NSString *)phones
{
    _eType = RequestAddBlack;
    self.dataSource = [[AddBlackDataSource alloc]init];
   
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"usersetting_addblack",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"phones",@"Name",phones,@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}
//移除黑名单
-(void)removeBlack:(NSString *)phones
{
    _eType = RequestRemoveBlack;
    self.dataSource = [[RemoveBlackDataSource alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"usersetting_removeblack",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"phones",@"Name",phones,@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark ------ 获取全部职业信息  ------
-(void)getOccupationAll
{
    _eType = RequestGetOccupationAll;
    self.dataSource = [[GetOccupationAll alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"common_occupation_all",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark ------ 通过level获取区域信息  ------
-(void)getRegionsByLevel
{
    _eType = RequestGetRegionsByLevel;
    self.dataSource = [[GetRegionsByLevelDataSource alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"common_getRegionsByLevel",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"level",@"Name",@"1",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark ------ 通过父区域id获取区域信息  ------
-(void)getRegionsByParent:(NSString *)idStr
{
    _eType = RequestGetRegionsByParent;
    self.dataSource = [[GetRegionsByParentDataSource alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"common_getRegionsByParent",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"id",@"Name",idStr,@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark ------ 获取全部可用标签名称  ------
-(void)getTagNames
{
    _eType = RequestGetTagNames;
    self.dataSource = [[GetTagNamesDataSource alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"common_getTagNames",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark ------ 新任务赠送 ------
-(void)getNewTaskGive:(NSString *)code
{
    _eType = RequestNewTaskGive;
    self.dataSource = [[NewTaskGiveDataSource alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"newtaskgive",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"code",@"Name",code,@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark ------ 验证任务是否完成 ------
-(void)checkTask:(NSString *)type
{
    _eType = RequestCheckTask;
    self.dataSource = [[CheckTaskDataSource alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"checktask",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",type,@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

#pragma mark ------ 通讯录推荐 ------
-(void)getFriendRecommendlist
{
//    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
//    if ((time - [UConfig getABFriendTimeInternal]) < 60*60*24.0) {
//        return ;
//    }
    
    _eType = RequestGetFriendRecommendlist;
    self.dataSource = [GetFriendRecommendlistDataSource sharedInstance];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"recommend_getfriendrecommendlist",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
    NSLog(@"getFriendRecommendlist params = %@", params);
}

#pragma mark ------ 统计数据收集接口 ------
-(void)addstat:(NSString *)apkname DataCode:(NSString *)dataCode TypeCode:(NSString *)typeCode
{
    _eType = RequestAddstat;
    self.dataSource = [[AddStatDataSource alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"addstat",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",[UConfig getUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"apkname",@"Name",apkname,@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"data_code",@"Name",dataCode,@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type_code",@"Name",typeCode,@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mac",@"Name",[Util makeUUID],@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"os", @"Name", OS_NAME, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}

-(void)createOrderWareID:(NSString *)aWareID Fee:(NSString *)aPayFee Type:(NSString *)aType
{
    _eType = RequestCreateOrder;
    CreateOrderDataSource *temp = [[CreateOrderDataSource alloc]init];
    temp.type = aType;
    self.dataSource = temp;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"createorder",@"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid", @"Name", [UConfig getUID], @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"resource", @"Name", aType, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"wareid", @"Name", aWareID, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"fee", @"Name", aPayFee, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"os", @"Name", @"iOS", @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
}



//请求开机广告
-(void)getMediatips
{
    _eType = Requestmediatips;
    self.dataSource = [[getmediatipsDataSource alloc] init];
    NSString *uid = [UConfig getUID];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getmediatips",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"uid",@"Name",uid,@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"type",@"Name",@"normal",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"code",@"Name",@"start",@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"os", @"Name", OS_NAME, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    NSString *resolution;
    if (IPHONE6plus) {
        resolution = @"ios_big_icon";
    }
    else if (IPHONE4||IPHONE5||IPHONE6) {
        resolution = @"ios_middle_icon";
    }
    else if(IPHONE3GS)
    {
        resolution = @"ios_little_icon";
    }
    else {
        resolution = @"ios_big_icon";
    }
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"resolution", @"Name", resolution, @"Value", nil]];
    
    
    [self sendHTTPRequest:params : SIGN_KEY_VERSION];
    
}






#pragma mark ------ 获取备选域名接口 ------
-(void)getreserveaddress
{
    _eType = RequestGetreserveaddress;
    self.dataSource = [[GetreserveaddressDataSource alloc]init];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cmd",@"Name",@"getreserveaddress",@"Value", nil]];
    
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"v", @"Name", UCLIENT_UPDATE_VER, @"Value", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"format", @"Name", @"json", @"Value", nil]];
    //    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"at",@"Name",[UConfig getAToken],@"Value",nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cid", @"Name", @"1000001", @"Value", nil]];
    [self sendHTTPRequest:params :SIGN_KEY_VERSION];
    
}

#pragma mark ------ ASIHttpRequest回调接口 ------
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];

    NSData *data;
    if (responseString == nil || responseString.length == 0) {
        data = [request responseData];
        NSDictionary *dic = [request responseHeaders];
        if(dataSource && [dataSource respondsToSelector:@selector(parseHeader:Data:)])
            [dataSource parseHeader:dic Data:data];
    }
    else {
        NSLog(@"_eType = %d,  responseString = %@",_eType, responseString);
        if(dataSource && [dataSource respondsToSelector:@selector(parseData:)])
            [dataSource parseData:responseString];
    }
    
    if(self.delegate)
        [self.delegate dataManager:self dataCallBack:dataSource type:_eType bResult:YES];
    
    if (!dataSource.bParseSuccessed) {
         [self addFailCount:_eType];
    }
    
    if (dataSource.nResultNum == 100204 || dataSource.nResultNum == 100205) {
        NSString *errMsg = [Util getErrorMsg:dataSource.nResultNum];
        [[[iToast makeText:errMsg] setGravity:iToastGravityCenter] show];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"_eType = %d, %@ request error:\n%@",_eType,request.url,error);
    
    [self addFailCount:_eType];
    if(self.delegate)
        [self.delegate dataManager:self dataCallBack:dataSource type:_eType bResult:NO];
    [Util getErrorMsg:dataSource.nResultNum];
}

-(void)setHttpTimeOutSeconds:(NSTimeInterval)timerInterval
{
    if (timerInterval > 0.0 && (timerInterval-120.0) < 0.0 ) {
        secTimeOut = timerInterval;
    }
}

-(void)cancelRequest
{
    self.delegate = nil;
    @synchronized(self.asiHTTPRequest){
        if (self.asiHTTPRequest != nil) {
            [self.asiHTTPRequest setDelegate:nil];
            [self.asiHTTPRequest clearDelegatesAndCancel];
        }
    }
}

- (void)dealloc
{
    [self cancelRequest];
}


- (void)addFailCount:(RequestType)eType
{
    NSString *typeKeyStr = [HTTPManager keyForType:eType];
    static NSInteger r;
    r = [failCount[[typeKeyStr integerValue]]integerValue];
    r++;
    if ([[[UConfig getPesDoamin] objectForKey:typeKeyStr] isKindOfClass:[NSString class]]) {
        [vaildomainDic setObject:[[UConfig getPesDoamin] objectForKey:typeKeyStr] forKey:typeKeyStr];
        r = 0;
    }else{
        if (r/3 >= [[[UConfig getPesDoamin] objectForKey:typeKeyStr] count]) {
            r = 0;
        }
        [vaildomainDic setObject:[[[UConfig getPesDoamin] objectForKey:typeKeyStr] objectAtIndex:r/3] forKey:typeKeyStr];
    }
    
    [failCount replaceObjectAtIndex:[typeKeyStr integerValue] withObject:[NSString stringWithFormat:@"%d",r]] ;
    
    [UConfig setValidPesDoamin:vaildomainDic andKey:typeKeyStr];
}

+(NSString *)domainUrl:(RequestType)eType
{
    if([HTTPManager getFailCountArray] == nil){
        [HTTPManager initFailCountArray];
        for (int i = 0; i<13; i++) {
            [failCount addObject:@"0"];
        }
    }
    NSString *typeKeyStr = [HTTPManager keyForType:eType];
    //新加的接口没暂定分级域名是哪一个  可防止崩溃
    if (typeKeyStr == nil|| [typeKeyStr isEqualToString:@""]) {
        typeKeyStr = @"1";
    }
    if ([[UConfig getValidPesDomain] isKindOfClass:[NSString class]]) {
        domainUrl = [UConfig getLastValidPesDomain];
    }else{
        domainUrl = [[UConfig getValidPesDomain] objectForKey:typeKeyStr];
    }
    if (domainUrl == nil) {
        if ([[[UConfig getPesDoamin] objectForKey:typeKeyStr] isKindOfClass:[NSString class]]) {
            domainUrl = [[UConfig getPesDoamin] objectForKey:typeKeyStr];
        }else{
            domainUrl = [[[UConfig getPesDoamin] objectForKey:typeKeyStr] objectAtIndex:0];
        }    }
    //    NSLog(@"失败协议的类型 = %d, 失败次数 = %d",eType, [failCount[[typeKeyStr integerValue]]integerValue]);
    
    return domainUrl;
}

+(NSString *)keyForType:(RequestType)eType{
    NSString *keyStr;
    switch (eType) {
        case RequestRegOrLogin://验证码注册或登录
        case RequestCode://获取验证码
        case RequestCheckCode://验证码确认
        case RequestCheckUser://验证手机是否注册
        case RequestLogin://基本用户信息获取
        case RequestShared://获取分享内容
        case RequestGiveGift://赠送接口
        case RequestUserTime://获取剩余时长
        case RequestUsablebizDetail://用户详细业务查询
        case RequestFeedBack://意见反馈接口
        case RequestGetfwd://前转号码获取
        case RequestSetfwd://前传设置
        case RequestCheckSetPwd://判断用户是否设置密码
        case RequestSetPwd://重设密码
        case RequestGetWare://获取套餐
        case RequestGetWareForIap://获取套餐
        case PostIAPForWare://购买套餐
        case RequestCheckInviteCode:
        case RequestGetTips://获取界面提示文字
        case RequestLottery://抽奖接口
        case RequestCheckShare://判断各平台是否分享
        case RequestGetInviteCode://获取邀请码
        case RequestTaskInfoTime://剩余时长查询
        case RequestCheckExchangeCode://兑换验证码
        case RequestExchangeLogCode://用户兑换记录
        case RequestBeforeLoginInfo://获取登录前信息
        case RequestUserTaskDetail://查看用户每月任务详情
        case RequestAfterLoginInfo://获取登录后信息
        case RequestGetActityTip://活动提示文字获取
        case RequestOpUsersList://获取运营账号信息及权限
        case RequestContactList://获取用户好友列表
        case RequestUserBaseInfo://获取用户基本信息
        case RequestStrangerInfo://获取陌生人信息
        case RequestUpdateUserBaseInfo://更新个人信息
        case RequestOAuthInfo://授权信息记录
        case RequestGetBindAccounts://获取第三方平台绑定信息
        case RequestAddFriend://发送好友请求
        case RequestProcessFriend://好友请求处理
        case RequestDeleteFriend://删除好友
        case RequestGetNewContact://获取未读好友信息
        case RequestUploadAddressBook://上传联系人接口
        case RequestOfflineMsg://获取未读消息
        case RequestUserStats://获取用户统计信息
        case RequestSendTextMediaMsg://发送多媒体信息
        case RequestGetMediaMsg://获取多媒体消息文件
        case RequestGetUnreadFriendChangeList://获取未读好友更新列表
        case RequestGetUserSettings://获取用户设置接口
        case RequestUpdateUserSettings://更新用户设置接口
        case RequestGetBlackList://获取黑名单列表
        case RequestAddBlack://介入黑名单
        case RequestRemoveBlack://移除黑名单
        case RequestGetOccupationAll://获取全部职业信息
        case RequestGetRegionsByLevel://通过level获取区域信息
        case RequestGetRegionsByParent://通过父区域id获取区域信息
        case RequestNewTaskGive://新任务赠送接口
        case RequestCheckTask://验证任务是否完成
        case RequestRefresh://刷新token
        case RequestGetFriendRecommendlist://获取好友推荐列表
        case RequestAddstat://统计数据收集
        case RequestGetMediaMsgBigPic:
            
        case RequestUpdatePushInfo:
        case RequestContactInfo:
        case RequestSendAudioMediaMsg:
        case RequestSendPictureMediaMsg:
        case RequestGetTagNames:
        case RequestGetIapEnvironment://判断当前版本状态 44
        case RequestUploadAvatar://上传头像 77
        case RequestGetAvatarDetailBigPhoto:
        case RequestGetAvatarDetail://获取头像详情 80
            
        case RequestDurationtrans://
        case RequestGetAccountBalance:
        case RequestCreateOrder:
        case RequestNewSendSms:
        case Requestmediatips:
        case RequestupdateSafeState:
        case RequestgetSafeState:
            
            keyStr = @"1";
            break;
            
        case RequestCheckUpdate://软件更新 11
        case RequestGetNotice://公告提示 43
        case RequestGetreserveaddress://获取备份域名 102
            
            keyStr = @"2";
            break;
            
        case RequestCallback://回拨 49
            
            keyStr = @"4";
            break;
            
        case RequestGetActiveAdds://广告推广激活数据采集 19
        case RequestGetAdsContent://广告内容获取 46
            
            keyStr = @"6";
            break;
            
        default:
            break;
    }
    
    return keyStr;
}


@end
