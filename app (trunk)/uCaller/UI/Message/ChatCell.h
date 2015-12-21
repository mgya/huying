//
//  ChatCell.h
//  CloudCC
//
//  Created by thehuah on 13-5-11.
//  Copyright (c) 2013年 MobileDev. All rights reserved.
//

#import "MsgLog.h"
#import <CoreLocation/CoreLocation.h>

#define CHATCELL_PADDING_X 10
#define CHATCELL_PADDING_Y 20
#define CHATCELL_HEIGHT 60
#define CHATCELL_MIN_WIDTH 60

#define CHATCELL_FONT [UIFont systemFontOfSize:15]

#define TIMELABEL_FRAME CGRectMake(10, 25, KDeviceWidth-20, 20)
#define TEXTCONTENT_SIZE(TEXT) [TEXT sizeWithFont:CHATCELL_FONT constrainedToSize:CGSizeMake(200.0 ,10000.0) lineBreakMode:NSLineBreakByCharWrapping]



@protocol ChatCellDelegate;


@interface ChatCell : UITableViewCell
{
    UIView *mainView;
    UILabel *timeLabel;
    
    UIMenuController *menu;
    
    CGFloat yPos;
    
    id<ChatCellDelegate> U__WEAK delegate;
    NSIndexPath *indexPath;
    MsgLog *msgLog;
    BOOL showTime;
    
    //added by cui
//    BOOL isChanged;
}

@property (nonatomic,UWEAK) id<ChatCellDelegate> delegate;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) MsgLog *msgLog;
@property (nonatomic,assign) BOOL showTime;
@property (nonatomic,assign) int height;

@property (nonatomic,strong) UContact *contact;
@property (nonatomic,strong) UIImage *myPhoto;
@property (nonatomic,strong) UIImage *contactPhoto;

@property(nonatomic,assign) BOOL isDeleteState;
@property(nonatomic,strong) NSMutableArray *deleteArray;
@property(nonatomic,assign) BOOL isFirstMsg;
@property(nonatomic,strong) UIImage *msgImg;
@property (nonatomic,strong) UIImage *photoImg;

@property (nonatomic,strong) NSMutableArray *cardInfo;

-(void)setMenuItem;
-(void)onLongPressed:(UILongPressGestureRecognizer *)longPressRecognizer;

-(void)showPlayView:(BOOL)show;
-(void)updateStatus;
-(void)deleteButtonPressed;

@end

@protocol ChatCellDelegate <NSObject>

@optional

-(void)chatCellPressed:(ChatCell *)chatCell;

-(void)chatCellLongPressed:(ChatCell *)chatCell;
//转发
-(void)chatCellWillRelay:(ChatCell *)chatCell;
//重发
-(void)chatCellWillResend:(ChatCell *)chatCell;

-(void)chatCellWillDelete:(MsgLog *)aMsgLog;

-(void)chatPhotoButtonPressed;

-(void)deleteMenuClicked:(UIMenuController *)menuController;

-(void)addMsgLogToDelete:(MsgLog *)msgLog;

-(void)cancelMsgLogToDelete:(MsgLog *)msgLog;

- (void)selectAdsMsg;

- (void)forMaxImg:(MsgLog*)aMsglog andSmallImg:(UIImage *)smallImg;

- (void)forInfo:(NSString *)infoUrl andJumpType:(NSString *)jumpType andTitle:(NSString *)infoTitle;

- (void)toContactInfo:(NSMutableArray *)contactinfo;

-(void)closeInput;

- (void)locBarCellNow:(CLLocationCoordinate2D)coordinate address:(NSString*)address;

@end
