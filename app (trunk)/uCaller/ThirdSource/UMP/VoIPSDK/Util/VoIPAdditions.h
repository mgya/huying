//
//  VoIPAdditions.h
//  VoIPSDK
//
//  Created by thehuah on 13-3-7.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (VoIPSDK)

- (void) VoIPSDK_postNotificationOnMainThread:(NSNotification *) notification;
- (void) VoIPSDK_postNotificationOnMainThread:(NSNotification *) notification waitUntilDone:(BOOL) wait;

- (void) VoIPSDK_postNotificationOnMainThreadWithName:(NSString *) name object:(id) object;
- (void) VoIPSDK_postNotificationOnMainThreadWithName:(NSString *) name object:(id) object userInfo:(NSDictionary *) userInfo;
- (void) VoIPSDK_postNotificationOnMainThreadWithName:(NSString *) name object:(id) object userInfo:(NSDictionary *) userInfo waitUntilDone:(BOOL) wait;

@end

@interface NSData (VoIPSDK)

+ (NSData *)VoIPSDK_dataWithBase64EncodedString:(NSString *)string;
- (NSString *)VoIPSDK_base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)VoIPSDK_base64EncodedString;

@end

@interface NSString (VoIPSDK)

-(NSString *)VoIPSDK_substringAtIndex:(int)index;
-(BOOL)VoIPSDK_startWith:(NSString *)str;
-(BOOL)VoIPSDK_contain:(NSString *)str;
-(BOOL)VoIPSDK_isNumber;
-(BOOL)VoIPSDK_isNormalChar;
-(NSString *)VoIPSDK_trim;
-(BOOL)VoIPSDK_containEmoji;

+ (NSString *)VoIPSDK_stringWithBase64EncodedString:(NSString *)string;
- (NSString *)VoIPSDK_base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)VoIPSDK_base64EncodedString;
- (NSString *)VoIPSDK_base64DecodedString;
- (NSData *)VoIPSDK_base64DecodedData;

@end

@interface NSDictionary (VoIPSDK)

-(BOOL)VoIPSDK_contain:(NSString *)key;

@end