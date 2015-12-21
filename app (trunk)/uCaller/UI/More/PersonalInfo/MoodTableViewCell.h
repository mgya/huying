//
//  MoodTableViewCell.h
//  uCaller
//
//  Created by HuYing on 15-3-23.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoodTableViewCell : UITableViewCell
{
    UILabel *nameLabel;
    UILabel *contentLabel;
}

-(void)setName:(UILabel *)nLabel ContentFrame:(UILabel *)cLabel;

@end
