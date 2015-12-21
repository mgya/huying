//
//  SoundViewController.m
//  uCaller
//
//  Created by admin on 14-11-20.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "SoundViewController.h"
#import "UIUtil.h"
#import "Util.h"
#import "UConfig.h"
#import "CustomSwitch.h"
#import "NotTroubleViewController.h"

#define SET_NEWMSG_OPEN 55016
#define SET_NEWMSG_SOUND 55017
#define SET_NEWMSG_VIBRATION 55018

@implementation SoundViewController
{
    UITableView     *soundTableView;
    
    BOOL isNewMsgOpen;
    BOOL isNewMsgSound;
    BOOL isNewMsgVibration;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navTitleLabel.text = @"新消息提醒";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    soundTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, LocationY+15, KDeviceWidth, KDeviceHeight - 10) style:UITableViewStyleGrouped];
    soundTableView.backgroundColor = [UIColor clearColor];
    soundTableView.scrollEnabled = NO;
    soundTableView.delegate = self;
    soundTableView.dataSource = self;
    [self.view addSubview:soundTableView];
    
    isNewMsgOpen = [UConfig getNewMsgOpen];
    isNewMsgSound = [UConfig getNewMsgtone];
    isNewMsgVibration = [UConfig getNewMsgVibration];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}




-(void)returnLastPage:(UISwipeGestureRecognizer * )swipeGesture{
    if ([swipeGesture locationInView:self.view].x < 100) {
        [self returnLastPage];
    }
    
}



-(void)returnLastPage
{
    [UConfig setNewMsgOpen:isNewMsgOpen];
    [UConfig setNewMsgtone:isNewMsgSound];
    [UConfig setNewMsgVibration:isNewMsgVibration];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self tableRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableRefresh
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [soundTableView reloadData];
        });
    });
    
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 1.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            if (isNewMsgOpen) {
                return 3;
            }
            else
            {
                return 1;
            }
        }
            
        case 1:
            return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    else{
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    UILabel *labelName = [[UILabel alloc]initWithFrame:CGRectMake(10,15,120,15)];
    labelName.font = [UIFont systemFontOfSize:16];
    labelName.textColor = [UIColor blackColor];
    labelName.backgroundColor = [UIColor clearColor];
    labelName.shadowColor = [UIColor whiteColor];
    labelName.shadowOffset = CGSizeMake(0, 2.0f);
    [cell.contentView addSubview:labelName];
    
    if (indexPath.section == 0) {
        
        if (isNewMsgOpen) {
            if (indexPath.row == 0) {
                labelName.text = @"新信息提示音";
                
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                if(!iOS7)
                {
                    switchView.frame = CGRectMake(switchView.frame.origin.x-20,
                                                  switchView.frame.origin.y,
                                                  switchView.frame.size.width,
                                                  switchView.frame.size.height);
                }
                [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                switchView.on = isNewMsgOpen;
                if ([Util systemBeforeFive] == NO)
                    switchView.onTintColor = [UIColor colorWithRed:14/255.0 green:161/255.0 blue:237/255.0 alpha:1.0];
                switchView.tag = SET_NEWMSG_OPEN;
                [cell.contentView addSubview:switchView];
            }
            else if (indexPath.row ==1)
            {
                labelName.text = @"声音";
                
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                if(!iOS7)
                {
                    switchView.frame = CGRectMake(switchView.frame.origin.x-20,
                                                  switchView.frame.origin.y,
                                                  switchView.frame.size.width,
                                                  switchView.frame.size.height);
                }
                [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                switchView.on = isNewMsgSound;
                if ([Util systemBeforeFive] == NO)
                    switchView.onTintColor = [UIColor colorWithRed:14/255.0 green:161/255.0 blue:237/255.0 alpha:1.0];
                switchView.tag = SET_NEWMSG_SOUND;
                [cell.contentView addSubview:switchView];
            }
            else
            {
                labelName.text = @"震动";
                
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                if(!iOS7)
                {
                    switchView.frame = CGRectMake(switchView.frame.origin.x-20,
                                                  switchView.frame.origin.y,
                                                  switchView.frame.size.width,
                                                  switchView.frame.size.height);
                }
                [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                switchView.on = isNewMsgVibration;
                if ([Util systemBeforeFive] == NO)
                    switchView.onTintColor = [UIColor colorWithRed:14/255.0 green:161/255.0 blue:237/255.0 alpha:1.0];
                switchView.tag = SET_NEWMSG_VIBRATION;
                [cell.contentView addSubview:switchView];
            }
        }
        else
        {
            labelName.text = @"新信息提示音";
            
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
            if(!iOS7)
            {
                switchView.frame = CGRectMake(switchView.frame.origin.x-20,
                                              switchView.frame.origin.y,
                                              switchView.frame.size.width,
                                              switchView.frame.size.height);
            }
            [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
            switchView.on = isNewMsgOpen;
            if ([Util systemBeforeFive] == NO)
                switchView.onTintColor = [UIColor colorWithRed:14/255.0 green:161/255.0 blue:237/255.0 alpha:1.0];
            switchView.tag = SET_NEWMSG_OPEN;
            [cell.contentView addSubview:switchView];
        }
    }
    else if (indexPath.section == 1)
    {
        labelName.text = @"免打扰";
        
        UILabel *contentLabel = [[UILabel alloc]init];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor grayColor];
        contentLabel.font = [UIFont systemFontOfSize:TEXT_FONTSIZE];
        
        NSString *contentStr;
        if ([UConfig getMuteMode]) {
            
            NSString *startTime;
            NSString *endTime;
            
            if ([Util isEmpty:[UConfig getStartTime]]) {
                startTime = MUTE_DEFAULT_TIME;
            }
            else
            {
                startTime = [UConfig getStartTime];
            }
            
            if ([Util isEmpty:[UConfig getEndTime]]) {
                endTime = MUTE_DEFAULT_TIME;
            }
            else
            {
                endTime = [UConfig getEndTime];
            }
            
            contentStr = [NSString stringWithFormat:@"%@至%@之间免打扰",startTime,endTime];
        }
        else
        {
            contentStr = @"未设置";
        }
        
        CGSize sizeDes;
        if (![Util isEmpty:contentStr]) {
            sizeDes = [contentStr sizeWithFont:contentLabel.font];
        }
        else {
            sizeDes = CGSizeMake(0,0);
        }
        contentLabel.text = contentStr;
        
        contentLabel.frame = CGRectMake(KDeviceWidth-30.0-sizeDes.width,
                                        (45.0-sizeDes.height)/2,
                                        sizeDes.width,
                                        sizeDes.height);
        
        
        [cell.contentView addSubview:contentLabel];
    }
    
    UIImage *image = [UIImage imageNamed:@"msg_accview"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    if (indexPath.section == 1) {
        cell.accessoryView = imageView;
        cell.accessoryView.hidden = NO;
    }
    else
    {
        cell.accessoryView.hidden = YES;
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NotTroubleViewController *notTroubleVC = [[NotTroubleViewController alloc]init];
        [self.navigationController pushViewController:notTroubleVC animated:YES];
    }
}


#pragma mark 相关点击滑动事件
-(void) switchFlipped:(UISwitch *) sender
{
    if (sender.tag == SET_NEWMSG_OPEN) {
        if (sender.on) {
            isNewMsgOpen = YES;
        }
        else
        {
            isNewMsgOpen = NO;
        }
        [self tableRefresh];
    }
    else if (sender.tag == SET_NEWMSG_SOUND)
    {
        if (sender.on) {
            isNewMsgSound = YES;
        }
        else
        {
            isNewMsgSound = NO;
            if (isNewMsgVibration == NO) {
                isNewMsgOpen = NO;
                [self tableRefresh];
               
            }
        }
    }
    else if (sender.tag == SET_NEWMSG_VIBRATION)
    {
        if (sender.on) {
            isNewMsgVibration = YES;
        }
        else
        {
            isNewMsgVibration = NO;
            if (isNewMsgSound == NO) {
                isNewMsgOpen = NO;
                [self tableRefresh];
                
            }
        }
    }
    
}

@end
