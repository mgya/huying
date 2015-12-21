//
//  AdsViewController.h
//  uCaller
//
//  Created by HuYing on 14-12-3.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "UDefine.h"
#import "ShareManager.h"
#import "TellFriendsViewController.h"

@interface AdsViewController : BaseViewController<UIWebViewDelegate,TellFriendsVCDelegate>

@property (nonatomic,strong) NSString *AdsUrlStr;


@end
