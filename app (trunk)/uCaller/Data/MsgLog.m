//
//  MsgLog.m
//  uCaller
//
//  Created by thehuah on 13-3-2.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "MsgLog.h"

#define MSG_TIMEOUT_SEC 3*60


@implementation ContentInfo

@synthesize title;
@synthesize text;
@synthesize link;
@synthesize jump;


@end



@implementation MsgLog

@synthesize msgType;
@synthesize content;
@synthesize subData;
@synthesize status;
@synthesize newMsgOfNumber;
@synthesize isPlaying;
@synthesize isRecv;
@synthesize isSend;
@synthesize isAudio;
@synthesize isText;
@synthesize isLocation;
@synthesize isCard;
@synthesize isRecvText;
@synthesize isRecvAudio;
@synthesize isSendText;
@synthesize isSendAudio;
@synthesize contentView;
@synthesize isLoaded;
@synthesize contentSize;

@synthesize contentInfoItems;
@synthesize style;

@synthesize cardName;
@synthesize cardPhtoUrl;
@synthesize cardPnum;
@synthesize cardUid;
@synthesize cardUnum;

@synthesize address;
@synthesize lon;
@synthesize lat;



-(void)parseContent{
    
    if (type != MSG_PHOTO_WORD && !self.isLocation) {
        NSLog(@"非图文混排地理位置，不用调用此函数");
        return;
    }
    
    if (type == MSG_PHOTO_WORD) {
    
    NSError *error;
    NSDictionary *contentData = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    
    NSArray *items = [contentData objectForKey:@"items"];
    for (NSDictionary *item in items) {
        
        ContentInfo * contentInfo = [[ContentInfo alloc]init];
        
        if (![[item objectForKey:@"title"] isKindOfClass:[NSNull class]]) {
            contentInfo.title = [item objectForKey:@"title"];
        }
        
        if (![[item objectForKey:@"text"] isKindOfClass:[NSNull class]]) {
            contentInfo.text = [item objectForKey:@"text"];
        }
        
        if (![[item objectForKey:@"pic_url"] isKindOfClass:[NSNull class]]) {
            NSString* pic_url = [item objectForKey:@"pic_url"];
            if (pic_url != nil) {
                NSString * md5 = [[Util md5:pic_url] uppercaseString];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *filePaths;
                filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"/Photo/%@.%@",md5,@"png"]];
                if ([fileManager fileExistsAtPath:filePaths])
                {
                    contentInfo.pic = [UIImage imageWithContentsOfFile:filePaths];
                }
                if (contentInfo.pic == nil) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            NSURL *url = [NSURL URLWithString:pic_url];
                            NSData *imageData = [NSData dataWithContentsOfURL:url];
                            [fileManager createFileAtPath:[[Util cachePhotoFolder] stringByAppendingFormat:@"/%@.%@",md5,@"png"] contents:imageData attributes:nil];
                            dispatch_async(dispatch_get_main_queue(), ^{        
                            if (imageData) {
                                contentInfo.pic  = [UIImage imageWithData:imageData];
                                NSNotification *notification =[NSNotification notificationWithName:UpdataCellPicture object:nil userInfo:nil];
                                [[NSNotificationCenter defaultCenter] postNotification:notification];
                            }
                        });
                    });
                       
                }
            }
        }
        
        if (![[item objectForKey:@"link"] isKindOfClass:[NSNull class]]) {
            contentInfo.link = [item objectForKey:@"link"];
        }
        
        if (![[item objectForKey:@"jump"] isKindOfClass:[NSNull class]]) {
            contentInfo.jump = [item objectForKey:@"jump"];
        }
        
        [contentInfoItems addObject:contentInfo];
    }
    
    style = [contentData objectForKey:@"style"];
        
    }else{
        
        NSError *error;
        
        NSDictionary *contentData = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        
        if (![[contentData objectForKey:@"longitude"] isKindOfClass:[NSNull class]]) {
            self.lon = [contentData objectForKey:@"longitude"];
        }
        if (![[contentData objectForKey:@"latitude"] isKindOfClass:[NSNull class]]) {
            self.lat = [contentData objectForKey:@"latitude"];
        }
        if (![[contentData objectForKey:@"address"] isKindOfClass:[NSNull class]]) {
            self.address = [contentData objectForKey:@"address"];
        }
    }
}
- (void)parseCardContent
{
  
    NSData *testData = [content dataUsingEncoding: NSUTF8StringEncoding];
    NSMutableDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    self.cardUnum = [contentDic objectForKey:@"hyid"];
    self.cardUid = [contentDic objectForKey:@"uid"];
    self.cardPnum = [contentDic objectForKey:@"mobile"];
    self.cardPhtoUrl = [contentDic objectForKey:@"avatar"];
    self.cardName = [contentDic objectForKey:@"nickname"];
}

-(id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code here.
        content = @"";
        subData = @"";
        status = MSG_SENT;
        newMsgOfNumber = 0;
        isPlaying = NO;
        contentInfoItems = [[NSMutableArray alloc] init];

    }
    
    return self;
}

-(id)initWith:(MsgLog *)log
{
    self = [super initWith:log];
    if(self)
    {
        msgType = log.msgType;
        content = log.content;
        subData = log.subData;
        status = log.status;
        newMsgOfNumber = log.newMsgOfNumber;
        isPlaying = log.isPlaying;
    }
    return self;
}

-(int)status
{
    if((status == MSG_SENT) || (status == MSG_SENDING))
    {
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval secDiff = nowTime - time;
        if(secDiff > MSG_TIMEOUT_SEC)
            status = MSG_FAILED;
    }
    
    return status;
}

-(BOOL)isSend
{
    return (type == MSG_AUDIO_SEND) || (type == MSG_TEXT_SEND) || (type == MSG_CALLLOG_SEND) || (type == MSG_PHOTO_SEND) || (type == MSG_LOCATION_SEND) || (type == MSG_CARD_SEND);
}

-(BOOL)isRecv
{
    return ![self isSend];
}

-(BOOL)isText
{
    return (type == MSG_TEXT_SEND) || (type == MSG_TEXT_RECV);
}

-(BOOL)isAudio
{
    return (type == MSG_AUDIO_SEND) || (type == MSG_AUDIO_RECV) || (type == MSG_AUDIOMAIL_RECV_STRANGER) || (type == MSG_AUDIOMAIL_RECV_CONTACT);
}
- (BOOL)isLocation
{
    return (type == MSG_LOCATION_SEND) || (type == MSG_LOCATION_RECV);
}
- (BOOL)isCard
{
    return (type == MSG_CARD_SEND) || (type == MSG_CARD_RECV);
}
- (BOOL)isPhoto
{
    return (type == MSG_PHOTO_SEND) || (type == MSG_PHOTO_RECV);
}
-(BOOL)isAudioBox
{
    return type == MSG_AUDIOMAIL_RECV_STRANGER;
}

-(BOOL)isRecvText
{
    return type == MSG_TEXT_RECV;
}

-(BOOL)isRecvAudio
{
    return type == MSG_AUDIO_RECV;
}

-(BOOL)isSendText
{
    return type == MSG_TEXT_SEND;
}

-(BOOL)isSendAudio
{
    return type == MSG_AUDIO_SEND;
}



@end
