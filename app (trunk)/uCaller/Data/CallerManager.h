//
//  CallerManager.h
//  uCaller
//
//  Created by admin on 14-9-11.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallViewController.h"

@class UContact;

typedef enum{
    RequestCallerType_Unknow = 0
    ,RequestCallerType_Direct
    ,RequestCallerType_Callback
}RequestCallerType;

typedef enum
{
    ERequestController_Unknow = 0
    ,ERequestController_More
}RequestController;

typedef enum CallerManagerEvent
{
    Event_CalleeFinish
    ,Event_CancelAction
    ,Event_AddAreaCode
    ,Event_ClearNumber
}CallerManagerEvent;


@interface CallerManager : NSObject<UIActionSheetDelegate, UIAlertViewDelegate,CallViewControllerDelegate>

@property(nonatomic,assign) RequestController   requestController;

+(CallerManager *)sharedInstance;
-(void)Caller:(NSString*)callee Contact:(UContact *)contact ParentView:(UIViewController*) view Forced:(RequestCallerType)aType;
-(RequestCallerType)RequestCallerType;

@property(assign,nonatomic) BOOL callIn;//判断是否是打进来的电话。

@property(strong,nonatomic)  id mySelf;//保存打出的view指针

@end
