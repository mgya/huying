//
//  ChangeView.h
//  uCalling
//
//  Created by changzheng-Mac on 13-3-13.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDefine.h"

@protocol SwitchButtonDelegate<NSObject>

@optional
- (void)changeButton:(BOOL)bLeft;
@end

@interface SwitchButton : UIView

@property (nonatomic, UWEAK) id<SwitchButtonDelegate> switchDelegate;
@property (nonatomic,strong) NSString *leftTitle;
@property (nonatomic,strong) NSString *rightTitle;

-(void)changeButton;
-(void)setLeftImage:(UIImage *)norImgLeft Sel:(UIImage *)selImgLeft;
-(void)setRightImage:(UIImage *)norImgRight Sel:(UIImage *)selImgRight;
-(void)resetTextColor;
-(BOOL)IsSelectLeft;

@end
