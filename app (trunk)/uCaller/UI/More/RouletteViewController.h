//
//  RouletteViewController.h
//  uCaller
//
//  Created by HuYing on 15-1-21.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "TellFriendsViewController.h"

@interface RouletteViewController : BaseViewController<UIWebViewDelegate,TellFriendsVCDelegate>

@property (nonatomic,strong) NSString *rouletteUrl;
@property BOOL needWXAuth;//是否需要微信授权

@end
