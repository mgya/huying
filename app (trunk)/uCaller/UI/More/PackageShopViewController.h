//
//  PackageShopViewController.h
//  uCaller
//
//  Created by wangxiongtao on 15/7/27.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "HTTPManager.h"
#import "IAPObserver.h"
#import "WareTableViewCell.h"


//套餐商店
@interface PackageShopViewController : BaseViewController<HTTPManagerControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,IAPDelegate,WareTableDelegate>

@end
