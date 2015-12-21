//
//  RefreshView.m
//  Testself
//
//  Created by Jason Liu on 12-1-10.
//  Copyright 2012年 Yulong. All rights reserved.
//

#import "RefreshView.h"

@implementation RefreshView
//@synthesize refreshIndicator;
//@synthesize refreshStatusLabel;
//@synthesize refreshLastUpdatedTimeLabel;
//@synthesize refreshArrowImageView;
@synthesize isLoading;
@synthesize isDragging;
@synthesize owner = owner;
@synthesize delegate = delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        refreshArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_arrow_blue.png"]];
        refreshArrowImageView.frame = CGRectMake(40.0f, 0.0f,23.0f , 60.0f);
        [self addSubview:refreshArrowImageView];
        
        refreshStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 0.0f, 200.0f, 60.0f)];
        refreshStatusLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:refreshStatusLabel];
                
        refreshIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        refreshIndicator.frame = CGRectMake(40.0f, 20.0f,20.0f , 20.0f);
        [self addSubview:refreshIndicator];
        
        
    }
    return self;
}


- (void)setupWithOwner:(UIScrollView *)owner_  delegate:(id)delegate_ {
    self.owner = owner_;
    self.delegate = delegate_;
    [owner insertSubview:self atIndex:0];
    self.frame = CGRectMake(0, -REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT);
    [refreshIndicator stopAnimating];
}
// refreshView 结束加载动画
- (void)stopLoading {
    // control
    isLoading = NO;
    
    // Animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
//    owner.contentInset = UIEdgeInsetsZero;
    owner.contentOffset = CGPointZero;
    refreshArrowImageView.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];
    
    // UI 赋值
    refreshStatusLabel.text = REFRESH_PULL_DOWN_STATUS;
    refreshArrowImageView.hidden = NO;
    [refreshIndicator stopAnimating];
}

// refreshView 开始加载动画
- (void)startLoading {
    // control
    isLoading = YES;
    
    // Animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    owner.contentOffset = CGPointMake(0, -REFRESH_HEADER_HEIGHT);
    owner.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshStatusLabel.text = REFRESH_LOADING_STATUS;
    refreshArrowImageView.hidden = YES;
    [refreshIndicator startAnimating];
    [UIView commitAnimations];
}
// refreshView 刚开始拖动时
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}
// refreshView 拖动过程中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            scrollView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            refreshStatusLabel.text = REFRESH_RELEASED_STATUS;
            refreshArrowImageView.transform = CGAffineTransformMakeRotation(3.14);
        } else { // User is scrolling somewhere within the header
            refreshStatusLabel.text = REFRESH_PULL_DOWN_STATUS;
            refreshArrowImageView.transform = CGAffineTransformMakeRotation(0);
        }
        [UIView commitAnimations];
    }
}
// refreshView 拖动结束后
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        if ([delegate respondsToSelector:@selector(refreshViewDidCallBack)]) {
            [delegate refreshViewDidCallBack];
        }
    }
}

@end
