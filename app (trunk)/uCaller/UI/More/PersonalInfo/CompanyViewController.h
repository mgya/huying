//
//  CompanyViewController.h
//  uCaller
//
//  Created by HuYing on 15-3-17.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"

@protocol EditCompanyDelegate <NSObject>

-(void)onCompanyUpdate:(NSString *)company;

@end

@interface CompanyViewController : BaseViewController<UITextFieldDelegate>

@property(nonatomic,weak) id<EditCompanyDelegate>delegate;

@end
