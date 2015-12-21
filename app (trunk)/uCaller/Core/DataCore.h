//
//  DataCore.h
//  uCaller
//
//  Created by thehuah on 13-1-29.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPManager.h"
#import "CoreBase.h"

@interface DataCore : CoreBase<HTTPManagerControllerDelegate>

+(DataCore *)sharedInstance;

-(void)sendMsg:(NSString *)content Number:(NSString *)uNumber;//模拟发送消息

@property(assign ,nonatomic)BOOL httpFinish;

@end
