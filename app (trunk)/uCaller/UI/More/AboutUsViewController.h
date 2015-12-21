//
//  AboutUsViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-4-2.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "ReturnDelegate.h"

@interface AboutUsViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,assign) id<ReturnDelegate>delegate;

@end
