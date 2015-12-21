//
//  DataSource.m
//  Quaner
//
//  Created by cz on 11-7-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPResultParser.h"

#import "TZ_DDXML.h"

@implementation HTTPResultParser


+(NSInteger)parseResponse:(NSString *)strResponse
{
    TZ_DDXMLDocument *doc = [[TZ_DDXMLDocument alloc] initWithXMLString:strResponse options:0 error:nil];
	
	TZ_DDXMLElement *rspElement = [doc rootElement];
	if (rspElement == nil) {
		return -1;
	}
	
	TZ_DDXMLElement *resultElement = [rspElement elementForName:@"result"];
	if (resultElement == nil) {
		return -1;
	}
    
	NSInteger resultCode = [resultElement.stringValue integerValue];
    return resultCode;
}

+(HYUserInfoResult *)parseUserInfoResponse:(NSString*)strResponse
{
	TZ_DDXMLDocument *doc = [[TZ_DDXMLDocument alloc] initWithXMLString:strResponse options:0 error:nil];
	
	TZ_DDXMLElement *rspElement = [doc rootElement];
	if (rspElement == nil) {
		return nil;
	}
	
	TZ_DDXMLElement *resultElement = [rspElement elementForName:@"result"];
	if (resultElement == nil) {
		return nil;
	}
    
    HYUserInfoResult *registerResult = [[HYUserInfoResult alloc] init];
	registerResult.resultCode = [resultElement.stringValue integerValue];
    if (registerResult.resultCode != 1) {
        return registerResult;
    }
    
    TZ_DDXMLElement *isNewElement = [rspElement elementForName:@"isnew"];
    if(isNewElement == nil)
    {
        registerResult.isNew = YES;
    }
    else
    {
        if([isNewElement.stringValue isEqualToString:@"true"])
        {
            registerResult.isNew = YES;
        }
        else
        {
            registerResult.isNew = NO;
        }
    }
    
    TZ_DDXMLElement *numberElement = [rspElement elementForName:@"number"];
    if (numberElement == nil) {
        return registerResult;
    }
    
    registerResult.strNumber = numberElement.stringValue;
    
    TZ_DDXMLElement *nameElement = [rspElement elementForName:@"name"];
    if (nameElement == nil) {
        return registerResult;
    }
    
    registerResult.strPhone = nameElement.stringValue;
    
    TZ_DDXMLElement *uIdElement = [rspElement elementForName:@"uid"];
    if(uIdElement == nil)
    {
        return registerResult;
    }
    registerResult.strUID = uIdElement.stringValue;
    
    return registerResult;
}

+(HYPackageInfoResult *)parseWareInfoResponse:(NSString*)strResponse;
{
    TZ_DDXMLDocument *doc = [[TZ_DDXMLDocument alloc] initWithXMLString:strResponse options:0 error:nil];
	
	TZ_DDXMLElement *rspElement = [doc rootElement];
	if (rspElement == nil)
    {
		return nil;
	}
	
	TZ_DDXMLElement *resultElement = [rspElement elementForName:@"result"];
	if (resultElement == nil)
    {
		return nil;
	}
    
    HYPackageInfoResult *curItem = [[HYPackageInfoResult alloc] init];
	curItem.resultCode = [resultElement.stringValue integerValue];
    if (curItem.resultCode != 1)
    {
        return nil;
    }
    
	TZ_DDXMLElement *freeTimeElement = [rspElement elementForName:@"freethreshold"];
    if (freeTimeElement == nil)
    {
        return nil;
    }
    
    curItem.strFreeMinute = freeTimeElement.stringValue;
    
    //paythreshold
    TZ_DDXMLElement *payTimeElement = [rspElement elementForName:@"paythreshold"];
    if (payTimeElement == nil)
    {
        return nil;
    }
    
    curItem.strPayMinute = payTimeElement.stringValue;
    
    NSArray* itemArray = [rspElement nodesForXPath:@"ware" error:nil];
    
    for (TZ_DDXMLElement *itemObj in itemArray)
    {
        
        HYPackageInfo *aItem = [[HYPackageInfo alloc] init];
        TZ_DDXMLElement *nameElement = [itemObj elementForName:@"name"];
        if (nameElement == nil)
        {
            continue;
        }
        aItem.strName = nameElement.stringValue;
        
        TZ_DDXMLElement *timeElement = [itemObj elementForName:@"biz"];
        aItem.strTime = timeElement.stringValue;
        
        TZ_DDXMLElement *expireElement = [itemObj elementForName:@"expiredate"];
        NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:expireElement.stringValue.doubleValue];
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        aItem.strExpireDate = [dateFormat stringFromDate:curDate];
        
        TZ_DDXMLElement *typeElement = [itemObj elementForName:@"type"];
        if([typeElement.stringValue isEqualToString:@"0"])
        {
            [curItem.freeArray addObject:aItem];
        }
        else if([typeElement.stringValue isEqualToString:@"1"])
        {
            [curItem.payArray addObject:aItem];
        }
    }
    return curItem;
}

@end
