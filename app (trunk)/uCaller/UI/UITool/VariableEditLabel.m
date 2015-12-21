//
//  VariableEditLabel.m
//  uCaller
//
//  Created by HuYing on 15/5/31.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "VariableEditLabel.h"
#import "Util.h"
#import "UDefine.h"


@implementation VariableEditLabel
{
    CGRect curFrame;
    
    UILabel *contentLabel;
    UIButton *editBtn;
    
    NSString *content;
}
@synthesize delegate;
@synthesize editType;
@synthesize showLabelColor;

-(id)init
{
    self = [super init];
    if (self) {
        contentLabel = [[UILabel alloc]init];
        editBtn = [[UIButton alloc]init];
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        curFrame = frame;
        self.backgroundColor = [UIColor clearColor];
        

        contentLabel = [[UILabel alloc]init];
        [self addSubview:contentLabel];
        
    }
    return self;
}

-(void)showView:(NSString *)contentStr refreshFrame:(CGRect )newFrame
{
    content = contentStr;
    contentLabel.text = content;
    
    if (editType == tagsShow) {
        curFrame = newFrame;
        self.frame = curFrame;
        self.backgroundColor = [UIColor clearColor];
        
        contentLabel.frame = CGRectMake(0, 0, curFrame.size.width, curFrame.size.height);
        contentLabel.textColor = showLabelColor;
        contentLabel.font = [UIFont systemFontOfSize:12];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.layer.borderColor = showLabelColor.CGColor;
        CGFloat borderWidth;
        if (iOS7) {
            borderWidth = 0.5;
        }
        else
        {
            borderWidth = 0.75;
        }
        contentLabel.layer.borderWidth = borderWidth;
        contentLabel.layer.cornerRadius = SelfTags_RornerRadius;
        contentLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:contentLabel];
    }
    else if (editType == tagsDelete)
    {
        UIImage *bImage = [UIImage imageNamed:@"tagsName_delete"];
        curFrame = CGRectMake(newFrame.origin.x, newFrame.origin.y, newFrame.size.width+bImage.size.width/2, newFrame.size.height);
        self.frame = curFrame;
        
        CGFloat lHeight = 25.0;
        contentLabel.frame = CGRectMake(0, bImage.size.height/2, curFrame.size.width-bImage.size.width/2, lHeight);
        contentLabel.textColor = SelfTagsBlueColor;
        contentLabel.font = [UIFont systemFontOfSize:12];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.layer.borderColor = SelfTagsBlueColor.CGColor;
        contentLabel.layer.borderWidth = 0.3;
        contentLabel.layer.cornerRadius = SelfTags_RornerRadius;
        contentLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:contentLabel];
        
        
        [editBtn setImage:bImage forState:(UIControlStateNormal)];
        editBtn.frame = CGRectMake(curFrame.size.width-bImage.size.width, 0, bImage.size.width, bImage.size.height);
        [editBtn addTarget:self action:@selector(deleteBtnFunction) forControlEvents:(UIControlEventTouchUpInside)];
        editBtn.hidden = YES;
        if (![Util isEmpty:contentLabel.text] ) {
            editBtn.hidden = NO;
        }
        [self addSubview:editBtn];
    }
    
}

-(void)deleteBtnFunction
{
    if (delegate && [delegate respondsToSelector:@selector(clearContent:)]) {
        [delegate performSelector:@selector(clearContent:) withObject:content];
        
    }
}

@end
