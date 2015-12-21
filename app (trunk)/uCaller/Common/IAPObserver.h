//
//  IAPObserver.h
//  QQVoice
//
//  Created by Rain on 13-6-28.
//  Copyright (c) 2013年 X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <StoreKit/SKPaymentTransaction.h>

@protocol IAPDelegate;

@interface IAPObserver : NSObject<SKPaymentTransactionObserver>

@property(nonatomic,assign) NSObject<IAPDelegate> *delegate;

@end

@protocol IAPDelegate

@optional
-(void)onIAPSucceed:(NSString*)receiptdata;
-(void)onIAPFailed:(BOOL)bCancel;

@end