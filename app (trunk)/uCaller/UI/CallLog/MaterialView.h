//
//  MaterialView.h
//  uCaller
//
//  Created by 张新花花花 on 15/6/18.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallLogViewController.h"

@protocol CallLogDelegate <NSObject>

@optional

-(void)onInfoClicked:(UContact*)contact tag:(NSInteger)tag number:(NSString *)number;
-(void)onCallLogClicked:(CallLog *)contact;
-(void)onCopyClicked:(NSString*)num;


@end

@interface MaterialView : UIView

@property (nonatomic,UWEAK) id<CallLogDelegate> delegate;

-(void)setCal:(CallLog *)callLog;

@end
