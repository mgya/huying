//
//  UsablebizDetailDataSource.m
//  uCaller
//
//  Created by 崔远方 on 14-4-30.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "UsablebizDetailDataSource.h"
#import "UCallsItem.h"

@implementation UsablebizDetailDataSource
@synthesize freeTime;
@synthesize payTime;
@synthesize freeArray;
@synthesize payArray;

-(id)init{
    if (self = [super init])
    {
        freeArray = [[NSMutableArray alloc] init];
        payArray = [[NSMutableArray alloc] init];
	}
	return self;
}


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
    
	DDXMLElement *freeTimeElement = [rspElement elementForName:@"freethreshold"];
    if (freeTimeElement == nil)
    {
       // return;
    }
    self.freeTime = freeTimeElement.stringValue;
    
    DDXMLElement *payTimeElement = [rspElement elementForName:@"paythreshold"];
    if(payTimeElement == nil)
    {
        //return;
    }
    self.payTime = payTimeElement.stringValue;
    
    //当前时间
    DDXMLElement *curTimeElement = [rspElement elementForName:@"current_time"];
    if(curTimeElement == nil)
    {
        return;
    }
     double curTime = [curTimeElement.stringValue doubleValue];
    
    NSLog(@"%lf",curTime);
    
    
    
    
    
    //没有时长数据说明是获取套餐
    if (freeTimeElement == nil && payTimeElement == nil) {
        NSArray* pakArray = [rspElement nodesForXPath:@"ware" error:nil];
        for (DDXMLElement *itemObj in pakArray)
        {
            UCallsItem *aItem = [[UCallsItem alloc] init];
            DDXMLElement *nameElement = [itemObj elementForName:@"name"];
            if (nameElement == nil)
            {
                continue;
            }
            aItem.uName = nameElement.stringValue;
            

            double compareTime;//到期时间
            DDXMLElement *expireElement = [itemObj elementForName:@"expiredate"];
            compareTime = [expireElement.stringValue doubleValue];
            
            NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:expireElement.stringValue.doubleValue/1000];
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            aItem.uExpireDate = [dateFormat stringFromDate:curDate];
            
            [payArray addObject:aItem];

        }
        
    }
    
    
    
    
    NSArray* itemArray = [rspElement nodesForXPath:@"ware" error:nil];
    for (DDXMLElement *itemObj in itemArray)
    {
        UCallsItem *aItem = [[UCallsItem alloc] init];
        DDXMLElement *nameElement = [itemObj elementForName:@"name"];
        if (nameElement == nil)
        {
            continue;
        }
        aItem.uName = nameElement.stringValue;
        
        DDXMLElement *timeElement = [itemObj elementForName:@"biz"];
        aItem.uTime = timeElement.stringValue;
        
        DDXMLElement *expireElement = [itemObj elementForName:@"expiredate"];
        aItem.compareStr = expireElement.stringValue;
        NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:expireElement.stringValue.doubleValue];
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        aItem.uExpireDate = [dateFormat stringFromDate:curDate];
        
        DDXMLElement *typeElement = [itemObj elementForName:@"type"];
        if([typeElement.stringValue isEqualToString:@"0"])
        {
            [freeArray addObject:aItem];
        }
        else if([typeElement.stringValue isEqualToString:@"1"])
        {
            [payArray addObject:aItem];
        }
    }
    NSComparator cmptr = ^(UCallsItem *obj1, UCallsItem *obj2)
    {
        if ([obj1.compareStr doubleValue] > [obj2.compareStr doubleValue])
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        else
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
    };
    [payArray sortUsingComparator:cmptr];
    [freeArray sortUsingComparator:cmptr];
}

@end
