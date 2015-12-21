//
//  WareTableViewCell.h
//  uCaller
//
//  Created by 崔远方 on 14-5-12.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetWareDataSource.h"

#define NorBorderWidth 0.5
#define SelBorderWidth 1.0
#define NorColor ([UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0])
#define SelColor ([UIColor colorWithRed:255.0/255.0 green:146.0/255.0 blue:36.0/255.0 alpha:1.0])


@protocol WareTableDelegate <NSObject>

-(void)requestOrder:(NSInteger)tag;

@end


@interface WareTableViewCell : UITableViewCell

@property(nonatomic,strong) UIButton *BtnChoose;
@property(nonatomic,strong) UIImageView *bgImageView;

-(void)setWare:(WareInfo *)wareInfo;

@property (nonatomic, strong) id<WareTableDelegate> delegate;

@end




