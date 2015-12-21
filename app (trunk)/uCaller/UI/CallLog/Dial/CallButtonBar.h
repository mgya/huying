//
//  CallButtonBar.h
//  uCalling
//
//  Created by thehuah on 11-10-19.
//  Copyright 2011年 X. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallButtonBar : UIView
{
    UIButton *button;
    UIButton *button2;
    
    NSString *title;
    NSString *smallTitle, *bigTitle;
    
}

@property (nonatomic, strong)  UIButton *button;
@property (nonatomic, strong)  UIButton *button2;
@property (nonatomic, strong)  UIButton *messageBtn;
@property (nonatomic, strong)  NSString *smallTitle , *bigTitle;

- (id)initWithDefaultSize;
- (id)initWithFrame:(CGRect)rect;
- (id)initForIncomingCallWaiting;
- (id)initForEndCall;

-(void)hideMessage:(BOOL)mHide;

+ (UIButton *)createButtonWithTitle:(NSString *)title
                              frame:(CGRect)frame
                         bgImage:(UIImage *)bgImage;

@end
