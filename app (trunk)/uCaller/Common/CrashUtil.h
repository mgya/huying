//
//  CrashUtil.h
//  uCaller
//
//  Created by thehuah on 13-4-4.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashUtil : NSObject

+(void)registerCrashHandler;
+(void)reportCrash:(NSString *)info;

@end
