//
//  ReturnDelegate.h
//  uCaller
//
//  Created by 崔远方 on 14-4-2.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReturnDelegate <NSObject>
-(void)returnLastPage;
-(void)modifiedFinished;
-(void)returnLastPage:(NSDictionary *)userInfo;
//-(void)goRegisterViewController:(NSString *)number;
//-(void)resetLoginNumber:(NSString *)number;
@end
