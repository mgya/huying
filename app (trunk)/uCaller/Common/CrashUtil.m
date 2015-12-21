//
//  CrashUtil.m
//  uCaller
//
//  Created by thehuah on 13-4-4.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "CrashUtil.h"
#import "UDefine.h"
#import "HTTPManager.h"
#import "XAlert.h"
#include <execinfo.h>

void handleStackInfo(int sig, siginfo_t *info, void *context)
{

    NSMutableString *stackInfo = [[NSMutableString alloc] init];
    [stackInfo appendFormat:@"Exception reason:Signal %d was raised\n",sig];
    [stackInfo appendString:@"Call Stack:\n"];
    void* callstack[128];
    int i, frames = backtrace(callstack, 512);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = 0; i < frames; ++i) {
        [stackInfo appendFormat:@"%s\n", strs[i]];
    }
    
    [CrashUtil reportCrash:stackInfo];
    
    exit(0);
}

void UncaughtExceptionHandler(NSException *exception)
{
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *info = [NSString stringWithFormat:@"Uncaught Exception:%@<br>Exception reason:%@<br>%@",name,reason,[arr componentsJoinedByString:@"<br>"]];
    
    [CrashUtil reportCrash:info];
    
    exit(0);
}

@implementation CrashUtil

+(void)registerCrashHandler
{
    NSUncaughtExceptionHandler *ueh ;
    ueh = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    struct sigaction mySigAction;
    mySigAction.sa_sigaction = handleStackInfo;
    mySigAction.sa_flags = SA_SIGINFO;
    
    sigemptyset(&mySigAction.sa_mask);
    sigaction(SIGQUIT, &mySigAction, NULL);
    sigaction(SIGILL , &mySigAction, NULL);
    sigaction(SIGTRAP, &mySigAction, NULL);
    sigaction(SIGABRT, &mySigAction, NULL);
    sigaction(SIGEMT , &mySigAction, NULL);
    sigaction(SIGFPE , &mySigAction, NULL);
    sigaction(SIGBUS , &mySigAction, NULL);
    sigaction(SIGSEGV, &mySigAction, NULL);
    sigaction(SIGSYS , &mySigAction, NULL);
    sigaction(SIGPIPE, &mySigAction, NULL);
    sigaction(SIGALRM, &mySigAction, NULL);
    sigaction(SIGXCPU, &mySigAction, NULL);
    sigaction(SIGXFSZ, &mySigAction, NULL);
}

+(void)reportCrash:(NSString *)info
{
    [HTTPManager postCrashReport:info];
    
    NSUInteger answer = [XAlert queryWith:@"抱歉,呼应客户端出现了异常,希望您可以发送崩溃信息给我们,非常感谢！" button1:@"取消" button2:@"确定" wait:5];

	if ((answer == 1) || (answer == kCFRunLoopRunTimedOut))
    {
        //[HttpManager postCrashReport:info];
    }
}

@end
