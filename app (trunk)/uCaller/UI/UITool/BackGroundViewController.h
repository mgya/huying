//
//  BackGroundViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-6-25.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TouchDelegate <NSObject>

-(void)viewTouched;

@end

@interface BackGroundViewController : UIViewController

@property(nonatomic,assign) id<TouchDelegate> touchDelegate;

@end
