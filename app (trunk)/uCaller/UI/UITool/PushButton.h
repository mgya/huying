//
//  PushButton.h
//  QQVoice
//
//  Created by thehuah on 11-10-19.
//  Copyright 2011年 X. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PushButton : UIButton
{
    CGRect _contentRect;
    
}

@property (nonatomic, assign)BOOL hasSelected;

- (void)setContentRect:(CGRect)rect;

@end
