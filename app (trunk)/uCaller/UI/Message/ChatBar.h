//
//  ChatBar.h
//  uCalling
//
//  Created by thehuah on 13-4-25.
//  Copyright (c) 2013年 Dev. All rights reserved.
//


#define  CHATBAR_HEIGHT 43
#define  CHATBUTTON_WIDTH 34

#define MAX_TEXT_NUMBER 2000

#import <UIKit/UIKit.h>
#import "UIExpandingTextView.h"
#import "LongPressButton.h"
#import <AVFoundation/AVFoundation.h>

#import "UDefine.h"
@protocol ChatBarDelegate<NSObject>
-(void)callBarButton;
-(void)msgBarButton;
-(void)locBarButton;
-(void)cardBarButton;
-(void)sendText:(NSString *)text;
-(void)startSpeak;
-(void)stopSpeak;
-(void)heightWillChange:(float)diff;
//added by yfCui
-(void)setRecordingState;
-(void)setCancelRecordingState;

- (void)callBarButtonNow;
- (void)msgBarButtonNow;
- (void)locBarButtonNow;
- (void)cardBarButtonNow;
@end

@interface ChatBar : UIToolbar<UIExpandingTextViewDelegate,LongPressedDelegate>

@property (UWEAK) NSObject<ChatBarDelegate> *delegate;
@property (nonatomic,strong) UIView *superView;
@property CGRect initialFrame;
@property CGRect expandFrame;

@property (strong,nonatomic) UIExpandingTextView *inputTextView;
@property (strong,nonatomic) LongPressButton *speakButton;
@property (strong,nonatomic) UIButton *switchButton;
@property (strong,nonatomic) UIButton *sendButton;

@property BOOL speakOn;


-(id)initFromView:(UIView *)superView;

-(void)dismissKeyBoard;

@end
