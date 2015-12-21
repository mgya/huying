//
//  StartAreaView.m
//  uCaller
//
//  Created by HuYing on 15-1-14.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "StartAreaView.h"
#import "UAppDelegate.h"
#import "XAlertView.h"
#import "UConfig.h"

@implementation StartAreaView
{
    UITableView *areaTable;
    NSMutableDictionary *mdic;
}
@synthesize delegate;
@synthesize areaMArr;

-(id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        areaMArr = [[NSMutableArray alloc]init];
        
        mdic = [[NSMutableDictionary alloc]init];
        
    }
    return self;
}

-(void)drawPage
{
    areaTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:(UITableViewStylePlain)];
    areaTable.delegate = self;
    areaTable.dataSource = self;
    [self addSubview:areaTable];
}

#pragma mark ------UITableViewDataSource/Delegate----

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return areaMArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:iden];
        
    }else
    {
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    UILabel *areaLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 50, 25)];
    areaLabel.text = [areaMArr objectAtIndex:indexPath.row];
    areaLabel.font = [UIFont systemFontOfSize:14];
    areaLabel.textColor = [UIColor colorWithRed:13/255.0 green:13/255.0 blue:13/255.0 alpha:1.0];
    [cell.contentView addSubview:areaLabel];
    
    NSString *strImgName = nil;
    
    NSDictionary *dic = [UConfig checkTicketsArea];
    BOOL rowBool = [[dic objectForKey:[areaMArr objectAtIndex:indexPath.row]] boolValue];
    if(!rowBool)
    {
        strImgName = @"contact_ticket_cell_nor";
    }else{
        strImgName = @"contact_ticket_cell_sel";
    }
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:strImgName];
    imageView.frame = CGRectMake(areaTable.frame.size.width-50, (cell.frame.size.height-imageView.image.size.height)/2, imageView.image.size.width, imageView.image.size.height);
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    [cell.contentView addSubview:imageView];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[UAppDelegate uApp] networkOK] == NO)
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:nil message:@"网络不可用，无法保存您的设置，请检查您的网络，稍后再试！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [mdic removeAllObjects];
    
    for (NSInteger i=0; i<areaMArr.count; i++) {
        if (i!=indexPath.row) {
            [mdic setValue:[NSNumber numberWithBool:NO] forKey:[areaMArr objectAtIndex:i]];
        }else{
            [mdic setValue:[NSNumber numberWithBool:YES] forKey:[areaMArr objectAtIndex:i]];
        }
    }
    
    [UConfig setTicketsArea:mdic];
    
    [areaTable reloadData];
    
    if (delegate && [delegate respondsToSelector:@selector(startAreaViewRemoveAndLoadData)]) {
        [delegate startAreaViewRemoveAndLoadData];
    }
}

@end
