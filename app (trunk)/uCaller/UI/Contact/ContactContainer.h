//
//  ContactContainer.h
//  uCalling
//
//  Created by thehuah on 13-3-14.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UDefine.h"
#import "Util.h"
#import "UAdditions.h"
#import "ContactCell.h"
#import "ContactCellDelegate.h"

@interface ContactContainer : NSObject <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *contacts;
    NSMutableDictionary *contactsMap;
    UITableView *contactTableView;
    int type;
    id<ContactCellDelegate> U__WEAK contactDelegate;
    BOOL isInSearch;
    NSString *strKeyWord;
}

@property(nonatomic,assign) BOOL isInSearch;
@property(nonatomic,assign) BOOL isHideNewFriends;
@property(nonatomic,assign) BOOL isHideMyHuNumber;
@property (nonatomic,strong) UITableView *contactTableView;
@property (nonatomic, UWEAK) id<ContactCellDelegate> contactDelegate;
@property (nonatomic,assign) int type;
@property (nonatomic,strong) NSString *strKeyWord;

-(id)initWithData:(NSArray *)contacts;
-(void)reloadData;
-(NSInteger)cellCount;

@end
