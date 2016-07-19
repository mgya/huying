//
//  tableCalleeTypeCell.h
//  uCaller
//
//  Created by wangxiongtao on 16/7/12.
//  Copyright © 2016年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tableCalleeTypeCell : UITableViewCell


@property(nonatomic,strong)NSString* title;
@property(nonatomic,strong)NSString* details;
@property(nonatomic,assign)BOOL bSelected;

-(void)setWare:(tableCalleeTypeCell*)ware;


@end
