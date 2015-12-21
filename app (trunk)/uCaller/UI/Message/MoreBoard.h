//
//  MoreBoard.h
//  uCaller
//
//  Created by 张新花花花 on 15/7/24.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrayPageControl.h"
#import "UDefine.h"
@protocol callBarBtnDelegate <NSObject>

@optional

-(void)callBarButton;
-(void)msgBarButton;
-(void)locBarButton;
-(void)cardBarButton;

@end

@interface MoreBoard : UIView<UIScrollViewDelegate>{
    UIScrollView *moreView;
    GrayPageControl *facePageControl;
}


@property (nonatomic, retain) UITextField *inputTextField;
@property (nonatomic, retain) UITextView *inputTextView;
@property (nonatomic,UWEAK) id<callBarBtnDelegate> delegate;
@end
