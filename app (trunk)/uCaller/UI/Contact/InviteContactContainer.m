//
//  InviteContactContainer.m
//  uCalling
//
//  Created by thehuah on 13-3-14.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "InviteContactContainer.h"
#import "HttpManager.h"
#import "ContactCell.h"
#import "UConfig.h"
#import "UAppDelegate.h"
#import "iToast.h"
#import "UIUtil.h"
#import "XAlert.h"

#define IMAGETAG 9010
#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"
#define ALPHABET @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"

@interface InviteContactContainer ()

@end

@implementation InviteContactContainer
{
    NSMutableDictionary *contactsMap;
}

@synthesize isInsearch;
@synthesize contactTableView = contactTableView;
@synthesize invitecontactDelegate;
@synthesize strKeyWord;

-(id)init
{
    if (self = [super init])
    {
        contacts = [[NSMutableArray alloc] init];
        contactSelectArray = [[NSMutableArray alloc] init];
        contactNoSelectArray = [[NSMutableArray alloc] init];
        contactsSelectMap = [[NSMutableDictionary alloc] init];
        contactsMap = [[NSMutableDictionary alloc] init];
        flagDictionary = [[NSMutableDictionary alloc]init];
    }
    return  self;
}

-(id)initWithData:(NSMutableArray *)aContacts
{
    self = [super init];
    if(self)
    {
        contacts = aContacts;
        contactSelectArray = [[NSMutableArray alloc] init];
        contactNoSelectArray = [[NSMutableArray alloc] init];
        contactsSelectMap = [[NSMutableDictionary alloc] initWithCapacity:28];
        
    }
    return self;
    
}

-(void)reloadData
{
    [contactTableView reloadData];
}

-(void)reloadWithData:(NSArray *)aContacts
{
    contacts = aContacts;
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
    
    if([contacts count] > 0)
    {
        for (int i = 0; i < 27; i++)
        {
            [contactsMap setObject:[NSMutableArray array] forKey:[ALPHA substringAtIndex:i]];
        }
        
        for(UContact* contact in contacts)
        {
            if (contact.type != CONTACT_LOCAL) {
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
            
            [[contactsMap objectForKey:firstLetter] addObject:contact];
        }
    }

    if(contactsSelectMap.count > 0)
    {
        [contactsSelectMap removeAllObjects];
    }
    if(contactSelectArray.count > 0)
    {
        [contactSelectArray removeAllObjects];
    }
    [self reloadData];
}

-(void)sendBtn
{
    if([contactSelectArray count] == 0)
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:nil message:@"请选择联系人" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    else if([contactSelectArray count] > 10)
    {
        [[[iToast makeText:@"每次仅限选取10位联系人\n请下一波再继续：)"] setGravity:iToastGravityCenter] show];
        return;
    }
    else
    {
        if([self.invitecontactDelegate respondsToSelector:@selector(showSendMsgView:)])
        {
            [self.invitecontactDelegate performSelector:@selector(showSendMsgView:) withObject:contactSelectArray];
        }
        return;
    }
}

-(void)setSendMsgState:(sendMsgState)curState
{
}

-(void)endThread
{
    [contactSelectArray removeAllObjects];
    [contactsSelectMap removeAllObjects];
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

#pragma Touch ended 触摸tableview使键盘下去
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    if ([invitecontactDelegate respondsToSelector:@selector(touchesEnded)])
    {
        [invitecontactDelegate touchesEnded];
    }
    
}


#pragma mark - Table View
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(!isInsearch)
    {
        NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
        for (int i = 0; i < 27; i++)
        {
            NSString *key = [ALPHA substringAtIndex:i];
            [indices addObject:key];
        }
        return indices;
    }
    return NULL;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return  [ALPHA rangeOfString:title].location;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *key = [ALPHA substringAtIndex:section];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    if(subArray.count != 0)
    {
        return 24;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 24)];
    bgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    bgView.layer.borderColor = [UIColor colorWithRed:240/255.0 green:243/255.0 blue:246/255.0 alpha:1.0].CGColor;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12+34.0/3, 0, bgView.frame.size.width-20, bgView.frame.size.height)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:13];
    NSString *key = [ALPHA substringAtIndex:section];
    titleLabel.text = key;
    [bgView addSubview:titleLabel];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    if(subArray.count == 0)
    {
        bgView.frame = CGRectMake(bgView.frame.origin.x, bgView.frame.origin.y, bgView.frame.size.width, 0);
    }
    return bgView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 28;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [ALPHA substringAtIndex:section];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i< [subArray count]; i++)
    {
        UContact *contact = [subArray objectAtIndex:i];
        BOOL isSelected = NO;
        UContact *contactsel = [contactsSelectMap objectForKey:contact.pNumber];
        if(contactsel)
        {
            isSelected = YES;
        }
        [array addObject:[NSNumber numberWithBool:isSelected]];
    }
    [flagDictionary setObject:array forKey:[NSString stringWithFormat:@"%d",section]];
    array = nil;
    return subArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ContactCell";
	ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = IMAGETAG;
        [cell.contentView addSubview:imageView];
	}
    //added by yfCui
    cell.strKeyWord = self.strKeyWord;
    //end
    NSUInteger row = indexPath.row;
    UContact *contact = nil;
    NSString *key = [ALPHA substringAtIndex:indexPath.section];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    contact = [subArray objectAtIndex:row];
    [cell setInviteContact:contact];    
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:IMAGETAG];
    NSString *strImgName = nil;
    NSMutableArray *curArray = [flagDictionary objectForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
    if(curArray.count > indexPath.row)
    {
        BOOL isSelected = [[curArray objectAtIndex:indexPath.row] boolValue];
        if (isSelected == YES)
        {
            strImgName = @"msg_multiDelete_select.png";
        }
        else
        {
            strImgName = @"msg_multiDelete_unselect.png";
        }
    }
    UIImage *image = [UIImage imageNamed:strImgName];
    imgView.image = image;
    imgView.frame = CGRectMake(KDeviceWidth-image.size.width-25,15, image.size.width, image.size.height);
    cell.selectedBackgroundView = [UIUtil CellSelectedView];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [ALPHA substringAtIndex:indexPath.section];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
 
    UContact *contact = [subArray objectAtIndex:indexPath.row];
    
    
    NSMutableArray *curArray = [flagDictionary objectForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
    selectIndex = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0]];
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:IMAGETAG];
    NSString *strImgName = nil;
    if(curArray.count > selectIndex)
    {
        BOOL  isSelected;
        if ([[curArray objectAtIndex:selectIndex] boolValue])
        {
            isSelected= NO;
            [contactSelectArray removeObject:contact];
            [contactsSelectMap removeObjectForKey:contact.pNumber];
        }
        else
        {
            if(contactSelectArray.count >= 10)
            {
                isSelected = NO;
                [[[iToast makeText:@"每次仅限选取10位联系\n人请下一波再继续：)"] setGravity:iToastGravityCenter] show];
                return;
//                [XAlert alertWith:@"提示" message:@"每次仅限选取10位联系人\n请下一波再继续：)" buttonText:@"确定" isError:YES];
//                return;
            }
            else
            {
                isSelected = YES;
                [contactSelectArray addObject:contact];
                [contactsSelectMap setObject:contact forKey:contact.pNumber];

            strImgName = @"msg_multiDelete_unselect.png";
        }
    }
        if(contactSelectArray.count > 0)
        {
            if([self.delegate respondsToSelector:@selector(enableInviteButton)])
            {
                [self.delegate performSelector:@selector(enableInviteButton) withObject:nil];
            }
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(unEnableInviteButton)])
            {
                [self.delegate performSelector:@selector(unEnableInviteButton) withObject:nil];
            }
        }
        [curArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:isSelected]];
        imgView.image = [UIImage imageNamed:strImgName];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView reloadData];
    }
}

-(void)matchedContacts:(NSString *)curPNumber
{
    BOOL isContain = NO;
    NSInteger row = 0;
    for(UContact *aContact in contacts)
    {
        if([aContact matchNumber:curPNumber])
        {
            isContain = YES;
            break;
        }
        row++;
    }
    
    if(isContain == YES)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self tableView:contactTableView didSelectRowAtIndexPath:indexPath];

    }
}

-(void)clearInviteArray
{
    if(contactSelectArray && contactSelectArray.count > 0)
    {
        [contactSelectArray removeAllObjects];
        [contactsSelectMap removeAllObjects];
        [contactTableView reloadData];
    }
}
@end
