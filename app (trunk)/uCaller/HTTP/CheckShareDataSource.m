//
//  CheckShareDataSource.m
//  uCaller
//
//  Created by 崔远方 on 14-5-15.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "CheckShareDataSource.h"
#import "UConfig.h"
#import <Foundation/NSObject.h>

#define KCheckShare_DefaultPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Common"]
#define KAccountPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"Accounts/%@", [UConfig getUID]]]

#define KCheckShareFile @"CheckShare.arc"

#define KIsShare        @"KIsShare"
#define KTitle          @"KTitle"
#define KFinishedTip    @"KFinishedTip"
#define KFailedTip      @"KFailedTip"

@implementation CheckShareData

@synthesize isShare;//是否分享
@synthesize title;//分享标题
@synthesize finishedTip;//已完成提示
@synthesize failedTip;//未完成提示

-(void)initDefaultData:(SharedType) shareType
{
    switch (shareType) {
        case WXShared:
        {
            self.title = @"分享至微信好友";
        }
            break;
        case WXCircleShared:
        {
            self.title = @"分享至朋友圈";
        }
            break;
        case SinaWbShared:
        {
            self.title = @"分享至新浪微博";
        }
            break;
        case QQZone:
        {
            self.title = @"分享至QQ空间";
        }
            break;
        case QQMsg:
        {
            self.title = @"分享至QQ";
        }
            break;
        case MessageShared:
        case MsgNotice:
        case TellFriends:
            break;
    }
    self.isShare        = NO;
    self.finishedTip    = @"本月已赚取，下月继续哦。";
    self.failedTip      = @"每月首次分享，立赚10分钟通话时长";
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.isShare forKey:KIsShare];
    [aCoder encodeObject:self.title forKey:KTitle];
    [aCoder encodeObject:self.finishedTip forKey:KFinishedTip];
    [aCoder encodeObject:self.failedTip forKey:KFailedTip];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.isShare = [aDecoder decodeBoolForKey:KIsShare];
        self.title = [aDecoder decodeObjectForKey:KTitle];
        self.finishedTip = [aDecoder decodeObjectForKey:KFinishedTip];
        self.failedTip = [aDecoder decodeObjectForKey:KFailedTip];
    }
    return self;
}


@end


@implementation CheckShareDataSource

@synthesize isFinished;
@synthesize shareDictionary;
static CheckShareDataSource *sharedInstance = nil;

+(CheckShareDataSource *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[CheckShareDataSource alloc] init];
        }
    }
	return sharedInstance;
}




+(void)clean{
    
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", KAccountPath, KCheckShareFile];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSError * error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }
    
    filePath = [NSString stringWithFormat:@"%@/%@", KCheckShare_DefaultPath, KCheckShareFile];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSError * error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }
}





-(id)init
{
    if (self = [super init])
    {
        isFinished = NO;
        NSString* filePath = [NSString stringWithFormat:@"%@/%@", KAccountPath, KCheckShareFile];

        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            //读取账号内缓存数据
            shareDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        }
        else {
            filePath = [NSString stringWithFormat:@"%@/%@", KCheckShare_DefaultPath, KCheckShareFile];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                //读取缺省数据
                shareDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            }
            else {
                //创建缺省缓存
                [[NSFileManager defaultManager] createDirectoryAtPath:KCheckShare_DefaultPath
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
                shareDictionary = [[NSMutableDictionary alloc] init];
                for (NSInteger i = 0; i < 5; i++) {
                    CheckShareData* shareData = [[CheckShareData alloc] init];
                    [shareData initDefaultData:i+6];
                    [shareDictionary setObject:shareData forKey:[NSString stringWithFormat:@"%d", i+6]];
                }
                
                [self saveData:filePath];
            }
            
        }

    }
    
	return self;
}

-(void)parseData:(NSString*)strXml
{
    /*
     <?xml version="1.0" encoding="UTF-8"?>
     
     <root>
     <result>1</result>
     <item>
     <type>6</type>
     <isshare>0</isshare>
     <title>分享至新浪微博</title>
     <success>本月已赚取，下月分享还可再次获得时长哦。</success>
     <failed>每月首次分享，立赚10分钟通话时长。</failed>
     </item>
     <item>
     <type>7</type>
     <isshare>0</isshare>
     <title>分享至腾讯微博</title>
     <success>本月已赚取，下月分享还可再次获得时长哦。</success>
     <failed>每月首次分享，立赚10分钟通话时长。</failed>
     </item>
     <item>
     <type>8</type>
     <isshare>0</isshare>
     <title>分享至QQ</title>
     <success>本月已赚取，下月分享还可再次获得时长哦。</success>
     <failed>每月首次分享，立赚10分钟通话时长。</failed>
     </item>
     <item>
     <type>9</type>
     <isshare>0</isshare>
     <title>分享至微信好友</title>
     <success>本月已赚取，下月分享还可再次获得时长哦。</success>
     <failed>每月首次分享，立赚10分钟通话时长。</failed>
     </item>
     <item>
     <type>10</type>
     <isshare>0</isshare>
     <title></title>
     <success>告诉更多小伙伴，全民免费打电话！</success>
     <failed>告诉更多小伙伴，全民免费打电话！分享至朋友圈</failed>
     </item>
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
    
    NSArray* itemArray = [rspElement nodesForXPath:@"item" error:nil];
    for (DDXMLElement *itemObj in itemArray)
    {
        DDXMLElement *typeElement = [itemObj elementForName:@"type"];
        NSInteger index = typeElement.stringValue.intValue;
        DDXMLElement *shareElement = [itemObj elementForName:@"isshare"];
        BOOL isShare = shareElement.stringValue.boolValue;
        DDXMLElement *msgFinishedElement;
        DDXMLElement *msgFailedElement;

        msgFinishedElement = [itemObj elementForName:@"success"];
        msgFailedElement = [itemObj elementForName:@"failed"];
        
        CheckShareData* shareData = [shareDictionary objectForKey:[NSString stringWithFormat:@"%d", index]];
        if (shareData == nil) {
            NSLog(@"CheckShareData is nil, error!!!");
            shareData = [[CheckShareData alloc] init];
        }
        shareData.isShare       = isShare;
        shareData.finishedTip   = msgFinishedElement.stringValue;
        shareData.failedTip     = msgFailedElement.stringValue;

        [shareDictionary setValue:shareData forKey:[NSString stringWithFormat:@"%d", index]];
    }
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:KAccountPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:KAccountPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    NSString* filePath = [NSString stringWithFormat:@"%@/%@",KAccountPath, KCheckShareFile];
    [self saveData:filePath];
    isFinished = YES;
}

-(void)saveData:(NSString *)filePath
{
    [NSKeyedArchiver archiveRootObject:shareDictionary toFile:filePath];
}

@end
