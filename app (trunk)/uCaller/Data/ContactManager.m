//
//  ContactManager.m
//  uCaller
//
//  Created by thehuah on 13-3-3.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "ContactManager.h"

#import <AddressBook/AddressBook.h>
#import "Util.h"
#import "UAdditions.h"
#import "UConfig.h"
#import "HTTPManager.h"
#import "DBManager.h"
#import "CallLogManager.h"
#import "MsgLogManager.h"
#import "UCore.h"

@implementation ContactManager
{
    NSMutableDictionary *localContactsMap;
    NSMutableDictionary *uContactsMap;
    
    NSMutableArray *starNumbers;
    NSMutableArray *starContacts;
    
    NSMutableDictionary *searchContactsMap;
    NSMutableDictionary *searchLocalContactsMap;
    NSMutableDictionary *searchXMPPContactsMap;
    
    
    DBManager *dbManager;
}

@synthesize localContacts;
@synthesize uContacts;
@synthesize allContacts;
@synthesize phoneContacts;
@synthesize recommendContacts;
@synthesize localContactsReady;
@synthesize xmppContactsReady;

static ContactManager *sharedInstance = nil;

+(ContactManager *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[ContactManager alloc] init];
        }
    }
	return sharedInstance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        self.localContactsReady = NO;
        self.xmppContactsReady = NO;
        
        localContacts = [[NSMutableArray alloc] init];
        uContacts = [[NSMutableArray alloc] init];
        localContactsMap = [[NSMutableDictionary alloc] init];
        uContactsMap = [[NSMutableDictionary alloc] init];
        
        starContacts = [[NSMutableArray alloc] init];
        recommendContacts = [[NSMutableArray alloc] init];
        
        searchContactsMap = [[NSMutableDictionary alloc] init];
        searchLocalContactsMap = [[NSMutableDictionary alloc] init];
        searchXMPPContactsMap = [[NSMutableDictionary alloc] init];
        
        dbManager= [DBManager sharedInstance];
    }
    return self;
}

-(void)postContactNotification:(NSDictionary *)info
{
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NContactEvent
                                                                        object:nil
                                                                      userInfo:info];
}

// 读取本地通讯录
- (void)loadLocalContacts
{
    if([ContactManager localContactsAccessGranted] == YES)
    {
        double lastUploadTime = [UConfig getLastAdressbookUpdateTimeInternal];
        NSMutableArray *incrementalLoaclContacts = [[NSMutableArray alloc] init];
        
        NSMutableArray *newLocalContacts = [[NSMutableArray alloc] init];
        NSMutableDictionary *newLocalContactsMap = [[NSMutableDictionary alloc] init];
        
        ABAddressBookRef addressBookRef = ABAddressBookCreate();
        
        ABRecordRef contactRef;
        
        UContact *localContact;
        
        NSArray *abContacts = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBookRef));
        
        for (id abContact in abContacts)
        {
            contactRef = (__bridge ABRecordRef)abContact;
            
            CFTypeRef numbersRef = ABRecordCopyValue(contactRef, kABPersonPhoneProperty);
            if(!numbersRef)
                return;
            for (int i = 0; i < ABMultiValueGetCount(numbersRef); i++)
            {
                CFStringRef numberRef = ABMultiValueCopyValueAtIndex(numbersRef, i);
                if(!numberRef)
                    continue;
                
                NSString *number = [ContactManager getNumberFromABNumber:numberRef];
                
                if([number length])
                {
                    if([newLocalContactsMap contain:number])
                        continue;
                    localContact = [[UContact alloc] init];
                    localContact.pNumber = number;
                    NSString *name = (NSString *)CFBridgingRelease(ABRecordCopyCompositeName(contactRef));
                    if([Util isEmpty:name])
                    {
                        name = number;
                    }
                    
                    localContact.localName = name;
                    [newLocalContactsMap setObject:localContact forKey:number];
                    [newLocalContacts addObject:localContact];
                    
                    NSDate *modifyDate = (__bridge NSDate*)ABRecordCopyValue(contactRef, kABPersonModificationDateProperty);
                    NSTimeInterval modifyTime = [modifyDate timeIntervalSince1970];
                    if (modifyTime > lastUploadTime) {
//                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//                        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//                        NSString *strModifyDate = [formatter stringFromDate:modifyDate];
//                        NSLog(@"%@",strModifyDate);
                        [incrementalLoaclContacts addObject:localContact];
                    }
                }
            }
            
            if(numbersRef)
                CFRelease(numbersRef);
        }
        
        [newLocalContacts sortUsingSelector:@selector(compareWithName:)];
        
        localContacts = newLocalContacts;
        localContactsMap = newLocalContactsMap;
        
        if (incrementalLoaclContacts.count > 0) {
//            NSDate *today = [NSDate date];
//            NSDate *lastUploadTime = [NSDate dateWithTimeIntervalSince1970:[UConfig getUploadABTime]];
//            NSTimeInterval time=[today timeIntervalSinceDate:lastUploadTime];
//            if(time > (24*60*60))
//            {
                NSLog(@"synUploadAddressBook start after 30 sec");
                [self performSelector:@selector(synUploadAddressBook:) withObject:incrementalLoaclContacts afterDelay:1];
//            }
        }
    }
    else
    {
        [self resetLocalContacts];
        if([localContacts count])
            [localContacts removeAllObjects];
        if([localContactsMap count])
            [localContactsMap removeAllObjects];
    }
    self.localContactsReady = YES;
}

-(void)synUploadAddressBook:(NSArray *)arrayAB
{
    NSLog(@"synUploadAddressBook start");
    [[UCore sharedInstance] newTask:U_POST_LOCALCONTACT data:arrayAB];
}

-(void)loadLocalContactsAsync
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadLocalContacts];
    });
}

-(void)reloadLocalContacts
{
    [self loadLocalContacts];
    [self matchAllContacts];
}

-(void)resetLocalContacts
{
    for(UContact *contact in localContacts)
    {
        NSString *uNumber = contact.uNumber;
        if([Util isEmpty:uNumber])
            continue;
        UContact *uContact = [uContactsMap objectForKey:uNumber];
        if(uContact == nil)
        {
            [contact reset];
        }
    }
}

//读取缓存xmpp好友列表
-(void)loadCacheContacts
{
    if(uContacts == nil)
        uContacts = [[NSMutableArray alloc] init];
    if(uContactsMap == nil)
        uContactsMap = [[NSMutableDictionary alloc] init];
    
    //呼应小秘书
    UContact *ucallerContact = [[UContact alloc] init];
    ucallerContact.uid = UCALLER_UID;
    ucallerContact.uNumber = UCALLER_NUMBER;
    ucallerContact.nickname = UCALLER_NAME;
    ucallerContact.mood = UCALLER_MOOD;
    ucallerContact.type = CONTACT_OpUsers;
    [dbManager addContact:ucallerContact];
    
    //留言小助手
    UContact *audioBoxContact = [[UContact alloc] init];
    audioBoxContact.uid = UAUDIOBOX_UID;
    audioBoxContact.uNumber = UAUDIOBOX_NUMBER;
    audioBoxContact.nickname = UAUDIOBOX_NAME;
    audioBoxContact.type = CONTACT_OpUsers;
    [dbManager addContact:audioBoxContact];
    
    NSMutableArray *cacheUCallerContacts  = [dbManager loadCacheContacts];
    for(UContact *contact in cacheUCallerContacts)
    {
        [self matchXMPPContact:contact];
        [uContacts addObject:contact];
        [uContactsMap setObject:contact forKey:contact.uNumber];
    }
    
    self.xmppContactsReady = YES;
    
    [uContacts sortUsingSelector:@selector(compareWithUCallerContact:)];
}

//获取server端联系人列表
-(void)loadContacts:(NSArray *)users
{
    if((users == nil) || ([users count] < 1))
        return;
    
    NSMutableArray *newXMPPContacts = [[NSMutableArray alloc] init];
    NSMutableDictionary *newXMPPContactsMap = [[NSMutableDictionary alloc] init];
        
    UContact *uCallerContact;
    for(UContact *contact in users)
    {
        if([contact.uNumber isEqualToString:[UConfig getUNumber]])
            continue;
        if([newXMPPContactsMap objectForKey:contact.uNumber] == nil)
        {
            UContact *mapContact = [self getContact:contact.uid];
            if(mapContact != nil)
            {
                uCallerContact = [[UContact alloc] initWithContact:mapContact];
            }
            else
            {
                uCallerContact = [[UContact alloc] initWith:CONTACT_uCaller];
            }
            
            uCallerContact.uid = contact.uid;
            uCallerContact.uNumber = contact.uNumber;
            uCallerContact.pNumber = contact.pNumber;
            uCallerContact.nickname = contact.nickname;
            uCallerContact.mood = contact.mood;
            uCallerContact.type = contact.type;
            uCallerContact.occupation = contact.occupation;
            uCallerContact.company = contact.company;
            uCallerContact.school = contact.school;
            uCallerContact.hometown = contact.hometown;
            
            [self matchXMPPContact:uCallerContact];
            
            [newXMPPContacts addObject:uCallerContact];
            [newXMPPContactsMap setObject:uCallerContact forKey:uCallerContact.uNumber];
        }
    }
    
    
    [uContacts addObjectsFromArray:newXMPPContacts];
    [uContactsMap addEntriesFromDictionary:newXMPPContactsMap];
    
    self.xmppContactsReady = YES;
    
    [uContacts sortUsingSelector:@selector(compareWithUCallerContact:)];
    
    [self resetLocalContacts];
}

-(void)loadStarContacts
{
    starNumbers = [dbManager loadStarContacts];
    if(self.localContactsReady || self.xmppContactsReady)
    {
        [starContacts removeAllObjects];
        for(NSString *number in starNumbers)
        {
            UContact *contact = [self getContact:number];
            if(contact != nil)
            {
                contact.isStar = YES;
                UContact *matchContact = [self getMatchContact:contact];
                if(matchContact != nil){
                    matchContact.isStar = YES;
                }
                
                UContact *starContact = [self getUCallerContact:contact.uNumber];
                if (starContact == nil) {
                    starContact = [self getLocalContact:contact.pNumber];
                }
                [starContacts addObject:starContact];
                
            }
        }
    }
}

-(NSMutableArray *)localContacts
{
    if(self.localContactsReady == NO)
        return [[NSMutableArray alloc] init];
    else
        return localContacts;
}

-(NSMutableArray *)allContacts
{
    if((self.localContactsReady == NO) && (self.xmppContactsReady == NO))
        return [[NSMutableArray alloc] init];
    
    //1.
    NSMutableArray *all = [[NSMutableArray alloc] init];
    for(UContact *uCallerContact in uContacts)
    {
        if(uCallerContact.type == CONTACT_uCaller)
            [all addObject:uCallerContact];
        }
    
    NSArray *tmpLocalContacts = [localContacts mutableCopy];
    for (UContact *localContact in tmpLocalContacts) {
        if (!localContact.isMatch) {
            [all addObject:localContact];
        }
    }
    [all sortUsingSelector:@selector(compareWithName:)];
    return all;
    
    //2.
//    NSMutableArray *all = [NSMutableArray arrayWithArray:localContacts];
//    NSArray *tmpUCallerContacts = [uContacts mutableCopy];
//    for(UContact *xmppContact in tmpUCallerContacts)
//    {
//        if(xmppContact.isMatch == NO && (xmppContact.type == CONTACT_uCaller /*||
//                                         xmppContact.type == CONTACT_OpUsers*/))
//            [all addObject:xmppContact];
//    }
//    [all sortUsingSelector:@selector(compareWithName:)];
//    return all;
}

-(NSMutableArray *)phoneContacts
{
    if(self.localContactsReady == NO)
        return [[NSMutableArray alloc] init];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (UContact *contact in localContacts) {
        if (contact.hasUNumber == NO) {
            if([Util isPhoneNumber:contact.pNumber])
                [resultArray addObject:contact];
        }
    }
    return resultArray;
}

-(NSMutableArray *)recommendContacts
{
    @synchronized(self)
    {
        if(self.localContactsReady == NO || self.xmppContactsReady == NO)
            return [[NSMutableArray alloc] init];
        if (recommendContacts.count == 0) {
            recommendContacts = [dbManager loadNewContacts];
        }
    }
    //将contact加入到每一个recommendContact中
    return recommendContacts;
}

-(UContact *)getLocalContact:(NSString *)pNumber
{
    if(self.localContactsReady == NO)
        return nil;
    
    NSString *validNumber = [Util getValidNumber:pNumber];
    if ([Util isEmpty:validNumber]) {
        return nil;
    }

    UContact *contact = [localContactsMap objectForKey:validNumber];

    return contact;
}

-(UContact *)getUCallerContact:(NSString *)uNumber
{
    if(self.xmppContactsReady == NO)
        return nil;
    
    if ([Util isEmpty:uNumber]) {
        return nil;
    }
    
    UContact *contact = [uContactsMap objectForKey:uNumber];
    
    if (contact.isUCallerContact || contact.isOPContact) {
        return contact;
    }
    if (contact.type == CONTACT_Unknow ||
        contact.type == CONTACT_Recommend) {
        //好友已经删除
        return nil;
    }
    return contact;
}

-(UContact *)getContact:(NSString *)number
{
    if((self.localContactsReady == NO) && (self.xmppContactsReady == NO))
        return nil;
    
    NSString *validNumber = [Util getValidNumber:number];
    if ([Util isEmpty:validNumber]) {
        return nil;
    }
    
    UContact *contact = [self getUCallerContact:validNumber];
    if(contact == nil){
        contact = [self getLocalContact:validNumber];
    }
    return contact;
}

-(UContact *)getContactByUID:(NSString *)uid
{
    for (UContact *contact in uContacts) {
        if ([contact.uid isEqualToString:uid]) {
            return contact;
        }
    }
    
    return nil;
}

-(UContact *)getContactByUNumber:(NSString *)aUNumber
{
    for (UContact *contact in uContacts) {
        if ([contact.uNumber isEqualToString:aUNumber]) {
            return contact;
        }
    }
    
    return nil;
}

-(UContact *)getMatchContact:(UContact *)contact
{
    if((self.localContactsReady == NO) && (self.xmppContactsReady == NO))
        return nil;
    
    if(contact == nil)
        return nil;
    
    UContact *matchContact = nil;
    if(contact.isMatch)
    {
        if(contact.type == CONTACT_LOCAL)
        {
            matchContact = [self getContact:contact.uNumber];
        }
        else
        {
            matchContact = [self getLocalContact:contact.pNumber];
        }
    }
    return matchContact;
}

-(void)saveContacts
{
//    @synchronized(self){
        [dbManager saveContacts:uContacts];
//    }
}

-(void)addContact:(NSArray *)users
{
    if(users == nil)
        return;
    
    for (UContact *addedcontact in users) {
        
        //1.更新呼应好友联系人
        UContact *contact = [uContactsMap objectForKey:addedcontact.uNumber];
        if (contact == nil) {
            contact = [[UContact alloc] initWithContact:addedcontact];
            [uContacts addObject:contact];
            [uContactsMap setObject:contact forKey:contact.uNumber];
        }
        else {
            contact.pNumber = addedcontact.pNumber;
            contact.uNumber = addedcontact.uNumber;
            contact.localName = addedcontact.localName;
            contact.remark = addedcontact.remark;
            contact.isMatch = addedcontact.isMatch;
            contact.type = addedcontact.type;
        }
        
        //2.校验本地联系人
        UContact *localContact = [localContactsMap objectForKey:addedcontact.pNumber];
        if (localContact != nil) {
            [self matchXMPPContact:contact];
        }
        
        //3.校验星标好友
        [self loadStarContacts];
        
//        @synchronized(self)
//        {
            [dbManager addContact:contact];
//        }
    }
}

-(void)delContact:(UContact *)aContact
{
    if(aContact == nil)
        return;
    
    if(aContact.isStar){
        [self delStarContact:aContact];
    }
    
    aContact.type = CONTACT_Unknow;
        
//    @synchronized(self){
        [dbManager delContactWithNumber:aContact.uid];
//    }
    
    [self matchXMPPContact:aContact];
}

-(void)delContactWithUID:(NSString *)uid
{
    if([Util isEmpty:uid])
        return;
    
    UContact *contact = [self getContactByUID:uid];
    [self delContact:contact];
}

-(void)updateContactRemark:(UContact *)contact
{
    if(contact == nil)
        return;
    [dbManager addContact:contact];
    [uContacts sortUsingSelector:@selector(compareWithUCallerContact:)];
}

-(BOOL)matchXMPPContact:(UContact *)aContact
{
    BOOL matched = NO;
    
    if (aContact == nil)
        return matched;
    else if ([aContact.uNumber isEqualToString:UCALLER_NUMBER])
        return matched;
    
    [aContact reset];
    
    NSString *pNumber = aContact.pNumber;
    UContact *localContact = [self getLocalContact:pNumber];

    if (localContact != nil)
    {
        if (aContact.type == CONTACT_uCaller) {
            matched = YES;
            
            aContact.localName = localContact.localName;
            aContact.isMatch = YES;
            
            localContact.uNumber = aContact.uNumber;
            localContact.remark = aContact.remark;
            localContact.nickname = aContact.nickname;
            localContact.mood = aContact.mood;
            localContact.photoURL = aContact.photoURL;
            localContact.gender = aContact.gender;
            localContact.birthday = aContact.birthday;
            localContact.isMatch = YES;
            localContact.occupation = aContact.occupation;
            localContact.company = aContact.company;
            localContact.school = aContact.school;
            localContact.hometown = aContact.hometown;
            localContact.feeling_status = aContact.feeling_status;
            localContact.diploma = aContact.diploma;
            localContact.month_income = aContact.month_income;
            localContact.interest = aContact.interest;
            localContact.self_tags = aContact.self_tags;
        }
        else if (aContact.type == CONTACT_Unknow){
            matched = YES;
            
            [localContact reset];
            [aContact reset];
        }
        else if(aContact.type == CONTACT_Recommend){
            matched = YES;
            
            [localContact reset];
            [aContact reset];
            
            aContact.isMatch = YES;
            aContact.localName = localContact.localName;
        }
        
    }

    return matched;
}

-(BOOL)matchAllContacts
{
    BOOL matched = NO;
    
    if((self.localContactsReady == NO) && (self.xmppContactsReady == NO))
        return matched;
    
    //1. local contact
    for (UContact *contact in localContacts)
    {
        [contact reset];
    }
    
    //2. ucaller contact
    for (UContact *xmppContact in uContacts)
    {
        NSString *uNumber = xmppContact.uNumber;
        
        if ([uNumber isEqualToString:UCALLER_NUMBER])
            continue;
        
        matched |= [self matchXMPPContact:xmppContact];
    }
    
    //3.star contact
    [self loadStarContacts];
    
    if (matched)
        [uContacts sortUsingSelector:@selector(compareWithUCallerContact:)];
    
    return matched;
}

-(void)resetSearchMap
{
    [searchContactsMap removeAllObjects];
    [searchLocalContactsMap removeAllObjects];
    [searchXMPPContactsMap removeAllObjects];
}

-(NSArray *)searchContactsWithKey:(NSString *)key searchMap:(NSMutableDictionary *)searchMap baseArray:(NSMutableArray *)baseArray
{
    NSMutableArray *searchArray = [searchMap valueForKey:key];
    if(searchArray != nil)
    {
        return searchArray;
    }
    else
    {
        if(key.length > 1)
        {
            NSString *parentKey = [key substringToIndex:key.length-1];
            searchArray = [searchMap valueForKey:parentKey];
        }
    }

    if(searchArray == nil)
    {
        if(baseArray == nil)
            searchArray = self.allContacts;
        else
            searchArray = baseArray;
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (UContact *contact in searchArray) {
        if([contact containKey:key])
            [resultArray addObject:contact];
    }
    [searchMap setValue:resultArray forKey:key];
    return resultArray;
}

-(NSArray *)searchContactsWithMainKey:(NSString *)key searchMap:(NSMutableDictionary *)searchMap baseArray:(NSMutableArray *)baseArray
{
    NSMutableArray *searchArray = [searchMap valueForKey:key];
    if(searchArray != nil)
    {
        return searchArray;
    }
    else
    {
        if(key.length > 1)
        {
            NSString *parentKey = [key substringToIndex:key.length-1];
            searchArray = [searchMap valueForKey:parentKey];
        }
    }
    
    if(searchArray == nil)
    {
        if(baseArray == nil)
            searchArray = self.allContacts;
        else
            searchArray = baseArray;
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (UContact *contact in searchArray) {
        if([contact containMainKey:key])
            [resultArray addObject:contact];
    }
    [searchMap setValue:resultArray forKey:key];
    return resultArray;
}

-(NSArray *)searchContactsWithKey:(NSString *)key andType:(int)type
{
    if((type == CONTACT_LOCAL) && (self.localContactsReady == NO))
        return [[NSArray alloc] init];
    else if((type == CONTACT_uCaller) && (self.xmppContactsReady == NO))
        return [[NSArray alloc] init];
    
    NSMutableArray *baseArray = (type == CONTACT_LOCAL) ? localContacts : uContacts;
    if ([Util isEmpty:key]) {
        [self resetSearchMap];
        return baseArray;
    }
    NSMutableDictionary *searchMap = (type == CONTACT_LOCAL) ? searchLocalContactsMap : searchXMPPContactsMap;
    
    return [self searchContactsWithKey:key searchMap:searchMap baseArray:baseArray];
}

-(NSArray *)searchContactsWithMainKey:(NSString *)key andType:(int)type
{
    if((type == CONTACT_LOCAL) && (self.localContactsReady == NO))
        return [[NSArray alloc] init];
    else if((type == CONTACT_uCaller) && (self.xmppContactsReady == NO))
        return [[NSArray alloc] init];
    
    NSMutableArray *baseArray = (type == CONTACT_LOCAL) ? localContacts : uContacts;
    if ([Util isEmpty:key]) {
        [self resetSearchMap];
        return baseArray;
    }
    NSMutableDictionary *searchMap = (type == CONTACT_LOCAL) ? searchLocalContactsMap : searchXMPPContactsMap;

    return [self searchContactsWithMainKey:key searchMap:searchMap baseArray:baseArray];
}

-(NSArray *)searchContactsWithKey:(NSString *)key
{
    if((self.xmppContactsReady == NO) && (self.localContactsReady == NO))
        return [[NSArray alloc] init];
    
    if ([Util isEmpty:key]) {
        [self resetSearchMap];
        return self.allContacts;
    }
    
    return [self searchContactsWithKey:key searchMap:searchContactsMap baseArray:nil];
}

-(NSArray *)searchContactsContainNumber:(NSString *)number
{
    if((self.xmppContactsReady == NO) && (self.localContactsReady == NO))
        return [[NSArray alloc] init];
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    if ([Util isEmpty:number]) {
        [self resetSearchMap];
        return resultArray;
    }
    
    NSMutableArray *searchArray = [searchContactsMap valueForKey:number];
    if(searchArray != nil)
    {
        return searchArray;
    }
    else
    {
        if(number.length > 1)
        {
            NSString *parentKey = [number substringToIndex:number.length-1];
            searchArray = [searchContactsMap valueForKey:parentKey];
        }
    }
    if(searchArray == nil)
    {
        NSMutableArray *allArray = [NSMutableArray arrayWithArray:localContacts];
        [allArray addObjectsFromArray:uContacts];
        searchArray = allArray;
    }
    
    for (UContact *contact in searchArray) {
        if([contact containMainNumber:number])
            [resultArray addObject:contact];
    }
    [searchContactsMap setValue:resultArray forKey:number];
    return resultArray;
}

-(NSArray *)searchContactsWithKey:(NSString *)key  baseArray:(NSMutableArray *)baseArray
{
    if ([Util isEmpty:key]) {
        [self resetSearchMap];
        return baseArray;
    }
    return [self searchContactsWithKey:key searchMap:searchContactsMap baseArray:baseArray];
}

-(void)clear
{
    self.xmppContactsReady = NO;
    
    for(UContact *contact in localContacts)
    {
        [contact reset];
    }
    
    [uContacts removeAllObjects];
    [uContactsMap removeAllObjects];
    [recommendContacts removeAllObjects];
}

+(BOOL)localContactsAccessGranted{
    ABAddressBookRef addressBookRef = nil;
    __block bool accessGranted = false;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error)
                                                 {
                                                     
                                                     accessGranted = granted;
                                                     dispatch_semaphore_signal(sema);
                                                 });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //dispatch_release(sema);
    }
    else
    {
        accessGranted = true;
    }
    
    return accessGranted == true;
}

+(NSString *)getNumberFromABNumber:(CFStringRef )abNumber
{
    NSMutableString *number = [NSMutableString stringWithString:(NSString *)CFBridgingRelease(abNumber)];
    [number replaceOccurrencesOfString:@"-" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [number length])];
    [number replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [number length])];
    
    //我不是普通的空格哦////////////////
    [number replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [number length])];
    /////////////////////////////////
    [number replaceOccurrencesOfString:@"(" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [number length])];
    [number replaceOccurrencesOfString:@")" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [number length])];
//    [number replaceOccurrencesOfString:@"+" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [number length])];
    [number replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [number length])];
    [number replaceOccurrencesOfString:@"#" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [number length])];
    [number replaceOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [number length])];
    [number replaceOccurrencesOfString:@";" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [number length])];
    
    return [Util getPNumber:number];
}

+(NSMutableArray *)getNumbersFromABRecord:(ABRecordRef)abRecord
{
    NSMutableArray *numbers = [[NSMutableArray alloc] init];
    if(!abRecord)
        return numbers;
    CFTypeRef numbersRef = ABRecordCopyValue(abRecord, kABPersonPhoneProperty);
    if(!numbersRef)
        return numbers;
    for (int i = 0; i < ABMultiValueGetCount(numbersRef); i++)
    {
        CFStringRef numberRef = ABMultiValueCopyValueAtIndex(numbersRef, i);
        if(!numberRef)
            continue;
        
        NSString *number = [ContactManager getNumberFromABNumber:numberRef];
        
        if([Util isEmpty:number])
        {
            continue;
        }
        
        [numbers addObject:number];
    }
    
    if(numbersRef)
        CFRelease(numbersRef);
    
    return numbers;
}

//判断是否是星标好友
-(BOOL)isStarContact:(UContact *)contact
{
    for(UContact *starContact in starContacts)
    {
        if([starContact matchContact:contact])
            return YES;
    }
    return NO;
}

-(NSMutableArray *)getStarContacts
{
    //TODO:
    return starContacts;
}

//添加星标好友
-(BOOL)addStarContact:(UContact *)contact
{
    if(starContacts.count >= 6)
    {
        return NO;
    }
    contact.isStar = YES;
    [starContacts addObject:contact];
    NSString *starNumber = (contact.hasUNumber ? contact.uNumber: contact.number);
    [starNumbers addObject:starNumber];
    UContact *matchedContact = [self getMatchContact:contact];
    matchedContact.isStar = YES;
    [dbManager addStartContact:contact];
    return YES;
}

-(void)delStarContact:(UContact *)contact
{
    contact.isStar = NO;
    for(UContact *starContact in starContacts)
    {
        if([starContact matchContact:contact])
        {
            [starContacts removeObject:starContact];
            [starNumbers removeObject:starContact.uNumber];
            [starNumbers removeObject:starContact.pNumber];
            break;
        }
    }
    UContact *matchedContact = [self getMatchContact:contact];
    matchedContact.isStar = NO;
    [dbManager delStarContact:contact];
}

-(BOOL)checkStarContacts
{
    return starContacts.count < 6;
}

-(NSMutableArray *)getBlackList:(NSString *)number
{
    return [dbManager getBlackList];
}
-(BOOL)isBlackNumber:(NSString *)number
{
    NSMutableArray *blackArray = [self getBlackList:number];
    for(NSDictionary *dict in blackArray)
    {
        NSString *blackNumber = [dict objectForKey:@"number"];
        if([number isEqualToString:blackNumber])
        {
            return YES;
        }
    }
    return NO;
}
-(void)addBlackNumber:(NSString *)number
{
    UContact *contact = [self getContact:number];
    [dbManager addBlackList:contact.name andNumber:number];
}
-(void)cancelBlackNumber:(NSString *)number
{
    [dbManager deleteNumberFromBlackList:number];
}

-(void)addNewContact:(UNewContact *)newContact
{
    @synchronized(self)
    {
        [recommendContacts insertObject:newContact atIndex:0];
        [dbManager addNewContact:newContact];
    }
}

-(void)updateNewContact:(UNewContact *)newContact
{
    @synchronized(self)
    {
        [dbManager updateNewContact:newContact];
    }
}

-(void)delNewContact:(UNewContact *)newContact
{
    @synchronized(self)
    {
        [dbManager delNewContact:newContact];
        [recommendContacts removeAllObjects];
    }
}

-(UContact *)searchContactsEqualNumber:(NSString *)number
{
    UContact *matchContact = nil;
    for(UContact *aContact in self.allContacts)
    {
        if([aContact.pNumber isEqualToString:number] || [aContact.uNumber isEqualToString:number])
        {
            matchContact = aContact;
        }
    }
    return matchContact;
}




@end
