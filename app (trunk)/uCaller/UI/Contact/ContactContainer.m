//
//  ContactContainer.m
//  uCalling
//
//  Created by thehuah on 13-3-14.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "ContactContainer.h"
#import "ContactCell.h"
#import "UIUtil.h"
#import "ContactManager.h"
#import "UConfig.h"



#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"
#define ALPHABET @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"

#define Label_HuyingNumber 260

@implementation ContactContainer

@synthesize isInSearch;
@synthesize contactTableView = contactTableView;
@synthesize contactDelegate;
@synthesize type;
@synthesize strKeyWord;
@synthesize isHideNewFriends;

-(id)initWithData:(NSMutableArray *)aContacts
{
    
    self = [super init];
    if(self)
    {
        contactsMap = [[NSMutableDictionary alloc] init];
        [self reloadData];
    }
    return self;
}

-(void)reloadData
{
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
    
    if (self.isInSearch) {
        contacts = [[ContactManager sharedInstance] searchContactsWithKey:strKeyWord andType:CONTACT_uCaller];
    }
    else{
        contacts = [ContactManager sharedInstance].uContacts;
    }
    
    if([contacts count] > 0)
    {
        for (int i = 0; i < 27; i++)
        {
            [contactsMap setObject:[NSMutableArray array] forKey:[ALPHA substringAtIndex:i]];
        }
        
        for(UContact* contact in contacts)
        {
            if (contact.type != CONTACT_uCaller) {
                continue;
            }
            
            NSString *firstLetter;
            
            if (![Util isEmpty:contact.localName]) {
                contact.namePinyin = nil;
            }
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

            [[contactsMap objectForKey:firstLetter] addObject:contact];
        }
    }
    [contactTableView reloadData];

}

-(NSInteger)cellCount
{
    NSInteger count = 0;
    NSArray *allValues = [contactsMap allValues];
    for (NSArray *array in allValues) {
        count += [array count];
    }
    return count;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (contactDelegate && [contactDelegate respondsToSelector:@selector(touchesEnded)]) {
        [contactDelegate touchesEnded];
    }
}

#pragma mark - Table View
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSInteger nSection;
    if(isInSearch){
        nSection = section;
    }
    else {
        nSection = section-1;
    }
    NSString *key = [ALPHA substringAtIndex:nSection];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    if(subArray.count != 0)
    {
        return 24;
    }
    
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(-1, -1, tableView.frame.size.width+2, 25)];
    bgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    bgView.layer.borderColor = [UIColor colorWithRed:240/255.0 green:243/255.0 blue:246/255.0 alpha:1.0].CGColor;
    bgView.layer.borderWidth = 0.5;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12+34.0/3, 0, bgView.frame.size.width-20, bgView.frame.size.height)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:13];
    
    
    NSInteger nSection;
    if(isInSearch){
        nSection = section;
    }
    else {
        nSection = section-1;
    }

    NSString *key = [ALPHA substringAtIndex:nSection];
    NSUInteger nCount = [[contactsMap objectForKey:key] count];
    if (nCount != 0)
    {
        titleLabel.text = key;
        
    }
    [bgView addSubview:titleLabel];
    return bgView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isInSearch) {
        return 27;
    }
    else {
        return 28;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isInSearch) {
        NSInteger nSection = section;
        NSString *key = [ALPHA substringAtIndex:nSection];
        NSMutableArray *subArray = [contactsMap objectForKey:key];
        return subArray.count;
    }
    else {
        NSInteger nSection = section-1;
        NSString *key = [ALPHA substringAtIndex:nSection];
        NSMutableArray *subArray = [contactsMap objectForKey:key];
        return subArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isInSearch) {
        static NSString *CellIdentifier = @"ContactCell";
        ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.delegate = contactDelegate;
        }
        
        NSUInteger nSection = indexPath.section;
        NSUInteger nIndex = indexPath.row;
        NSString *key = [ALPHA substringAtIndex:nSection];
        NSMutableArray *subArray = [contactsMap objectForKey:key];
        UContact *contact = [subArray objectAtIndex:nIndex];
        if(indexPath.row < subArray.count-1)
        {
            cell.isShowLine = YES;
        }
        else
        {
            cell.isShowLine = NO;
        }
        cell.curCellType = XMPPContacts;
        
        cell.strKeyWord = self.strKeyWord;
        cell.contact = contact;
        cell.selectedBackgroundView = [UIUtil CellSelectedView];
        return cell;
    }
    
    static NSString *CellIdentifier = @"ContactCell";
    ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = contactDelegate;
    }
    
    NSUInteger nSection = indexPath.section-1;
    NSUInteger nIndex = indexPath.row;
    NSString *key = [ALPHA substringAtIndex:nSection];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    UContact *contact = [subArray objectAtIndex:nIndex];
    if(indexPath.row < subArray.count-1)
    {
        cell.isShowLine = YES;
    }
    else
    {
        cell.isShowLine = NO;
    }
    cell.curCellType = XMPPContacts;

    cell.strKeyWord = self.strKeyWord;
    cell.contact = contact;
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger nIndex = nIndex = indexPath.row;
    NSInteger  nSection;
    if (isInSearch) {
        nSection = indexPath.section;
    }else {
        nSection = indexPath.section-1;
    }
    
    NSString *key = [ALPHA substringAtIndex:nSection];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    UContact *contact = [subArray objectAtIndex:nIndex];
    if (contact && contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellClicked:)])
    {
        [contactDelegate contactCellClicked:contact];
    }
    else if(contact && contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellCall:)]){
        [contactDelegate contactCellCall:contact];
    }else if (contact && contactDelegate && [contactDelegate respondsToSelector:@selector(contactCellMsg:)]){
        [contactDelegate contactCellMsg:contact];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//#pragma mark ----DrawMyHuyingCell----
//-(UITableViewCell *)drawMyHuyingNumberCell:(UITableView *)tableView
//{
//    static NSString *cellName = @"MyHuyingNumber";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
//    if(nil == cell)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
//        UILabel *MyHuyingLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 9, Label_HuyingNumber, 38)];
//        MyHuyingLabel.backgroundColor = [UIColor clearColor];
//        NSString *myHuyingNumber =[UConfig getUNumber];
//        
//        MyHuyingLabel.text =[NSString stringWithFormat:@"我的呼应号:%@",myHuyingNumber];
//        MyHuyingLabel.textColor = [[UIColor alloc]initWithRed:13/255.0 green:13/255.0 blue:13/255.0 alpha:1];
//        MyHuyingLabel.font = [UIFont systemFontOfSize:16];
//  
////去掉我的呼应号下面的下划线
////        UILabel* dividingLine = [[UILabel alloc] init];
////        if (iOS7) {
////            dividingLine.frame = CGRectMake(MyHuyingLabel.frame.origin.x, 54.5, KDeviceWidth-10, 0.5);
////        }else{
////            dividingLine.frame = CGRectMake(MyHuyingLabel.frame.origin.x, 54.5, KDeviceWidth-10, 1.5);
////        }
////        
////        dividingLine.backgroundColor = [[UIColor alloc] initWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1.0];
//        
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        
////        [cell addSubview:dividingLine];
//        [cell addSubview:MyHuyingLabel];
//    }
//    return cell;
//}
//
@end
