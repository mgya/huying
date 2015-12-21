//
//  CoreBase.m
//  uCaller
//
//  Created by thehuah on 13-3-24.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "CoreBase.h"

@implementation CoreBase

@synthesize delegate;

-(id)init
{
    self = [super init];
    if(self)
    {
        [self startNewThread];
    }
    return self;
}

-(void)dealloc
{
    [self stopThread];
}

-(void)startNewThread
{
	[NSThread detachNewThreadSelector:@selector(runThread) toTarget:self withObject:nil];
}

-(void)runThread
{
	@autoreleasepool {
        
        coreThread = [NSThread currentThread];
        
        coreRunLoop = CFRunLoopGetCurrent();
        
        CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
        CFRunLoopSourceRef src = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), src, kCFRunLoopDefaultMode);
        
        isRunning = YES;
        while (isRunning) {
            CFRunLoopRun();
        }
        
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), src, kCFRunLoopDefaultMode);
        CFRelease(src);
	}
}

-(void)stopThread
{
    isRunning = NO;
    CFRunLoopStop(coreRunLoop);
    
}

-(void)addCallLog:(id)callLog
{
    int i = 0;
    i++;
    //[callLogManager addCalllog:callLog];
}

-(void)perform:(SEL)selector
{
    [self performSelector:selector onThread:coreThread withObject:nil waitUntilDone:NO];
}

-(void)perform:(SEL)selector withData:(id)data
{
    [self performSelector:selector onThread:coreThread withObject:data waitUntilDone:NO];
}

-(BOOL)doTask:(CoreTask)task
{
    return NO;
}

-(BOOL)doTask:(CoreTask)task data:(id)data
{
    return NO;
}

-(BOOL)doTask:(CoreTask)task async:(BOOL)async
{
    return NO;
}

-(BOOL)doTask:(CoreTask)task async:(BOOL)async data:(id)data
{
    return NO;
}


@end
