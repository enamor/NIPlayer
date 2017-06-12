//
//  ViewController.m
//  NIPlayer
//
//  Created by zhouen on 2017/6/2.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "ViewController.h"
#import "NIPlayer.h"
#import <Masonry.h>
#import "NIPlayerMacro.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NIPlayer *avPlayer = [[NIPlayer alloc] init];
    [self.view addSubview:avPlayer];
    
    [avPlayer playWithUrl:_url];
    
    CGFloat wid = [UIScreen mainScreen].bounds.size.width;
    CGFloat hei = [UIScreen mainScreen].bounds.size.height;
    CGFloat rate = wid < hei ? (wid/hei) : (hei/wid);
    [avPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(avPlayer.mas_width).multipliedBy(rate);
    }];

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    APP.statusBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    APP.statusBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
