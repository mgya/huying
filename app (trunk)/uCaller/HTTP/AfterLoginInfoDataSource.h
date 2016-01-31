//
//  AfterLoginInfoDataSource.h
//  uCaller
//
//  Created by HuYing on 15-1-6.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"


@interface AfterLoginInfoData :NSObject

@property (nonatomic,strong) NSString *signRuleUrl;
@property (nonatomic,strong) NSString *qiangPiaoHelpUrl;


+(AfterLoginInfoData *)sharedInstance;

@end

@interface AfterLoginInfoDataSource : HTTPDataSource

@property (nonatomic,strong) NSString *leaveCallMsg;

@end
