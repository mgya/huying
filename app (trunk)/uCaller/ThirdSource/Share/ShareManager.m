//
//  ShareManager.m
//  uCaller
//
//  Created by admin on 14-10-21.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "ShareManager.h"
#import "UDefine.h"
#import "QQApi.h"
#import "QQApiInterfaceObject.h"
#import "TencentMessageObject.h"
#import "WXApi.h"
#import "UConfig.h"
#import "SinaWeiboUserInfoDataSource.h"
#import "ShareContent.h"
#import "iToast.h"
#import "UCore.h"
#import "UAppDelegate.h"

@interface ShareManager()
{
    HTTPManager*    sinaHttp;
    NSDictionary*   shareArray;
    ShareContent *tencentWBShareContent;
}

@end

@implementation ShareManager

//@synthesize qqWeibo;
@synthesize sharedType;
@synthesize tencentOAuth;


static ShareManager* sharedInstance;

+(ShareManager*) SharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[ShareManager alloc] init];
        }
    }
    return sharedInstance;

}

-(void)RegThirdSDK
{
    sinaHttp = [[HTTPManager alloc] init];
    sinaHttp.delegate = self;
    
    //sina weibo
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:KSinaAppKey];
    
    //qq weibo
//    qqWeibo = [[WeiboApi alloc] initWithAppKey:KTcAppKey andSecret:KTcAppSecret andRedirectUri:KTcRedirectURI andAuthModeFlag:0 andCachePolicy:0];
    
    //qq 互联 － tencent
    tencentOAuth = [[TencentOAuth alloc] initWithAppId:KQQAppId andDelegate:self];
    
    //wechat reg
    [WXApi registerApp:KWeChatAppId];
}

#pragma mark-----------新浪微博-----------
-(void)SinaWeiboOAuth
{
    sharedType = SinaWbShared;
    [UAppDelegate uApp].thirdAppType = EThirdAppCallbackType_Share_SinaWeibo;
    WBAuthorizeRequest* request = [WBAuthorizeRequest request];
    request.redirectURI = KSinaRedirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

-(void)SinaWeiboSendMsg
{
    if ([WeiboSDK isWeiboAppInstalled]) {
        if (!shareArray) {
            shareArray = [NSKeyedUnarchiver unarchiveObjectWithFile:KShareContentsPath];
        }
        
        sharedType = SinaWbShared;
        [UAppDelegate uApp].thirdAppType = EThirdAppCallbackType_Share_SinaWeibo;
        ShareContent* content = [shareArray objectForKey:[NSString stringWithFormat:@"%d", sharedType]];
        
        //text
        WBMessageObject *message = [WBMessageObject message];
        message.text = [NSString stringWithFormat:@"%@邀请码%@。%@", content.msg, [UConfig getInviteCode], content.hideUrl];

        //image
        WBImageObject *image = [WBImageObject object];
        NSString* imgurl = content.imgUrls.lastObject;
        NSURL* url = [NSURL URLWithString:imgurl];
        image.imageData = [[NSData alloc]initWithContentsOfURL:url];
        message.imageObject = image;
        
        WBSendMessageToWeiboRequest*request = [WBSendMessageToWeiboRequest requestWithMessage:message];
        NSInteger res = [WeiboSDK sendRequest:request];
        NSLog(@"%ld",res);
//    NSString *jsonData = @"{\"text\": \"新浪新闻是新浪网官方出品的新闻客户端，用户可以第一时间获取新浪网提供的高品质的全球资讯新闻，随时随地享受专业的资讯服务，加入一起吧\",\"url\": \"http://app.sina.com.cn/appdetail.php?appID=84475\",\"invite_logo\":\"http://sinastorage.com/appimage/iconapk/1b/75/76a9bb371f7848d2a7270b1c6fcf751b.png\"}";
//    [WeiboSDK inviteFriend:jsonData withUid:@"123456" withToken:[UConfig getSinaToken] delegate:self withTag:@"invite1"];
    }
    else {
        //没有安装新浪微博客户端
        [[[iToast makeText:@"尚未安装新浪微博客户端"] setGravity:iToastGravityCenter] show];
    }
}

-(void)SinaWeiboSendMsg:(ShareContent *)shareObject
{
    if ([WeiboSDK isWeiboAppInstalled]) {

        sharedType = SinaWbShared;
        [UAppDelegate uApp].thirdAppType = EThirdAppCallbackType_Share_SinaWeibo;
        
        //text
        WBMessageObject *message = [WBMessageObject message];
        message.text = [NSString stringWithFormat:@"%@%@", shareObject.msg, shareObject.hideUrl];
        
        //image
        WBImageObject *image = [WBImageObject object];
        NSString* imgurl = shareObject.imgUrls.lastObject;
        NSURL* url = [NSURL URLWithString:imgurl];
        image.imageData = [[NSData alloc]initWithContentsOfURL:url];
        message.imageObject = image;
        
        WBSendMessageToWeiboRequest*request = [WBSendMessageToWeiboRequest requestWithMessage:message];
        NSInteger res = [WeiboSDK sendRequest:request];
        NSLog(@"%ld",res);
        
    }
    else {
        //没有安装新浪微博客户端
        [[[iToast makeText:@"尚未安装新浪微博客户端"] setGravity:iToastGravityCenter] show];
    }
}

- (void)SinaWeiboSsoOut
{
    [WeiboSDK logOutWithToken:[UConfig getSinaToken] delegate:self withTag:@"user1"];
}

-(void)SinaWeiboUserInfo
{
    [sinaHttp getSinaWeiboUserInfo];
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    NSLog(@"sina weibo http success! result = %@", result);
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error;
{
    NSString *title = nil;
    UIAlertView *alert = nil;
    
    title = @"请求异常";
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:[NSString stringWithFormat:@"%@",error]
                                      delegate:nil
                             cancelButtonTitle:@"确定"
                             otherButtonTitles:nil];
    [alert show];
}


-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(bResult && eType == RequestSinaWeiboUserInfo) {
        SinaWeiboUserInfoDataSource* dataSrc = (SinaWeiboUserInfoDataSource*)theDataSource;
        [UConfig setSinaNickName:dataSrc.name];
        
        NSString *info = [NSString stringWithFormat:@"%d",sharedType];
        [[UCore sharedInstance] newTask:U_UPDATE_OAUTHINFO data:info];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KSinaWeiboOAuthSuc object:self];
    }
}


//for third sdk delegate
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if(response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
        if([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KShareSuccess object:self];
        }
        else if ([response isKindOfClass:WBAuthorizeResponse.class])
        {
            if ( 0 == response.statusCode) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSLog(@"sina token == %@", [(WBAuthorizeResponse*)response accessToken]);
                    [UConfig setSinaToken:[(WBAuthorizeResponse*)response accessToken]];
                    NSLog(@"sina user id == %@", [(WBAuthorizeResponse*)response userID]);
                    [UConfig setSinaUId:[(WBAuthorizeResponse*)response userID]];
                    [UConfig setSinaNickName:@"已授权"];
                    
                    NSDate* time = [(WBAuthorizeResponse*)response expirationDate];
                    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    [UConfig setSinaExpireDate:[formatter stringFromDate:time]];
                    [[ShareManager SharedInstance] SinaWeiboUserInfo];

                    NSString *info = [NSString stringWithFormat:@"%d",sharedType];
                    [[UCore sharedInstance] newTask:U_UPDATE_OAUTHINFO data:info];

                    [[NSNotificationCenter defaultCenter] postNotificationName:KSinaWeiboOAuthSuc object:self];
                });
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:KShareFail object:self];
            }
        }//iskindofclass
    }else if ( response.statusCode == WeiboSDKResponseStatusCodeUserCancel
              || response.statusCode == WeiboSDKResponseStatusCodeSentFail)
    {
        if([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KShareFail object:self];
        }
    }
}


#pragma mark-----------腾讯微博-----------
//-(void)QQWeiboOAuth:(ShareContent *)shareObject
//{
//    sharedType = QQWbShared;
//    
//    if (shareObject != nil) {
//        tencentWBShareContent = [[ShareContent alloc]init];
//        tencentWBShareContent.title = shareObject.title;
//        tencentWBShareContent.msg = shareObject.msg;
//        tencentWBShareContent.imgUrls = shareObject.imgUrls;
//        tencentWBShareContent.hideUrl = shareObject.hideUrl;
//    }
//    
//    [qqWeibo loginWithDelegate:self andRootController:[UIApplication sharedApplication].keyWindow.rootViewController];
//}
//
//
////WeiboAuthDelegate
//- (void)DidAuthFinished:(WeiboApiObject *)wbobj
//{
//    if (tencentWBShareContent ==nil) {
//        [self QQWeiboSendMsg];
//    }else{
//        [self QQWeiboSendMsg:tencentWBShareContent];
//    }
//}
//- (void)DidAuthCanceled:(WeiboApiObject *)wbobj
//{
//    NSLog(@"qq weibo auth cancel by user");
//    [[NSNotificationCenter defaultCenter] postNotificationName:KShareFail object:self];
//}
//- (void)DidAuthFailWithError:(NSError *)error
//{
//    [[[iToast makeText:@"分享失败，请稍后重试！"] setGravity:iToastGravityCenter] show];
//}
//
//-(void)QQWeiboSendMsg
//{
//    if (!shareArray) {
//        shareArray = [NSKeyedUnarchiver unarchiveObjectWithFile:KShareContentsPath];
//    }
//    
//    sharedType = QQWbShared;
//    ShareContent* shareContent = [shareArray objectForKey:[NSString stringWithFormat:@"%d", sharedType]];
//    
//    NSString *msg = [NSString stringWithFormat:@"%@邀请码[%@]",shareContent.msg,[UConfig getInviteCode]];
//
//    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"json",@"format",
//                                   msg, @"content",
//                                   shareContent.imgUrls.lastObject, @"pic_url",
//                                   nil];
//    NSInteger res = [qqWeibo requestWithParams:params apiName:@"t/add_pic_url" httpMethod:@"POST" delegate:self];
//    if (res < 0) {
//        //没有安装腾讯微博客户端
//        [[[iToast makeText:@"分享失败，请稍后再试"] setGravity:iToastGravityCenter] show];
//    }
//}
//
//-(void)QQWeiboSendMsg:(ShareContent *)shareObject
//{
//    sharedType = QQWbShared;
//    
//    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"json",@"format",
//                                   shareObject.msg, @"content",
//                                   shareObject.imgUrls.lastObject, @"pic_url",
//                                   nil];
//    NSInteger res = [qqWeibo requestWithParams:params apiName:@"t/add_pic_url" httpMethod:@"POST" delegate:self];
//    if (res < 0) {
//        //没有安装腾讯微博客户端
//        [[[iToast makeText:@"分享失败，请稍后再试"] setGravity:iToastGravityCenter] show];
//    }
//}
//
//- (void)didReceiveRawData:(NSData *)data reqNo:(int)reqno
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:KShareSuccess object:self];
//    tencentWBShareContent = nil;
//}
//- (void)didFailWithError:(NSError *)error reqNo:(int)reqno
//{
//    NSString *str = [[NSString alloc] initWithFormat:@"refresh token error, errcode = %@",error.userInfo];
//    NSLog(@"didFailWithError error = %@", str);
//    if (tencentWBShareContent != nil) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:KShareFail object:self];
//    }
//    tencentWBShareContent = nil;
//}


#pragma mark-----------腾讯QQ互联-----------
-(void)tencentDidOAuth
{
    sharedType = QQOAuth;
    [UAppDelegate uApp].thirdAppType = EThirdAppCallbackType_Share_QQOAuth;
    NSArray* permissions = [NSArray arrayWithObjects:
                   kOPEN_PERMISSION_GET_USER_INFO,
                   kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                   kOPEN_PERMISSION_ADD_SHARE,
                   nil];

    [tencentOAuth authorize:permissions inSafari:NO];
}


//qq互联delegate
- (void)tencentDidLogin
{
    //登录成功
    [UConfig setTencentToken:tencentOAuth.accessToken];
    [UConfig setTencentUId:tencentOAuth.openId];
    [UConfig setTencentOpenId:tencentOAuth.openId];
    [UConfig setTencentNickName:@"已授权"];
    
    NSDate* time = tencentOAuth.expirationDate;
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [UConfig setTencentExpireDate:[formatter stringFromDate:time]];
    
    NSString *info = [NSString stringWithFormat:@"%d",QQMsg];
    [[UCore sharedInstance] newTask:U_UPDATE_OAUTHINFO data:info];

    [[NSNotificationCenter defaultCenter] postNotificationName:KTencentWeiboOAuthSuc object:self];
    
    //获取用户个人信息
    [tencentOAuth getUserInfo];
}

//非网络问题导致登录失败
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if(cancelled)
    {
        //用户取消
        NSLog(@"tencentDidNotLogin usercancel");
    }
    else
    {
        //非用户取消
        NSLog(@"tencentDidNotLogin error");
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KShareFail object:self];
}

//网络问题导致登录失败
- (void)tencentDidNotNetWork
{
    //无网络连接，要设置网络
    NSLog(@"tencentDidNotNetWork");
    [[NSNotificationCenter defaultCenter] postNotificationName:KShareFail object:self];
}

//获取个人信息回调
- (void)getUserInfoResponse:(APIResponse*) response {
    if (response.retCode == URLREQUEST_SUCCEED)
    {
        NSString* nickname = [response.jsonResponse objectForKey:@"nickname"];
        NSLog(@"%@", nickname);
        [UConfig setTencentNickName:nickname];
        
        NSString *info = [NSString stringWithFormat:@"%d",QQMsg];
        [[UCore sharedInstance] newTask:U_UPDATE_OAUTHINFO data:info];

        [[NSNotificationCenter defaultCenter] postNotificationName:KTencentWeiboOAuthSuc object:self];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"操作失败" message:[NSString stringWithFormat:@"%@", response.errorMsg] delegate:self cancelButtonTitle:@"我知道啦" otherButtonTitles: nil];
        [alert show];
    }
}


//登出授权
-(void)tencentDidSsoout
{
    [tencentOAuth logout:self];
}

/**
 * 退出登录的回调
 */
- (void)tencentDidLogout
{
    NSLog(@"退出登录成功");
}

-(void)tencentDidSendMsg
{
    if (!shareArray) {
        shareArray = [NSKeyedUnarchiver unarchiveObjectWithFile:KShareContentsPath];
    }
    
    sharedType = QQMsg;
    [UAppDelegate uApp].thirdAppType = EThirdAppCallbackType_Share_QQMsg;
    //2.分享一个有图片，有文本的内容
    ShareContent *QQContent = [shareArray objectForKey:[NSString stringWithFormat:@"%d", QQMsg]];
    NSString *description = [NSString stringWithFormat:@"%@邀请码[%@]",QQContent.msg,[UConfig getInviteCode]];
    
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:QQContent.hideUrl]
                                title:QQContent.title
                                description:description
                                previewImageURL:[NSURL URLWithString:QQContent.imgUrls.lastObject]];
    if ([QQApiInterface isQQInstalled]) {
        //将内容分享到qq
        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:newsObj];
        [QQApiInterface sendReq:req];
        //将内容分享到qzone
        [QQApiInterface SendReqToQZone:req];
    }
    else {
        //没有安装腾讯QQ客户端
        [[[iToast makeText:@"尚未安装腾讯QQ客户端"] setGravity:iToastGravityCenter] show];
    }
}

-(void)tencentDidSendMsgQZone
{
    if (!shareArray) {
        shareArray = [NSKeyedUnarchiver unarchiveObjectWithFile:KShareContentsPath];
    }
    
    sharedType = QQZone;
    [UAppDelegate uApp].thirdAppType = EThirdAppCallbackType_Share_QQMsg;
    //2.分享一个有图片，有文本的内容
    ShareContent *QQContent = [shareArray objectForKey:[NSString stringWithFormat:@"%d", QQMsg]];
    NSString *description = [NSString stringWithFormat:@"%@邀请码[%@]",QQContent.msg,[UConfig getInviteCode]];
    
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:QQContent.hideUrl]
                                title:QQContent.title
                                description:description
                                previewImageURL:[NSURL URLWithString:QQContent.imgUrls.lastObject]];
    if ([QQApiInterface isQQInstalled]) {
        //将内容分享到qq
        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:newsObj];
//        [QQApiInterface sendReq:req];
        //将内容分享到qzone
        [QQApiInterface SendReqToQZone:req];
    }
    else {
        //没有安装腾讯QQ客户端
        [[[iToast makeText:@"尚未安装腾讯QQ客户端"] setGravity:iToastGravityCenter] show];
    }
}


-(void)tencentDidSendMsg:(ShareContent *)shareObject
{
    sharedType = QQMsg;
    [UAppDelegate uApp].thirdAppType = EThirdAppCallbackType_Share_QQMsg;
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:shareObject.hideUrl]
                                title:shareObject.title
                                description:shareObject.msg
                                previewImageURL:[NSURL URLWithString:shareObject.imgUrls.lastObject]];
    
    if ([QQApiInterface isQQInstalled]) {
        //将内容分享到qq
        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:newsObj];
        [QQApiInterface sendReq:req];
        [QQApiInterface SendReqToQZone:req];
    }
    else {
        //没有安装腾讯QQ客户端
        [[[iToast makeText:@"尚未安装腾讯QQ客户端"] setGravity:iToastGravityCenter] show];
    }
}

- (void)onResp:(QQBaseResp *)resp
{
    if( 0 == resp.result.integerValue ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KShareSuccess object:self];
    }
    else{
        //除去成功以外的结果
        [[NSNotificationCenter defaultCenter] postNotificationName:KShareFail object:self];
    }
}


#pragma mark-----------微信好友-----------
-(void)weChatSceneSession
{
    sharedType = WXShared;
    [UAppDelegate uApp].thirdAppType = EThirdAppCallbackType_Share_Weixin;
    [self weChatSendMsg:WXSceneSession];
}

-(void)weChatSceneSession:(ShareContent *)shareObject
{
    sharedType = WXShared;
    [UAppDelegate uApp].thirdAppType = EThirdAppCallbackType_Share_Weixin;
    [self weChatSendMsg:WXSceneSession Object:shareObject];
}

//授权登陆
//微信授权-第一步-请求code
-(void)sendAuthRequest
{
    if ([WXApi isWXAppInstalled])
    {
        //构造SendAuthReq结构体
        sharedType = WXShared;
        [UAppDelegate uApp].thirdAppType = EThirdAppCallbackType_Share_Weixin;
        SendAuthReq* req =[[SendAuthReq alloc ] init];
        req.scope = @"snsapi_userinfo";
        req.state = UCLIENT_INFO;
        //第三方向微信终端发送一个SendAuthReq消息结构
        [WXApi safeSendReq:req];
    }else
    {
        //没有安装微信客户端
        [[[iToast makeText:@"尚未安装微信客户端"] setGravity:iToastGravityCenter] show];
    }
}

#pragma mark-----------微信朋友圈-----------
-(void)weChatSceneTimeline
{
    sharedType = WXCircleShared;
    [UAppDelegate uApp].thirdAppType = EThirdAppCallbackType_Share_Weixin;
    [self weChatSendMsg:WXSceneTimeline];
}

-(void)weChatSceneTimeline:(ShareContent *)shareObject
{
    sharedType = WXCircleShared;
    [UAppDelegate uApp].thirdAppType = EThirdAppCallbackType_Share_Weixin;
    [self weChatSendMsg:WXSceneTimeline Object:shareObject];
}

-(void)weChatSendMsg:(int) scene
{
    if ([WXApi isWXAppInstalled]) {
        //media
        if (!shareArray) {
            shareArray = [NSKeyedUnarchiver unarchiveObjectWithFile:KShareContentsPath];
        }
        ShareContent *wxChatContent = [shareArray objectForKey:[NSString stringWithFormat:@"%d", sharedType]];
    
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = wxChatContent.title;
        message.description = [NSString stringWithFormat:@"%@邀请码[%@]",wxChatContent.msg,[UConfig getInviteCode]];
        
        NSString* imgurl = wxChatContent.imgUrls.lastObject;
        NSURL* url = [NSURL URLWithString:imgurl];
        NSData* data = [[NSData alloc]initWithContentsOfURL:url];
        UIImage* img = [[UIImage alloc]initWithData:data];
        [message setThumbImage:img];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = wxChatContent.hideUrl;
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = scene;
        NSInteger res = [WXApi sendReq:req];
        NSLog(@"sendMessageToWXReq res = %ld", res);
    }
    else {
        //没有安装微信客户端
        [[[iToast makeText:@"尚未安装微信客户端"] setGravity:iToastGravityCenter] show];
    }
    
}

-(void)weChatSendMsg:(int) scene Object:(ShareContent *)shareObject
{
    if ([WXApi isWXAppInstalled]) {
        //media
    
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = shareObject.title;
        message.description = shareObject.msg;
        
        NSString* imgurl = shareObject.imgUrls.lastObject;
        NSURL* url = [NSURL URLWithString:imgurl];
        NSData* data = [[NSData alloc]initWithContentsOfURL:url];
        UIImage* img = [[UIImage alloc]initWithData:data];
        [message setThumbImage:img];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = shareObject.hideUrl;
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = scene;
        [WXApi sendReq:req];
    }
    else {
        //没有安装微信客户端
        [[[iToast makeText:@"尚未安装微信客户端"] setGravity:iToastGravityCenter] show];
    }
    
}

@end
