//
//  TableMenuCell.m
//  TableViewCellMenu
//
//  Created by shan xu on 14-4-2.
//  Copyright (c) 2014年 夏至. All rights reserved.
//

#import "TableMenuCell.h"
#import "UDefine.h"
#import "UAppDelegate.h"
#import "TabBarViewController.h"

#define ISIOS7 ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7)
#define KMenu_Width 60

@interface TableMenuCell ()

@end


@implementation TableMenuCell
{
    UIPanGestureRecognizer *myPanGes;
}
@synthesize cellView;
@synthesize startX;
@synthesize cellX;
@synthesize menuActionDelegate;
@synthesize indexpathNum;
@synthesize menuCount;
@synthesize menuView;




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        menuCount = 0;
        
//        self.cellView = [[UIView alloc] init];
//        self.cellView.backgroundColor = [UIColor clearColor];
//        [self.contentView addSubview:self.cellView];
        
        myPanGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cellPanGes:)];
        myPanGes.delegate = self;
        myPanGes.cancelsTouchesInView = NO;
        [self addGestureRecognizer:myPanGes];
    }
    return self;
}
-(void)configWithData:(NSIndexPath *)indexPath menuData:(NSArray *)menuData cellFrame:(CGRect)cellFrame{
    indexpathNum = indexPath;
    //初始化菜单个数
    menuCount = [menuData count];
    
    //初始化菜单view,frame是整条cell的frame
    if (self.cellView) {
        [self.cellView removeFromSuperview];
        self.cellView = nil;
    }
    if (self.menuView) {
        [self.menuView removeFromSuperview];
        self.menuView = nil;
    }
    
    self.cellView = [[UIView alloc] init];
    self.cellView.frame = cellFrame;
    self.cellView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.cellView];
    
    //初始化菜单区域
    menuView = [[UIView alloc] init];
    menuView.backgroundColor = [UIColor clearColor];
    [self.contentView insertSubview:menuView belowSubview:self.cellView];
    menuView.hidden = YES;
    menuView.frame = CGRectMake(KDeviceWidth, 0, 0, 0);

    for (int i = 0; i < menuCount; i++) {
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(KDeviceWidth, 0, 0, 0);;
        menuBtn.tag = i;
        [menuBtn addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [menuBtn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[[menuData objectAtIndex:i] objectForKey:@"stateNormal"]]] forState:UIControlStateNormal];
        [menuBtn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[[menuData objectAtIndex:i] objectForKey:@"stateHighLight"]]] forState:UIControlStateHighlighted];
        [menuView addSubview:menuBtn];
    }
}
-(void)menuBtnClick:(id)sender{
    UIButton *btn = sender;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self initCellFrame:0];
    } completion:^(BOOL finished) {
        menuView.hidden = YES;
        [self.menuActionDelegate tableMenuDidHideInCell:self];
    }];
    
    [self.menuActionDelegate menuChooseIndex:indexpathNum.row menuIndexNum:btn.tag];
    _didActionOfMenu(indexpathNum.row, btn.tag);
}

-(void)cellPanGes:(UIPanGestureRecognizer *)panGes{
    if (self.selected) {
        NSLog(@"tableview的选择设置为NO");
        [self setSelected:NO animated:NO];
    }

    CGPoint translatedPoint = [panGes translationInView:self];
    if(translatedPoint.x > 0 && menuView.isHidden){
        //直接向右滑动
        if (panGes.state == UIGestureRecognizerStateBegan) {
            self.bNormalToRight = YES;
        }
        return ;
    }

    CGPoint pointer = [panGes locationInView:self.contentView];
    if (panGes.state == UIGestureRecognizerStateBegan) {
        menuView.hidden = NO;
        startX = pointer.x;
        cellX = self.cellView.frame.origin.x;
        [self setSelected:NO];
//        NSLog(@"滑动手势 UIGestureRecognizerStateBegan startX = %f, cellX = %f",startX,cellX);
    }
    else if (panGes.state == UIGestureRecognizerStateChanged){
//        NSLog(@"滑动手势 UIGestureRecognizerStateChanged, cellX = %f, pointer.x = %f, startx = %f",cellX, pointer.x, startX);
        menuView.hidden = NO;
    }
    else if (panGes.state == UIGestureRecognizerStateEnded){
//        NSLog(@"滑动手势 UIGestureRecognizerStateEnded startX = %f, pointer.x = %f, cellreset = %f",startX, pointer.x,pointer.x-startX);
        [self cellReset:pointer.x - startX];
        return;
    }
    else if (panGes.state == UIGestureRecognizerStateCancelled){
        NSLog(@"滑动手势 UIGestureRecognizerStateCancelled");
        [self cellReset:pointer.x - startX];
        return;
    }
    [self cellViewMoveToX:cellX + pointer.x - startX];
}

-(void)cellReset:(float)moveX{
    //从正常cell使用右向左滑，和使用左负数向右滑还原正常cell。
    if (moveX <= 0) {
        //从右至左滑，moveX小于0
        if(moveX < -20){
            //从右至左滑，大于20像素
            [UIView animateWithDuration:0.2 animations:^{
                [self initCellFrame:-menuCount*KMenu_Width];
            } completion:^(BOOL finished) {
                menuView.hidden = NO;
                [self.menuActionDelegate tableMenuDidShowInCell:self];
            }];
        }else if (moveX >= -20){
            //从右至左滑，小于20像素
            [UIView animateWithDuration:0.2 animations:^{
                [self initCellFrame:0];
            } completion:^(BOOL finished) {
                menuView.hidden = YES;
                [self.menuActionDelegate tableMenuDidHideInCell:self];
            }];
        }
    }
    else {
        if(moveX > 20){
            //从左负数至右滑，大于20像素
            [UIView animateWithDuration:0.2 animations:^{
                [self initCellFrame:0];
            } completion:^(BOOL finished) {
                menuView.hidden = YES;
                [self.menuActionDelegate tableMenuDidHideInCell:self];
            }];
        }else if (moveX <= 20){
            [UIView animateWithDuration:0.2 animations:^{
                [self initCellFrame:-menuCount*KMenu_Width];
            } completion:^(BOOL finished) {
                menuView.hidden = NO;
                [self.menuActionDelegate tableMenuDidShowInCell:self];
            }];
        }
    }
}


-(void)cellViewMoveToX:(float)x{
    [UIView animateWithDuration:0.2 animations:^{
        if (x>0) {
            [self initCellFrame:0];
        }
        else{
            [self initCellFrame:x];
        }
    } completion:^(BOOL finished) {
    }];
}
- (void)initCellFrame:(float)x{
    CGRect frame = self.cellView.frame;
    frame.origin.x = x;
    self.cellView.frame = frame;

    float menuViewWidth = fabsf(x);
    if (x < 0) {
        if ((fabsf(x)-KMenu_Width*menuCount) > 0) {
            menuViewWidth = KMenu_Width*menuCount;
        }
        menuView.frame = CGRectMake(KDeviceWidth - menuViewWidth, 0, KMenu_Width*menuCount, self.cellView.frame.size.height);
    }
    else {
        menuView.frame = CGRectMake(KDeviceWidth, 0, KMenu_Width*menuCount, self.cellView.frame.size.height);
    }

    
    for (int i = 0; i < menuCount; i++) {
        UIView *subView = menuView.subviews[i];
        if (x<0) {
            subView.frame = CGRectMake(menuViewWidth/menuCount*i, 0, KMenu_Width, self.cellView.frame.size.height);
        }
        else {
            subView.frame = CGRectMake(0, 0, KMenu_Width, self.cellView.frame.size.height);
        }
    }
}
#pragma mark * UIPanGestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    NSString *str = [NSString stringWithUTF8String:object_getClassName(gestureRecognizer)];
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
        return fabs(translation.x) > fabs(translation.y);
    }
    return YES;
}

- (void)setMenuHidden:(BOOL)hidden animated:(BOOL)animated completionHandler:(void (^)(void))completionHandler{
    if (self.selected) {
        [self setSelected:NO animated:NO];
    }
    if (hidden) {
        CGRect frame = self.cellView.frame;
        if (frame.origin.x != 0) {
            [UIView animateWithDuration:0.2 animations:^{
                [self initCellFrame:0];
            } completion:^(BOOL finished) {
                self.menuViewHidden = YES;
                [self.menuActionDelegate tableMenuDidHideInCell:self];
                if (completionHandler) {
                    completionHandler();
                }
            }];
        }
    }
}
- (void)setMenuViewHidden:(BOOL)aHidden{
    if(aHidden) {
        menuView.hidden = YES;
    }
    else{
        menuView.hidden = NO;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)setDidActionOfMenu:(void (^)(NSInteger, NSInteger))didActionOfMenu
{
    _didActionOfMenu = didActionOfMenu;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    if ([self.menuActionDelegate tableMenuCellIsEditing:self]) {
//        NSLog(@"cell手势中，不兼容其他手势");
        return NO;
    }else{
//        NSLog(@"非cell手势中，兼容其他手势");
        return YES;
    }
}

- (void)addPanGes
{
    if(myPanGes != nil && [self gestureRecognizers].count == 0){
        [self addGestureRecognizer:myPanGes];
    }
}

- (void)removePanGes
{
    if (myPanGes != nil && [self gestureRecognizers].count > 0) {
        [self removeGestureRecognizer:myPanGes];
    }

    [self initCellFrame:0];
    menuView.hidden = YES;
    [self.menuActionDelegate tableMenuDidHideInCell:self];
}
@end
