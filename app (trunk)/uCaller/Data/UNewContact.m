//
//  UNewContact.m
//  uCaller
//
//  Created by thehuah on 14-4-28.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "UNewContact.h"
#import "Util.h"

@implementation UNewContact

@synthesize type;
@synthesize status;
@synthesize time;
@synthesize name;
@synthesize uNumber;
@synthesize pNumber;
@synthesize info;
@synthesize showTime;

-(id)init
{
    self = [super init];
    if(self)
    {
        type = NEWCONTACT_RECOMMEND;
        status = STATUS_NONE;
        name = @"";
        uNumber = @"";
        pNumber = @"";
        info = @"";
        time = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

-(NSString *)showTime
{
    NSString *strTime = [Util getShowTime:time];
    return strTime;
}

-(BOOL)matchUNumber:(NSString *)number
{
    if([Util isEmpty:number])
        return NO;
    if([uNumber isEqualToString:number])
        return YES;
    return NO;
}

-(NSString *)name
{
    if([Util isEmpty:name])
    {
        return uNumber;
    }
    return name;
}


@end
