//
//  PersonalInfoViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-4-2.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "UConfig.h"
#import "Util.h"
#import "XAlertView.h"
#import "UCore.h"
#import "iToast.h"
#import "UIUtil.h"
#import "OccupationViewController.h"
#import "ProvinceViewController.h"
#import "EmpowerViewController.h"
#import "SchoolViewController.h"
#import "NewTaskGiveDataSource.h"
#import "CheckTaskDataSource.h"
#import "ContactManager.h"
#import "MoodTableViewCell.h"
#import "VariableEditLabel.h"

#define FeelStatus  @"FeelStatus"
#define Diploma     @"Diploma"
#define MonthInCome @"MonthInCome"
#define CellLeftMargin (78.0+15.0)


@interface PersonalInfoViewController ()
{
    UITableView *infoTableView;
    
    UILabel *labelnickname;//昵称
    UILabel *labelSex;//性别
    UILabel *birthLabel;//生日
    UILabel *constellationLabel;//星座
    UILabel *labelCompany;//公司
    NSString *moodContentStr;//心情内容
    
    UILabel *labelFeelingStatus;//情感状态
    UILabel *labelDiploma;//学历
    UILabel *labelMonthIncome;//收入
    UIView *markView;//自标签
    NSString *hobbiesContentStr;//兴趣爱好内容
    NSString *markStr;//标签内容
    
    NSArray *feelArr;//情感状态数组
    NSArray *diplomaArr;//学历数组
    NSArray *incomeArr;//收入数组
    
    
    DateView *dateView;//生日
    DataPickerView *curPickerView;//情感，学历，收入
    
    UIButton *giftFinishBtn;//右上角礼盒按钮
    UIView *hideView;//遮罩
    UIImageView *showImageView;//遮罩上半部分
    UIButton *knowBtn;//遮罩上知道了按钮
    BOOL guideBool;//判断是否进入引导页
    
    BOOL  isUpdateInfoToServer;//是否更新用户基本信息
    NSMutableDictionary *updateInfoMdic;//用于存放用户基本信息用户更新到pes端
    
    HTTPManager *newTaskGiveHttp;//个人信息完成任务
    HTTPManager *newTaskGiveHttp2;//个人信息完成任务2
    HTTPManager *newTaskGiveHttp3;//个人信息完成任务3

    
    HTTPManager *checkTaskHttp;//检测个人信息完成任务
    HTTPManager *httpUpdateUserBaseInfo;//更新用户个人信息
    
    CGFloat iToastHeight;//同时显示多个iToast时，使N>1iToast靠下
    
    BOOL isReview;//审核版本控制按钮
}

@end


@implementation PersonalInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        isReview = [UConfig getVersionReview];
        
        updateInfoMdic = [[NSMutableDictionary alloc] init];
        
        feelArr = [NSArray arrayWithObjects:@"保密",@"单身",@"求勾搭",@"热恋中",@"已婚",@"同性", nil];
        
        diplomaArr = [NSArray arrayWithObjects:@"保密",@"中学",@"高中",@"专科",@"本科",@"硕士",@"博士", nil];
        
        incomeArr = [NSArray arrayWithObjects:@"保密",@"2千以下",@"2-6千元",@"6千-1万元",@"1-2万元",@"2-5万元",@"5万元以上", nil];
        
        isUpdateInfoToServer = NO;
        
        newTaskGiveHttp = [[HTTPManager alloc]init];
        newTaskGiveHttp.delegate = self;
        newTaskGiveHttp2 = [[HTTPManager alloc]init];
        newTaskGiveHttp2.delegate = self;
        newTaskGiveHttp3 = [[HTTPManager alloc]init];
        newTaskGiveHttp3.delegate = self;
        
        checkTaskHttp = [[HTTPManager alloc]init];
        checkTaskHttp.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeEvent) name:KEvent_SchoolOrWorkOrHometwon object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navigationController.navigationBarHidden = YES;
    
    self.navTitleLabel.text = @"个人信息";
    
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    giftFinishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [giftFinishBtn setFrame:CGRectMake(KDeviceWidth-NAVI_MARGINS-28, (NAVI_HEIGHT-28)/2, 28, 28)];
    [giftFinishBtn addTarget:self action:@selector(rightBarItemFunction) forControlEvents:(UIControlEventTouchUpInside)];
    [self addNaviSubView:giftFinishBtn];
    
    //资料完成度按钮
    guideBool = [[(NSDictionary *)[UConfig getPersonalGuide] objectForKey:[UConfig getUID]] boolValue];
    [UConfig updateInfoPercent];//记录进度
    if (guideBool) {
        [self checkGiftShow];
    }
    [checkTaskHttp checkTask:@"userinfo"];
    
   // if (iOS7) {
        infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-LocationY) style:UITableViewStyleGrouped];
//    }else{
//        infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(-10, LocationY, KDeviceWidth +20, KDeviceHeight-65) style:UITableViewStyleGrouped];
//    }
    infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoTableView.delegate = self;
    infoTableView.dataSource = self;
    infoTableView.bounces = NO;
    [self.view addSubview:infoTableView];

    if (!guideBool) {
        [self finishFunction];
    }
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [infoTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEvent_SchoolOrWorkOrHometwon object:nil];
}

#pragma mark ---BarButtonItemFunction---

-(void)returnLastPage
{
    [self.delegate upDataContactInfo];
    [self knowSelectionFunction];
    [self.navigationController popViewControllerAnimated:YES];
    if (isUpdateInfoToServer) {
        [[UCore sharedInstance] newTask:U_UPDATE_USERBASEINFO data:updateInfoMdic];
    }
}


-(void)returnLastPage:(UISwipeGestureRecognizer * )swipeGesture{
    if ([swipeGesture locationInView:self.view].x < 100) {
        [self returnLastPage] ;
    }
}



#pragma mark ---GiftFinish---
-(void)rightBarItemFunction
{
    NSInteger count = [(NSString *)[UConfig getInfoPercent] integerValue];
    NSString *miniteStr = [UConfig getNewTaskMinite];
    if (count >= 40) {
        if (miniteStr == nil) {
            //未领取过此时为nil
            [self updateUserBaseInfo:updateInfoMdic];
            return;
        }
    }
    if (count >= 70) {
        if (miniteStr.integerValue<30) {
            [self updateUserBaseInfo:updateInfoMdic];
            return;
        }
    }
    if (count == 100) {
        if (miniteStr.integerValue<60) {
            [self updateUserBaseInfo:updateInfoMdic];
            return;
        }
    }
    [self finishFunction];
}

-(void)finishFunction
{
    if (isReview) {
        //审核期间
        return;
    }else
    {
        hideView = [[UIView alloc]initWithFrame:CGRectMake(0, -LocationY, KDeviceWidth, KDeviceHeight+LocationY)];
        hideView.alpha = 0.68;
        hideView.backgroundColor = [UIColor grayColor];
        
        [self.navigationController.view addSubview:hideView];
        
        UIImage *remindImage = [UIImage imageNamed:@"gift_remind"];
        UIImage *knowImage = [UIImage imageNamed:@"gift_know"];
        UIImage *guideImage = [UIImage imageNamed:@"gift_guide"];
        
        
        showImageView = [[UIImageView alloc]init];
        UIImage *showImage;
        CGFloat guideFloat = 0.0;
        CGFloat knowFloat =0.0;
        if (!guideBool) {
            showImage = guideImage;
            
            self.navigationController.navigationBarHidden = YES;
            if (IPHONE4 ) {
                guideFloat = 60;
            }
            if (!isRetina&&!iOS7) {
                guideFloat = 90;
                knowFloat = 30;
            }
            guideBool = !guideBool;
            [UConfig setPersonalGuide:YES];
        }
        else{
            showImage = remindImage;
        }
        showImageView.frame = CGRectMake((KDeviceWidth-showImage.size.width)/2, 130-guideFloat, showImage.size.width, showImage.size.height);
        showImageView.image = showImage;
        showImageView.backgroundColor = [UIColor clearColor];
        
        [self.navigationController.view addSubview:showImageView];
        
        knowBtn = [[UIButton alloc]initWithFrame:CGRectMake((KDeviceWidth-knowImage.size.width)/2, showImageView.frame.origin.y+showImageView.frame.size.height+60-knowFloat, knowImage.size.width, knowImage.size.height)];
        [knowBtn setImage:knowImage forState:(UIControlStateNormal)];
        [knowBtn addTarget:self action:@selector(knowSelectionFunction) forControlEvents:(UIControlEventTouchUpInside)];
        knowBtn.backgroundColor = [UIColor clearColor];
        [self.navigationController.view addSubview:knowBtn];
    }
}

-(void)knowSelectionFunction
{
    [hideView removeFromSuperview];
    [showImageView removeFromSuperview];
    [knowBtn removeFromSuperview];
}

-(void)updateUserBaseInfo:(NSDictionary *)dicInfo
{
    if (httpUpdateUserBaseInfo == nil) {
        httpUpdateUserBaseInfo = [[HTTPManager alloc] init];
        httpUpdateUserBaseInfo.delegate = self;
    }
    
    [httpUpdateUserBaseInfo updateUserBaseInfo:dicInfo];
}

-(void)afterUpdateInfoRequestNewTask
{
    iToastHeight = 0;
    
    NSInteger count = [(NSString *)[UConfig getInfoPercent] integerValue];
    
    if (count>=40) {
        //userinfo_firstnode=用户信息完成第一个节点
        NSLog(@"第一节点");
        [newTaskGiveHttp getNewTaskGive:@"userinfo_firstnode"];
    }
    if (count>=70) {
        //userinfo_secondnode=用户信息完成第二个节点
        NSLog(@"第二节点");
       [newTaskGiveHttp2 getNewTaskGive:@"userinfo_secondnode"];
    }
    if (count==100) {
        //userinfo_thirdnode=用户信息完成第三个节点
        NSLog(@"第三节点");    }
        [newTaskGiveHttp3 getNewTaskGive:@"userinfo_thirdnode"];

}


#pragma mark---UITableViewDelegate/UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15.0;
    }
    else
    {
        return 1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 44.0;
    }
    return 9.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 44)];
    return footerView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 4;
    }
    else if(section == 1)
    {
        return 1;
    }
    else if (section == 2)
    {
        return 4;
    }
    else if (section == 3)
    {
        return 5;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(  (indexPath.section == 1 )
       ||(indexPath.section ==3 && indexPath.row == 3) )
    {
        MoodTableViewCell *moodcell = (MoodTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return moodcell.frame.size.height;//签名
    }
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if([[UConfig getMood] length] > 0)
        {
            moodContentStr = [UConfig getMood];
        }else
        {
            moodContentStr = @"写下想说的话，让大家认识你！";
        }
        MoodTableViewCell *moodCell = [self drawChangeCell:tableView ContentStr:moodContentStr Title:@"签名" HasLine:NO];
        moodCell.selectedBackgroundView = [UIUtil CellSelectedView];
        return moodCell;
    }
    else if (indexPath.section ==3&&indexPath.row==3)
    {
        //兴趣爱好
        if([[UConfig getInterest] length] > 0)
        {
            hobbiesContentStr = [UConfig getInterest];
        }else
        {
            hobbiesContentStr = @"请填写你的兴趣爱好";
        }
        
        MoodTableViewCell *interestCell = [self drawChangeCell:tableView ContentStr:hobbiesContentStr Title:@"兴趣爱好" HasLine:YES];
        interestCell.selectedBackgroundView = [UIUtil CellSelectedView];
        return interestCell;
    }
    else
    {
        static NSString *cellName = @"InfoCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if(nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            
        }
        for(UIView *subView in cell.contentView.subviews)
        {
                [subView removeFromSuperview];
        }
        
        UILabel *cellLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,(44.0-15.0)/2,95,15)];
        cellLabel.textAlignment = NSTextAlignmentLeft;
        cellLabel.font = [UIFont systemFontOfSize:16];
        cellLabel.textColor = [UIColor blackColor];
        cellLabel.backgroundColor = [UIColor clearColor];
        cellLabel.shadowColor = [UIColor whiteColor];
        cellLabel.shadowOffset = CGSizeMake(0, 2.0f);
        [cell.contentView addSubview:cellLabel];
      
        //分割线
        float cellHeightMargin;
        UIView *lineView = [[UIView alloc] init];
        if (iOS7) {
            cellHeightMargin = 0.5;
        }else{
            cellHeightMargin = 0.0;//iOS tableView(Group类型)有自己的线，这里去掉画的线效果更好。
        }
        lineView.frame = CGRectMake(cellLabel.frame.origin.x,cell.contentView.frame.origin.y+cell.contentView.frame.size.height-cellHeightMargin, KDeviceWidth-15, cellHeightMargin);
        lineView.backgroundColor = [[UIColor alloc] initWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0];
        [cell.contentView addSubview:lineView];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImage *image = [UIImage imageNamed:@"msg_accview"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        cell.accessoryView = imageView;
        if (  ( indexPath.section==0 && indexPath.row==1 )
            ||( indexPath.section==3 && indexPath.row==4 ) )
        {
            cell.accessoryView.hidden = YES;
        }
        
        
        if(indexPath.section == 0)
        {
            if(indexPath.row == 0)
            {
                cellLabel.text = @"昵称";
                
                labelnickname = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftMargin,(44-30)/2,220,30)];
                labelnickname.textAlignment = NSTextAlignmentLeft;
                labelnickname.font = [UIFont systemFontOfSize:16];
                labelnickname.textColor = [UIColor grayColor];
                labelnickname.shadowColor = [UIColor whiteColor];
                labelnickname.shadowOffset = CGSizeMake(0, 2.0f);
                labelnickname.backgroundColor = [UIColor clearColor];
                labelnickname.text = @"";
                if([[UConfig getNickname] length] > 0)
                {
                    labelnickname.text = [UConfig getNickname];
                }else
                {
                    labelnickname.text = @"请输入昵称";
                }
                
                cell.contentView.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:labelnickname];
                
            }
            else if(indexPath.row ==1)
            {
                
                cellLabel.text = @"手机";
                UILabel *labelTelphone = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftMargin, (44-30)/2, 220, 30)];
                labelTelphone.textAlignment = NSTextAlignmentLeft;
                labelTelphone.font = [UIFont systemFontOfSize:16];
                labelTelphone.textColor = [UIColor grayColor];
                labelTelphone.shadowColor = [UIColor whiteColor];
                labelTelphone.shadowOffset = CGSizeMake(0, 2.0f);
                labelTelphone.backgroundColor = [UIColor clearColor];
                if([[UConfig getPNumber] length] > 0)
                {
                    labelTelphone.text = [UConfig getPNumber];
                }else
                {
                    labelTelphone.text = @"注册手机号";
                }
                
                cell.contentView.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:labelTelphone];
                
            }
            else if(indexPath.row == 2){
                cellLabel.text = @"性别";
                
                labelSex = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftMargin, (44-30)/2, 220, 30)];
                labelSex.textAlignment = NSTextAlignmentLeft;
                labelSex.font = [UIFont systemFontOfSize:16];
                labelSex.textColor = [UIColor grayColor];
                labelSex.shadowColor = [UIColor whiteColor];
                labelSex.shadowOffset = CGSizeMake(0, 2.0f);
                labelSex.backgroundColor = [UIColor clearColor];
                
                NSString *curSex = [UConfig getGender];
                
                if([curSex isEqualToString:MALE])
                {
                    labelSex.text = @"男";
                }
                else
                {
                    labelSex.text = @"女";
                }
                
                cell.contentView.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:labelSex];
                
            }
            else if(indexPath.row == 3)
            {
                cellLabel.text = @"生日";
                
                birthLabel = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftMargin,7,120,30)];
                birthLabel.textAlignment = NSTextAlignmentLeft;
                birthLabel.font = [UIFont systemFontOfSize:16];
                birthLabel.textColor = [UIColor grayColor];
                birthLabel.shadowColor = [UIColor whiteColor];
                birthLabel.shadowOffset = CGSizeMake(0, 2.0f);
                birthLabel.backgroundColor = [UIColor clearColor];
                
                constellationLabel = [[UILabel alloc]initWithFrame:CGRectMake(birthLabel.frame.origin.x+birthLabel.frame.size.width+30, birthLabel.frame.origin.y, 90, 30)];
                constellationLabel.font = [UIFont systemFontOfSize:16];
                constellationLabel.textColor = [UIColor grayColor];
                constellationLabel.shadowColor = [UIColor whiteColor];
                constellationLabel.shadowOffset = CGSizeMake(0, 2.0f);
                constellationLabel.backgroundColor = [UIColor clearColor];
                
                if ([UConfig getBirthday].length > 0) {
                    birthLabel.text    = [UConfig getBirthday];
                    constellationLabel.text = [UConfig getConstellation];
                }else
                {
                    birthLabel.text    = @"请选择";
                    constellationLabel.text = @"星座";
                }
                lineView.hidden = YES;
                [cell.contentView addSubview:birthLabel];
                [cell.contentView addSubview:constellationLabel];
                
            }
            
            
        }
        else if (indexPath.section == 2)
        {
            if (indexPath.row == 0) {
                cellLabel.text = @"职业";
                
                UILabel *labelWork = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftMargin, (44-30)/2, 220, 30)];
                labelWork.textAlignment = NSTextAlignmentLeft;
                labelWork.font = [UIFont systemFontOfSize:16];
                labelWork.textColor = [UIColor grayColor];
                labelWork.shadowColor = [UIColor whiteColor];
                labelWork.shadowOffset = CGSizeMake(0, 2.0f);
                labelWork.backgroundColor = [UIColor clearColor];
                
                if([[UConfig getWork] length] > 0)
                {
                    labelWork.text = [UConfig getWork];
                }else
                {
                    labelWork.text = @"选择职业，找到同行";
                }
                
                [cell.contentView addSubview:labelWork];
            }
            else if (indexPath.row == 1)
            {
                cellLabel.text = @"公司";
                
                labelCompany = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftMargin, (44-30)/2, 220, 30)];
                labelCompany.textAlignment = NSTextAlignmentLeft;
                labelCompany.font = [UIFont systemFontOfSize:16];
                labelCompany.textColor = [UIColor grayColor];
                labelCompany.shadowColor = [UIColor whiteColor];
                labelCompany.shadowOffset = CGSizeMake(0, 2.0f);
                labelCompany.backgroundColor = [UIColor clearColor];
                
                if([[UConfig getCompany] length] > 0)
                {
                    labelCompany.text = [UConfig getCompany];
                }else
                {
                    labelCompany.text = @"填写公司，找到同事";
                }
                
                [cell.contentView addSubview:labelCompany];
            }
            else if (indexPath.row == 2)
            {
                cellLabel.text = @"学校";
                UILabel *labelSchool = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftMargin, (44-30)/2, 220, 30)];
                labelSchool.textAlignment = NSTextAlignmentLeft;
                labelSchool.font = [UIFont systemFontOfSize:16];
                labelSchool.textColor = [UIColor grayColor];
                labelSchool.shadowColor = [UIColor whiteColor];
                labelSchool.shadowOffset = CGSizeMake(0, 2.0f);
                labelSchool.backgroundColor = [UIColor clearColor];
                
                if([[UConfig getSchool] length] > 0)
                {
                    labelSchool.text = [UConfig getSchool];
                }else
                {
                    labelSchool.text = @"填写学校，找到同学";
                }
                
                [cell.contentView addSubview:labelSchool];
            }
            else if (indexPath.row == 3)
            {
                cellLabel.text = @"故乡";
                UILabel *labelHometown = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftMargin, (44-30)/2, 220, 30)];
                labelHometown.textAlignment = NSTextAlignmentLeft;
                labelHometown.font = [UIFont systemFontOfSize:16];
                labelHometown.textColor = [UIColor grayColor];
                labelHometown.shadowColor = [UIColor whiteColor];
                labelHometown.shadowOffset = CGSizeMake(0, 2.0f);
                labelHometown.backgroundColor = [UIColor clearColor];
                
                if([[UConfig getHometown] length] > 0)
                {
                    labelHometown.text = [UConfig getHometown];
                }else
                {
                    labelHometown.text = @"选择家乡，找到老乡";
                }
                
                lineView.hidden = YES;
                [cell.contentView addSubview:labelHometown];
            }
            
        }
        else
        {
            if (indexPath.row ==0) {
                //情感状态
                cellLabel.text = @"情感状态";
                labelFeelingStatus = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftMargin, (44-30)/2, 220, 30)];
                labelFeelingStatus.textAlignment = NSTextAlignmentLeft;
                labelFeelingStatus.font = [UIFont systemFontOfSize:16];
                labelFeelingStatus.textColor = [UIColor grayColor];
                labelFeelingStatus.shadowColor = [UIColor whiteColor];
                labelFeelingStatus.shadowOffset = CGSizeMake(0, 2.0f);
                labelFeelingStatus.backgroundColor = [UIColor clearColor];
                
                if([[UConfig getFeelStatus] length] > 0)
                {
                    NSString *strValue = [UConfig getFeelStatus];
                    labelFeelingStatus.text = strValue;
                    
                }else
                {
                    labelFeelingStatus.text = @"请选择你的情感状态";
                }
                
                lineView.hidden = NO;
                [cell.contentView addSubview:labelFeelingStatus];
            }
            else if (indexPath.row == 1)
            {
                //学历
                cellLabel.text = @"学历";
                labelDiploma = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftMargin, (44-30)/2, 220, 30)];
                labelDiploma.textAlignment = NSTextAlignmentLeft;
                labelDiploma.font = [UIFont systemFontOfSize:16];
                labelDiploma.textColor = [UIColor grayColor];
                labelDiploma.shadowColor = [UIColor whiteColor];
                labelDiploma.shadowOffset = CGSizeMake(0, 2.0f);
                labelDiploma.backgroundColor = [UIColor clearColor];
                
                if([[UConfig getDiploma] length] > 0)
                {
                    NSString *strValue = [UConfig getDiploma];
                    labelDiploma.text = strValue;
                    
                }else
                {
                    labelDiploma.text = @"请选择你的学历";
                }
                
                lineView.hidden = NO;
                [cell.contentView addSubview:labelDiploma];
            }
            else if (indexPath.row == 2)
            {
                //收入
                cellLabel.text = @"收入";
                labelMonthIncome = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftMargin, (44-30)/2, 220, 30)];
                labelMonthIncome.textAlignment = NSTextAlignmentLeft;
                labelMonthIncome.font = [UIFont systemFontOfSize:16];
                labelMonthIncome.textColor = [UIColor grayColor];
                labelMonthIncome.shadowColor = [UIColor whiteColor];
                labelMonthIncome.shadowOffset = CGSizeMake(0, 2.0f);
                labelMonthIncome.backgroundColor = [UIColor clearColor];
                
                if([[UConfig getMonthIncome] length] > 0)
                {
                    NSString *strValue = [UConfig getMonthIncome];
                    labelMonthIncome.text = strValue;
                    
                }else
                {
                    labelMonthIncome.text = @"请选择你的收入";
                }
                
                lineView.hidden = NO;
                [cell.contentView addSubview:labelMonthIncome];
            }
            else if (indexPath.row == 4)
            {
                //我的标签
                cellLabel.text = @"我的标签";
                
                markView = [[UIView alloc]initWithFrame:CGRectMake(CellLeftMargin, (44-30)/2, 220, 30)];
                markView.backgroundColor = [UIColor clearColor];
                
                if([[UConfig getSelfTags] length] > 0)
                {
                    markStr = [UConfig getSelfTags];
                    [self drawSelfTags:markStr];
                }else
                {
                    UILabel *labelMark = [[UILabel alloc]init];
                    labelMark.frame = CGRectMake(0, 0, markView.frame.size.width, markView.frame.size.height);
                    labelMark.text = @"请选择你的标签";
                    labelMark.textAlignment = NSTextAlignmentLeft;
                    labelMark.font = [UIFont systemFontOfSize:16];
                    labelMark.textColor = [UIColor grayColor];
                    labelMark.shadowColor = [UIColor whiteColor];
                    labelMark.shadowOffset = CGSizeMake(0, 2.0f);
                    labelMark.backgroundColor = [UIColor clearColor];
                    [markView addSubview:labelMark];
                }
                
                lineView.hidden = YES;
                [cell.contentView addSubview:markView];
            }
           
        }
        return cell;
    }
    
}

-(void)drawSelfTags:(NSString *)str
{
    NSArray *arr = [str componentsSeparatedByString:@"|"];
    if (arr.count>0) {
        
        CGFloat xWidth = 0.0;//用于记录x方向的位置
        for (NSInteger i=0; i<arr.count; i++) {
            NSString *str = arr[i];
            
            CGFloat bWidth = 0.0;//宽度 56.0f是一个默认值
            CGFloat bHeigth = 25.0;//高度度 为固定值
            CGFloat bMarginW = 5.0;//x方向的间距
            
            CGFloat strMaxWidth = markView.frame.size.width;//文本的最大宽度
            UIFont *font = [UIFont systemFontOfSize:14.0];
            
            CGFloat textLeftMargin = 6.0;//文本距btn左右两边的固定距离
            
            if (![Util isEmpty:str]) {
                CGSize strSize = [Util countTextSize:str MaxWidth:strMaxWidth MaxHeight:bHeigth UFont:font LineBreakMode:NSLineBreakByCharWrapping Other:nil];
                bWidth = strSize.width+2*textLeftMargin;
            }
            
            
            if (xWidth+bWidth>strMaxWidth) {
                //计算本次VELabel的originx
                //当将要描绘的VELabel超出屏幕时的处理（这种情况跟产品讨论过，因暂时，三个最长内容的标签长度不会超出屏幕右侧，且标签内容在很长一段时间内不会变更，这种情况先不做处理；以后万一长度超出了屏幕右侧，需正确产品超出的部分将以什么方式处理）
                
            }
            
            CGRect curRect = CGRectMake(xWidth, (markView.frame.size.height-bHeigth)/2, bWidth, bHeigth);
            VariableEditLabel *showVBLabel = [[VariableEditLabel alloc]init];
            showVBLabel.editType = 101;
            showVBLabel.showLabelColor = SelfTagsBlueColor;
            [showVBLabel showView:str refreshFrame:curRect];
            [markView addSubview:showVBLabel];
            
            xWidth += bMarginW+bWidth;
        }
        
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (dateView != nil) {
        [dateView hideView:YES];
    }
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            //昵称
            [self editNickname];
        }
        else if(indexPath.row == 1) {
            //手机号
        }
        else if(indexPath.row ==2){
            //性别
            UIActionSheet *editSexActionSheet  = [[UIActionSheet alloc]
                                                   initWithTitle:nil
                                                   delegate:self
                                                   cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                   otherButtonTitles: @"男", @"女",nil];
            
            //该方法解决点击Cancel Button很难响应的问题
            [editSexActionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
        else if(indexPath.row == 3)
        {
            //生日
            if(dateView == nil)
            {
                CGRect frame;
                frame = CGRectMake(0, KDeviceHeight-220, KDeviceWidth, 220);
                dateView = [[DateView alloc] initWithFrame:frame];
                dateView.delegate = self;
                [dateView showInView:self.view];
            }
        }
    }
    else if(indexPath.section == 1)
    {
        //签名
        [self editMood];
    }
    else if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            //职业
            OccupationViewController *occupationVC = [[OccupationViewController alloc]init];
            [self.navigationController pushViewController:occupationVC animated:YES];
        }
        else if(indexPath.row == 1)
        {
            //公司
            CompanyViewController *companyVC = [[CompanyViewController alloc]init];
            companyVC.delegate = self;
            [self.navigationController pushViewController:companyVC animated:YES];
        }
        else if(indexPath.row == 2)
        {
            //学校
            SchoolViewController *schoolVC = [[SchoolViewController alloc]init];
            [self.navigationController pushViewController:schoolVC animated:YES];
        }
        else if (indexPath.row == 3)
        {
            //故乡
            ProvinceViewController *provinceVC = [[ProvinceViewController alloc]init];
            [self.navigationController pushViewController:provinceVC animated:YES];
        }
    }
    else if (indexPath.section == 3)
    {
        if (indexPath.row ==0) {
            //情感状态
            if (curPickerView == nil) {
                CGRect frame;
                frame = CGRectMake(0, 0, KDeviceWidth, KDeviceHeight);
                
                curPickerView = [[DataPickerView alloc]initWithFrame:frame];
                curPickerView.title = FeelStatus;
                curPickerView.delegate = self;
                [curPickerView.dataMarr addObjectsFromArray:feelArr];
                curPickerView.curContent = [UConfig getFeelStatus];
                [curPickerView dataShowInView:self.navigationController.view];
            }
            
        }
        else if (indexPath.row == 1)
        {
            //学历
            if (curPickerView == nil) {
                CGRect frame;
                frame = CGRectMake(0, 0, KDeviceWidth, KDeviceHeight);
                
                curPickerView = [[DataPickerView alloc]initWithFrame:frame];
                curPickerView.title = Diploma;
                curPickerView.delegate = self;
                [curPickerView.dataMarr addObjectsFromArray:diplomaArr];
                curPickerView.curContent = [UConfig getDiploma];
                [curPickerView dataShowInView:self.navigationController.view];
            }
        }
        else if (indexPath.row == 2)
        {
            //收入
            if (curPickerView == nil) {
                
                CGRect frame;
                frame = CGRectMake(0, 0, KDeviceWidth, KDeviceHeight);
                
                curPickerView = [[DataPickerView alloc]initWithFrame:frame];
                curPickerView.title = MonthInCome;
                curPickerView.delegate = self;
                
                [curPickerView.dataMarr addObjectsFromArray:incomeArr];
                curPickerView.curContent = [UConfig getMonthIncome];
                [curPickerView dataShowInView:self.navigationController.view];
            }
        }
        else if (indexPath.row == 3)
        {
            //兴趣爱好
            HobbiesViewController *hobbiesVC = [[HobbiesViewController alloc]init];
            hobbiesVC.delegate = self;
            [self.navigationController pushViewController:hobbiesVC animated:YES];
        }
        else if (indexPath.row == 4)
        {
            //我的标签
            MarkViewController *markVC = [[MarkViewController alloc]init];
            markVC.delegate = self;
            markVC.showStr = [UConfig getSelfTags];
            [self.navigationController pushViewController:markVC animated:YES];
        }
    }

}

#pragma mark ---DrawChangeCell---
- (MoodTableViewCell *)drawChangeCell:(UITableView *)tableView ContentStr:(NSString *)contentStr Title:(NSString *)title HasLine:(BOOL)hasLine
{
    NSString *iden = title;
    MoodTableViewCell *moodcell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (moodcell == nil)
    {
        moodcell = [[MoodTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iden];
        
    }
    moodcell.backgroundColor = [UIColor whiteColor];
    UILabel *signLabel = [[UILabel alloc]init];
    signLabel.text =title;
    signLabel.textColor = [UIColor blackColor];
    signLabel.font = [UIFont systemFontOfSize:16];
    
    UILabel *contentLabel = [[UILabel alloc]init];
    contentLabel.font = [UIFont systemFontOfSize:16];
    contentLabel.frame = CGRectMake(CellLeftMargin,15, KDeviceWidth-100-15.0, 40);
    contentLabel.text = contentStr;
    contentLabel.textColor = [UIColor grayColor];
    contentLabel.numberOfLines = 2;
    
    [moodcell setName:signLabel ContentFrame:contentLabel];
    
    if (hasLine) {
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = [[UIColor alloc] initWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:0.5];;
        lineView.frame = CGRectMake(15.0, moodcell.frame.size.height-0.5, KDeviceWidth-15.0, 0.5);
        [moodcell addSubview:lineView];
    }
    
    UIImage *image = [UIImage imageNamed:@"msg_accview"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    moodcell.accessoryView = imageView;
    
    moodcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return moodcell;
}

#pragma mark ---NotificationEvent---
-(void)completeEvent
{
    NSString *workId = [UConfig getWorkId];
    if (![Util isEmpty:[UConfig getWork]]) {
        [updateInfoMdic setValue:workId forKey:@"occupation"];
    }
    
    NSString *school = [UConfig getSchool];
    if (![Util isEmpty:school]) {
        [updateInfoMdic setValue:school forKey:@"school"];
    }
    
    NSString *hometownId = [UConfig getHometownId];
    if (![Util isEmpty:[UConfig getHometown]]) {
        [updateInfoMdic setValue:hometownId forKey:@"native_region"];
    }
    
    [UConfig updateInfoPercent];//记录进度
    [self updateUserInfoStatus];
}

#pragma mark ---EditInformation----

-(void)editNickname
{
    ModifiedNickNameViewController *nickNameViewController = [[ModifiedNickNameViewController alloc] init];
    nickNameViewController.delegate = self;
    [self.navigationController pushViewController:nickNameViewController animated:YES];
}

-(void)editMood
{
    MoodViewController *moodViewController = [[MoodViewController alloc] init];
    moodViewController.delegate = self;
    [self.navigationController pushViewController:moodViewController animated:YES];
}

-(void)onNicknameUpdated:(NSString *)nickname
{
    labelnickname.text = nickname;
    [UConfig setNickname:nickname];
    
    [updateInfoMdic setValue:nickname forKey:@"nickname"];//上传用
    
    [UConfig updateInfoPercent];//记录进度
    [self updateUserInfoStatus];
}

-(void)onMoodUpdated:(NSString *)mood
{
    moodContentStr = mood;
    [UConfig setMood:mood];
    
    [updateInfoMdic setValue:mood forKey:@"emotion"];
    
    [UConfig updateInfoPercent];
    [self updateUserInfoStatus];
}

-(void)onCompanyUpdate:(NSString *)company
{
    labelCompany.text = company;
    [UConfig setCompany:company];
    
    [updateInfoMdic setValue:company forKey:@"company"];
   
    [UConfig updateInfoPercent];
    [self updateUserInfoStatus];
}

-(void)onHobbiesUpdated:(NSString *)hobbies
{
    hobbiesContentStr = hobbies;
    
    [UConfig setInterest:hobbies];
    
    isUpdateInfoToServer = YES;
    [updateInfoMdic setValue:hobbies forKey:@"interest"];
}

-(void)onTagsUpdated:(NSString *)tagsStr
{
    markStr = tagsStr;
    
    [UConfig setSelfTags:tagsStr];
    
    isUpdateInfoToServer = YES;
    [updateInfoMdic setValue:tagsStr forKey:@"self_tags"];

}

#pragma mark ---IBActionSheetDelegate---
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *curSex;
    if (curSex == nil) {
        curSex = [UConfig getGender];
    }
    switch (buttonIndex)
    {
        case 0:
        {
            curSex = MALE;
            labelSex.text = @"男";
        }
            break;
        case 1:
        {
            curSex = FEMALE;
            labelSex.text = @"女";
        }
            break;
    }
    
    [UConfig setGender:curSex];
    
    [updateInfoMdic setValue:[NSNumber numberWithInteger:[self genderFormot:curSex]] forKey:@"gender"];
    [UConfig updateInfoPercent];
    [self updateUserInfoStatus];
}
//设置性别
-(NSInteger)genderFormot:(NSString *)genderStr
{
    NSInteger genderInt ;
    if ([genderStr isEqualToString:MALE]) {
        genderInt = 2;
    }else if([genderStr isEqualToString:FEMALE])
    {
        genderInt = 1;
    }else{
        genderInt = 3;
    }
    return genderInt;
}

#pragma mark---DateViewDelegate---
-(void)hide:(NSDate *)birthday
{
    dateView = nil;
    if(birthday)
    {
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDateStr = [dateFormat stringFromDate:birthday];
        birthLabel.text = currentDateStr;
        
        NSString *constellationStr = [Util constellationFunction:birthLabel.text];
        [UConfig setConstellation:constellationStr];
        
        constellationLabel.text = constellationStr;
        [UConfig setBirthday:currentDateStr];
        [UConfig setBirthdayWithDouble:[NSString stringWithFormat:@"%lf",[birthday timeIntervalSince1970]*1000]];
        
        double birthdayTime = [birthday timeIntervalSince1970]*1000;
        [updateInfoMdic setValue:[NSNumber numberWithDouble:birthdayTime] forKey:@"birthday"];
        
        [UConfig updateInfoPercent];
        [self updateUserInfoStatus];
    }
    
}

-(void)dataHide:(NSDictionary *)dic
{
    curPickerView = nil;
    NSString *typeName = [dic objectForKey:@"typeName"];
    NSString *strValue = [dic objectForKey:@"strValue"];
    if ([typeName isEqualToString:FeelStatus] && strValue!=nil) {
        
        labelFeelingStatus.text = strValue;
        
        [UConfig setFeelStatus:strValue];
        
        isUpdateInfoToServer = YES;
        [updateInfoMdic setValue:strValue forKey:@"feeling_status"];
    }
    else if ([typeName isEqualToString:Diploma] && strValue!=nil)
    {
        labelDiploma.text = strValue;
        
        [UConfig setDiploma:strValue];
        
        isUpdateInfoToServer = YES;
        [updateInfoMdic setValue:strValue forKey:@"diploma"];
    }
    else if ([typeName isEqualToString:MonthInCome] && strValue!=nil)
    {
        labelMonthIncome.text = strValue;
        
        [UConfig setMonthIncome:strValue];
        
        isUpdateInfoToServer = YES;
        [updateInfoMdic setValue:strValue forKey:@"month_income"];
    }
    
}

-(void)dataTouchEnd:(id)sender
{
    DataPickerView *aPickerView = (DataPickerView *)sender;
    [aPickerView dataHideView:NO Title:aPickerView.title];
    
}

#pragma mark---HTTPManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    BOOL showXAlert = NO;
    if (eType == RequestNewTaskGive) {
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            NewTaskGiveDataSource *newTaskgiveDS = (NewTaskGiveDataSource *)theDataSource;
            NSString *miniteStr= [UConfig getNewTaskMinite];
            if (miniteStr == nil) {
                miniteStr = @"0";
            }
            NSInteger miniteNumber = miniteStr.integerValue+newTaskgiveDS.giveTime.integerValue;
            [UConfig setNewTaskMinite:[NSString stringWithFormat:@"%d",miniteNumber]];
            
            [self setGiftShowNumber:0];
            NSString *giveTime = newTaskgiveDS.giveTime;
            if (giveTime.integerValue !=0 && giveTime != nil ) {
                
                CGPoint point = CGPointMake(KDeviceWidth/2, KDeviceHeight/2+iToastHeight);
                [[[iToast makeText:[NSString stringWithFormat:@"恭喜您获得%@分钟免费时\n长,将于2分钟内到账。",giveTime]] setPostion:point] show];
                iToastHeight+=70.0;
            }
        }
        else
        {
            //result!=1
            showXAlert = YES;
        }
    }
    else if (eType == RequestCheckTask)
    {
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            CheckTaskDataSource *checkTaskDataSource = (CheckTaskDataSource *)theDataSource;
            [self setGiftShowType:checkTaskDataSource.taskInformationMdic];
        }
    }
    else if (eType == RequestUpdateUserBaseInfo)
    {
        if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1)
        {
            [self afterUpdateInfoRequestNewTask];
        }
    }
    if(!bResult && showXAlert)
    {
        XAlertView *alert = [[XAlertView alloc] initWithTitle:@"提示" message:@"连接服务器超时，请稍后再试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        showXAlert = NO;
        return;
    }
}

#pragma mark ---判断是否上传个人信息和gift图标更新

-(void)updateUserInfoStatus
{
    isUpdateInfoToServer = YES;
    [self checkGiftShow];
}

//设置右上角gift图标状态
-(void)checkGiftShow
{
    NSInteger showNumber = 0;
    NSInteger count = [(NSString *)[UConfig getInfoPercent] integerValue];
    NSInteger achieveMinite = [UConfig getNewTaskMinite].integerValue;
    if (count>=40 && achieveMinite < 15){
        showNumber += 15;
    }
    if (count>=70 && achieveMinite < 30) {
        showNumber += 15;
    }
    if (count==100 && achieveMinite < 60) {
        showNumber += 30;
    }
    
    [self setGiftShowNumber:showNumber];
}

-(void)setGiftShowNumber:(NSInteger)showNumber
{
    if (showNumber == 15) {
        [giftFinishBtn setBackgroundImage:[UIImage imageNamed:@"gift_finish_15"] forState:(UIControlStateNormal)];
    }else if (showNumber == 30){
        [giftFinishBtn setBackgroundImage:[UIImage imageNamed:@"gift_finish_30"] forState:(UIControlStateNormal)];
    }else if (showNumber == 45){
        [giftFinishBtn setBackgroundImage:[UIImage imageNamed:@"gift_finish_45"] forState:(UIControlStateNormal)];
    }else if (showNumber == 60)
    {
        [giftFinishBtn setBackgroundImage:[UIImage imageNamed:@"gift_finish_60"] forState:(UIControlStateNormal)];
    }else{
        [giftFinishBtn setBackgroundImage:[UIImage imageNamed:@"gift_finish_nor"] forState:(UIControlStateNormal)];
    }
    NSInteger miniteCount =[(NSString *)[UConfig getNewTaskMinite] integerValue];
    if (miniteCount==60) {
        giftFinishBtn.hidden = YES;
    }
    
}

//用户卸载软件后，再次下载软件，会检测用户用户gift图标该显示什么状态。
-(void)setGiftShowType:(NSDictionary *)dic
{
    NSInteger showNumber = 0;
    BOOL firstNode = [(TaskObject *)[dic objectForKey:@"userinfo_firstnode"] isGive];
    BOOL secondNode = [(TaskObject *)[dic objectForKey:@"userinfo_secondnode"] isGive];
    BOOL thirdNode = [(TaskObject *)[dic objectForKey:@"userinfo_thirdnode"] isGive];
    
    //未领取
    NSInteger count = [(NSString *)[UConfig getInfoPercent] integerValue];
    if (count>=40 && !firstNode){
        showNumber += 15;
    }
    if (count>=70 && !secondNode) {
        showNumber += 15;
    }
    if (count==100 && !thirdNode) {
        showNumber += 30;
    }
    
    
    if (firstNode) {
        [UConfig setNewTaskMinite:[NSString stringWithFormat:@"%d",15]];
    }
    if (secondNode) {
        [UConfig setNewTaskMinite:[NSString stringWithFormat:@"%d",30]];
    }
    if (thirdNode) {
        [UConfig setNewTaskMinite:[NSString stringWithFormat:@"%d",60]];
    }
    
    
    [self setGiftShowNumber:showNumber];
}
@end
