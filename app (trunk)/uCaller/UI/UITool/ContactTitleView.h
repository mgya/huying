//
//  ChangeView.h
//  uCalling
//
//  Created by changzheng-Mac on 13-3-13.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDefine.h"

@protocol ContactTitleViewDelegate<NSObject>
@optional
- (void)titleTouch:(BOOL)bchange;
@end

@interface ContactTitleView : UIView

@property (nonatomic, UWEAK) id<ContactTitleViewDelegate> contactTitleDelegate;
@property (nonatomic,strong) NSString *leftTitle;
@property (nonatomic,strong) NSString *rightTitle;
@property (nonatomic) BOOL bchange;

-(void)changeView;
-(void)changeViewTow;

@end
