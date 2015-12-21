//
//  MoodTextView.h
//  uCaller
//
//  Created by HuYing on 15-3-24.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MoodTextView;

@protocol MoodTextViewDelegate <NSObject>

@optional

-(void)textView:(MoodTextView *)textView heightChanged:(NSInteger)height;

@end

@interface MoodTextView : UITextView

@property (assign, nonatomic) id<UITextViewDelegate,MoodTextViewDelegate> delegate;

-(void)setPlaceHoder:(NSString *)placeholder;

@end
