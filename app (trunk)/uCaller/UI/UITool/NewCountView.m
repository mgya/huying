//
//  NewCountView.m
//  CloudCC
//
//  Created by changzheng-Mac on 13-5-3.
//  Copyright (c) 2013年 changzheng-Mac. All rights reserved.
//

#import "NewCountView.h"
#import "UDefine.h"

@implementation NewCountView
{
    int mCount;
    UILabel *bubbleText;
    UIImageView *bubbleImageView;
}

@synthesize mCount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // build single chat bubble cell with given text
        UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
        returnView.backgroundColor = [UIColor clearColor];
        
        bubbleImageView = [[UIImageView alloc] init];
        bubbleText = [[UILabel alloc] init];
        UIFont *font = [UIFont systemFontOfSize:13];
        bubbleText.font = font;
        bubbleText.backgroundColor = [UIColor clearColor];
        bubbleText.numberOfLines = 0;
        bubbleText.lineBreakMode = NSLineBreakByWordWrapping;
        bubbleText.textColor = [UIColor grayColor];
        
        [self addSubview:bubbleImageView];
        [self addSubview:bubbleText];
    }
    return self;
}

//设置未读信息数量
-(void)setCount:(NSInteger)count
{
    NSString *countStr =[[NSString alloc] initWithFormat:@"%ld",count];
    
    if (count >= 100)
    {
        bubbleText.text = @"....";
    }else
    {
        bubbleText.text = countStr;
    }
    
    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize size = [countStr sizeWithFont:font constrainedToSize:CGSizeMake(150.0f, 1000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
    if(count == 0)
    {
        self.hidden = YES;
        return;
    }
    self.hidden = NO;
    bubbleText.minimumFontSize = 10;
    //modified by fyCui 用 adjustsLetterSpacingToFitWidth iOS5会崩溃
    bubbleText.adjustsFontSizeToFitWidth = YES;
    if(count > 9)
    {
//        bubbleImageView.image = [UIImage imageNamed:@"uc_new_count_long_bg.png"];
        bubbleImageView.frame = CGRectMake(0.0f, 0.0f, 24, 16);
        bubbleText.frame = CGRectMake(2, 0, 20, 16);
        if(count >= 100)
        {
            bubbleText.frame = CGRectMake(2, -3, 20, 16);
        }
        bubbleText.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
//        bubbleImageView.image = [UIImage imageNamed:@"uc_new_count_bg.png"];
        bubbleImageView.frame = CGRectMake(0.0f, 0.0f, 16.0f, 16.0f);
        bubbleText.frame = CGRectMake(1, 0.0f, 16, 16);
        if(!iOS7)
        {
            bubbleText.frame = CGRectMake(0, 0, 16, 16);
        }
        bubbleText.textAlignment = NSTextAlignmentCenter;
    }
}

-(void)setText:(NSString *)text
{
    bubbleText.text = text;
//    bubbleImageView.image = [UIImage imageNamed:@"msg_radio.png"];
    bubbleImageView.frame = CGRectMake(0.0f, 0.0f, 39.0f, 19.0f);
    bubbleText.frame = CGRectMake(3,3,self.frame.size.width,self.frame.size.height-6);
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
