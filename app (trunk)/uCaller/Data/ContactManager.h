//
//  ContactManager.h
//  uCaller
//
//  Created by thehuah on 13-3-3.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/ABRecord.h>
#import "UContact.h"
#import "UNewContact.h"

@interface ContactManager : NSObject

@property (nonatomic,strong) NSMutableArray *localContacts;//adressbook 好友
@property (nonatomic,strong) NSMutableArray *uContacts;//ucaller 好友
@property (nonatomic,readonly) NSMutableArray *allContacts;//uCaller和adressbook好友的集合
@property (nonatomic,readonly) NSMutableArray *phoneContacts;//uCaller和adressbook的差集
@property (nonatomic,readonly) NSMutableArray *recommendContacts;//好友推荐，好友申请（已处理，未处理）的集合
@property (atomic) BOOL localContactsReady;
@property (atomic) BOOL xmppContactsReady;

+(ContactManager *)sharedInstance;

//local
-(void)loadLocalContacts;
-(void)loadLocalContactsAsync;
-(void)reloadLocalContacts;

//ucaller
-(void)loadCacheContacts;
-(void)loadContacts:(NSArray *)users;
-(void)saveContacts;
-(void)delContactWithUID:(NSString *)uid;
-(void)updateContactRemark:(UContact *)contact;
-(void)addContact:(NSArray *)contacts;

//star contact
-(void)loadStarContacts;
-(NSMutableArray *)getStarContacts;
-(BOOL)addStarContact:(UContact *)contact;
-(void)delStarContact:(UContact *)contact;
-(BOOL)isStarContact:(UContact *)contact;//是否为星标好友
-(BOOL)checkStarContacts;

//black
-(BOOL)isBlackNumber:(NSString *)number;
-(void)addBlackNumber:(NSString *)number;
-(void)cancelBlackNumber:(NSString *)number;

//new contact
-(void)addNewContact:(UNewContact *)newContact;
-(void)updateNewContact:(UNewContact *)newContact;
-(void)delNewContact:(UNewContact *)newContact;

//show
-(UContact *)getLocalContact:(NSString *)pNumber;//取本地
-(UContact *)getUCallerContact:(NSString *)uNumber;//取呼应
-(UContact *)getContact:(NSString *)number;//number 呼应 or 手机号
-(UContact *)getContactByUID:(NSString *)uid;//不区分contact_type
-(UContact *)getContactByUNumber:(NSString *)aUNumber;//不区分contact_type

-(void)resetSearchMap;
-(NSArray *)searchContactsWithKey:(NSString *)key searchMap:(NSMutableDictionary *)searchMap baseArray:(NSMutableArray *)baseArray;
-(NSArray *)searchContactsWithKey:(NSString *)key;
-(NSArray *)searchContactsWithKey:(NSString *)key baseArray:(NSMutableArray *)baseArray;
-(NSArray *)searchContactsWithKey:(NSString *)key andType:(int)type;
-(NSArray *)searchContactsWithMainKey:(NSString *)key andType:(int)type;
-(NSArray *)searchContactsContainNumber:(NSString *)number;

+(BOOL)localContactsAccessGranted;
+(NSString *)getNumberFromABNumber:(CFStringRef )abNumber;
+(NSMutableArray *)getNumbersFromABRecord:(ABRecordRef)abRecord;

-(UContact *)searchContactsEqualNumber:(NSString *)number;//获取完全匹配到的联系人

-(void)clear;

@end
