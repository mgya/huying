//
//  DataPickerView.h
//  uCaller
//
//  Created by HuYing on 15/5/28.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DataPickerViewDelegate <NSObject>

-(void)dataTouchEnd:(id)sender;//遮罩
-(void)dataHide:(NSDictionary *)dic;//隐藏

@end

@interface DataPickerView : UIView<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic,assign) id<DataPickerViewDelegate>delegate;
@property (nonatomic,strong) NSMutableArray *dataMarr;//展示内容的数组
@property (nonatomic,strong) NSString *title;//展示内容的title，用来区分展示不同的内容
@property (nonatomic,strong) NSString *curContent;//当前选中的内容

-(void)dataShowInView:(UIView *)view;
-(void)dataHideView:(BOOL)isSetting Title:(NSString *)aTitle;

@end
