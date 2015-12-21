//
//  GameViewController.h
//  uCaller
//
//  Created by HuYing on 15/5/27.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"

@interface GameViewController : BaseViewController<UIWebViewDelegate>

@property (nonatomic,strong) NSString *gameUrl;

@end
