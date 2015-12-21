//
//  MoodViewController.h
//  uCaller
//
//  Created by HuYing on 15/5/22.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "MoodTextView.h"

@protocol EditMoodDelegate <NSObject>

@optional
-(void)onMoodUpdated:(NSString *)mood;

@end

@interface MoodViewController : BaseViewController<UITextViewDelegate,MoodTextViewDelegate>

@property (nonatomic,UWEAK) id<EditMoodDelegate>delegate;

@end
