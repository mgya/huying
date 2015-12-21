//
//  UAppDelegate.h
//  uCaller
//
//  Created by 崔远方 on 14-3-7.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDefine.h"
#import "WXApi.h"
#import "HTTPManager.h"
#import <BaiduMapAPI_Map/BMKMapView.h>


@class HTTPManager;
@class NoticeViewController;
@class TabBarViewController;
@class CTCallCenter;
@class MainViewController;
@class SideMenuViewController;

typedef enum _EThirdAppCallbackType
{
    EThirdAppCallbackType_Unknow = 0,
    EThirdAppCallbackType_Share_SinaWeibo,//SinaWbShared
//    EThirdAppCallbackType_Share_QQWeibo,//QQWbShared
    EThirdAppCallbackType_Share_QQOAuth,//QQOAuth
    EThirdAppCallbackType_Share_QQMsg,//QQMsgShared, include msg and qqzone
    EThirdAppCallbackType_Share_Weixin,//WXShared or WXCircleShared
    EThirdAppCallbackType_AliPay,//支付宝支付
    EThirdAppCallbackType_WXPay//微信支付
//    EThirdAppCallbackType_//银联支付
}EThirdAppCallbackType;

@protocol GlobalDelegate <NSObject>

@optional

-(void)onEnterBackground;
-(void)onResignActive;

@end

@interface UAppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate,HTTPManagerControllerDelegate,BMKGeneralDelegate>
{
    NoticeViewController *noticeViewController;
}

@property (strong,nonatomic) UIWindow *window;

@property (nonatomic,UWEAK) id<GlobalDelegate> gDelegate;

@property (nonatomic,unsafe_unretained) UIBackgroundTaskIdentifier bgTaskIdentifier;

@property (nonatomic,assign) BOOL inCalling;

@property (nonatomic,assign) BOOL inRecord;

@property(nonatomic,strong) NSDictionary *imageDict;

@property(nonatomic,assign)EThirdAppCallbackType thirdAppType;

@property(nonatomic,strong)MainViewController *rootViewController;

+(UAppDelegate *)uApp;

-(BOOL)networkOK;
-(void)tryLogin;
-(void)reLogin;
-(void)logout;
-(void)quit;

-(void)onCallEnd;
-(void)showMainView;
-(void)showLoginView:(BOOL)animation;

-(void)startRing;
-(void)stopRing;

-(void)getNoticeMsg;

@end
