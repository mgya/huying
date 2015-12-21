//
//  DataPickerView.m
//  uCaller
//
//  Created by HuYing on 15/5/28.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "DataPickerView.h"
#import "UConfig.h"
#import "UDefine.h"
#import "Util.h"

#define PICKERVIEWHEIGHT 220.0

@implementation DataPickerView
{
    CGRect curFrame;
    UIView *shadeView;
    
    UIPickerView *aPickerView;
}
@synthesize dataMarr;
@synthesize title;
@synthesize curContent;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        curFrame = frame;
        self.frame=CGRectMake(curFrame.origin.x, curFrame.origin.y, curFrame.size.width, curFrame.size.height);
        self.backgroundColor = [UIColor clearColor];
        

        
        shadeView = [[UIView alloc]init];
        shadeView.frame = CGRectMake(0, 0, curFrame.size.width, curFrame.size.height-220.0);
        shadeView.alpha = 0.7;
        shadeView.backgroundColor = [UIColor blackColor];
        [self addSubview:shadeView];
        
        
        dataMarr = [[NSMutableArray alloc]init];
        
        
        CGRect pickRect = CGRectMake(0, shadeView.frame.origin.y+shadeView.frame.size.height, KDeviceWidth, PICKERVIEWHEIGHT);
        
        UIView *aView = [[UIView alloc]init];
        aView.frame = pickRect;
        aView.backgroundColor = [UIColor whiteColor];
        [self addSubview:aView];
        
        aPickerView = [[UIPickerView alloc]init];
        aPickerView.backgroundColor = [UIColor whiteColor];
        if (iOS7) {
            aPickerView.frame = CGRectMake(0, 0, aView.frame.size.width, aView.frame.size.height);
        }else
        {
            
            aPickerView.frame  = CGRectMake(60, 0,aView.frame.size.width-120,aView.frame.size.height);
            aPickerView.center = CGPointMake(aView.frame.size.width/2, aView.frame.size.height/2);
            aPickerView.showsSelectionIndicator = YES;
        }
        aPickerView.delegate = self;
        aPickerView.dataSource = self;
        
        [aView addSubview:aPickerView];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, 0, 60, 40);
        [cancelButton setTitleColor:[UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:1.0] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        cancelButton.backgroundColor = [UIColor clearColor];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [aView addSubview:cancelButton];
        
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButton setTitleColor:[UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:1.0] forState:UIControlStateNormal];
        confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
        confirmButton.frame = CGRectMake(aView.frame.size.width-60, 0, 60, 40);
        confirmButton.backgroundColor = [UIColor clearColor];
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [aView addSubview:confirmButton];
        
    }
    return self;
}

-(void)dataShowInView:(UIView *)view
{
    NSInteger curRow = [self showCurCount];
    [aPickerView selectRow:curRow inComponent:0 animated:NO];
    
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    //改变它的frame的x,y的值
    self.frame=curFrame;
    [UIView commitAnimations];
    
    [view addSubview:self];
}
-(void)dataHideView:(BOOL)isSetting Title:(NSString *)aTitle
{
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    shadeView.hidden = YES;
    //改变它的frame的x,y的值
    self.frame=CGRectMake(0, curFrame.origin.y+curFrame.size.height, curFrame.size.width, 0);
    [UIView commitAnimations];
    NSString *str;
    if(isSetting == YES)
    {
        str = curContent;
    }
    
    NSMutableDictionary *mdic = [[NSMutableDictionary alloc]init];
    if (str != nil) {
        [mdic setObject:str forKey:@"strValue"];
    }
    
    [mdic setObject:aTitle forKey:@"typeName"];
    if([self.delegate respondsToSelector:@selector(dataHide:)])
    {
        [self.delegate performSelector:@selector(dataHide:) withObject:mdic];
    }
}

-(void)cancelBtnClicked
{
    [self dataHideView:NO Title:title];
}

-(void)confirmBtnClicked
{
    if ([Util isEmpty:curContent] ) {
        curContent = [dataMarr objectAtIndex:0];
    }
    [self dataHideView:YES Title:title];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate respondsToSelector:@selector(dataTouchEnd:)])
    {
        [self.delegate performSelector:@selector(dataTouchEnd:) withObject:self];
    }
}

#pragma mark -----UIPickerViewDelegate/DataSource------

//以下3个方法实现PickerView的数据初始化
//确定picker的轮子个数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
//确定picker的每个轮子的item数
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return dataMarr.count;
}
//确定每个轮子的每一项显示什么内容
#pragma mark 实现协议UIPickerViewDelegate方法
-(NSString *)pickerView:(UIPickerView *)pickerView
            titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [dataMarr objectAtIndex:row];
}

//监听轮子的移动
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    curContent = [dataMarr objectAtIndex:row];
}

//查找当前选中内容所在的轮子row
- (NSInteger)showCurCount
{
    for (NSInteger i=0; i<dataMarr.count; i++) {
        NSString *str = dataMarr[i];
        if ([str isEqualToString:curContent]) {
            return i;
        }
    }
    return 0;
}


@end
