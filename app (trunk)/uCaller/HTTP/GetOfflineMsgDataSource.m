//
//  GetOfflineMsgDataSource.m
//  uCaller
//
//  Created by admin on 15/1/13.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetOfflineMsgDataSource.h"
#import "MsgLog.h"

@implementation GetOfflineMsgDataSource
@synthesize msgArray;

-(id)init
{
    if (self = [super init]) {
        msgArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    /*好友消息
     {
     "result":"1",
     "item":[
        {
        "sender":102706157,//发送者uid
        "id":72658,//消息id
        "expireTime":0,
        "content":"05",
        "createTime":1423033512272,//消息创建时间
        "status":1,
        "senderOpUser":false,
        "contentType":1,//消息内容类型 1.文字 2.语音url 3.图片url 4.留言箱url
        "type":1,//消息类型 1-好友信息 2-运营消息
        "recipient":102706156//接收者uid
        "duration":"11",//语音消息时长
        "fileType":"jpg"//图片消息文件类型
        "senderOpUser": "false", //发送者是否是运营账号
        }
     ]
     ...items
     }
     */
    
    /*留言箱
     {
        "result":"1",
        "item":
        [{
            "sender":102706139,
            "id":7569499,
            "expireTime":0,
            "content":"15210780543给95013799999990发了一条留言",
            "createTime":1432971007781,
            "status":1,
            "contentType":4,
            "type":1,
            "isSenderOpUser":true,
            "recipient":102924875,
            "fileType":"amr",
            "duration":"4"
        }]
     }
     */
    
    /*运营消息
     {"result":"1",
     "item":[
     {
        "sender":100001270,
        "id":500002457,
        "expireTime":1435654754852,
        "content":"xiaomishu",
        "createTime":1435568354853,
        "status":1,
        "contentType":1,
        "type":2,
        "isSenderOpUser":true,
        "recipient":0
     },
     {
        "sender":100001270,"id":500002458,"expireTime":1436864372566,"content":"123456","createTime":1435568372566,"status":1,"contentType":1,"type":2,"isSenderOpUser":true,"recipient":0},{"sender":100001270,"id":500002474,"expireTime":1435661407894,"content":"123456","createTime":1435575007895,"status":1,"contentType":1,"type":2,"isSenderOpUser":true,"recipient":0},{"sender":100001270,"id":500002526,"expireTime":1435722236740,"content":"123","createTime":1435635836740,"status":1,"contentType":1,"type":2,"isSenderOpUser":true,"recipient":0},{"sender":100001270,"id":500002527,"expireTime":1435723574687,"content":"1234","createTime":1435637174801,"status":1,"contentType":1,"type":2,"isSenderOpUser":true,"recipient":0}]}
     */
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"%@", dic);
    
    _bParseSuccessed = YES;
    _nResultNum = [[dic objectForKey:@"result"] integerValue];
    if(_nResultNum != 1) {
        return ;
    }
    
    NSArray *items = [dic objectForKey:@"item"];
    for (NSDictionary *offMsg in items) {
        MsgLog *msg = [[MsgLog alloc] init];
        [msg makeID];
        msg.status = MSG_UNREAD;
        
        if (![[offMsg objectForKey:@"id"] isKindOfClass:[NSNull class]]) {
            msg.msgID = [[offMsg objectForKey:@"id"] stringValue];
        }
        
        if (![[offMsg objectForKey:@"sender"] isKindOfClass:[NSNull class]]) {
            msg.logContactUID = [[offMsg objectForKey:@"sender"] stringValue];
        }
        
        if (![[offMsg objectForKey:@"content"] isKindOfClass:[NSNull class]]) {
            msg.content = [offMsg objectForKey:@"content"];
        }else{
            msg.content = @"[图片]";
        }
       
        if (![[offMsg objectForKey:@"type"] isKindOfClass:[NSNull class]]) {
            msg.msgType = [[offMsg objectForKey:@"type"] intValue];
        }
        
        if ([[offMsg objectForKey:@"contentType"] isKindOfClass:[NSNull class]]) {
            return ;
        }
        
        NSInteger contentType = [[offMsg objectForKey:@"contentType"] integerValue];
        switch (contentType) {
            case 1:
                msg.type = MSG_TEXT_RECV;
                break;
            case 2:
            {
                msg.type = MSG_AUDIO_RECV;
                
                if (![[offMsg objectForKey:@"createTime"] isKindOfClass:[NSNull class]]) {
                    double timeFromSip = [[offMsg objectForKey:@"createTime"] doubleValue];
                    msg.time = timeFromSip/1000;//(sip端时间是已毫秒计数的，本地是以秒计数的)
                }
                
                if (![[offMsg objectForKey:@"duration"] isKindOfClass:[NSNull class]]) {
                    msg.duration = [[offMsg objectForKey:@"duration"] intValue];
                }
                
                if (![[offMsg objectForKey:@"fileType"] isKindOfClass:[NSNull class]]) {
                    msg.fileType = [offMsg objectForKey:@"fileType"];
                }
            }
                break;
            case 3:
                msg.content = @"[图片]";
                msg.type = MSG_PHOTO_RECV;
                if (![[offMsg objectForKey:@"createTime"] isKindOfClass:[NSNull class]]) {
                    double timeFromSip = [[offMsg objectForKey:@"createTime"] doubleValue];
                    msg.time = timeFromSip/1000;//(sip端时间是已毫秒计数的，本地是以秒计数的)
                }
                
                if (![[offMsg objectForKey:@"duration"] isKindOfClass:[NSNull class]]) {
                    msg.duration = [[offMsg objectForKey:@"duration"] intValue];
                }
                
                if (![[offMsg objectForKey:@"fileType"] isKindOfClass:[NSNull class]]) {
                    msg.fileType = [offMsg objectForKey:@"fileType"];
                }
                break;
            case 4:
            {
                //留言箱
                if ([msg.logContactUID isEqualToString:UAUDIOBOX_UID]) {
                    msg.type = MSG_AUDIOMAIL_RECV_STRANGER;
                    msg.msgType = 2;
                    msg.uNumber = UAUDIOBOX_NUMBER;
                    msg.pNumber = UAUDIOBOX_NUMBER;
                }
                else {
                    msg.type = MSG_AUDIOMAIL_RECV_CONTACT;
                }
                
                if (![[offMsg objectForKey:@"createTime"] isKindOfClass:[NSNull class]]) {
                    double timeFromSip = [[offMsg objectForKey:@"createTime"] doubleValue];
                    msg.time = timeFromSip/1000;//(sip端时间是已毫秒计数的，本地是以秒计数的)
                }
                
                if (![[offMsg objectForKey:@"duration"] isKindOfClass:[NSNull class]]) {
                    msg.duration = [[offMsg objectForKey:@"duration"] intValue];
                }

                if (![[offMsg objectForKey:@"fileType"] isKindOfClass:[NSNull class]]) {
                    msg.fileType = [offMsg objectForKey:@"fileType"];
                }
            }
                break;
            case 5:{//位置消息
 
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msg.content
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&error];
                if (! jsonData) {
                    NSLog(@"Got an error: %@", error);
                } else {
                    msg.content = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
     
                msg.type = MSG_LOCATION_RECV;
            }
                break;
            case 6:{
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msg.content
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&error];
                if (! jsonData) {
                    NSLog(@"Got an error: %@", error);
                } else {
                    msg.content = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
                msg.type = MSG_CARD_RECV;
            }
                break;
            case 7:{
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msg.content
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&error];
                if (! jsonData) {
                    NSLog(@"Got an error: %@", error);
                } else {
                    msg.content = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
                msg.type = MSG_PHOTO_WORD;
            }
                break;
            default:
            {
                continue;
            }
                break;
        }
        
        [msgArray addObject:msg];
    }
}

@end
