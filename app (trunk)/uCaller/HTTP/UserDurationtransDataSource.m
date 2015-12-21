//
//  UserDurationtransDataSource.m
//  uCaller
//
//  Created by wangxiongtao on 15/8/7.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "UserDurationtransDataSource.h"


@implementation DurationtransInfo

@synthesize timeLong;
@synthesize timeType;
@synthesize getTime;
@synthesize Invalid;

@end

@implementation UserDurationtransDataSource

@synthesize DurationtransList;


-(id)init{

    return self;
}

//解析月份的时长
-(void)parseData:(NSString*)strXml
{
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:strXml options:0 error:nil];
    
    DDXMLElement *rspElement = [doc rootElement];
    if (rspElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    
    DDXMLElement *resultElement = [rspElement elementForName:@"result"];
    if (resultElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    
    _bParseSuccessed = YES;
    _nResultNum = [resultElement.stringValue integerValue];
    if (_nResultNum != 1)
    {
        return;
    }
    
    NSArray* itemArray = [rspElement nodesForXPath:@"trans" error:nil];
    NSMutableArray *itemList = [[NSMutableArray alloc] initWithCapacity:[itemArray count]];
    

    for (DDXMLElement *itemObj in itemArray)
    {
        
        DurationtransInfo * durationtInfo = [[DurationtransInfo alloc]init];
        
       
        //类型
        DDXMLElement *source = [itemObj elementForName:@"source"];
        durationtInfo.timeType = source.stringValue;
        
        //获得时间
        DDXMLElement *create_time = [itemObj elementForName:@"create_time"];
        durationtInfo.getTime = create_time.stringValue;
        
        //时长
        DDXMLElement *duration = [itemObj elementForName:@"duration"];
        durationtInfo.timeLong = duration.stringValue;
        
        //过期时间
        DDXMLElement *expire_time = [itemObj elementForName:@"expire_time"];
        durationtInfo.Invalid = expire_time.stringValue;
        
        
        [itemList addObject:durationtInfo];
    }
    
    self.DurationtransList = itemList;

    
    
}

@end
