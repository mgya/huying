//
//  AboutUsViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-4-2.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "AboutUsViewController.h"
#import "UDefine.h"
#import "Util.h"
#import "FunctionViewController.h"
#import "UIUtil.h"
#import "HelpViewController.h"
#import "UOperate.h"
#import "CheckUpdateDataSource.h"
#import "iToast.h"
#import "XAlertView.h"
#import "CallerManager.h"
#import "ContactManager.h"
#import "UCore.h"
#import "UConfig.h"


@interface AboutUsViewController ()
{
    BOOL isAppReview;
}

@end

@implementation AboutUsViewController
{
    UIImageView *logoImageView;
    UITableView *aboutTableView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitleLabel.text = @"关于我们";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(KDeviceWidth-NAVI_MARGINS-80, (NAVI_HEIGHT-RIGHTITEMWIDTH)/2, 80, RIGHTITEMWIDTH);
    [confirmButton setTitle:@"保存二维码" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:RIGHTITEMFONT];
    [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:confirmButton];
    
    //logo
    UIImage *logoImage = [UIImage imageNamed:@"cli_300px"];
    CGFloat logoWidth = logoImage.size.width/2;
    logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    logoImageView.frame = CGRectMake((KDeviceWidth-logoWidth)/2, LocationY+15, logoWidth, logoImage.size.height/2);
    [self.view addSubview:logoImageView];
    
    //des
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, logoImageView.frame.origin.y+logoImageView.frame.size.height+10, KDeviceWidth, 20)];
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.text = [NSString stringWithFormat:@"呼应 iOS版 %@",UCLIENT_UPDATE_VER];//[Util getAppVersion];
    versionLabel.font = [UIFont systemFontOfSize:16];
    versionLabel.textColor = [UIColor colorWithRed:35/255.0 green:115/255.0 blue:190/255.0 alpha:1.0];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:versionLabel];
    
    if(iOS7)
        self.automaticallyAdjustsScrollViewInsets = NO;
    
    aboutTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, versionLabel.frame.origin.y+versionLabel.frame.size.height+20, KDeviceWidth, KDeviceHeight-(versionLabel.frame.origin.y+versionLabel.frame.size.height+30)) style:UITableViewStyleGrouped];
    aboutTableView.backgroundColor = [UIColor clearColor];
    aboutTableView.rowHeight = 50;
    aboutTableView.delegate = self;
    aboutTableView.dataSource = self;
    aboutTableView.scrollEnabled = NO;
    [self.view addSubview:aboutTableView];
    
    //添加右滑返回手势
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
    isAppReview = [UConfig getVersionReview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)confirmBtnClicked
{
    UIImageWriteToSavedPhotosAlbum(logoImageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"";
    if (!error) {
        message = @"成功保存到相册";
        
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"二维码已保存至相册\n\n扫一扫二维码即可下载最新版呼应" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alertView show];
    }else
    {
        message = [error description];
    }
    NSLog(@"message is %@",message);
}


#pragma mark---UITableView---
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isAppReview)
        return 2;//帮助与资费 呼叫客服
    else
        return 3;//功能介绍 帮助与资费 呼叫客服
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cellName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    }
    
    if (isAppReview) {
        if (indexPath.row == 0){
            cell.textLabel.text = @"帮助";
        }
        else if(indexPath.row == 1) {
            cell.textLabel.text = @"呼叫客服";
        }
    }
    else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"功能介绍";
            cell.textLabel.textColor = [UIColor blackColor];
        }
        else
        if (indexPath.row == 1){
            cell.textLabel.text = @"帮助";
        }
        else if(indexPath.row == 2) {
            cell.textLabel.text = @"呼叫客服";
        }
    }
    
    UIImage *image = [UIImage imageNamed:@"msg_accview"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    cell.accessoryView = imageView;
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isAppReview) {
        if(indexPath.row == 0){
            HelpViewController *helpViewController = [[HelpViewController alloc] init];
            [self.navigationController pushViewController:helpViewController animated:YES];
        }
        else if(indexPath.row == 1){
            if ([UConfig hasUserInfo])
            {
                if([Util ConnectionState])
                {
                    CallerManager* manager = [CallerManager sharedInstance];
                    manager.requestController = ERequestController_More;
                    [manager Caller:UCALLER_NUMBER Contact:[[ContactManager sharedInstance] getContact:UCALLER_NUMBER] ParentView:self Forced:RequestCallerType_Unknow];
                }
                else
                {
                    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }else{
                //未登录
                XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"尊敬的用户，您需要注册/登录后才能使用应用的全部功能。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注册/登录", nil];
                [alertView show];
                
            }
        }
        
    }
    else {
        if(indexPath.row == 0){
            FunctionViewController *functionViewController = [[FunctionViewController alloc] init];
            [self.navigationController pushViewController:functionViewController animated:YES];
        }
        else if(indexPath.row == 1){
            HelpViewController *helpViewController = [[HelpViewController alloc] init];
            [self.navigationController pushViewController:helpViewController animated:YES];
        }
        else if(indexPath.row == 2){
            if ([UConfig hasUserInfo])
            {
                if([Util ConnectionState])
                {
                    CallerManager* manager = [CallerManager sharedInstance];
                    manager.requestController = ERequestController_More;
                    [manager Caller:UCALLER_NUMBER Contact:[[ContactManager sharedInstance] getContact:UCALLER_NUMBER] ParentView:self Forced:RequestCallerType_Unknow];
                }
                else
                {
                    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }else{
                //未登录
                XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"尊敬的用户，您需要注册/登录后才能使用应用的全部功能。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注册/登录", nil];
                [alertView show];
                
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark---UIAlertViewDelegate--
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [uApp showLoginView:YES];
}


@end