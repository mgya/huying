//
//  ULogData.m
//  uCaller
//
//  Created by thehuah on 13-3-2.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "ULogData.h"
#import "Util.h"
#import "UConfig.h"

@implementation ULogData

@synthesize logID;
@synthesize logContactUID;
@synthesize number;
@synthesize contact;
@synthesize type;
@synthesize time;
@synthesize duration;
@synthesize numberLogCount;
@synthesize contactLogCount;
@synthesize showTime;


-(id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code here.
        [self makeID];
        numberLogCount = 1;
        contactLogCount = 1;
    }
    
    return self;
}

-(id)initWith:(ULogData *)log
{
    self = [super init];
    if(self)
    {
        logID = log.logID;
        logContactUID = log.logContactUID;
        number = log.number;
        contact = log.contact;
        type = log.type;
        time = log.time;
        duration = log.duration;
        numberLogCount = log.numberLogCount;
        contactLogCount = log.contactLogCount;
    }
    return self;
}

-(void)makeID
{
    double curTime = [[NSDate date] timeIntervalSince1970] * 1000.0f;
    logID = [NSString stringWithFormat:@"%@-%f",[UConfig getUID],curTime];
}

-(void)setNumber:(NSString *)aNumber
{
    number = [Util getValidNumber:aNumber];
}

-(NSString *)showTime
{
    NSString *strTime = [Util getShowTime:time];
    return strTime;
}

-(BOOL)matchUid:(NSString *)aUid
{
    if ([Util isEmpty:aUid]) {
        return NO;
    }
    if ([Util matchString:aUid and:self.logContactUID]) {
        return YES;
    }
    return NO;
}

-(BOOL)matchNumber:(NSString *)aNumber
{
    if([Util isEmpty:number] || [Util isEmpty:aNumber])
        return NO;
    if([Util matchNumber:number with:aNumber])
        return YES;
    return NO;
}

-(BOOL)matchNumber:(NSString *)aNumber withContact:(BOOL)matchContact
{
    if([self matchNumber:aNumber])
        return YES;
    if(matchContact)
    {
        if((contact != nil) && [contact matchNumber:aNumber])
            return YES;
    }
    return NO;
}

-(BOOL)matchNumber:(NSString *)aNumber orContact:(UContact *)aContact
{
    if([self matchNumber:aNumber])
        return YES;
    if(aContact != nil)
    {
        return [aContact matchNumber:number];
    }
    return NO;
}

@end
