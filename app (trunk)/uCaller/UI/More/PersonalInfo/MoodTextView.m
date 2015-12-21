//
//  MoodTextView.m
//  uCaller
//
//  Created by HuYing on 15-3-24.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "MoodTextView.h"
#import "UDefine.h"

@implementation MoodTextView
{
    UILabel *placeholderLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat placeHight;
        if (iOS7) {
            placeHight = 5.0;
        }
        else
        {
            placeHight = 8.0;
        }
        placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,placeHight,frame.size.width-2*placeHight,20)];
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

-(void)setContentInset:(UIEdgeInsets)contentInset
{
    contentInset.bottom = 8.0;
}

- (void)setContentSize:(CGSize)contentSize
{
    CGSize oriSize = self.contentSize;
    [super setContentSize:contentSize];
    
    if(oriSize.height != self.contentSize.height)
    {
        CGRect newFrame = self.frame;
        newFrame.size.height = self.contentSize.height;
        self.frame = newFrame;
        if([self.delegate respondsToSelector:@selector(textView:heightChanged:)])
        {
            [self.delegate textView:self heightChanged:self.contentSize.height - oriSize.height];
        }
    }
}


@end
