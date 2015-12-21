//
//  ActivitytipDataSource.m
//  uCaller
//
//  Created by HuYing on 15-1-16.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "ActivitytipDataSource.h"

@implementation ActivityTipData
@synthesize titleStr;
@synthesize contentStr;
@synthesize imgUrlStr;
@synthesize hideUrlStr;

static ActivityTipData * sharedInstance = nil;
+(ActivityTipData *)sharedInstance
{
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[ActivityTipData alloc] init];
        }
    }
    return sharedInstance;

}

@end

@implementation ActivitytipDataSource
@synthesize titleStr;
@synthesize contentStr;
@synthesize imgUrlStr;
@synthesize hideUrlStr;

-(id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

-(void)parseData:(NSString *)strXml
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
    
    DDXMLElement *itemsElement = [rspElement elementForName:@"items"];
    DDXMLElement *typeElement = [itemsElement elementForName:@"type"];
    //param
    DDXMLElement *paramElement = [typeElement elementForName:@"param"];
    
    titleStr   = [[paramElement elementForName:@"title"] stringValue];
    
    contentStr = [[paramElement elementForName:@"content"] stringValue];
    
    hideUrlStr = [[paramElement elementForName:@"hideUrl"] stringValue];
    
    imgUrlStr  = [[[[paramElement elementForName:@"shareUrl"]
                                  elementForName:@"imgUrl"]
                                  elementForName:@"url"]
                                  stringValue];
    
    /*<root>
    <result>1</result>
    <items>
    <type>
    <typevalue>1</typevalue>
    <param>
    <paramvalue></paramvalue>
    <title>标题</title>
    <content>
    欢迎使用呼应
    </content>
    <hideUrl>
    分享内容隐藏的地址
    </hideUrl>
    <shareUrl>
    <imgUrl>
    <url>图片地址</url>
    <url>图片地址1</url>
    </imgUrl>
    <videoUrl>
    <url>视频地址</url>
    <url>视频地址</url>
    </videoUrl>
    </shareUrl>
    <param>
    </type>
    </items>
    </root>*/
}

@end
