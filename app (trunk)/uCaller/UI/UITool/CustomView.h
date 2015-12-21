//
//  CustomView.h
//  QQVoice
//
//  Created by thehuah on 11-11-7.
//  Copyright 2011年 X. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDefine.h"

@class CustomButton;

@protocol CustomDelegate<NSObject>
@optional
- (void)backTouch:(UIView *)aView;
- (void)beginEdit:(CustomButton *)aButton;
- (void)endEdit:(CustomButton *)aButton;
@end

@interface CustomView : UIScrollView
{
    id<CustomDelegate> U__WEAK touchDelegate;
}

@property (nonatomic, UWEAK) id<CustomDelegate> touchDelegate;

@end

@interface CustomTableView : UITableView
{
    id<CustomDelegate> U__WEAK touchDelegate;
}

@property (nonatomic,UWEAK) id<CustomDelegate> touchDelegate;

@end

@interface CustomButton : UIButton <UITextFieldDelegate>
{
    UILabel *label;
    UITextField *textField;
    NSString *U__WEAK placeText;
    UIButton *returnButton;
    id<CustomDelegate> U__WEAK buttonDelegate;
    BOOL isEditing;
    
    BOOL fixedKeyboard;
    
    UIScrollView *srView;
    CGFloat keyboardTop;
    
    CGRect keyboardFrame;
    
    float osVer;
    
    BOOL isActive;
}

@property (nonatomic,UWEAK) id<CustomDelegate> buttonDelegate;
@property (nonatomic,strong) UIScrollView *srView;
@property (nonatomic,readonly) UILabel *label;
@property (nonatomic,readonly) UITextField *textField;
@property (nonatomic,assign) NSString *tfText;
@property (nonatomic,UWEAK) NSString *placeText;
@property (nonatomic,assign) NSString *returnText;
@property (nonatomic) SEL returnAction;
@property (nonatomic) NSInteger tfTag; 
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic) BOOL isEditing;
@property (nonatomic) BOOL fixedKeyboard;

-(id)initWith:(CGRect)aFrame label:(NSString *)aLabelText placeholder:(NSString *)aPlaceText 
   returnText:(NSString *)aReturnText returnAction:(SEL)aReturnAction;

-(void)customReturnKey;

-(void)activate;
-(void)inactivate;

@end



