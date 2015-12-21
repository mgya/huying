//
//  GetWareDataSource.m
//  uCalling
//
//  Created by Rain on 13-3-6.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "GetWareDataSource.h"
#import "DDXML.h"
#import "NSXMLElement+XMPP.h"

@implementation WareInfo

@synthesize strID;
@synthesize fFee;
@synthesize strName;
@synthesize strDesc;
@synthesize strIAPID;
@synthesize imageUrl;
@synthesize sellType;
@synthesize endsec;

-(id)init{
    if (self = [super init]) {
        
	}
	return self;
}


@end

@implementation GetWareDataSource

@synthesize wareList;

-(id)init{
    if (self = [super init]) {
        
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
    if (_nResultNum != 1) {
        return;
    }
    
    DDXMLElement *curtime = [rspElement elementForName:@"current_time"];
    double cur = [curtime.stringValue doubleValue];
    
    NSArray* itemArray = [rspElement nodesForXPath:@"ware" error:nil];
    
    NSMutableArray *itemList = [[NSMutableArray alloc] initWithCapacity:[itemArray count]];
    for (DDXMLElement *itemObj in itemArray)
    {
    
        WareInfo *wareInfo = [[WareInfo alloc] init];
        DDXMLElement *idElement = [itemObj elementForName:@"id"];
        wareInfo.strID = idElement.stringValue;

        DDXMLElement *feeElement = [itemObj elementForName:@"fee"];
        wareInfo.fFee = [feeElement.stringValue floatValue];
        
        DDXMLElement *nameElement = [itemObj elementForName:@"name"];
        wareInfo.strName = nameElement.stringValue;
        
        DDXMLElement *appidElement = [itemObj elementForName:@"appgoodid"];
        if (appidElement != nil)
        {
            wareInfo.strIAPID = appidElement.stringValue;
        }

        DDXMLElement *descElement = [itemObj elementForName:@"desc"];
        wareInfo.strDesc = descElement.stringValue;
        
        DDXMLElement *imageElement = [itemObj elementForName:@"imgurl"];
        wareInfo.imageUrl = imageElement.stringValue;
        
        DDXMLElement *selltype = [itemObj elementForName:@"sell_type"];
        wareInfo.sellType = [selltype.stringValue integerValue];
        
        DDXMLElement *original = [itemObj elementForName:@"original_price"];
        wareInfo.original = [original.stringValue floatValue];
        
        
        DDXMLElement *endsec = [itemObj elementForName:@"expire_time"];
        if ([endsec.stringValue doubleValue] > 0) {
            wareInfo.endsec = ([endsec.stringValue doubleValue] - cur)/1000;
        }
       
        [itemList addObject:wareInfo];
        
      
    }
    
    self.wareList = itemList;
}


@end
