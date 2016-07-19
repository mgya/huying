//
//  UCore.h
//  uCaller
//
//  Created by thehuah on 13-1-29.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreType.h"
#import "CoreBase.h"

@interface UCore : NSObject <CoreDelegate>

@property (nonatomic,assign) BOOL isOnline;
@property (nonatomic,assign) BOOL backGround;
@property (nonatomic,assign) BOOL startAd;
@property (nonatomic,strong) NSString *state;
@property (nonatomic,strong) NSString *safeState;
@property (nonatomic,strong) NSString *buySafeUrl;
@property (nonatomic,strong) NSString *recommended;
@property (nonatomic,assign) BOOL isIPV6;


+(UCore *)sharedInstance;

-(void)newTask:(CoreTask)task;
-(void)newTask:(CoreTask)task data:(id)data;

@end
