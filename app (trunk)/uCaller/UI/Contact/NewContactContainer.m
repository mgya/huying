////
////  NewContactContainer.m
////  uCaller
////
////  Created by 崔远方 on 14-4-16.
////  Copyright (c) 2014年 yfCui. All rights reserved.
////
//
//#import "NewContactContainer.h"
//#import "UContact.h"
//#import "ContactManager.h"
//#import "UNewContact.h"
//#import "Util.h"
//#import "ContactInfoViewController.h"
//
//@implementation NewContactContainer
//{
//    NSMutableArray *newContacts;
//    BOOL isEdit;
//}
//
//@synthesize cellDelegate;
//@synthesize mTableView;
//@synthesize curType;
//
//-(id)init
//{
//    self = [super init];
//    if(nil != self)
//    {
//        self.mTableView.delegate = self;
//    }
//    return self;
//}
//-(void)reloadWithData:(NSMutableArray *)contacts;
//{
//    newContacts = contacts;
//    [mTableView reloadData];
//}
//
//#pragma mark---UITableViewDelegate/UITableViewDataSource
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 80;
//
//}
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return newContacts.count;
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *cellName = @"cell";
//    NewContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
//    if(nil == cell)
//    {
//        cell = [[NewContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
//        cell.delegate = cellDelegate;
//    }
//    [cell setNewContact:[newContacts objectAtIndex:indexPath.row]];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.backgroundColor = [UIColor clearColor];
//    
//    UIButton  *clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    clickButton.frame = CGRectMake(0 , 0, KDeviceWidth-90*KFORiOS, 80);
//    [clickButton setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
//    [clickButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
//    clickButton.tag = indexPath.row;
//    [cell.contentView addSubview:clickButton];
//    
//    return cell;
//    
//}
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        [newContacts removeObject:[newContacts objectAtIndex:indexPath.row]];
//    }
//    [self reloadWithData:newContacts];
//      //[self deleteRowsAtIndexPaths:indexPath.row  withRowAnimation:UITableViewRowAnimationFade];
//}
//- (void)clickButton:(UIButton*)sender{
//    ContactInfoViewController *infoVC = [[ContactInfoViewController alloc]initWithContact:[newContacts objectAtIndex:sender.tag]];
//    
//    
//    
//}
//    
//
//@end
