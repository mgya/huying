//
//  CallerManager.m
//  uCaller
//
//  Created by admin on 14-9-11.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "CallerManager.h"
#import "Util.h"
#import "UConfig.h"
#import "UCore.h"
#import "UAppDelegate.h"
#import "TabBarViewController.h"
#import "XAlertVIew.h"
#import "UDefine.h"
#import "CallerTypeViewController.h"
#import "UAppDelegate.h"

#define NETWORK_G234            1001
#define NETWORK_OFFLINE         1002

#define CALLBACK95013           10001
#define callerBackSelf          10002

typedef enum{
    notRegularTag,
    notAreaCodeTag
}alertTag;

@interface CallerManager()
{
    NSString* callerNumber;
    UIViewController* parentView;
    UContact* callerContact;
    RequestCallerType requestCallerType;
    NSString* callNumber;
    CallViewController *callView;
}
@end

@implementation CallerManager
@synthesize requestController;

static CallerManager *sharedInstance = nil;

+(CallerManager *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[CallerManager alloc] init];
        }
    }
	return sharedInstance;
}


-(void)Caller:(NSString*)caller
      Contact:(UContact *)contact
   ParentView:(UIViewController*) view
       Forced:(RequestCallerType)aType
{
    
    requestCallerType = RequestCallerType_Unknow;
    
    parentView = view;
    callerContact = contact;
    
    //特殊号码处理
    caller = [self SpecialCall:caller];
    
    if ([UConfig getAreaCode].length > 0) {
        //已增加过区号
        //判断号码是否规则
        if ([self numberIsRegular:caller]) {

            //规则
            if ((caller.length == 7 || caller.length == 8) && ![@"0" isEqualToString:[caller substringWithRange:NSMakeRange(0,1)]]) {
                //未加区号的把默认区号加入
                NSString *string = [[NSString alloc]init];
                caller = [string stringByAppendingFormat:@"%@%@",[UConfig getAreaCode],caller];
            }
            callerNumber = caller;
        }else{
            //不规则
           // if (caller.length <= 6 || caller.length > 14){
            if ( [caller rangeOfString:@"*"].location != NSNotFound || [caller rangeOfString:@"#"].location != NSNotFound) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"您拨打的号码有误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
                callNumber = caller;
                [alertView show];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"应用内无法呼叫此号码，你可以\n 使用系统电话呼叫" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"系统呼叫",nil];
                alertView.tag = notAreaCodeTag;
                callNumber = caller;
                [alertView show];
            }
                return;

           // }
                    }
    }else {
        //未增加区号
        if ([self numberIsRegular:caller]) {
            //号码规则时
            callerNumber = caller;
                }else{
            if (caller.length <= 6 || caller.length > 14){
                if ( [caller rangeOfString:@"*"].location != NSNotFound || [caller rangeOfString:@"#"].location != NSNotFound) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"您拨打的号码有误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
                    callNumber = caller;
                    [alertView show];
                }else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"应用内无法呼叫此号码，你可以\n 使用系统电话呼叫" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"系统呼叫",nil];
                    alertView.tag = notAreaCodeTag;
                    callNumber = caller;
                    [alertView show];
                }
                
            }else if(caller.length == 7 || caller.length == 8){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"大陆固话：区号+号码\n也可添加区号，今后拨打固话时\n自动为您添加区号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"添加区号",nil];
                alertView.tag = notAreaCodeTag;
                callNumber = caller;
                [alertView show];
                
            }else {
                if ( [caller rangeOfString:@"*"].location != NSNotFound || [caller rangeOfString:@"#"].location != NSNotFound) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"您拨打的号码有误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
                    callNumber = caller;
                    [alertView show];
                }else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"应用内无法呼叫此号码，你可以\n 使用系统电话呼叫" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"系统呼叫",nil];
                    alertView.tag = notAreaCodeTag;
                    callNumber = caller;
                    [alertView show];
                }
                
            }

            return ;
        }
    }
    
    if ([UConfig getVersionReview]) {
        [self versionReview];
        return;
    }
    
    if( callerNumber.length == 14 && 0 == [callerNumber compare:[UConfig getUNumber]] ) {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"抱歉，不能拨打自己的呼应号。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alertView.tag = callerBackSelf;
        [alertView show];
        return ;
    }
    
    //处理forced逻辑
    if(aType == RequestCallerType_Direct){
        [self DirectCaller];
        return ;
    }
    else if (aType == RequestCallerType_Callback){
        [self CallbackCaller];
        return ;
    }

    //回拨逻辑
    NSString *strOnlineStatus = [Util getOnLineStyle];
    if ( 0 == [strOnlineStatus compare:@"3G"]) {
        
        if ([UConfig Get3GCaller] == ECallerType_UnKnow ||
            [UConfig Get3GCaller] == ECallerType_3G_Callback) {
                //客户端在线
                if ( [UConfig Get3GCaller] == ECallerType_UnKnow) {
                    //尚未拨号设置，弹选项
                    //拨号方式处理－－－－－  回拨 or 直拨
                    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                                  initWithTitle:@"4/3/2G下以回拨方式呼出，通话质量好，且不耗流量。"
                                                  delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  destructiveButtonTitle:nil
                                                  otherButtonTitles:@"0流量拨打", @"不需要", nil];
                    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
                    actionSheet.tag = NETWORK_G234;
                    [actionSheet showInView:parentView.view];
                }
                else {
                    //已经拨号设置，不弹选项，回拨逻辑
                    [self CallbackCaller];
                }
        }//3g callback
        else if ([UConfig Get3GCaller] == ECallerType_3G_Direct){
            [self DirectCaller];
        }//3g direct
    }//3g
    else if ( 0 == [strOnlineStatus compare:@"Wifi"])
    {
        if ( [UConfig WifiCaller] == ECallerType_UnKnow ||
            [UConfig WifiCaller] == ECallerType_Wifi_Direct) {
            [self DirectCaller];
        }
        else if ([UConfig WifiCaller] == ECallerType_Wifi_Callback) {
            [self CallbackCaller];
        }
    }//wifi
}



-(NSString*)SpecialCall:(NSString*)caller{
    
    BOOL bCheck = YES;//需要判断
    
    if (caller.length<6) {
        return caller;
    }
    
    NSString * Check = @"12590";
    NSString * temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller substringWithRange:NSMakeRange(Check.length,caller.length - Check.length)];
        bCheck = NO;
    }
    Check = @"17909";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller substringWithRange:NSMakeRange(Check.length,caller.length - Check.length)];
        bCheck = NO;
    }
    Check = @"+0086";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller substringWithRange:NSMakeRange(Check.length,caller.length - Check.length)];
        bCheck = NO;
    }
    Check = @"0086";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller substringWithRange:NSMakeRange(Check.length,caller.length - Check.length)];
        bCheck = NO;
    }
    Check = @"+86";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller substringWithRange:NSMakeRange(Check.length,caller.length - Check.length)];
        bCheck = NO;
    }
    Check = @"-";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller substringWithRange:NSMakeRange(Check.length,caller.length - Check.length)];
        bCheck = NO;
    }
    ////////////////////////
    Check = @"+65";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
        bCheck = NO;
    }
    
    Check = @"+1204";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
        bCheck = NO;
    }
    
    Check = @"+44";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
        bCheck = NO;
    }
    
    Check = @"+1";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
        bCheck = NO;
    }
    
    Check = @"+34";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
        bCheck = NO;
    }
    
    Check = @"+61";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
        bCheck = NO;
    }
    
    Check = @"+886";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
        bCheck = NO;
    }
    
    Check = @"+82";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
        bCheck = NO;
    }
    
    Check = @"+41";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
        bCheck = NO;
    }
    
    Check = @"+852";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
        bCheck = NO;
    }
    
    Check = @"+81";
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        caller = [caller stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
        bCheck = NO;
    }
    
    ///////////
    
    
        
    Check = @"95013";
    NSRange range = [caller rangeOfString:Check];
    NSUInteger location = range.location;
    NSUInteger length = range.length;
    temp = [caller substringToIndex:1];
        
    if ([temp isEqualToString:@"0"]&&length>0) {
        caller = [caller substringWithRange:NSMakeRange(location,caller.length - location)];
    }
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        if (([caller rangeOfString:@"0131"].location == 2 && caller.length == 16)) {
            caller = [caller substringWithRange:NSMakeRange(Check.length,caller.length - Check.length)];
        }
        
        bCheck = NO;
    }

    
    
    Check = @"95010";
    
    range = [caller rangeOfString:Check];
    location = range.location;
    length = range.length;
    temp = [caller substringToIndex:1];
    
    if ([temp isEqualToString:@"0"]&&length>0) {
        caller = [caller substringWithRange:NSMakeRange(location,caller.length - location)];
    }
    temp = [ caller substringWithRange:NSMakeRange(0,Check.length)];
    if ([temp isEqualToString: Check] && bCheck){
        if (([caller rangeOfString:@"0101"].location == 2 && caller.length == 16)) {
            caller = [caller substringWithRange:NSMakeRange(Check.length,caller.length - Check.length)];
        }
        
        bCheck = NO;
    }
    
    
    return caller;
}

#pragma mark -----判断拨号是否规则------

-(BOOL)numberIsRegular:(NSString *)number
{
    
    if ( [number rangeOfString:@"*"].location != NSNotFound || [number rangeOfString:@"#"].location != NSNotFound ||[number rangeOfString:@","].location != NSNotFound || [number rangeOfString:@"+"].location != NSNotFound) {
        return NO;
    }else{
        if ( ([number rangeOfString:@"01"].location == 0 && number.length == 12)
            || ([number rangeOfString:@"1"].location == 0 && number.length == 11) ) {
            //判断为手机号(12位可能为含区号座机号)
            return YES;
        }else if( [number rangeOfString:@"95013"].location == 0 ){
            //判断为呼应号
            return YES;
        }else if ( [number rangeOfString:@"0"].location == 0 /*&&(number.length >= 10 && number.length <= 12) */)
        {
            //判断为加区号的座机号
            return YES;
        }else if(number.length == 7 || number.length == 8){
            //判断为不加区号的座机号
            if ([UConfig getAreaCode].length>0) {
                return YES;
        }else{
                return NO;
            }
                                                                  
        }

    }
    //号码不规则
    return NO;
}

#pragma mark ------ 拨号方式操作表的action处理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case NETWORK_G234:
        {
            if (buttonIndex == 0) {
                //回拨
                [self CallbackCaller];
            }else if (buttonIndex == 1) {
                //直拨
                [self DirectCaller];
            }
        }
            break;
        case NETWORK_OFFLINE:
        {
            if (buttonIndex == 0) {
                //回拨
                [self CallbackCaller];
            }else if (buttonIndex == 1) {
                //查看登录状态
                parentView = nil;
                [UAppDelegate uApp].rootViewController.tabBarViewController.selectedIndex = 0;
            }
        }
        default:
            break;
    }
}

#pragma mark ------ 直拨接口
-(void) DirectCaller
{
    //判断在线状态
    if ([[UCore sharedInstance] isOnline]) {
        //sip在线
        requestController = ERequestController_Unknow;
        requestCallerType = RequestCallerType_Direct;

        callView = [[CallViewController alloc] init];
        callView.view.alpha = 0.0;
        [UIView beginAnimations:nil context:nil];
        //设定动画持续时间
        [UIView setAnimationDuration:0.3];
        //动画的内容
        callView.view.alpha = 1.0;
        //动画结束
        [UIView commitAnimations];
        [callView callOut:callerContact number:callerNumber];
        callView.delegate = self;
        parentView = nil;
        
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:Event_CalleeFinish] forKey:KEventType];
        [notifyInfo setValue:nil forKey:KData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KEvent_CallerManager object:nil userInfo:notifyInfo];
    }
    else {
        //客户端离线状态 -- 有网离线
        //拨号方式处理－－－－－  回拨 or 登录状态查看
        if (requestController == ERequestController_More) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:@"当前好友登录状态为[离线]，将以回拨方式呼出，通话质量好，且不耗流量"
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:@"0流量拨打", nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            actionSheet.tag = NETWORK_OFFLINE;
            [actionSheet showInView:parentView.view];
            return;
        }
        else
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:@"当前好友登录状态为[离线]，将以回拨方式呼出，通话质量好，且不耗流量"
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:@"0流量拨打", @"查看登录状态", nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            actionSheet.tag = NETWORK_OFFLINE;
            [actionSheet showInView:parentView.view];
            return ;
        }

    }
}

#pragma mark ----- 回拨接口
-(void) CallbackCaller
{
    //回拨逻辑
    requestController = ERequestController_Unknow;
    requestCallerType = RequestCallerType_Callback;

    callView = [[CallViewController alloc] init];
    callView.view.alpha = 0.0;
    [UIView beginAnimations:nil context:nil];
    //设定动画持续时间
    [UIView setAnimationDuration:0.3];
    //动画的内容
    callView.view.alpha = 1.0;
    //动画结束
    [UIView commitAnimations];
    [callView callOut:callerContact number:callerNumber];
    callView.delegate = self;
    parentView = nil;
    
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:Event_CalleeFinish] forKey:KEventType];
    [notifyInfo setValue:nil forKey:KData];
    [[NSNotificationCenter defaultCenter] postNotificationName:KEvent_CallerManager object:nil userInfo:notifyInfo];
}

#pragma mark---UIAlertViewDelegate----
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CALLBACK95013) {
        if(buttonIndex == 1) {
            //回拨时，如果是呼应号改走直拨逻辑
            [self DirectCaller];
        }
    }
    else if( alertView.tag == callerBackSelf) {
        
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:Event_CalleeFinish] forKey:KEventType];
        [notifyInfo setValue:nil forKey:KData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KEvent_CallerManager object:nil userInfo:notifyInfo];
        return ;
    }
    else if(alertView.tag == notAreaCodeTag){
        if (buttonIndex == 0) {
            
            NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
            [notifyInfo setValue:[NSNumber numberWithInt:Event_CancelAction] forKey:KEventType];
            [notifyInfo setValue:nil forKey:KData];
            [[NSNotificationCenter defaultCenter] postNotificationName:KEvent_CallerManager object:nil userInfo:notifyInfo];

        }else if (buttonIndex == 1) {
            
            if (callNumber.length == 7 || callNumber.length == 8) {
                AreaCodeViewController* callerTypeViewController = [[AreaCodeViewController alloc] init];
                [[UAppDelegate uApp].rootViewController.navigationController pushViewController:callerTypeViewController animated:YES];
                NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                [notifyInfo setValue:[NSNumber numberWithInt:Event_AddAreaCode] forKey:KEventType];
                [notifyInfo setValue:nil forKey:KData];
                [[NSNotificationCenter defaultCenter] postNotificationName:KEvent_CallerManager object:nil userInfo:notifyInfo];
            }else{
                NSString * tel = [@"tel://" stringByAppendingString:callNumber];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
            }
 
        }
    }else if(alertView.tag == notRegularTag){

        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:Event_ClearNumber] forKey:KEventType];
        [notifyInfo setValue:nil forKey:KData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KEvent_CallerManager object:nil userInfo:notifyInfo];
    }
    parentView = nil;
}

-(RequestCallerType)RequestCallerType
{
    return requestCallerType;
}

-(void)versionReview
{
    //审核期间，改走直拨逻辑
    
    //判断在线状态
    if ([[UCore sharedInstance] isOnline]) {
        //sip在线
        requestController = ERequestController_Unknow;
        requestCallerType = RequestCallerType_Direct;
        
        callView = [[CallViewController alloc] init];
        callView.view.alpha = 0.0;
        [UIView beginAnimations:nil context:nil];
        //设定动画持续时间
        [UIView setAnimationDuration:0.3];
        //动画的内容
        callView.view.alpha = 1.0;
        //动画结束
        [UIView commitAnimations];
        [callView callOut:callerContact number:callerNumber];
        callView.delegate = self;
        parentView = nil;
        
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:Event_CalleeFinish] forKey:KEventType];
        [notifyInfo setValue:nil forKey:KData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KEvent_CallerManager object:nil userInfo:notifyInfo];
    }
    parentView = nil;
}

#pragma mark ----------------   CallViewControllerDelegate   ----------------
-(void)dissmissCallView
{
    if (callView != nil) {
        callView = nil;
    }
}

@end
