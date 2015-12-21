//
//  BeforeLoginInfoDataSource.m
//  uCaller
//
//  Created by admin on 14/12/17.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BeforeLoginInfoDataSource.h"

@implementation BeforeLoginInfoDataSource
@synthesize totalDurationValue;
@synthesize taskArray;
@synthesize pesDomainArray;
@synthesize umpDomainArray;

static BeforeLoginInfoDataSource * sharedInstance = nil;
+(BeforeLoginInfoDataSource *)sharedInstance
{
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[BeforeLoginInfoDataSource alloc] init];
        }
    }
    return sharedInstance;
}

-(id)init
{
    if (self = [super init]) {
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
     <key>taskduration</key>
     <value>281</value>
     <items>
     <item>
     <key>1</key>
     <value>5</value>
     </item>
     <item>
     <key>2</key>
     <value>10</value>
     </item>
     <item>
     <key>3</key>
     <value>15</value>
     </item>
     <item>
     <key>4</key>
     <value>100</value>
     </item>
     <item>
     <key>5</key>
     <value>10</value>
     </item>
     <item>
     <key>6</key>
     <value>10</value>
     </item>
     <item>
     <key>7</key>
     <value>10</value>
     </item>
     <item>
     <key>8</key>
     <value>10</value>
     </item>
     <item>
     <key>9</key>
     <value>10</value>
     </item>
     <item>
     <key>10</key>
     <value>10</value>
     </item>
     <item>
     <key>12</key>
     <value>10</value>
     </item>
     <item>
     <key>14</key>
     <value>100</value>
     </item>
     <item>
     <key>15</key>
     <value>5</value>
     </item>
     </items>
     </item>
     
     <domain>
     <key>pesaddress</key>
     <items>
     <item>
     <host>http://pes.yxhuying.com</host>
     <port>9999</port>
     </item>
     <item>
     <host>http://pes.yxhuying.cn</host>
     <port>780</port>
     </item>
     <item>
     <host>http://pes.yxhuying.cn</host>
     <port>560</port>
     </item>
     </items>
     </domain>
     <domain>
     <key>umpaddress</key>
     <items>
     <item>
     <host>hcp.yxhuying.com</host>
     <port>1800</port>
     </item>
     </items>
     </domain>
     </root>
     */
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
    
    NSArray *rspItems = [rspElement elementsForName:@"item"];
    if (rspItems.count <= 0) {
        _bParseSuccessed = NO;
        return ;
    }
    
    for (DDXMLElement *rspItem in rspItems) {
        
        totalDurationValue = [rspItem elementForName:@"value"].stringValueAsNSInteger;
        DDXMLElement *taskItems = [rspItem elementForName:@"items"];
        if (taskItems == nil) {
            return ;
        }
        
        NSArray *items = [taskItems elementsForName:@"item"];
        if (items.count <= 0) {
            return ;
        }
        for (DDXMLElement *taskItem in items) {
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[taskItem elementForName:@"key"].stringValue, @"key", [taskItem elementForName:@"value"].stringValue, @"value", nil];
            [taskArray addObject:dic];
        }
    }
    
    
    NSArray *domainElements = [rspElement elementsForName:@"domain"];
    for (DDXMLElement *doaminItem in domainElements) {
        NSString *strKey = [doaminItem elementForName:@"key"].stringValue;
        
        DDXMLElement *taskItems = [doaminItem elementForName:@"items"];
        if (taskItems == nil) {
            return ;
        }
        
        NSArray *items = [taskItems elementsForName:@"item"];
        if (items.count <= 0) {
            return ;
        }
        
        for (DDXMLElement *taskItem in items) {
            
            NSString *strDomain = [NSString stringWithFormat:@"%@%@", [taskItem elementForName:@"host"], [taskItem elementForName:@"port"]];
            if ([strKey isEqualToString:@"pesaddress"]) {
                [pesDomainArray addObject:strDomain];
            }
            else if([strKey isEqualToString:@"umpaddress"]){
                [umpDomainArray addObject:strDomain];
            }
        }
    }
    
}
@end
