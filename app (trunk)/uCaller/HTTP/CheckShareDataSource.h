//
//  CheckShareDataSource.h
//  uCaller
//
//  Created by 崔远方 on 14-5-15.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"
#import "UDefine.h"

@interface CheckShareData : NSObject<NSCoding>

@property(nonatomic,assign)BOOL     isShare;//是否分享
@property(nonatomic,strong)NSString *title;//分享标题
@property(nonatomic,strong)NSString *finishedTip;//已完成提示
@property(nonatomic,strong)NSString *failedTip;//未完成提示

-(void)initDefaultData:(SharedType) shareType;

@end


@interface CheckShareDataSource : HTTPDataSource

+(CheckShareDataSource *)sharedInstance;
+(void)clean;

@property(nonatomic,assign)BOOL                 isFinished;
@property(nonatomic,strong)NSMutableDictionary  *shareDictionary;

@end
