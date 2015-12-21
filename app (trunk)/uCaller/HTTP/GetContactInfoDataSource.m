//
//  GetContactInfoDataSource.m
//  uCaller
//
//  Created by admin on 15/1/23.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetContactInfoDataSource.h"
#import "Util.h"

@implementation GetContactInfoDataSource
@synthesize contact;

-(id)init
{
    if (self = [super init]) {
        contact = [[UContact alloc] init];
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    /*
     {
     "region":0,
     "uid":0,
     "createTime":0,
     "birthday":0,
     "constellation":0,
     "desc":"",
     "string2":"",
     "string1":"",
     "string3":"",
     "number1":0,
     "zodiac":0,
     "nativeRegion":0,
     "interest":"",
     "age":0,
     "gender":0,
     "occupation":0,
     "updateTime":0,
     "nickname":"",
     "number":"",
     "avatar":"",
     "emotion":"",
     "bloodType":0,
     "school":"",
     "email":"",
     "inviteCode":"",
     "result":"1"
     }

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
    
    if (![[dic objectForKey:@"uid"] isKindOfClass:[NSNull class]]) {
        contact.uid = [[dic objectForKey:@"uid"] stringValue];
    }
    
    if (![[dic objectForKey:@"updateTime"] isKindOfClass:[NSNull class]]) {
        contact.updateTime = [[dic objectForKey:@"updateTime"] unsignedLongLongValue];
    }
    
    if (![[dic objectForKey:@"nickname"] isKindOfClass:[NSNull class]]) {
        contact.nickname = [dic objectForKey:@"nickname"];
    }
    
    if (![[dic objectForKey:@"emotion"] isKindOfClass:[NSNull class]]) {
        contact.mood = [dic objectForKey:@"emotion"];
    }
    
    if (![[dic objectForKey:@"avatar"] isKindOfClass:[NSNull class]]) {
        contact.photoURL = [dic objectForKey:@"avatar"];
    }
    
    if (![[dic objectForKey:@"gender"] isKindOfClass:[NSNull class]]) {
        NSInteger nGender = [[dic objectForKey:@"gender"] integerValue];
        if(nGender == 3 || nGender == 1||nGender == 0 ){
            contact.gender = FEMALE;
        }
        else if (nGender == 2) {
            contact.gender = MALE;
        }
    }
    
    if (![[dic objectForKey:@"birthday"] isKindOfClass:[NSNull class]]) {
        NSString *strBir = [[dic objectForKey:@"birthday"] stringValue];
        contact.birthday =  [strBir isEqualToString:@"0"] ? @"" : strBir;
    }

    if (![[dic objectForKey:@"occupationName"] isKindOfClass:[NSNull class]]) {
        contact.occupation = [dic objectForKey:@"occupationName"];
    }
    
    if (![[dic objectForKey:@"company"] isKindOfClass:[NSNull class]]) {
        contact.company = [dic objectForKey:@"company"];
    }
    
    if (![[dic objectForKey:@"school"] isKindOfClass:[NSNull class]]) {
        contact.school = [dic objectForKey:@"school"];
    }
    
    if (![[dic objectForKey:@"nativeRegionName"] isKindOfClass:[NSNull class]]) {
        contact.hometown = [dic objectForKey:@"nativeRegionName"];
    }
    
    if (![[dic objectForKey:@"feeling_status"] isKindOfClass:[NSNull class]]) {
        NSString *aStr = [dic objectForKey:@"feeling_status"];
        NSDictionary *adic = [NSDictionary dictionaryWithObjectsAndKeys:aStr,@"feeling_status", nil];
        contact.feeling_status = [Util intergerTransfromString:adic];
    }
    if (![[dic objectForKey:@"diploma"] isKindOfClass:[NSNull class]]) {
        NSString *aStr = [dic objectForKey:@"diploma"];
        NSDictionary *adic = [NSDictionary dictionaryWithObjectsAndKeys:aStr,@"diploma", nil];
        contact.diploma = [Util intergerTransfromString:adic];
    }
    if (![[dic objectForKey:@"month_income"] isKindOfClass:[NSNull class]]) {
        NSString *aStr = [dic objectForKey:@"month_income"];
        NSDictionary *adic = [NSDictionary dictionaryWithObjectsAndKeys:aStr,@"month_income", nil];
        contact.month_income = [Util intergerTransfromString:adic];
    }
    if (![[dic objectForKey:@"interest"] isKindOfClass:[NSNull class]]) {
        contact.interest = [dic objectForKey:@"interest"];
    }
    if (![[dic objectForKey:@"self_tags"] isKindOfClass:[NSNull class]]) {
        contact.self_tags = [dic objectForKey:@"self_tags"];
    }
    
    if (![[dic objectForKey:@"number"] isKindOfClass:[NSNull class]]) {
        contact.uNumber = [dic objectForKey:@"number"];
    }
}
@end
