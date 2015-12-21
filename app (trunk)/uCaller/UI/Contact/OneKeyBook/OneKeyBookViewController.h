//
//  OneKeyBookViewController.h
//  uCaller
//
//  Created by HuYing on 15-1-13.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "CallerManager.h"
#import "StartAreaView.h"

@protocol TouchScrollViewDelegate <NSObject>

@optional

- (void)scrollView:(UIScrollView *)scrollView
     touchesEnded:(NSSet *)touches
        withEvent:(UIEvent *)event;

@end
@interface TouchScrollView : UIScrollView

@property (nonatomic,assign) id<TouchScrollViewDelegate> touchDelegate;

@end

@interface OneKeyBookViewController : BaseViewController<TouchScrollViewDelegate,CalleeManagerDelegate,StartAreaViewDelegate>

@end
