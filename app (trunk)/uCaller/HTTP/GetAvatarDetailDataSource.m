//
//  GetAvatarDetailDataSource.m
//  uCaller
//
//  Created by admin on 15/1/7.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetAvatarDetailDataSource.h"
#import "UConfig.h"
#import "Util.h"

@implementation GetAvatarDetailDataSource
@synthesize photoData;

-(id)init{
    if (self = [super init]) {

    }
    return self;
}

-(void)parseHeader:(NSDictionary*)dicHeader Data:(NSData *)data;
{
    photoData = data;
    if (data != nil)
    {
        _bParseSuccessed = YES;
        _nResultNum = 1;
    }
    
}

@end
