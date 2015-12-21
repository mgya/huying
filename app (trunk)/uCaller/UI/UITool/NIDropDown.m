//
//  NIDropDown.m
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"
#import "UDefine.h"

@interface NIDropDown ()

@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, retain) NSArray *list;
@property(nonatomic, retain) NSArray *imageList;
@end

@implementation NIDropDown
@synthesize table;
@synthesize btnSender;
@synthesize list;
@synthesize imageList;
@synthesize delegate;


- (void)showDropDownTitle:(NSArray *)arr andImage:(NSArray *)imgArr 
{
    if (arr == nil || arr.count == 0) {
        return ;
    }

    self.list = [NSArray arrayWithArray:arr];
    self.imageList = [NSArray arrayWithArray:imgArr];

    
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40*arr.count)];
    table.delegate = self;
    table.dataSource = self;
    table.scrollEnabled = NO;
    UIImage *bgRectangularImage = [UIImage imageNamed:@"rectangular.png"];
    bgRectangularImage = [bgRectangularImage stretchableImageWithLeftCapWidth:bgRectangularImage.size.width/2 topCapHeight:bgRectangularImage.size.height/2];
    UIImageView *bgTableView = [[UIImageView alloc] initWithImage:bgRectangularImage];
    
    table.backgroundView = bgTableView;
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table.separatorColor = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:table.bounds];
    table.layer.masksToBounds = NO;
    table.layer.shadowColor = [UIColor blackColor].CGColor;
    table.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    table.layer.shadowOpacity = 0.3f;
    table.layer.shadowPath = shadowPath.CGPath;
//    table.hidden = YES;
    [self addSubview:table];
}

-(void)hideDropDown{
//    [UIView beginAnimations:@"move" context:nil];
//    [UIView setAnimationDuration:0.2];
    self.frame =CGRectZero;
//    [UIView commitAnimations];
    table.frame = CGRectZero;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    if ([self.imageList count] == [self.list count]) {
        cell.textLabel.text =[list objectAtIndex:indexPath.row];
        cell.imageView.image = [imageList objectAtIndex:indexPath.row];
    }
    else if ([self.imageList count] > [self.list count]) {
        cell.textLabel.text =[list objectAtIndex:indexPath.row];
        if (indexPath.row < [imageList count]) {
            cell.imageView.image = [imageList objectAtIndex:indexPath.row];
        }
    }
    else if ([self.imageList count] < [self.list count]) {
        cell.textLabel.text =[list objectAtIndex:indexPath.row];
        if (indexPath.row < [imageList count]) {
            cell.imageView.image = [imageList objectAtIndex:indexPath.row];
        }
    }
    
    cell.textLabel.textColor = [UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideDropDown];
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }

    [self myDelegate:indexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void) myDelegate:(NSInteger)selectIndex
{
    [self.delegate niDropDownDelegateMethod:self andIndex:selectIndex];
}

@end
