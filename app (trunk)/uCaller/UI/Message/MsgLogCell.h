//
//  MsgLogCell.h
//  uCalling
//
//  Created by thehuah on 13-4-25.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgLog.h"
#import "NewCountView.h"
#import "UCustomLabel.h"
#import "TableMenuCell.h"


@interface MsgLogCell : TableMenuCell

@property(nonatomic,strong) NSString *strKey;
@property(nonatomic,strong) MsgLog *msgLog;

@end
