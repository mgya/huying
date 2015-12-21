//
//  MenuCallView.h
//  QQVoice
//
//  Created by thehuah on 11-10-19.
//  Copyright 2011年 X. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushButton.h"

#define PUSHBUTTONNUMBER 3

@protocol MenuCallViewDelegate <NSObject>

- (void)menuButtonClicked:(PushButton *)button;

@end

@interface MenuCallView : UIView 
{
    PushButton *_buttons[PUSHBUTTONNUMBER];
}

@property (nonatomic,assign)  id<MenuCallViewDelegate> delegate;

- (PushButton *)buttonAtPosition:(NSInteger)button;
- (void)setTitle:(NSString *)title image:(UIImage *)image highlighted:(UIImage *)selImage forPosition:(NSInteger)pos;

@end



