//
//  PersonalInfoViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-4-2.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BaseViewController.h"

#import "DateView.h"
#import "HTTPManager.h"
#import "ModifiedNickNameViewController.h"
#import "MoodViewController.h"
#import "CompanyViewController.h"
#import "HobbiesViewController.h"
#import "MarkViewController.h"
#import "DataPickerView.h"
#import "UContact.h"

@protocol ContactInfoDelegate <NSObject>

-(void)upDataContactInfo;

@end


@interface PersonalInfoViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,DateViewDelegate,HTTPManagerControllerDelegate,UIAlertViewDelegate,EditNciknameDelegate,EditMoodDelegate,UIActionSheetDelegate,EditCompanyDelegate,EditHobbiesDelegate,EditTagsDelegate,DataPickerViewDelegate>


@property (nonatomic,assign)id<ContactInfoDelegate> delegate;


@end
