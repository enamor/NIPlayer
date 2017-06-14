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
    
    UIView *view = [[UIView alloc ] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    [self.view addSubview:view];
    
    NIPlayer *avPlayer = [[NIPlayer alloc] init];
    [self.view addSubview:avPlayer];
    
    
    
    [avPlayer playWithUrl:_url onView:view];
    


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

- (BOOL)shouldAutorotate {
    return NO;
}


@end
