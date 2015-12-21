//
//  FaceBoard.m
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood

#import "FaceBoard.h"
#import "UDefine.h"

@implementation FaceBoard
@synthesize inputTextField = _inputTextField;
@synthesize inputTextView = _inputTextView;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, KDeviceWidth, 216)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:248.0/255.0 blue:250.0/255.0 alpha:1.0];
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"faceMap_ch" ofType:@"plist"]];
        //表情盘
        faceView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 190)];
        faceView.pagingEnabled = YES;
        faceView.contentSize = CGSizeMake((126/21)*KDeviceWidth, 190);//120为表情总个人，28是每页的表情个数，7为每页每行7个表情
        faceView.showsHorizontalScrollIndicator = NO;
        faceView.showsVerticalScrollIndicator = NO;
        faceView.delegate = self;
        
        for (int i = 1; i<=126; i++)
        {
                FaceButton *faceButton = [FaceButton buttonWithType:UIButtonTypeCustom];
                faceButton.buttonIndex = i;
            
            //计算每一个表情按钮的坐标和在哪一屏
            //原来表情宽度算法是两边分20和25，每个表情btn宽度是35，间距是5
            //现在只是把每个btn宽度按比例拉伸，同时在btn上增加了UIImageView
            float kW = (KDeviceWidth-50.0)/(320.0-50.0);
            float btnWidth = 20.0*kW;
            if (i == 21||i == 42 || i == 63|| i == 84 || i ==105 ||i == 126) {
                //删除键
                UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
                [back setTitle:@"删除" forState:UIControlStateNormal];
                [back setImage:[UIImage imageNamed:@"backFace"] forState:UIControlStateNormal];
                [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
                back.frame = CGRectMake((((i-1)%21)%7)*btnWidth+btnWidth*((i-1)%7)+30+((i-1)/21*KDeviceWidth), (((i-1)%21)/7)*27+27*((i-1)%21/7+1), 2*btnWidth, 25);
                [faceView addSubview:back];

            }else{
                [faceButton addTarget:self
                               action:@selector(faceButton:)
                     forControlEvents:UIControlEventTouchUpInside];
                
                faceButton.frame = CGRectMake((((i-1)%21)%7)*btnWidth+btnWidth*((i-1)%7)+20+((i-1)/21*KDeviceWidth), (((i-1)%21)/7)*27+27*((i-1)%21/7+1), 2*btnWidth, 25);
                UIImage *faceImage = [UIImage imageNamed:[NSString stringWithFormat:@"%03d",i]];
                UIImageView *btnFaceImgView = [[UIImageView alloc]initWithFrame:CGRectMake((faceButton.frame.size.width-25.0)/2, 0, 25, faceButton.frame.size.height)];
                btnFaceImgView.image = faceImage;
                btnFaceImgView.backgroundColor = [UIColor clearColor];
                [faceButton addSubview:btnFaceImgView];
                [faceView addSubview:faceButton];
            }
            
            
        }
        
        //添加PageControl
        facePageControl = [[GrayPageControl alloc]initWithFrame:CGRectMake(KDeviceWidth/2-50, 180, 120, 24)];
        
        [facePageControl addTarget:self
                            action:@selector(pageChange:)
                  forControlEvents:UIControlEventValueChanged];
        
        facePageControl.numberOfPages = 126/21;
        facePageControl.currentPage = 0;
        facePageControl.currentPageIndicatorTintColor = [UIColor clearColor];
        facePageControl.pageIndicatorTintColor = [UIColor clearColor];
        [self addSubview:facePageControl];
        
        //添加键盘View
        [self addSubview:faceView];
        
    }
    return self;
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [facePageControl setCurrentPage:faceView.contentOffset.x/KDeviceWidth];
    [facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {
    [faceView setContentOffset:CGPointMake(facePageControl.currentPage*KDeviceWidth, 0) animated:YES];
    [facePageControl setCurrentPage:facePageControl.currentPage];
}

- (void)faceButton:(id)sender {
    int i = ((FaceButton*)sender).buttonIndex;
    if (self.inputTextField) {
        NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextField.text];
        [faceString appendString:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d",i]]];
        self.inputTextField.text = faceString;
    }
    if (self.inputTextView) {
        NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextView.text];
        [faceString appendString:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d",i]]];
        self.inputTextView.text = faceString;
        NSRange curSelectedRange = self.inputTextView.selectedRange;
        [self.inputTextView.delegate textView:self.inputTextView shouldChangeTextInRange:curSelectedRange replacementText:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d",i]]];
    }
}

- (void)backFace
{
    NSRange curSelectedRange = self.inputTextView.selectedRange;
    [self.inputTextView.delegate textView:self.inputTextView shouldChangeTextInRange:NSMakeRange(curSelectedRange.location-1, 1) replacementText:@""];
}

@end
