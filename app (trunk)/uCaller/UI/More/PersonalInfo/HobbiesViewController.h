//
//  HobbiesViewController.h
//  uCaller
//
//  Created by HuYing on 15/5/28.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"

@protocol EditHobbiesDelegate <NSObject>

@optional
-(void)onHobbiesUpdated:(NSString *)hobbies;

@end

@interface HobbiesViewController : BaseViewController<UITextViewDelegate>

@property (nonatomic,UWEAK) id<EditHobbiesDelegate>delegate;

@end
