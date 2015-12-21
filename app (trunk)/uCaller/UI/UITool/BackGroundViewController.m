//
//  BackGroundViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-6-25.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BackGroundViewController.h"

@interface BackGroundViewController ()

@end

@implementation BackGroundViewController
@synthesize touchDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];//[UIColor colorWithRed:(40/255.0f) green:(40/255.0f) blue:(40/255.0f) alpha:1.0f];
    self.view.alpha = 0.4;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.touchDelegate respondsToSelector:@selector(viewTouched)])
    {
        [self.touchDelegate performSelector:@selector(viewTouched) withObject:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
