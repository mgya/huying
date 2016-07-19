//
//  GetUserBaseInfoDataSource.m
//  uCaller
//
//  Created by admin on 15/1/6.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetUserBaseInfoDataSource.h"
#import "UConfig.h"
#import "UContact.h"
#import "Util.h"

@implementation GetUserBaseInfoDataSource
@synthesize uid;
@synthesize nickname;
@synthesize photoMid;
@synthesize inviteCode;
@synthesize mood;
@synthesize gender;
@synthesize birthday;

@synthesize school;
@synthesize occupationId;
@synthesize occupationName;
@synthesize company;
@synthesize nativeRegionId;
@synthesize nativeRegionName;

@synthesize feeling_status;
@synthesize diploma;
@synthesize month_income;
@synthesize interest;
@synthesize self_tags;

@synthesize state;
@synthesize userState;
@synthesize recommended;

-(id)init
{
    if (self = [super init]) {
        NSString *info = [UConfig getAccountUserInfo];
        if (info != nil && info.length > 0) {
            [self parseData:info];
        }
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    /*
     {
     "region": "1",
     "uid": "100002049",
     "createTime": "1413738392187",
     "birthday": "1413738392",
     "constellation": "1",
     "number1": "0",
     "zodiac": "1",
     "nativeRegion": "1",
     "age": "11",
     "gender": "1",
     "occupation": "1",
     "nickname": "哈哈",
     "updateTime": "1418968905848",
     "bloodType": "1",
     “nativeRegionName”:"籍贯名称",
     "regionName":"所在地名称",
     "occupationName":"职业名称",
     “company”:"公司名称",
     "self_tags":"",
     "other_tags":"",
     "diploma":"1",
     "feeling_status":"1",
     "month_income":"月收入",
     "interest":"",
     "result": "1"
     }

     */
    [UConfig setAccountUserInfo:strXml];
    
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
        uid = [[dic objectForKey:@"uid"] stringValue];
    }
   
    if (![[dic objectForKey:@"avatar"] isKindOfClass:[NSNull class]]) {
        photoMid = [dic objectForKey:@"avatar"];
    }
    
    if (![[dic objectForKey:@"inviteCode"] isKindOfClass:[NSNull class]]) {
        inviteCode = [dic objectForKey:@"inviteCode"];
    }
    
    if (![[dic objectForKey:@"nickname"] isKindOfClass:[NSNull class]]) {
        nickname = [dic objectForKey:@"nickname"];
    }
    
    if (![[dic objectForKey:@"emotion"] isKindOfClass:[NSNull class]]) {
        mood = [dic objectForKey:@"emotion"];
    }
    
    if (![[dic objectForKey:@"gender"] isKindOfClass:[NSNull class]]) {
        NSInteger nGender = [[dic objectForKey:@"gender"] integerValue];
        if(nGender == 3 || nGender == 1 ||nGender == 0 ){
            gender = FEMALE;
        }
        else if (nGender == 2) {
            gender = MALE;
        }
    }
    
    if (![[dic objectForKey:@"birthday"] isKindOfClass:[NSNull class]]) {
        birthday = [[dic objectForKey:@"birthday"] stringValue];
    }
    
    if (![[dic objectForKey:@"school"] isKindOfClass:[NSNull class]]) {
        school = [dic objectForKey:@"school"];
    }
    
    if (![[dic objectForKey:@"occupation"] isKindOfClass:[NSNull class]]) {
        occupationId = [[dic objectForKey:@"occupation"] stringValue];
    }
    
    if (![[dic objectForKey:@"occupationName"] isKindOfClass:[NSNull class]]) {
        occupationName =[dic objectForKey:@"occupationName"];
    }
    
    if (![[dic objectForKey:@"company"] isKindOfClass:[NSNull class]]) {
        company = [dic objectForKey:@"company"];
    }
    
    if (![[dic objectForKey:@"nativeRegion"] isKindOfClass:[NSNull class]]) {
        nativeRegionId = [[dic objectForKey:@"nativeRegion"] stringValue];
    }
    
    if (![[dic objectForKey:@"nativeRegionName"] isKindOfClass:[NSNull class]]) {
        nativeRegionName = [dic objectForKey:@"nativeRegionName"];
    }
    if (![[dic objectForKey:@"feeling_status"] isKindOfClass:[NSNull class]]) {
        NSString *aStr = [dic objectForKey:@"feeling_status"];
        NSDictionary *adic = [NSDictionary dictionaryWithObjectsAndKeys:aStr,@"feeling_status", nil];
        feeling_status = [Util intergerTransfromString:adic];
    }
    if (![[dic objectForKey:@"diploma"] isKindOfClass:[NSNull class]]) {
        NSString *aStr = [dic objectForKey:@"diploma"];
        NSDictionary *adic = [NSDictionary dictionaryWithObjectsAndKeys:aStr,@"diploma", nil];
        diploma = [Util intergerTransfromString:adic];
    }
    if (![[dic objectForKey:@"month_income"] isKindOfClass:[NSNull class]]) {
        NSString *aStr = [dic objectForKey:@"month_income"];
        NSDictionary *adic = [NSDictionary dictionaryWithObjectsAndKeys:aStr,@"month_income", nil];
        month_income = [Util intergerTransfromString:adic];
    }
    if (![[dic objectForKey:@"interest"] isKindOfClass:[NSNull class]]) {
        interest = [dic objectForKey:@"interest"];
    }
    if (![[dic objectForKey:@"self_tags"] isKindOfClass:[NSNull class]]) {
        self_tags = [dic objectForKey:@"self_tags"];
    }
    NSDictionary *packages = [[NSDictionary alloc]init];

    if (![[dic objectForKey:@"packages"] isKindOfClass:[NSNull class]]) {
        packages = [dic objectForKey:@"packages"];
    }
    self.state = [packages objectForKey:@"safe"];
    self.recommended = [packages objectForKey:@"recommended"];
    
    NSDictionary *userPackages = [[NSDictionary alloc]init];
    
    if (![[dic objectForKey:@"userPackages"] isKindOfClass:[NSNull class]]) {
        userPackages = [dic objectForKey:@"userPackages"];
    }
    self.userState = [userPackages objectForKey:@"safe"];
    
}

@end
