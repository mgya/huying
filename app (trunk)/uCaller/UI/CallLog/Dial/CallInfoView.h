//
//  CallInfoView.h
//  uCaller
//
//  Created by thehuah on 11-10-19.
//  Copyright 2011年 X. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDefine.h"

#import "UContact.h"

@interface CallInfoView : UIView

@property (nonatomic,strong) UContact *contact;
@property (nonatomic,strong) NSString *number;
@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSString *special;//通话回拨 开始时“请准备接听”大号字体


-(void)refreshNumber:(NSString *)newNumber;
-(void)showBgImgView:(BOOL)isShow ImageStr:(NSString *)imgStr;

@end
