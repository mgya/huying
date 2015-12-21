//
//  MoreBoard.m
//  uCaller
//
//  Created by 张新花花花 on 15/7/24.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "MoreBoard.h"
#import "UDefine.h"

@implementation MoreBoard
@synthesize delegate;
@synthesize inputTextField = _inputTextField;
@synthesize inputTextView = _inputTextView;
- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, KDeviceWidth, 216)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:248.0/255.0 blue:250.0/255.0 alpha:1.0];
        
        moreView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 190)];
        NSArray *titleName = [NSArray arrayWithObjects:@"打电话",@"发图片",@"发位置",@"发名片", nil];
        NSArray *picNameNor = [NSArray arrayWithObjects:@"more_call_nor",@"more_msg_nor",@"more_location_nor",@"more_card_nor", nil];
        NSArray *picNameSel = [NSArray arrayWithObjects:@"more_call_sel",@"more_msg_sel",@"more_location_sel",@"more_card_sel", nil];
       for (int i = 0; i<4; i++) {
            UIButton *moreBtn = [[UIButton alloc]initWithFrame:CGRectMake((KDeviceWidth-45*KWidthCompare6*4)/5+(45*KWidthCompare6+(KDeviceWidth-45*KWidthCompare6*4)/5)*i,21*KWidthCompare6, 45*KWidthCompare6, 45*KWidthCompare6)];
            [moreBtn setBackgroundImage:[UIImage imageNamed:picNameNor[i]] forState:UIControlStateNormal];
            [moreBtn setBackgroundImage:[UIImage imageNamed:picNameSel[i]] forState:UIControlStateHighlighted];
            moreBtn.tag = i;
            [moreBtn addTarget:self action:@selector(moreClicked:) forControlEvents:UIControlEventTouchUpInside];
            [moreView addSubview:moreBtn];
            UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake((KDeviceWidth-45*KWidthCompare6*4)/5+(45*KWidthCompare6+(KDeviceWidth-45*KWidthCompare6*4)/5)*i, (21+45)*KWidthCompare6, 45*KWidthCompare6, 25*KWidthCompare6)];
            moreLabel.text = titleName[i];
            moreLabel.backgroundColor = [UIColor clearColor];
            moreLabel.textColor = [UIColor colorWithRed:89.0/255.0 green:89.0/255.0 blue:89.0/255.0 alpha:1.0];
            moreLabel.font = [UIFont systemFontOfSize:12];
            moreLabel.textAlignment = NSTextAlignmentCenter;
            [moreView addSubview:moreLabel];
        }
        
        

        //添加PageControl
        facePageControl = [[GrayPageControl alloc]initWithFrame:CGRectMake(KDeviceWidth/2-50, 190, 100, 20)];
        
        [facePageControl addTarget:self
                            action:@selector(pageChange:)
                  forControlEvents:UIControlEventValueChanged];
        
        facePageControl.numberOfPages = 1;
        facePageControl.currentPage = 0;
        facePageControl.backgroundColor = [UIColor clearColor];
        [self addSubview:facePageControl];
        
        //添加键盘View
        [self addSubview:moreView];
        
    }
    return self;
}
- (void)moreClicked:(UIButton *)sender{
    if (sender.tag == 0) {
        if (delegate && [delegate respondsToSelector:@selector(callBarButton)]) {
            [delegate callBarButton];
        }
    }else if (sender.tag == 1){
        if (delegate && [delegate respondsToSelector:@selector(msgBarButton)]) {
            [delegate msgBarButton];
        }
    }else if (sender.tag == 2){
        if (delegate && [delegate respondsToSelector:@selector(locBarButton)]) {
            [delegate locBarButton];
        }
    }else if (sender.tag == 3){
        if (delegate && [delegate respondsToSelector:@selector(cardBarButton)]) {
            [delegate cardBarButton];
        }
    }
}



//停止滚动的时候
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    [facePageControl setCurrentPage:moreView.contentOffset.x/KDeviceWidth];
//    [facePageControl updateCurrentPageDisplay];
//}
//
//- (void)pageChange:(id)sender {
//    [moreView setContentOffset:CGPointMake(facePageControl.currentPage*KDeviceWidth, 0) animated:YES];
//    [facePageControl setCurrentPage:facePageControl.currentPage];
//}

//- (void)faceButton:(id)sender {
//    int i = ((FaceButton*)sender).buttonIndex;
//    if (self.inputTextField) {
//        NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextField.text];
//        [faceString appendString:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d",i]]];
//        self.inputTextField.text = faceString;
//    }
//    if (self.inputTextView) {
//        NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextView.text];
//        [faceString appendString:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d",i]]];
//        self.inputTextView.text = faceString;
//        NSRange curSelectedRange = self.inputTextView.selectedRange;
//        [self.inputTextView.delegate textView:self.inputTextView shouldChangeTextInRange:curSelectedRange replacementText:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d",i]]];
//
//    }
//}

- (void)backFace
{
    NSRange curSelectedRange = self.inputTextView.selectedRange;
    [self.inputTextView.delegate textView:self.inputTextView shouldChangeTextInRange:NSMakeRange(curSelectedRange.location-1, 1) replacementText:@""];
}

@end
