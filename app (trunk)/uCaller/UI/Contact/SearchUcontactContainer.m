//
//  SearchUcontactContainer.m
//  uCaller
//
//  Created by 张新花花花 on 15/7/24.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "SearchUcontactContainer.h"
#import "ContactManager.h"
#import "UConfig.h"
#import "UIUtil.h"
#import "UAppDelegate.h"
#import "TabBarViewController.h"
#import "SearchContactCell.h"
@implementation SearchUcontactContainer
{
    NSMutableArray *uContacs;
}
- (void)reloadData
{
    uContacs = [[NSMutableArray alloc]init];
    contacts = [[ContactManager sharedInstance] searchContactsWithKey:strKeyWord andType:CONTACT_uCaller];
    for (UContact *contact in contacts) {
        if (contact.type == CONTACT_uCaller) {
            [uContacs addObject:contact];
        }
    }
    
    [contactTableView reloadData];
}

#pragma mark - Table View

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 31;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(-1, -1, tableView.frame.size.width-30, 31)];
    bgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    bgView.layer.borderColor = [UIColor colorWithRed:240/255.0 green:243/255.0 blue:246/255.0 alpha:1.0].CGColor;
    bgView.layer.borderWidth = 0.5;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, bgView.frame.size.width-20, bgView.frame.size.height)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:15];
    
    NSString *key = [NSString stringWithFormat: @"搜索到%d个好友",uContacs.count];
    if (uContacs.count == 0) {
        titleLabel.text = @"无搜索结果";
        titleLabel.textAlignment = NSTextAlignmentCenter;
    }else{
        titleLabel.text = key;
    }
    [bgView addSubview:titleLabel];
    return bgView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return uContacs.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ExtendContactCell";
    SearchContactCell *cell = (SearchContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[SearchContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.curCellType = ALL;
    cell.strKeyWord = self.strKeyWord;
    
    UContact *contact  = nil;
    
    contact = [uContacs objectAtIndex:indexPath.row];
    [cell setContact:contact];
    //设置cell的动态高度
    NSInteger cellHeight = [cell cellHeight];
    CGRect cellFrame = [cell frame];
    cellFrame.origin = CGPointMake(0, 0);
    cellFrame.size.height = cellHeight;
    [cell setFrame:cellFrame];
    
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UContact *contact = nil;
    contact = [uContacs objectAtIndex:indexPath.row];
    if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClicked:)])
    {
        [contactDelegate contactCellClicked:contact];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
