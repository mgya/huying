//
//  FunctionViewController.m
//  uCaller
//
//  Created by changzheng-Mac on 14-4-20.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "FunctionViewController.h"
#import "UIUtil.h"

#define FUNCTION_TITLE_ONE @"拨打电话"
#define FUNCTION_TEXT_ONE @"拨号（国内手机号、固话加区号、呼应号）后——直接进行呼叫、添加联系人。"

#define FUNCTION_TITLE_TWO @"通话记录"
#define FUNCTION_TEXT_TWO @"    查看所有往来通话及详情，更可直接在记录中添加联系人，发信息，设置防骚扰拦截。"

#define FUNCTION_TITLE_THREE @"联系人"
#define FUNCTION_TEXT_THREE @"    查看联系人、好友详情——可呼叫或发信息给该联系人、好友——可结交新朋友、添加呼应好友。"

#define FUNCTION_TITLE_FOUR @"信息"
#define FUNCTION_TEXT_FOUR @"    与呼应好友间发送文字信息、语音信息、表情等内容。"

#define FUNCTION_TITLE_FIVE @"赚话费"
#define FUNCTION_TEXT_FIVE @"    更多任务赚取免费通话时长，完善资料、每日签到、发送邀请码、邀请手机联系人、分享至各平台等。"


@interface FunctionViewController ()
{
    UITableView *tableFunction;
}

@end

@implementation FunctionViewController

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
	// Do any additional setup after loading the view.
    self.navTitleLabel.text = @"功能介绍";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    tableFunction = [[UITableView alloc] initWithFrame:CGRectMake(0,LocationY, KDeviceWidth, KDeviceHeight-LocationY) style:UITableViewStyleGrouped];
    if(!iOS7)
    {
        tableFunction.frame = CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-64-LocationY);
    }
    tableFunction.backgroundColor = [UIColor clearColor];
    tableFunction.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableFunction.separatorColor = [UIColor clearColor];
    tableFunction.delegate = self;
    tableFunction.dataSource = self;
    [self.view addSubview:tableFunction];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 3 || indexPath.row == 2)
    {
        return 260;
    }
    else if(indexPath.row == 4)
    {
        return 270;
    }
    return 250;
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
    
    UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(10,10,KDeviceWidth-20,30)];
    labelTitle.font = [UIFont systemFontOfSize:16];
    labelTitle.textColor = [UIColor colorWithRed:13.0/255.0 green:13.0/255.0 blue:13.0/255.0 alpha:1.0];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.shadowColor = [UIColor whiteColor];
    labelTitle.shadowOffset = CGSizeMake(0, 2.0f);
    labelTitle.numberOfLines = 0;
    [cell.contentView addSubview:labelTitle];
    
    UIImageView *imageline = [[UIImageView alloc] init];
    imageline.frame = CGRectMake(10, labelTitle.frame.origin.y+labelTitle.frame.size.height, KDeviceWidth-20, 1);
    [cell.contentView addSubview:imageline];
    
    UILabel *labelText = [[UILabel alloc]initWithFrame:CGRectMake(10,imageline.frame.origin.y+imageline.frame.size.height,KDeviceWidth-20,14)];
    labelText.textAlignment = NSTextAlignmentLeft;
    labelText.font = [UIFont systemFontOfSize:13];
    labelText.textColor = [UIColor colorWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1.0];
    labelText.backgroundColor = [UIColor clearColor];
    labelText.shadowColor = [UIColor whiteColor];
    labelText.shadowOffset = CGSizeMake(0, 2.0f);
    labelText.numberOfLines = 0;
    [cell.contentView addSubview:labelText];
    
    
    UIImageView *imagePic = [[UIImageView alloc] init];
    imagePic.frame = CGRectMake(20, 90, KDeviceWidth-40, 110);
    [cell.contentView addSubview:imagePic];
    
    UIImage *showImage = nil;
    
    switch (indexPath.row) {
        case 0:
        {
            labelTitle.text = FUNCTION_TITLE_ONE;
            labelText.text = FUNCTION_TEXT_ONE;
            labelText.frame = CGRectMake(labelText.frame.origin.x,labelText.frame.origin.y,KDeviceWidth-20,50);
            
            showImage = [UIImage imageNamed:@"img_function_declaration_one.png"];
            
        }
            break;
        case 1:
        {
            labelTitle.text = FUNCTION_TITLE_TWO;
            labelText.text = FUNCTION_TEXT_TWO;
            labelText.frame = CGRectMake(10,45,KDeviceWidth-20,50);
            
            showImage = [UIImage imageNamed:@"img_function_declaration_two.png"];
            
        }
            break;
        case 2:
        {
            labelTitle.text = FUNCTION_TITLE_THREE;
            labelText.text = FUNCTION_TEXT_THREE;
            labelText.frame = CGRectMake(10,45,KDeviceWidth-20,50);
            
            showImage = [UIImage imageNamed:@"img_function_declaration_three.png"];

        }
            break;
        case 3:
        {
            labelTitle.text = FUNCTION_TITLE_FOUR;
            labelText.text = FUNCTION_TEXT_FOUR;
            labelText.frame = CGRectMake(10,45,KDeviceWidth-20,50);
            
            showImage = [UIImage imageNamed:@"img_function_declaration_four.png"];
        }
            break;
        case 4:
        {
            labelTitle.text = FUNCTION_TITLE_FIVE;
            labelText.text = FUNCTION_TEXT_FIVE;
            labelText.frame = CGRectMake(10,45,KDeviceWidth-20,50);
            imagePic.frame = CGRectMake(20, 105, KDeviceWidth-40, 120);
            showImage = [UIImage imageNamed:@"img_function_declaration_five.png"];
        }
            break;
        default:
            break;
    }
    
    imageline.image = [UIImage imageNamed:@"helpInfo_line.png"];
    imagePic.image = showImage;
    imagePic.frame = CGRectMake((KDeviceWidth-showImage.size.width)/2, labelText.frame.origin.y+labelText.frame.size.height, showImage.size.width, showImage.size.height);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
