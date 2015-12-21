//
//  GetSharedDataSource.m
//  uCaller
//
//  Created by 崔远方 on 14-3-18.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "GetSharedDataSource.h"
#import "UConfig.h"
#import "UDefine.h"
#import "ShareContent.h"
#import "Util.h"


@implementation GetSharedDataSource

@synthesize shareContentArray;

-(id)init
{
    if (self = [super init])
    {
        shareContentArray = [[NSMutableDictionary alloc] init];
        
        ShareContent *curContent;
        
        //step 1
        curContent = [[ShareContent alloc] initWithType:QQZone];
        [shareContentArray setObject:curContent forKey:[NSString stringWithFormat:@"%d", QQZone]];
        
        //step 2
        curContent = [[ShareContent alloc] initWithType:SinaWbShared];
        [shareContentArray setObject:curContent forKey:[NSString stringWithFormat:@"%d", SinaWbShared]];

        //step 3
        curContent = [[ShareContent alloc] initWithType:QQMsg];
        [shareContentArray setObject:curContent forKey:[NSString stringWithFormat:@"%d", QQMsg]];
        
        curContent = [[ShareContent alloc] initWithType:WXShared];
        [shareContentArray setObject:curContent forKey:[NSString stringWithFormat:@"%d", WXShared]];
        
        curContent = [[ShareContent alloc] initWithType:WXCircleShared];
        [shareContentArray setObject:curContent forKey:[NSString stringWithFormat:@"%d", WXCircleShared]];
        
        curContent = [[ShareContent alloc] initWithType:Sms_invite];
        [shareContentArray setObject:curContent forKey:[NSString stringWithFormat:@"%d", Sms_invite]];
        
        curContent = [[ShareContent alloc] initWithType:TellFriends];
        [shareContentArray setObject:curContent forKey:[NSString stringWithFormat:@"%d", TellFriends]];
	}

    [NSKeyedArchiver archiveRootObject:shareContentArray toFile:KShareContentsPath];
    return self;
}


-(void)parseData:(NSString*)strXml
{
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
    if (_nResultNum != 1) {
        return;
    }
    
    NSArray* itemArray = [rspElement nodesForXPath:@"item" error:nil];
    for (DDXMLElement *itemObj in itemArray)
    {
        DDXMLElement *codeElement = [itemObj elementForName:@"code"];
        if (codeElement == nil)
        {
            return;
        }
        
        NSString *sharedType = codeElement.stringValue;
        SharedType curType = SharedType_Unknow;
        
        if([sharedType isEqualToString:KSINA])
        {
            curType = SinaWbShared;
        }
        else if([sharedType isEqualToString:KQZONE])
        {
            curType = QQMsg;
        }
        else if([sharedType isEqualToString:KWX_CIRCLE])
        {
            curType = WXCircleShared;
        }
        else if([sharedType isEqualToString:KWX_SESSION])
        {
            curType = WXShared;
        }
        else if([sharedType isEqualToString:KTENCENT])
        {
            curType = QQZone;
        }
        else if([sharedType isEqualToString:KSMS])
        {
            curType = Sms_invite;
        }
        else if([sharedType isEqualToString: KSMSNotice])
        {
            curType = TellFriends;
        }
        
        if (curType == SharedType_Unknow) {
            continue;
        }
        
        ShareContent *curContent = [[ShareContent alloc] initWithType:curType];
        
        DDXMLElement *titleElement = [itemObj elementForName:@"title"];
        if(titleElement != nil)
            curContent.title = titleElement.stringValue;
        
        DDXMLElement *msgElement = [itemObj elementForName:@"msg"];
        if(msgElement != nil)
        {
            curContent.msg = msgElement.stringValue;
        }
        
        DDXMLElement *hideUrlElement = [itemObj elementForName:@"hideUrl"];
        if(hideUrlElement != nil)
            curContent.hideUrl = hideUrlElement.stringValue;
        
        DDXMLElement *sharedUrlElement = [itemObj elementForName:@"shareUrl"];
        if(sharedUrlElement != nil)
        {
            DDXMLElement *imgUrlElement = [sharedUrlElement elementForName:@"imgUrl"];
            NSArray *imageUrls = [imgUrlElement elementsForName:@"url"];
            NSMutableArray *curImageUrls = [NSMutableArray array];
            for(DDXMLElement *item in imageUrls)
            {
                [curImageUrls addObject:item.stringValue];
            }
            if(curImageUrls)
            {
                curContent.imgUrls = curImageUrls;
            }

            DDXMLElement *videoUrlElement = [sharedUrlElement elementForName:@"videoUrl"];//[sharedUrlElement elementsForName:@"videoUrl"];
            NSArray *videoUrls = [videoUrlElement elementsForName:@"url"];
            NSMutableArray *curVideoUrls = [NSMutableArray array];
            for(DDXMLElement *item in videoUrls)
            {
                [curVideoUrls addObject:item.stringValue];
            }
            if(curVideoUrls.count > 0)
            {
                curContent.videoUrls = curVideoUrls;
            }
        }
        
        [shareContentArray setObject:curContent forKey:[NSString stringWithFormat:@"%d", curType]];
    }
    [NSKeyedArchiver archiveRootObject:shareContentArray toFile:KShareContentsPath];
    [UConfig setRequestShareTime:[NSDate date]];
}



@end
