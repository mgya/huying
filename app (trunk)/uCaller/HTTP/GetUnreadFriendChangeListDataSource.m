//
//  GetUnreadFriendChangeListDataSource.m
//  uCaller
//
//  Created by admin on 15/2/4.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetUnreadFriendChangeListDataSource.h"
#import "UConfig.h"
#import "UContact.h"

@implementation GetUnreadFriendChangeListDataSource
@synthesize addContactList;
@synthesize delContactList;

-(id)init
{
    if (self = [super init]) {
        addContactList = [[NSMutableArray alloc] init];
        delContactList = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    /*add
     {
     "result":"1",
     "lastreqtime":1423105977207,
     "uid":102706157,
     "item":[
        {
        "friendUid":102706156,
        "noteName":"",
        "status":1,
        "sort":0,
        "friendupdatetime":1423036217673,
        "userinfo":
            {
            "phone":"13683250890",
            "number":"95013790101803",
            "birthday":0,
            "updateTime":1422520727832
            }
        }
     ]
     }
     */
    
    /*delete friend
     {
        item = (
        {
            friendUid = 102706157;
            friendupdatetime = 1423730833537;
            noteName = "";
            sort = 0;
            status = 2;
            type = 5;
        });
     result = 1;
     }

     */
    [addContactList removeAllObjects];
    [delContactList removeAllObjects];
    
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
    for (NSDictionary* item in items) {
        UContact *contact = [[UContact alloc] init];
        
        if (![[item objectForKey:@"friendUid"] isKindOfClass:[NSNull class]]) {
            contact.uid = [[item objectForKey:@"friendUid"] stringValue];
        }
        
        if (![[item objectForKey:@"noteName"] isKindOfClass:[NSNull class]]) {
            contact.remark = [item objectForKey:@"noteName"];
        }
        
        if (![[item objectForKey:@"sort"] isKindOfClass:[NSNull class]]) {
            contact.sort = [[item objectForKey:@"sort"] integerValue];
        }
        
        if (![[item objectForKey:@"friendupdatetime"] isKindOfClass:[NSNull class]]) {
            contact.updateTime = [[item objectForKey:@"friendupdatetime"] unsignedLongLongValue];
        }
        
        if (![[item objectForKey:@"status"] isKindOfClass:[NSNull class]]) {
            contact.type = [[item objectForKey:@"status"] integerValue] == 1 ? CONTACT_uCaller:CONTACT_Unknow;//status：1正常。 2取消，取消时userinfo为空
        }
        
        if (contact.type == CONTACT_uCaller) {
            NSDictionary *userInfo = [item objectForKey:@"userinfo"];
            
            if (![[userInfo objectForKey:@"phone"] isKindOfClass:[NSNull class]]) {
                contact.pNumber = [userInfo objectForKey:@"phone"];
            }
            
            if (![[userInfo objectForKey:@"number"] isKindOfClass:[NSNull class]]) {
                contact.uNumber = [userInfo objectForKey:@"number"];
            }
            
            if (![[userInfo objectForKey:@"nickname"] isKindOfClass:[NSNull class]]) {
                contact.nickname = [userInfo objectForKey:@"nickname"];
            }
            
            if (![[userInfo objectForKey:@"birthday"] isKindOfClass:[NSNull class]]) {
                contact.birthday = [[userInfo objectForKey:@"birthday"] stringValue];
            }
            
            if (![[userInfo objectForKey:@"emotion"] isKindOfClass:[NSNull class]]) {
                contact.mood = [userInfo objectForKey:@"emotion"];
            }
            
            if (![[userInfo objectForKey:@"gender"] isKindOfClass:[NSNull class]]) {
                NSInteger nGender = [[userInfo objectForKey:@"gender"] integerValue];
                if(nGender == 1 || nGender == 3||nGender == 0){
                    contact.gender = FEMALE;
                }
                else if (nGender == 2) {
                    contact.gender = MALE;
                }
            }
            
            [addContactList addObject:contact];
        }
        else {
            [delContactList addObject:contact];
        }
    }
}

@end
