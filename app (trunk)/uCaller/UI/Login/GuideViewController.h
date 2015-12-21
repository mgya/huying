//
//  IntroViewController.h
//  QQVoice
//
//  Created by thehuah on 11-11-8.
//  Copyright 2011年 X. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomView.h"
#import "MyPageControl.h"
#import "BaseViewController.h"
#import "MCPagerView.h"

@interface GuideViewController : BaseViewController <UIScrollViewDelegate,CustomDelegate,MCPagerViewDelegate,HTTPManagerControllerDelegate>
{
	CustomView *srView;
    NSInteger curPage;
    NSInteger offsetPage;
    MCPagerView *pagerView;
}
@property (nonatomic,strong) MyPageControl *pageControl;
@end