//
//  CityViewController.h
//  uCaller
//
//  Created by HuYing on 15-3-18.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "HTTPManager.h"

@interface CityViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,HTTPManagerControllerDelegate>

@property (nonatomic,strong) NSString *provinceStr;
@property (nonatomic,strong) NSString *idStr;

@end
