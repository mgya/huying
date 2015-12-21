//
//  StartAreaView.h
//  uCaller
//
//  Created by HuYing on 15-1-14.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StartAreaViewDelegate <NSObject>

- (void) startAreaViewRemoveAndLoadData;

@end

@interface StartAreaView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak) id<StartAreaViewDelegate>delegate;

@property (nonatomic,strong) NSMutableArray *areaMArr;


-(void)drawPage;

@end
