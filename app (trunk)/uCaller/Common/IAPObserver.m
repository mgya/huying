//
//  IAPObserver.m
//  QQVoice
//
//  Created by Rain on 13-6-28.
//  Copyright (c) 2013年 X. All rights reserved.
//

#import "IAPObserver.h"
#import "NSObject+SBJson.h"

@implementation IAPObserver
@synthesize delegate;

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	NSLog(@"paymetnQueue");
	for (SKPaymentTransaction* transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				NSLog(@"Complete Transaction");
				[self onPurchased:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				[self onFailed:transaction];
				break;
            case SKPaymentTransactionStatePurchasing:
			case SKPaymentTransactionStateRestored:
				break;
			default:
				break;
		}
	}
}


//苹果返回的数据
- (void)onPurchased: (SKPaymentTransaction *)transaction
{
	NSLog(@"Transaction　complete");
    NSString* jsonObjectString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes
                                       length:transaction.transactionReceipt.length];
	NSDictionary *tempDict = [NSDictionary dictionaryWithObject:jsonObjectString forKey:@"receipt-data"];
	NSString *josnValue = [tempDict JSONRepresentation];
    NSLog(@"%@", josnValue);
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    if (delegate != nil && [delegate respondsToSelector:@selector(onIAPSucceed:)]) {
        [delegate onIAPSucceed:josnValue];
    }
}

- (void)onFailed: (SKPaymentTransaction *)transaction
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"faliedTransaction" object:nil];
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    BOOL bCancel = NO;
    if (transaction.error.code == SKErrorPaymentCancelled) {
        bCancel = YES;
    }
    
    if (delegate != nil && [delegate respondsToSelector:@selector(onIAPFailed:)]) {
        [delegate onIAPFailed:bCancel];
    }
}

- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


@end
