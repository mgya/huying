//
//  TicketsTask.m
//  uCaller
//
//  Created by HuYing on 15-1-15.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "TicketsTaskView.h"

@implementation TicketsTaskView
@synthesize delegate;
@synthesize qiangpiaoBtn;
@synthesize reDialBtn;
@synthesize shareBtn;

-(id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        //抢票秘籍
        UIImage *imageQiang = [UIImage imageNamed:@"ticket_qiangpiao_nor"];
        float widthLabel = imageQiang.size.width;
        UILabel *qiangUpLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, widthLabel, 14)];
        qiangUpLabel.text = @"没买到?";
        qiangUpLabel.font = [UIFont systemFontOfSize:13];
        qiangUpLabel.textColor = [UIColor whiteColor];
        qiangUpLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:qiangUpLabel];
        
        qiangpiaoBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, qiangUpLabel.frame.origin.y+qiangUpLabel.frame.size.height+17, imageQiang.size.width, imageQiang.size.height)];
        [qiangpiaoBtn setImage:imageQiang forState:(UIControlStateNormal)];
        [qiangpiaoBtn setImage:[UIImage imageNamed:@"ticket_qiangpiao_sel"] forState:(UIControlStateHighlighted)];
        [qiangpiaoBtn addTarget:self action:@selector(qiangpiaoAction) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:qiangpiaoBtn];
        
        UILabel *qiangDownLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, qiangpiaoBtn.frame.origin.y+qiangpiaoBtn.frame.size.height+17, widthLabel, 14)];
        qiangDownLabel.text = @"抢票秘籍";
        qiangDownLabel.font = [UIFont systemFontOfSize:13];
        qiangDownLabel.textColor = [UIColor whiteColor];
        qiangDownLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:qiangDownLabel];
        
        //重拨
        UIImage *imageReDial = [UIImage imageNamed:@"ticket_redial_nor"];
        UILabel *reDialUpLabel = [[UILabel alloc]initWithFrame:CGRectMake(qiangUpLabel.frame.origin.x+qiangUpLabel.frame.size.width+50, 0, widthLabel, 14)];
        reDialUpLabel.text = @"再打一个!";
        reDialUpLabel.font = [UIFont systemFontOfSize:13];
        reDialUpLabel.textColor = [UIColor whiteColor];
        reDialUpLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:reDialUpLabel];
        
        reDialBtn = [[UIButton alloc]initWithFrame:CGRectMake(reDialUpLabel.frame.origin.x, reDialUpLabel.frame.origin.y+reDialUpLabel.frame.size.height+17, imageQiang.size.width, imageQiang.size.height)];
        [reDialBtn setImage:imageReDial forState:(UIControlStateNormal)];
        [reDialBtn setImage:[UIImage imageNamed:@"ticket_redial_sel"] forState:(UIControlStateHighlighted)];
        [reDialBtn addTarget:self action:@selector(reDialAction) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:reDialBtn];
        
        UILabel *reDialDownLabel = [[UILabel alloc]initWithFrame:CGRectMake(reDialBtn.frame.origin.x, reDialBtn.frame.origin.y+reDialBtn.frame.size.height+17, widthLabel, 14)];
        reDialDownLabel.text = @"重拨";
        reDialDownLabel.font = [UIFont systemFontOfSize:13];
        reDialDownLabel.textAlignment = NSTextAlignmentCenter;
        reDialDownLabel.textColor = [UIColor whiteColor];
        [self addSubview:reDialDownLabel];
        
        //分享
        UIImage *imageShare = [UIImage imageNamed:@"ticket_share_nor"];
        UILabel *shareUpLabel = [[UILabel alloc]initWithFrame:CGRectMake(reDialUpLabel.frame.origin.x+reDialUpLabel.frame.size.width+50, 0, widthLabel, 14)];
        shareUpLabel.text = @"定好喽!";
        shareUpLabel.font = [UIFont systemFontOfSize:13];
        shareUpLabel.textColor = [UIColor whiteColor];
        shareUpLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:shareUpLabel];
        
        shareBtn = [[UIButton alloc]initWithFrame:CGRectMake(shareUpLabel.frame.origin.x, shareUpLabel.frame.origin.y+shareUpLabel.frame.size.height+17, imageQiang.size.width, imageQiang.size.height)];
        [shareBtn setImage:imageShare forState:(UIControlStateNormal)];
        [shareBtn setImage:[UIImage imageNamed:@"ticket_share_sel"] forState:(UIControlStateHighlighted)];
        [shareBtn addTarget:self action:@selector(shareAction) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:shareBtn];
        
        UILabel *shareDownLabel = [[UILabel alloc]initWithFrame:CGRectMake(shareBtn.frame.origin.x, shareBtn.frame.origin.y+shareBtn.frame.size.height+17, widthLabel, 14)];
        shareDownLabel.text = @"分享";
        shareDownLabel.font = [UIFont systemFontOfSize:13];
        shareDownLabel.textAlignment = NSTextAlignmentCenter;
        shareDownLabel.textColor = [UIColor whiteColor];
        [self addSubview:shareDownLabel];
        
    }
    return self;
}

#pragma mark -----BtnAction-----
-(void)qiangpiaoAction
{
    if (delegate && [delegate respondsToSelector:@selector(ticketsTaskQiangpiaoAction)]) {
        [delegate ticketsTaskQiangpiaoAction];
    }
}

-(void)reDialAction
{
    if (delegate && [delegate respondsToSelector:@selector(ticketsTaskReDialAction)]) {
        [delegate ticketsTaskReDialAction];
    }
}

-(void)shareAction
{
    if (delegate && [delegate respondsToSelector:@selector(ticketsTaskShareAction)]) {
        [delegate ticketsTaskShareAction];
    }
}

@end
