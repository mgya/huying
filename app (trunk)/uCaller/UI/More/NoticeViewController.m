//
//  NoticeViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-7-1.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "NoticeViewController.h"
#import "UDefine.h"
#import "UConfig.h"
#import "Util.h"

@interface NoticeViewController ()
{
    UIView *bgView;
}

@end

@implementation NoticeViewController
@synthesize title;
@synthesize content;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];

    NSInteger startY = 0;
    if(!iOS7)
    {
        startY = 20;
    }
    
    UIImage *bgImage = nil;
    if(IPHONE5)
    {
        bgImage = [UIImage imageNamed:@"noticeview_bg5"];
    }
    else
    {
        bgImage = [UIImage imageNamed:@"noticeview_bg4"];
    }
    bgView = [[UIView alloc] initWithFrame:CGRectMake((KDeviceWidth-bgImage.size.width)/2,(210-startY)/2, bgImage.size.width, bgImage.size.height)];
    [bgView setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    bgView.layer.cornerRadius = 4;
    [self.view addSubview:bgView];
    
    if(iOS7)
        self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIImage *norCancelImage = [UIImage imageNamed:@"notice_cancel_nor"];
    UIImage *selCancelImage = [UIImage imageNamed:@"notice_cancel_sel"];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:norCancelImage forState:UIControlStateNormal];
    [cancelButton setImage:selCancelImage forState:UIControlStateHighlighted];
    [cancelButton setFrame:CGRectMake(bgView.frame.size.width-14-norCancelImage.size.width, 15/2.0, norCancelImage.size.width, norCancelImage.size.height)];
    [cancelButton setFrame:CGRectMake(bgView.frame.size.width-45, 0, 45, 45)];
    [cancelButton addTarget:self action:@selector(cancelbuttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:cancelButton];
    
    UILabel *noticeTitle = [[UILabel alloc] initWithFrame:CGRectMake(14+norCancelImage.size.width, 10, (bgView.frame.size.width-(14+norCancelImage.size.width))-45, 30)];
    noticeTitle.textColor = TITLE_COLOR;
    noticeTitle.font = [UIFont systemFontOfSize:16];
    noticeTitle.backgroundColor = [UIColor clearColor];
    noticeTitle.text = @"";
    noticeTitle.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:noticeTitle];
    
    if(![Util isEmpty:title])
    {
        noticeTitle.text = title;
    }
    
    UITextView *noticeMsgContent = [[UITextView alloc] initWithFrame:CGRectMake(10, 45+5, 290-20, (bgView.frame.size.height-(45+13))-40)];
    noticeMsgContent.text =  @"";
    noticeMsgContent.font = [UIFont systemFontOfSize:13];
    noticeMsgContent.textColor = [UIColor colorWithRed:134/255.0 green:134/255.0 blue:134/255.0 alpha:1.0];
    noticeMsgContent.editable = NO;//检测链接时必须的
    noticeMsgContent.dataDetectorTypes = UIDataDetectorTypeLink;
    noticeMsgContent.backgroundColor = [UIColor clearColor];
    [bgView addSubview:noticeMsgContent];
    
    content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(![Util isEmpty:content])
    {
        noticeMsgContent.text = content;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreate
}

-(void)cancelbuttonClicked
{
    [self.view removeFromSuperview];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    CGPoint touchPoint = [anyTouch locationInView:self.view];
    if(touchPoint.x<bgView.frame.origin.x || touchPoint.x>(bgView.frame.origin.x+bgView.frame.size.width) || touchPoint.y<bgView.frame.origin.y || touchPoint.y > (bgView.frame.origin.y+bgView.frame.size.height))
    {
        [self cancelbuttonClicked];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
