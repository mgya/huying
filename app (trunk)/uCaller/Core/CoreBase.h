//
//  CoreBase.h
//  uCaller
//
//  Created by thehuah on 13-3-24.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDefine.h"
#import "CoreType.h"

@protocol CoreDelegate <NSObject>

@optional
-(void)taskDone:(CoreTask)task data:(id)data;
-(void)postCoreNotification:(NSString *)name object:(id)object info:(NSDictionary *)info;

@end

@interface CoreBase : NSObject
{
    NSThread *coreThread;
    CFRunLoopRef coreRunLoop;
    BOOL isRunning;
    U__WEAK id<CoreDelegate> delegate;
    
}

@property (nonatomic,UWEAK) id<CoreDelegate> delegate;

-(void)doTask:(CoreTask)task;
-(void)doTask:(CoreTask)task data:(id)data;
-(void)doTask:(CoreTask)task async:(BOOL)async;
-(void)doTask:(CoreTask)task async:(BOOL)async data:(id)data;

-(void)perform:(SEL)selector;
-(void)perform:(SEL)selector withData:(id)data;

@end
