//
//  TaskInfoTimeDataSource.m
//  uCaller
//
//  Created by admin on 14-11-25.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "TaskInfoTimeDataSource.h"

@implementation TaskInfoData : NSObject

@end


@implementation TaskInfoTimeDataSource

@synthesize taskArray;
static TaskInfoTimeDataSource *sharedInstance = nil;

+(TaskInfoTimeDataSource *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[TaskInfoTimeDataSource alloc] init];
        }
    }
    return sharedInstance;
}

-(id)init
{
    if (self = [super init])
    {
        taskArray = [[NSMutableArray alloc] init];
    }
    return self;
}


-(void)parseData:(NSString*)strXml
{
    /*
     <root>
     <result>1</result>
     <item>
     <type>1</type>
     <subtype>1</subtype>
     <isfinish>0</isfinish>
     <duration>10</duration>
     </item>
     ...
     </root>
     */
    
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:strXml options:0 error:nil];
    
    DDXMLElement *rspElement = [doc rootElement];
    if (rspElement == nil)
    {
        _bParseSuccessed = NO;
        return;
    }
    
    DDXMLElement *resultElement = [rspElement elementForName:@"result"];
    if (resultElement == nil)
    {
        _bParseSuccessed = NO;
        return;
    }
    
    _bParseSuccessed = YES;
    _nResultNum = [resultElement.stringValue integerValue];
    
    
    [taskArray removeAllObjects];
    NSArray *itemArray = [rspElement nodesForXPath :@"item" error:nil];
    for (DDXMLElement *itemObj in itemArray) {
        
        TaskInfoData *taskInfo = [[TaskInfoData alloc] init];
        
        taskInfo.type = [[itemObj elementForName:@"type"].stringValue integerValue];
        taskInfo.subtype = [[itemObj elementForName:@"subtype"].stringValue integerValue];
        taskInfo.isfinish = [[itemObj elementForName:@"isfinish"].stringValue boolValue];
        taskInfo.duration = [[itemObj elementForName:@"duration"].stringValue integerValue];
        [taskArray addObject:taskInfo];
    }
    
}

@end
