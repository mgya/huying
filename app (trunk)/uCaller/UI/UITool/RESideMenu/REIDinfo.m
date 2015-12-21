//
//  REIDinfo.m
//  uCaller
//
//  Created by wangxiongtao on 15/7/2.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "REIDinfo.h"
#import "UConfig.h"
#import "UDefine.h"

#import "GetAdsContentDataSource.h"
#import "GetUserTimeDataSource.h"
#import "GetAccountBalanceDataSource.h"


@implementation REIDinfo
{
    UIImageView *idInfoPic;
    HTTPManager *httpUserAccountBalance;
    UILabel *myTime ;
    UILabel *idInfoSig;
    UILabel *idInfoName;
    UILabel *idInfoNumber;
    
    UIImageView *lineAbove;
    UIImageView *lineBelow;
    UIImageView * line;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    
     return self;
}


-(void)initItem
{

    if (!idInfoPic) {
         idInfoPic = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
    }
   
    idInfoPic.backgroundColor = [UIColor whiteColor];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",[UConfig getPhotoURL]]];

 
    if ([fileManager fileExistsAtPath:filePaths])
    {
        idInfoPic.image = [UIImage imageWithContentsOfFile:filePaths];
    }
    else {
        idInfoPic.image = [UIImage imageNamed:@"contact_default_photo"];
    }
    
    idInfoPic.layer.cornerRadius = idInfoPic.frame.size.width/2;
    idInfoPic.layer.masksToBounds = YES;
    
    [idInfoPic.layer setMasksToBounds:YES];
    [idInfoPic.layer setBorderWidth:2.0];
    idInfoPic.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8].CGColor;
    
    idInfoPic.backgroundColor = [UIColor clearColor];
    [self addSubview:idInfoPic];
    
    
    UIFont *pFontName = [UIFont boldSystemFontOfSize:17];
    CGFloat h = pFontName.capHeight;

    if (!idInfoName) {
        idInfoName = [[UILabel alloc]initWithFrame:CGRectMake(idInfoPic.frame.size.width + KWidthCompare6*12, KHeightCompare6*12, 200, 20)];
    }
    
    idInfoName.text = [UConfig getNickname];
    if (idInfoName.text.length == 0) {
        idInfoName.text = @"未设置昵称";
    }
    [idInfoName setTextColor:[UIColor whiteColor]];
    idInfoName.font = pFontName;
    idInfoName.backgroundColor = [UIColor clearColor];
    [self addSubview:idInfoName];
    


    UIFont *pFontNumber = [UIFont systemFontOfSize:13];
    h = pFontNumber.capHeight;

    if (!idInfoNumber) {
        idInfoNumber = [[UILabel alloc]initWithFrame:CGRectMake(idInfoPic.frame.size.width + KWidthCompare6*12, KHeightCompare6*12+idInfoName.frame.size.height +kKHeightCompare6*11, 200, h+2)];
    }
    [idInfoNumber setText:[UConfig getUNumber]];
    [idInfoNumber setTextColor:[UIColor whiteColor]];
    idInfoNumber.font = pFontNumber;
    idInfoNumber.backgroundColor = [UIColor clearColor];
    [self addSubview:idInfoNumber];
    

    UIFont *pFontSig = [UIFont systemFontOfSize:13];
    h = pFontSig.capHeight;
    if (!idInfoSig) {
        idInfoSig = [[UILabel alloc]initWithFrame:CGRectMake(0, 70+KHeightCompare6*23 , KDeviceWidth*0.82-42, KHeightCompare6*45)];
    }
    
    [idInfoSig setText:[UConfig getMood]];
    if (idInfoSig.text.length == 0) {
        idInfoSig.text = @"编辑个性签名";
    }
    [idInfoSig setTextColor:[UIColor whiteColor]];
    idInfoSig.font = pFontSig;
    CGFloat R  = (CGFloat) 255/255.0;
    CGFloat G = (CGFloat) 255/255.0;
    CGFloat B = (CGFloat) 255/255.0;
    UIColor *myColorRGB = [ UIColor colorWithRed: R  green: G  blue: B  alpha: 0.4  ];
    [idInfoSig setTextColor:myColorRGB];
    
    if (lineAbove == nil) {
        lineAbove  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, idInfoSig.frame.size.width+42, 1)];
        lineAbove.backgroundColor = [UIColor colorWithRed:R green:G blue:B alpha:0.08];
        [idInfoSig addSubview:lineAbove];
    }

    if (lineBelow == nil) {
        lineBelow  = [[UIImageView alloc]initWithFrame:CGRectMake(0, idInfoSig.frame.size.height-1, lineAbove.frame.size.width, 1)];
        lineBelow.backgroundColor = [UIColor colorWithRed:R green:G blue:B alpha:0.08];
        [idInfoSig addSubview:lineBelow];
    }


    idInfoSig.backgroundColor = [UIColor clearColor];

    
    [self addSubview:idInfoSig];
    
    /////////时长
    
    if (!myTime) {
        myTime= [[UILabel alloc]initWithFrame:CGRectMake(idInfoSig.frame.origin.x, idInfoSig.frame.origin.y + idInfoSig.frame.size.height, idInfoSig.frame.size.width, idInfoSig.frame.size.height)];
    }
    myTime.backgroundColor = [UIColor clearColor];
    
    if (line == nil) {
        line = [[UIImageView alloc]initWithFrame:CGRectMake(0, myTime.frame.size.height -1, lineAbove.frame.size.width, 1)];
        line.backgroundColor =  [UIColor colorWithRed:R green:G blue:B alpha:0.08];
        [myTime addSubview:line];
    }

    
    CGFloat Balance = 0;//获取余额
    UIFont *pFontTime = [UIFont systemFontOfSize:17];
    NSString * aString = [NSString stringWithFormat:@"应币余额：%0.1f",Balance];
    myTime.text = aString;
    myTime.textColor = [UIColor whiteColor];
    myTime.font = pFontTime;
    
    [self addSubview:myTime];
    
    
    ////////
    
    UITapGestureRecognizer * tapGestureSig = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sig)];
    [idInfoSig addGestureRecognizer:tapGestureSig];
    idInfoSig.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * tapGestureTime = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mytime)];
    [myTime addGestureRecognizer:tapGestureTime];
    myTime.userInteractionEnabled = YES;
    
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(peopleInfo)];
    [self addGestureRecognizer:tapGesture];
    
    httpUserAccountBalance = [[HTTPManager alloc]init];
    httpUserAccountBalance.delegate = self;
    [httpUserAccountBalance GetAccountBalance];
    
}


-(void)peopleInfo
{
    NSLog(@"!!!!触发编辑个人资料");
    if (self.delegate && [self.delegate respondsToSelector:@selector(editInfo)]) {
        [self.delegate editInfo];
    }
}

-(void)sig
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editMood)]) {
        [self.delegate editMood];
    }
}

-(void)mytime{
    NSLog(@"点击时长");
    if (self.delegate && [self.delegate respondsToSelector:@selector(myTime)]) {
        [self.delegate myTime];
    }
}

-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource*)theDataSource type:(RequestType)eType bResult:(BOOL)bResult{
    if(eType == RequestGetAccountBalance)
    {
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            GetAccountBalanceDataSource* userAccountBalance = (GetAccountBalanceDataSource *)theDataSource;
            NSString * aString = [NSString stringWithFormat:@"应币余额：%@",userAccountBalance.balance];
            myTime.text = aString;
                       
        }
    }
}

-(void)UpdataAccountBalance{
    if (httpUserAccountBalance) {
        [httpUserAccountBalance GetAccountBalance];
    }
}

@end
