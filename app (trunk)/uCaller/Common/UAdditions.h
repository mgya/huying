//
//  UAdditions.h
//  uCaller
//
//  Created by thehuah on 13-3-7.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>

#define COLLAPSE_TEXT_NODES		YES
#define TRIM_WHITE_SPACE		YES

#define XML_ATTRIBUTES_KEY		@"__attributes"
#define XML_COMMENTS_KEY		@"__comments"
#define XML_TEXT_KEY			@"__text"
#define XML_NAME_KEY			@"__name"

#define XML_ATTRIBUTE_PREFIX	@"_"

@interface NSNotificationCenter (uCaller)

- (void) postNotificationOnMainThread:(NSNotification *) notification;
- (void) postNotificationOnMainThread:(NSNotification *) notification waitUntilDone:(BOOL) wait;

- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object;
- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object userInfo:(NSDictionary *) userInfo;
- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object userInfo:(NSDictionary *) userInfo waitUntilDone:(BOOL) wait;

@end

@interface NSData (uCaller)

+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;

@end

@interface NSString (uCaller)

-(NSString *)substringAtIndex:(int)index;
-(BOOL)startWith:(NSString *)str;
-(BOOL)endWith:(NSString *)str;
-(BOOL)contain:(NSString *)str;
-(BOOL)isNumber;
-(BOOL)isNormalChar;
-(BOOL)isChinese;
-(NSString *)trim;
-(BOOL)containEmoji;
-(BOOL)containAbnormalChar;

- (NSString *)xmlEncodedString;

+ (NSString *)stringWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;
- (NSData *)base64DecodedData;

@end

@interface NSDictionary (uCaller)

+ (NSDictionary *)dictionaryWithXMLData:(NSData *)data;
+ (NSDictionary *)dictionaryWithXMLString:(NSString *)string;
+ (NSDictionary *)dictionaryWithXMLFile:(NSString *)path;

- (NSString *)attributeForKey:(NSString *)key;
- (NSDictionary *)attributes;
- (NSDictionary *)childNodes;
- (NSArray *)comments;
- (NSString *)nodeName;
- (NSString *)innerText;
- (NSString *)innerXML;
- (NSString *)xmlString;
-(BOOL)contain:(NSString *)key;

@end

@interface UIImage (uCaller)

+ (UIImage*)makeGrayImage:(UIImage*)sourceImage;

@end

@interface UIImageView (uCaller)

- (void)makeDefaultPhotoView:(UIFont *)font;
- (void)makePhotoViewWithImage:(UIImage *)image;
- (void)makeOneKeyBookPhotoView:(UIImage *)image;

@end

//@interface XMPPIQ (uCaller)
//
//+ (XMPPIQ *)iqWithType:(NSString *)type from:(NSString *)myJID elementID:(NSString *)eid child:(NSXMLElement *)childElement;
//
//@end
//
//@interface XMPPvCardTemp (uCaller)
//
//+ (XMPPvCardTemp *)vCardTemp;
//
//- (NSString *)mood;
//- (void)setMood:(NSString *)mood;
//
//- (NSString *)gender;
//- (void)setGender:(NSString *)gender;
//
////- (NSString *)birthday;
////- (void)setBirthday:(NSString *)bday;
//
//- (NSString *)extras;
//- (void)setExtras:(NSString *)extrasInfo;
//
//- (NSString *)infoPercent;
//- (void)setInfoPercent:(NSString *)infoPercent;
//
//- (NSString *)autoRoster;
//- (void)setAutoRoster:(NSString *)autoRoster;
//- (NSString *)autoSMS;
//- (void)setAutoSMS:(NSString *)autoSMS;
//
//@end
//
//@interface XMPPPresence (uCaller)
//
//+ (XMPPPresence *)presenceWithType:(NSString *)type to:(XMPPJID *)to status:(NSString *)status;
//+ (XMPPPresence *)presenceWithShow:(NSString *)showValue;
//
//@end
//
//@interface XMPPRoster (uCaller)
//
//- (void)addUser:(XMPPJID *)jid withRemark:(NSString *)remark;
//
//@end
