//
//  UContact.m
//  uCaller
//
//  Created by thehuah on 13-3-2.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "UContact.h"

#import "Util.h"
#import "UAdditions.h"
#import "JPinYinUtil.h"
#import "ContactManager.h"

#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"
#define ALPHABET @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"

@implementation UContact

@synthesize sort;
@synthesize updateTime;
@synthesize uid;
@synthesize type;
@synthesize name;
@synthesize number;
@synthesize uNumber;
@synthesize pNumber;
@synthesize localName;
@synthesize remark;
@synthesize nickname;
@synthesize mood;
@synthesize photoURL;
@synthesize photo;
@synthesize BigPhoto;
@synthesize gender;
@synthesize birthday;
@synthesize namePinyin;
@synthesize nameShuzi;
@synthesize nameShoushuzi;
@synthesize nameSZArr;
@synthesize numberLast;
@synthesize isMatch;
@synthesize isLocalContact;
@synthesize isUCallerContact;
@synthesize isOPContact;
@synthesize isMale;
@synthesize isStar;
@synthesize hasUNumber;
@synthesize occupation;
@synthesize company;
@synthesize school;
@synthesize hometown;
@synthesize feeling_status;
@synthesize month_income;
@synthesize diploma;
@synthesize interest;
@synthesize self_tags;
@synthesize nickNamePinyin;
@synthesize localNamePinyin;
@synthesize remarkNamePinyin;

-(id)init
{
    self = [super init];
    if(self)
    {
        type = CONTACT_LOCAL;

        uid = @"";
        name = @"";
        number = @"";
        uNumber = @"";
        pNumber = @"";
        gender = FEMALE;
        isMatch = NO;
        isStar = NO;
    }
    return self;
    
}

-(id)initWith:(ContactType)aType
{
    self = [super init];
    if(self)
    {
        type = aType;
        uid = @"";
        name = @"";
        number = @"";
        uNumber = @"";
        pNumber = @"";
        gender = FEMALE;
        isMatch = NO;
        isStar = NO;
    }
    return self;
}

-(id)initWithContact:(UContact *)aContact
{
    self = [super init];
    if(self)
    {
        if(aContact != nil)
        {
            type = aContact.type;
            self.uid = aContact.uid;
            self.localName = aContact.localName;
            self.remark = aContact.remark;
            self.nickname = aContact.nickname;

            self.number = aContact.number;
            self.uNumber = aContact.uNumber;
            self.pNumber = aContact.pNumber;
            self.photoURL = aContact.photoURL;
            self.mood = aContact.mood;
            self.gender = aContact.gender;
            self.birthday = aContact.birthday;
            self.isStar = aContact.isStar;
            self.isMatch = aContact.isMatch;
            self.occupation = aContact.occupation;
            self.company = aContact.company;
            self.school = aContact.school;
            self.hometown = aContact.hometown;
            self.feeling_status = aContact.feeling_status;
            self.diploma = aContact.diploma;
            self.month_income = aContact.month_income;
            self.interest = aContact.interest;
            self.self_tags = aContact.self_tags;
        }
    }
    return self;
}

//-(NSString *)Uid
//{
//    return self.uid;
//}

//-(NSString *)getDisplayName
//{
//    //获取联系人的名称（通讯录 》 备注 》 昵称 》 呼应号）
//    NSString *strDisplayName = nil;
//    if (![Util isEmpty:localName]) {
//        strDisplayName = localName;
//    }
//    else if (![Util isEmpty:remark]){
//        strDisplayName = remark;
//    }
//    else if (![Util isEmpty:nickname]){
//        strDisplayName = nickname;
//    }
//    else{
//        strDisplayName = uNumber;
//    }
//    
//    return strDisplayName;
//}

-(NSString *)name
{
//    if([Util isEmpty:name])
//    {
    if (![Util isEmpty:remark]){
        name = remark;
    }
    else if (![Util isEmpty:localName]) {
        name = localName;
    }
    else if (![Util isEmpty:nickname]){
        name = nickname;
    }
    else{
        name = uNumber;
    }
//    }
//    
    return name;
}

-(NSString *)number
{
//    if([Util isEmpty:number])
//    {
        if (self.isMatch) {
            number = uNumber;
        }
        else if(type == CONTACT_LOCAL)
        {
            number = pNumber;
        }
        else
        {
            number = uNumber;
        }
//    }
    return number;
}

//-(void)setNumber:(NSString *)aNumber
//{
//    number = aNumber;
//}

//-(NSString *)uNumber
//{
//    if(uNumber == nil)
//        uNumber = @"";
//    return uNumber;
//}

//-(void)setUNumber:(NSString *)aNumber
//{
//    uNumber = aNumber;
//    if([Util isEmpty:aNumber])
//        uNumber = @"X";
//    else
//        uNumber = [Util substringFromStart:aNumber sep:@"@"];
//    if(type == CONTACT_uCaller)
//    {
//        [self setNumber:uNumber];
//        if([Util isEmpty:localName] && [Util isEmpty:remark] && [Util isEmpty:nickname])
//            [self setName:uNumber];
//    }
//}

//-(NSString *)pNumber
//{
//    if(pNumber == nil)
//        pNumber = @"";
//    return pNumber;
//}

//-(void)setPNumber:(NSString *)aNumber
//{
//    if([Util isEmpty:aNumber])
//    {
//        pNumber = @"";
//    }
//    else
//    {
//        pNumber = [Util getValidNumber:aNumber];
//        if(type == CONTACT_LOCAL)
//        {
//            [self setNumber:pNumber];
//        }
//    }
//}

//-(NSString *)localName
//{
//    return localName;
//}

//-(void)setLocalName:(NSString *)aLocalName
//{
//    localName = aLocalName;
//    if([Util isEmpty:localName] && (type == CONTACT_uCaller))
//    {
//        if([Util isEmpty:remark] == NO)
//        {
//            [self setName:remark];
//        }
//        else if([Util isEmpty:nickname] == NO)
//        {
//            [self setName:nickname];
//        }
//        else
//        {
//            [self setName:uNumber];
//        }
//    }
//    else
//    {
//        [self setName:localName];
//    }
//}

//-(NSString *)remark
//{
//    if(remark == nil)
//        remark = @"";
//    return remark;
//}

//-(void)setRemark:(NSString *)aRemark
//{
//    if([Util isEmpty:localName] && (type == CONTACT_uCaller))
//    {
//        if([Util isEmpty:aRemark] == NO)
//        {
//            self.name = aRemark;
//        }
//        else if([Util isEmpty:nickname] == NO)
//        {
//            self.name = nickname;
//        }
//        else
//        {
//            self.name = uNumber;
//        }
//    }
//    remark = aRemark;
//}

//-(NSString *)nickname
//{
//    if(nickname == nil)
//        nickname = @"";
//    return nickname;
//}

//-(void)setNickname:(NSString *)aNickname
//{
//    if([Util isEmpty:localName] && (type == CONTACT_uCaller))
//    {
//        if([Util isEmpty:remark])
//        {
//            if([Util isEmpty:aNickname] == NO)
//            {
//                self.name = aNickname;
//            }
//            else
//            {
//                self.name = uNumber;
//            }
//        }
//    }
//    nickname = aNickname;
//}

//-(NSString *)occupation
//{
//    if (occupation  == nil) {
//        occupation = @"";
//    }
//    return occupation;
//}

//-(NSString *)company
//{
//    if (company == nil) {
//        company = @"";
//    }
//    return company;
//}

//-(NSString *)school
//{
//    if (school == nil) {
//        school = @"";
//    }
//    return school;
//}

//-(NSString *)hometown
//{
//    if (hometown == nil) {
//        hometown = @"";
//    }
//    return hometown;
//}


//-(NSString *)mood
//{
//    if(mood == nil)
//        mood = @"";
//    return mood;
//}

//-(NSString *)photoURL
//{
//    if(photoURL == nil)
//        photoURL = @"";
//    return photoURL;
//}

//-(NSString *)gender
//{
//    if(gender == nil)
//        gender = FEMALE;
//    return gender;
//}

//-(NSString *)birthday
//{
//    if(birthday == nil)
//        birthday = @"";
//    return birthday;
//}

//-(BOOL)isOnline
//{
//    Modified by huah in 2013-11-11
//    return isOnline;
//    return YES;
//}

-(NSString *)namePinyin
{
    if([Util isEmpty:namePinyin])
    {
        namePinyin = getStringPinYin(self.name);
    }
    //    if([Util isEmpty:namePinyin])
    //        namePinyin = @"";
    return namePinyin;
}
- (NSString *)remarkNamePinyin
{
    if([Util isEmpty:remarkNamePinyin])
    {
        remarkNamePinyin = getStringPinYin(self.remark);
    }
    //    if([Util isEmpty:namePinyin])
    //        namePinyin = @"";
    return remarkNamePinyin;
}
- (NSString *)nickNamePinyin
{
    if([Util isEmpty:nickNamePinyin])
    {
        nickNamePinyin = getStringPinYin(self.nickname);
    }
    //    if([Util isEmpty:namePinyin])
    //        namePinyin = @"";
    return nickNamePinyin;
}
- (NSString *)localNamePinyin
{
    if([Util isEmpty:localNamePinyin])
    {
        localNamePinyin = getStringPinYin(self.localName);
    }
    //    if([Util isEmpty:namePinyin])
    //        namePinyin = @"";
    return localNamePinyin;
}

//-(NSString *)headChar
//{
//    if([Util isEmpty:self.name])
//        return @"";
//    NSString *lastStr = [name substringAtIndex:name.length - 1];
//    if([lastStr isChinese])
//        return lastStr;
//    return @"";
//}

-(UIImage *)photo
{
    UIImage *photoImage = nil;
    if([self.uid isEqualToString:UCALLER_UID])
    {
        
        photoImage = [UIImage imageNamed:@"cc_cloudccer.png"];
    }
    else if([self hasUNumber]/*[self hasUNumber] && ![Util isEmpty:photoURL]*/)
    {
        //photo
        NSString *photoName = [NSString stringWithFormat:@"u%@.png",uid];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",photoName]];
        if ([fileManager fileExistsAtPath:filePaths])
        {
            photoImage = [UIImage imageWithContentsOfFile:filePaths];
        }
//        photoImage = [UIImage imageWithContentsOfFile:photoURL];
    }
    return photoImage;
}

-(UIImage *)BigPhoto
{
    UIImage *photoImage = nil;
    if([self.uid isEqualToString:UCALLER_UID])
    {
        photoImage = [UIImage imageNamed:@" "];
    }
    else if([self hasUNumber]/*[self hasUNumber] && ![Util isEmpty:photoURL]*/)
    {
        //photo
        NSString *photoName = [NSString stringWithFormat:@"u%@_big.png",uid];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",photoName]];
        if ([fileManager fileExistsAtPath:filePaths])
        {
            photoImage = [UIImage imageWithContentsOfFile:filePaths];
        }
        //        photoImage = [UIImage imageWithContentsOfFile:photoURL];
    }
    return photoImage;
}


-(BOOL)isLocalContact
{
    return type == CONTACT_LOCAL || isMatch == YES;//通讯录好友类型 or 通讯录匹配ucaller contact成功
}

-(BOOL)isUCallerContact
{
    return type == CONTACT_uCaller || (type == CONTACT_LOCAL && isMatch == YES);//呼应好友类型 and 通讯录好友匹配成功
}

-(BOOL)isOPContact
{
    return type == CONTACT_OpUsers && isMatch == NO;
}

-(BOOL)isMale
{
    return [self.gender isEqualToString:MALE];
}

-(BOOL)hasUNumber
{
    return ([Util isEmpty:uNumber] == NO) || self.isMatch == YES;
}

-(BOOL)checkPNumber
{
    return (([Util isEmpty:pNumber] == NO) && (self.isLocalContact)) ||
    (self.isMatch);
}

-(BOOL)matchUid:(NSString *)aUid
{
    if ([Util isEmpty:uid]) {
        return NO;
    }
    if (uid != nil && [uid isEqualToString:aUid]) {
        return YES;
    }
    return NO;
}

-(BOOL)matchUNumber:(NSString *)aNumber
{
    if([Util isEmpty:aNumber])
        return NO;
    if(self.hasUNumber && [uNumber isEqualToString:aNumber])
        return YES;
    return NO;
}

-(BOOL)matchPNumber:(NSString *)aNumber
{
    if([Util isEmpty:aNumber])
        return NO;
    if([self checkPNumber] && [Util matchPNumber:pNumber with:aNumber])
        return YES;
    return NO;
}

-(BOOL)matchNumber:(NSString *)aNumber
{
    return [self matchUNumber:aNumber] || [self matchPNumber:aNumber];
}

-(BOOL)matchContact:(UContact *)aContact
{
    if(aContact == nil)
        return NO;
    if([self matchPNumber:aContact.pNumber] || [self matchUNumber:aContact.uNumber])
        return YES;
    return NO;
}

-(BOOL)containNumber:(NSString *)aNumber
{
    if([Util isEmpty:aNumber])
        return NO;
    
    if(([self checkPNumber] && [pNumber contain:aNumber]) ||
       (self.hasUNumber && [uNumber contain:aNumber]) /*这个是搜索逻辑的接口，uid是对用户无感知的，不应体现在搜索中||
       (self.uid != nil && [self.uid contain:aNumber])*/)
        return YES;
    
    return NO;
}

-(BOOL)containMainNumber:(NSString *)aNumber
{
    if([Util isEmpty:aNumber])
        return NO;
    
    if(([Util isEmpty:self.number] == NO) && [self.number contain:aNumber])
        return YES;
    
    return NO;
}

-(NSComparisonResult)compareWithName:(UContact *)aContact
{
    if (![Util isEmpty:self.name] && ![Util isEmpty:aContact.name]) {
        NSString *myFirstChar = [self.namePinyin substringAtIndex:0];
        NSString *contactFirstChar = [aContact.namePinyin substringAtIndex:0];
        if(![ALPHABET contain:myFirstChar] && [ALPHABET contain:contactFirstChar])
            return NSOrderedDescending;
        else if([ALPHABET contain:myFirstChar] && ![ALPHABET contain:contactFirstChar])
            return NSOrderedAscending;
        else
            return [self.namePinyin compare:aContact.namePinyin];
    }
    return NSOrderedSame;//[self.name localizedCaseInsensitiveCompare:aContact.name];
}

-(NSComparisonResult)compareWithUCallerContact:(UContact *)aContact
{
    //    if([self.uNumber isEqualToString:UCALLER_NUMBER])
    //        return NSOrderedAscending;
    //    else if([xmppContact.uNumber isEqualToString:UCALLER_NUMBER])
    //        return NSOrderedDescending;
    
    if (![Util isEmpty:self.name] && ![Util isEmpty:aContact.name]) {
        NSString *myFirstChar = [self.namePinyin substringAtIndex:0];
        NSString *contactFirstChar = [aContact.namePinyin substringAtIndex:0];
        if(![ALPHABET contain:myFirstChar] && [ALPHABET contain:contactFirstChar])
            return NSOrderedDescending;
        else if([ALPHABET contain:myFirstChar] && ![ALPHABET contain:contactFirstChar])
            return NSOrderedAscending;
        else
            return [self.namePinyin compare:aContact.namePinyin];
    }
    
    return NSOrderedSame;
}
//联系人搜索逻辑
-(NSDictionary *)getMatchedChineseFromKey:(NSString *)key
{
 
    NSMutableArray *resultsArr = [[NSMutableArray alloc]init];
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    if(key == nil||[key isEqualToString:@""])
        return nil;
    if ([self.remark isEqualToString:@""]&&[self.localName isEqualToString:@""]&&[self.nickname isEqualToString:@""]&&![self.name isEqualToString:@""]) {
        [resultsArr addObject:self.name];
        [resultsArr addObject:key];
    }else{
        if([self.remark contain:key])
        {
            [resultsArr addObject:self.remark];
            [resultsArr addObject:key];
        }
        else{
            if ([self.nickname contain:key]){
                [resultsArr addObject:self.nickname];
                [resultsArr addObject:key];
                if ([self.localName contain:key]) {
                    [resultsArr addObject:self.localName];
                    [resultsArr addObject:key];
                }else{
                    if (self.remark!=nil&&![self.remark isEqualToString:@""]) {
                        [resultsArr addObject:self.remark];
                    }
                }
            }
            else if ([self.localName contain:key]) {
                [resultsArr addObject:self.localName];
                [resultsArr addObject:key];
                if (self.remark!=nil&&![self.remark isEqualToString:@""]) {
                    [resultsArr addObject:self.remark];
                }
            }
        }
        if (resultsArr == nil||resultsArr.count == 0) {
            NSString *remarkResult =[self getMatchedChineses:self.remarkNamePinyin andName:self.remark andKey:key];
            NSString *localResult =[self getMatchedChineses:self.localNamePinyin andName:self.localName andKey:key];
            NSString *nickResult = [self getMatchedChineses:self.nickNamePinyin andName:self.nickname andKey:key];
            
            if (remarkResult!=nil&&![remarkResult isEqualToString:@""]) {
                
                [resultsArr addObject:self.remark];
                [resultsArr addObject:remarkResult];
            }else{
                if (nickResult!=nil&&![nickResult isEqualToString:@""]){
                    [resultsArr addObject:self.nickname];
                    [resultsArr addObject:nickResult];
                    if (localResult!=nil&&![localResult isEqualToString:@""]) {
                        [resultsArr addObject:self.localName];
                        [resultsArr addObject:localResult];
                    }else{
                        if (self.remark!=nil&&![self.remark isEqualToString:@""]) {
                            [resultsArr addObject:self.remark];
                        }
                    }
                }else if(localResult!=nil&&![localResult isEqualToString:@""] ){
                    [resultsArr addObject:self.localName];
                    [resultsArr addObject:localResult];
                    if (self.remark!=nil&&![self.remark isEqualToString:@""]) {
                        [resultsArr addObject:self.remark];
                    }
                }
            }
        }
        
        
        if ([self.pNumber contain:key]) {
            [resultArray addObject:self.pNumber];
            [resultArray addObject:key];
            
        }if([self.uNumber contain:key]){
            [resultArray addObject:self.uNumber];
             [resultArray addObject:key];
        }
        if ((resultsArr==nil||resultsArr.count == 0)&&resultArray.count!=0) {
            [resultArray addObject:self.name];
        }
    }
    
    NSDictionary *resultDic = [NSDictionary dictionaryWithObjectsAndKeys:resultsArr,@"name",resultArray,@"num", nil];
        return resultDic;
    //    return nil;
}
- (NSString*)getMatchedChineses:(NSString *)namePinYin andName:(NSString*)name andKey:(NSString*)key{
    NSArray *pinyinArray = [namePinYin componentsSeparatedByString:@"_"];
    NSMutableString *jianPinyin = [NSMutableString stringWithString:@""];
    int i = 0;
    NSString *resultName;
    for(NSString *pinyin in pinyinArray)
    {
        if([Util isEmpty:pinyin])
            continue;
        if([pinyin startWith:key])
        {
            resultName =  [name substringAtIndex:i];
        }
        i++;
        [jianPinyin appendString:[pinyin substringWithRange:NSMakeRange(0,1)]];
    }
    if([jianPinyin contain:key])
    {
        NSRange range = [jianPinyin rangeOfString:[key uppercaseString]];
        if(range.location == NSNotFound)
            return nil;
        else
        {
            resultName = [name substringWithRange:range];
        }
    }
    return resultName;
}

//获取匹配的中文
-(NSString *)getMatchedChinese:(NSString *)key
{
    if(key == nil)
        return nil;
    if([self.name contain:key])
    {
        return key;
    }
    NSArray *pinyinArray = [self.namePinyin componentsSeparatedByString:@"_"];
    NSMutableString *jianPinyin = [NSMutableString stringWithString:@""];
    int i = 0;
    for(NSString *pinyin in pinyinArray)
    {
        if([Util isEmpty:pinyin])
            continue;
        if([pinyin startWith:key])
        {
            return [self.name substringAtIndex:i];
        }
        i++;
        [jianPinyin appendString:[pinyin substringWithRange:NSMakeRange(0,1)]];
    }
    if([jianPinyin contain:key])
    {
        NSRange range = [jianPinyin rangeOfString:[key uppercaseString]];
        if(range.location == NSNotFound)
            return nil;
        else
        {
            return [self.name substringWithRange:range];
        }
    }
    
    return nil;
}

-(BOOL)containKey:(NSString *)key
{
    if([self containNumber:key])
        return YES;
    
    if(([Util isEmpty:self.name] == NO) && [self.name contain:key])
        return YES;
    
    if(([Util isEmpty:self.nickname] == NO) && [self.nickname contain:key])
        return YES;
    if(([Util isEmpty:self.localName] == NO) && [self.localName contain:key])
        return YES;
    
    if([Util isEmpty:self.namePinyin])
        return NO;
    
    NSArray *pinyinArray = [self.namePinyin componentsSeparatedByString:@"_"];
    NSMutableString *jianPinyin = [NSMutableString stringWithString:@""];
    for(NSString *pinyin in pinyinArray)
    {
        if([Util isEmpty:pinyin])
            continue;
        if([pinyin startWith:key])
        {
            return YES;
        }
        [jianPinyin appendString:[pinyin substringWithRange:NSMakeRange(0,1)]];
    }
    if([jianPinyin contain:key])
    {
        return YES;
    }
    
    return NO;
}

-(BOOL)containMainKey:(NSString *)key
{
    if([self containMainNumber:key])
        return YES;
    
    if(([Util isEmpty:self.name] == NO) && [self.name contain:key])
        return YES;
    
    if([Util isEmpty:self.namePinyin])
        return NO;
    
    NSArray *pinyinArray = [self.namePinyin componentsSeparatedByString:@"_"];
    NSMutableString *jianPinyin = [NSMutableString stringWithString:@""];
    for(NSString *pinyin in pinyinArray)
    {
        if([Util isEmpty:pinyin])
            continue;
        if([pinyin startWith:key])
            return YES;
        [jianPinyin appendString:[pinyin substringWithRange:NSMakeRange(0,1)]];
    }
    
    if([jianPinyin contain:key])
        return YES;
    
    return NO;
}

-(void)reset
{
    isMatch = NO;
    
    if(type == CONTACT_LOCAL)
    {
        uNumber = @"";
        remark = @"";
        nickname = @"";
        mood = @"";
        photoURL = @"";
        gender = @"";
        birthday = @"";
        uid = @"";
        
        occupation = @"";
        company = @"";
        school = @"";
        hometown = @"";
        feeling_status = @"";
        diploma = @"";
        month_income = @"";
        interest = @"";
        self_tags = @"";
    }
    else
    {
        localName = @"";
        namePinyin = nil;
        nameShuzi = nil;
        nameShoushuzi = nil;
        [nameSZArr removeAllObjects];
    }
}

-(NSString *)nameShoushuzi{
    if ([Util isEmpty:nameShoushuzi]) {
        NSMutableString *s = [[NSMutableString alloc] initWithCapacity:30];
        for (int m = 0; m<[self.namePinyin length]; m++) {
            NSString *ss = [self.namePinyin substringAtIndex:m];
            if (m == 0 ||[ss isEqualToString:@"_"] ) {
                if (m == 0) {
                    ss = [self.namePinyin substringAtIndex:0];
                }
                if ([ss isEqualToString:@"_"]) {
                    ss = [self.namePinyin substringAtIndex:m+1];
                }
                NSString *strr = [self forchange:ss];
                if (strr!=nil)
                    [s appendString:strr];
            }
        }
        nameShoushuzi = s;
    }
    return nameShoushuzi;
}

- (NSArray *)nameSZArr{
    if (nameSZArr.count == 0) {
        NSMutableString *s = [[NSMutableString alloc] initWithCapacity:50];
        self.nameSZArr = [[NSMutableArray alloc]init];
        for (int n = 0; n<=[self.namePinyin length]; n++) {
            NSString *ss = [self.namePinyin substringAtIndex:n];
            if (![ss isEqualToString:@"_"]) {
                NSString *strr = [self forchange:ss];
                if (strr!=nil) {
                    [s appendString:strr];
                }
                if (n==[self.namePinyin length]) {
                    [nameSZArr addObject:s];
                }
            }else{
                [nameSZArr addObject:s];
                s = [[NSMutableString alloc] initWithCapacity:50];
            }
        }
    }
    return nameSZArr;
}

- (NSString *)nameShuzi{
    if ([Util isEmpty:nameShuzi]) {
        NSMutableString *s = [[NSMutableString alloc] initWithCapacity:50];
        for (int n = 0; n<[self.namePinyin length]; n++) {
            NSString *ss = [self.namePinyin substringAtIndex:n];
            if (![ss isEqualToString:@"_"]) {
                NSString *strr = [self forchange:ss];
                if (strr!=nil) {
                    [s appendString:strr];
                }
            }
        }
        nameShuzi = s;
    }
    return nameShuzi;
}
-(void)makePhotoView:(UIImageView *)photoView withFont:(UIFont *)font
{
    if(photoView == nil)
        return;
    
    UIImage *contactPhoto = self.photo;
    if(contactPhoto != nil)
    {
        [photoView makePhotoViewWithImage:contactPhoto];
    }
    else
    {
        if (![Util isEmpty:self.number]) {
                self.numberLast = [self.number substringAtIndex:self.number.length-1];
        }
        if (![Util isEmpty:self.numberLast]) {
            if ([@"01"  rangeOfString:self.numberLast].location!=NSNotFound) {
                [photoView makePhotoViewWithImage:[UIImage imageNamed:@"contactPhoto_a"]];
            }else if ([@"234"  rangeOfString:self.numberLast].location!=NSNotFound){
                [photoView makePhotoViewWithImage:[UIImage imageNamed:@"contactPhoto_g"]];
            }else if ([@"567"  rangeOfString:self.numberLast].location!=NSNotFound){
                [photoView makePhotoViewWithImage:[UIImage imageNamed:@"contactPhoto_m"]];
            }else if ([@"89"  rangeOfString:self.numberLast].location!=NSNotFound){
                [photoView makePhotoViewWithImage:[UIImage imageNamed:@"contactPhoto_s"]];
            }else{
                [photoView makePhotoViewWithImage:[UIImage imageNamed:@"contact_default_photo"]];
            }
        }else{
            [photoView makePhotoViewWithImage:[UIImage imageNamed:@"contact_default_photo"]];
        }
    }
}
- (NSString*)forchange:(NSString*)str{
    NSString *st;
    if ([@"ABC2" rangeOfString:str].location != NSNotFound) {
        st = @"2";
    }else if ([@"DEF3" rangeOfString:str].location != NSNotFound){
        st = @"3";
    }else if ([@"GHI4" rangeOfString:str].location != NSNotFound){
        st = @"4";
    }else if ([@"JKL5" rangeOfString:str].location != NSNotFound){
        st = @"5";
    }else if ([@"MNO6" rangeOfString:str].location != NSNotFound){
        st = @"6";
    }else if ([@"PQRS7" rangeOfString:str].location != NSNotFound){
        st = @"7";
    }else if ([@"TUV8" rangeOfString:str].location  != NSNotFound){
        st = @"8";
    }else if ([@"WXYZ9" rangeOfString:str].location != NSNotFound){
        st = @"9";
    }else if([str isEqualToString:@"0"]){
        st = @"0";
    }else if([str isEqualToString:@"1"]){
        st = @"1";
    }else if([str isEqualToString:@"#"]){
        st = @"#";
    }else if([str isEqualToString:@"*"]){
        st = @"*";
    }else if([str isEqualToString:@"+"]){
        st = @"+";
    }else{
        st = @"#";
    }
    return st;
}

@end

