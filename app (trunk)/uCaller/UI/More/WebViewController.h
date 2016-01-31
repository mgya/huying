//
//  WebViewController.h
//  uCaller
//
//  Created by HuYing on 15/5/30.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "ShareManager.h"
#import "TellFriendsViewController.h"
#import "HTTPManager.h"

#import "UDefine.h"

#import "IAPObserver.h"

#define YINGBI @"huying:com.ucaller.YingBiOrDurationStore?isFeeStore=false"
#define TIME @"huying:com.ucaller.YingBiOrDurationStore?isFeeStore=true"
#define PACKAGE @"huying:com.ucaller.PackageStore"
#define BILL @"huying:com.ucaller.Recharge"
#define DURINFO @"huying:com.ucaller.AccountDuration"
#define TASK @"huying:com.ucaller.MoreTask"
#define SINGDETAI @"huying:com.ucaller.SignDetail"



@interface WebBackObject : NSObject

@property BOOL isBack;//是否回调
@property(nonatomic,strong) NSString *cmd;//回调函数名
@property(nonatomic,strong) NSMutableArray *paraMarr;//回调参数
@property id other;//扩展字段

@end


@interface WebViewController : BaseViewController<UIWebViewDelegate,TellFriendsVCDelegate,HTTPManagerControllerDelegate,IAPDelegate>

@property (nonatomic,strong) NSString *webUrl;
@property (nonatomic,assign) BOOL fromDismissModal;//dismissModal过来的。

@end
