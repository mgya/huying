//
//  ShareManager.h
//  uCaller
//
//  Created by admin on 14-10-21.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "WeiboApi.h"
#import "TencentOAuth.h"
#import "QQApiInterface.h"
#import "UDefine.h"
#import "HTTPManager.h"
#import "WXApi.h"
#import "TencentSDK/TencentOpenAPI.framework/Headers/TencentOAuth.h"

@class ShareContent;
@interface ShareManager : NSObject<WeiboSDKDelegate, WBHttpRequestDelegate, TencentSessionDelegate,QQApiInterfaceDelegate, HTTPManagerControllerDelegate>

//@property (nonatomic,strong) WeiboApi*              qqWeibo;
@property (nonatomic,strong) TencentOAuth*          tencentOAuth;
@property (nonatomic,assign, readonly) SharedType   sharedType;


+(ShareManager*) SharedInstance;
-(void)RegThirdSDK;

//sina weibo
-(void)SinaWeiboOAuth;
-(void)SinaWeiboSendMsg;
-(void)SinaWeiboSsoOut;
-(void)SinaWeiboUserInfo;

-(void)SinaWeiboSendMsg:(ShareContent *)shareObject;

//tencent
-(void)tencentDidOAuth;
-(void)tencentDidSsoout;
-(void)tencentDidSendMsg;
-(void)tencentDidSendMsgQZone;
-(void)tencentDidSendMsg:(ShareContent *)shareObject;

//qq weibo
//-(void)QQWeiboOAuth:(ShareContent *)shareObject;

//wechat
-(void)weChatSceneSession;
-(void)weChatSceneTimeline;
-(void)sendAuthRequest;

-(void)weChatSceneSession:(ShareContent *)shareObject;
-(void)weChatSceneTimeline:(ShareContent *)shareObject;

@end
