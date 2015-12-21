//
//  XAlert.h
//  uCalling
//
//  Created by thehuah on 7/11/11.
//  Copyright 2011 X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XAlertView.h"

@interface XAlert : NSObject

+(void)showAlert:(NSString *)aTitle message:(NSString *)aMessage buttonText:(NSString *)aText;

+(BOOL)ask: (NSString *) question isError:(BOOL)isError;  
+(BOOL)confirm:(NSString *) statement isError:(BOOL)isError;  
+(BOOL)ask: (NSString *) question yes:(NSString*)strYes no:(NSString*)strNO isError:(BOOL)isError;
+(BOOL)ask: (NSString *)question message:(NSString *)aMessage yes:(NSString*)strYes no:(NSString*)strNO isError:(BOOL)isError;
+(BOOL)alert: (NSString *)aTitle message:(NSString *)aMessage buttonText:(NSString *)aText isError:(BOOL)isError;
+(NSUInteger)ask: (NSString *)question withCancel: (NSString *) cancelButtonTitle withButtons: (NSArray *) buttons isError:(BOOL)isError;
+(void)alertWith: (NSString *)aTitle message:(NSString *)aMessage buttonText:(NSString *)aText isError:(BOOL)isError;
+(NSUInteger)queryWith: (NSString *)aTitle message:(NSString *)aMessage button1: (NSString *)button1 button2: (NSString *)button2 isError:(BOOL)isError;

+(NSUInteger) queryWith: (NSString *)aMessage button1: (NSString *)button1 button2: (NSString *)button2 wait:(NSInteger)time ;

//added by cui
+(void)showInviteSuccessAlertView;
+(void)showAutomaticallyCutAlertView:(NSString *)mString;
+(void)showDisabledNetWorkAlertView;
//end

@end  
