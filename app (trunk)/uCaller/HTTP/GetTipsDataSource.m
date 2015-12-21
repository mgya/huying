//
//  GetTipsDataSource.m
//  uCaller
//
//  Created by 崔远方 on 14-5-13.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "GetTipsDataSource.h"
#import "UDefine.h"

@implementation GetTipsDataSource
@synthesize tipsDictionary;
static GetTipsDataSource *sharedInstance = nil;

+(GetTipsDataSource *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[GetTipsDataSource alloc] init];
        }
    }
    return sharedInstance;
}


-(id)init{
    if (self = [super init])
    {
        self.tipsDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:KTipsPath];
        if (self.tipsDictionary == nil) {
            self.tipsDictionary = [[NSMutableDictionary alloc] init];
        }
        
        /* local default */
        NSString* strInviteVip = [self.tipsDictionary objectForKey:@"InviteVip"];
        if (strInviteVip.length <= 0) {
            [self.tipsDictionary setObject:@"恭喜您，获得特权优惠" forKey:@"InviteVip"];
        }
        
        NSString* strPerson = [self.tipsDictionary objectForKey:@"person"];
        if (strPerson.length <= 0) {
            [self.tipsDictionary setObject:@"恭喜您及好友分别获得邀请赠送30分钟通话时长。将于2分钟内到账。" forKey:@"person"];
        }
        
        //挂机短信缺省提示语
        NSString* strGJDX = [self.tipsDictionary objectForKey:@"gjdx"];
        if (strGJDX.length <= 0) {
            [self.tipsDictionary setObject:@"刚是用“呼应”打的电话，用它打电话不用花钱，你也下载安装一个？http://t.cn/RhO3Yan 记得填我的" forKey:@"gjdx"];
        }
        
        [NSKeyedArchiver archiveRootObject:self.tipsDictionary toFile:KTipsPath];
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
    
    NSArray* itemArray = [rspElement nodesForXPath:@"item" error:nil];
    for (DDXMLElement *itemObj in itemArray)
    {
        DDXMLElement *codeElement = [itemObj elementForName:@"code"];
        DDXMLElement *msgElement = [itemObj elementForName:@"msg"];
        [self.tipsDictionary setObject:msgElement.stringValue forKey:codeElement.stringValue];
    }
    
    [NSKeyedArchiver archiveRootObject:self.tipsDictionary toFile:KTipsPath];
}

@end
