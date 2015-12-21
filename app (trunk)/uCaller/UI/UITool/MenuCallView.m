//
//  MenuCallView.m
//  QQVoice
//
//  Created by thehuah on 11-10-19.
//  Copyright 2011年 X. All rights reserved.
//

#import "MenuCallView.h"


@implementation MenuCallView
{
    CGFloat buttonWidth;
    CGFloat buttonHeight;
}

@synthesize delegate;

- (void)preloadButtons
{
    int i;
    CGRect rect = {0.0f, 0.0f, 0.0f, 0.0f};
    NSString *bg, *bgSel;
    UIImage *image, *selectedImage;
    
    for (i = 0; i < PUSHBUTTONNUMBER; ++i)
    {
        bg    = [NSString stringWithFormat:@"callmenu_%d.png", i];
        bgSel = [NSString stringWithFormat:@"callmenu_%d.png", i];
        image = [UIImage imageNamed:bg];
        selectedImage = [UIImage imageNamed:bgSel];
        
        rect.size = CGSizeMake(buttonWidth, buttonHeight);
        PushButton *button = [[PushButton alloc] initWithFrame:rect];
        
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
        [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
                
        [button setTag:i];
        [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
   
        CGRect content = CGRectMake(18.0, 15.0, 40.0, 40.0);
        if (i == 0)
            content.origin.x += 0.0;

        [button setContentRect: content];
  
        _buttons[i] = button;
        [self addSubview:_buttons[i]];
        
        rect.origin.x += (rect.size.width+2);
    }
}

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        CGRect curFrame = frame;
        buttonWidth = curFrame.size.width/PUSHBUTTONNUMBER;
        buttonHeight = curFrame.size.height;
        
        
        [self preloadButtons];
    }
    return self;
}

- (void)clicked:(UIButton *)button
{
    PushButton *pushButton = (PushButton *)button;
    pushButton.hasSelected = !pushButton.hasSelected;
    if ([delegate respondsToSelector:@selector(menuButtonClicked:)])
    {
        [delegate menuButtonClicked:pushButton];
    }
}



- (PushButton *)buttonAtPosition:(NSInteger)pos
{
    if (pos < 0 || pos > PUSHBUTTONNUMBER-1)
        return nil;
    return _buttons[pos];
}

- (void)setTitle:(NSString *)title image:(UIImage *)image highlighted:(UIImage *)selImage forPosition:(NSInteger)pos
{
    if (pos < 0 || pos > PUSHBUTTONNUMBER-1)
        return;
    if (image)
    {
        CGRect rect;
        if (pos == 0)
        {
            rect = CGRectMake(0.0, (buttonHeight-image.size.height)/2, image.size.width, image.size.height);
        }
        else if (pos == 1) {
            rect = CGRectMake((buttonWidth-image.size.width)/2, (buttonHeight-image.size.height)/2, image.size.width, image.size.height);
        }
        else if (pos == 2)
        {
            rect = CGRectMake(buttonWidth-image.size.width, (buttonHeight-image.size.height)/2, image.size.width, image.size.height);
        }
        
        [_buttons[pos] setContentRect:rect];
        [_buttons[pos] setImage:image forState:UIControlStateNormal];
        [_buttons[pos] setImage:image forState:UIControlStateSelected];
    }
    if(selImage)
    {
        [_buttons[pos] setImage:selImage forState:UIControlStateHighlighted];
    }
    if (title)
    {
#ifdef __IPHONE_3_0
        _buttons[pos].titleLabel.font = [UIFont systemFontOfSize:[UIFont buttonFontSize] - 2.];
#else
        [_buttons[pos] setFont:[UIFont systemFontOfSize:[UIFont buttonFontSize] - 2.]];
#endif
        [_buttons[pos] setTitle:title forState:UIControlStateNormal];
    }
}

@end
