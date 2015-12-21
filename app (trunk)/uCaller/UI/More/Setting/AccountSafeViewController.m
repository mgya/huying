//
//  AccountSafeViewController.m
//  uCaller
//
//  Created by HuYing on 15/6/25.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "AccountSafeViewController.h"
#import "UDefine.h"
#import "UIUtil.h"
#import "UConfig.h"
#import "EmpowerViewController.h"
#import "VertifyPhoneNumberViewControlller.h"

@interface AccountSafeViewController ()
{
    UITableView *aTableView;
}
@end

@implementation AccountSafeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navTitleLabel.text = @"账号和安全";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, LocationY+15, KDeviceWidth, KDeviceHeight - 10.0) style:UITableViewStyleGrouped];
    aTableView.backgroundColor = [UIColor clearColor];
    aTableView.scrollEnabled = NO;
    aTableView.delegate = self;
    aTableView.dataSource = self;
    [self.view addSubview:aTableView];
    if(!iOS7)
    {
        UIView *tableViewBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, aTableView.frame.size.width, aTableView.frame.size.height)];
        tableViewBgView.backgroundColor = PAGE_BACKGROUND_COLOR;
        aTableView.backgroundView = tableViewBgView;
    }
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark---UITableViewDelegate/UITableViewdataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
        
    }
    else{
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:TITLE_FONTSIZE];
    cell.textLabel.textColor = TITLE_COLOR;
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"绑定账号管理";
    }
    else
    {
        cell.textLabel.text = @"密码设置";
    }
    
    UIImage *image = [UIImage imageNamed:@"msg_accview"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    cell.accessoryView = imageView;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        EmpowerViewController *empowerVC = [[EmpowerViewController alloc]init];
        [self.navigationController pushViewController:empowerVC animated:YES];
    }
    else
    {
        VertifyPhoneNumberViewControlller *phoneNumberViewController = [[VertifyPhoneNumberViewControlller alloc] init];
        phoneNumberViewController.curType = ResetPwdFromSetting;
        phoneNumberViewController.phoneNumber = [UConfig getPNumber];
        phoneNumberViewController.controllerTitle = @"设置密码";
        [self.navigationController pushViewController:phoneNumberViewController animated:YES];
    }
}


@end
