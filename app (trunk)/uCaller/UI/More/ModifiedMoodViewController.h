//
//  ModifiedMoodViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-4-29.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "MoodTextView.h"

@protocol EditMoodDelegate <NSObject>

@optional
-(void)onMoodUpdated:(NSString *)mood;

@end

@interface ModifiedMoodViewController : BaseViewController<UITextViewDelegate,MoodTextViewDelegate>

@property (nonatomic,UWEAK) id<EditMoodDelegate> delegate;

@end
