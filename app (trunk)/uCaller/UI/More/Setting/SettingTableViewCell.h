//
//  SettingTableViewCell.h
//  uCaller
//
//  Created by HuYing on 15/6/23.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    middleStyle = 1,
    leftStyle = 0
}cellStyle;

@interface SettingTableViewCell : UITableViewCell

@property cellStyle cellType;

-(void)setTitle:(NSString *)aTitle StatusImg:(BOOL)aStatus  Description:(NSString *)aDescription Point:(BOOL)aPoint ImageView:(BOOL)aHidden;

@end
