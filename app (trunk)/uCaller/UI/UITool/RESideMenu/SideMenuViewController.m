//
//  SideMenuViewController.m
//  uCaller
//
//  Created by wangxiongtao on 15/8/16.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "SideMenuViewController.h"
#import "REIDinfo.h"
#import "UConfig.h"
#import "RESideMenuItem.h"
#import "RESideMenuCell.h"
#import "GetAdsContentDataSource.h"
#import "CoreType.h"
#import "WebViewController.h"
#import "MainViewController.h"

@interface SideMenuViewController ()


@property (strong, readonly, nonatomic)  REIDinfo * reIDinfo;
@property (strong, readonly, nonatomic)  UIButton * setButton;
@property (strong, readonly, nonatomic)  UIButton * soundButton;
//@property (strong, readonly, nonatomic)  AdsView  * adButton;


@property (strong, readonly, nonatomic) UIImageView * setButtonImageView;
@property (strong, readonly, nonatomic) UILabel * setButtonTitle;


@property (strong, readonly, nonatomic) UIImageView * soundButtonImageView;
@property (strong, readonly, nonatomic) UILabel * soundButtonTitle;

@property (strong,readonly,nonatomic)UITableView *menuTableView;


@property (assign, readwrite, nonatomic) CGFloat verticalOffset;


@property (strong, readwrite, nonatomic) NSMutableArray *menuStack;
@property (strong, readwrite, nonatomic) RESideMenuItem *backMenu;

@property (strong, readonly, nonatomic)  AdsView  * adButton;
@property (strong,nonatomic) UIImageView *doubleView;



@end



@implementation SideMenuViewController


- (id)initWithItems:(NSArray *)items
{
    self = [self init];
    if (!self)
        return nil;
    
    _items = items;
    [_menuStack addObject:items];
    _backMenu = [[RESideMenuItem alloc] initWithTitle:@"<" image:@"icon_29" action:nil];

    return self;
}


- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    

    
    self.verticalOffset = 100;
    self.horizontalOffset = KWidthCompare6*23;//滑动菜单左边距
    self.itemHeight = 45*KHeightCompare6;
    self.textColor = [UIColor whiteColor];
    self.highlightedTextColor = [UIColor lightGrayColor];
   // self.hideStatusBarArea = YES;
    self.font = [UIFont systemFontOfSize:15];
    
    
    _menuStack = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadAdsContent:)
                                                 name:KAdsContent
                                               object:nil];

    return self;
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCoreEvent:)
                                                 name:NContactEvent
                                               object:nil];

    [self setNaviHidden:YES];
    
    //做菜单的位置
    _menuTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kKHeightCompare6*68+70+30+KHeightCompare6*55+20, KDeviceWidth, 300*KHeightCompare6)];
    _menuTableView.delegate = self;
    _menuTableView.dataSource = self;
    _menuTableView.backgroundColor = [UIColor clearColor];
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
    UIImage * setButtonImage = [UIImage imageNamed:@"setoff"];;
    
    _setButtonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, setButtonImage.size.width, setButtonImage.size.height)];
    _setButtonImageView.image = setButtonImage;
    
    _setButtonTitle = [[UILabel alloc]initWithFrame:CGRectMake(setButtonImage.size.width+10*KWidthCompare6,0,KWidthCompare6*26*2,setButtonImage.size.height)];
    _setButtonTitle.font = [UIFont systemFontOfSize:13];
    [_setButtonTitle setText:@"设置"];
    [_setButtonTitle setTextColor:[UIColor whiteColor]];
    _setButtonTitle.backgroundColor = [UIColor clearColor];
    
    _setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _setButton.frame = CGRectMake(23*KWidthCompare6,  self.view.frame.size.height -30*kKHeightCompare6-setButtonImage.size.height, setButtonImage.size.width + KWidthCompare6*10+KWidthCompare6*26*2, setButtonImage.size.height);
    
    _setButton.backgroundColor  = [UIColor clearColor];
    [_setButton addSubview:_setButtonTitle];
    [_setButton addSubview:_setButtonImageView];
    [_setButton addTarget:self action:@selector(setup) forControlEvents:UIControlEventTouchUpInside];
    [_setButton addTarget:self action:@selector(setdown) forControlEvents:UIControlEventTouchDown];
    [_setButton addTarget:self action:@selector(setupOutside) forControlEvents:UIControlEventTouchDragOutside];

    
    UIImage * soundButtonImage;
    
    if ([UConfig getMuteMode]) {
        soundButtonImage = [UIImage imageNamed:@"NotTroubleon-off"];
    }else{
        soundButtonImage = [UIImage imageNamed:@"NotTroubleoff-off"];
    }
    _soundButtonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, soundButtonImage.size.width, soundButtonImage.size.height)];
    _soundButtonImageView.image = soundButtonImage;
    
    _soundButtonTitle = [[UILabel alloc]initWithFrame:CGRectMake(soundButtonImage.size.width+10*KWidthCompare6,0,KWidthCompare6*26*3,soundButtonImage.size.height)];
    _soundButtonTitle.font = [UIFont systemFontOfSize:13];
    [_soundButtonTitle setText:@"免打扰"];
    [_soundButtonTitle setTextColor:[UIColor whiteColor]];
    
    _soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _soundButton.frame = CGRectMake(23*KWidthCompare6 + _setButton.frame.size.width + 46*KWidthCompare6, self.view.frame.size.height -30*kKHeightCompare6 - soundButtonImage.size.height, setButtonImage.size.width + KWidthCompare6*10+KWidthCompare6*26*3, setButtonImage.size.height);
    
    
    _soundButtonTitle.backgroundColor = [UIColor clearColor];
    _soundButton.backgroundColor = [UIColor clearColor];
    [_soundButton addSubview:_soundButtonTitle];
    [_soundButton addSubview:_soundButtonImageView];
    [_soundButton addTarget:self action:@selector(sound) forControlEvents:UIControlEventTouchUpInside];
    [_soundButton addTarget:self action:@selector(soundDown) forControlEvents:UIControlEventTouchDown];
    [_soundButton addTarget:self action:@selector(soundOutside) forControlEvents:UIControlEventTouchDragOutside];

    
    self.doubleView = [[UIImageView alloc]init];
    
    ///////end
    
    _adButton = [[AdsView alloc] initWithFrame:CGRectMake(23*KWidthCompare6, _setButton.frame.origin.y - kKHeightCompare6*78,KWidthCompare6* 230,kKHeightCompare6*60)];
    _adButton.backgroundColor = [UIColor clearColor];
    UIImage * adButtonImage = [GetAdsContentDataSource sharedInstance].imgLeftBar;
    _adButton.delegate = self;
    if (adButtonImage != nil && ![UConfig getIsAdsCloseLeftBar]) {
        if (![UConfig getVersionReview]) {
            [_adButton setBackgroundImage:adButtonImage];
        }
    }
    else {
        _adButton.hidden = YES;
    }
    
    [self.view addSubview:_menuTableView];
    [self.view addSubview:_adButton];
    [self.view addSubview:_setButton];
    [self.view addSubview:_soundButton];
    
    _menuTableView.scrollEnabled = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UConfig getVersionReview]) {
        return _items.count - 2;
    }
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 45*KHeightCompare6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = @"RESideMenuCell";
    
    RESideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[RESideMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.textLabel.font = self.font;
        cell.textLabel.textColor = self.textColor;
    }
    
    RESideMenuItem *item;
    
    if ([UConfig getVersionReview]) {
        
        switch (indexPath.row) {
            case 0:{
                item = [_items objectAtIndex:indexPath.row];
                break;
            }
            case 1:{
                item = [_items objectAtIndex:2];
                break;
            }
            case 2:{
                item = [_items objectAtIndex:4];
                
                break;
            }
            default:
               
                break;
        }

    }else{
       item = [_items objectAtIndex:indexPath.row];
#ifdef HOLIDAY
        if (indexPath.row == 4) {
            cell.rightImage = [UIImage imageNamed:@"doubleGive"];
        }
#endif
    }
    
    cell.textLabel.text = item.title;
    cell.imageView.image = item.image;
    cell.imageView.highlightedImage = item.highlightedImage;
    cell.horizontalOffset = KWidthCompare6*23;
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
    
    
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([UConfig getVersionReview]) {
        
        NSInteger temp = 0;
        switch (indexPath.row) {
            case 0:
                temp = 0;
                break;
            case 1:
                temp = 2;
                break;
            case 2:
                temp = 4;
                break;
                
            default:
                break;
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        RESideMenuItem *item = [_items objectAtIndex:temp];
        
        if (item.action)
            item.action(nil);
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        RESideMenuItem *item = [_items objectAtIndex:indexPath.row];
        
        if (item.action)
            item.action(nil);
    }

}



-(void)setupOutside{
     _setButtonImageView.image = [UIImage imageNamed:@"setoff"];
    [_setButtonTitle setTextColor:[UIColor whiteColor]];

}


-(void)setup{
    NSLog(@"设置按钮");
    [_setButtonTitle setTextColor:[UIColor whiteColor]];
    _setButtonImageView.image = [UIImage imageNamed:@"setoff"];

    if (self.delegate && [self.delegate respondsToSelector:@selector(jumpMenu:)]) {
        [self.delegate jumpMenu:0];
    }
}

-(void)setdown{
    _setButtonImageView.image = [UIImage imageNamed:@"seton"];
    [_setButtonTitle setTextColor:[ UIColor colorWithRed: 1  green: 1  blue: 1  alpha: 0.4  ]];
}

-(void)sound{
    NSLog(@"提醒按钮");
    [_soundButtonTitle setTextColor:[UIColor whiteColor]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(jumpMenu:)]) {
        [self.delegate jumpMenu:1];
    }
}

-(void)soundDown{
    [_soundButtonTitle setTextColor:[ UIColor colorWithRed: 1  green: 1  blue: 1  alpha: 0.4]];
    if ([UConfig getMuteMode]) {
         _soundButtonImageView.image  = [UIImage imageNamed:@"NotTroubleon-on"];
    }else{
         _soundButtonImageView.image  = [UIImage imageNamed:@"NotTroubleoff-on"];
    }
}

-(void)soundOutside{
    [_soundButtonTitle setTextColor:[UIColor whiteColor]];
    if ([UConfig getMuteMode]) {
        _soundButtonImageView.image = [UIImage imageNamed:@"NotTroubleon-off"];
    }else{
        _soundButtonImageView.image = [UIImage imageNamed:@"NotTroubleoff-off"];
    }
}

-(void)editMood{
    if (self.delegate && [self.delegate respondsToSelector:@selector(jumpMenu:)]) {
        [self.delegate jumpMenu:2];
    }
}

-(void)editInfo{
    NSLog(@"!!!");
    if (self.delegate && [self.delegate respondsToSelector:@selector(jumpMenu:)]) {
        [self.delegate jumpMenu:4];
    }
}

-(void)myTime{
    if (self.delegate && [self.delegate respondsToSelector:@selector(jumpMenu:)]) {
        [self.delegate jumpMenu:5];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([UConfig getMuteMode]) {
        _soundButtonImageView.image = [UIImage imageNamed:@"NotTroubleon-off"];
    }else{
        _soundButtonImageView.image = [UIImage imageNamed:@"NotTroubleoff-off"];
    }
    if (_reIDinfo == nil) {
        _reIDinfo = [[REIDinfo alloc]initWithFrame:CGRectMake(KWidthCompare6*23, KHeightCompare6*55, KDeviceWidth*0.82-KWidthCompare6*23, 70+112*KHeightCompare6)];
        _reIDinfo.backgroundColor = [UIColor clearColor];
        [_reIDinfo initItem];
        _reIDinfo.delegate = self;
        [self.view addSubview:_reIDinfo];
    }else{
        [_reIDinfo initItem];
    }

    [_menuTableView reloadData];

}


- (void)viewWillDisappear:(BOOL)animated{


}


- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

-(void)didAdsContent{
    NSLog(@"广告");

    [uApp.rootViewController initZoom];
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.webUrl = [GetAdsContentDataSource sharedInstance].urlLeftBar;

    [uApp.rootViewController.navigationController pushViewController:webVC animated:YES];
}

-(void)didAdsClose
{
    [UConfig setIsAdsCloseLeftBar:YES];
    _adButton.hidden = YES;
}

-(void)loadAdsContent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == AdsImgUrlLeftBarUpdate)
    {
        if ([UConfig getVersionReview]) {
            return ;
        }
        
        UIImage* image = [eventInfo objectForKey:KValue];
        if (image != nil) {
            [_adButton setBackgroundImage:image];
            _adButton.hidden = NO;
        }
    }
}




-(void)UpdateReidinfo{
    [_reIDinfo UpdataAccountBalance];
}

-(void)onCoreEvent:(NSNotification *)notification
{
    NSDictionary *statusInfo = [notification userInfo];
    int event = [[statusInfo objectForKey:KEventType] intValue];
    if(event == UserInfoUpdate)
    {
        [_reIDinfo initItem];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
