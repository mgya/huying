//
//  ContactCellDelegate.h
//  uCalling
//
//  Created by changzheng-Mac on 13-3-15.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UContact.h"
#import "CallLog.h"

@protocol CallLogDelegate<NSObject>

@optional
-(void)callLogCellClicked:(CallLog *)callLog;
-(void)callLogCellDeleted:(CallLog *)callLog;
-(void)callLogTableBeginEdit;
-(void)callLogTableEndEdit;
-(void)callLogTableTouchEnd;
-(void)callDirectly:(CallLog *)callLog;
-(void)clearNumber;
//-(void)keyboard:(NSInteger)tag;
-(void)onInfoClicked:(UContact*)contact tag:(NSInteger)tag number:(NSString*)num;
-(void)onCallLogClicked:(CallLog *)contact;
-(void)onCopyClicked:(NSString*)num;

@end
