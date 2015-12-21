//
//  GetNewFriendDataSource.m
//  uCaller
//
//  Created by admin on 15/1/13.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetNewFriendDataSource.h"
#import "UNewContact.h"
#import "Util.h"
#import <Foundation/NSNull.h>

@implementation GetNewFriendDataSource
@synthesize myNewFriendArray;

-(id)init
{
    if (self = [super init]) {
        myNewFriendArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    if(strXml == nil)
        return ;
    
    /*
     {
     "result":"1",
    "item":[{
        "msgid":148,
        "uid":102706157,
        "type":2,
        "verifyInfo":"我是zzz",
        "noteName":null,
        "createtime":1421231673312,
        "status":1,
        "phone":"18515065979",
        "number":"95013790102988"
        }]
     }
     
     
     {
        item = ({
            avatar = 107057463;
            createtime = 1433584444787;
            msgid = 451252;
            noteName = "<null>";
            number = 95013797850919;
            phone = 18253595665;
            status = 1;
            type = 2;
            uid = 107057463;
            verifyInfo = "<null>";
        });
        result = 1;
     }
     */
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"%@", dic);
    
    _bParseSuccessed = YES;
    NSString *res = [dic objectForKey:@"result"];
    _nResultNum = res.integerValue;
    if (_nResultNum != 1) {
        return ;
    }
    
    NSArray *newFriends = [dic objectForKey:@"item"];
    for (NSDictionary *newFriend in newFriends) {

        UNewContact *newContact = [[UNewContact alloc] init];
        if (![[newFriend objectForKey:@"createtime"] isKindOfClass:[NSNull class]]) {
            double time = [[newFriend objectForKey:@"createtime"] doubleValue];
            newContact.time = time/1000;
        }
        
        if (![[newFriend objectForKey:@"msgid"] isKindOfClass:[NSNull class]]) {
            newContact.msgID = [[newFriend objectForKey:@"msgid"] stringValue];
        }
        
        if (![[newFriend objectForKey:@"uid"] isKindOfClass:[NSNull class]]) {
            newContact.uid = [NSString stringWithFormat:@"%ld", [[newFriend objectForKey:@"uid"] integerValue]];
        }
        
        if (![[newFriend objectForKey:@"type"] isKindOfClass:[NSNull class]]) {
            newContact.type = [[newFriend objectForKey:@"type"] integerValue];
        }
        
        if (![[newFriend objectForKey:@"status"] isKindOfClass:[NSNull class]]) {
            newContact.status = [[newFriend objectForKey:@"status"] integerValue];
        }
        
        if (![[newFriend objectForKey:@"noteName"] isKindOfClass:[NSNull class]]) {
            newContact.name = [newFriend objectForKey:@"noteName"];
        }
        else {
            newContact.name = @"";
        }
        
        if (![[newFriend objectForKey:@"number"] isKindOfClass:[NSNull class]]) {
            newContact.uNumber = [newFriend objectForKey:@"number"];
        }
        else {
            newContact.uNumber = @"";
        }
        
        if (![[newFriend objectForKey:@"phone"] isKindOfClass:[NSNull class]]) {
            newContact.pNumber = [newFriend objectForKey:@"phone"];
        }
        else {
            newContact.pNumber = @"";
        }

        if (![[newFriend objectForKey:@"verifyInfo"] isKindOfClass:[NSNull class]]) {
            newContact.info = [newFriend objectForKey:@"verifyInfo"];
        }
        else {
            newContact.info = @"";
        }

        [myNewFriendArray addObject:newContact];
    }
}

@end
