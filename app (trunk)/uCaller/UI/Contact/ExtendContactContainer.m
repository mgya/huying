//

//  ExtendContactContainer.m

//  CloudCC

//

//  Created by thehuah on 13-5-21.

//  Copyright (c) 2013年 MobileDev. All rights reserved.

//



#import "ExtendContactContainer.h"

#import "ContactCell.h"

#import "ContactManager.h"

#import "UConfig.h"

#import "UIUtil.h"

#import "UAppDelegate.h"

#import "TabBarViewController.h"

#import "UCore.h"



#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"

#define ALPHABET @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"



#define Label_HuyingNumber 260

@implementation ExtendContactContainer

{
    
    NSMutableArray *starContacts;
    
    BOOL hasStarFriends;
    
    UIImageView *newCountView;
    
    UITableViewCell *newContactCell;
    
    UCore *uCore;
    
}



-(id)init

{
    
    if (self = [super init])
        
    {
        
        UIImage *newImage = [UIImage imageNamed:@"contact_new_count.png"];
        
        newCountView = [[UIImageView alloc] initWithImage:newImage];
        
        newCountView.frame = CGRectMake(130, 11, newImage.size.width, newImage.size.height);
        
        if(!iOS7 && !isRetina)
            
        {
            newCountView.frame = CGRectMake(130, 11, newImage.size.width/2, newImage.size.height/2);
            
        }
    }
    return  self;
}



-(id)initWithData:(NSMutableArray *)aContacts

{
    self = [super initWithData:aContacts];
    
    if(self)
        
    {
        
        UIImage *newImage = [UIImage imageNamed:@"contact_new_count.png"];
        
        newCountView = [[UIImageView alloc] initWithImage:newImage];
        
        newCountView.frame = CGRectMake(130, 21, newImage.size.width, newImage.size.height);
        
        if(!iOS7 && !isRetina)
            
        {
            
            newCountView.frame = CGRectMake(130, 21, newImage.size.width/2, newImage.size.height/2);
            
        }
        
    }
    
    return self;
    
}





- (void)reloadData

{
    
    hasStarFriends = NO;
    
    starContacts = [[ContactManager sharedInstance] getStarContacts];
    
    if(starContacts.count > 0)
        
    {
        
        hasStarFriends = YES;
        
    }
    
    if(contactsMap && [contactsMap count])
        
    {
        
        NSArray *allValues = [contactsMap allValues];
        
        for(NSMutableArray *array in allValues)
            
        {
            
            if(array && [array count])
                
                [array removeAllObjects];
            
        }
        
        [contactsMap removeAllObjects];
        
    }
    contacts = [[ContactManager sharedInstance] allContacts];
    
    if([contacts count] > 0)
        
    {
        
        for (int i = 0; i < 27; i++)
            
        {
            
            [contactsMap setObject:[NSMutableArray array] forKey:[ALPHA substringAtIndex:i]];
            
        }
        
        for(UContact* contact in contacts)
            
        {
            
            if (contact.type != CONTACT_LOCAL && contact.type != CONTACT_uCaller) {
                
                continue;
                
            }
            
            NSString *firstLetter;
            
            NSString *namePinyin = contact.namePinyin;
            
            if([Util isEmpty:namePinyin])
                
            {
                
                firstLetter = @"#";
                
            }
            
            else
                
            {
                
                firstLetter = [namePinyin substringAtIndex:0];
                
            }
            
            if([ALPHA contain:firstLetter] == NO)
                
                firstLetter = @"#";
            
            if (contact.isStar!=YES) {
                
                [[contactsMap objectForKey:firstLetter] addObject:contact];
                
            }
            
        }
        
    }
    
    [contactTableView reloadData];
    
}



-(void)refreshNewContact:(BOOL)isHasNewContact

{
    
    
    if(isHasNewContact)
        
    {
        
        newCountView.hidden = NO;
        
    }
    
    else
        
    {
        
        newCountView.hidden = YES;
        
    }
    
}

#pragma mark - Table View

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView

{
    uCore = [UCore sharedInstance];
    
    NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
    
    for (int i = 0; i < 27; i++)
        
    {
        NSString *key = [ALPHA substringAtIndex:i];
        
        [indices addObject:key];
        
    }
    
    return indices;
    
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index

{
    
    return  [ALPHA rangeOfString:title].location;
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    
    NSInteger count = 28;
    
    if (self.isHideNewFriends == NO) {
        
        if(hasStarFriends)
            
        {
            
            count++;
            
        }
        
    }else{
        
        count++;
        
    }
    
    return count;
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    
    NSInteger nSection = section;
    
    if(self.isHideNewFriends == NO)
        
    {
        
        nSection = section-1;
        
        if(section == 0)
            
        {
            
            if ([UConfig hasUserInfo]) {
                
                
                if ([uCore.recommended isEqualToString:@"1"]) {
                    return 3;
                }
                return 2;//新的朋友，呼应好友
                
                
                
            }
            
            else {
                
                if ([UConfig getTrainTickets]) {
                    
                    if ([uCore.recommended isEqualToString:@"1"]) {
                        return 4;
                    }
                    return 3;//新的朋友,免费订票
                    
                }
                
                else {
                    if ([uCore.recommended isEqualToString:@"1"]) {
                        return 3;
                    }
                    return 2;//新的朋友
                    
                }
                
            }
            
        }
        
        
        
        if(hasStarFriends)
            
        {
            
            nSection = section-2;
            
            if(section == 1)
                
            {
                
                return starContacts.count;
                
            }
            
        }
        
    }
    
    else {
        
        nSection = section-1;
        
    }
    
    NSString *key = [ALPHA substringAtIndex:nSection];
    
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    
    return subArray.count;
    
    
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section

{
    
    if(self.isHideNewFriends == NO)
        
    {
        
        if(section == 0)
            
            return 0.0;
        
        else
            
        {
            
            NSInteger nSection = section-1;
            
            if(hasStarFriends)
                
            {
                
                nSection = section-2;
                
                if(section == 1)
                    
                {
                    
                    return 24;
                    
                }
                
            }
            
            NSString *key = [ALPHA substringAtIndex:nSection];
            
            NSMutableArray *subArray = [contactsMap objectForKey:key];
            
            if(subArray.count != 0)
                
            {
                
                return 24;
                
            }
            
        }
        
        return 0;
        
    }
    
    else
        
    {
        
        NSString *key = [ALPHA substringAtIndex:section-1];
        
        NSMutableArray *subArray = [contactsMap objectForKey:key];
        
        if(subArray.count != 0)
            
        {
            
            return 24;
            
        }
        
        return 0;
        
    }
    
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section

{
    
    UIView *bgView = [[UIView alloc] init];
    
    
    
    bgView.frame = CGRectMake(-1, -1, tableView.frame.size.width+2, 25);
    
    
    
    bgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    
    bgView.layer.borderColor = [UIColor colorWithRed:240/255.0 green:243/255.0 blue:246/255.0 alpha:1.0].CGColor;
    
    if (iOS7) {
        
        bgView.layer.borderWidth = 0.5;
        
    }else{
        
        bgView.layer.borderWidth = 1.0;
        
    }
    
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12+34.0/3, 0, bgView.frame.size.width-20, bgView.frame.size.height)];
    
    titleLabel.backgroundColor = [UIColor clearColor];
    
    titleLabel.textColor = [UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    
    titleLabel.textAlignment = NSTextAlignmentLeft;
    
    titleLabel.font = [UIFont systemFontOfSize:13];
    
    
    
    if(self.isHideNewFriends == NO)
        
    {
        
        if(section == 0)
            
        {
            
            bgView.frame = CGRectMake(bgView.frame.origin.x, bgView.frame.origin.y, bgView.frame.size.width, 0);
            
        }
        
        if(section >= 1)
            
        {
            
            if(hasStarFriends)
                
            {
                
                if(section == 1)
                    
                {
                    
                    UIImage *starImage = [UIImage imageNamed:@"contact_starfriends_icon"];
                    
                    UIImageView *starImageView = [[UIImageView alloc] initWithImage:starImage];
                    
                    starImageView.frame = CGRectMake(20,5,13, 13);
                    
                    [bgView addSubview:starImageView];
                    
                    titleLabel.frame = CGRectMake(starImageView.frame.origin.x+starImageView.frame.size.width+6,titleLabel.frame.origin.y , titleLabel.frame.size.width, titleLabel.frame.size.height);
                    
                    titleLabel.text = @"收藏联系人";
                    
                }
                
                else
                    
                {
                    
                    NSString *key = [ALPHA substringAtIndex:section-2];
                    
                    NSUInteger nCount = [[contactsMap objectForKey:key] count];
                    
                    if (nCount != 0)
                        
                    {
                        
                        titleLabel.text = key;
                        
                    }
                    
                }
                
            }
            
            else
                
            {
                
                NSString *key = [ALPHA substringAtIndex:section-1];
                
                NSUInteger nCount = [[contactsMap objectForKey:key] count];
                
                if (nCount != 0)
                    
                {
                    
                    titleLabel.text = key;
                    
                }
                
            }
            
        }
        
    }
    
    else
        
    {
        
        hasStarFriends = NO;
        
        
        
        NSString *key = [ALPHA substringAtIndex:section-1];
        
        NSUInteger nCount = [[contactsMap objectForKey:key] count];
        
        if (nCount != 0)
            
        {
            
            titleLabel.text = key;
            
        }
        
    }
    
    [bgView addSubview:titleLabel];
    
    return bgView;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if(self.isHideNewFriends == NO)
        
    {
        
        if(indexPath.section == 0 )
            
        {
            
            if ([UConfig hasUserInfo] ) {
                
                if ([UConfig getTrainTickets]) {
                    if ([uCore.recommended isEqualToString:@"1"]) {
                        if(indexPath.row == 0){
                            
                            UITableViewCell *cell = [self drawOneKeyBookCell:tableView];
                            
                            return cell;
                            
                        }else if(indexPath.row == 1){
                            
                            UITableViewCell *cell = [self drawCommondCell:tableView];
                            
                            return cell;
                            
                        }
                        
                        else if(indexPath.row == 2){
                            
                            UITableViewCell *cell = [self drawNewContactCell:tableView];
                            
                            return cell;
                            
                        }else if(indexPath.row == 3){
                            
                            UITableViewCell *cell = [self drawUContactCell:tableView];
                            
                            return cell;
                            
                        }
                     }else{
                        if(indexPath.row == 0){
                            
                            UITableViewCell *cell = [self drawOneKeyBookCell:tableView];
                            
                            return cell;
                            
                        }else if(indexPath.row == 1){
                            
                            UITableViewCell *cell = [self drawNewContactCell:tableView];
                            
                            return cell;
                            
                        }else if(indexPath.row == 2){
                            
                            UITableViewCell *cell = [self drawUContactCell:tableView];
                            
                            return cell;
                            
                        }
                    }
                }
                
                else {
                    if ([uCore.recommended isEqualToString:@"1"]) {
                        if(indexPath.row == 0){
                            
                            UITableViewCell *cell = [self drawCommondCell:tableView];
                            
                            return cell;
                            
                        }
                        else if(indexPath.row == 1){
                            
                            UITableViewCell *cell = [self drawNewContactCell:tableView];
                            
                            return cell;
                            
                        }else if(indexPath.row == 2){
                            
                            UITableViewCell *cell = [self drawUContactCell:tableView];
                            
                            return cell;
                            
                        }

                       }else{
                         if(indexPath.row == 0){
                            
                            UITableViewCell *cell = [self drawNewContactCell:tableView];
                            
                            return cell;
                            
                         }else if(indexPath.row == 1){
                            
                            UITableViewCell *cell = [self drawUContactCell:tableView];
                            
                            return cell;
                            
                        }

                    }
                    
                    
                }
            }
            
            else {
                
                if([UConfig getTrainTickets])
                    
                {
                    if ([uCore.recommended isEqualToString:@"1"]) {
                        
                        if (indexPath.row == 0) {
                            
                            UITableViewCell *cell = [self drawOneKeyBookCell:tableView];
                            
                            return cell;
                            
                        }
                        else if (indexPath.row ==1){
                            
                            UITableViewCell *cell = [self drawCommondCell:tableView];
                            
                            return cell;
                            
                        }
                        else if (indexPath.row ==2){
                            
                            UITableViewCell *cell = [self drawNewContactCell:tableView];
                            
                            return cell;
                            
                        }else if(indexPath.row == 3){
                            
                            UITableViewCell *cell = [self drawUContactCell:tableView];
                            
                            return cell;
                            
                        }

                    }else{
                        
                        if (indexPath.row == 0) {
                            
                            UITableViewCell *cell = [self drawOneKeyBookCell:tableView];
                            
                            return cell;
                            
                        }else if (indexPath.row ==1){
                            
                            UITableViewCell *cell = [self drawNewContactCell:tableView];
                            
                            return cell;
                            
                        }else if(indexPath.row == 2){
                            
                            UITableViewCell *cell = [self drawUContactCell:tableView];
                            
                            return cell;
                            
                        }

                    }
                    
                }
                
                else {
                    if ([uCore.recommended isEqualToString:@"1"])
                    {
                        if (indexPath.row == 0) {
                            
                            UITableViewCell *cell = [self drawCommondCell:tableView];
                            
                            return cell;
                            
                        }
                        else if (indexPath.row == 1) {
                            
                            UITableViewCell *cell = [self drawNewContactCell:tableView];
                            
                            return cell;
                            
                        }else if(indexPath.row == 2){
                            
                            UITableViewCell *cell = [self drawUContactCell:tableView];
                            
                            return cell;
                            
                        }
                        
                    }else{
                        if (indexPath.row == 0) {
                            
                            UITableViewCell *cell = [self drawNewContactCell:tableView];
                            
                            return cell;
                            
                        }else if(indexPath.row == 1){
                            
                            UITableViewCell *cell = [self drawUContactCell:tableView];
                            
                            return cell;
                            
                        }
                    }
                    
                }
                
            }
            
        }
        
        
        
        NSUInteger nSection = indexPath.section-1;
        
        NSUInteger nIndex = indexPath.row;
        
        
        
        static NSString *CellIdentifier = @"ExtendContactCell";
        
        ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
            
        {
            
            cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        
        cell.curCellType = ALL;
        
        cell.strKeyWord = self.strKeyWord;
        
        
        
        
        
        UContact *contact  = nil;
        
        BOOL isStar = NO;
        
        if(hasStarFriends)
            
        {
            
            nSection = indexPath.section-2;
            
            
            
            if(indexPath.section == 1)
                
            {
                
                isStar = YES;
                
                contact = [starContacts objectAtIndex:nIndex];
                
                if(indexPath.row < starContacts.count-1)
                    
                {
                    
                    cell.isShowLine = YES;
                    
                }
                
                else
                    
                {
                    
                    cell.isShowLine = NO;
                    
                }
                
            }
            
        }
        
        if(isStar == NO)
            
        {
            NSString *key = [ALPHA substringAtIndex:nSection];
            
            NSMutableArray *subArray = [contactsMap objectForKey:key];
            
            contact = [subArray objectAtIndex:nIndex];
            
            if(indexPath.row < subArray.count-1)
                
            {
                
                cell.isShowLine = YES;
                
            }
            
            else
                
            {
                
                cell.isShowLine = NO;
                
            }
            
        }
        
        [cell setContact:contact];
        
        
        
        cell.selectedBackgroundView = [UIUtil CellSelectedView];
        
        return cell;
        
    }
    
    else
        
    {
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            
            UITableViewCell *cell = [self drawMyHuyingNumber:tableView];
            
            return cell;
            
        }
        
        
        
        NSUInteger nSection = indexPath.section-1;
        
        NSUInteger nIndex = indexPath.row;
        
        
        
        static NSString *CellIdentifier = @"ExtendContactCell";
        
        ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
            
        {
            
            cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        
        cell.curCellType = ALL;
        
        cell.strKeyWord = self.strKeyWord;
        
        
        
        UContact *contact  = nil;
        
        NSString *key = [ALPHA substringAtIndex:nSection];
        
        NSMutableArray *subArray = [contactsMap objectForKey:key];
        
        contact = [subArray objectAtIndex:nIndex];
        
        if(indexPath.row < subArray.count-1)
            
        {
            
            cell.isShowLine = YES;
            
        }
        
        else
            
        {
            
            cell.isShowLine = NO;
            
        }
        
        [cell setContact:contact];
        
        
        
        cell.selectedBackgroundView = [UIUtil CellSelectedView];
        
        
        
        return cell;
        
    }
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    NSInteger nSection = indexPath.section-1;
    
    NSInteger row = indexPath.row;
    
    BOOL isStar = NO;
    
    UContact *contact = nil;
    
    if(indexPath.section == 0 && self.isHideNewFriends == NO)
        
    {
        
        if ([UConfig hasUserInfo]) {
            
            if ([UConfig getTrainTickets]) {
                if ([uCore.recommended isEqualToString:@"1"]) {
                    
                    if (indexPath.row == 0){
                        
                        //一键买票
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellclickedTicket:)])
                            
                        {
                            
                            [contactDelegate contactCellclickedTicket:nil];
                            
                        }
                        
                    }
                    else if(indexPath.row ==1){
                        
                        //推荐有奖
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(toCommondVebView)])
                            
                        {
                            
                            [contactDelegate toCommondVebView];
                            
                        }
                        
                    }
                    else if(indexPath.row ==2){
                        
                        //新的朋友
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClicked:)])
                            
                        {
                            
                            [contactDelegate contactCellClicked:contact];
                            
                        }
                        
                    }
                    
                    else if(indexPath.row ==3){
                        
                        //通讯录
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClickedAdd)])
                            
                        {
                            
                            [contactDelegate contactCellClickedAdd];
                            
                        }
                        
                    }

                }else{
                    
                    if (indexPath.row == 0){
                        
                        //一键买票
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellclickedTicket:)])
                            
                        {
                            
                            [contactDelegate contactCellclickedTicket:nil];
                            
                        }
                        
                    }
                    
                    else if(indexPath.row ==1){
                        
                        //新的朋友
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClicked:)])
                            
                        {
                            
                            [contactDelegate contactCellClicked:contact];
                            
                        }
                        
                    }
                    
                    else if(indexPath.row ==2){
                        
                        //通讯录
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClickedAdd)])
                            
                        {
                            
                            [contactDelegate contactCellClickedAdd];
                            
                        }
                        
                    }

                }
                
            }
            
            else {
                if ([uCore.recommended isEqualToString:@"1"]) {
                    if(indexPath.row ==0){
                        
                        //推荐有奖
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(toCommondVebView)])
                            
                        {
                            
                            [contactDelegate toCommondVebView];
                            
                        }
                        
                    }

                    else if(indexPath.row ==1){
                        
                        //新的朋友
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClicked:)])
                            
                        {
                            
                            [contactDelegate contactCellClicked:contact];
                            
                        }
                        
                    }
                    
                    else if(indexPath.row ==2){
                        
                        //通讯录
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClickedAdd)])
                            
                        {
                            
                            [contactDelegate contactCellClickedAdd];
                            
                        }
                        
                    }
                    

                }else{
                    if(indexPath.row ==0){
                        
                        //新的朋友
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClicked:)])
                            
                        {
                            
                            [contactDelegate contactCellClicked:contact];
                            
                        }
                        
                    }
                    
                    else if(indexPath.row ==1){
                        
                        //通讯录
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClickedAdd)])
                            
                        {
                            
                            [contactDelegate contactCellClickedAdd];
                            
                        }
                        
                    }
                    
                    
                }
                
                
            }
            
        }
        
        else{
            
            if ([UConfig getTrainTickets]) {
                if ([uCore.recommended isEqualToString:@"1"]) {
                    if (indexPath.row == 0) {
                        
                        //一键买票
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(toCommondVebView)])
                            
                        {
                            
                            [contactDelegate toCommondVebView];
                            
                        }
                        
                    }

                    else if (indexPath.row == 1) {
                        
                        //一键买票
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellclickedTicket:)])
                            
                        {
                            
                            [contactDelegate contactCellclickedTicket:nil];
                            
                        }
                        
                        
                        
                    }
                    
                    else if (indexPath.row == 1){
                        
                        //新的朋友
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClicked:)])
                            
                        {
                            
                            [contactDelegate contactCellClicked:contact];
                            
                        }
                        
                    }
                    
                    else if(indexPath.row ==2){
                        
                        //通讯录
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClickedAdd)])
                            
                        {
                            
                            [contactDelegate contactCellClickedAdd];
                            
                        }
                        
                    }

                }
                else{
                    if (indexPath.row == 0) {
                        
                        //一键买票
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellclickedTicket:)])
                            
                        {
                            
                            [contactDelegate contactCellclickedTicket:nil];
                            
                        }
                        
                        
                        
                    }
                    
                    else if (indexPath.row == 1){
                        
                        //新的朋友
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClicked:)])
                            
                        {
                            
                            [contactDelegate contactCellClicked:contact];
                            
                        }
                        
                    }
                    
                    else if(indexPath.row ==2){
                        
                        //通讯录
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClickedAdd)])
                            
                        {
                            
                            [contactDelegate contactCellClickedAdd];
                            
                        }
                        
                    }

                }
                
            }
            
            else {
                if ([uCore.recommended isEqualToString:@"1"]) {
                    
                    if (indexPath.row==0) {
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(toCommondVebView)])
                            
                        {
                            
                            [contactDelegate toCommondVebView];
                            
                        }
                        
                    }
                    
                    //新的朋友
                    
                   else if (indexPath.row==1) {
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClicked:)])
                            
                        {
                            
                            [contactDelegate contactCellClicked:contact];
                            
                        }
                        
                    }
                    
                    else if (indexPath.row==1)
                        
                    {
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClickedAdd)])
                            
                        {
                            
                            [contactDelegate contactCellClickedAdd];
                            
                        }
                        
                    }

                }
                else{
                    //新的朋友
                    
                    if (indexPath.row==0) {
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClicked:)])
                            
                        {
                            
                            [contactDelegate contactCellClicked:contact];
                            
                        }
                        
                    }
                    
                    else if (indexPath.row==1)
                        
                    {
                        
                        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClickedAdd)])
                            
                        {
                            
                            [contactDelegate contactCellClickedAdd];
                            
                        }
                        
                    }

                    
                }

            }
            
        }
        
    }
    
    else
        
    {
        
        if(hasStarFriends)
            
        {
            
            nSection = indexPath.section-2;
            
            if(indexPath.section == 1)
                
            {
                
                isStar = YES;
                
                contact = [starContacts objectAtIndex:indexPath.row];
                
            }
            
        }
        
        if(isStar == NO)
            
        {
            
            NSUInteger nIndex = indexPath.row;
            
            NSString *key = [ALPHA substringAtIndex:nSection];
            
            NSMutableArray *subArray = [contactsMap objectForKey:key];
            
            contact = [subArray objectAtIndex:nIndex];
            
        }
        
        
        
        if (contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClicked:)])
            
        {
            
            [contactDelegate contactCellClicked:contact];
            
        }
        
        
        
    }
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}





#pragma mark ----DrawCell-----

-(UITableViewCell *)drawMyHuyingNumber:(UITableView *)tableView

{
    
    static NSString *cellName = @"myHuyingNumber";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        
        UILabel *MyHuyingLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 9, Label_HuyingNumber, 38)];
        
        MyHuyingLabel.backgroundColor = [UIColor clearColor];
        
        NSString *myHuyingNumber =[UConfig getUNumber];
        
        
        
        MyHuyingLabel.text =[NSString stringWithFormat:@"我的呼应号:%@",myHuyingNumber];
        
        MyHuyingLabel.textColor = TITLE_COLOR;
        
        MyHuyingLabel.font = [UIFont systemFontOfSize:16];
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        
        if (![UConfig getTrainTickets])
            
        {
            
            UILabel* dividingLine = [[UILabel alloc] init];
            
            dividingLine.backgroundColor = [[UIColor alloc] initWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1.0];
            
            if (iOS7) {
                
                dividingLine.frame = CGRectMake(MyHuyingLabel.frame.origin.x, 54.5, KDeviceWidth-10, 0.5);
                
            }else{
                
                dividingLine.frame = CGRectMake(MyHuyingLabel.frame.origin.x, 54.5, KDeviceWidth-10, 1.5);
                
            }
            
            
            
            [cell addSubview:dividingLine];
            
        }
        
        
        
        [cell addSubview:MyHuyingLabel];
        
    }
    
    
    
    return cell;
    
}



-(UITableViewCell *)drawOneKeyBookCell:(UITableView *)tableView

{
    
    static NSString *cellName = @"oneKeyBook";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        
        
        
        UIImageView *photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 9, 34, 34)];
        
        photoImgView.image = [UIImage imageNamed:@"contact_ticket_train"];
        
        [cell.contentView addSubview:photoImgView];
        
        
        
        UILabel *bookLabel = [[UILabel alloc] initWithFrame:CGRectMake(photoImgView.frame.origin.x+photoImgView.frame.size.width+5, photoImgView.frame.origin.y, 100, 38)];
        
        bookLabel.backgroundColor = [UIColor clearColor];
        
        bookLabel.text = @"免费订火车票";
        
        bookLabel.textColor = [UIColor redColor];
        
        bookLabel.font = [UIFont systemFontOfSize:16];
        
        
        
        [cell.contentView addSubview:bookLabel];
        
        
        
        UIImage *hotImage = [UIImage imageNamed:@"contact_ticket_hot"];
        
        
        
        UIImageView *hotImgView = [[UIImageView alloc] initWithFrame:CGRectMake(bookLabel.frame.origin.x+bookLabel.frame.size.width+5, bookLabel.frame.size.height/2, hotImage.size.width, hotImage.size.height)];
        
        hotImgView.image = hotImage;
        
        [cell.contentView addSubview:hotImgView];
        
        
        
        UILabel* dividingLineHeader = [[UILabel alloc] init];
        
        UILabel* dividingLineFooter = [[UILabel alloc] init];
        
        
        
        dividingLineHeader.backgroundColor = [[UIColor alloc] initWithRed:255/255.0 green:88/255.0 blue:81/255.0 alpha:1.0];
        
        dividingLineFooter.backgroundColor = dividingLineHeader.backgroundColor;
        
        
        
        if (iOS7) {
            
            dividingLineHeader.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 0.5);
            
            dividingLineFooter.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y+53.5, cell.frame.size.width, 0.5);
            
        }else
            
        {
            
            dividingLineHeader.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 1.5);
            
            dividingLineFooter.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y+53.5, cell.frame.size.width, 1.5);
            
        }
        
        
        
        [cell.contentView addSubview:dividingLineHeader];
        
        [cell.contentView addSubview:dividingLineFooter];
        
        
        
        cell.selectedBackgroundView = [UIUtil CellSelectedView];
        
    }
    
    return cell;
    
}

-(UITableViewCell *)drawCommondCell:(UITableView *)tableView

{
    
    static NSString *cellName = @"CommondCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        
        
        
        UIImageView *photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12,10, 34, 34)];
        
        photoImgView.image = [UIImage imageNamed:@"commendContacts"];
        
        [cell.contentView addSubview:photoImgView];
        
        cell.imageView.image = [UIImage imageNamed:@""];
        
        
        
        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(photoImgView.frame.origin.x+photoImgView.frame.size.width+14, photoImgView.frame.origin.y,KDeviceWidth-100, 38)];
        
        newLabel.backgroundColor = [UIColor clearColor];
        
        newLabel.text = @"推荐呼应给好友获取免费时长";
        
        newLabel.textAlignment = NSTextAlignmentLeft;
        
        newLabel.font = [UIFont systemFontOfSize:16];
        
        [cell.contentView addSubview:newLabel];
        
        
        
        
        
        newContactCell = cell;
        
        [newContactCell.contentView addSubview:newCountView];
        
        
        
        cell.selectedBackgroundView = [UIUtil CellSelectedView];
        
        
        
        UILabel* dividingLine = [[UILabel alloc] init];
        
        dividingLine.backgroundColor = [[UIColor alloc] initWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
        
        if (iOS7) {
            
            dividingLine.frame = CGRectMake(12, 54.5, KDeviceWidth-10, 0.5);
            
        }else{
            
            dividingLine.frame = CGRectMake(12, 54.5, KDeviceWidth-10, 1.5);
            
        }
        
        
        
        [cell addSubview:dividingLine];
        
    }
    
    
    
    
    
    return cell;
    
}

-(UITableViewCell *)drawNewContactCell:(UITableView *)tableView

{
    
    static NSString *cellName = @"NewContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        
        
        
        UIImageView *photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12,10, 34, 34)];
        
        photoImgView.image = [UIImage imageNamed:@"new_contact"];
        
        [cell.contentView addSubview:photoImgView];
        
        cell.imageView.image = [UIImage imageNamed:@""];
        
        
        
        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(photoImgView.frame.origin.x+photoImgView.frame.size.width+14, photoImgView.frame.origin.y, 100, 38)];
        
        newLabel.backgroundColor = [UIColor clearColor];
        
        newLabel.text = @"新的朋友";
        
        newLabel.textAlignment = NSTextAlignmentLeft;
        
        newLabel.font = [UIFont systemFontOfSize:16];
        
        [cell.contentView addSubview:newLabel];
        
        
        
        
        
        newContactCell = cell;
        
        [newContactCell.contentView addSubview:newCountView];
        
        
        
        cell.selectedBackgroundView = [UIUtil CellSelectedView];
        
        
        
        UILabel* dividingLine = [[UILabel alloc] init];
        
        dividingLine.backgroundColor = [[UIColor alloc] initWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
        
        if (iOS7) {
            
            dividingLine.frame = CGRectMake(12, 54.5, KDeviceWidth-10, 0.5);
            
        }else{
            
            dividingLine.frame = CGRectMake(12, 54.5, KDeviceWidth-10, 1.5);
            
        }
        
        
        
        [cell addSubview:dividingLine];
        
    }
    
    
    
    
    
    return cell;
    
}



-(UITableViewCell *)drawUContactCell:(UITableView *)tableView

{
    
    static NSString *cellName = @"LocalContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        
        
        
        UIImageView *photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12,10, 34, 34)];
        
        photoImgView.image = [UIImage imageNamed:@"addXMPP"];
        
        [cell.contentView addSubview:photoImgView];
        
        cell.imageView.image = [UIImage imageNamed:@""];
        
        
        
        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(photoImgView.frame.origin.x+photoImgView.frame.size.width+14, photoImgView.frame.origin.y, 150, 38)];
        
        newLabel.backgroundColor = [UIColor clearColor];
        
        newLabel.text = @"呼应好友";
        
        newLabel.font = [UIFont systemFontOfSize:16];
        
        newLabel.textAlignment = NSTextAlignmentLeft;
        
        [cell.contentView addSubview:newLabel];
        
        cell.selectedBackgroundView = [UIUtil CellSelectedView];
        
    }
    
    
    
    return cell;
    
}



@end

