//
//  GetContactListDataSource.m
//  uCaller
//
//  Created by admin on 15/1/6.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetContactListDataSource.h"
#import "UConfig.h"
#import "UContact.h"

@implementation GetContactListDataSource
@synthesize contacts;

-(id)init
{
    if (self = [super init]) {
        contacts = [[NSMutableArray alloc] init];
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
        "uid":102706157,
        "item":[
        {
            "friendUid":102706156,
            "noteName":"",
            "status":1,
            "sort":0,
            "friendupdatetime":1421477906031,
            "userinfo":
            {
                "phone":"13683250890",
                "number":"95013790101803",
                "birthday":0,
                "updateTime":0
            }
        }
        {
            ...
        }
        ...
        ]
     }*/
    
    [contacts removeAllObjects];
    
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
    
    if ([dic objectForKey:@"uid"] != nil &&
        ![[dic objectForKey:@"uid"] isKindOfClass:[NSNull class]]) {
        NSString *uid = [[dic objectForKey:@"uid"] stringValue];
        if (![uid isEqualToString:[UConfig getUID]]) {
            return ;
        }
    }
    
    if ([dic objectForKey:@"lastreqtime"] != nil &&
        ![[dic objectForKey:@"lastreqtime"] isKindOfClass:[NSNull class]]) {
        NSString *lastreqtime = [[dic objectForKey:@"lastreqtime"] stringValue];
        [UConfig updateContactListUpdateTime:lastreqtime];
    }
    
    NSArray *contactList = [dic objectForKey:@"item"];
    for (NSDictionary *contactDic in contactList) {
        
        UContact *contact = [[UContact alloc] init];
        
        if ([contactDic objectForKey:@"friendUid"] != nil &&
            ![[contactDic objectForKey:@"friendUid"] isKindOfClass:[NSNull class]]) {
            contact.uid = [NSString stringWithFormat:@"%ld", [[contactDic objectForKey:@"friendUid"] integerValue]];
        }
        
        if ([contactDic objectForKey:@"noteName"] != nil &&
            ![[contactDic objectForKey:@"noteName"] isKindOfClass:[NSNull class]]) {
            contact.remark = [contactDic objectForKey:@"noteName"];
        }
        
        if ([contactDic objectForKey:@"sort"] != nil &&
            ![[contactDic objectForKey:@"sort"] isKindOfClass:[NSNull class]]) {
            contact.sort = [[contactDic objectForKey:@"sort"] integerValue];
        }
        
        if ([contactDic objectForKey:@"friendupdatetime"] != nil &&
            ![[contactDic objectForKey:@"friendupdatetime"] isKindOfClass:[NSNull class]]) {
            contact.updateTime = [[contactDic objectForKey:@"friendupdatetime"] unsignedLongLongValue];
        }
        
        if ([contactDic objectForKey:@"friendupdatetime"] != nil &&
            ![[contactDic objectForKey:@"friendupdatetime"] isKindOfClass:[NSNull class]]) {
            contact.type = [[contactDic objectForKey:@"status"] integerValue] == 1 ? CONTACT_uCaller:CONTACT_Unknow;//status：1正常。 2取消，取消时userinfo为空
        }
        
        if (contact.type == CONTACT_uCaller) {
            NSDictionary *userInfo = [contactDic objectForKey:@"userinfo"];
            
            if ([userInfo objectForKey:@"phone"] != nil &&
                ![[userInfo objectForKey:@"phone"] isKindOfClass:[NSNull class]]) {
                contact.pNumber = [userInfo objectForKey:@"phone"];
            }
            
            if ([userInfo objectForKey:@"number"] != nil &&
                ![[userInfo objectForKey:@"number"] isKindOfClass:[NSNull class]]) {
                contact.uNumber = [userInfo objectForKey:@"number"];
            }
            
            //解决测试号码在线上注销情况下，注销号码注销前的呼应账号还与登陆的呼应号有好友关系（此时该账号只有uid没有uNumber和pNumber），这时对这个账号处理会出现bug，所以在联系人列表不加入它。
            if ([contact.uNumber isEqualToString:@"X"]) {
                continue;
            }
            
            if ([userInfo objectForKey:@"nickname"] != nil &&
                ![[userInfo objectForKey:@"nickname"] isKindOfClass:[NSNull class]]) {
                contact.nickname = [userInfo objectForKey:@"nickname"];
            }
            
            if ([userInfo objectForKey:@"birthday"] != nil &&
                ![[userInfo objectForKey:@"birthday"] isKindOfClass:[NSNull class]]) {
                NSString *strBir = [[userInfo objectForKey:@"birthday"] stringValue];
                contact.birthday =  [strBir isEqualToString:@"0"] ? @"" : strBir;
            }
            
            if ([userInfo objectForKey:@"emotion"] != nil &&
                ![[userInfo objectForKey:@"emotion"] isKindOfClass:[NSNull class]]) {
                contact.mood = [userInfo objectForKey:@"emotion"];
            }
            
            if ([userInfo objectForKey:@"gender"] != nil &&
                ![[userInfo objectForKey:@"gender"] isKindOfClass:[NSNull class]]) {
                NSInteger nGender = [[userInfo objectForKey:@"gender"] integerValue];
                if(nGender == 3 || nGender == 1 ||nGender == 0){
                    contact.gender = FEMALE;
                }
                else if (nGender == 2) {
                    contact.gender = MALE;
                }
            }

            if ([userInfo objectForKey:@"occupationName"] != nil &&
                ![[userInfo objectForKey:@"occupationName"] isKindOfClass:[NSNull class]]) {
                contact.occupation = [userInfo objectForKey:@"occupationName"];
            }
            
            if ([userInfo objectForKey:@"company"] != nil &&
                ![[userInfo objectForKey:@"company"] isKindOfClass:[NSNull class]]) {
                contact.company = [userInfo objectForKey:@"company"];
            }
            
            if ([userInfo objectForKey:@"school"] != nil &&
                ![[userInfo objectForKey:@"school"] isKindOfClass:[NSNull class]]) {
                contact.school = [userInfo objectForKey:@"school"];
            }
            
            if ([userInfo objectForKey:@"nativeRegionName"] != nil &&
                ![[userInfo objectForKey:@"nativeRegionName"] isKindOfClass:[NSNull class]]) {
                contact.hometown = [userInfo objectForKey:@"nativeRegionName"];
            }
            
        }
        
        if (contact.uNumber != nil && contact.uNumber.length > 0) {
            [contacts addObject:contact];
        }
        else {
            contact = nil;
        }
    }
}

@end
