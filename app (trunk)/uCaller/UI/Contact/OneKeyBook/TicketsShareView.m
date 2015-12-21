//
//  TicketsShareView.m
//  uCaller
//
//  Created by HuYing on 15-1-16.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "TicketsShareView.h"

@implementation TicketsShareView
{
    UITableView *shareTable;
    UIImageView *iconImgView;
    UILabel     *titleLabel;
}
@synthesize delegate;
-(id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        shareTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:(UITableViewStylePlain)];
        shareTable.dataSource = self;
        shareTable.delegate = self;
        [self addSubview:shareTable];
    }
    return self;
}

#pragma mark -----UITableViewDelegate/DataSource------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    UIImage *image = [UIImage imageNamed:@"InviteContact"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:iden];
        
        iconImgView = [[UIImageView alloc]initWithFrame:CGRectMake(15,(cell.frame.size.height - image.size.height)/2,image.size.width,image.size.height)];
        [cell.contentView addSubview:iconImgView];
        
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconImgView.frame.origin.x+iconImgView.frame.size.width+11, iconImgView.frame.origin.y, 140, 25)];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:titleLabel];
    }
    switch (indexPath.row) {
        case 0:
        {
            iconImgView.image = [UIImage imageNamed:@"InviteContact"];
            titleLabel.text   = @"分享给联系人";
        }
            break;
        case 1:
        {
            iconImgView.image = [UIImage imageNamed:@"ShareWXCircle"];
            titleLabel.text   = @"分享到微信朋友圈";
        }
            break;
        case 2:
        {
            iconImgView.image = [UIImage imageNamed:@"ShareWX"];
            titleLabel.text   = @"分享给微信好友";
        }
            break;
        case 3:
        {
            iconImgView.image = [UIImage imageNamed:@"ShareQQ"];
            titleLabel.text   = @"分享给QQ";
        }
            break;
            
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            if (delegate && [delegate respondsToSelector:@selector(ticketsShareInviteContact)]) {
                [delegate ticketsShareInviteContact];
            }
        }
            break;
        case 1:
        {
            if (delegate && [delegate respondsToSelector:@selector(ticketsShareWXCircle)]) {
                [delegate ticketsShareWXCircle];
            }
        }
            break;
        case 2:
        {
            if (delegate && [delegate respondsToSelector:@selector(ticketsShareWX)]) {
                [delegate ticketsShareWX];
            }
        }
            break;
        case 3:
        {
            if (delegate && [delegate respondsToSelector:@selector(ticketsShareQQ)]) {
                [delegate ticketsShareQQ];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
