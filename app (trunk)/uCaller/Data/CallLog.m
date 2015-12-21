//
//  CallLog.m
//  uCaller
//
//  Created by thehuah on 13-3-2.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "CallLog.h"

#import "Util.h"
#import "UAdditions.h"

#import "DBManager.h"

@implementation CallLog

@synthesize group;
@synthesize showIndex;
@synthesize numberArea;
@synthesize showDuration;

-(id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code here.
        group = GROUP_OK;
		showIndex = INDEX_ALL;
    }
    
    return self;
}

-(id)initWith:(CallLog *)log
{
    self = [super initWith:log];
    if(self)
    {
        group = log.group;
        showIndex = log.showIndex;
        numberArea = log.numberArea;
    }
    return self;
}

-(void)setType:(int)aType
{
    type = aType;
    if(type == CALL_MISSED)
        group = GROUP_MISSED;
    else
        group = GROUP_OK;
}

-(void)setNumberArea:(NSString *)aNumberArea
{
    numberArea = aNumberArea;
    if([Util isEmpty:aNumberArea])
    {
        numberArea = [[DBManager sharedInstance] getAreaByNumber:number];
    }
}

-(BOOL)containNumber:(NSString *)aNumber
{
    if([Util isEmpty:aNumber])
        return NO;
    
    if((([Util isEmpty:number] == NO) && [number contain:aNumber]))
        return YES;
    
    return NO;
}

-(NSString *)showDuration
{
    NSString *callDuration;
    if (duration >= 3600)
    {
        long sec = duration % 3600;
        callDuration = [[NSString alloc] initWithFormat:@"%d小时%d分%d秒",
                        duration / 3600,
                        sec/60, sec%60];
    }
    else if(duration >= 60)
    {
        callDuration = [[NSString alloc]initWithFormat:@"%d分%d秒",
                        duration/60,
                        duration%60];
    }
    else
    {
        callDuration = [[NSString alloc]initWithFormat:@"%d秒",
                        duration];
    }
    
    return callDuration;
}

@end
