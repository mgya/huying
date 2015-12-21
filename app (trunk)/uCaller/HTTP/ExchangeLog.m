//
//  ExchangeLog.m
//  uCaller
//
//  Created by admin on 14-11-27.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "ExchangeLog.h"
#import "UConfig.h"

#define KAccountPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [UConfig getUID]]]
#define KExchangeLogsFile @"ExchangeLogs.arc"

@implementation ExchangeItem

@synthesize name;
@synthesize type;
@synthesize duration;
@synthesize expiredate;


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeInteger:type forKey:@"type"];
    [aCoder encodeInteger:duration forKey:@"duration"];
    [aCoder encodeInt64:expiredate forKey:@"expiredate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ([super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.type = [aDecoder decodeInt32ForKey:@"type"];
        self.duration = [aDecoder decodeInt32ForKey:@"duration"];
        self.expiredate = [aDecoder decodeInt64ForKey:@"expiredate"];
    }
    return self;
}

@end

@implementation ExchangeLog

@synthesize logs;

-(id)init
{
    if (self = [super init]) {
        NSString* filePath = [NSString stringWithFormat:@"%@/%@", KAccountPath, KExchangeLogsFile];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            logs = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        }
        else {
            logs = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    /*
     <root>
     <result>1</result>
     <item>
     <name></name>
     <type>1</type>
     <duration>赠送时长</duration>
     <expiredate>有效期时间戳</expiredate>
     </item>
     ...
     </root>
     */
    
//    DDXMLElement *rspElement = [doc rootElement];
//    if (rspElement == nil)
//    {
//        _bParseSuccessed = NO;
//        return;
//    }
//    DDXMLElement *resultElement = [rspElement elementForName:@"result"];
//    if (resultElement == nil)
//    {
//        _bParseSuccessed = NO;
//        return;
//    }
//    _nResultNum = [resultElement.stringValue integerValue];
    
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:strXml options:0 error:nil];
    
    DDXMLElement *rootElement = [doc rootElement];
    if (rootElement == nil) {
        _bParseSuccessed = NO;
        return ;
    }
    
    DDXMLElement *resultElement = [rootElement elementForName:@"result"];
    if (resultElement == nil) {
        _bParseSuccessed = NO;
        return ;
    }
    
    _bParseSuccessed = YES;
    _nResultNum = [resultElement.stringValue integerValue];
    
    
    NSArray* itemArray = [rootElement elementsForName:@"item"];
    if (itemArray == nil) {
        return ;
    }
    for (DDXMLElement *itemElement in itemArray) {
        ExchangeItem * exchangeItem = [[ExchangeItem alloc] init];
        exchangeItem.name = [itemElement elementForName:@"name"].stringValue;
        exchangeItem.type = [itemElement elementForName:@"type"].stringValue.integerValue;
        exchangeItem.duration = [itemElement elementForName:@"duration"].stringValue.integerValue;
        exchangeItem.expiredate = [itemElement elementForName:@"expiredate"].stringValue.longLongValue;
        [logs addObject:exchangeItem];
    }
}

@end
