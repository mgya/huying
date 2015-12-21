//
//  ActivitytipDataSource.h
//  uCaller
//
//  Created by HuYing on 15-1-16.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface ActivityTipData : NSObject

@property (nonatomic,strong) NSString *titleStr;
@property (nonatomic,strong) NSString *contentStr;
@property (nonatomic,strong) NSString *imgUrlStr;
@property (nonatomic,strong) NSString *hideUrlStr;

+(ActivityTipData *)sharedInstance;

@end

@interface ActivitytipDataSource : HTTPDataSource

@property (nonatomic,strong) NSString *titleStr;
@property (nonatomic,strong) NSString *contentStr;
@property (nonatomic,strong) NSString *imgUrlStr;
@property (nonatomic,strong) NSString *hideUrlStr;

@end
