//
//  XAlert.m
//  uCalling
//
//  Created by thehuah on 11-11-10.
//  Copyright 2011 X. All rights reserved.
//

#import "XAlert.h" 
#import "XAlertView.h"
#import "UDefine.h"
#import "UConfig.h"

@interface XAlertDelegate : NSObject <UIAlertViewDelegate>  
{  
	CFRunLoopRef currentLoop;  
	NSUInteger index;
    BOOL isError;
}  
@property (readonly) NSUInteger index;
@property (nonatomic,assign) BOOL isError;
@end  

@implementation XAlertDelegate  
@synthesize index;  
@synthesize isError;


// Initialize with the supplied run loop  
-(id) initWithRunLoop: (CFRunLoopRef)runLoop   
{  
	if (self = [super init])
    {
        currentLoop = runLoop;
        isError = NO;
    }
	return self;  
}  

// User pressed button. Retrieve results  
-(void) alertView: (XAlertView*)aView clickedButtonAtIndex: (NSInteger)anIndex   
{  
	index = anIndex;  
	CFRunLoopStop(currentLoop);  
}

//#if 0
- (void)willPresentAlertView:(XAlertView *)alertView
{
    //alertView.frame = CGRectMake(alertView.frame.origin.x, alertView.frame.origin.y,alertView.frame.size.width , alertView.frame.size.height+130);
    XAlertView *alert = (XAlertView *)alertView;
    for(UIView *label in [alert subviews])
	{
        if([label isKindOfClass:[UIImageView class]])
        {
            if(alert.bgImage)
            {
                [(UIImageView *)label setImage:[alert.bgImage stretchableImageWithLeftCapWidth:alert.bgImage.size.width / 2.0 topCapHeight:alert.bgImage.size.height / 2.0]];
            }
            
        }
        
		//UILabel *label = [[alert subviews] objectAtIndex:1];
		if([label isKindOfClass:[UILabel class]] && label.frame.size.height > 40)
		{
			((UILabel *)label).textAlignment = alert.messageAlignment;
			break;
			
		}
		//NSLog(label.text);
	}

}
//#endif

@end 

   
 @implementation XAlert

+(void) alertWith: (NSString *)aTitle message:(NSString *)aMessage buttonText:(NSString *)aText isError:(BOOL)isError 
{  
    CFRunLoopRef currentLoop = CFRunLoopGetCurrent();  
    
	// Create Alert  
	XAlertDelegate *xDelegate = [[XAlertDelegate alloc] initWithRunLoop:currentLoop];
    
    NSString *imgName;
//    if(isError)
//    {
//        imgName = @"alert_black.png";
//    }
//    else
//    {
//        imgName = @"alert_green.png";
//    }

    XAlertView *alertView = [[XAlertView alloc] initWithTitle:(aTitle?NSLocalizedString(aTitle,nil):nil) message:(aMessage?NSLocalizedString(aMessage,nil):nil) delegate:xDelegate cancelButtonTitle:(aText?NSLocalizedString(aText,nil):nil) otherButtonTitles:nil,nil];
    //alertView.messageAlignment = UITextAlignmentLeft;
//	alertView.bgImage = [UIImage imageNamed:imgName];
	[alertView show]; 
    
    // Wait for response  
	CFRunLoopRun();
        
	// Retrieve answer  
	//NSUInteger answer = xDelegate.index;  
	//return answer; 
    
    //[alertView release];
	// Wait for response 
} 

+(NSUInteger) queryWith: (NSString *)aTitle message:(NSString *)aMessage button1: (NSString *)button1 button2: (NSString *)button2 isError:(BOOL)isError 
{  
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();  

	// Create Alert  
	XAlertDelegate *madelegate = [[XAlertDelegate alloc] initWithRunLoop:currentLoop];
    XAlertView *alertView = [[XAlertView alloc] initWithTitle:(aTitle?NSLocalizedString(aTitle,nil):nil) message:(aMessage?NSLocalizedString(aMessage,nil):nil) delegate:madelegate cancelButtonTitle:(button1?NSLocalizedString(button1,nil):nil) otherButtonTitles:(button2?NSLocalizedString(button2,nil):nil), nil];
	[alertView show];

	// Wait for response  
	CFRunLoopRun();

	// Retrieve answer  
	NSUInteger answer = madelegate.index;  
	return answer;  
}

+(NSUInteger) queryWith: (NSString *)aMessage button1: (NSString *)button1 button2: (NSString *)button2 wait:(NSInteger)time 
{  
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();  
    
	// Create Alert  
	XAlertDelegate *madelegate = [[XAlertDelegate alloc] initWithRunLoop:currentLoop];
    
    XAlertView *alertView = [[XAlertView alloc] initWithTitle:nil message:(aMessage?NSLocalizedString(aMessage,nil):nil) delegate:madelegate cancelButtonTitle:(button1?NSLocalizedString(button1,nil):nil) otherButtonTitles:(button2?NSLocalizedString(button2,nil):nil), nil];

	[alertView show];  
    
	// Wait for response  
    int ret = CFRunLoopRunInMode(kCFRunLoopDefaultMode,time,NO);
    
    if (ret == kCFRunLoopRunTimedOut)
    {
        return ret; 
    }
    
	// Retrieve answer  
	NSUInteger answer = madelegate.index;  
	return answer;  
}  

+ (NSUInteger)ask: (NSString *)question withCancel: (NSString *) cancelButtonTitle withButtons: (NSArray *) buttons isError:(BOOL)isError
{
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	
	// Create Alert
	XAlertDelegate *madelegate = [[XAlertDelegate alloc] initWithRunLoop:currentLoop];
    NSString *imgName;
//    if(isError)
//    {
//        imgName = @"alert_black.png";
//    }
//    else
//    {
//        imgName = @"alert_green.png";
//    }

    XAlertView *alertView = [[XAlertView alloc] initWithTitle:(question?NSLocalizedString(question,nil):nil) message:nil delegate:madelegate cancelButtonTitle:(cancelButtonTitle?NSLocalizedString(cancelButtonTitle,nil):nil) otherButtonTitles:nil];
    alertView.messageAlignment = UITextAlignmentCenter;
//	alertView.bgImage = [UIImage imageNamed:imgName];
	for (NSString *buttonTitle in buttons) 
        [alertView addButtonWithTitle:(buttonTitle?NSLocalizedString(buttonTitle,nil):nil)];
	[alertView show];
	
	// Wait for response
	CFRunLoopRun();    
	
	// Retrieve answer
	NSUInteger answer = madelegate.index;
	return answer;
}

+(void)showAlert:(NSString *)aTitle message:(NSString *)aMessage buttonText:(NSString *)aText
{
    XAlertView *alertView = [[XAlertView alloc] initWithTitle:(aTitle?NSLocalizedString(aTitle,nil):nil) message:(aMessage?NSLocalizedString(aMessage,nil):nil) delegate:nil cancelButtonTitle:(aText?NSLocalizedString(aText,nil):nil) otherButtonTitles:nil,nil];
	[alertView show];
}

+ (BOOL) ask: (NSString *) question  isError:(BOOL)isError
{  
    return  [XAlert queryWith:question message:nil button1: @"No" button2: @"Yes" isError:isError];  
}  

+ (BOOL) ask: (NSString *) question yes:(NSString*)strYes no:(NSString*)strNO isError:(BOOL)isError
{  
    return  [XAlert queryWith:question message:nil button1: strNO button2: strYes isError:isError];  
}

+ (BOOL) ask: (NSString *)question message:(NSString *)aMessage yes:(NSString*)strYes no:(NSString*)strNO isError:(BOOL)isError
{  
    return  [XAlert queryWith:question message:aMessage button1:strNO button2:strYes isError:isError];  
} 
   
+ (BOOL) confirm: (NSString *) statement isError:(BOOL)isError  
{  
	return  [XAlert queryWith:statement message:nil button1:@"Cancel" button2:@"OK" isError:isError];  
} 

+ (BOOL)alert:(NSString *)aTitle message:(NSString *)aMessage buttonText:(NSString *)aText isError:(BOOL)isError
{
    return [XAlert queryWith:aTitle message:aMessage button1:aText button2:nil isError:isError];
}

+(void)showInviteSuccessAlertView
{
    XAlertView *alertView = [[XAlertView alloc] initWithTitle: nil message:@"邀请好友成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
+(void)showAutomaticallyCutAlertView:(NSString *)mString
{
    mString = [mString substringWithRange:NSMakeRange(0, 4)];
    XAlertView *alertView = [[XAlertView alloc] initWithTitle: nil message:@"签名最多输入4位，系统将自动为您截取" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
   // alertView.tag = TAG_INVITE_SUCCESS;
    [alertView show];
    //[UConfig setSignName:mString];
}
+(void)showDisabledNetWorkAlertView
{
    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"邀请失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}
@end 
