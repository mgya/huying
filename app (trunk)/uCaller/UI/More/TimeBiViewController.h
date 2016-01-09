//
//  TimeBiViewController.h
//  uCaller
//
//  Created by wangxiongtao on 15/7/29.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "IAPObserver.h"
#import "HTTPManager.h"


//时长和应币
@interface TimeBiViewController : BaseViewController<HTTPManagerControllerDelegate,IAPDelegate,UITableViewDataSource,UITableViewDelegate>


- (id)initWithTitle:(NSString *)title;

@end
