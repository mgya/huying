//
//  GetMediaMsgDataSource.m
//  uCaller
//
//  Created by admin on 15/2/6.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetMediaMsgDataSource.h"
#import "DataCore.h"

@implementation GetMediaMsgDataSource
@synthesize duration;
@synthesize fileType;
@synthesize content;
@synthesize mediaData;

-(id)init
{
    if (self = [super init]) {
    }
    return self;
}

-(void)parseHeader:(NSDictionary*)dicHeader Data:(NSData *)data;
{
    /*
     header info = {
        Connection = "keep-alive";
        Date = "Sat, 07 Feb 2015 03:24:06 GMT";
        Server = "nginx/1.6.2";
        "Transfer-Encoding" = Identity;
        duration = 2;
        fileType = amr;
     }
     */
    [DataCore sharedInstance].httpFinish = YES;
    if (dicHeader == nil) {
        _nResultNum = 0;
        return ;
    }
    
    _nResultNum = 1;
    _bParseSuccessed = YES;
    
    if (![[dicHeader objectForKey:@"duration"] isKindOfClass:[NSNull class]]) {
        duration = [[dicHeader objectForKey:@"duration"] intValue];
    }
    
    if (![[dicHeader objectForKey:@"fileType"] isKindOfClass:[NSNull class]]) {
        fileType = [dicHeader objectForKey:@"fileType"];
    }
    
    if (![[dicHeader objectForKey:@"content"] isKindOfClass:[NSNull class]]) {
        content = [[dicHeader objectForKey:@"content"] stringValue];
    }
    
    mediaData = [[NSData alloc] initWithData:data];
}

@end
