//
//  IntroViewController.m
//  QQVoice
//
//  Created by thehuah on 11-11-8.
//  Copyright 2011年 X. All rights reserved.
//

#import "GuideViewController.h"
#import "UAppDelegate.h"
#import "Util.h"
#import "GetIapEnvironmentDataSource.h"
#import "UConfig.h"

#define PAGE_COUNT 4

@implementation GuideViewController{
       HTTPManager *getIapEnvironmentHttp;//获取版本审核状态
}

-(void)pageTurn
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	srView.contentOffset = CGPointMake(offsetPage*self.view.frame.size.width, 0.0f);
	[UIView commitAnimations];
}

-(id)init
{
    if(self = [super init])
    {
        UIView *bgView = [[UIView alloc] init];
        if (iOS7) {
            bgView.frame = self.view.frame;
        }
        else {
            bgView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-20);
        }

        srView = [[CustomView alloc] initWithFrame:bgView.frame];
        srView.contentSize = CGSizeMake(PAGE_COUNT * self.view.frame.size.width, srView.frame.size.height);
        srView.pagingEnabled = YES;
        srView.delegate = self;
        srView.touchDelegate = self;
        srView.backgroundColor = [UIColor clearColor];
        
        for (int i = 0; i < PAGE_COUNT; i++)
        {
            NSString *introImageName = nil;
            introImageName = [NSString stringWithFormat:@"guild%d.jpg", i+1];
            
            UIImage *img = [UIImage imageNamed:introImageName];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
            imgView.frame = CGRectMake(i * srView.frame.size.width, 0.0f,srView.frame.size.width,srView.frame.size.height);
            [srView addSubview:imgView];
            if (i == 3) {
                UIButton *experienceBtn = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth/2-175*KWidthCompare6/2, KDeviceHeight-20-13-50*KHeightCompare6, 175*KWidthCompare6, 48*KHeightCompare6)];
                if (IPHONE3GS) {
                    experienceBtn.frame = CGRectMake(KDeviceWidth/2-175*KWidthCompare6/2, KDeviceHeight-20-35-50*KHeightCompare6, 175*KWidthCompare6, 48*KHeightCompare6);
                }
                
                
                [experienceBtn setTitle:@"立即体验" forState:UIControlStateNormal];
                
                [experienceBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
                
                [experienceBtn.layer setMasksToBounds:YES];
                
                experienceBtn.titleLabel.font = [UIFont systemFontOfSize:18];
                
                [experienceBtn.layer setCornerRadius:5.0]; //设置矩圆角半径
                
                [experienceBtn.layer setBorderWidth:1.0]; //边框宽度
                
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                
                CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 255/255.0, 255/255.0, 255/255.0, 1.0});
                
                [experienceBtn.layer setBorderColor:colorref];//边框颜色
                [experienceBtn addTarget:self action:@selector(enterAction) forControlEvents:UIControlEventTouchUpInside];
                [imgView addSubview:experienceBtn];
            }
        }
        
        [self.view addSubview:srView];
        

        // Pager
        curPage = 0;
        if (!isRetina) {
            pagerView = [[MCPagerView alloc] initWithFrame:CGRectMake((KDeviceWidth-45)/2, srView.frame.size.height - 15 - 15, 45, 15)];
        }
        else if(IPHONE5){
            pagerView = [[MCPagerView alloc] initWithFrame:CGRectMake((KDeviceWidth-45)/2, srView.frame.size.height - 10 - 15, 45, 15)];
        }
        else
        {
            pagerView = [[MCPagerView alloc] initWithFrame:CGRectMake((KDeviceWidth-45)/2, srView.frame.size.height - 10 - 15, 45, 15)];
        }
        [pagerView setImage:[UIImage imageNamed:@"guidePageCtr-default.png"]
           highlightedImage:[UIImage imageNamed:@"guidePageCtr-1.png"]
                     forKey:@"1"];
        [pagerView setImage:[UIImage imageNamed:@"guidePageCtr-default.png"]
           highlightedImage:[UIImage imageNamed:@"guidePageCtr-2.png"]
                     forKey:@"2"];
        [pagerView setImage:[UIImage imageNamed:@"guidePageCtr-default.png"]
           highlightedImage:[UIImage imageNamed:@"guidePageCtr-3.png"]
                     forKey:@"3"];
        [pagerView setImage:[UIImage imageNamed:@"guidePageCtr-default.png"]
           highlightedImage:[UIImage imageNamed:@"guidePageCtr-4.png"]
                     forKey:@"4"];
        [pagerView setPattern:@"1234"];
        pagerView.delegate = self;
        [self.view addSubview:pagerView];
        
        
        getIapEnvironmentHttp = [[HTTPManager alloc] init];
        getIapEnvironmentHttp.delegate = self;
        [getIapEnvironmentHttp getIapEnvironment];

    }
    return self;
}

- (void)enterAction
{
    [Util pushView:self];
    [uApp showLoginView:NO];
    
}

#pragma mark -- CustomDelegate Methods
-(void)backTouch:(UIView *)aView
{
    if(curPage < PAGE_COUNT-1)
    {
        offsetPage++;
        [self pageTurn];
    }
    else
    {
        [self enterAction];
    }
}

#pragma mark - UIScrollViewDelegate Methods

- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
    if(curPage >= PAGE_COUNT)
        return;
    
	CGPoint offset = srView.contentOffset;
    CGFloat xOffset = offset.x;
    NSUInteger nCount = PAGE_COUNT-1;
    if((xOffset < 0.0f) && (curPage == 0))
    {
        [srView setContentOffset:CGPointMake(0, offset.y) animated:NO];
        curPage = 0;
        offsetPage = 0;
        return;
    }
    else if((xOffset > (self.view.frame.size.width*nCount)) && (curPage == nCount))
    {
        curPage = PAGE_COUNT;
        [self enterAction];
        return;
    }
	curPage = offset.x / self.view.frame.size.width;
    offsetPage = curPage;
    pagerView.page = curPage;
}


- (void)dealloc
{
    [self.view removeFromSuperview];
    self.view = nil;
}

- (void)pageView:(MCPagerView *)pageView didUpdateToPage:(NSInteger)newPage
{
//    CGPoint offset = CGPointMake(srView.frame.size.width * pagerView.page, 0);
//    [srView setContentOffset:offset animated:YES];
}

#pragma mark--------------- HTTPManagerControllerDelegate ---------------
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource*)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (!bResult) {
        return ;
    }
    
    else if(eType == RequestGetIapEnvironment)
    {
        GetIapEnvironmentDataSource *dataSource = (GetIapEnvironmentDataSource *)theDataSource;
        if(dataSource.nResultNum == 1 && dataSource.bParseSuccessed)
        {
            if([dataSource.flag isEqualToString:@"2"])
            {
                //审核状态
                [UConfig setVersionReview:YES];
            }
            else
            {
                //上线状态
                [UConfig setVersionReview:NO];
            }
        }
    }
    
}

@end
