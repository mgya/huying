//
//  RemarkViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-5-5.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UContact.h"

@interface RemarkViewController : BaseViewController<UITextFieldDelegate>

-(id)initWithContact:(UContact *)aContact;

@end
