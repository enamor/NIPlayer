//
//  ViewController.m
//  FullDemo
//
//  Created by zhouen on 2017/7/5.
//  Copyright © 2017年 nina. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIView *palyerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _palyerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 255)];
    _palyerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_palyerView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)btnAction {
//    CGFloat sw = [[UIScreen mainScreen] bounds].size.width;
//    CGFloat sh = [[UIScreen mainScreen] bounds].size.height;
//    CGFloat width = sw > sh ? sw : sh;
//    CGFloat height = sh > sw ? sw : sh;
    CGFloat height = self.palyerView.superview.frame.size.width;
    CGFloat width = self.palyerView.superview.frame.size.height;
    CGAffineTransform tranform = CGAffineTransformMakeRotation(M_PI_2);
    [UIView animateWithDuration:0.3f animations:^{
        self.palyerView.frame = CGRectMake((height -width)/2.0,(width - height)/2.0, width, height);
        [self.palyerView setTransform:tranform];
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
