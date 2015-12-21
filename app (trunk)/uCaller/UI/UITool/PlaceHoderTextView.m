//
//  PlaceHoderTextView.m
//  uCaller
//
//  Created by 崔远方 on 14-4-18.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "PlaceHoderTextView.h"

@implementation PlaceHoderTextView
{
    UILabel *placeholderLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.delegate = self;
        
        placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,5,frame.size.width-10,20)];
        placeholderLabel.backgroundColor = [UIColor clearColor];
        placeholderLabel.textColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:198/255.0 alpha:1.0];
        [self addSubview:placeholderLabel];
        [self textViewDidChange:self];
    }
    return self;
}

-(void)setPlaceHoder:(NSString *)placeholder
{
    placeholderLabel.text = placeholder;
    placeholderLabel.font = self.font;

}

-(void)textViewDidChange:(UITextView *)textView
{
    if(textView.text.length == 0)
        placeholderLabel.alpha = 1;
    else
        placeholderLabel.alpha = 0;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self textViewDidChange:textView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
