//
//  BlackViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-4-22.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HTTPManager.h"

@interface BlackListOperatorViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,HTTPManagerControllerDelegate>
{
    NSMutableArray *dataArray;
}

@property(nonatomic,strong) NSString *uNumber;
@property(nonatomic,strong) NSString *pNumber;
@end
