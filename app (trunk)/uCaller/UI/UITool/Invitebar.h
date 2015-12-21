

#import <AVFoundation/AVFoundation.h>
#import "UIExpandingTextView.h"
#import "UDefine.h"

#define  keyboardHeight 216
#define  toolBarHeight 49
#define  facialViewWidth 300
#define facialViewHeight 170
#define  buttonWh 41

@protocol InviteBarDelegate <NSObject>
-(void)allSelect:(BOOL)isSelectAll;
-(void)sendInviteMsg;
@end

@interface InviteBar : UIToolbar<UIExpandingTextViewDelegate>

@property (UWEAK) NSObject<InviteBarDelegate> *delegate;
@property (nonatomic,strong) UIView *superView;
@property CGRect initialFrame;
@property CGRect expandFrame;
@property (strong,nonatomic) UIButton *menuButton;
@property (strong,nonatomic) UIButton *sendButton;

-(id)initFromView:(UIView *)superView;

-(void)dismissKeyBoard;

@end
