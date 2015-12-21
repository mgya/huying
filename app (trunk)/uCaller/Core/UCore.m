//
//  UCore.m
//  uCaller
//
//  Created by thehuah on 13-1-29.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

/*
 应用Facade设计模式简化核心子系统的使用
 */

#import "UCore.h"
#import "UMPCore.h"
#import "DataCore.h"
#import "UAdditions.h"

@implementation UCore
{
    UMPCore *umpCore;
    DataCore *dataCore;
}

static UCore *sharedInstance = nil;

@synthesize isOnline;
@synthesize backGround;

+(UCore *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[UCore alloc] init];
        }
    }
	return sharedInstance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        isOnline = NO;
        backGround = NO;
        umpCore = [UMPCore sharedInstance];
        dataCore = [DataCore sharedInstance];
        dataCore.delegate = self;
    }
    return self;
}

-(BOOL)isOnline
{
    return umpCore.isOnline;
}

#pragma mark CoreDelegate Methods
-(void)taskDone:(CoreTask)task data:(id)data
{
}

-(void)postCoreNotification:(NSString *)name object:(id)object info:(NSDictionary *)info
{
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:name
                                                                        object:object
                                                                      userInfo:info];
}

#pragma mark task dispatcher

-(void)newTask:(CoreTask)task
{
    [umpCore doTask:task];
    [dataCore doTask:task];
}

-(void)newTask:(CoreTask)task data:(id)data
{
    [umpCore doTask:task data:data];
    [dataCore doTask:task data:data];
}

@end
