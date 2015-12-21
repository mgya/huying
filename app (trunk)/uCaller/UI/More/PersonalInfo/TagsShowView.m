//
//  TagsShowView.m
//  uCaller
//
//  Created by HuYing on 15/5/29.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "TagsShowView.h"
#import "Util.h"

@implementation TagsShowView
{
    CGRect curFrame;
    
    UILabel *contentLabel;
    UIButton *deleteBtn;
    
    NSString *content;
}
@synthesize delegate;
@synthesize clearShow;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        curFrame = frame;
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *bImage = [UIImage imageNamed:@"tagsName_delete"];
        CGFloat lHeight = 25.0;
        contentLabel = [[UILabel alloc]init];
        contentLabel.frame = CGRectMake(0, bImage.size.height/2, curFrame.size.width-bImage.size.width/2, lHeight);
        contentLabel.textColor = [UIColor blueColor];
        contentLabel.font = [UIFont systemFontOfSize:12];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.layer.borderColor = [UIColor blueColor].CGColor;
        contentLabel.layer.borderWidth = 0.3;
        contentLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:contentLabel];
        
        
        deleteBtn = [[UIButton alloc]init];
        [deleteBtn setImage:bImage forState:(UIControlStateNormal)];
        deleteBtn.frame = CGRectMake(curFrame.size.width-bImage.size.width, 0, bImage.size.width, bImage.size.height);
        [deleteBtn addTarget:self action:@selector(deleteBtnFunction) forControlEvents:(UIControlEventTouchUpInside)];
        deleteBtn.hidden = YES;
        [self addSubview:deleteBtn];
        
    }
    return self;
}

-(void)showView:(NSString *)contentStr
{
    content = contentStr;
    contentLabel.text = content;
    if (!clearShow && ![Util isEmpty:contentLabel.text] ) {
        deleteBtn.hidden = NO;
    }
}

-(void)deleteBtnFunction
{
    if (delegate && [delegate respondsToSelector:@selector(clearContent:)]) {
        [delegate performSelector:@selector(clearContent:) withObject:content];
        contentLabel.text = @"";
        deleteBtn.hidden = YES;
    }
}

@end
