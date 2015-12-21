//
//  AgreeViewController.m
//  PhoneMessage
//
//  Created by cz on 12-1-6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "AgreeViewController.h"
#import "UDefine.h"
#import "Util.h"  
#import "UIUtil.h"

#pragma mark Page size
#define stringColor			[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0]

#define PAGE_NAVBAR_VERTICAL_HEIGHT              43.0f
#define PAGE_NAVBAR_HORIZONTAL_HEIGHT            46.0f

#define PAGE_TABBAR_VERTICAL_HEIGHT              50.0f
#define PAGE_TABBAR_HORIZONTAL_HEIGHT            50.0f

#define PAGE_SEGMENTBAR_HEIGHT                   29.0f   

#define PAGE_VERTICAL_CONTENT_HEIGHT             (KDeviceHeight-20 - PAGE_NAVBAR_VERTICAL_HEIGHT - PAGE_TABBAR_VERTICAL_HEIGHT)
#define PAGE_VERTICAL_SEGBAR_CONTENT_HEIGHT      (PAGE_VERTICAL_CONTENT_HEIGHT - PAGE_SEGMENTBAR_HEIGHT)
#define PAGE_HORIZONTAL_CONTENT_HEIGHT           (KDeviceWidth - PAGE_NAVBAR_HORIZONTAL_HEIGHT)
#define PAGE_HORIZONTAL_SEGBAR_CONTENT_HEIGHT    (PAGE_HORIZONTAL_CONTENT_HEIGHT - PAGE_SEGMENTBAR_HEIGHT)

#define PAGE_LOADING_ICON_BIGSIZE                30.0f   
#define PAGE_LOADING_ICON_SMALLSIZE              20.0f

#define CONTENT_Y_OFFSET                         20.0f

#pragma mark credit page style
#define CREDIT_BG               [UIImage imageNamed:@"tzf_credit_bg.png"]
#define CREDIT_INTRO_BG         [UIImage imageNamed:@"alertView-bg.png"]

#pragma mark flight info style
#define FONT_FIGHTNO        [UIFont boldSystemFontOfSize:18]
#define FONT_COLOR_FIGHTNO  [UIColor whiteColor]

#define FONT_FLIGHTTIME         [UIFont systemFontOfSize:15]
#define FONT_COLOR_FLIGHTTIME   [UIColor whiteColor]

#define FONT_FLIGHTPRICE        [UIFont boldSystemFontOfSize:18]
#define FONT_COLOR_FLIGHTPRICE  INTCOLOR(0, 153.0, 0, 255.0)

#define FONT_FLIGHTINFO         [UIFont systemFontOfSize:14]
#define FONT_FLIGHTSMALLINFO    [UIFont systemFontOfSize:12]
#define FONT_FLIGHTSMALLSMALLINFO    [UIFont systemFontOfSize:10]

#define FONT_COLOR_URGENT       INTCOLOR(242.0, 63.0, 0.0, 255.0)
#define FONT_COLOR_IMPORTANT    INTCOLOR(10.0, 101.0, 195.0, 255.0)

#pragma mark status style
#define FONT_STATUS_COLOR_BLACK			[UIColor whiteColor]
#define FONT_STATUS_COLOR_GREEN			INTCOLOR(0.0, 153.0, 0.0, 255.0)
#define FONT_STATUS_COLOR_RED			INTCOLOR(242.0, 63.0, 0.0, 255.0)
#define FONT_STATUS_COLOR_BLUE			INTCOLOR(10.0, 101.0, 195.0, 255.0)
#define FONT_STATUS_COLOR_WHITE			[UIColor whiteColor]

#define FONT_STATUS_CITY			[UIFont systemFontOfSize:16]
#define FONT_STATUS_DATE			[UIFont systemFontOfSize:14]
#define FONT_STATUS_NO				[UIFont boldSystemFontOfSize:18]
#define FONT_STATUS_STATE			[UIFont boldSystemFontOfSize:18]
#define FONT_STATUS_TIME			[UIFont systemFontOfSize:14]
#define FONT_STATUS_DETAIL_TITLE	[UIFont boldSystemFontOfSize:14]
#define FONT_STATUS_DETAIL_TOP_CELL	[UIFont systemFontOfSize:16]
#define FONT_STAUTS_DETAIL_NO		[UIFont systemFontOfSize:18]
#define FONT_STATUS_DETAIL_CITY		[UIFont systemFontOfSize:16]
#define FONT_STATUS_DETAIL_DATE		[UIFont systemFontOfSize:14]
#define FONT_STATUS_DETAIL_STATE	[UIFont systemFontOfSize:18]
#define FONT_STATUS_DETAIL_FIRST_LINE	[UIFont systemFontOfSize:12]
#define FONT_STATUS_DETAIL_SECOND_LINE	[UIFont boldSystemFontOfSize:30]
#define FONT_LOADING_TITLE          [UIFont boldSystemFontOfSize:18]

#define FONT_STATE_INFO                 [UIFont systemFontOfSize:18]

#pragma mark credit style
#define FONT_CREDIT                     [UIFont boldSystemFontOfSize:24]
#define FONT_COLOR_CREDIT               [UIColor colorWithRed:217.0/255 green:51.0/255 blue:0.0/255 alpha:1.0]//INTCOLOR(217, 51, 0, 255.0)
#define FONT_CREDITINTRO_SECTION        [UIFont boldSystemFontOfSize:16]
#define FONT_COLOR_CREDITINTRO_SECTION  [UIColor blackColor]//[UIColor colorWithRed:127.0/255 green:27.0/255 blue:0.0/255 alpha:1.0]//INTCOLOR(127.0, 27.0, 0.0, 255.0)
#define FONT_CREDITINTRO_CONTENT        [UIFont boldSystemFontOfSize:14]
#define FONT_COLOR_CREDITINTRO_CONTENT  [UIColor grayColor]//[UIColor colorWithRed:127.0/255 green:27.0/255 blue:0.0/255 alpha:1.0]//INTCOLOR(127.0, 27.0, 0.0, 255.0)
#define FONT_CREDITINTRO_NOTE           [UIFont boldSystemFontOfSize:12]
#define FONT_COLOR_CREDITINTRO_NOTE     [UIColor whiteColor]//[UIColor colorWithRed:127.0/255 green:27.0/255 blue:0.0/255 alpha:1.0]//INTCOLOR(127.0, 27.0, 0.0, 255.0)
#define FONT_COLOR_CREDITINTRO_SHADOW   [UIColor whiteColor]//[UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0]//INTCOLOR(255.0, 247.0, 119.0, 255.0)


#pragma mark help page style
#define HELP_LONG_BTNS          [UIImage imageNamed:@"tzf_help_long_btns.png"]
#define HELP_LONG_BTN           [UIImage imageNamed:@"tzf_help_long_btn.png"]
#define HELP_SHORT_BTNS         [UIImage imageNamed:@"tzf_help_short_btns.png"]
#define HELP_SHORT_BTN          [UIImage imageNamed:@"tzf_help_short_btn.png"]


#define INFOSTR					NSLocalizedString(@"使用协议", @"")
#define BACKPAGETITLE			NSLocalizedString(@"  使用协议", @"")
#define SECTIONONE              NSLocalizedString(@"《呼应服务条款》",@"")
#define SECTIONONECONTENT       NSLocalizedString(@"1 服务概述\n本服务条款是用户（您）与北京呼应网络科技有限公司之间的协议。\n\n1.1 重要须知：北京呼应网络科技有限公司在此特别提醒，用户（您）欲访问和使用呼应网站，必须事先认真阅读本服务条款中各条款，包括免除或者限制北京呼应网络科技有限公司责任的免责条款及对用户的权利限制。请您审阅并接受或不接受本服务条款（未成年人审阅时应得到法定监护人的陪同）。如您不同意本服务条款及/或随时对其的修改，您应不使用或主动取消北京呼应网络科技有限公司提供的服务。您的使用行为将被视为您对本服务条款全部的完全接受，包括接受北京呼应网络科技有限公司对服务条款随时所做的任何修改。\n\n1.2 这些条款可由北京呼应网络科技有限公司随时更新，且毋须另行通知。北京呼应网络科技有限公司服务条款（以下简称“服务条款”）一旦发生变更, 北京呼应网络科技有限公司将在网页上公布修改内容。修改后的服务一旦在网页上公布即有效代替原来的服务条款。您可随时登录呼应网站查阅最新版服务条款。\n\n1.3 呼应目前经由其产品服务组合，向用户提供网上及线下资源及诸多产品与服务，包括但不限于各种网络通信工具、通信录软件及服务、电信增值服务等（以下简称“服务”或“本服务”）。本服务条款适用于呼应提供的各种服务，但当您使用呼应某一特定服务时，如该服务另有单独的服务条款、指引或规则，您应遵守本服务条款及北京呼应网络科技有限公司随时公布的与该服务相关的服务条款、指引或规则等。前述所有的指引和规则，均构成本服务条款的一部分。除非本服务条款另有其他明示规定，新推出的产品或服务、增加或强化目前本服务的任何新功能，均受到本服务条款之规范。\n\n2 用户使用规则\n\n2.1 用户必须自行配备上网和使用电信增值业务所需的设备，自行负担个人上网或第三方（包括但不限于电信或移动通信提供商）收取的通信费、信息费等有关费用。如涉及电信增值服务的，我们建议您与您的电信增值服务提供商确认相关的费用问题。\n\n2.2 除您与北京呼应网络科技有限公司另有约定外，您同意本服务仅供个人使用且非商业性质的使用，您不可对本服务任何部分或本服务之使用或获得（包括但不限于呼应号码），进行复制、拷贝、出售、或利用本服务进行调查、广告、或用于其他商业目的，其中，您不得将任何广告信函与信息、促销资料、垃圾邮件与信息、滥发邮件与信息、直销及传销邮件与信息以网络电话、信息、彩信、邮件、即时通信、文件分享或以其他方式传送，但北京呼应网络科技有限公司对特定服务另有适用指引或规则的除外。\n\n2.3 不得发送任何妨碍社会治安或非法、虚假、骚扰性、侮辱性、恐吓性、伤害性、破坏性、挑衅性、庸俗性、淫秽色情性等内容的信息。\n\n2.4 保证自己在使用各服务时用户身份的真实性和正确性及完整性，如果资料发生变化，您应及时更改。在安全完成本服务的登记程序并收到一个密码及账号后，您应维持密码及账号的机密安全。您应对任何人利用您的密码及账号（包括但不限于呼应号码，呼应号的捆绑手机号码等）所进行的活动负完全的责任，北京呼应网络科技有限公司无法对非法或未经您授权使用您账号及密码的行为作出甄别，因此北京呼应网络科技有限公司不承担任何责任。在此，您同意并承诺做到∶\n\n2.4.1 当您的密码或账号遭到未获授权的使用，或者发生其他任何安全问题时，您会立即有效通知到北京呼应网络科技有限公司。\n\n2.4.2 当您每次上网或使用其他服务完毕后，会将有关账号，例如呼应号码等安全退出。\n\n2.5 用户同意接受北京呼应网络科技有限公司通过手机信息、呼应客户端软件、网页或其他合法方式向用户发送商品促销或其他相关商业信息。在使用电信增值服务的情况下，用户同意接受本公司及合作公司通过增值服务系统或其他方式向用户发送的相关服务信息或其他信息，其他信息包括但不限于通知信息、宣传信息、广告信息等。\n\n2.6 关于收费服务\n\n2.6.1 北京呼应网络科技有限公司的某些服务是以收费方式提供的。一旦您本人或他人（包括您的代理）通过个人账户购买收费服务，您应按有关的收费标准、付款方式支付相关服务费及其他费用。资费说明标明在呼应网站相应服务的相应页面上。您可以通过我们的客户服务中心选择取消相关付费服务。在您正式取消相关服务并经呼应批准前，我们将按相关服务收费标准与方式继续收费。\n\n2.7 依本服务条款所取得的服务权利不可转让。\n\n2.8 您需要严格遵守国家的有关法律、法规和行政规章制度。如用户违反国家法律法规或本服务条款，本公司和合作公司将有权停止向用户提供服务而不需承担任何责任，如导致北京呼应网络科技有限公司遭受任何损害或遭受任何来自第三方的纠纷、诉讼、索赔要求等，用户须向本公司赔偿相应的损失，用户并需对其违反服务条款所产生的一切后果负全部法律责任。\n\n3 服务风险及免责声明\n\n3.1 用户须明白，本服务仅依其当前所呈现的状况提供，本服务涉及到互联网及相关通信等服务，可能会受到各个环节不稳定因素的影响。因此服务存在因上述不可抗力、计算机病毒或黑客攻击、系统不稳定、用户所在位置、用户关机、通信网络、互联网络原因等造成的服务中断或不能满足用户要求的风险。开通服务的用户须承担以上风险，本公司对服务之及时性、安全性、准确性不作担保，对因此导致用户不能发送和接受阅读信息、或传递错误，个人设定之时效、未予储存或其他问题不承担任何责任。\n\n3.2 如本公司的系统发生故障影响到本服务的正常运行，本公司承诺在第一时间内与相关单位配合，及时处理进行修复。但用户因此而产生的经济损失，本公司不承担责任。此外，北京呼应网络科技有限公司保留不经事先通知为维修保养、升级或其他目的暂停本服务任何部分的权利。\n\n3.3 北京呼应网络科技有限公司在此郑重提醒您注意，任何经由本服务上载、发送即时信息、电子邮件或任何其他方式传送的资讯、资料、文字、软件、音乐、音讯、照片、图形、视讯、信息、用户的登记资料或其他资料（以下简称“内容”），均由内容提供者承担责任。北京呼应网络科技有限公司无法控制经由本服务传送之内容，也无法对用户的使用行为进行全面控制，因此不保证内容的合法性、正确性、完整性、真实性或品质；您已预知使用本服务时，可能会接触到令人不快、不适当或令人厌恶之内容，并同意将自行加以判断并承担所有风险，而不依赖于北京呼应网络科技有限公司。但在任何情况下，北京呼应网络科技有限公司有权依法停止传输任何前述内容并采取相应行动，包括但不限于暂停用户使用本服务的全部或部分，保存有关记录，并向有关机关报告。但北京呼应网络科技有限公司有权(但无义务)依其自行之考量，拒绝和删除可经由本服务提供之违反本条款的或其他引起北京呼应网络科技有限公司或其他用户反感的任何内容。\n\n3.4 关于使用及储存之一般措施：您承认关于本服务的使用北京呼应网络科技有限公司有权制订一般措施及限制，包含但不限于本服务将保留用户个人信息、电子邮件信息、通信资料信息、所上载内容之最长期间、本服务一个账号当中可收发电子邮件或手机信息等的最大数量、本服务一个账号当中可收发的单个信息或电子邮件的大小、呼应服务器为您分配的最大使用空间，以及一定期间内您使用本服务之次数上限（及每次使用时间之上限）。通过本服务存储或传送任何信息、通信资料和其他内容，如被删除或未予储存，您同意呼应毋须承担任何责任。您也同意，长时间未使用的账号，北京呼应网络科技有限公司有权关闭并收回账号。您也同意，北京呼应网络科技有限公司有权依其自行之考量，不论通知与否，随时变更这些一般措施及限制。\n\n3.5 链接服务：本服务或第三方可提供与其他国际互联网上之网站或资源之链接。由于呼应无法控制这些网站及资源，您了解并同意：无论此类网站或资源是否可供利用，北京呼应网络科技有限公司不予负责；北京呼应网络科技有限公司也对存在或源于此类网站或资源之任何内容、广告、产品或其他资料不予保证或负责。因您使用或依赖任何此类网站或资源发布的或经由此类网站或资源获得的任何内容、商品或服务所产生的任何损害或损失，北京呼应网络科技有限公司不负任何直接或间接之责任。若您认为该链接所载的内容侵犯您的权利，北京呼应网络科技有限公司声明与上述内容无关，不承担任何责任。北京呼应网络科技有限公司建议您与该网站或法律部门联系，寻求法律保护。\n\n4 服务变更、中断或终止及服务条款的修改\n\n4.1 本服务的所有权和运作权、一切解释权归北京呼应网络科技有限公司。北京呼应网络科技有限公司提供的服务将按照其发布的章程、服务条款和操作规则严格执行。\n\n4.2 本公司有权在必要时修改服务条款，服务条款一旦发生变动，将会在相关页面上公布修改后的服务条款。如果不同意所改动的内容，用户应主动取消此项服务。如果用户继续使用服务，则视为接受服务条款的变动。\n\n4.3 本公司和合作公司有权按需要修改或变更所提供的收费服务、收费标准、收费方式、服务费、及服务条款。北京呼应网络科技有限公司在提供服务时，可能现在或日后对部分服务的用户开始收取一定的费用如用户拒绝支付该等费用，则不能在收费开始后继续使用相关的服务。但北京呼应网络科技有限公司和合作公司将尽最大努力通过有效方式通知用户有关的修改或变更。\n\n4.4 本公司特别提请用户注意，本公司为了保障公司业务发展和调整的自主权，本公司拥有经或未经事先通知而修改服务内容、中断或中止部分或全部服务的权利，修改会以通告形式公布于呼应网站相关页面上，一经公布视为通知。北京呼应网络科技有限公司行使修改或中断服务的权利而造成损失的，北京呼应网络科技有限公司不需对用户或任何第三方负责。\n\n4.5 如发生下列任何一种情形，本公司有权随时中断或终止向用户提供服务而无需通知用户：\n\n4.5.1 用户提供的个人资料不真实；\n\n4.5.2 用户违反本服务条款的规定；\n\n4.5.3 按照主管部门的要求；\n\n4.5.4 其他本公司认为是符合整体服务需求的特殊情形。\n\n5 信息内容的所有权\n\n5.1 本公司定义的信息内容包括：文字、软件、声音、相片、呼应网页、广告中全部内容、本公司为用户提供的其它商业信息。所有这些内容受版权、商标权、和其它知识产权和所有权法律的保护。所以，用户只能在本公司和相关权利人授权下才能使用这些内容，而不能擅自使用、抄袭、复制、修改、编撰这些内容、或创造与内容有关的衍生产品。\n\n5.2 关于北京呼应网络科技有限公司提供的软件：您了解并同意，本服务及本服务所使用或提供之相关软件是由北京呼应网络科技有限公司拥有所有相关知识产权及其他法律保护之专有之知识产权（包括但不限于版权、商标权、专利权及商业秘密）资料。若就某一具体软件存在单独的最终用户软件授权协议，您除应遵守本协议有关规定外，亦应遵守该软件授权协议。　除非您也同意该软件授权协议，否则您不得安装或使用该软件。对于未提供单独的软件授权协议的软件，除您应遵守本服务协议外，北京呼应网络科技有限公司或所有权人仅将为您个人提供可取消、不可转让、非专属的软件授权许可，并仅为访问或使用本服务之目的而使用该软件。此外，在任何情况下，未经北京呼应网络科技有限公司明示授权，您均不得修改、出租、出借、出售、散布本软件之任何部份或全部，或据以制作衍生著作，或使用擅自修改后的软件，或进行还原工程、反向编译，或以其他方式发现原始编码，包括但不限于为了未经授权而使用本服务之目的。您同意将通过由北京呼应网络科技有限公司所提供的界面而非任何其他途径使用本服务。\n\n6 法律\n\n6.1 本服务条款要与国家相关法律、法规一致，如发生服务条款与相关法律、法规条款有相抵触的内容，抵触部分以法律、法规条款为准。\n\n7 保障\n\n7.1 用户同意保障和维护本公司全体成员的利益，负责支付由用户使用超出服务范围或不当使用服务引起的一切费用（包括但不限于：律师费用、违反服务条款的损害补偿费用以及其它第三方使用用户的电脑、账号和其它知识产权的追索费）。\n\n7.2 用户须对违反国家法律规定及本服务条款所产生的一切后果承担法律责任。\n\n8 其它\n\n8.1 如本服务条款中的任何条款无论因何种原因完全或部分无效或不具有执行力，本服务条款的其余条款仍应有效且具有约束力，并且努力使该规定反映之意向具备效力。\n\n8.2 每项服务的内容、收费标准、收费方式、服务费及服务条款应以最后发布通知为准。\n\n8.3 用户对服务之任何部分或本服务条款的任何部分之意见及建议可通过呼应客户服务部与我们联系：95013790000\n\n8.5 本服务条款的解释、效力及纠纷的解决，适用于中华人民共和国法律。若用户和北京呼应网络科技有限公司之间发生任何纠纷或争议，首先应友好协商解决，协商不成的，用户在此完全同意将纠纷或争议提交北京呼应网络科技有限公司所在地法院管辖。\n\n8.6 北京呼应网络科技有限公司，保留本服务条款之解释权。",@"")

#define SECTIONTHREE            NSLocalizedString(@"", @"")
#define SECTIONTHREECONTENT     NSLocalizedString(@"", @"")

#define SECTIONFOUR             NSLocalizedString(@"", @"")
#define SECTIONFOURCONTENT       NSLocalizedString(@"",@"")

#define PHONENUMERSTR           NSLocalizedString(@"", @"")
#define DIALSTR                 NSLocalizedString(@"", @"")
#define CANCELSTR               NSLocalizedString(@"", @"")
#define PHONEURL                NSLocalizedString(@"", @"")
#define EMAILSTR                NSLocalizedString(@"", @"")
#define EMAILURL                NSLocalizedString(@"", @"")
#define SENDMAILSTR             NSLocalizedString(@"", @"")
#define PHONE2URL               NSLocalizedString(@"", @"")
#define PHONENUMER2STR          NSLocalizedString(@"", @"")
#define DIAL2STR                NSLocalizedString(@"", @"")

#define MARGIN                  18.0f
#define CONTENT_MARGIN          20.0f
#define CONTENT_SMARGIN         10.0f
#define SHADOW_OFFSET           CGSizeMake(1.0f, -1.0f)
#define MAXLABELHEIGHT  8000

enum {
    TAG_CALLBUTTON = 101,
    TAG_CALL2BUTTON,
    TAG_CALLACTION,
    TAG_MAILBUTTON,
    TAG_MAILACTION,
    TAG_CALL2ACTION
};

@interface AgreeViewController()
-(UIView *)buildHelpSection:(NSString *)aSectionTitle sectionContent:(NSString *)aSectionContent sectionNote:(NSString *)aSectionNote;
-(UIButton *)buildDailingButton:(CGPoint)aPosition title:(NSString *)aTitle tag:(int)aTag isShort:(BOOL)aIsShort;
@end

@implementation AgreeViewController
@synthesize myAppVersion;

- (id)init
{
	if (self = [super init]) {
		//self.myBackPageName = BACKPAGETITLE;
        self.myAppVersion = @"2.0.2.2";
	}
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)viewDidLoad
{
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"隐私协议和服务条款";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];

    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"uc_loginbg" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, KDeviceWidth-20, KDeviceHeight)];
	backgroundImage.image = image;
	[self.view addSubview:backgroundImage];
    int credit_intro_width = KDeviceWidth-30;
    UIScrollView *contentView = [[UIScrollView alloc]initWithFrame:CGRectMake((int)((KDeviceWidth - credit_intro_width) / 2.0f), LocationY, KDeviceWidth,KDeviceHeight-LocationY)];
    contentView.bounces = NO;
    float height = 0.0f;
    UIView *sectionOne = [self buildHelpSection:[NSString stringWithFormat:SECTIONONE] sectionContent:SECTIONONECONTENT sectionNote:nil];
    sectionOne.frame = CGRectMake((int)((credit_intro_width - sectionOne.frame.size.width) / 2.0f), height,
                                  sectionOne.frame.size.width, sectionOne.frame.size.height);
    [contentView addSubview:sectionOne];
    height = height + sectionOne.frame.size.height + MARGIN;
    
    UIView *sectionFour = [self buildHelpSection:SECTIONFOUR sectionContent:SECTIONFOURCONTENT sectionNote:nil];
    sectionFour.frame = CGRectMake((int)((credit_intro_width - sectionFour.frame.size.width) / 2.0f), height,
                                   sectionFour.frame.size.width, sectionFour.frame.size.height);
    [contentView addSubview:sectionFour];
    height = height + sectionFour.frame.size.height + MARGIN;
    
    UIView *sectionThree = [self buildHelpSection:SECTIONTHREE sectionContent:SECTIONTHREECONTENT sectionNote:nil];
    sectionThree.frame = CGRectMake((int)((credit_intro_width - sectionThree.frame.size.width) / 2.0f), height,
                                    sectionThree.frame.size.width, sectionThree.frame.size.height);
    [contentView addSubview:sectionThree];
    height = height + sectionThree.frame.size.height;
    
    contentView.contentSize = CGSizeMake(credit_intro_width, height + 5.0f);
    [self.view addSubview:contentView];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(goback:)];
}

-(void)returnLastPage{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIView *)buildHelpSection:(NSString *)aSectionTitle sectionContent:(NSString *)aSectionContent sectionNote:(NSString *)aSectionNote
{
    if (aSectionTitle == nil || aSectionContent == nil)
        return nil;
    float height = 0;
    int credit_intro_width = KDeviceWidth-16;//CREDIT_INTRO_BG.size.width;
    
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectZero];
    
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    sectionLabel.font =  FONT_CREDITINTRO_SECTION;
    sectionLabel.backgroundColor = [UIColor clearColor];
    sectionLabel.textColor = FONT_COLOR_CREDITINTRO_SECTION;
    sectionLabel.shadowColor = FONT_COLOR_CREDITINTRO_SHADOW;
    sectionLabel.shadowOffset = SHADOW_OFFSET;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize size = [aSectionTitle sizeWithFont:sectionLabel.font constrainedToSize:CGSizeMake(credit_intro_width - (CONTENT_MARGIN * 2), MAXLABELHEIGHT)
                                lineBreakMode:NSLineBreakByTruncatingTail];
#pragma clang diagnostic pop
    sectionLabel.frame = CGRectMake(0, 0, size.width, size.height);
    sectionLabel.numberOfLines = 0;
    sectionLabel.text = aSectionTitle;
    [sectionView addSubview:sectionLabel];
    
    height = size.height + CONTENT_SMARGIN;
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contentLabel.font =  FONT_CREDITINTRO_CONTENT;
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = FONT_COLOR_CREDITINTRO_CONTENT;
    contentLabel.shadowColor = FONT_COLOR_CREDITINTRO_SHADOW;
    contentLabel.shadowOffset = SHADOW_OFFSET;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    size = [aSectionContent sizeWithFont:contentLabel.font constrainedToSize:CGSizeMake(credit_intro_width - (CONTENT_MARGIN * 2), MAXLABELHEIGHT)
                           lineBreakMode:NSLineBreakByTruncatingTail];
#pragma clang diagnostic pop
    contentLabel.frame = CGRectMake(0, height, size.width, size.height);
    contentLabel.numberOfLines = 0;
    contentLabel.text = aSectionContent;
    [sectionView addSubview:contentLabel];
    
    height = height + size.height;
    if (aSectionNote != nil)
    {
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        noteLabel.font =  FONT_CREDITINTRO_NOTE;
        noteLabel.backgroundColor = [UIColor clearColor];
        noteLabel.textColor = FONT_COLOR_CREDITINTRO_NOTE;
        noteLabel.shadowColor = FONT_COLOR_CREDITINTRO_SHADOW;
        noteLabel.shadowOffset = SHADOW_OFFSET;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [aSectionNote sizeWithFont:noteLabel.font constrainedToSize:CGSizeMake(credit_intro_width - (CONTENT_MARGIN * 2), MAXLABELHEIGHT)
                            lineBreakMode:NSLineBreakByTruncatingTail];
#pragma clang diagnostic pop
        noteLabel.frame = CGRectMake(0, height, size.width, size.height);
        noteLabel.numberOfLines = 0;
        noteLabel.text = aSectionNote;
        [sectionView addSubview:noteLabel];
        height = height + size.height;
    }
    sectionView.frame = CGRectMake(0.0f, 0.0f, credit_intro_width - (CONTENT_MARGIN * 2), height);
    return sectionView;
}

-(UIButton *)buildDailingButton:(CGPoint)aPosition title:(NSString *)aTitle tag:(int)aTag isShort:(BOOL)aIsShort
{
    //int credit_intro_width = CREDIT_INTRO_BG.size.width;
    //CGSize size = [aTitle sizeWithFont:FONT_CREDITINTRO_CONTENT constrainedToSize:CGSizeMake(credit_intro_width - (CONTENT_MARGIN * 2), 200)
    //lineBreakMode:UILineBreakModeTailTruncation];
    UIImage *btnImg, *btnsImg;
    
    if (aIsShort)
    {
        btnImg = HELP_SHORT_BTN;
        btnsImg = HELP_SHORT_BTNS; 
    } else {
        btnImg = HELP_LONG_BTN;
        btnsImg = HELP_LONG_BTNS; 
    }
    UIButton  *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(aPosition.x, aPosition.y, btnImg.size.width, btnImg.size.height);
    [button setBackgroundImage:btnImg forState:UIControlStateNormal];
    [button setBackgroundImage:btnsImg forState:UIControlStateHighlighted];
    [button setTitle:aTitle forState:UIControlStateNormal];
    [button setTitleColor:FONT_COLOR_CREDITINTRO_CONTENT forState:UIControlStateNormal];
    button.titleLabel.font = FONT_CREDITINTRO_CONTENT;
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [button setTag:aTag];
    return button;
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = INFOSTR;
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc {

}

- (void)clickButton:(id)sender
{
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == TAG_CALLACTION && buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PHONEURL]];
    } else if (actionSheet.tag == TAG_CALL2ACTION && buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PHONE2URL]];
    } else if (actionSheet.tag == TAG_MAILACTION && buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:EMAILURL]];
    } 
}
@end

