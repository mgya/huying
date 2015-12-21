//
//  ModifiedNickNameViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-4-29.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BaseViewController.h"


@protocol EditNciknameDelegate <NSObject>

@optional
-(void)onNicknameUpdated:(NSString *)nickname;

@end

@interface ModifiedNickNameViewController : BaseViewController<UITextFieldDelegate>

@property (nonatomic,UWEAK) id<EditNciknameDelegate> delegate;

@end
