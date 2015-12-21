//
//  CustomSwitch.h
//  yunhaocc
//
//  Created by apple on 13-3-12.
//  Copyright (c) 2013年 bianheshan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSwitch : UISlider {
BOOL on;
UIColor *tintColor;
UIView *clippingView;
UILabel *rightLabel;
UILabel *leftLabel;

// private member
BOOL m_touchedSelf;
}

@property(nonatomic,getter=isOn) BOOL on;
@property (nonatomic,strong) UIColor *tintColor;
@property (nonatomic,strong) UIView *clippingView;
@property (nonatomic,strong) UILabel *rightLabel;
@property (nonatomic,strong) UILabel *leftLabel;

+ (CustomSwitch *) switchWithLeftText: (NSString *) tag1 andRight: (NSString *) tag2;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end

