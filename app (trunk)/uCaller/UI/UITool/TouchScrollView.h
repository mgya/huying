//
//  TouchScrollView.h
//  uCaller
//
//  Created by HuYing on 15-4-15.
//  Copyright (c) 2015年 qixin. All rights reserved.
//  解决UIScrollView上touchend无响应的问题

#import <UIKit/UIKit.h>

@protocol TouchScrollViewDelegate <NSObject>

@optional

- (void)scrollView:(UIScrollView *)scrollView
      touchesEnded:(NSSet *)touches
         withEvent:(UIEvent *)event;

@end

@interface TouchScrollView : UIScrollView

@property (nonatomic,assign) id<TouchScrollViewDelegate> touchDelegate;

@end
