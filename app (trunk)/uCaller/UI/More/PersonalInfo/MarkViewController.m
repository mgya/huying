//
//  MarkViewController.m
//  uCaller
//
//  Created by HuYing on 15/5/28.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "MarkViewController.h"
#import "UIUtil.h"
#import "GetTagNamesDataSource.h"
#import "UConfig.h"
#import "Util.h"
#import "iToast.h"

#define TagsArr @"TagsArr"
#define KTagsNamePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Common/tagsNameArr.arc"]

#define LeftMargin  15.0


@implementation TagsName
@synthesize tagsMarr;

-(id)init
{
    if (self = [super init]) {
        tagsMarr = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:tagsMarr forKey:TagsArr];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        tagsMarr = [aDecoder decodeObjectForKey:TagsArr];

    }
    return self;
}

@end

@interface MarkViewController ()
{
    NSInteger tagsNum;//已选标签的数量
    
    NSMutableArray *tagsSectionMarr;//标签总量
    NSMutableArray *tagsShowMarr;//已选择的标签
    
    HTTPManager *getTagsHttp;//获取全部标签
    
    UIScrollView *bgScrollView;
    
    UIView *tagsSectionView;
    UILabel *showCountLabel;
    
    VariableEditLabel *show1;
    VariableEditLabel *show2;
    VariableEditLabel *show3;
    
    UIButton *confirmButton;
}
@end

@implementation MarkViewController
@synthesize delegate;
@synthesize showStr;

-(id)init
{
    if (self = [super init]) {
        tagsSectionMarr = [[NSMutableArray alloc]init];
        tagsShowMarr = [[NSMutableArray alloc]init];
        
        //取全部标签
        [self getAllTags];
    }
    return self;
}

//获取标签规则为，每隔24h从新从服务器获取一次，每次获取下载存到本地，并记录一个获取时间
-(void)getAllTags
{

    NSDate *today = [NSDate date];
    NSDate *tagsDate = [UConfig getTagsArrObjTime];//上次存入标签的时间
    if (tagsDate != nil) {
        NSTimeInterval time=[today timeIntervalSinceDate:tagsDate];
        if(time < (24*60*60) && [[NSFileManager defaultManager] fileExistsAtPath:KTagsNamePath])
        {
            TagsName *tagsObj = [[TagsName alloc]init];
            tagsObj = [NSKeyedUnarchiver unarchiveObjectWithFile:KTagsNamePath];
            
            [tagsSectionMarr addObjectsFromArray:tagsObj.tagsMarr];
        }
        else
        {
            [self getHttp];
        }
    }
    else
    {
        [self getHttp];
    }
}

-(void)getHttp
{
    getTagsHttp = [[HTTPManager alloc]init];
    getTagsHttp.delegate = self;
    [getTagsHttp getTagNames];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"我的标签";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(KDeviceWidth-NAVI_MARGINS-RIGHTITEMWIDTH, (NAVI_HEIGHT-RIGHTITEMWIDTH)/2, RIGHTITEMWIDTH, RIGHTITEMWIDTH);
    [confirmButton setTitle:@"完成" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:RIGHTITEMFONT];
    [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.hidden = YES;
    [self addNaviSubView:confirmButton];
    
    
    bgScrollView = [[UIScrollView alloc]init];
    bgScrollView.frame = CGRectMake(0, LocationY+10, KDeviceWidth, KDeviceHeight-LocationY-10);
    bgScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgScrollView];
    
    //已选标签
    UIView *showView = [[UIView alloc]init];
    showView.backgroundColor = [UIColor clearColor];
    showView.frame = CGRectMake(0, 0, KDeviceWidth, 20);
    [bgScrollView addSubview:showView];
    
    //展示已选标签数量
    showCountLabel = [[UILabel alloc]init];
    showCountLabel.frame = CGRectMake(LeftMargin, 0, KDeviceWidth-2*LeftMargin, showView.frame.size.height) ;
    showCountLabel.textColor = [UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1.0];
    showCountLabel.backgroundColor = [UIColor clearColor];
    showCountLabel.textAlignment = NSTextAlignmentLeft;
    showCountLabel.font = [UIFont systemFontOfSize:14];
    [showView addSubview:showCountLabel];
    
    [self showCountContent];
    
    //已选标签内容展示区
    UIView *contentView = [[UIView alloc]init];
    contentView.frame = CGRectMake(0, showView.frame.origin.y+showView.frame.size.height+10, KDeviceWidth, 40.0);
    contentView.backgroundColor = [UIColor whiteColor];
    [bgScrollView addSubview:contentView];
    
    show1 = [[VariableEditLabel alloc]init];
    show1.editType = 102;
    show1.delegate = self;
    [contentView addSubview:show1];
    
    show2 = [[VariableEditLabel alloc]init];
    show2.editType = 102;
    show2.delegate = self;
    [contentView addSubview:show2];
    
    show3 = [[VariableEditLabel alloc]init];
    show3.editType = 102;
    show3.delegate = self;
    [contentView addSubview:show3];
    
   
    //添加标签
    UILabel *addTagsLabel = [[UILabel alloc]init];
    addTagsLabel.frame = CGRectMake(LeftMargin, contentView.frame.origin.y+contentView.frame.size.height+43.0, KDeviceWidth-2*LeftMargin, 20) ;
    addTagsLabel.textColor = [UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1.0];
    addTagsLabel.backgroundColor = [UIColor clearColor];
    addTagsLabel.textAlignment = NSTextAlignmentLeft;
    addTagsLabel.text = @"添加标签";
    addTagsLabel.font = [UIFont systemFontOfSize:14];
    [bgScrollView addSubview:addTagsLabel];
    
    //选择标签
    CGFloat tagsSectionViewOriginY = addTagsLabel.frame.origin.y+addTagsLabel.frame.size.height+25.0;
    tagsSectionView = [[UIView alloc]init];
    tagsSectionView.frame = CGRectMake(LeftMargin, tagsSectionViewOriginY, KDeviceWidth-2*LeftMargin, bgScrollView.frame.size.height-tagsSectionViewOriginY);
    tagsSectionView.backgroundColor = [UIColor clearColor];
    [bgScrollView addSubview:tagsSectionView];
    

    [self strTransArr:showStr];

    [self tagsShowRefresh];
    
    if (tagsSectionMarr.count>0) {
        [self tagsSectionLoad];
    }
    
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnLastPage
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)confirmBtnClicked
{
    NSString *str = [self arrTransfromStr];
    if (str==nil) {
        str = @"";
    }
    if (delegate && [delegate respondsToSelector:@selector(onTagsUpdated:)]) {
        [delegate onTagsUpdated:str];
        [self returnLastPage];
    }
    
}


//字符串转化成数组
-(void)strTransArr:(NSString *)str
{
    if ([Util isEmpty:str]) {
        NSArray *arr = @[@"",@"",@""];
        [tagsShowMarr addObjectsFromArray:arr];
        return;
    }
    else
    {
        NSArray *arr0 =[str componentsSeparatedByString:@"|"];
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        for (NSInteger i=0; i<arr0.count; i++) {
            NSString *string = arr0[i];
            if(![Util isEmpty:string] ) {
                [arr addObject:string];
            }
        }
        
        if (arr.count>0) {
            if (arr.count>3) {
                tagsNum = 3;
            }
            else
            {
                tagsNum = arr.count;
            }
            
            [self showCountContent];
        }
        [tagsShowMarr removeAllObjects];
        
        if (arr.count>=3) {
            NSMutableArray *newMarr = [[NSMutableArray alloc]init];
            for (NSInteger i=0; i<3; i++) {
                [newMarr addObject:arr[i]];
            }
            [tagsShowMarr addObjectsFromArray:newMarr];
        }
        else
        {
            [tagsShowMarr addObjectsFromArray:arr];
        }
        
        if (arr.count>=3) {
            return;
        }
        for (NSInteger i=0; i<3-arr.count; i++) {
            [tagsShowMarr addObject:@""];
        }
    }
    
}

//数组转化成字符串
-(NSString *)arrTransfromStr
{
    NSString *result;
    if (tagsShowMarr.count==3) {
        
        for (NSInteger i=0; i<tagsShowMarr.count; i++) {
            NSString *str = tagsShowMarr[i];
            if (![Util isEmpty:str]) {
                if (i==0) {
                    result = [NSString stringWithFormat:@"%@",str];
                }
                else
                {
                    result = [NSString stringWithFormat:@"%@|%@",result,str];
                }
            }
        }
    }
    return result;
}



#pragma mark ---ShowCountLabel---
-(void)showCountContent
{
    NSInteger count = tagsNum;
    showCountLabel.text = [NSString stringWithFormat:@"已选标签 %ld/3",count];
    if (count < 0) {
        NSMutableAttributedString *strSharePrize=[[NSMutableAttributedString alloc]initWithString:showCountLabel.text];
        [strSharePrize addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(5,3)];
        showCountLabel.attributedText = strSharePrize;
    }
}

-(void)tagsShowRefresh
{
    if (tagsShowMarr.count ==3) {
        
        CGFloat xWidth = LeftMargin;//用于记录x方向的位置
        for (NSInteger i=0; i<3; i++) {
            NSString *str = [tagsShowMarr objectAtIndex:i];
            
            CGFloat bWidth = 56.0;//btn宽度 56.0f是一个默认值
            CGFloat bHeigth = 25.0;//btn高度度 为固定值
            CGFloat bMarginW = 15.0;//btn x方向的间距
            
            CGFloat strMaxWidth = KDeviceWidth-2*LeftMargin;//文本的最大宽度
            UIFont *font = [UIFont systemFontOfSize:12.0];
            
            CGFloat textLeftMargin = 6.0;//文本距btn左右两边的固定距离
            
            if (![Util isEmpty:str]) {
                CGSize strSize = [Util countTextSize:str MaxWidth:strMaxWidth MaxHeight:bHeigth UFont:font LineBreakMode:NSLineBreakByCharWrapping Other:nil];
                bWidth = strSize.width+2*textLeftMargin;
            }
            
            
            if (xWidth+bWidth>strMaxWidth) {
                //计算本次btn的originx
                //此情况暂时不会发生，但要处理
                
            }
            
            CGRect curRect = CGRectMake(xWidth, 0, bWidth, bHeigth);
            
            if (i==0) {
                [show1 showView:str refreshFrame:curRect];
            }
            else if (i==1)
            {
                [show2 showView:str refreshFrame:curRect];
            }
            else if (i==2)
            {
                [show3 showView:str refreshFrame:curRect];
            }
            
            
            xWidth += bMarginW+bWidth;
        }
        
    }
    
}

#pragma mark ---TagsShowViewDelegate---
-(void)clearContent:(NSString *)strContent
{
    NSString *str = strContent;
    if ([Util isEmpty:str]) {
        return;
    }
   
    for (NSInteger i=0; i<3; i++) {
        NSString *string = tagsShowMarr[i];
        if ([string isEqualToString:str]) {
            
            [tagsShowMarr removeObjectAtIndex:i];
            [tagsShowMarr addObject:@""];
            break;
        }
    }
    
    confirmButton.hidden = NO;
    
    [self tagsShowRefresh];
    tagsNum--;
    [self showCountContent];
    
}


//全部标签load
-(void)tagsSectionLoad
{
    if (tagsSectionMarr.count>0) {
        
        CGFloat xWidth = 0.0;//用于记录x方向的位置
        CGFloat yHeight = 0.0;//用于记录y方向的位置
        
        for (NSInteger i=0; i<tagsSectionMarr.count; i++) {
            NSString *str = tagsSectionMarr[i];
            
            if ([Util isEmpty:str]) {
                continue;//取到空内容时不显示
            }
            
            CGFloat bWidth = 34.0;//btn宽度 34.0f是一个默认值
            CGFloat bHeigth = 25.0;//btn高度度 为固定值
            CGFloat bMarginW = 15.0;//btn x方向的间距
            CGFloat bMarginH = 15.0;//btn y方向的间距
            
            CGFloat strMaxWidth = tagsSectionView.frame.size.width;//文本的最大宽度
            UIFont *font = [UIFont systemFontOfSize:12.0];
            
            CGFloat textLeftMargin = 6.0;//文本距btn左右两边的固定距离
            
            CGSize strSize = [Util countTextSize:str MaxWidth:strMaxWidth MaxHeight:bHeigth UFont:font LineBreakMode:NSLineBreakByCharWrapping Other:nil];
            bWidth = strSize.width+2*textLeftMargin;
            
            if (xWidth+bWidth>strMaxWidth) {
                //计算本次btn的originx，与originy
                xWidth=0.0;
                yHeight += bHeigth+bMarginH;
                
                if (yHeight>tagsSectionView.frame.size.height) {
                    //标签太多超出tagsSectionView的情况
                    
                    
                }
            }
            
            UIButton *btn = [[UIButton alloc]init];
            btn.frame = CGRectMake(xWidth, yHeight, bWidth, bHeigth);
            btn.titleLabel.font = font;
            [btn setTitle:str forState:(UIControlStateNormal)];
            [btn setTitleColor:SelfTagsBlueColor forState:(UIControlStateNormal)];
            btn.layer.borderWidth = 0.5;
            btn.layer.borderColor = SelfTagsBlueColor.CGColor;
            btn.layer.cornerRadius = SelfTags_RornerRadius;
            [btn addTarget:self action:@selector(addTagsFunction:) forControlEvents:(UIControlEventTouchUpInside)];
            [tagsSectionView addSubview:btn];
            
            xWidth  += bWidth+bMarginW;
        }
    }
    
}

-(void)addTagsFunction:(id)sender
{
    UIButton *btn = (UIButton  *)sender;
    NSString *strContent = btn.titleLabel.text;
    if (tagsNum<3) {
        
        if ([Util isEmpty:strContent]) {
            return;
        }
        
        for (NSString *aStr in tagsShowMarr) {
            if ([aStr isEqualToString:strContent]) {
                return;
            }
        }
        
        confirmButton.hidden = NO;
        
        [tagsShowMarr replaceObjectAtIndex:tagsNum withObject:strContent];
        
        tagsNum++;
        [self tagsShowRefresh];
        [self showCountContent];
    }
    else if(tagsNum == 3)
    {
        NSString *msg = [NSString stringWithFormat:@"最多选择3个标签"];
        CGPoint point = CGPointMake(KDeviceWidth/2, KDeviceHeight-50);
        [[[iToast makeText:msg] setPostion:point] show];
    }
}


#pragma mark ---HttpManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (!bResult) {
        return;
    }
    
    if (eType == RequestGetTagNames) {
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            GetTagNamesDataSource *tagsDataSource = (GetTagNamesDataSource *)theDataSource;
            NSArray *arr = tagsDataSource.tagsMarr;
            
            [tagsSectionMarr addObjectsFromArray:arr];//传值用于本次进入显示
            [self tagsSectionLoad];
            
            TagsName *tagsObj = [[TagsName alloc]init];
            [tagsObj.tagsMarr addObjectsFromArray:arr];//传值给obj用于存储
            [NSKeyedArchiver archiveRootObject:tagsObj toFile:KTagsNamePath];
            
            [UConfig setTagsArrObjTime:[NSDate date]];
            
        }
    }
}


@end
